# Phase 3 Finite Persistent Queue Results

## Goal

Validate whether table-driven variant selection plus workgroup-level atomic
ticket batching can reduce scheduling overhead or improve load balance without
hurting worst-case behavior.

This phase is not a daemon. It is a single-launch finite queue: a limited
number of workgroups repeatedly claim logical graph tasks from a global ticket,
process them, and exit when the queue is exhausted.

## Implemented

- `graph_persistent_global`
- `graph_persistent_lds`
- `graph_persistent_lds_chunked`
- `graph_persistent_auto`
- `sweep_graph_persistent.py`

The queue uses one atomic per workgroup ticket claim:

```cpp
if (threadIdx.x == 0) ticket_base = atomicAdd(ticket, ticket_batch_size);
__syncthreads();
```

`ticket_batch_size` is configurable and the sweep covers 1/2/4/8.

The baseline is `graph_auto`, which is already a single-launch batched kernel
using the current table-driven policy. This avoids incorrectly attributing
"fewer launches" to the persistent queue.

## ISA Contract Check

The local RDNA3 ISA PDF review found the Phase 3 queue design valid under these
constraints:

- The task descriptors are kernel-launch-time read-only inputs, so the ticket
  atomic does not need a producer/consumer payload ordering protocol.
- `S_BARRIER` synchronizes only within the workgroup and does not by itself
  drain memory counters.
- The atomic return value must be waited on before use.
- LDS ticket broadcast and tile reuse need waitcnt/barrier discipline.

After rebuilding, `roc-obj` disassembly confirms:

```text
global_atomic_add_u32 ... glc
s_waitcnt vmcnt(0)
ds_store_b32
s_waitcnt lgkmcnt(0)
s_barrier
```

Examples:

- `graph_persistent_global_kernel`: `global_atomic_add_u32` at ISA line 5607.
- `graph_persistent_lds_kernel`: `global_atomic_add_u32` at ISA line 6380.
- `graph_persistent_lds_chunked_kernel`: `global_atomic_add_u32` at ISA line 7183.

The persistent LDS launch checks include the static `ticket_base` shared-memory
slot, so the check is `dynamic_LDS + 4 <= 64 KiB`.

## Policy Validation Bad Cases

The realistic median validation writes:

```text
experiments/rdna3_gather/prof/graph_auto_policy_bad_cases_realistic_table.csv
```

Current table-driven validation has six median rows below 95% of measured best:

| dtype | tasks | tile_tokens | dim | transforms | policy | best | speedup vs global | auto/best |
| --- | ---: | ---: | ---: | ---: | --- | --- | ---: | ---: |
| bf16 | 128 | 256 | 64 | 32 | graph_global | global | 0.934 | 0.934 |
| bf16 | 256 | 256 | 64 | 32 | graph_global | global | 0.949 | 0.949 |
| fp16 | 128 | 128 | 128 | 32 | graph_global | global | 0.922 | 0.922 |
| fp16 | 128 | 256 | 64 | 32 | graph_global | global | 0.921 | 0.921 |
| fp16 | 256 | 128 | 128 | 16 | graph_global | global | 0.912 | 0.912 |
| fp16 | 256 | 256 | 64 | 16 | graph_global | global | 0.914 | 0.914 |

All six have `policy=graph_global` and `best=global`, so these are not
LDS/chunked mis-dispatches. They are short-kernel table-wrapper/timing-tail
cases and should stay visible in reports.

## Sanity Sweep

Command:

```bash
python experiments/rdna3_gather/sweep_graph_persistent.py \
  --quiet \
  --dtypes bf16 \
  --tasks-list 128 \
  --tile-tokens-list 64 \
  --dims-list 128 \
  --num-transforms-list 32 \
  --patterns-list random contiguous page-cross tail-negative \
  --seeds-list 0 1 2 \
  --ticket-batch-sizes 1 2 4 8 \
  --warmup 3 --iters 20 \
  --output experiments/rdna3_gather/prof/graph_persistent_ticket_sweep_sanity.csv
```

Result versus single-launch `graph_auto`:

| ticket batch | cases | median speedup | mean speedup | min speedup |
| ---: | ---: | ---: | ---: | ---: |
| 1 | 12 | 0.229x | 0.229x | 0.226x |
| 2 | 12 | 0.219x | 0.219x | 0.214x |
| 4 | 12 | 0.220x | 0.220x | 0.218x |
| 8 | 12 | 0.168x | 0.168x | 0.167x |

Interpretation: for this uniform graph workload, the finite persistent queue is
not competitive. It reduces grid-level parallelism and adds ticket overhead.
Batching does not rescue it; batch 8 is worse because it reduces load-balance
granularity without providing enough atomic relief.

## Current Conclusion

The Phase 3 queue is correct and ISA-compatible, but it should not replace the
single-launch table-driven batched kernel on uniform graph shapes. The next
experiment must introduce genuinely uneven per-task work before claiming any
persistent-queue benefit.

The right next baseline matrix is:

- `graph_auto`: single-launch batched grid baseline.
- `graph_persistent_auto`: finite persistent queue with ticket batch 1/2/4/8.
- Uneven graph workload: variable valid neighbor count or variable transform
  chunks per task.

Wave role specialization should remain out of the default path and only be
tested on shapes where `graph_lds_chunked` is already a clear winner.

## Phase 3B: Skewed Workload Scheduling

The next test isolates scheduling from LDS reuse by using varlen global graph
aggregation. Each node has a synthetic neighbor count drawn from a uniform or
Pareto-like distribution. This makes node length change the actual loop trip
count; padding with invalid rows is not used because that would keep every task
the same amount of work.

Implemented strategies:

- `static_node`: one block per `(node, transform)`.
- `static_node sorted`: same kernel, but nodes are ordered by descending
  neighbor count.
- `static_chunked`: overdecompose each node into fixed edge chunks and
  `atomicAdd` partial sums.
- `static_chunked sorted`: chunk list follows descending node length.
- `persistent_node`: finite ticket queue over node/transform work items.
- `persistent_chunked`: finite ticket queue over edge-chunk work items.

New harness:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py
```

Initial sweep:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --quiet \
  --dtypes fp16 \
  --tasks-list 32 128 \
  --dims-list 64 \
  --num-transforms-list 8 \
  --mean-neighbors-list 64 \
  --max-neighbors-list 1024 \
  --skews-list 0 0.8 0.95 \
  --seeds-list 0 1 \
  --ticket-batch-sizes 1 4 \
  --chunk-tokens 64 \
  --warmup 3 --iters 20 \
  --output experiments/rdna3_gather/prof/graph_skew_scheduling_initial.csv
```

Key median speedups versus `static_node identity`:

| skew | strategy | median speedup | min speedup |
| ---: | --- | ---: | ---: |
| 0.0 | static_chunked sorted | 0.722x | 0.652x |
| 0.0 | persistent_chunked best tested | 0.246x | 0.210x |
| 0.8 | static_chunked sorted | 1.742x | 1.089x |
| 0.8 | persistent_chunked best tested | 0.571x | 0.453x |
| 0.95 | static_chunked sorted | 1.592x | 1.026x |
| 0.95 | persistent_chunked best tested | 0.581x | 0.467x |

Conclusion: skew helps overdecomposition immediately, but the default
persistent queue still loses because 48 persistent blocks do not provide enough
resident work to hide memory latency.

Persistent block-count sweep on `fp16,tasks=128,dim=64,transforms=8,skew=0.95`:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --quiet \
  --dtypes fp16 \
  --tasks-list 128 \
  --dims-list 64 \
  --num-transforms-list 8 \
  --mean-neighbors-list 64 \
  --max-neighbors-list 1024 \
  --skews-list 0.95 \
  --seeds-list 0 1 \
  --ticket-batch-sizes 1 4 \
  --persistent-blocks-list 48 96 192 256 \
  --chunk-tokens 64 \
  --warmup 3 --iters 20 \
  --output experiments/rdna3_gather/prof/graph_skew_scheduling_persistent_blocks_sweep.csv
```

Selected median speedups:

| strategy | blocks | batch | median speedup |
| --- | ---: | ---: | ---: |
| persistent_chunked sorted | 48 | 1 | 0.545x |
| persistent_chunked sorted | 96 | 1 | 0.957x |
| persistent_chunked sorted | 192 | 1 | 1.461x |
| persistent_chunked sorted | 256 | 1 | 1.686x |
| persistent_chunked sorted | 256 | 4 | 1.638x |
| static_chunked sorted | any tested | 0 | about 2.36x |

This supports the more precise explanation: the 0.22x-style regression is not
"SPI versus persistent" in isolation. It is primarily that the initial
persistent grid was too small for the resource profile, causing resident
WG/wave starvation. Increasing persistent blocks restores some latency hiding,
but static edge-chunk overdecomposition remains the strongest baseline on this
synthetic skewed workload.

Current Phase 3B conclusion: persistent queue is not the winner yet. The first
positive scheduling result belongs to static overdecomposition plus sorted
dispatch. Persistent may still be useful, but only after exploring work-item
granularity, block count, and genuinely irregular per-item costs beyond simple
edge-count skew.

## CPU Preprocessing And End-to-End Timing

The skew sweep now reports three timing layers:

- `gpu_kernel_ms`: CUDA/HIP event timing around the kernel only.
- `cpu_preprocess_ms`: CPU-side count/order/chunk work-item construction.
- `h2d_metadata_ms`: host-to-device transfer of scheduling metadata such as
  offsets, order arrays, and chunk descriptors.
- `end_to_end_ms`: sum of the three fields above.

This is intentionally conservative: it uses the current Python harness for
online metadata construction. A production C++ preprocessing path could reduce
this cost, and offline/static graph preprocessing could hide it entirely.
The harness performs one warmup CPU-to-GPU metadata copy before timed cases to
avoid first-copy initialization noise.

Sanity command:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --quiet \
  --dtypes fp16 \
  --tasks-list 128 \
  --dims-list 64 \
  --num-transforms-list 8 \
  --mean-neighbors-list 64 \
  --max-neighbors-list 1024 \
  --skews-list 0.95 \
  --seeds-list 0 1 \
  --ticket-batch-sizes 1 4 \
  --persistent-blocks-list 48 256 \
  --chunk-tokens 64 \
  --warmup 3 --iters 20 \
  --output experiments/rdna3_gather/prof/graph_skew_scheduling_e2e_sanity.csv
```

Representative row (`seed=0,persistent_blocks=256`):

| strategy | kernel ms | CPU prep ms | H2D metadata ms | E2E ms | kernel speedup | E2E speedup |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| static_node identity | 0.0617 | 0.2759 | 0.3717 | 0.7094 | 1.000x | 1.000x |
| static_chunked sorted | 0.0305 | 0.9779 | 0.6032 | 1.6117 | 2.023x | 0.440x |
| persistent_chunked sorted, batch=1 | 0.0429 | 0.9779 | 0.6032 | 1.6241 | 1.438x | 0.437x |
| persistent_chunked sorted, batch=4 | 0.0444 | 0.9779 | 0.6032 | 1.6255 | 1.392x | 0.436x |

This changes the interpretation:

- Kernel-only: static chunked sorted remains the best tested scheduling route.
- Online end-to-end with Python preprocessing: metadata construction and H2D
  transfer dominate; chunked strategies lose despite faster kernels.
- Offline/precomputed graph: kernel-only numbers are the relevant comparison.
- Online dynamic graph: preprocessing must be optimized or moved onto the GPU
  before static chunked sorted can claim an end-to-end win.

Next experiments should separate three deployment regimes:

1. Offline static graph: precompute chunk/order metadata once.
2. Online CPU preprocessing: include CPU chunk/sort and H2D metadata cost.
3. Online GPU preprocessing: build/filter chunk work items on device, then run
   static chunked or bucket-local persistent scheduling.

## Phase 3C: GPU-Side Worklist Generation And Dynamic Cost

Implemented:

- `graph_build_varlen_work_items`: a C++/HIP extension entry point that builds
  chunk work arrays on device from `offsets`, `task_order`,
  `transform_counts`, and `edge_limits`.
- `worklist_builder={cpu,gpu}` reporting in `sweep_graph_skew.py`.
- Dynamic per-item cost controls:
  - `filter_ratio`: reduces the effective edge count per task/transform.
  - `transform_active_ratio`: varies the number of active transform IDs per
    task.
  - `early_exit_ratio`: caps the consumed edge prefix per task/transform.
- `gpu_preprocess_ms` is reported separately from CPU preprocessing, H2D
  metadata transfer, and graph kernel time.

The sweep performs one warmup `graph_build_varlen_work_items` call per case so
one-time `cumsum`/allocator initialization is not charged to the first tested
order.
Dynamic scenarios skip node-level full-transform baselines because they no
longer have the same semantics; their speedup baseline is
`static_chunked/worklist=cpu/order=identity`.

Sanity command:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --quiet \
  --dtypes fp16 \
  --tasks-list 32 \
  --dims-list 64 \
  --num-transforms-list 8 \
  --mean-neighbors-list 32 \
  --max-neighbors-list 256 \
  --skews-list 0.8 \
  --filter-ratios-list 0.6 \
  --transform-active-ratios-list 0.5 \
  --early-exit-ratios-list 0.5 \
  --seeds-list 0 \
  --ticket-batch-sizes 1 \
  --persistent-blocks-list 48 \
  --chunk-tokens 32 \
  --warmup 1 --iters 3 \
  --output experiments/rdna3_gather/prof/graph_skew_dynamic_gpuwork_sanity.csv
```

Representative dynamic result (`seed=0`, `persistent_blocks=48`):

| strategy | worklist | kernel ms | CPU prep ms | H2D metadata ms | GPU prep ms | E2E ms | E2E speedup |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| static_chunked identity | CPU | 0.0181 | 3.8871 | 0.7202 | 0.0000 | 4.6254 | 1.000x |
| static_chunked identity | GPU | 0.0179 | 3.4305 | 0.5528 | 0.0957 | 4.0969 | 1.129x |
| persistent_chunked identity | CPU | 0.0277 | 3.8871 | 0.7202 | 0.0000 | 4.6349 | 0.998x |
| persistent_chunked identity | GPU | 0.0276 | 3.4305 | 0.5528 | 0.0957 | 4.1066 | 1.126x |

Interpretation: this first GPU-side worklist builder does not make the graph
kernel faster; it reduces the online metadata path by avoiding full CPU
construction and H2D transfer of expanded work arrays. It is therefore a
preprocessing-path win, not a new compute-kernel win. The remaining CPU cost is
still dominated by Python-side graph/count generation and dynamic metadata
construction, so the next step is to move more of that path to C++ or GPU and
then run a larger median sweep.

Small dynamic sweep:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --quiet \
  --dtypes fp16 \
  --tasks-list 32 128 \
  --dims-list 64 \
  --num-transforms-list 8 \
  --mean-neighbors-list 32 \
  --max-neighbors-list 256 \
  --skews-list 0.8 0.95 \
  --filter-ratios-list 0.6 \
  --transform-active-ratios-list 0.5 \
  --early-exit-ratios-list 0.5 \
  --seeds-list 0 1 \
  --ticket-batch-sizes 1 \
  --persistent-blocks-list 48 \
  --chunk-tokens 32 \
  --warmup 2 --iters 10 \
  --output experiments/rdna3_gather/prof/graph_skew_dynamic_gpuwork_sweep.csv
```

Median over 8 cases:

