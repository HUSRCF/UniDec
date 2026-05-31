# RDNA3 Gather/Densify Phase 1/2

This directory is a standalone Phase 1/2 scaffold for RDNA3/gfx11 gather and
local densification experiments. It intentionally avoids the historical D256
and full FA4 build paths.

## Reports

- `PHASE3_RESULTS.md`: running experiment log from persistent queue through
  fixed-grid, strict vLLM replay, row ordering, and remap-policy ablations.
- `RDNA3_PAGED_KV_TECHNICAL_REPORT.md`: conservative summary of what the
  current evidence supports and what it does not support.
- `VLLM_LOCALITY_INTEGRATION_PLAN.md`: minimal vLLM-facing integration plan for
  locality-aware row permutation and row-index output writeback.
- `VLLM_TRACE_SCHEMA.md`: trace schema and collection guidance for paged-KV
  decode replay.

## ABI

The first ABI is deliberately flat:

- `features`: contiguous `[num_rows, dim]`, `fp16` or `bf16`
- `indices`: contiguous `int32 [num_tasks, tile_tokens]`
- `output`: contiguous `[num_tasks, tile_tokens, dim]`

Each `indices[task, token]` selects one feature row. Negative or out-of-range
indices produce zero rows. `dim` must be even because the kernels copy one
DWORD at a time, i.e. two fp16/bf16 elements per lane operation.

## Kernel Matrix

- `baseline`: global gather -> global dense
- `vgpr_lds`: global -> VGPR -> LDS -> global dense
- `direct_lds`: candidate direct-to-LDS -> global dense, with a fallback path
  if the candidate is not compiled in
- `fused_global`: Phase 2 global gather + repeated sum consumer
- `fused_lds`: Phase 2 LDS densify + repeated sum consumer
- `dot_global`: Phase 2 decode-like global gather + per-task query dot products
- `dot_lds`: Phase 2 decode-like LDS densify + per-task query dot products
- `graph_global`: Phase 2 graph-style global gather + multi-transform neighbor aggregation
- `graph_lds`: Phase 2 graph-style LDS densify + multi-transform neighbor aggregation
- `graph_lds_chunked`: Phase 2 graph-style LDS densify with one block per
  `(task, transform_chunk)`
- `graph_auto`: shape-based graph dispatch over `graph_global`, `graph_lds`,
  and `graph_lds_chunked`

The direct-to-LDS path is not assumed correct or profitable. It must be checked
with disassembly and profiling before being promoted to Phase 2.

## Quick Start

Build only:

```bash
python experiments/rdna3_gather/test_gather.py --build-only
```

Run correctness and latency checks:

```bash
python experiments/rdna3_gather/test_gather.py --variant all --dtype fp16 --rows 4096 --tasks 32 --tile-tokens 128 --dim 64 --iters 30
python experiments/rdna3_gather/test_gather.py --variant all --dtype bf16 --rows 4096 --tasks 32 --tile-tokens 128 --dim 64 --iters 30
```

Run the Phase 2 fused consumer:

```bash
python experiments/rdna3_gather/test_gather.py --mode fused --variant all --dtype fp16 --rows 4096 --tasks 32 --tile-tokens 128 --dim 64 --consumer-passes 4 --iters 100
```

`consumer-passes` controls how many times the small compute consumer reuses the
same gathered tile. `fused_global` rereads global memory every pass, while
`fused_lds` gathers once into LDS and then reads the LDS tile repeatedly. This is
an intentionally small proxy for the reuse pressure expected from a later
attention or graph aggregation consumer.

Run the decode-like dot-product consumer:

```bash
python experiments/rdna3_gather/test_gather.py --mode dot --variant all --dtype fp16 --rows 4096 --tasks 32 --tile-tokens 128 --dim 64 --num-queries 16 --iters 100
```

`num-queries` controls how many per-task query vectors reuse the same gathered
tile. `dot_global` rereads the gathered feature row for every query, while
`dot_lds` materializes the task tile in LDS once and then computes all query-dot
outputs from that LDS tile.

