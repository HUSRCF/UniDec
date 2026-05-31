# vLLM Locality-Aware Decode Integration Plan

## Goal

Move the measured `first-page` row-ordering win from standalone replay toward a
minimal vLLM-compatible integration path. The first integration should be thin:
it should permute decode rows when a cheap reuse predictor says the batch has
layout-scoped KV locality, run the backend in that order, and write outputs back
to the original row ids.

This is a feasibility plan, not a request to rewrite the vLLM allocator or the
whole scheduler.

## Non-Goals

- Do not change vLLM's KV allocator in the first prototype.
- Do not rely on device-side kernel launch or dynamic parallelism.
- Do not force sorting when the predictor says reuse is low.
- Do not use raw numeric `block_id` as a global address identity.
- Do not claim cache-layer causality without profiler evidence.

## Integration Boundary

The intended hook point is after vLLM has finalized the active decode batch and
KV metadata, but before the paged attention backend launches.

At that point the integration needs:

```text
active row count
per-row block table or first valid block id
per-row cache sequence length
layer id / attention layer identity
KV cache K/V base pointer identity
KV layout strides or enough information to derive a scoped first-page key
Q/output row mapping
KV head mapping if rows are owned by KV head or address differs by KV head
```

This must be collected on the same semantic rows that the attention backend will
consume. Do not build the permutation before scheduler filtering, and do not use
metadata after it has been mutated unless the before/after-append convention is
explicitly tracked.

## Scoped First-Page Key

The sort key must describe the first KV address range consumed by the row. The
minimum replay key has been:

```text
(k_data_ptr, v_data_ptr, layer, first_block_id)
```

For a real backend, extend the key when needed:

```text
(k_data_ptr, v_data_ptr, layer, kv_head_or_group, first_block_id)
```

or use a derived first-page byte offset/address if the backend can compute it
without a CPU readback.

The key must be layout-scoped. The same numeric `block_id` in two layers, two KV
allocations, or two incompatible layouts is not the same locality group.

## Predictor And Gate

Default conservative gate:

```text
sort if:
  rows >= min_rows
  and unique_first_pages / rows <= 0.50
```

Suggested starting values:

```text
min_rows = 4096 or 8192 for throughput replay
unique_first_ratio_threshold = 0.50
aggressive threshold = 0.75
```

The production gate should also record auxiliary signals:

```text
window_unique_first_pages / window_size
adjacent_first_page_hit_ratio
adjacent_lcp_mean when cheap
```

Important caveat: row count alone is not enough. A 512-row batch with high
shared-prefix reuse may benefit, while a much larger batch with no reuse may
not. The gate should look at reuse first and use row count as a cost floor.

## Scheduler Pipeline

For each decode batch:

1. Build `original_row_ids = [0, 1, ..., rows - 1]`.
2. Extract the scoped first-page key for each row.
3. Compute predictor metrics.
4. If the gate is off, keep original order and pass through.
5. If the gate is on, sort rows by:

```text
(capacity_class, scoped_first_page_key, optional stable tie-breaker)
```

6. Build:

```text
sorted_row_ids
inverse_row_ids if an explicit restore path is required
group descriptors or capacity-class launch descriptors
```

7. Launch the backend over sorted rows.
8. Prefer row-index scatter output: each row writes to `output[original_row_id]`.
9. Record scheduler and kernel timing.

Sorting inside capacity classes preserves the current capacity-class launch
shape. If a future backend uses a single max-capacity launch, the sort can be
global over all active rows.

## Output Restore

Preferred path:

```text
backend receives sorted_row_ids
backend writes final output by original row id
```

This avoids a separate unpermute kernel. It is not "free"; the scatter write is
part of the backend's output path. The replay data only shows that it was not a
bottleneck for the measured output size.

Fallback path:

```text
backend writes sorted output
unpermute kernel copies sorted output back to original row order
```