| strategy | worklist | order | E2E speedup | CPU prep ms | H2D metadata ms | GPU prep ms | kernel ms |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| static_chunked | CPU | identity | 1.000x | 1.945 | 0.741 | 0.000 | 0.0163 |
| static_chunked | GPU | identity | 2.558x | 0.296 | 0.462 | 0.081 | 0.0163 |
| static_chunked | CPU | sorted | 0.994x | 2.031 | 0.728 | 0.000 | 0.0158 |
| static_chunked | GPU | sorted | 2.487x | 0.313 | 0.459 | 0.080 | 0.0158 |
| persistent_chunked | CPU | identity | 0.993x | 1.945 | 0.741 | 0.000 | 0.0319 |
| persistent_chunked | GPU | identity | 2.505x | 0.296 | 0.462 | 0.081 | 0.0319 |

The stable signal is that GPU worklist generation cuts the measured online
metadata path substantially for dynamic workloads. Persistent scheduling still
does not win the kernel-only comparison in this small sweep; its value remains
tied to load balancing once the preprocessing bottleneck is under control.

## Phase 3D: GPU Metadata Generation And Bucketed Two-Level Scheduling

Implemented:

- `graph_generate_varlen_metadata`: a GPU-side synthetic metadata generator
  that creates `counts`, `offsets`, `flat_indices`, `identity_order`,
  `bucket_order`, `transform_counts`, and `edge_limits`.
- `--metadata-builders cpu gpu` in `sweep_graph_skew.py`.
- `--order-buckets` for lightweight count-bucket ordering. This is a bucketed
  approximation, not an exact sort.

Important scope note: the GPU metadata path uses a deterministic synthetic
Pareto-like count generator. It is intended to benchmark a GPU-native online
metadata pipeline. It should be compared within `metadata_builder=gpu`; it is
not a row-identical replacement for the CPU normalized Pareto generator.

Sanity command:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --quiet \
  --metadata-builders cpu gpu \
  --dtypes fp16 \
  --tasks-list 32 \
  --dims-list 64 \
  --num-transforms-list 8 \
  --mean-neighbors-list 32 \
  --max-neighbors-list 256 \
  --skews-list 0.8 \
  --filter-ratios-list 0.6 \
  --transform-active-ratios-list 0.5 \
  --early-exit-ratios-list 0.5 \
  --seeds-list 0 \
  --ticket-batch-sizes 1 \
  --persistent-blocks-list 48 \
  --chunk-tokens 32 \
  --order-buckets 8 \
  --warmup 1 --iters 3 \
  --output experiments/rdna3_gather/prof/graph_skew_metadata_builders_sanity.csv
```

Median sweep:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --quiet \
  --metadata-builders cpu gpu \
  --dtypes fp16 \
  --tasks-list 32 128 256 \
  --dims-list 64 \
  --num-transforms-list 8 \
  --mean-neighbors-list 32 \
  --max-neighbors-list 256 \
  --skews-list 0.8 0.95 \
  --filter-ratios-list 0.6 \
  --transform-active-ratios-list 0.5 \
  --early-exit-ratios-list 0.5 \
  --seeds-list 0 1 2 \
  --ticket-batch-sizes 1 4 \
  --persistent-blocks-list 48 256 \
  --chunk-tokens 32 \
  --order-buckets 8 \
  --warmup 2 --iters 10 \
  --output experiments/rdna3_gather/prof/graph_skew_metadata_phase3d_sweep.csv
```

Key medians:

| metadata | strategy | order | ticket | blocks | E2E median | E2E min | bad `<0.95x` | CPU prep ms | H2D ms | GPU prep ms |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| CPU | static_chunked | CPU worklist identity | 0 | 48 | 1.000x | 1.000x | 0 | 2.197 | 0.700 | 0.000 |
| CPU | static_chunked | GPU worklist identity | 0 | 48 | 3.214x | 1.168x | 0 | 0.333 | 0.406 | 0.087 |
| GPU | static_chunked | bucket | 0 | 48 | 1.080x | 0.968x | 0 | 0.000 | 0.000 | 0.216 |
| GPU | static_chunked | bucket | 0 | 256 | 1.087x | 0.978x | 0 | 0.000 | 0.000 | 0.213 |
| GPU | persistent_chunked | bucket | 1 | 256 | 1.048x | 0.951x | 0 | 0.000 | 0.000 | 0.213 |
| GPU | persistent_chunked | bucket | 4 | 256 | 1.034x | 0.944x | 1 | 0.000 | 0.000 | 0.213 |

Best strategy count for `metadata_builder=gpu` over the 36 tested
case/block combinations:

- `static_chunked + bucket`: 33 cases.
- `static_chunked + identity`: 3 cases.
- `persistent_chunked`: 0 cases.

Persistent block extension:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --quiet \
  --metadata-builders gpu \
  --dtypes fp16 \
  --tasks-list 32 128 256 \
  --dims-list 64 \
  --num-transforms-list 8 \
  --mean-neighbors-list 32 \
  --max-neighbors-list 256 \
  --skews-list 0.8 0.95 \
  --filter-ratios-list 0.6 \
  --transform-active-ratios-list 0.5 \
  --early-exit-ratios-list 0.5 \
  --seeds-list 0 1 2 \
  --ticket-batch-sizes 1 4 \
  --persistent-blocks-list 256 512 1024 \
  --chunk-tokens 32 \
  --order-buckets 8 \
  --warmup 2 --iters 10 \
  --output experiments/rdna3_gather/prof/graph_skew_gpumeta_persistent_blocks_sweep.csv
```

Result: increasing persistent blocks beyond 256 did not overtake static
bucketed dispatch. `persistent_chunked + bucket + batch=1` stayed around
`1.040x-1.046x` E2E median for 256/512/1024 blocks, while
`static_chunked + bucket` stayed around `1.070x-1.083x`.

Current Phase 3D conclusion: two-level scheduling is worthwhile in the
static/bucketed form: GPU metadata generation plus bucketed static chunked
dispatch reduces online metadata overhead and gives a stable E2E gain. The
persistent queue inside the bucket is not justified on this synthetic dynamic
workload yet.

## Phase 3E: Fixed-Grid Self-Culling Static Dispatch

Implemented:

- `graph_build_varlen_work_items_fixed`: builds a fixed-capacity compacted
  worklist on device and returns a device-resident `work_size`.
- `graph_varlen_static_chunked_fixed`: launches a fixed grid over the worklist
  capacity and returns immediately when `blockIdx.x >= work_size[0]`.
- `static_chunked_fixed/worklist=fixed` reporting in `sweep_graph_skew.py`.

This avoids the host readback and exact-size tensor allocation used by the
previous GPU worklist path. The capacity is a conservative upper bound:

```text
tasks * num_transforms * ceil(max_neighbors / chunk_tokens)
```

Sanity command:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --quiet \
  --metadata-builders gpu \
  --dtypes fp16 \
  --tasks-list 32 \
  --dims-list 64 \
  --num-transforms-list 8 \
  --mean-neighbors-list 32 \
  --max-neighbors-list 256 \
  --skews-list 0.8 \
  --filter-ratios-list 0.6 \
  --transform-active-ratios-list 0.5 \
  --early-exit-ratios-list 0.5 \
  --seeds-list 0 \
  --ticket-batch-sizes 1 \
  --persistent-blocks-list 48 \
  --chunk-tokens 32 \
  --order-buckets 8 \
  --warmup 1 --iters 3 \
  --output experiments/rdna3_gather/prof/graph_skew_phase3e_fixed_sanity.csv
```

Representative sanity result:

| strategy | worklist | order | kernel ms | GPU prep ms | E2E ms | E2E speedup |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| static_chunked | exact GPU | identity | 0.0183 | 0.5308 | 0.5491 | 1.000x |
| static_chunked_fixed | fixed | identity | 0.0175 | 0.2365 | 0.2540 | 2.162x |
| static_chunked | exact GPU | bucket | 0.0172 | 0.2270 | 0.2442 | 2.249x |
| static_chunked_fixed | fixed | bucket | 0.0175 | 0.2028 | 0.2204 | 2.492x |

Median sweep:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --quiet \
  --metadata-builders gpu \
  --dtypes fp16 \
  --tasks-list 32 128 256 \
  --dims-list 64 \
  --num-transforms-list 8 \
  --mean-neighbors-list 32 \
  --max-neighbors-list 256 \
  --skews-list 0.8 0.95 \
  --filter-ratios-list 0.6 \
  --transform-active-ratios-list 0.5 \
  --early-exit-ratios-list 0.5 \
  --seeds-list 0 1 2 \
  --ticket-batch-sizes 1 4 \
  --persistent-blocks-list 48 256 \
  --chunk-tokens 32 \
  --order-buckets 8 \
  --warmup 2 --iters 10 \
  --output experiments/rdna3_gather/prof/graph_skew_phase3e_fixed_sweep.csv
```

Key medians over 18 cases per row:

| strategy | order | blocks | E2E median | E2E min | bad `<0.95x` | GPU prep ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| static_chunked exact GPU | bucket | 48 | 1.086x | 1.027x | 0 | 0.211 |
| static_chunked exact GPU | bucket | 256 | 1.083x | 0.992x | 0 | 0.213 |
| static_chunked_fixed | bucket | 48 | 1.186x | 1.100x | 0 | 0.190 |
| static_chunked_fixed | bucket | 256 | 1.183x | 1.131x | 0 | 0.188 |
| persistent_chunked | bucket, batch=1 | 256 | 1.047x | 0.962x | 0 | 0.213 |

Extreme filtering sweep (`filter_ratio=0.1`):

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --quiet \
  --metadata-builders gpu \
  --dtypes fp16 \
  --tasks-list 32 128 256 \
  --dims-list 64 \
  --num-transforms-list 8 \
  --mean-neighbors-list 32 \
  --max-neighbors-list 256 \
  --skews-list 0.8 0.95 \
  --filter-ratios-list 0.1 \
  --transform-active-ratios-list 0.5 \
  --early-exit-ratios-list 0.5 \
  --seeds-list 0 1 2 \
  --ticket-batch-sizes 1 4 \
  --persistent-blocks-list 48 256 \
  --chunk-tokens 32 \
  --order-buckets 8 \
  --warmup 2 --iters 10 \
  --output experiments/rdna3_gather/prof/graph_skew_phase3e_extreme_filter_sweep.csv
```

Key extreme-filter medians:

| strategy | order | blocks | E2E median | E2E min | bad `<0.95x` |
| --- | --- | ---: | ---: | ---: | ---: |
| static_chunked exact GPU | bucket | 48 | 1.085x | 0.986x | 0 |
| static_chunked exact GPU | bucket | 256 | 1.036x | 1.002x | 0 |
| static_chunked_fixed | bucket | 48 | 1.167x | 1.090x | 0 |
| static_chunked_fixed | bucket | 256 | 1.131x | 1.084x | 0 |
| persistent_chunked | bucket, batch=1 | 256 | 1.005x | 0.967x | 0 |

Current Phase 3E conclusion: fixed-grid self-culling is the preferred Level 2
dispatch form. It keeps `work_size` on device, avoids host-driven exact grid
sizing, and remains stable even when 90% of edges are dynamically filtered.
Persistent remains a fallback candidate for future multi-hop or truly
runtime-generated workloads, not for this bucketed compacted-worklist regime.

## Phase 3F: Fixed Capacity Sweep And Overflow Fallback

Implemented:

- `--fixed-capacity-scales`: sweeps fixed-grid capacity as a multiple of the
  exact compacted work size, plus `max` for the conservative static upper bound.
- `--overflow-policy`: controls behavior when measured work exceeds capacity:
  `error`, `skip`, or `exact`.
- Segmented timing fields:
  - `metadata_build_event_ms`
  - `worklist_build_ms`
  - `worklist_build_event_ms`
  - `level2_compute_ms`
- Capacity diagnostics:
  - `capacity_scale`
  - `actual_work_size`
  - `work_capacity`
  - `capacity_actual_ratio`
  - `overflowed`

Scope note: `actual_work_size` is used only to calibrate this experiment's
capacity sweep. The timed fixed-grid path keeps `work_size` on device and does
not use a host readback to size the Level 2 launch.

Capacity sanity command:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --quiet \
  --metadata-builders gpu \
  --dtypes fp16 \
  --tasks-list 32 \
  --dims-list 64 \
  --num-transforms-list 8 \
  --mean-neighbors-list 32 \
  --max-neighbors-list 256 \
  --skews-list 0.8 \
  --filter-ratios-list 0.6 \
  --transform-active-ratios-list 0.5 \
  --early-exit-ratios-list 0.5 \
  --seeds-list 0 \
  --ticket-batch-sizes 1 \
  --persistent-blocks-list 48 \
  --chunk-tokens 32 \
  --order-buckets 8 \
  --fixed-capacity-scales 1 1.25 2 max \
  --overflow-policy error \
  --warmup 1 --iters 3 \
  --output experiments/rdna3_gather/prof/graph_skew_phase3f_capacity_sanity.csv
```

Overflow sanity command:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --quiet \
  --metadata-builders gpu \
  --dtypes fp16 \
  --tasks-list 32 \
  --dims-list 64 \
  --num-transforms-list 8 \
  --mean-neighbors-list 32 \
  --max-neighbors-list 256 \
  --skews-list 0.8 \
  --filter-ratios-list 0.6 \
  --transform-active-ratios-list 0.5 \
  --early-exit-ratios-list 0.5 \
  --seeds-list 0 \
  --ticket-batch-sizes 1 \
  --persistent-blocks-list 48 \
  --chunk-tokens 32 \
  --order-buckets 8 \
  --fixed-capacity-scales 0.5 1 \
  --overflow-policy exact \
  --warmup 1 --iters 3 \
  --output experiments/rdna3_gather/prof/graph_skew_phase3f_overflow_sanity.csv
```

Overflow fallback was exercised at `capacity_scale=0.5x`: `actual_work_size=132`,
`work_capacity=66`, `overflowed=1`, and `worklist_builder=fixed_overflow_exact`.
Both identity and bucket rows had `max_abs_diff=0.0`, so the too-small-capacity
path does not silently truncate work.

Median capacity sweep:

```bash
python experiments/rdna3_gather/sweep_graph_skew.py \
  --quiet \
  --metadata-builders gpu \
  --dtypes fp16 \
  --tasks-list 32 128 256 \
  --dims-list 64 \
  --num-transforms-list 8 \
  --mean-neighbors-list 32 \
  --max-neighbors-list 256 \
  --skews-list 0.8 0.95 \
  --filter-ratios-list 0.6 \
  --transform-active-ratios-list 0.5 \
  --early-exit-ratios-list 0.5 \
  --seeds-list 0 1 2 \
  --ticket-batch-sizes 1 \
  --persistent-blocks-list 48 \
  --chunk-tokens 32 \
  --order-buckets 8 \
  --fixed-capacity-scales 1 1.25 2 4 8 max \
  --overflow-policy error \
  --warmup 2 --iters 10 \
  --output experiments/rdna3_gather/prof/graph_skew_phase3f_capacity_sweep.csv
```

Bucket-order results over 18 GPU-metadata cases:

| variant | capacity | capacity/actual median | E2E median | E2E min | worklist event ms | worklist wall ms | Level 2 ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| exact GPU worklist | exact | 1.000 | 1.067x | 0.994x | 0.0711 | 0.0987 | 0.0168 |
| fixed self-cull | 1x | 1.000 | 1.196x | 1.165x | 0.0357 | 0.0640 | 0.0170 |
| fixed self-cull | 1.25x | 1.250 | 1.192x | 1.120x | 0.0370 | 0.0648 | 0.0169 |
| fixed self-cull | 2x | 2.000 | 1.191x | 1.059x | 0.0359 | 0.0637 | 0.0170 |
| fixed self-cull | 4x | 4.000 | 1.190x | 1.101x | 0.0360 | 0.0643 | 0.0176 |
| fixed self-cull | 8x | 8.000 | 1.179x | 1.071x | 0.0364 | 0.0641 | 0.0195 |
| fixed self-cull | max | 14.990 | 1.169x | 1.126x | 0.0363 | 0.0642 | 0.0221 |