Run the graph neighbor aggregation consumer:

```bash
python experiments/rdna3_gather/test_gather.py --mode graph --variant all --dtype fp16 --rows 4096 --tasks 32 --tile-tokens 128 --dim 64 --num-transforms 8 --iters 100
```

`num-transforms` controls how many transform vectors consume the same neighbor
tile. `graph_global` rereads the neighbor feature rows for every transform,
while `graph_lds` stages the neighbor tile once and then computes all transform
aggregates from LDS. This is the current graph proxy for GNN-style message
aggregation over sparse neighbor lists.

For small task counts, test the chunked LDS mapping:

```bash
python experiments/rdna3_gather/test_gather.py --mode graph --variant graph_lds_chunked --dtype fp16 --rows 4096 --tasks 32 --tile-tokens 128 --dim 64 --num-transforms 32 --transform-chunk-size 4 --iters 100
```

`transform-chunk-size` trades duplicated gather work for more grid-level
parallelism. A chunk size of 4 or 8 is the intended first sweep range.

Run the current shape-based policy:

```bash
python experiments/rdna3_gather/test_gather.py --mode graph --variant graph_auto --dtype bf16 --rows 4096 --tasks 32 --tile-tokens 128 --dim 64 --num-transforms 32 --iters 100
```

`graph_auto` first checks an exact-match CSV policy table from
`RDNA3_GATHER_GRAPH_POLICY`. If no table entry exists, it falls back to the
conservative built-in heuristic. The default test harness uses
`prof/graph_auto_policy_table.csv` when that file exists, or pass
`--policy-table PATH` to override it. Set the policy table before the first
`graph_auto` call in a process; the C++ loader caches the table.

Run a policy quality sweep:

```bash
python experiments/rdna3_gather/sweep_graph_auto.py --iters 50
```

This compares `graph_auto` against `graph_global`, `graph_lds`, and chunked
LDS variants with chunk sizes 2/4/8 across dtype, task count, tile token count,
dimension, transform reuse, access pattern, and seed. By default it sweeps
`random`, `contiguous`, `page-cross`, and `tail-negative` patterns over seeds
0/1/2. It writes raw measurements, per-shape median measurements, and an
exact-match policy table generated from the median rows:

```text
experiments/rdna3_gather/prof/graph_auto_policy_sweep.csv
experiments/rdna3_gather/prof/graph_auto_policy_median.csv
experiments/rdna3_gather/prof/graph_auto_policy_table.csv
```

The policy table generator uses a 2% guard by default: it writes
`graph_global` unless the best LDS candidate beats global by at least
`--policy-min-speedup-vs-global`. This avoids baking short-run timing noise
into dispatch.

To validate the generated table instead of the built-in heuristic:

```bash
python experiments/rdna3_gather/sweep_graph_auto.py \
  --output experiments/rdna3_gather/prof/graph_auto_policy_sweep_realistic_table_raw.csv \
  --aggregate-output experiments/rdna3_gather/prof/graph_auto_policy_sweep_realistic_table_median.csv \
  --policy-table-for-auto experiments/rdna3_gather/prof/graph_auto_policy_table.csv
```

Run the Phase 3 finite persistent queue ticket sweep:

```bash
python experiments/rdna3_gather/sweep_graph_persistent.py \
  --ticket-batch-sizes 1 2 4 8 \
  --output experiments/rdna3_gather/prof/graph_persistent_ticket_sweep.csv
```

Use `graph_auto` as the single-launch batched baseline. The persistent queue is
only expected to help once the workload has genuine per-task imbalance; on
uniform graph shapes it can be much slower because it gives up grid-level
parallelism.

Run the Phase 3B skewed workload scheduling sweep:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --skews-list 0 0.8 0.95 \
  --persistent-blocks-list 48 96 192 256 \
  --output experiments/rdna3_gather/prof/graph_skew_scheduling_sweep.csv