Keep this path for ABI compatibility testing, but do not make it the default if
the backend can consume row ids directly.

## Timing And Metrics

Each integration experiment should report:

```text
predictor_ms
key_build_ms
sort_or_group_ms
metadata_h2d_ms
kernel_ms
restore_ms if explicit restore is used
online_e2e_ms
```

Also report locality metrics:

```text
rows
unique_first_pages
unique_first_pages / rows
window-128 unique first pages p50
adjacent first-page hit ratio
adjacent LCP mean if available
```

And serving metrics:

```text
per-request latency p50/p90/p99
tail latency change
fairness or starvation indicators
number of requests moved across scheduler order
```

The same row count must compare original order against first-page or auto. Do
not extrapolate a full-trace speedup to a small online batch without measuring
that row count.

## Correctness Checks

For every sorted run:

- Verify output equivalence against original order within the kernel's expected
  numerical tolerance.
- Verify that `sorted_row_ids` is a permutation of `[0, rows)`.
- Verify that no row crosses a semantic boundary where order is required for
  correctness.
- Verify that block ID scoping includes layout identity.
- Add a regression test where raw numeric block IDs alias across layers or KV
  allocations; the reuse analyzer must not treat them as the same page.

## Rollout Plan

### Stage 1: Offline Replay ABI Alignment

Use the current standalone replay data structure but rename fields to match the
vLLM decode metadata:

```text
block_table
cache_seqlens
kv_head_mapping
row_indices
output_stride
layer identity
KV layout identity
```

Goal: keep the replay result stable while making the ABI look like the future
extension boundary.

### Stage 2: C++ Scheduler Microbench

Implement the predictor and permutation in C++ with reusable buffers. Measure
the same row-count matrix used in Phase 6 and add high-reuse/low-reuse traces.

Acceptance:

- low-reuse batches fall back to original order;
- high-reuse batches keep most of the replay speedup after scheduler cost;
- row-index output path remains correct.

### Stage 3: Thin Extension Prototype

Expose one experimental backend function that accepts GPU tensors and host-side
metadata already present in the framework path. Avoid changing the model logic.

Inputs:

```text
Q
block_table
cache_seqlens
KV cache tensors or base pointers
layer id / layout descriptor
optional preallocated row_indices buffer
```

Outputs:

```text
attention output in original row order
debug metrics when enabled
```

### Stage 4: vLLM Scheduler Hook

At the decode batch boundary:

- compute scoped first-page keys;
- run the gate;
- pass sorted row ids to the backend;
- write output by original row id;
- log metrics under a feature flag.

Do not reorder across fairness or admission-control boundaries until latency
behavior is measured.

### Stage 5: Broader Trace Validation

Validate these cases:

- high prefix/shared-page reuse;
- low prefix reuse;
- mixed prompt lengths;
- small online batches with reuse;
- large online batches with low reuse;
- different layer/KV-head mappings;
- different block sizes or KV layouts if available.

## Open Design Questions

1. Can vLLM expose a stable layout-scoped first-page key without CPU copies of
   large block tables?
2. Is per-step sorting better done in C++, in a thin scheduler extension, or by
   a small GPU metadata kernel?
3. How much of the current `metadata_h2d_ms` survives in the real framework path?
4. Does row permutation affect serving fairness or tail latency under
   continuous batching?
5. If sequence/request provenance is available, can `prefix_group_compact` or
   `sequence_append` allocator replay produce a stronger layout signal than the
   cheap remap policies tested so far?

## Recommended Initial Feature Flag

```text
UNIDEC_VLLM_LOCALITY_ORDER=off|auto|force
UNIDEC_VLLM_LOCALITY_THRESHOLD=0.50
UNIDEC_VLLM_LOCALITY_MIN_ROWS=4096
UNIDEC_VLLM_LOCALITY_DEBUG=0|1
```

Default should be `off` until the integration has correctness and online E2E
data. The first experimental default can be `auto` only in controlled runs.