Interpretation:

- Fixed-grid self-culling remains better than exact GPU worklist generation
  across the tested capacity range.
- The worklist builder is the main win: event time drops from about `0.071 ms`
  to about `0.036 ms`.
- Level 2 self-cull overhead becomes visible as capacity grows: median
  `level2_compute_ms` rises from `0.0170 ms` at `1x` to `0.0221 ms` at `max`.
- Overprovisioning up to `4x` is still stable in this sweep. `8x` and `max`
  remain positive but show the expected capacity-tax trend.

Current Phase 3F conclusion: the recommended RDNA3 route is still GPU metadata
plus fixed-capacity compacted worklist plus fixed-grid self-culling static
dispatch. The production capacity should be chosen from real-trace quantiles or
pre-instantiated capacity classes, with an explicit overflow fallback. The next
step is not more persistent-queue tuning; it is real-trace validation and a thin
PyTorch extension path that keeps inputs and outputs on GPU.

## Phase 3G: Real Trace Capacity Planning

Implemented:

- `trace_capacity_plan.py`: offline planner for fixed-grid capacity classes.
- Input formats:
  - `.jsonl`: one JSON object per trace row.
  - `.pt/.pth`: dict, list of dicts, or dict with `traces`.
  - `.npz`: `counts` arrays or grouped trace arrays.
  - `.csv`: one row per trace with list-valued `counts`, one row per task with
    `trace_id,count`, or trace-like rows with `actual_work_size`.
- Required metadata: `counts`, `offsets`, `indptr`, or `actual_work_size`.
- Optional metadata: `num_transforms`, `transform_counts`, and
  `edge_limits`.
- Output:
  - per-trace CSV with `actual_work_size`, static max-capacity ratio, selected
    class, class ratio, and overflow flag.
  - JSON summary with distribution statistics and recommended classes.

The default planner is ratio-aware rather than pure quantile-based. It chooses
up to `--num-classes` capacities that minimize worst observed
`selected_capacity / actual_work_size` after alignment. This avoids a common
small-batch failure mode where `p50/p90/p99/max` quantiles omit a small
capacity class and overlaunch tiny traces.

Real trace command template:

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

Smoke validation used the existing Phase 3F trace-like CSV because no separate
real trace file is present in this experiment directory:

```bash
python experiments/rdna3_gather/trace_capacity_plan.py \
  --trace experiments/rdna3_gather/prof/graph_skew_phase3f_capacity_sweep.csv \
  --chunk-tokens 32 \
  --num-transforms 8 \
  --capacity-round 64 \
  --num-classes 4 \
  --output experiments/rdna3_gather/prof/trace_capacity_plan_smoke.csv \
  --summary-output experiments/rdna3_gather/prof/trace_capacity_plan_smoke.json
```

Smoke result:

| metric | value |
| --- | ---: |
| trace-like rows | 288 |
| actual work p50 / p90 / p99 / max | 548 / 1094 / 1108 / 1108 |
| static max-capacity ratio p50 / p90 / p99 / max | 1.628 / 14.734 / 15.784 / 15.784 |
| recommended classes | `[192, 576, 1152]` |
| class-capacity ratio p50 / p90 / p99 / max | 1.083 / 1.455 / 1.455 / 1.455 |
| class overflow rate | 0.0% |

Interpretation: on this trace-like sample, conservative static max capacity can
overlaunch by more than `15x` for small work sizes. A small number of
pre-instantiated fixed-grid capacities can keep the observed overlaunch ratio
below `1.455x` while preserving zero overflow. This is only a tooling smoke
result; the production classes must be recomputed from real model traces.

## Phase 3H: vLLM/AWQ Decode Trace Capacity Plan

Input trace:

```text
/home/husrcf/Code/ProtBind/MTP/traceData/vllm_decode_workload
```

This is a trace-only vLLM/AWQ decode workload sweep over prompt lengths
`64/128/256/512/1024/2048`, with strict rows captured at the ROCm paged-attention
`CommonAttentionMetadata` builder boundary. The trace contains 11,932 decode
rows and has checker `error_count=0` for all six JSONL files.

The planner now supports JSONL and reads the provided `actual_work_size`
directly. It does not infer the formula from variable names when this field is
present.

Observed strict-row shape:

| field | value |
| --- | --- |
| `batch_size` | always `1` |
| `q_len` | always `1` |
| `num_q_heads` | `16` |
| `num_kv_heads` | `2` |
| `head_dim` | `256` |
| `chunk_tokens` | `32` |
| `head_mapping` | `kv` |
| `kv_dtype` | `bf16` |

Per prompt-length work sizes:

| prompt len | rows | cache seqlen range | actual work min / p50 / max |
| ---: | ---: | --- | --- |
| 64 | 1,994 | 65-127 | 6 / 6 / 8 |
| 128 | 2,008 | 129-191 | 10 / 10 / 12 |
| 256 | 2,016 | 257-319 | 18 / 18 / 20 |
| 512 | 2,016 | 513-575 | 34 / 34 / 36 |
| 1024 | 1,917 | 1025-1087 | 66 / 66 / 68 |
| 2048 | 1,981 | 2049-2111 | 130 / 130 / 132 |

Combined KV-head gather mapping:

```bash
python experiments/rdna3_gather/trace_capacity_plan.py \
  --trace /home/husrcf/Code/ProtBind/MTP/traceData/vllm_decode_workload/jsonl/dolly_plen64_gen64_gpu1.jsonl \
          /home/husrcf/Code/ProtBind/MTP/traceData/vllm_decode_workload/jsonl/dolly_plen128_gen64_gpu1.jsonl \
          /home/husrcf/Code/ProtBind/MTP/traceData/vllm_decode_workload/jsonl/dolly_plen256_gen64_gpu1.jsonl \
          /home/husrcf/Code/ProtBind/MTP/traceData/vllm_decode_workload/jsonl/dolly_plen512_gen64_gpu1.jsonl \
          /home/husrcf/Code/ProtBind/MTP/traceData/vllm_decode_workload/jsonl/dolly_plen1024_gen64_gpu1.jsonl \
          /home/husrcf/Code/ProtBind/MTP/traceData/vllm_decode_workload/jsonl/dolly_plen2048_gen64_gpu1.jsonl \
  --capacity-round 4 \
  --num-classes 6 \
  --output experiments/rdna3_gather/prof/vllm_decode_capacity_plan_all.csv \
  --summary-output experiments/rdna3_gather/prof/vllm_decode_capacity_plan_all.json
```

Result:

| mapping | scale | recommended classes | p50 actual | p90 actual | max actual | ratio p50 / p90 / p99 / max | overflow |
| --- | ---: | --- | ---: | ---: | ---: | --- | ---: |
| KV-head gather | 1 | `[8, 12, 20, 36, 68, 132]` | 20 | 130 | 132 | 1.015 / 1.200 / 1.333 / 1.333 | 0.0% |
| Q transform chunk 4 | 2 | `[16, 24, 40, 72, 136, 264]` | 40 | 260 | 264 | 1.015 / 1.200 / 1.333 / 1.333 | 0.0% |
| Q-head ownership | 8 | `[64, 96, 160, 288, 544, 1056]` | 160 | 1040 | 1056 | 1.015 / 1.200 / 1.333 / 1.333 | 0.0% |

`scale=2` corresponds to grouped-query reuse with `num_q_heads/num_kv_heads=8`
and a fused transform chunk of 4 Q heads per KV head. `scale=8` corresponds to
one work item per Q head. These are capacity-planning variants, not claims that
one mapping is faster.

Capacity-planning note: 64-block rounding is a poor fit for this small-batch
decode trace if the goal is to minimize overlaunch. With `capacity_round=64`,
the combined plan collapses to `[64, 192]` and overlaunches the smallest rows by
up to `10.67x`. A round of 4 or exact even capacities is the better first
capacity plan. This is a capacity-waste statement; the replay benchmark below
checks whether that waste is large enough to move measured latency.

Current Phase 3H conclusion: for this vLLM/AWQ trace, production should use
pre-instantiated fixed-grid capacity classes rather than a single max-capacity
graph. For the current KV-head gather mapping, the first candidate class set is
`[8, 12, 20, 36, 68, 132]`; if the fused kernel splits the GQA consumers into
4-Q-head chunks, use `[16, 24, 40, 72, 136, 264]` instead. The next benchmark
should replay these capacity classes in the fixed-grid self-culling path and
compare against a single max-capacity launch.

## Phase 3I: vLLM Trace Replay Microbench

Implemented:

- Local trace copy under `experiments/rdna3_gather/trace/vllm_decode_workload`
  so the replay does not depend on the MTP working tree. The copied subset is
  about `13M` and contains only the summary, manifest, JSONL traces, and checker
  outputs.
- `replay_vllm_trace.py`: loads the 11,932 strict vLLM rows and replays their
  `actual_work_size` sequence.
- `replay_self_cull_kernel`: launches `work_capacity` blocks, immediately
  returns when `blockIdx.x >= actual_work_size`, and optionally does a small
  integer loop for active blocks.
- `replay_gather_dot_kernel`: uses the same self-culling launch shape, then runs
  a synthetic gather/dot consumer over bf16/fp16 inputs for active blocks.

The replay compares:

- `single_max`: one capacity class, `[132]`.
- `capacity_class`: `[8, 12, 20, 36, 68, 132]`.
- `round64_class`: `[64, 192]`.

The first multi-iteration timing attempt queued all replay iterations inside one
event interval. That produced a process crash. A focused strace showed:

```text
SIGSEGV {si_signo=SIGSEGV, si_code=SI_KERNEL, si_addr=NULL}
```

The stable harness now synchronizes once per replay iteration and reports the
median event time. This avoids a large unsynchronized launch storm while still
keeping the 11,932 trace-row launches inside each measured replay pass. The
extension also records the returned sink tensor on the current HIP stream.

Self-cull command:

```bash
python experiments/rdna3_gather/replay_vllm_trace.py \
  --modes self-cull \
  --warmup 1 --iters 3 \
  --work-iters-list 0 16 \
  --output experiments/rdna3_gather/prof/vllm_trace_replay_self_cull.csv
```

Self-cull results:

| mode | strategy | classes | empty block fraction | event ms | per trace |
| --- | --- | --- | ---: | ---: | ---: |
| self-cull, 0 iters | single max | `[132]` | 0.662 | 66.073 | 5.537 us |
| self-cull, 0 iters | capacity class | `[8,12,20,36,68,132]` | 0.022 | 66.147 | 5.544 us |
| self-cull, 0 iters | 64-round | `[64,192]` | 0.578 | 66.072 | 5.537 us |
| self-cull, 16 iters | single max | `[132]` | 0.662 | 66.285 | 5.555 us |
| self-cull, 16 iters | capacity class | `[8,12,20,36,68,132]` | 0.022 | 66.262 | 5.553 us |
| self-cull, 16 iters | 64-round | `[64,192]` | 0.578 | 66.181 | 5.547 us |

Gather/dot replay command:

```bash
python experiments/rdna3_gather/replay_vllm_trace.py \
  --modes gather-dot \
  --warmup 1 --iters 3 \
  --output experiments/rdna3_gather/prof/vllm_trace_replay_gather_dot.csv
```

Gather/dot results:

| strategy | classes | empty block fraction | event ms | per trace |
| --- | --- | ---: | ---: | ---: |
| single max | `[132]` | 0.662 | 108.543 | 9.097 us |
| capacity class | `[8,12,20,36,68,132]` | 0.022 | 108.578 | 9.100 us |
| 64-round | `[64,192]` | 0.578 | 108.530 | 9.096 us |

Exploratory `actual_scale=8` replay:

| mode | strategy | classes | empty block fraction | event ms | per trace |
| --- | --- | --- | ---: | ---: | ---: |
| self-cull | single max | `[1056]` | 0.662 | 85.041 | 7.127 us |
| self-cull | capacity class | `[64,96,160,288,544,1056]` | 0.022 | 71.835 | 6.020 us |
| self-cull | 64-round | `[192,1088]` | 0.439 | 75.652 | 6.340 us |
| gather/dot | single max | `[1056]` | 0.662 | 166.024 | 13.914 us |
| gather/dot | capacity class | `[64,96,160,288,544,1056]` | 0.022 | 163.849 | 13.732 us |
| gather/dot | 64-round | `[192,1088]` | 0.439 | 159.013 | 13.327 us |

A reverse-order gather/dot check kept the same qualitative ordering:
`64-round=160.908 ms`, `capacity_class=164.983 ms`, `single_max=164.903 ms`.
This scale-8 replay is only exploratory. It shows that empty-block tax becomes
visible in the self-cull-only path, but a compute consumer can change the best
capacity shape. Do not select production classes from empty-block fraction
alone.

Interpretation:

- Capacity classes reduce empty blocks very effectively: `66.2% -> 2.2%`.
- For this replay shape, measured time is essentially unchanged across
  strategies. The per-row capacity range is small (`<=192`) and each trace row
  is still replayed as a separate kernel launch, so launch/runtime overhead
  dominates the empty-block tax.
- This weakens the earlier wording around 64-rounding: `[64,192]` is wasteful
  in block-count terms, but it is not measurably slower in this per-trace
  launch replay.
- The class plan is still useful for larger fused ownership models
  (`actual_scale=2/8`), batched serving, HIP Graph/pre-instantiated launch
  regimes, or any future design where many trace rows are fused into fewer
  launches. The next capacity decision should therefore be tied to the actual
  integration path, not only to offline block-count ratios.

## Phase 4A: Fused Multi-Row Static Replay

Goal: remove per-row launch overhead and directly test whether capacity classes
matter once all 11,932 vLLM trace rows are replayed inside a small number of
kernel launches.

Implemented:

- `replay_self_cull_fused`: one launch per capacity group, using
  `grid=(work_capacity, rows_in_group)`.
- `replay_gather_dot_fused`: same static row/work mapping, plus the synthetic
  gather/dot consumer.
- No persistent queue and no atomic ticket. The mapping is static:

```cpp
row_id = blockIdx.y;
work_id = blockIdx.x;
if (work_id >= work_size[row_id]) return;
```

The fused replay compares:

- `single_max`: one capacity class.
- `capacity_class`: ratio-aware classes from trace planning.
- `round64_class`: two 64-aligned classes.
- `exact_work_sim`: zero-empty theoretical upper bound grouped by the exact
  observed work sizes. This is a simulation baseline; it does not claim a
  practical host-side exact-grid path.

Scale-1 command:

```bash
python experiments/rdna3_gather/replay_vllm_trace.py \
  --launch-mode fused \
  --include-exact \
  --modes self-cull gather-dot \
  --warmup 1 --iters 5 \
  --work-iters-list 0 \
  --output experiments/rdna3_gather/prof/vllm_trace_replay_fused_scale1_exact.csv
```

Scale-1 result:

| mode | strategy | classes | empty block fraction | event ms | per trace |
| --- | --- | --- | ---: | ---: | ---: |
| self-cull | single max | `[132]` | 0.662 | 1.237 | 0.104 us |
| self-cull | capacity class | `[8,12,20,36,68,132]` | 0.022 | 0.458 | 0.038 us |
| self-cull | 64-round | `[64,192]` | 0.578 | 0.890 | 0.075 us |
| self-cull | exact work | 12 exact classes | 0.000 | 0.446 | 0.037 us |
| gather/dot | single max | `[132]` | 0.662 | 11.313 | 0.948 us |
| gather/dot | capacity class | `[8,12,20,36,68,132]` | 0.022 | 11.005 | 0.922 us |
| gather/dot | 64-round | `[64,192]` | 0.578 | 11.405 | 0.956 us |
| gather/dot | exact work | 12 exact classes | 0.000 | 11.250 | 0.943 us |

Scale-8 command:

```bash
python experiments/rdna3_gather/replay_vllm_trace.py \
  --launch-mode fused \
  --include-exact \
  --actual-scale 8 \
  --capacity-round 4 --num-classes 6 \
  --modes self-cull gather-dot \
  --warmup 1 --iters 5 \
  --work-iters-list 0 \
  --output experiments/rdna3_gather/prof/vllm_trace_replay_fused_scale8_exact.csv
```

Scale-8 result:

| mode | strategy | classes | empty block fraction | event ms | per trace |
| --- | --- | --- | ---: | ---: | ---: |
| self-cull | single max | `[1056]` | 0.662 | 8.791 | 0.737 us |
| self-cull | capacity class | `[64,96,160,288,544,1056]` | 0.022 | 3.153 | 0.264 us |
| self-cull | 64-round | `[192,1088]` | 0.439 | 5.414 | 0.454 us |
| self-cull | exact work | 12 exact classes | 0.000 | 3.153 | 0.264 us |
| gather/dot | single max | `[1056]` | 0.662 | 96.288 | 8.070 us |
| gather/dot | capacity class | `[64,96,160,288,544,1056]` | 0.022 | 95.274 | 7.985 us |
| gather/dot | 64-round | `[192,1088]` | 0.439 | 96.138 | 8.057 us |
| gather/dot | exact work | 12 exact classes | 0.000 | 95.466 | 8.001 us |

Interpretation:

- Removing per-row launches changes the absolute scale dramatically. Scale-1
  gather/dot drops from about `108.5 ms` in per-row replay to about `11.0 ms`
  in fused replay for the capacity-class path.
- Capacity classes are valuable for pure launch/self-cull overhead: scale-1
  self-cull improves `1.237 -> 0.458 ms`, and scale-8 improves
  `8.791 -> 3.153 ms` versus single max.
- With the gather/dot consumer enabled, capacity classes still help, but only
  modestly: about `2.7%` at scale 1 and about `1.1%` at scale 8 versus single
  max in this synthetic consumer.
- `exact_work_sim` does not beat the ratio-aware capacity class in the consumer
  path. It launches more capacity groups, and the zero-empty advantage is too
  small to dominate. This argues against very fine-grained capacity classes for
  the current fused consumer.
- 64-round remains a poor block-count policy, but in fused gather/dot it is only
  slightly slower than capacity classes on these traces. Production policy must
  be chosen from fused consumer timing, not from empty-block fraction alone.

Current Phase 4A conclusion: capacity classes are real after launch overhead is
removed, but their benefit is mostly on the self-cull/scheduling surface. For
this trace and synthetic gather/dot consumer, the compute/memory body dominates.
The practical default should be a small fixed class set, not exact capacities and
not a persistent/God kernel.

Recommended next steps:

1. Keep Phase 4A as the first-order capacity conclusion.
2. Replace the synthetic gather/dot input ABI with a vLLM-like trace-batch ABI:
   block table, sequence lengths, KV head mapping, row offsets, dtype/layout,
   and output stride.
3. Add segmented fused timing for metadata preparation, grouped launches,
   gather/dot, and output/reduce.
4. Use HIP Graph only as a host-overhead mitigation baseline around a fixed
   topology such as `metadata -> fixed-grid gather/dot -> reduce`; do not capture
   11,932 tiny per-row nodes and do not treat HIP Graph as device-side launch.
5. Do not reintroduce persistent ticket scheduling unless a later workload has
   runtime-generated or unpredictable work that static fused mapping cannot
   represent.

## Phase 4B: vLLM-Like Paged KV ABI Replay

Goal: replace the synthetic contiguous gather/dot input with a vLLM-like paged KV
ABI while keeping the Phase 4A static fused mapping. This tests whether the
capacity-class conclusion survives block-table indirection.

Implemented:

- `replay_paged_kv_dot_fused`: fused grouped launch over
  `grid=(work_capacity, rows_in_group)`.
- Per-row metadata:
  - `cache_seqlens`: one decode sequence length per trace row.
  - `block_tables`: synthetic physical page table generated from the real trace
    seqlens.
  - `page_block_size`: taken from the trace unless `--kv-page-tokens` overrides
    it.
- KV pool ABI:
  - `kv_pool`: `[num_pages, num_kv_heads, page_block_size, head_dim]`.
  - `transforms`: `[num_work_heads, head_dim]`.
  - work mapping: `slot -> (chunk_id, work_head)`, then
    `work_head -> kv_head` for GQA-style reuse.
- CSV now reports `launch_count` and `metadata_setup_ms`. The metadata setup is
  a one-time trace-replay setup segment, not included in the kernel event time.

The kernel performs real paged token lookup:

```cpp
row_id = row_indices[blockIdx.y];
work_id = blockIdx.x;
chunk_id = work_id / num_work_heads;
work_head = work_id % num_work_heads;
kv_head = work_head % num_kv_heads;
page = block_tables[row_id, token / page_block_size];
```

Default formal replay uses `--kv-pages 256`. For this trace, the captured
`page_block_size` is `1056`, so the synthetic KV pool is intentionally much more
paged/indirect than the previous contiguous replay.

Scale-1 command:

```bash
python experiments/rdna3_gather/replay_vllm_trace.py \
  --launch-mode fused \
  --include-exact \
  --modes paged-dot \
  --warmup 1 --iters 5 \
  --kv-pages 256 \
  --output experiments/rdna3_gather/prof/vllm_trace_replay_paged_scale1_exact_kv256.csv
```

Scale-1 paged result:

| strategy | classes | launches | empty block fraction | event ms | per trace |
| --- | --- | ---: | ---: | ---: | ---: |
| single max | `[132]` | 1 | 0.662 | 24.590 | 2.061 us |
| capacity class | `[8,12,20,36,68,132]` | 6 | 0.022 | 24.504 | 2.054 us |
| 64-round | `[64,192]` | 2 | 0.578 | 27.534 | 2.308 us |
| exact work | 12 exact classes | 12 | 0.000 | 26.959 | 2.259 us |

Scale-8 command:

```bash
python experiments/rdna3_gather/replay_vllm_trace.py \
  --launch-mode fused \
  --include-exact \
  --actual-scale 8 \
  --capacity-round 4 --num-classes 6 \
  --modes paged-dot \
  --warmup 1 --iters 5 \
  --kv-pages 256 \
  --output experiments/rdna3_gather/prof/vllm_trace_replay_paged_scale8_exact_kv256.csv
```

Scale-8 paged result:

| strategy | classes | launches | empty block fraction | event ms | per trace |
| --- | --- | ---: | ---: | ---: | ---: |
| single max | `[1056]` | 1 | 0.662 | 187.442 | 15.709 us |
| capacity class | `[64,96,160,288,544,1056]` | 6 | 0.022 | 187.363 | 15.703 us |
| 64-round | `[192,1088]` | 2 | 0.439 | 187.547 | 15.718 us |
| exact work | 12 exact classes | 12 | 0.000 | 186.936 | 15.667 us |

Interpretation:

- Moving from contiguous synthetic gather/dot to paged KV raises the scale-1
  capacity-class path from about `11.0 ms` to about `24.5 ms`. The block-table
  indirection and paged memory layout are now first-order costs.
- At scale 1, capacity class and single max are effectively tied
  (`24.504 ms` vs `24.590 ms`). Exact work is slower despite zero empty blocks,
  likely because it creates more launch groups and less regular grid shapes.
- At scale 8, all practical capacity policies are effectively tied around
  `187 ms`; exact work is only about `0.23%` faster than capacity class. This is
  not enough to justify exact capacity as a production route.
- Once the ABI resembles paged KV, empty-block fraction is no longer a reliable
  predictor. Memory indirection, page locality, work-head mapping, and grid shape
  dominate.
- `metadata_setup_ms` is about `56-60 ms` in this Python replay because it
  allocates and initializes a synthetic KV pool and block table. This is setup
  cost for the microbench, not a per-token inference cost; a real integration
  would receive the KV pool and block table from vLLM.

Current Phase 4B conclusion: capacity classes remain a reasonable engineering
choice, but they are not the main optimization lever for vLLM-like paged KV. The
next useful work is memory-layout and ABI fidelity, not more capacity tuning.

Recommended next steps after Phase 4B:

1. Replace the synthetic block table with captured real block IDs if available,
   or collect them in the next vLLM trace pass.
2. Split K and V paths explicitly and add the decode value-aggregation/reduce
   stage; current paged replay is still a dot proxy.
3. Sweep page locality: contiguous physical pages, random pages, page-crossing
   stress, and reused hot pages.
4. Add a HIP Graph baseline only around a fixed small topology such as
   `metadata/update -> grouped paged gather/dot -> reduce`, and measure parameter
   update time separately.
5. Keep persistent/ticket scheduling out of the default route until the workload
   contains runtime-generated tasks that cannot be statically mapped.

## Phase 4C: Paged K/V Attention-Proxy And Locality Sweep

Goal: add the missing V read path and a numerically checked local aggregation
proxy before doing more scheduling work. This is still not full decode attention:
it computes chunk-local softmax over K scores and a scalar value projection from
V. It is designed to stress K/V paged loads, block-table indirection, and local
V aggregation without introducing cross-chunk softmax/reduce yet.

Implemented:

- `replay_paged_kv_attn_fused`: fused grouped launch over
  `grid=(work_capacity, rows_in_group)`.
- Separate K and V pools:
  - `k_pool`: `[num_pages, num_kv_heads, page_block_size, head_dim]`.
  - `v_pool`: same shape as K.
  - `q_transforms`: `[num_work_heads, head_dim]`.
  - `v_transforms`: `[num_work_heads, head_dim]` for scalar value projection.
- Per chunk/work item:
  1. Read paged K and compute `score = dot(K, Q) / sqrt(head_dim)`.
  2. Reduce chunk-local max.
  3. Re-read K scores and read paged V.
  4. Compute chunk-local softmax-weighted value projection.
- `--page-locality {random,contiguous,page-cross,hot-page}` controls synthetic
  physical page assignment.
- `--check-paged-attn` runs a small PyTorch reference comparison.

Correctness check:

```bash
python experiments/rdna3_gather/replay_vllm_trace.py \
  --launch-mode fused \
  --modes paged-attn \
  --limit-traces 8 \
  --kv-pages 32 --kv-page-tokens 64 \
  --dim 64 --chunk-tokens 16 \
  --check-paged-attn --check-rows 4 --check-slots 8 \
  --warmup 0 --iters 1 \
  --output experiments/rdna3_gather/prof/vllm_trace_replay_paged_attn_check.csv
```

Result: `paged_attn_check rows=4 checked=24 max_abs=7.15256e-07`.

Random-locality capacity results:

| scale | strategy | launches | empty block fraction | event ms | per trace |
| ---: | --- | ---: | ---: | ---: | ---: |
| 1 | single max | 1 | 0.662 | 82.778 | 6.937 us |
| 1 | capacity class | 6 | 0.022 | 95.678 | 8.019 us |
| 1 | 64-round | 2 | 0.578 | 87.483 | 7.332 us |
| 1 | exact work | 12 | 0.000 | 97.847 | 8.200 us |
| 8 | single max | 1 | 0.662 | 550.148 | 46.107 us |
| 8 | capacity class | 6 | 0.022 | 547.411 | 45.878 us |
| 8 | 64-round | 2 | 0.439 | 548.910 | 46.003 us |
| 8 | exact work | 12 | 0.000 | 547.202 | 45.860 us |

Locality sweep using practical capacity policies:

| scale | locality | single max ms | capacity class ms | 64-round ms |
| ---: | --- | ---: | ---: | ---: |
| 1 | random | 82.778 | 95.678 | 87.483 |
| 1 | contiguous | 82.011 | 92.400 | 87.346 |
| 1 | page-cross | 82.746 | 96.037 | 88.106 |
| 1 | hot-page | 72.355 | 73.963 | 73.440 |
| 8 | random | 550.148 | 547.411 | 548.910 |
| 8 | contiguous | 553.797 | 553.808 | 555.502 |
| 8 | page-cross | 558.640 | 559.478 | 561.883 |
| 8 | hot-page | 536.075 | 536.494 | 536.475 |

Interpretation:

- Adding V aggregation changes the scheduling conclusion again. At scale 1,
  `single_max` is fastest despite 66% empty blocks. The extra group launches and
  less regular grid shapes of fine capacity classes cost more than they save.
- At scale 8, capacity policy barely matters: all practical policies are within
  about `0.5%` under random locality.
- Page locality is the dominant lever. Hot-page reuse improves scale-1 single
  max by about `12.6%` versus random (`82.778 -> 72.355 ms`) and improves
  scale-8 by about `2.6%` (`550.148 -> 536.075 ms`). This is much larger than
  the capacity-class effect in the K/V path.
- `page-cross` is consistently worst or near-worst, which is the expected shape
  for poor page locality and likely worse TLB/cache behavior.
- This confirms that once K/V paged loads and local V aggregation are present,
  the next useful work is locality/layout/reuse and real block-table fidelity,
  not more capacity tuning.

Current Phase 4C conclusion: for the K/V attention-proxy, a simple single max or
coarse capacity policy is enough. Fine capacity classes and exact work are not
the production priority. The production-facing work should now move to real
block IDs, K/V cache layout, page locality, and the cross-chunk softmax/value
reduction path.



## Phase 4D: Two-Kernel Full Chunk Softmax/Value Reduce

Goal: replace the chunk-local scalar attention proxy with a full cross-chunk
online softmax and vector value aggregation path, while keeping the first version
architecturally clear. This phase deliberately uses two kernels instead of
forcing global atomics into the producer kernel.

Implemented:

- `replay_paged_kv_chunk_workspace`: one block handles one
  `(row, work_head, chunk)` work item and writes chunk-local workspace.
- `replay_paged_kv_reduce_workspace`: one block handles one `(row, work_head)`
  and merges all chunks with the standard online softmax recurrence.
- Workspace layout is head-explicit:
  - `chunk_m`: `[num_rows, num_work_heads, max_chunks]`
  - `chunk_l`: `[num_rows, num_work_heads, max_chunks]`
  - `chunk_acc`: `[num_rows, num_work_heads, max_chunks, value_dim]`
  - `output`: `[num_rows, num_work_heads, value_dim]`
- `replay_vllm_trace.py --modes paged-full` runs all capacity groups through the
  chunk producer, then launches one reduce kernel.
- `--value-dim` controls the vector V aggregation dimension.
- vLLM JSONL `actual_work_size` is now recomputed from
  `cache_seqlen / chunk_tokens / kv_heads` for replay so chunk-size sweeps do not
  reuse stale capture-time work sizes.

The reduce formula is:

```text
m = max(m_old, m_chunk)
l = l_old * exp(m_old - m) + l_chunk * exp(m_chunk - m)
acc = acc_old * exp(m_old - m) + acc_chunk * exp(m_chunk - m)
out = acc / l
```