```

This compares static node dispatch, sorted/bucketed node dispatch, static
edge-chunk overdecomposition, and persistent ticket queues. Treat
`static_chunked sorted` as the strong kernel-only baseline for skewed graphs.
The sweep also reports CPU preprocessing, H2D metadata transfer, and
end-to-end time; online dynamic graphs must include those costs. The script
performs one warmup metadata copy before timed cases to avoid first-copy
initialization noise.

For Phase 3C preprocessing experiments, the same sweep can build chunk work
items on the GPU and inject dynamic per-item costs:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --skews-list 0.8 \
  --filter-ratios-list 0.6 \
  --transform-active-ratios-list 0.5 \
  --early-exit-ratios-list 0.5 \
  --output experiments/rdna3_gather/prof/graph_skew_dynamic_gpuwork_sanity.csv
```

Rows with `worklist_builder=gpu` use `graph_build_varlen_work_items` to
construct `work_task/work_start/work_count/work_transform` on device from
`offsets`, `task_order`, per-task active transform counts, and per
task/transform edge limits.

The Phase 3D path can also generate the remaining synthetic graph metadata on
device:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --metadata-builders gpu \
  --skews-list 0.8 0.95 \
  --filter-ratios-list 0.6 \
  --transform-active-ratios-list 0.5 \
  --early-exit-ratios-list 0.5 \
  --order-buckets 8 \
  --output experiments/rdna3_gather/prof/graph_skew_gpumeta_sweep.csv
```

`metadata_builder=gpu` creates synthetic counts, offsets, flat indices,
dynamic edge limits, and a lightweight count-bucket order on device. Treat the
bucket order as a cheap online scheduling approximation, not as an exact
replacement for CPU sorting.

Phase 3E adds a fixed-grid self-culling dispatch path. Rows with
`variant=static_chunked_fixed` and `worklist_builder=fixed` use a fixed-capacity
device worklist plus a device-resident `work_size`; Level 2 launches over the
capacity and returns early for inactive blocks.

Phase 3F capacity sweeps can vary fixed capacity relative to exact work size:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --metadata-builders gpu \
  --fixed-capacity-scales 1 1.25 2 4 8 max \
  --overflow-policy error \
  --output experiments/rdna3_gather/prof/graph_skew_phase3f_capacity_sweep.csv
```

The exact work size is used only to calibrate this experiment. The fixed
self-culling timed path itself keeps `work_size` on device. Use
`--overflow-policy exact` to test fallback behavior when capacity is too small.

Plan production capacity classes from real trace metadata:

```bash
python experiments/rdna3_gather/trace_capacity_plan.py \
  --trace path/to/real_trace.pt \
  --chunk-tokens 32 \
  --num-transforms 8 \
  --num-classes 4 \
  --capacity-round 64 \
  --output experiments/rdna3_gather/prof/real_trace_capacity_plan.csv \
  --summary-output experiments/rdna3_gather/prof/real_trace_capacity_plan.json
```

Trace files can be `.jsonl`, `.pt/.pth`, `.npz`, or `.csv`. The minimum field is
`counts` or `offsets`/`indptr`; optional fields are `num_transforms`,
`transform_counts`, and `edge_limits`. CSV can be one row per trace with a
list-valued `counts` column, or one row per task with `trace_id,count`.
The planner reports the `work_capacity / actual_work_size` distribution and
chooses ratio-aware pre-instantiated capacity classes. Use
`--manual-capacities` to evaluate a fixed class set. Use `--actual-scale` when
one recorded KV work item must be expanded into multiple Q-head or transform
chunks in a fused decode kernel.

For vLLM decode trace collection, see
`experiments/rdna3_gather/VLLM_TRACE_SCHEMA.md`. The important point is to
capture workload metadata after the scheduler has finalized the active sequence
set and KV block mapping, but before the attention backend consumes it. Do not
collect this trace inside latency timing.


Replay the collected vLLM decode trace against fixed-grid capacity strategies:

```bash
python experiments/rdna3_gather/replay_vllm_trace.py \
  --modes self-cull gather-dot \
  --warmup 1 --iters 3 \
  --work-iters-list 0 16 \
  --output experiments/rdna3_gather/prof/vllm_trace_replay.csv
```

