# vLLM Decode Workload Trace Schema

This trace is for RDNA3 fixed-grid capacity planning. It is not a profiler
trace. It records the workload metadata needed to estimate how many compacted
work items a paged-KV decode/gather kernel would launch.

Current formal replay input:

```text
experiments/rdna3_gather/trace/vllm_decode_block_table_v2_strict_kvlayout_true/jsonl_flattened
```

This v2 trace is decode-only (`q_len == 1`), one sequence per replay row, carries
real `sequences[].block_ids`, row provenance, and
`kv_cache_layout.available=true`. The sibling `jsonl/` directory keeps batched
metadata records for provenance and inspection; current replay kernels consume
`jsonl_flattened/`.

For replay, numeric `block_ids` are scoped by KV layout identity. The same block
ID in a different layer or a different KV-cache allocation is not the same
address range. Current replay tools use `(k_data_ptr, v_data_ptr, layer)` when
available, with file/layer fallback for older traces.

## Collection Unit

Record one row per attention invocation shape, not one row per physical GPU
kernel.

Preferred unit:

- One decode scheduler/model-runner step.
- One model layer is enough if all layers share the same active request set and
  KV-cache metadata for that step.
- If vLLM calls different attention kernels with different shapes in the same
  step, record one row per distinct attention call.

Do not collect during warmup when benchmarking latency. Trace collection may
copy tiny metadata to CPU and will pollute timing. Run a separate trace-only
session, then run performance separately.

## Required Output Format

Use `.jsonl` or `.csv`. JSONL is preferred because arrays are unambiguous.
Each line is one trace record.

Minimum JSONL record:

```json
{
  "schema_version": 1,
  "trace_id": "decode_step_000123_layer_0",
  "phase": "decode",
  "capture_point": "after_scheduler_before_attention_launch",
  "batch_size": 12,
  "q_len": 1,
  "num_q_heads": 32,
  "num_kv_heads": 8,
  "head_dim": 128,
  "dtype": "fp16",
  "kv_dtype": "fp16",
  "page_block_size": 16,
  "cache_seqlens": [108, 2048, 513, 7, 91, 4096, 1024, 38, 64, 819, 1300, 11],
  "block_table_valid_counts": [7, 128, 33, 1, 6, 256, 64, 3, 4, 52, 82, 1],
  "block_table_shape": [12, 256],
  "sliding_window": null,
  "scheduler_active_tokens": 12
}
```

If you can compute the intended work item count in vLLM, also include:

```json
{
  "actual_work_size": 12345,
  "work_item_formula": "sum_b ceil(effective_kv_len[b] / chunk_tokens) * num_kv_heads"
}
```

`actual_work_size` is the best field when available. It avoids ambiguity about
how the future kernel maps heads, query tokens, and KV chunks to blocks.

## Field Semantics

Do not infer these fields only from variable names. Use these definitions.

| field | required | meaning |
| --- | --- | --- |
| `schema_version` | yes | Integer schema version. Use `1`. |
| `trace_id` | yes | Stable unique ID for this trace row. Include step and layer/call index if available. |
| `phase` | yes | Use `"decode"` for one/few-token decode. Use `"prefill"` only if this row is prefill. |
| `capture_point` | yes | Human-readable point where trace was captured. Recommended: `"after_scheduler_before_attention_launch"`. |
| `batch_size` | yes | Number of active sequences/requests in this attention call. Must match length of `cache_seqlens`. |
| `q_len` | yes | Number of query tokens per active sequence for this attention call. Decode is usually `1`, but do not assume. |
| `num_q_heads` | yes | Number of query heads consumed by the attention call. |
| `num_kv_heads` | yes | Number of KV heads in the cache. For MQA/GQA this is smaller than `num_q_heads`. |
| `head_dim` | yes | Per-head dimension. |
| `dtype` | yes | Query/output compute dtype, for example `fp16` or `bf16`. |
| `kv_dtype` | yes | KV-cache storage dtype. If quantized, write the actual storage format, not just the dequant compute type. |
| `page_block_size` | yes for paged KV | Tokens per KV page/block. This is not the number of blocks. |
| `cache_seqlens` | yes | Effective KV length per active sequence at the attention call. Define whether it is before or after appending the current token in `notes`. |
| `block_table_valid_counts` | strongly recommended | Number of valid physical KV pages per active sequence. Usually `ceil(cache_seqlens / page_block_size)`, but record actual table-valid count when available. |
| `block_table_shape` | recommended | Shape of the block table used by the attention call, usually `[batch_size, max_blocks_per_seq]`. |
| `sliding_window` | recommended | `null` for full-context attention, or integer effective window size. |
| `scheduler_active_tokens` | recommended | Total active scheduled tokens in this step. For simple decode this equals `batch_size * q_len`. |
| `actual_work_size` | optional but best | Exact compacted work items for our future kernel mapping, if you compute it at collection time. |
| `work_item_formula` | required if `actual_work_size` is present | Text description of the formula used to compute `actual_work_size`. |
| `notes` | optional | Add details such as “cache_seqlens measured before append” or “spec decode accepted tokens only”. |

## Derived Fields We Will Compute

For a first capacity estimate, we can derive:

```text
effective_kv_len[b] =
    min(cache_seqlens[b], sliding_window) if sliding_window is not null
    else cache_seqlens[b]

kv_chunks[b] = ceil(effective_kv_len[b] / chunk_tokens)
```

Candidate work-size formulas:

```text
KV-head gather mapping:
actual_work_size = sum_b kv_chunks[b] * num_kv_heads * q_len

Q-head mapping:
actual_work_size = sum_b kv_chunks[b] * num_q_heads * q_len

GQA-group mapping:
actual_work_size = sum_b kv_chunks[b] * num_kv_heads * groups_per_kv_head * q_len
where groups_per_kv_head = num_q_heads / num_kv_heads
```

Which formula is correct depends on the future kernel ownership model. That is
why raw trace fields are required even if `actual_work_size` is provided.

## When To Capture

Capture after vLLM has finalized the active sequence set and KV-cache mapping
for the step, and immediately before the attention call consumes the metadata.

Good capture point:

```text
scheduler/model runner has selected active sequences
KV block table / slot mapping / cache lengths are ready
attention backend is about to launch
```

Bad capture points:

- Before scheduler filtering: includes requests that may not run this step.
- Before block allocation or append decisions: page count may be wrong.
- After attention if `cache_seqlens` has already been mutated and you cannot
  tell whether it is before or after append.
- Inside latency timing with synchronous CPU copies.

If the only convenient point is after append, it is still usable, but add:

```json
{"notes": "cache_seqlens measured after appending current decode token"}
```

## How To Collect Safely

Run a separate trace-only workload. Sampling is fine.

Recommended policy:

- Skip warmup steps.
- Record at most one layer per decode step unless layer shapes differ.
- Sample every N steps if output is too large.
- Stop after 1k to 10k trace rows.
- Move only small metadata tensors to CPU, never KV cache tensors.

Pseudo-code:

```python
def tensor_list(x):
    if x is None:
        return None
    if isinstance(x, int):
        return [int(x)]
    return [int(v) for v in x.detach().cpu().reshape(-1).tolist()]

def record_decode_trace(
    sink,
    step_id,
    layer_id,
    q,
    cache_seqlens,
    block_table,
    num_q_heads,
    num_kv_heads,
    head_dim,
    page_block_size,
    dtype,
    kv_dtype,
    sliding_window=None,
    notes="",
):
    seqlens = tensor_list(cache_seqlens)
    if len(seqlens) == 1 and q.shape[0] != 1:
        seqlens = seqlens * int(q.shape[0])

    valid_counts = None
    block_shape = None
    if block_table is not None:
        bt = block_table.detach().cpu()
        block_shape = list(bt.shape)
        # Use this only if invalid pages are represented by negative values.
        # If vLLM stores all allocated pages without negative sentinels, use
        # ceil(cache_seqlens / page_block_size) instead.
        valid_counts = (bt >= 0).sum(dim=1).to(torch.int64).tolist()

    if valid_counts is None:
        valid_counts = [
            (int(length) + int(page_block_size) - 1) // int(page_block_size)
            for length in seqlens
        ]

    sink.write_jsonl({
        "schema_version": 1,
        "trace_id": f"step_{step_id}_layer_{layer_id}",
        "phase": "decode",
        "capture_point": "after_scheduler_before_attention_launch",
        "batch_size": int(q.shape[0]),
        "q_len": int(q.shape[1]),
        "num_q_heads": int(num_q_heads),
        "num_kv_heads": int(num_kv_heads),
        "head_dim": int(head_dim),
        "dtype": str(dtype),
        "kv_dtype": str(kv_dtype),
        "page_block_size": int(page_block_size),
        "cache_seqlens": seqlens,
        "block_table_valid_counts": [int(x) for x in valid_counts],
        "block_table_shape": block_shape,
        "sliding_window": sliding_window,
        "scheduler_active_tokens": int(q.shape[0] * q.shape[1]),
        "notes": notes,
    })
```

## CSV Alternative

If JSONL is inconvenient, use one row per trace:

```csv
trace_id,phase,batch_size,q_len,num_q_heads,num_kv_heads,head_dim,dtype,kv_dtype,page_block_size,cache_seqlens,block_table_valid_counts,block_table_shape,sliding_window,notes
decode_step_1_layer_0,decode,3,1,32,8,128,fp16,fp16,16,"[108,2048,513]","[7,128,33]","[3,256]",,
```

Keep array fields as JSON-like strings. Do not write space-separated arrays
without brackets.

## Common Pitfalls

- `block_table.shape[1]` is capacity, not actual valid pages.
- Batched trace records are not replay rows. Use the flattened one-sequence-per-row
  JSONL when running `replay_vllm_trace.py` or `standalone_paged_producer`.
- Do not merge numeric `block_ids` across layers or independent runs without a
  layout scope. This creates artificial page reuse in locality benchmarks.
- `page_block_size` is tokens per page, not number of pages.
- `cache_seqlens` may be before-append or after-append depending on capture
  point. Record which one.
- For GQA/MQA, `num_q_heads` and `num_kv_heads` differ. Record both.
- Speculative decoding can make `q_len > 1` or create accepted/rejected token
  ambiguity. Record accepted tokens only if that is what attention consumes.
- Do not save `block_table` contents unless needed for page locality analysis.
  For capacity planning, valid counts are usually enough.