Correctness checks:

```bash
python experiments/rdna3_gather/replay_vllm_trace.py \
  --launch-mode fused \
  --modes paged-full \
  --limit-traces 4 \
  --kv-pages 16 --kv-page-tokens 32 \
  --dim 32 --value-dim 8 \
  --check-paged-full --check-rows 2 --check-heads 2 \
  --warmup 0 --iters 1 \
  --output experiments/rdna3_gather/prof/vllm_trace_replay_paged_full_check.csv
```

Result: `paged_full_check rows=2 heads=2 checked=32 max_abs=7.82311e-08`.

A second check with `--chunk-tokens 8` validates the recomputed work-size path:
`paged_full_check rows=2 heads=2 checked=32 max_abs=1.19209e-07`.

Full trace replay, random locality, 11,932 rows:

| value dim | strategy | launches | empty block fraction | event ms | per trace | vs single max |
| ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 32 | single max | 2 | 0.662 | 61.695 | 5.171 us | 1.000x |
| 32 | capacity class | 7 | 0.022 | 58.429 | 4.897 us | 1.056x |
| 32 | 64-round | 3 | 0.578 | 62.540 | 5.241 us | 0.986x |
| 64 | single max | 2 | 0.662 | 63.616 | 5.332 us | 1.000x |
| 64 | capacity class | 7 | 0.022 | 59.008 | 4.945 us | 1.078x |
| 64 | 64-round | 3 | 0.578 | 62.897 | 5.271 us | 1.011x |
| 128 | single max | 2 | 0.662 | 64.984 | 5.446 us | 1.000x |
| 128 | capacity class | 7 | 0.022 | 61.676 | 5.169 us | 1.054x |
| 128 | 64-round | 3 | 0.578 | 65.338 | 5.476 us | 0.995x |

`launches` counts capacity producer launches plus the one reduce launch. For
example, single max is one producer launch plus one reduce launch.

Value-dim-32 locality sweep using practical capacity policies:

| locality | single max ms | capacity class ms | 64-round ms |
| --- | ---: | ---: | ---: |
| random | 61.695 | 58.429 | 62.540 |
| contiguous | 60.555 | 56.963 | 60.660 |
| page-cross | 62.957 | 58.539 | 61.961 |
| hot-page | 49.055 | 42.746 | 45.968 |

Interpretation:

- Two-kernel full softmax/value reduce changes the scheduling balance relative
  to Phase 4C. Capacity classes are again measurably useful, improving random
  locality by about `5-8%` versus single max across `value_dim=32/64/128`.
- The benefit is still modest compared with locality. Hot-page reuse improves
  capacity-class `value_dim=32` from `58.429 ms` to `42.746 ms`, about `26.8%`.
- `64-round` remains a poor fit for this batch-1 trace: it has fewer launches
  than fine capacity classes but keeps too many empty blocks.
- The two-kernel design is a good diagnostic baseline. It exposes workspace
  traffic and reduce cost without introducing global atomic ordering or single
  kernel synchronization complexity.
- These locality modes are still synthetic. They do not prove adjacent vLLM block
  IDs are physically adjacent, and they should not be used as a substitute for
  captured real block IDs plus profiler counters.

Current Phase 4D conclusion: keep the two-kernel full-softmax path as the main
correctness/profile baseline. Capacity classes are worth retaining for this full
path, but the larger production lever remains page locality and real block-table
fidelity. Do not re-open persistent/ticket scheduling for this statically known
workload unless the next trace contains runtime-generated tasks.

Recommended next steps after Phase 4D:

1. Collect or replay real vLLM block IDs rather than synthetic physical page
   mappings.
2. Add segmented timing for chunk producer vs reduce kernel so workspace traffic
   can be separated from paged K/V loads.
3. Run `rocprof` on random vs hot-page and capacity vs single-max to check cache,
   memory, occupancy, and scratch behavior.
4. Sweep KV page/block size and `chunk_tokens` now that actual work is recomputed
   from `cache_seqlen`.
5. Only after the two-kernel profile is understood, consider fusing reduce back
   into the producer for selected small-chunk shapes.


## Phase 4E: Segmented Timing And Reduce Ablation

Goal: split Phase 4D into producer and reducer timing so the capacity-class and
locality effects are not inferred from a black-box E2E number. This phase also
adds a reducer ablation that reads only `chunk_m/chunk_l` and skips
`chunk_acc`, isolating softmax metadata reduction from value-accumulator
workspace bandwidth.

Implemented:

- `replay_paged_kv_reduce_ml_workspace`: m/l-only reduce kernel writing
  `[num_rows, num_work_heads, 2]`.
- `--modes paged-full-producer`: runs only the chunk producer launches.
- `--modes paged-full-reduce`: pre-fills workspace once, then times only full
  row/head reduce over `chunk_m/l/acc`.
- `--modes paged-full-reduce-ml`: pre-fills workspace once, then times only the
  m/l-only reducer.

The full path and segmented paths are timed independently, so `full` is not
expected to equal `producer + reduce` exactly. Use the segmented rows for causal
attribution, not as an additive timing model.

Random locality, default `chunk_tokens=32`:

| value dim | strategy | full ms | producer ms | reduce ms | m/l-only reduce ms |
| ---: | --- | ---: | ---: | ---: | ---: |
| 32 | single max | 62.415 | 61.767 | 0.349 | 0.202 |
| 32 | capacity class | 58.338 | 57.908 | 0.474 | 0.188 |
| 32 | 64-round | 61.599 | 62.138 | 0.506 | 0.197 |
| 64 | single max | 62.637 | 63.065 | 0.528 | 0.193 |
| 64 | capacity class | 58.728 | 58.644 | 0.550 | 0.188 |
| 64 | 64-round | 63.331 | 62.392 | 0.551 | 0.192 |
| 128 | single max | 66.385 | 64.721 | 0.678 | 0.254 |
| 128 | capacity class | 61.889 | 61.245 | 0.684 | 0.260 |
| 128 | 64-round | 66.352 | 65.140 | 0.688 | 0.157 |

Hot-page locality, selected value dims:

| value dim | strategy | full ms | producer ms | reduce ms | m/l-only reduce ms |
| ---: | --- | ---: | ---: | ---: | ---: |
| 32 | single max | 47.018 | 45.830 | 0.458 | 0.238 |
| 32 | capacity class | 43.126 | 43.015 | 0.500 | 0.246 |
| 32 | 64-round | 46.880 | 45.763 | 0.482 | 0.200 |
| 128 | single max | 47.864 | 47.986 | 0.679 | 0.255 |
| 128 | capacity class | 45.849 | 44.732 | 0.675 | 0.156 |
| 128 | 64-round | 48.778 | 48.026 | 0.675 | 0.158 |

`chunk_tokens=8`, `value_dim=32`:

| locality | strategy | full ms | producer ms | reduce ms | m/l-only reduce ms |
| --- | --- | ---: | ---: | ---: | ---: |
| random | single max | 161.025 | 161.149 | 1.221 | 0.153 |
| random | capacity class | 153.325 | 152.351 | 1.221 | 0.152 |
| random | 64-round | 157.324 | 155.898 | 1.210 | 0.185 |
| hot-page | single max | 123.014 | 122.969 | 1.232 | 0.188 |
| hot-page | capacity class | 115.725 | 114.024 | 1.116 | 0.241 |
| hot-page | 64-round | 119.653 | 117.737 | 1.235 | 0.190 |

Interpretation:

- Capacity-class benefit is producer-side. In the stable reverse-order random
  `value_dim=32` run, capacity class improves full time by `6.5%` and producer
  time by `6.2%`; reduce time is tiny and does not explain the gain.
- Hot-page benefit is also producer-side. For `value_dim=32`, capacity-class
  producer time improves from `57.908 ms` random to `43.015 ms` hot-page. The
  reducer stays around `0.5 ms`, so locality is acting on paged K/V access, not
  on workspace reduce.
- Reducer is not the current bottleneck. For default chunks, full reduce is only
  about `0.35-0.68 ms` while producer is `43-65 ms`. Even `chunk_tokens=8`
  raises reduce only to about `1.1-1.2 ms` while producer becomes
  `114-161 ms`.
- The m/l-only reducer is `0.15-0.26 ms`. The gap to full reduce is the
  `chunk_acc` value workspace bandwidth, but that gap is still small relative to
  the producer.
- `value_dim=32 -> 128` increases reducer time as expected, but not enough to
  become first-order. The earlier hypothesis that producer is likely dominant is
  supported by segmented timing.
- Therefore, the next optimization target should be producer-side page locality,
  KV layout, chunk sizing, and block-table fidelity. Workspace layout/reducer
  fusion can wait until profiler data shows producer-side memory behavior is no
  longer dominant.

Current Phase 4E conclusion: capacity classes are worth keeping in the full
softmax/value path because they reduce producer-side overlaunch. The reducer is
measurable but not yet a limiting stage. The most important unresolved question
is microarchitectural: which cache/address-translation counters explain the
random vs hot-page producer gap.

Recommended profiler commands should be built from the counters available on the
target ROCm/GPU, for example start by listing counters rather than hard-coding
names:

```bash
rocprof --list-basic
rocprof --list-derived
```

Then profile the narrow matrix:

1. random vs hot-page producer-only, `value_dim=32`, capacity class.
2. random single-max vs capacity-class producer-only, `value_dim=32`.
3. random `value_dim=128` producer-only and reduce-only.
4. random `chunk_tokens=8` producer-only and reduce-only.

Prioritize counter families for L2/MALL requests or hits, VMEM load/store busy
or bytes, TLB/cache translation if available, waves/occupancy/VGPR/scratch, and
VALU utilization. Do not assume a fixed MALL size or semantics before reading the
actual target counters.


## Phase 4F: rocprof Producer Profile

Goal: profile the Phase 4E producer-only path for the narrow matrix that
separates locality and capacity policy:

- random vs hot-page physical page assignment
- single max capacity `[132]` vs capacity classes `[8, 12, 20, 36, 68, 132]`
- `value_dim=32`, `chunk_tokens=32`, full 11,932-row vLLM trace

Profiler tooling result:

- `rocprof-compute` was not usable in the current environment because its Python
  UI/report dependencies are not installed.
- `rocprofv3` direct profiling aborts during PyTorch extension import with a
  rocprofiler configuration-period error.
- `rocprofv3 --attach` is blocked by ptrace permissions.
- Legacy `rocprof --tool-version 2` works if run from the output directory with
  relative output names.
- On this setup, the attempted derived counters `L2CacheHit`, `FETCH_SIZE`,
  `MemUnitBusy`, `GPUBusy`, `OccupancyPercent`, `SALUInsts`, `SFetchInsts`, and
  `VALUInsts` are emitted as `0.000000` for this PyTorch extension workload.
  Raw GL2C/TA counter probes also did not produce usable cache/memory evidence
  on `gfx1100`.

Therefore, this phase treats only dispatch metadata, resource metadata, and the
nonzero `Wavefronts` counter as reliable. Do not infer L2/MALL/TLB behavior from
this profiler run; the locality conclusion still comes from segmented timing.

Input file used:

```text
prof/rocprof_inputs/producer_split.txt
```

Representative commands:

```bash
cd experiments/rdna3_gather/prof/rocprof_runs

rocprof --tool-version 2 -i ../rocprof_inputs/producer_split.txt \
  -o producer_random_capacity_vdim32 \
  python ../../replay_vllm_trace.py \
    --launch-mode fused --modes paged-full-producer \
    --strategy-filter capacity_class \
    --value-dim 32 --warmup 0 --iters 1 \
    --output replay_random_capacity_vdim32.csv

rocprof --tool-version 2 -i ../rocprof_inputs/producer_split.txt \
  -o producer_hot_single_vdim32 \
  python ../../replay_vllm_trace.py \
    --launch-mode fused --modes paged-full-producer \
    --strategy-filter single_max \
    --page-locality hot-page \
    --value-dim 32 --warmup 0 --iters 1 \
    --output replay_hot_single_vdim32.csv
```

Summary from `pmc_4/results_*.csv` plus the replay CSVs:

| locality | strategy | producer event ms | launches | grid threads | wavefronts | empty block fraction |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| random | single max | 64.564 | 1 | 403,206,144 | 15,488,207 | 0.662 |
| random | capacity class | 59.938 | 6 | 139,466,752 | 4,932,615 | 0.022 |
| hot-page | single max | 50.984 | 1 | 403,206,144 | 14,900,392 | 0.662 |
| hot-page | capacity class | 47.386 | 6 | 139,466,752 | 4,872,813 | 0.022 |

Kernel resource metadata is stable across the four runs:

| field | value |
| --- | ---: |
| workgroup size | 256 |
| wave size | 32 |
| LDS per workgroup | 2,560 bytes |
| scratch per workitem | 0 bytes |
| Arch VGPR | 24 |
| SGPR | 128 |

Capacity-class launch breakdown:

| locality | dispatch | grid threads | wavefronts | profiler duration ms |
| --- | ---: | ---: | ---: | ---: |
| random | 18 | 4,083,712 | 256,935 | 1.314 |
| random | 19 | 6,168,576 | 287,264 | 2.027 |
| random | 20 | 10,321,920 | 409,808 | 4.257 |
| random | 21 | 18,579,456 | 659,008 | 8.015 |
| random | 22 | 33,371,136 | 1,140,416 | 14.306 |
| random | 23 | 66,941,952 | 2,179,184 | 28.587 |
| hot-page | 18 | 4,083,712 | 194,206 | 0.934 |
| hot-page | 19 | 6,168,576 | 271,318 | 1.406 |
| hot-page | 20 | 10,321,920 | 412,064 | 2.586 |
| hot-page | 21 | 18,579,456 | 656,944 | 4.848 |
| hot-page | 22 | 33,371,136 | 1,138,977 | 8.482 |
| hot-page | 23 | 66,941,952 | 2,199,304 | 25.399 |

Interpretation:

- Capacity classes cut launched grid threads by about `65%` versus single max
  (`403.2M -> 139.5M`) while preserving the same actual work. This directly
  matches the producer-side timing gain observed in Phase 4E.
- The `Wavefronts` counter also drops by about `68%` on random locality and
  about `67%` on hot-page locality. Treat the counter as a relative signal here;
  it is not used as a precise occupancy model.
- `scratch per workitem = 0` and `Arch VGPR = 24` rule out scratch spilling as
  the reason for the random-vs-hot-page gap in this producer kernel.
- Hot-page remains faster than random for both capacity policies, but this
  profiler run cannot attribute that to a specific cache, MALL, TLB, or page
  locality counter. The safe conclusion is still timing-based: hot-page improves
  producer-side paged K/V access locality.

Current profiler conclusion: the reliable rocprof evidence supports the
capacity-class mechanism as an overlaunch/wavefront reduction in the producer.
It does not yet explain the memory hierarchy source of the hot-page speedup.
The next profiler step should use a working rocprofv3/rocprof-compute setup or
a lower-level standalone HIP binary to collect nonzero cache, VMEM, and TLB
counters without PyTorch extension/profiler interaction.

Interpretation guardrails:

- Do not claim command processor, SPI, or front-end queue saturation from this
  run. The measured evidence is narrower: capacity classes reduce launched grid
  threads, early-exit work, and profiler-reported wavefronts.
- `Arch VGPR = 24` and `scratch = 0` are useful because they rule out scratch
  spilling as the obvious cause, but they do not prove 100% theoretical
  occupancy. SGPR pressure, LDS allocation, workgroup size, wave slots, barriers,
  and scheduler limits still matter.