The default trace path is the local strict vLLM trace copy under
`experiments/rdna3_gather/trace/vllm_decode_block_table_v2_strict_kvlayout_true/jsonl_flattened`.
These files are one-sequence-per-row, decode-only, carry real
`sequences[].block_ids`, and have `kv_cache_layout.available=true`. The replay compares
`single_max`, ratio-aware capacity classes, and a 64-round class plan. It is a
launch-level replay by default: one kernel launch per recorded decode row. Use
`--launch-mode fused` to group rows by capacity class and remove per-row launch
overhead. Use `--include-exact` to add a zero-empty simulated upper bound,
`--actual-scale` to emulate Q-head or transform expansion, and
`--strategy-order reverse` as a quick check for fixed strategy-order bias.
Use `--modes paged-dot --launch-mode fused` to replay a vLLM-like paged KV ABI
with synthetic block tables and a `[num_pages, num_kv_heads, page_block_size,
head_dim]` KV pool. Use `--modes paged-attn --launch-mode fused` for the K/V
attention-proxy path with chunk-local softmax and scalar value aggregation. Use
`--modes paged-full --launch-mode fused` for the two-kernel full chunk-softmax
path: capacity-group producer launches write `[row, head, chunk]` workspace and
one reduce launch emits `[row, head, value_dim]`. Use `paged-full-producer`,
`paged-full-reduce`, and `paged-full-reduce-ml` to time the producer, full
workspace reducer, and m/l-only reducer separately. `--value-dim` controls the V
aggregation dimension. `--page-locality` selects `random`, `contiguous`,
`page-cross`, or `hot-page` synthetic physical page assignment. Use
`--page-locality trace` with v2 traces that contain `sequences[].block_ids` to
replay the real vLLM block table instead of a synthetic mapping;
`--check-paged-attn` and `--check-paged-full` run small PyTorch tolerance checks.

The strict trace also contains batched JSONL under `jsonl/`. Current replay
kernels intentionally consume the flattened `jsonl_flattened/` form; passing
the batched files raises an error because the replay ABI maps one sequence to
one trace row.

Example v2 block-id replay smoke:

```bash
python experiments/rdna3_gather/replay_vllm_trace.py \
  --trace experiments/rdna3_gather/trace/vllm_decode_block_table_v2_strict_kvlayout_true/jsonl_flattened/dolly_plen2048_gen64_gpu0.flat.jsonl \
  --limit-traces 256 \
  --launch-mode fused \
  --modes paged-full-producer \
  --strategy-filter capacity_class \
  --page-locality trace \
  --warmup 0 --iters 1 \
  --output experiments/rdna3_gather/prof/replay_trace_blockids_smoke.csv
```

The standalone producer has the same `--page-locality trace` mode.
Use `--limit-traces` for small standalone smoke tests against the default strict
trace without running the full 114,820-row replay.

Strict full-trace standalone result files use the `standalone_strict_all_*`
prefix in `prof/`. Block IDs are remapped by KV layout scope
(`k_data_ptr`, `v_data_ptr`, layer) before replay, because the same numeric
block ID in different layers or independent runs is not the same address range.
With that correction, real vLLM block IDs are close to same-footprint
random/contiguous placement and much slower than the synthetic hot-page upper
locality case. Capacity classes reduced producer wavefronts by about 66%, but
full producer timing changed by about 0.2-1%, so K/V footprint and locality are
the main levers for this strict trace.

The same scoped conclusion holds for the PyTorch-extension two-kernel
`paged-full` replay: real trace `544.4 ms`, same-footprint random `547.9 ms`,
and same-footprint hot-page `390.0 ms` for `value_dim=32`.

`--row-order first-page` groups rows within each capacity class by their first
layout-scoped KV block. This is the current strongest scheduling lever: on the
strict scoped trace, the two-kernel `paged-full` path improves from about
`544 ms` to about `341 ms`. A same-footprint random trace improves much less, so
the benefit is tied to real block-table reuse/locality rather than generic
sorting overhead. `--row-order auto-first-page` is the online-gating prototype:
it computes cheap first-page reuse predictors and resolves to `first-page` or
`original`. The current gate can use global unique-first-page ratio, windowed
unique-first-page ratio, adjacent first-page hits, adjacent shared-prefix mean,
and a row-count floor. Additional row-order policies are available for ablation:
`first-2-pages`, `first-4-pages`, `lexicographic`, `prefix-hash-2`,
`prefix-hash-4`, and `lcp-bucket`. The replay preserves original row identity by
passing `row_indices` to the kernels, so sorted execution still writes outputs
to original row slots.

The standalone binary can measure C++ scheduler-side permutation and restore
costs without Python/Torch in the timing path:

```bash
cd experiments/rdna3_gather

./standalone_paged_producer \
  --page-locality trace \
  --strategy capacity_class \
  --row-order auto-first-page \
  --restore-mode row-indices \
  --scheduler-reuse-metadata-buffers \
  --output prof/phase5_scheduler_auto_first_page_row_indices_reusebuf.csv

./standalone_paged_producer \
  --page-locality trace \
  --strategy capacity_class \
  --row-order auto-first-page \
  --restore-mode explicit-copy \
  --scheduler-reuse-metadata-buffers \
  --output prof/phase5_scheduler_auto_first_page_explicit_copy_reusebuf.csv
```

`row-indices` is the preferred restore path: sorted execution still writes by
original row id. `explicit-copy` measures the fallback cost for a sorted
temporary output followed by an unpermute copy.

To isolate the global `unique_first_pages / rows` gate, disable the auxiliary
gates and sweep the threshold:

```bash
./standalone_paged_producer \
  --page-locality trace \
  --strategy capacity_class \
  --row-order auto-first-page \
  --restore-mode row-indices \
  --scheduler-reuse-metadata-buffers \
  --auto-first-page-max-unique-ratio 0.75 \
  --auto-first-page-max-window128-unique-ratio 0 \
  --auto-first-page-max-window128-unique -1 \
  --auto-first-page-min-adjacent-hit 2 \
  --auto-first-page-min-lcp-mean 999 \
  --limit-traces 8192 \
  --output prof/phase6_gate_thr_0p75_rows_8192.csv
```

Useful summaries from the online-gating sweeps:

```text
experiments/rdna3_gather/prof/phase6_same_rowcount_e2e_summary.csv
experiments/rdna3_gather/prof/phase6_gate_threshold_sweep_summary.csv
experiments/rdna3_gather/prof/phase6_gate_minrows_sweep_summary.csv
```

When evaluating online usefulness, compare `original`, `first-page`, and
`auto-first-page` at the same row count. The full 114k-row replay is a stress
test, not a single decode step. Existing same-row-count summaries are written to:

```text
experiments/rdna3_gather/prof/phase6_same_rowcount_e2e_summary.csv
```

To quantify the locality exposed by each row-order policy:

```bash
python experiments/rdna3_gather/analyze_row_order_reuse.py \
  --output experiments/rdna3_gather/prof/strict_trace_row_order_reuse.csv
```

This reports adjacent shared-prefix length, unique layout-scoped pages per
execution window, and reuse-distance summaries. Do not interpret these rows as
proof of a specific L2/MALL/TLB mechanism; they quantify the address-locality
signal that the timing results can exploit.

Current route after Phase 6:

- Freeze `auto-first-page` as a conditional scheduling optimization:
  conservative default `unique_first_pages / rows <= 0.50`, optional aggressive
  profile `0.75`, plus a row-count/windowed-reuse guard for integration.
- Keep `row-indices` scatter writeback as the default restore path and keep
  original-order fallback for low-reuse or small-batch inputs.
- Do not keep tuning capacity, persistent queues, or gate thresholds as the main
  line. The next structural replay should model physical superblock packing:
  logical 16-token vLLM blocks stay intact, while `4/8/16` adjacent logical
  blocks inside the same layout scope are placed contiguously before measuring
  `original`, `first-page`, and `auto-first-page`.