- Do not state that the producer is "100% memory latency bound". The data points
  to producer-side cost dominated by paged K/V access plus overlaunch/front-end
  work, but the current profiler did not expose valid VMEM/cache/TLB counters.
- The rocprofv3/derived-counter failures should be recorded as a limitation of
  this PyTorch extension profiling path, not attributed to a specific root cause
  such as Python, GIL, or allocator hooks without a separate repro.
- If `rocprofv3 --attach` is revisited via Linux `ptrace_scope`, treat it as a
  temporary system-level profiling change on an isolated machine and restore the
  original setting afterward.


## Phase 4G: Standalone HIP Producer Profiler Path

Goal: remove Python, PyTorch extension loading, and the PyTorch allocator from
the profiling path so cache/VMEM/TLB counters can be retried on a clean HIP
binary.

Implemented:

- `standalone_paged_producer.hip`: pure HIP C++ replay of the Phase 4D producer
  kernel. It loads the local vLLM JSONL trace, reconstructs `cache_seqlens`,
  recomputes `actual_work_size`, builds the same capacity groups, creates
  synthetic paged K/V block tables, initializes packed BF16-like K/V/Q buffers on
  GPU, and launches a producer-only chunk-softmax/value workspace kernel.
- `Makefile`: builds the standalone binary with `hipcc -O3 -std=c++17
  --offload-arch=gfx1100`.
- `prof/rocprof_inputs/standalone_producer_split.txt`: rocprofv2 input targeting
  `replay_paged_kv_chunk_softmax_standalone`.

Build status:

```bash
make -C experiments/rdna3_gather standalone_paged_producer
```

completed successfully and produced:

```text
experiments/rdna3_gather/standalone_paged_producer
```

Important profiling preflight:

```bash
rocm-smi
rocm-smi --showpids
```

At setup time, the target GPU was not idle: `rocm-smi` reported GPU 0 at 100%
GPU use and `rocm-smi --showpids` showed a live `python` KFD process
(`PID 1096451`) using GPU resources. No standalone smoke/profile numbers were
recorded under that condition, because they would be contaminated.

When the target GPU is idle, run:

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

Then retry profiling, preferably with `rocprofv3` first. If `rocprofv3` still
does not produce usable counters, fall back to:

```bash
mkdir -p experiments/rdna3_gather/prof/rocprof_standalone_runs
cd experiments/rdna3_gather/prof/rocprof_standalone_runs

rocprof --tool-version 2 -i ../rocprof_inputs/standalone_producer_split.txt \
  -o standalone_random_capacity_vdim32 \
  ../../standalone_paged_producer \
    --strategy capacity_class --page-locality random \
    --warmup 0 --iters 1 \
    --output ../standalone_random_capacity_vdim32_rocprof.csv
```

Expected decision criteria:

- If standalone profiling produces nonzero cache/VMEM/TLB counters, use it to
  attribute the random-vs-hot-page gap.
- If standalone profiling still only gives dispatch/resource counters, keep the
  current safe claim: capacity classes reduce producer overlaunch/wavefronts,
  while hot-page improves locality without a confirmed cache-level attribution.


## Phase 4H: Standalone HIP GPU1 Baseline And rocprofv3

GPU0 was busy during profiling:

```text
Device 0: GPU% 95-100%, KFD python process PID 1096451
Device 1: GPU% 0%, low power
```

The standalone runs below therefore use GPU1 via:

```bash
HIP_VISIBLE_DEVICES=1
```

Do not directly mix absolute timing with earlier GPU0 PyTorch-extension results.
Use these as an internally consistent GPU1 baseline. `ROCR_VISIBLE_DEVICES=1`
hid the device on this machine, so the working isolation mechanism was
`HIP_VISIBLE_DEVICES=1` only.

Standalone baseline, no profiler, `warmup=1`, `iters=3`:

| locality | strategy | event ms | per trace us | launches | grid threads | empty block fraction |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| random | single max | 55.882 | 4.683 | 1 | 403,206,144 | 0.662 |
| random | capacity class | 55.791 | 4.676 | 6 | 139,466,752 | 0.022 |
| hot-page | single max | 41.006 | 3.437 | 1 | 403,206,144 | 0.662 |
| hot-page | capacity class | 41.093 | 3.444 | 6 | 139,466,752 | 0.022 |

Key timing observation:

- In standalone HIP on GPU1, capacity class does **not** reproduce the
  PyTorch-extension producer timing gain. It cuts launched work dramatically,
  but event time is effectively tied with `single_max`.
- Hot-page still improves producer time by about `26%` relative to random
  locality for both policies. This strengthens the conclusion that locality is
  the larger lever for the standalone producer path.

`rocprofv3 --kernel-trace` works on the standalone binary. The earlier
PyTorch-extension `rocprofv3` failure is therefore path-specific, not a blanket
rocprofv3 failure.

`rocprofv3` Wavefronts, `warmup=0`, `iters=1`:

| locality | strategy | profiler ms | launches | grid threads | Wavefronts | VGPR | SGPR | scratch |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| random | single max | 56.181 | 1 | 403,206,144 | 12,600,192 | 24 | 128 | 0 |
| random | capacity class | 55.832 | 6 | 139,466,752 | 4,358,336 | 24 | 128 | 0 |
| hot-page | single max | 41.525 | 1 | 403,206,144 | 12,600,192 | 24 | 128 | 0 |
| hot-page | capacity class | 40.987 | 6 | 139,466,752 | 4,358,336 | 24 | 128 | 0 |

Counter status:

- `Wavefronts` is nonzero and matches the expected launch-size reduction:
  capacity class reduces wavefronts by about `65%` (`12.60M -> 4.36M`).
- `L2CacheHit`, `GL2C_HIT_sum`, `GL2C_MISS_sum`, TA load/store counters, and SQ
  instruction counters were still emitted as zero in standalone. So the
  standalone path solves the rocprofv3 launch/import problem, but not the
  cache/VMEM counter availability problem on this setup.
- A large multi-counter `rocprofv3 --pmc` request exceeded hardware single-pass
  counter capacity and left the target process hung; it had to be killed. Future
  counter experiments should use one small counter group per run.

Updated interpretation:

- The capacity-class mechanism definitely reduces overlaunch and wavefronts.
  However, in standalone HIP on GPU1 that reduction does not translate into a
  measurable timing gain. The earlier PyTorch-extension capacity gain likely
  includes framework/launch-path effects or GPU/card-state differences, not just
  raw producer kernel execution.
- The random-vs-hot-page gap persists under standalone HIP and remains the
  strongest signal. We still cannot attribute it to L2, MALL, TLB, or a specific
  cache level because the relevant counters are zero.
- The next root-cause step is not another capacity sweep. It is either:
  1. fix counter collection at the ROCm/tooling level for GL2C/TA/SQ/translation
     counters, or
  2. add controlled layout/locality ablations in the standalone binary
     (`kv_pages`, `hot_pages`, page assignment pattern, page block size) and use
     timing as the primary signal.

Controlled locality ablations, GPU1 standalone, capacity class, `warmup=1`,
`iters=3`:

| page block size | kv pages | locality | hot pages | event ms | note |
| ---: | ---: | --- | ---: | ---: | --- |
| 1056 | 256 | random | 0 | 55.791 | default random |
| 1056 | 256 | contiguous | 0 | 54.236 | slightly better than random |
| 1056 | 256 | page-cross | 0 | 55.725 | near random |
| 1056 | 256 | hot-page | 1 | 41.093 | shared first large page |
| 1056 | 256 | hot-page | 2 | 32.250 | all current trace pages hot |
| 1056 | 32 | random | 0 | 45.203 | smaller physical page pool |
| 1056 | 64 | random | 0 | 46.680 | smaller physical page pool |
| 1056 | 1024 | random | 0 | 57.154 | larger physical page pool |
| 16 | 4096 | random | 0 | 42.433 | smaller total K/V footprint |
| 16 | 4096 | hot-page | 1 | 42.507 | one 16-token hot page is negligible |
| 16 | 4096 | hot-page | 16 | 48.592 | noisy/unfavorable under smaller pool |
| 16 | 16896 | random | 0 | 54.717 | footprint roughly matches default |
| 16 | 16896 | hot-page | 16 | 50.026 | shared 256-token prefix improves timing |

Locality interpretation from timing:

- With the trace-native `page_block_size=1056`, each sequence has only one or
  two large pages. Sharing page 0 across rows is a very strong prefix-cache
  proxy and improves capacity-class producer time from `55.8 ms` to `41.1 ms`;
  sharing both pages improves it to `32.3 ms`.
- Reducing the random physical page pool from `256` to `32/64` pages improves
  timing, while increasing it to `1024` pages slightly hurts. This supports the
  page-reuse/locality explanation even without usable cache counters.
- Simulating 16-token pages changes the story. A single hot page only covers the
  first 16 tokens and has no benefit. With a footprint comparable to the default
  pool, a 16-page hot prefix (256 tokens) improves `54.7 ms -> 50.0 ms`.
- Therefore the current trace-native hot-page result should be described as a
  shared-large-page/prefix-reuse stress test, not as a direct measurement of
  production 16-token paged-attention locality. For production fidelity, the
  next trace should carry real block IDs or enough metadata to reconstruct the
  actual vLLM KV block size and physical block reuse pattern.


## Phase 4I: vLLM Block Table v2 Smoke Trace Acceptance

The first v2 smoke trace was collected under:

```text
/home/husrcf/Code/ProtBind/MTP/traceData/vllm_decode_block_table_v2_smoke
```

It has been copied into the local experiment directory without deleting the
original:

```text
experiments/rdna3_gather/trace/vllm_decode_block_table_v2_smoke
```

Smoke input:

```text
trace/vllm_decode_block_table_v2_smoke/jsonl/dolly_plen64_gen8_gpu0.jsonl
```

Schema acceptance:

- `schema_version = 2` for all rows.
- `trace_type = vllm_paged_kv_block_table` for all rows.
- `sequences[].block_ids` is present and contains real block table values.
- `block_size_tokens = page_block_size = 1056` for all rows.
- vLLM log confirms this is a real runtime setting:
  `Setting attention block size to 1056 tokens to ensure that attention page size
  is >= mamba page size`.
- Checker reports `error_count = 0`.

Smoke summary:

| field | value |
| --- | ---: |
| rows | 7 |
| prompt length | 64 |
| generated decode rows | 7 |
| cache seqlen range | 65-71 |
| actual work size | 6 |
| valid block count | 1 |
| unique physical block ids | 1 |
| block id sequence | `[4]` repeated |
| block reuse ratio | 0.857 |
| prefix shared block groups | 1 |
| kv cache layout available | false |

Important limitation:

- This smoke trace validates the schema and the block-id capture path, but it is
  too small for production locality conclusions. It has one sample, seven decode
  rows, and only one physical block id.
- `kv_cache_layout.available=false`. This is not a blocker for block-id reuse
  replay, but it prevents address/stride-level analysis of whether adjacent
  block ids imply adjacent memory.

Implemented consumer support:

- `replay_vllm_trace.py` now stores v2 `sequences[].block_ids` and supports:

  ```bash
  --page-locality trace
  ```

  This explicitly uses the trace block table instead of synthetic `random`,
  `contiguous`, `page-cross`, or `hot-page` mapping.

- `standalone_paged_producer.hip` now also supports:

  ```bash
  --page-locality trace
  ```

  It auto-expands `kv_pages` if real block ids exceed the default synthetic pool.
  It rejects `--kv-page-tokens` overrides with trace block ids because the block
  ids are only valid at the trace-native `block_size_tokens`.

Smoke validation:

```bash
./standalone_paged_producer \
  --trace trace/vllm_decode_block_table_v2_smoke/jsonl/dolly_plen64_gen8_gpu0.jsonl \
  --strategy capacity_class \
  --page-locality trace \
  --warmup 0 --iters 1 \
  --output prof/standalone_trace_blockids_smoke.csv
```

Result:

```text
traces=7 actual_min=6 actual_p50=6 actual_max=6
total_actual=42 total_capacity=56 empty_frac=0.25
event_ms=0.04752
```

PyTorch replay smoke:

```bash
python replay_vllm_trace.py \
  --trace trace/vllm_decode_block_table_v2_smoke/jsonl/dolly_plen64_gen8_gpu0.jsonl \
  --launch-mode fused \
  --modes paged-full-producer \
  --strategy-filter capacity_class \
  --page-locality trace \
  --warmup 0 --iters 1 \
  --output prof/replay_trace_blockids_smoke.csv
```

Result:

```text
loaded traces=7 actual_min=6 actual_p50=6.0 actual_max=6
paged_kv_full_producer fused capacity_class classes=[8] empty=0.250
event_ms=2.859
```

Next trace request:

- The v2 schema is accepted. No additional fields are required to run block-id
  replay.
- For production locality conclusions, collect a larger v2 trace with the same
  schema:
  - prompt lengths `64, 128, 256, 512, 1024, 2048`
  - `gen64`
  - at least `32` samples per prompt length for cold single-user decode
  - a separate warm-prefix/prefix-cache run if that path matters
  - continuous batching if serving behavior matters
- If possible, make `kv_cache_layout.available=true` by recording K/V cache
  tensor shape, stride, data pointer, and element size. This is optional for
  block reuse, but required for address-contiguity analysis.


## Phase 4J: Full v2 Block Table Trace Acceptance

The full v2 trace directory is complete:

```text
/home/husrcf/Code/ProtBind/MTP/traceData/vllm_decode_block_table_v2
```

It has been copied into the local experiment tree:

```text
experiments/rdna3_gather/trace/vllm_decode_block_table_v2
```

Manifest:

| field | value |
| --- | --- |
| prompt lengths | `64, 128, 256, 512, 1024, 2048` |
| samples per length | `32` |
| max tokens | `64` |
| runs | `6` |
| total JSONL rows | `11,932` |
| checker errors | `0` |
| schema version | `2` |
| trace type | `vllm_paged_kv_block_table` |
| block size tokens | `1056` for all rows |
| kv cache layout | `available=false` for all rows |
| unique physical block ids | `11` |
| total block references | `14,843` |

Per-file summary:

| file | rows | checker errors | unique block ids | block references |
| --- | ---: | ---: | ---: | ---: |
| `dolly_plen64_gen64_gpu0.jsonl` | 1,994 | 0 | 7 | 1,994 |
| `dolly_plen128_gen64_gpu0.jsonl` | 2,008 | 0 | 7 | 2,008 |
| `dolly_plen256_gen64_gpu0.jsonl` | 2,016 | 0 | 7 | 2,016 |
| `dolly_plen512_gen64_gpu0.jsonl` | 2,016 | 0 | 3 | 2,016 |
| `dolly_plen1024_gen64_gpu0.jsonl` | 1,917 | 0 | 8 | 2,847 |
| `dolly_plen2048_gen64_gpu0.jsonl` | 1,981 | 0 | 2 | 3,962 |

Acceptance decision:

- This directory is the correct full v2 block-table trace for replay and
  block-id reuse analysis.
- The earlier `vllm_decode_block_table_v2_smoke` directory is only schema smoke.
- `vllm_decode_block_table_v2_kvlayout_true` is not a full replacement: it only
  covers prompt length 512 with 4 samples.
- `vllm_decode_block_table_v2_kvlayout_true_32` is also not a full replacement:
  it only covers prompt length 512 and has only 63 rows in its JSONL output.

Remaining limitation:

- `kv_cache_layout.available=false` in the accepted full v2 trace, so it is
  sufficient for real block-id replay and block reuse statistics, but not enough
  for address-contiguity or stride-level memory-layout claims.