- Split-K/chunked full attention remains the stable route for latency hiding.
  Software prefetch should stay a narrow C++/ISA microkernel sweep before any
  hand-written assembly is considered.

Physical superblock replay is available in the standalone and Python replay
paths:

```bash
./standalone_paged_producer \
  --page-locality trace \
  --physical-superblock 8 \
  --strategy capacity_class \
  --row-order auto-first-page \
  --restore-mode row-indices \
  --scheduler-reuse-metadata-buffers \
  --limit-traces 8192 \
  --output prof/phase7_superblock_s8_auto-first-page_rows_8192.csv

python experiments/rdna3_gather/analyze_row_order_reuse.py \
  --physical-superblock 8 \
  --row-orders original first-page \
  --output experiments/rdna3_gather/prof/phase7_superblock_reuse_s8.csv
```

The current `--physical-superblock` mode is only a replay allocator model. It
groups layout-scoped numeric block IDs into local allocation groups; it does not
assert that vLLM numeric block IDs are physical addresses. First results are in
`prof/phase7_superblock_rows8192_summary.csv`; they show the scaffold is working,
but the current numeric-ID grouping does not yet beat the Phase 6 row-ordering
effect by itself.

For allocator-policy ablations, use `--physical-remap-policy`:

```bash
./standalone_paged_producer \
  --page-locality trace \
  --physical-remap-policy first-touch-compact \
  --strategy capacity_class \
  --row-order auto-first-page \
  --restore-mode row-indices \
  --scheduler-reuse-metadata-buffers \
  --limit-traces 8192 \
  --output prof/phase8_remap_first-touch-compact_auto-first-page_rows_8192.csv

./standalone_paged_producer \
  --page-locality trace \
  --physical-remap-policy oracle-access-order \
  --strategy capacity_class \
  --row-order auto-first-page \
  --restore-mode row-indices \
  --scheduler-reuse-metadata-buffers \
  --limit-traces 8192 \
  --output prof/phase8_remap_oracle-access-order_auto-first-page_rows_8192.csv
```

`oracle-access-order` is implemented only in the standalone C++ replay. It is an
upper-bound diagnostic that remaps after observing the launch/group order; it is
not a production allocator. In the first 8,192-row run it did not improve kernel
time over first-touch compaction, so the next layout experiment should target a
more realistic allocator model: sequence append, prefix allocation groups, or
request/sequence-aware compaction if the trace exposes reliable provenance.

To inspect the captured block-table reuse and KV layout signatures:

```bash
python experiments/rdna3_gather/analyze_vllm_strict_trace_layout.py
```

Use the scoped-remap assertion as a regression guard against accidentally
treating naked numeric `block_id` values as globally reusable across layers or
KV allocations:

```bash
python experiments/rdna3_gather/analyze_vllm_strict_trace_layout.py \
  --assert-layout-scoped-remap
```

This writes:

```text
experiments/rdna3_gather/prof/strict_trace_layout_summary.csv
experiments/rdna3_gather/prof/strict_trace_layout_summary.json
```

To isolate address-stride effects from the attention replay:

```bash
make -C experiments/rdna3_gather standalone_stride_probe

cd experiments/rdna3_gather
./standalone_stride_probe \
  --footprint-mb 4096 \
  --stride-bytes 2097152 \
  --refs 33554432 \
  --loads-per-ref 4 \
  --output prof/stride_probe_4g_stride2m.csv
```

The stride probe is a relative microbench, not a VRAM page-size detector. On the
current W7900 run, 2MB stride was not worse than 4KB/64KB/16MB under either high
or low block concurrency, so the data does not support treating 2MB stride alone
as proof of TLB collapse.

By default the direct-to-LDS probe is disabled so the Phase 1 harness remains
buildable. To force the experimental inline-assembly probe:

```bash
python experiments/rdna3_gather/test_gather.py --build-only --enable-direct
```

On current gfx11/ROCm combinations this may fail at compile time. That is a
valid Phase 1 result; keep using `vgpr_lds` as the safe fallback.

If your RDNA3 target is not `gfx1100`, set:

```bash
RDNA3_GATHER_GPU_ARCH=gfx1101 python experiments/rdna3_gather/test_gather.py --build-only
```

## ISA And Profiling Notes

The JIT build directory is local to this experiment:

```text
experiments/rdna3_gather/.torch_ext/
```

After a build, inspect the generated shared object with ROCm tools, for example:

```bash
/opt/rocm/bin/roc-obj -d experiments/rdna3_gather/.torch_ext/rdna3_gather_ext*.so
```

Check whether the `direct_lds` kernel actually contains a `buffer_load_dword`
with the `lds` modifier on gfx11. Also compare VGPR, scratch, LDS usage,
latency, effective GB/s, and LDS bank conflict counters.

For the vLLM trace producer profile, the working local path is legacy
`rocprofv2`:

```bash
cd experiments/rdna3_gather/prof/rocprof_runs
rocprof --tool-version 2 -i ../rocprof_inputs/producer_split.txt \
  -o producer_random_capacity_vdim32 \
  python ../../replay_vllm_trace.py \
    --launch-mode fused --modes paged-full-producer \
    --strategy-filter capacity_class \
    --value-dim 32 --warmup 0 --iters 1 \
    --output replay_random_capacity_vdim32.csv
```

Current ROCm/tooling limits: `rocprof-compute` is missing Python report
dependencies, direct `rocprofv3` aborts during PyTorch extension import, and
`rocprofv3 --attach` is blocked by ptrace permissions. In this setup,
`rocprofv2` gives reliable dispatch/resource metadata and nonzero `Wavefronts`,
but the attempted L2, memory-busy, and instruction derived counters are emitted
as zero for this workload. Treat Phase 4F cache/MALL/TLB attribution as
unresolved until a working rocprofv3/rocprof-compute path or a standalone HIP
binary is available.

The standalone producer binary removes Python and PyTorch from the profiler
path:

```bash
make -C experiments/rdna3_gather standalone_paged_producer
```

Before any profiler run, check that the target GPU is idle:

```bash
rocm-smi
rocm-smi --showpids
```

Do not record profiler conclusions if another process is driving GPU% or CU
occupancy. When the GPU is idle, run the same four-way producer matrix:

```bash
cd experiments/rdna3_gather

./standalone_paged_producer \
  --strategy capacity_class --page-locality random \
  --output prof/standalone_random_capacity_vdim32.csv

./standalone_paged_producer \
  --strategy single_max --page-locality random \
  --output prof/standalone_random_single_vdim32.csv

./standalone_paged_producer \
  --strategy capacity_class --page-locality hot-page \
  --output prof/standalone_hot_capacity_vdim32.csv

./standalone_paged_producer \
  --strategy single_max --page-locality hot-page \
  --output prof/standalone_hot_single_vdim32.csv
```

Then profile from a dedicated output directory, for example:

```bash
mkdir -p prof/rocprof_standalone_runs
cd prof/rocprof_standalone_runs

rocprof --tool-version 2 -i ../rocprof_inputs/standalone_producer_split.txt \
  -o standalone_random_capacity_vdim32 \
  ../../standalone_paged_producer \
    --strategy capacity_class --page-locality random \
    --warmup 0 --iters 1 \
    --output ../standalone_random_capacity_vdim32_rocprof.csv
```

If `rocprofv3` works on this standalone binary, prefer it for cache/VMEM/TLB
counters. Keep the PyTorch-extension `rocprofv2` results as dispatch-resource
evidence only.

## Current Limits

- No MMA or daemon-style persistent kernel. Phase 4D includes a two-kernel
  full chunk-softmax/value-reduce proxy over paged K/V, but it is still a
  microbench path rather than a production vLLM attention backend. Phase 3
  includes finite persistent-queue experiments, but the current recommended
  route is static/fixed-grid dispatch plus explicit reduce.
- `fp16` and `bf16` only.
- `dim` must be even.
- Per-task LDS tile must fit in the device shared memory limit. The first
  target is `tile_tokens=128`, `dim=64`, which uses 16 KiB.