## Phase 4K: Strict KV-Layout Trace Accepted And Localized

The strict vLLM paged-KV trace has been copied into the local experiment tree
without raw `runs/` tensors:

```text
experiments/rdna3_gather/trace/vllm_decode_block_table_v2_strict_kvlayout_true
```

Copied subset:

- `jsonl/` batched records and checker outputs
- `jsonl_flattened/` one-sequence-per-row records and checker outputs
- `configs/`
- `SUMMARY.md`, `length_sweep_manifest.json`, `v2_sweep_run_status.json`,
  `flatten_summary.json`
- capacity plans and replay CSV summaries

Local acceptance:

| field | value |
| --- | ---: |
| prompt lengths | `64, 128, 256, 512, 1024, 2048` |
| samples per length | `32` |
| generation length | `64` |
| batched JSONL records | `3,780` |
| flattened JSONL rows | `114,820` |
| checker errors | `0` |
| `kv_cache_layout.available` | `100%` |
| strict gates | decode-only, provenance, KV-layout fields all true |

The flattened trace is now the default input for `replay_vllm_trace.py` and
`standalone_paged_producer.hip`. This avoids accidentally using the older
`vllm_decode_workload` rows or the batched strict `jsonl/` records in replay
kernels that expect one sequence per row.

Default replay input:

```text
trace/vllm_decode_block_table_v2_strict_kvlayout_true/jsonl_flattened
```

Important ABI rule:

- Use `jsonl_flattened/` for current replay and standalone kernels.
- Keep `jsonl/` for provenance and batched metadata inspection.
- Passing batched records to replay is rejected because each record contains
  multiple active sequences.


## Phase 4L: Strict Trace Standalone Locality Matrix

After switching the default replay input to the strict flattened trace, the
pure HIP standalone producer was rerun on GPU1 with:

```text
trace/vllm_decode_block_table_v2_strict_kvlayout_true/jsonl_flattened
chunk_tokens=32
value_dim=32
page_block_size=1056
num_kv_heads=2
work_heads=2
rows=114,820
```

Standalone timing, `warmup=1`, `iters=3`:

| locality | strategy | event ms | per trace us | empty block fraction | launches | grid threads |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| real vLLM block IDs, layout-scoped | capacity class | 541.223 | 4.714 | 0.022 | 6 | 1,328,803,840 |
| real vLLM block IDs, layout-scoped | single max | 542.316 | 4.723 | 0.665 | 1 | 3,879,997,440 |
| random, same KV footprint | capacity class | 544.061 | 4.738 | 0.022 | 6 | 1,328,803,840 |
| contiguous, same KV footprint | capacity class | 542.016 | 4.721 | 0.022 | 6 | 1,328,803,840 |
| hot-page, same KV footprint | capacity class | 386.116 | 3.363 | 0.022 | 6 | 1,328,803,840 |

Locality interpretation:

- Block IDs must be scoped by KV-cache layout pointer/layer. Numeric block IDs
  from different layers or independent prompt-length runs are not the same
  address range.
- After layout scoping, real vLLM block IDs are only slightly faster than
  same-footprint random/contiguous synthetic placement for this full producer
  path.
- Synthetic hot-page remains far faster, so the real captured trace does not
  behave like an ideal shared-prefix upper-bound case.
- The previous unscoped all-length replay made real block IDs look much better
  by aliasing equal numeric block IDs across independent layouts. Treat those
  older `standalone_strict_all_trace_capacity_vdim32.csv` and
  `standalone_strict_all_trace_single_vdim32.csv` files as superseded.

Capacity-policy interpretation:

- Capacity class cuts empty work from `66.5%` to `2.2%`, and grid threads by
  about `65.8%`.
- Timing improves only `0.2%` on layout-scoped real block IDs. This is much
  smaller than the hot-page versus non-hot locality gap.
- Therefore strict full producer performance is primarily governed by paged K/V
  access footprint/locality, not empty-block self-cull overhead.

`rocprofv3 --pmc Wavefronts`, `warmup=0`, `iters=1`, real block IDs:

| strategy | profiler event ms | producer wavefronts | producer grid threads | VGPR | SGPR | scratch |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| capacity class, layout-scoped | 542.859 | 41,525,120 | 1,328,803,840 | 24 | 128 | 0 |
| single max, unprofiled after scope fix | 542.316 | 121,249,920 expected from grid | 3,879,997,440 | 24 | 128 | 0 |

This confirms the capacity policy removes the expected producer wavefronts, but
the removed wavefronts do not translate into proportional time savings. The
stronger optimization target remains page/block locality and KV layout, not
finer capacity classes.

Result files:

```text
prof/standalone_strict_all_trace_capacity_vdim32.csv
prof/standalone_strict_all_trace_single_vdim32.csv
prof/standalone_strict_all_trace_scoped_capacity_vdim32.csv
prof/standalone_strict_all_trace_scoped_single_vdim32.csv
prof/standalone_strict_all_random_capacity_vdim32.csv
prof/standalone_strict_all_random_single_vdim32.csv
prof/standalone_strict_all_random_kvpages10180_capacity_vdim32.csv
prof/standalone_strict_all_contiguous_kvpages10180_capacity_vdim32.csv
prof/standalone_strict_all_hot_page_kvpages10180_capacity_vdim32.csv
prof/standalone_strict_all_contiguous_capacity_vdim32.csv
prof/standalone_strict_all_page_cross_capacity_vdim32.csv
prof/standalone_strict_all_hot_page_capacity_vdim32.csv
prof/standalone_strict_all_hot_page_single_vdim32.csv
prof/rocprofv3_strict_runs/strict_trace_capacity_wavefronts_counter_collection.csv
prof/rocprofv3_strict_runs/strict_trace_single_wavefronts_counter_collection.csv
prof/rocprofv3_strict_runs/strict_trace_scoped_capacity_wavefronts_counter_collection.csv
```

Two-kernel full-path PyTorch extension replay after the same block-scope fix:

| locality | strategy | event ms | per trace us | notes |
| --- | --- | ---: | ---: | --- |
| real vLLM block IDs, layout-scoped | capacity class | 544.419 | 4.742 | `paged-full`, `value_dim=32` |
| random, same KV footprint | capacity class | 547.895 | 4.772 | `--kv-pages 10180` |
| hot-page, same KV footprint | capacity class | 390.019 | 3.397 | `--kv-pages 10180` |

Result files:

```text
prof/replay_strict_scoped_trace_all_paged_full_vdim32.csv
prof/replay_strict_random_kvpages10180_all_paged_full_vdim32.csv
prof/replay_strict_hot_page_kvpages10180_all_paged_full_vdim32.csv
```

This full-path result matches the standalone producer conclusion: once numeric
block IDs are scoped by KV layout identity, the real trace is close to a
same-footprint random baseline and far from the synthetic hot-page upper bound.

Row ordering / page grouping:

`standalone_paged_producer` and `replay_vllm_trace.py` now support:

```text
--row-order original
--row-order first-page
```

`first-page` sorts rows inside each capacity class by the first physical page
after layout-scoped block-ID remapping. This is a scheduling-only proxy for
prefix/shared-page grouping; it does not change math ownership or output row
identity.

Standalone producer, `warmup=1`, `iters=3`:

| locality | row order | event ms | per trace us |
| --- | --- | ---: | ---: |
| real vLLM block IDs, layout-scoped | original | 541.223 | 4.714 |
| real vLLM block IDs, layout-scoped | first-page | 337.453 | 2.939 |
| random, same KV footprint | original | 544.061 | 4.738 |
| random, same KV footprint | first-page | 472.533 | 4.115 |
| hot-page, same KV footprint | original | 386.116 | 3.363 |
| hot-page, same KV footprint | first-page | 385.662 | 3.359 |

Two-kernel full-path PyTorch extension, `paged-full`, `value_dim=32`:

| locality | row order | event ms | per trace us |
| --- | --- | ---: | ---: |
| real vLLM block IDs, layout-scoped | original | 544.419 | 4.742 |
| real vLLM block IDs, layout-scoped | first-page | 341.470 | 2.974 |
| random, same KV footprint | original | 547.895 | 4.772 |
| random, same KV footprint | first-page | 477.599 | 4.160 |
| hot-page, same KV footprint | original | 390.019 | 3.397 |

Interpretation:

- Physical-page row grouping is now the largest observed lever in this phase.
- The real trace benefits much more than same-footprint random, which suggests
  the captured block table has exploitable reuse/locality once work is issued in
  a locality-aware order.
- Hot-page is already grouped by construction, so `first-page` gives almost no
  extra gain there.
- This supports prioritizing prefix/shared-page grouping and physical-locality
  work ordering before complex prefetch or HugePage investigations.

Additional result files:

```text
prof/standalone_strict_all_trace_scoped_firstpage_capacity_vdim32.csv
prof/standalone_strict_all_random_kvpages10180_firstpage_capacity_vdim32.csv
prof/standalone_strict_all_hot_page_kvpages10180_firstpage_capacity_vdim32.csv
prof/replay_strict_scoped_trace_firstpage_all_paged_full_vdim32.csv
prof/replay_strict_random_kvpages10180_firstpage_all_paged_full_vdim32.csv
```


## Phase 4M: Strict Trace Block-Reuse And KV Layout Analysis

A reusable trace analysis script was added:

```text
analyze_vllm_strict_trace_layout.py
```

It consumes the strict flattened JSONL by default and writes:

```text
prof/strict_trace_layout_summary.csv
prof/strict_trace_layout_summary.json
```

Global summary:

| field | value |
| --- | ---: |
| flattened rows | 114,820 |
| block references | 142,840 |
| unique numeric block IDs | 101 |
| unique layout-scoped block IDs | 10,180 |
| numeric block reuse ratio | 0.999293 |
| layout-scoped block reuse ratio | 0.928731 |
| layer count | 40 |
| KV pointer pairs per layer | 6 |
| layout signatures | 3 |
| K block stride bytes | 2,162,688 |

Per-prompt block reuse:

| prompt length | rows | block refs | unique blocks | valid blocks p50/max | reuse ratio |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 64 | 19,480 | 19,480 | 32 | 1 / 1 | 0.998357 |
| 128 | 19,380 | 19,380 | 32 | 1 / 1 | 0.998349 |
| 256 | 19,590 | 19,590 | 32 | 1 / 1 | 0.998367 |
| 512 | 19,100 | 19,100 | 32 | 1 / 1 | 0.998325 |
| 1024 | 18,700 | 28,150 | 63 | 2 / 2 | 0.997762 |
| 2048 | 18,570 | 37,140 | 64 | 2 / 2 | 0.998277 |

Layout signatures differ only in the KV-cache block capacity dimension:

| rows | K shape | K stride | V shape | V stride |
| ---: | --- | --- | --- | --- |
| 75,960 | `[872, 2, 32, 1056, 8]` | `[1081344, 270336, 8448, 8, 1]` | `[872, 2, 256, 1056]` | `[1081344, 270336, 1056, 1]` |
| 19,480 | `[892, 2, 32, 1056, 8]` | `[1081344, 270336, 8448, 8, 1]` | `[892, 2, 256, 1056]` | `[1081344, 270336, 1056, 1]` |
| 19,380 | `[882, 2, 32, 1056, 8]` | `[1081344, 270336, 8448, 8, 1]` | `[882, 2, 256, 1056]` | `[1081344, 270336, 1056, 1]` |

Interpretation:

- The real trace is highly reused, not random. Each prompt-length sweep has only
  `32-64` unique block IDs reused across many layers and decode invocations.
- However, numeric block IDs are only meaningful inside their KV layout scope.
  When `(k_data_ptr, v_data_ptr, layer)` is included in the identity, the trace
  has `10,180` unique scoped pages, not `101`. This scoping is now used by
  `replay_vllm_trace.py` and `standalone_paged_producer.hip`.
- This correction removes the artificial cross-layer/cross-run page aliasing
  from the earlier all-length replay.
- The synthetic hot-page case is still faster because it collapses many rows
  onto a smaller idealized shared-page set than the real trace.
- `kv_cache_layout.available=true` now confirms the stride-level layout. It does
  not prove physical HBM adjacency, but it does show that adjacent block IDs are
  adjacent in the traced virtual tensor layout with a constant block stride of
  `2,162,688` bytes.


## Phase 4N: Stride Probe And HugePage Hypothesis Check

A standalone address-stride microbench was added:

```text
standalone_stride_probe.hip
```

Build:

```bash
make -C experiments/rdna3_gather standalone_stride_probe
```

Purpose:

- isolate stride/footprint effects from the paged-attention replay;
- check whether a `2,162,688`-byte KV block stride should be treated as direct
  evidence of a TLB/page-size failure;
- keep HugePage/VRAM page-size work as a system-level investigation, not an ISA
  or kernel mainline assumption.

System check:

```text
rocminfo: XNACK enabled: NO
target GPUs: gfx1100, AMD Radeon Pro W7900 / W7900 Dual Slot
```

Stride probe results, high concurrency (`blocks=4096`, `refs=33,554,432`,
`loads_per_ref=4`):

| footprint | stride | segments | event ms | effective GiB/s |
| ---: | ---: | ---: | ---: | ---: |
| 1GB | 4KB | 262,144 | 18.709 | 26.73 |
| 1GB | 64KB | 16,384 | 14.548 | 34.37 |
| 1GB | 2MB | 512 | 13.074 | 38.24 |
| 1GB | 16MB | 64 | 17.978 | 27.81 |
| 4GB | 4KB | 1,048,576 | 17.587 | 28.43 |
| 4GB | 64KB | 65,536 | 21.082 | 23.72 |
| 4GB | 2MB | 2,048 | 17.067 | 29.30 |
| 4GB | 16MB | 256 | 21.181 | 23.61 |

Stride probe results, lower concurrency (`blocks=64`, `refs=8,388,608`,
`loads_per_ref=4`, 4GB footprint):

| stride | segments | event ms | effective GiB/s |
| ---: | ---: | ---: | ---: |
| 4KB | 1,048,576 | 6.708 | 18.63 |
| 64KB | 65,536 | 4.460 | 28.03 |
| 2MB | 2,048 | 4.273 | 29.26 |
| 16MB | 256 | 6.340 | 19.72 |

Interpretation:

- These results do **not** support the strong claim that a 2MB stride is by
  itself the worst case or direct proof of TLB collapse.
- The probe is still synthetic and does not expose the actual VRAM PTE size.
  It only says the current W7900/ROCm path can service a 2MB-strided access
  stream at least as well as the tested 4KB/64KB/16MB streams under this access
  generator.
- Therefore HugePages/VRAM page-size tuning should remain a low-priority system
  investigation. The main line stays on KV layout/allocator locality and
  page-reuse scheduling.

Result files:

```text
prof/stride_probe_1g_stride4k.csv
prof/stride_probe_1g_stride64k.csv
prof/stride_probe_1g_stride2m.csv
prof/stride_probe_1g_stride16m.csv
prof/stride_probe_4g_stride4k.csv
prof/stride_probe_4g_stride64k.csv
prof/stride_probe_4g_stride2m.csv
prof/stride_probe_4g_stride16m.csv
prof/stride_probe_4g_blocks64_stride4k.csv
prof/stride_probe_4g_blocks64_stride64k.csv
prof/stride_probe_4g_blocks64_stride2m.csv
prof/stride_probe_4g_blocks64_stride16m.csv
```

## Phase 5: Layout-Scoped Row Ordering

Goal: test whether the strict vLLM trace has exploitable KV block reuse that
the original replay order fails to present to the cache/address-translation
hierarchy. This phase uses layout-scoped KV block IDs, not raw numeric block IDs:
the same `block_id` in different layers or KV allocations is treated as a
different address range.

Implemented row-order policies:

- `original`
- `first-page`
- `auto-first-page`
- `first-2-pages`
- `first-4-pages`
- `lexicographic`
- `prefix-hash-2`
- `prefix-hash-4`
- `lcp-bucket` (currently trie-equivalent lexicographic ordering over the
  captured block table)

`auto-first-page` is an online-gating prototype. It computes cheap reuse
predictors before grouping rows:

- `first_page_unique / rows`
- adjacent first-page hit ratio in the incoming row order
- median unique first pages in 128-row windows
- median unique-first-page ratio in 128-row windows
- adjacent shared-prefix length mean
- optional `min_rows`

With the current default thresholds, it enables `first-page` if any of these
conditions indicates enough reuse:

```text
rows >= auto_first_page_min_rows
first_page_unique_ratio <= 0.50
first_page_unique_w128_ratio_p50 <= 0.75
adjacent_first_page_hit_ratio >= 0.05
first_page_unique_w128_p50 <= 96
adjacent_lcp_mean >= 1.0
```

The replay keeps row identity intact. The grouped launch sorts rows only inside
each capacity class, and kernels receive `row_indices`, so outputs are written
to the original row slots. In a production scheduler this is the same role as an
inverse permutation.

Reuse metric script:

```bash
python experiments/rdna3_gather/analyze_row_order_reuse.py \
  --output experiments/rdna3_gather/prof/strict_trace_row_order_reuse.csv
```

Selected reuse metrics on the 114,820-row strict trace:

| row order | adjacent LCP mean | reuse distance p50 | unique pages/window-128 p50 |
| --- | ---: | ---: | ---: |
| original | 0.000 | 1240.0 | 128.0 |
| first-page | 1.155 | 1.0 | 10.0 |
| first-2-pages | 1.155 | 1.0 | 10.0 |
| lexicographic | 1.155 | 1.0 | 10.0 |
| prefix-hash-2 | 1.145 | 1.0 | 10.0 |

Standalone kernel-only ablation (`standalone_paged_producer`, capacity classes,
`value_dim=32`, `page-locality=trace`):

| row order | event ms | speedup vs original |
| --- | ---: | ---: |
| original | 541.053 | 1.000x |
| auto-first-page -> first-page | 337.433 | 1.604x |
| first-page | 337.523 | 1.603x |
| first-2-pages | 337.624 | 1.602x |
| first-4-pages | 337.785 | 1.602x |
| lexicographic | 337.598 | 1.603x |
| lcp-bucket | 337.698 | 1.602x |
| prefix-hash-2 | 344.105 | 1.572x |
| prefix-hash-4 | 344.537 | 1.570x |

PyTorch extension two-kernel `paged-full` replay, same trace and policy:

| row order | event ms | speedup vs original |
| --- | ---: | ---: |
| original | 544.302 | 1.000x |
| auto-first-page -> first-page | 341.340 | 1.595x |
| first-page | 341.293 | 1.595x |
| first-2-pages | 341.233 | 1.595x |
| lexicographic | 341.266 | 1.595x |
| prefix-hash-2 | 347.771 | 1.565x |

### C++ Scheduler And Restore Path

`standalone_paged_producer` now reports C++ scheduler-side row permutation
costs, split into:

- `scheduler_metrics_ms`: cheap reuse predictor.
- `scheduler_row_order_key_ms`: row-order key construction.
- `scheduler_group_build_ms`: capacity grouping and row permutation.
- `scheduler_group_h2d_ms`: host-to-device update of grouped row metadata.
- `restore_event_ms`: optional explicit `sorted_output -> original_output`
  unpermute kernel.

Two restore modes are supported:

- `row-indices`: current preferred path. Kernels receive sorted `row_indices`
  and write workspace/output by original row id, so there is no separate
  unpermute kernel.
- `explicit-copy`: fallback ABI path. It models a scheduler that writes a sorted
  temporary output and then copies it back to original row order.

Full 114,820-row strict replay, `value_dim=32`, capacity classes:

| row order | restore | kernel ms | scheduler ms | restore ms | online E2E ms |
| --- | --- | ---: | ---: | ---: | ---: |
| original | row-indices | 541.071 | 31.851 | 0.000 | 572.922 |
| first-page | row-indices | 337.314 | 33.347 | 0.000 | 370.660 |
| auto -> first-page | row-indices | 337.439 | 34.229 | 0.000 | 371.667 |
| auto -> first-page | explicit-copy | 337.428 | 33.886 | 0.062 | 371.375 |

The full replay is intentionally much larger than a normal single decode batch;
it stresses 114,820 rows across prompt lengths/layers/steps. A row-count scaling
sweep gives a better sense of online scheduler cost:

| rows | effective order | kernel ms | scheduler ms | H2D ms | restore ms |
| ---: | --- | ---: | ---: | ---: | ---: |
| 512 | original | 4.100 | 0.154 | 0.081 | 0.013 |
| 2,048 | original | 14.798 | 0.367 | 0.095 | 0.014 |
| 8,192 | first-page | 39.942 | 11.055 | 9.789 | 0.017 |
| 32,768 | first-page | 94.419 | 16.755 | 10.923 | 0.036 |
| 114,820 | first-page | 337.380 | 36.282 | 11.090 | 0.062 |

The scheduler cost alone is not enough to claim online ROI. The same row count
must compare `original` against `first-page` or `auto-first-page`:

| rows | policy | effective order | kernel speedup | E2E speedup | first-page unique ratio |
| ---: | --- | --- | ---: | ---: | ---: |
| 512 | first-page | first-page | 0.997x | 0.996x | 1.000 |
| 512 | auto-first-page | original | 1.005x | 1.007x | 1.000 |
| 2,048 | first-page | first-page | 1.053x | 1.025x | 0.625 |
| 2,048 | auto-first-page | original | 0.989x | 0.991x | 0.625 |
| 8,192 | first-page | first-page | 1.486x | 1.386x | 0.156 |
| 8,192 | auto-first-page | first-page | 1.479x | 1.369x | 0.156 |
| 32,768 | first-page | first-page | 1.623x | 1.504x | 0.078 |
| 32,768 | auto-first-page | first-page | 1.618x | 1.521x | 0.078 |

Threshold sweep, disabling all auxiliary gates except `first_page_unique_ratio`.
This isolates how aggressive the global first-page reuse threshold should be:

| threshold | rows | effective order | E2E speedup vs original | first-page unique ratio |
| ---: | ---: | --- | ---: | ---: |
| 0.75 | 512 | original | 1.012x | 1.000 |
| 0.75 | 2,048 | first-page | 1.027x | 0.625 |
| 0.75 | 8,192 | first-page | 1.352x | 0.156 |
| 0.75 | 32,768 | first-page | 1.497x | 0.078 |
| 0.50 | 512 | original | 0.999x | 1.000 |
| 0.50 | 2,048 | original | 0.971x | 0.625 |
| 0.50 | 8,192 | first-page | 1.350x | 0.156 |
| 0.50 | 32,768 | first-page | 1.490x | 0.078 |
| 0.25 | 512 | original | 1.014x | 1.000 |
| 0.25 | 2,048 | original | 0.977x | 0.625 |
| 0.25 | 8,192 | first-page | 1.371x | 0.156 |
| 0.25 | 32,768 | first-page | 1.509x | 0.078 |

With threshold `0.75`, an additional `min_rows` guard can intentionally skip the
2,048-row borderline case:

| min rows | rows | effective order | E2E speedup vs original |
| ---: | ---: | --- | ---: |
| 4,096 | 512 | original | 1.014x |
| 4,096 | 2,048 | original | 0.967x |
| 4,096 | 8,192 | first-page | 1.332x |
| 4,096 | 32,768 | first-page | 1.497x |
| 8,192 | 512 | original | 0.996x |
| 8,192 | 2,048 | original | 0.982x |
| 8,192 | 8,192 | first-page | 1.350x |
| 8,192 | 32,768 | first-page | 1.457x |

Interpretation:

- The output restore cost is negligible at this scale: explicit unpermute is
  about `0.06 ms` for `114,820 x 2 x 32` float outputs, and the preferred
  `row-indices` path avoids it entirely.
- The measured scheduler cost is dominated by host-side key/group construction
  plus synchronous metadata H2D update in this standalone harness. It is still
  far smaller than the `~204 ms` kernel-time gain from row ordering on the full
  replay.
- Do not treat the 114,820-row scheduler cost as one online decode step. For
  smaller row counts, the measured C++ scheduler path is sub-millisecond until
  the gate turns on first-page sorting. Real integration should reuse metadata
  buffers and may need pinned or device-side metadata construction if H2D update
  remains expensive.
- Row ordering is not universally profitable. At 512 rows there is no reuse to
  exploit and forced `first-page` is a wash; `auto-first-page` correctly keeps
  original order. At 2,048 rows forced `first-page` gives a small E2E win but
  conservative gates may reasonably skip it if the target is robustness over
  small wins. At 8,192 rows and above, the gate turns on and the E2E gain remains
  large after scheduler cost.
- `first_page_unique / rows` is a strong predictor on this trace, but it should
  not be the only production gate. A practical policy should combine it with a
  row-count floor and a windowed reuse metric, because online batches can be
  small-but-reused or large-but-unreused.
- Phase 6 closes the row-ordering gate work for now. The conservative default
  should keep `first_page_unique_ratio <= 0.50`, with `0.75` available as an
  aggressive profile. The default restore path remains `row-indices` scatter
  writeback, and original-order fallback must remain enabled for low-reuse or
  small-batch cases.
- The next structural experiments should move away from gate micro-tuning:
  first simulate logical 16-token blocks packed into physical superblocks
  (`4/8/16` logical blocks per local allocation group), then combine that with
  `first-page` ordering and chunked full-attention sweeps. Software-pipelined
  prefetch is only a narrow follow-up microkernel experiment; it should not be a
  main architecture assumption until a C++ unrolled version shows a clear signal
  without VGPR/scratch regressions.

### Phase 7: Physical Superblock Replay Scaffold

The first physical-layout experiment is implemented as a replay-only remap, not
as a vLLM allocator change. With `--page-locality trace`, `--physical-superblock
N` groups layout-scoped numeric block IDs into allocation groups of `N` logical
blocks and maps blocks inside each group to contiguous physical page IDs. The
default `N=1` keeps the previous dense trace remap.

This is intentionally a low-cost simulator. It preserves vLLM logical block
semantics and only changes the synthetic KV pool address mapping used by replay.
It does not claim that real vLLM numeric block IDs are physical addresses.

Initial 8,192-row replay, `value_dim=32`, capacity classes:

| physical superblock | row order | effective order | online E2E ms | speedup vs same-layout original | window-128 page span p50 |
| ---: | --- | --- | ---: | ---: | ---: |
| 1 | original | original | 69.762 | 1.000x | 138 |
| 1 | first-page | first-page | 51.155 | 1.364x | 10 |
| 1 | auto-first-page | first-page | 51.659 | 1.350x | 10 |
| 4 | original | original | 70.067 | 1.000x | 2712 |
| 4 | first-page | first-page | 51.319 | 1.365x | 37 |
| 4 | auto-first-page | first-page | 50.965 | 1.375x | 37 |
| 8 | original | original | 70.678 | 1.000x | 2841 |
| 8 | first-page | first-page | 51.323 | 1.377x | 41 |
| 8 | auto-first-page | first-page | 51.053 | 1.384x | 41 |
| 16 | original | original | 69.812 | 1.000x | 2973 |
| 16 | first-page | first-page | 50.333 | 1.387x | 41 |
| 16 | auto-first-page | first-page | 51.424 | 1.358x | 41 |

Interpretation:

- The scaffold is working, but this first remap does not yet show a clear
  standalone speedup from physical superblocks. Kernel time is dominated by the
  same row-ordering signal as Phase 6.
- Equality-based reuse metrics (`unique pages`, reuse distance, LCP) are
  unchanged by physical remapping, as expected. Superblock layout changes address
  distance/span, not whether two rows refer to the same logical block.
- The current remap uses numeric block-ID groups. On this trace, that can
  increase window span because the captured numeric IDs are sparse across layout
  scopes. The next replay variant should test a compaction-oriented allocator
  model: keep logical IDs stable for sharing, but allocate consecutive blocks in
  generation order inside each `(layout scope, sequence)` or prefix allocation
  segment.

Output files:

```text
prof/phase7_superblock_reuse_s{1,4,8,16}.csv
prof/phase7_superblock_s{1,4,8,16}_{original,first-page,auto-first-page}_rows_8192.csv
prof/phase7_superblock_rows8192_summary.csv
```

Output files:

```text
prof/strict_trace_row_order_reuse.csv
prof/phase5_row_order_ablation_summary.csv
prof/phase5_scheduler_*.csv
prof/phase5_scheduler_scaling_summary.csv
prof/phase6_same_rowcount_e2e_summary.csv
prof/phase6_gate_threshold_sweep_summary.csv
prof/phase6_gate_minrows_sweep_summary.csv
prof/phase5_standalone_trace_*_capacity_vdim32.csv
prof/phase5_replay_strict_scoped_trace_*_paged_full_vdim32.csv
```

Interpretation:

- The strongest measured signal is layout-scoped KV block locality. Original
  order has effectively no adjacent shared prefix; `first-page` ordering
  reduces median reuse distance to 1 and cuts unique pages in a 128-row window
  from 128 to 10.
- `first-page`, `first-2-pages`, `first-4-pages`, `lexicographic`, and
  `lcp-bucket` are equivalent within noise on this strict trace. The likely
  reason is trace shape: each row has only a small number of block-table pages,
  so grouping by the first scoped block captures almost all observable reuse.
- Prefix hash policies are still much better than original but slower than
  direct prefix/lexicographic ordering, likely because hashing loses some
  useful deterministic locality inside a bucket.
- This result does not prove the specific microarchitectural source of the
  gain. It may involve L2, MALL, TLB/address translation, block-table reuse,
  memory coalescing, or several of them. The current profiler data does not
  isolate that layer.
- The auto gate behaves correctly on the tested extremes. On the full strict
  trace it resolves to `first-page` and matches the manual policy. On a
  256-row smoke slice with little first-page reuse, it resolves to `original`.
- `analyze_vllm_strict_trace_layout.py --assert-layout-scoped-remap` now acts
  as a regression guard: strict traces with multiple layouts/layers must show
  more layout-scoped unique blocks than raw numeric unique blocks. This catches
  the class of bug where naked numeric `block_id` is reused across unrelated KV
  layouts.

Current Phase 5 conclusion: the optimization focus should move from capacity
class tuning to locality-aware row scheduling. For the current strict vLLM trace,
`first-page` is the simplest winning policy; deeper prefix sorting does not pay
on this trace, but the infrastructure now supports it for traces with longer
shared prefixes.

Next production-facing check:

1. Move this from standalone replay into the real decode scheduler boundary:
   build the row permutation for each active decode batch, pass sorted row ids to
   the backend, and write outputs by original row id.
2. Replace the current synchronous metadata update with the actual framework
   path. If it remains expensive, test pinned host metadata buffers or
   device-side row-order generation.
3. Include fairness/tail-latency constraints if online serving reorders requests
   across users.
4. If cache counters become available, profile `original` vs `first-page` in the
   standalone binary to locate whether the gain is mainly cache, TLB/address
   translation, or block-table reuse.
