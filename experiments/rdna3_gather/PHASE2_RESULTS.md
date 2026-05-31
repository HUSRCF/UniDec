# RDNA3 Gather/Densify Phase 2 Results

Target: gfx1100 / RDNA3, ROCm 7.2.0

Phase 2 adds a small fused compute consumer:

- `fused_global`: gather from global memory on every consumer pass, then reduce to one `fp32` scalar per task.
- `fused_lds`: gather once into LDS, then run the same consumer passes from the LDS tile.
- `dot_global`: decode-like per-task query dot products, rereading gathered rows from global memory for each query.
- `dot_lds`: decode-like per-task query dot products, gathering the task tile once into LDS and reusing it for all queries.
- `graph_global`: graph-style neighbor aggregation, rereading neighbor rows from global memory for every transform.
- `graph_lds`: graph-style neighbor aggregation, gathering the neighbor tile once into LDS and reusing it across transforms.
- `graph_lds_chunked`: graph-style neighbor aggregation with one block per `(task, transform_chunk)`.
- `graph_auto`: shape-based dispatch over `graph_global`, `graph_lds`, and `graph_lds_chunked`.

The repeated-sum consumer is a controlled reuse proxy. The dot-product consumer is closer to decode score generation. The graph consumer computes multi-transform neighbor aggregation, but still omits persistent scheduling and a full model epilogue.

Formal shape:

- `rows=4096`
- `tasks=32`
- `tile_tokens=128`
- `dim=64`
- `warmup=10`
- `iters=100`
- `pattern=random` unless otherwise noted

Repeated-sum results matched `fused_global` exactly (`max_abs_diff_vs_fused_global=0`). PyTorch reference differences are due only to reduction order and stayed within tolerance.

## Consumer-Pass Sweep

### fp16 / random

| passes | fused_global ms | fused_lds ms | LDS speedup |
| ---: | ---: | ---: | ---: |
| 1 | 0.010653 | 0.011134 | 0.96x |
| 2 | 0.014309 | 0.012776 | 1.12x |
| 4 | 0.021777 | 0.016292 | 1.34x |
| 8 | 0.036675 | 0.022964 | 1.60x |
| 16 | 0.065909 | 0.036861 | 1.79x |

### bf16 / random

| passes | fused_global ms | fused_lds ms | LDS speedup |
| ---: | ---: | ---: | ---: |
| 1 | 0.009820 | 0.010091 | 0.97x |
| 2 | 0.011097 | 0.009313 | 1.19x |
| 4 | 0.016718 | 0.010625 | 1.57x |
| 8 | 0.029500 | 0.014954 | 1.97x |

## Pattern Sweep

fp16, `consumer_passes=4`:

| pattern | fused_global ms | fused_lds ms | LDS speedup |
| --- | ---: | ---: | ---: |
| random | 0.021777 | 0.016292 | 1.34x |
| page-cross | 0.020220 | 0.014644 | 1.38x |
| contiguous | 0.021748 | 0.016119 | 1.35x |
| tail-negative | 0.021825 | 0.016301 | 1.34x |

## ISA And Resource Check

Disassembly was refreshed with:

```bash
/opt/rocm/bin/roc-obj -d -o experiments/rdna3_gather/isa experiments/rdna3_gather/.torch_ext/rdna3_gather_ext_d0.so
```

Observed:

- `fused_global_sum_kernel` issues repeated `global_load_b32` in the consumer path.
- `fused_lds_sum_kernel` issues `global_load_b32` + `ds_store_b32` to create the tile, then `s_barrier`, then `ds_load_b32` in the consumer loop.
- Both fused kernels use LDS for the block-level float reduction.

Metadata from `llvm-readelf --notes`:

- `fused_global_sum_kernel`: `vgpr_count=23`, `sgpr_count=40`, spills 0, `wavefront_size=32`.
- `fused_lds_sum_kernel`: `vgpr_count=20`, `sgpr_count=37`, spills 0, `wavefront_size=32`.
- `dot_global_kernel`: `vgpr_count=20`, `sgpr_count=40`, spills 0, `wavefront_size=32`.
- `dot_lds_kernel`: `vgpr_count=20`, `sgpr_count=41`, spills 0, `wavefront_size=32`.
- `graph_global_kernel`: `vgpr_count=19`, `sgpr_count=42`, spills 0, `wavefront_size=32`.
- `graph_lds_kernel`: `vgpr_count=22`, `sgpr_count=42`, spills 0, `wavefront_size=32`.
- `graph_lds_chunked_kernel`: `vgpr_count=22`, `sgpr_count=46`, spills 0, `wavefront_size=32`.

For the formal tile, `fused_lds` dynamic LDS is 16 KiB for the tile plus 1 KiB for the reduction scratch.

For the formal tile, `dot_lds` dynamic LDS is 16 KiB for the gathered tile.

For the formal tile, `graph_lds` dynamic LDS is 16 KiB for the gathered tile plus 1 KiB for reduction scratch.

For the formal tile, `graph_lds_chunked` uses the same 17 KiB dynamic LDS as `graph_lds`.

## Dot-Product Consumer

The dot consumer computes `output[task, query, token] = dot(query[task, query], gathered_feature[task, token])`.

Formal shape:

- `rows=4096`
- `tasks=32`
- `tile_tokens=128`
- `dim=64`
- `warmup=10`
- `iters=100`
- `pattern=random`

All results matched `dot_global` exactly (`max_abs_diff_vs_dot_global=0`).

### fp16 / random

| num_queries | dot_global ms | dot_lds ms | LDS speedup |
| ---: | ---: | ---: | ---: |
| 1 | 0.012495 | 0.015316 | 0.82x |
| 2 | 0.011048 | 0.014047 | 0.79x |
| 4 | 0.018193 | 0.020529 | 0.89x |
| 8 | 0.033616 | 0.035046 | 0.96x |
| 16 | 0.060136 | 0.059571 | 1.01x |
| 32 | 0.120625 | 0.115271 | 1.05x |

### bf16 / random

| num_queries | dot_global ms | dot_lds ms | LDS speedup |
| ---: | ---: | ---: | ---: |
| 1 | 0.006793 | 0.009766 | 0.70x |
| 4 | 0.011291 | 0.014965 | 0.75x |
| 16 | 0.028643 | 0.032468 | 0.88x |
| 32 | 0.050022 | 0.054371 | 0.92x |

### Dot Consumer Interpretation

This is a more realistic result than the repeated-sum proxy. The standalone LDS copy is still not useful, and the decode-like dot consumer only amortizes LDS staging under high fp16 query reuse. For bf16 at this tile size, the global path remains faster, likely because the dot work and query reads dominate enough that cached global feature rereads are not the limiting cost.

The practical route is not to force LDS for every decode-style dot. It should be gated on measured reuse and dtype:

- fp16 may justify LDS staging when the same gathered tile feeds roughly 16+ query vectors or a heavier fused consumer;
- bf16 does not justify LDS staging for this simple dot consumer at `dim=64`;
- graph-style aggregation with multiple transforms may still be a better fit because each transform can reuse the entire neighbor tile.

## Graph Multi-Transform Consumer

The graph consumer computes:

```text
output[task, transform] =
  sum_{neighbor in tile} dot(features[indices[task, neighbor]], transforms[transform])
```

`graph_global` launches one block per `(task, transform)`. `graph_lds` launches one block per task, gathers the neighbor tile once, then consumes all transforms from LDS inside that block. That mapping intentionally tests LDS reuse, but it also exposes an occupancy risk when `tasks` is small.

All graph results matched `graph_global` exactly (`max_abs_diff_vs_graph_global=0`).

### fp16 / random / tasks=32

| num_transforms | graph_global ms | graph_lds ms | LDS speedup |
| ---: | ---: | ---: | ---: |
| 1 | 0.012165 | 0.013194 | 0.92x |
| 2 | 0.011138 | 0.015876 | 0.70x |
| 4 | 0.013593 | 0.026051 | 0.52x |
| 8 | 0.016876 | 0.043067 | 0.39x |
| 16 | 0.022519 | 0.076212 | 0.30x |
| 32 | 0.038687 | 0.147796 | 0.26x |

### bf16 / random / tasks=32

| num_transforms | graph_global ms | graph_lds ms | LDS speedup |
| ---: | ---: | ---: | ---: |
| 1 | 0.010476 | 0.011465 | 0.91x |
| 4 | 0.011780 | 0.019143 | 0.62x |
| 16 | 0.019297 | 0.050042 | 0.39x |
| 32 | 0.028611 | 0.093433 | 0.31x |

At the original formal `tasks=32`, `graph_lds` loses badly as `num_transforms` grows. This does not mean LDS reuse is intrinsically bad. It means this one-block-per-task mapping has too little grid-level parallelism, while `graph_global` gets `tasks * num_transforms` blocks.

### Parallelism Check / random / tasks=256

| dtype | num_transforms | graph_global ms | graph_lds ms | LDS speedup |
| --- | ---: | ---: | ---: | ---: |
| fp16 | 8 | 0.076883 | 0.066962 | 1.15x |
| fp16 | 32 | 0.287242 | 0.256677 | 1.12x |
| bf16 | 8 | 0.056618 | 0.041154 | 1.38x |
| bf16 | 32 | 0.202803 | 0.141045 | 1.44x |

With enough tasks to populate the GPU, the same LDS design becomes profitable. The current evidence says graph-style LDS densification is viable only when the scheduler provides enough independent task blocks or when the kernel mapping keeps transform parallelism without duplicating too much gather work.

## Chunked Graph LDS Mapping

`graph_lds_chunked` launches one block per `(task, transform_chunk)`. It gathers the neighbor tile once per chunk and computes only that chunk of transforms. This duplicates gather work compared with `graph_lds`, but restores grid-level parallelism for small `tasks`.

All chunked results matched `graph_global` exactly (`max_abs_diff_vs_graph_global=0`).

### fp16 / random / tasks=32

| num_transforms | chunk | graph_global ms | graph_lds ms | graph_lds_chunked ms | chunked speedup vs global |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 8 | 4 | 0.016962 | 0.043267 | 0.027673 | 0.61x |
| 8 | 8 | 0.016855 | 0.043039 | 0.043197 | 0.39x |
| 16 | 4 | 0.022506 | 0.075725 | 0.027702 | 0.81x |
| 16 | 8 | 0.024023 | 0.077331 | 0.045608 | 0.53x |
| 32 | 2 | 0.039025 | 0.148371 | 0.037400 | 1.04x |
| 32 | 4 | 0.038846 | 0.147838 | 0.036119 | 1.08x |
| 32 | 8 | 0.038820 | 0.148193 | 0.047154 | 0.82x |

### bf16 / random / tasks=32

| num_transforms | chunk | graph_global ms | graph_lds ms | graph_lds_chunked ms | chunked speedup vs global |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 8 | 4 | 0.013941 | 0.029591 | 0.020165 | 0.69x |
| 8 | 8 | 0.013918 | 0.029436 | 0.029648 | 0.47x |
| 16 | 4 | 0.019291 | 0.050012 | 0.021297 | 0.91x |
| 16 | 8 | 0.019291 | 0.050356 | 0.030780 | 0.63x |
| 32 | 2 | 0.028820 | 0.093629 | 0.026692 | 1.08x |
| 32 | 4 | 0.029026 | 0.093262 | 0.024338 | 1.19x |
| 32 | 8 | 0.028618 | 0.093388 | 0.031488 | 0.91x |

For the small-task case, chunking fixes most of the original `graph_lds` failure. A chunk size of 4 is the best point in this sweep. Chunk size 8 leaves too little parallelism when `tasks=32`, while chunk size 2 duplicates more gather work and is only competitive at high transform count.

### Parallelism Check / random / tasks=256 / num_transforms=32 / chunk=4

| dtype | graph_global ms | graph_lds ms | graph_lds_chunked ms | chunked speedup vs global | chunked speedup vs graph_lds |
| --- | ---: | ---: | ---: | ---: | ---: |
| fp16 | 0.287580 | 0.261445 | 0.233860 | 1.23x | 1.12x |
| bf16 | 0.205550 | 0.143594 | 0.155138 | 1.33x | 0.93x |

At high task count, chunked is still good for fp16, but bf16 prefers the original one-block-per-task `graph_lds`. That suggests chunk size should be selected from runtime shape: smaller chunks for low task count, larger chunks or original `graph_lds` for already-saturated grids.

### Graph Profiler Check

Representative rocprof run:

```bash
rocprof --stats -o experiments/rdna3_gather/prof/graph_tasks256_t32_bf16.csv \
  python experiments/rdna3_gather/test_gather.py --mode graph --variant all \
  --dtype bf16 --rows 4096 --tasks 256 --tile-tokens 128 --dim 64 \
  --num-transforms 32 --warmup 5 --iters 20 --pattern random
```

`rocprofv3` failed during PyTorch extension loading with `Configuration request occurred outside of valid rocprofiler configuration period`, so this pass used legacy `rocprof --stats`.

Profiler stats:

| kernel | calls | avg ns |
| --- | ---: | ---: |
| `graph_global_kernel` | 26 | 194367 |
| `graph_lds_kernel` | 25 | 128226 |

The dispatch CSV reports `graph_lds_kernel` with 17,408 bytes LDS (`16 KiB` tile + `1 KiB` reduction), scratch 0, wave size 32.

## Decision

LDS densification is not useful as a standalone copy path. In the synthetic repeated-sum proxy it becomes profitable once the consumer reuses the tile at least twice.

The dot-product replacement is implemented. It shows that realistic dot-product reuse is less favorable than the synthetic repeated-sum proxy: LDS becomes competitive only at high fp16 reuse and does not currently win for bf16.

The graph multi-transform replacement is implemented. The key result is conditional: original `graph_lds` wins once task-level parallelism is sufficient, but loses badly for small `tasks` when transforms are serialized inside each task block.

The chunked mapping is now implemented and is the best current route for decode-sized batches. For `tasks=32, num_transforms=32`, `graph_lds_chunked` with chunk 4 beats both `graph_global` and original `graph_lds` for fp16 and bf16. The next engineering step is shape-based dispatch: use chunked LDS for low task count and high transform reuse, and use original `graph_lds` or global for already-saturated grids depending on dtype.

## Shape-Based Dispatch

`graph_auto` is implemented in the C++ extension, not only in the Python harness. The first policy used original `graph_lds` too aggressively and the sweep showed losses around `tasks=128`. The updated policy is:

```text
if tasks < 128:
  if dtype == bf16 and num_transforms >= 32:
    use graph_lds_chunked(chunk=4)
  elif dtype == bf16 and num_transforms >= 16:
    use graph_lds_chunked(chunk=2)
  elif dtype == fp16 and num_transforms >= 64:
    use graph_lds_chunked(chunk=2)
  else:
    use graph_global
else:
  if num_transforms >= 32:
    use graph_lds_chunked(chunk=8)
  elif num_transforms >= 16:
    use graph_lds_chunked(chunk=8 for tasks>=256, otherwise chunk=4)
  elif num_transforms >= 8:
    use graph_lds_chunked(chunk=8 for bf16/tasks>=256, otherwise chunk=4)
  else:
    use graph_global
```

Validation runs:

| dtype | tasks | num_transforms | selected policy | graph_auto ms | max_abs_diff_vs_graph_global |
| --- | ---: | ---: | --- | ---: | ---: |
| fp16 | 32 | 32 | `graph_lds_chunked(chunk=4)` | 0.038105 | 0 |
| bf16 | 32 | 32 | `graph_lds_chunked(chunk=4)` | 0.025996 | 0 |
| fp16 | 256 | 32 | `graph_lds_chunked(chunk=4)` | 0.223852 | 0 |
| bf16 | 256 | 32 | `graph_lds` | 0.138520 | 0 |
| fp16 | 32 | 8 | `graph_global` | 0.015396 | 0 |
| bf16 | 256 | 8 | `graph_lds` | 0.039201 | 0 |

This is a policy layer, not a final autotuner. The thresholds should stay visible because they are empirical for `tile_tokens=128`, `dim=64`, gfx1100, ROCm 7.2.0. The next refinement is to either sweep thresholds across more `tile_tokens/dim` shapes or make the policy table data-driven.

### Policy Sweep

The policy sweep script compares `graph_auto` with `graph_global`, original `graph_lds`, and chunked LDS with chunk sizes 2/4/8:

```bash
python experiments/rdna3_gather/sweep_graph_auto.py --warmup 5 --iters 50
```

The first sweep wrote:

```text
experiments/rdna3_gather/prof/graph_auto_policy_sweep.csv
```

That sweep found the first policy was not reliable around `tasks=128`: it picked `graph_lds`, while chunked LDS was the best candidate. The updated policy above is based on that sweep, and should be re-swept after any kernel change.

One nuance from long-iteration retesting: for `fp16, tasks=32, num_transforms=32`, concrete chunked LDS is only slightly faster than global, and the `graph_auto` wrapper overhead can erase that gain. The low-task fp16 auto threshold is therefore raised to `num_transforms>=64`. At `fp16, tasks=32, num_transforms=64`, `graph_auto` measured 0.072355 ms versus 0.076597 ms for `graph_global`, about 1.06x.

Final sweep after the policy update wrote:

```text
experiments/rdna3_gather/prof/graph_auto_policy_sweep_v4.csv
```

Summary of `graph_auto` speedup versus `graph_global`:

| dtype | tasks | transforms=8 | transforms=16 | transforms=32 |
| --- | ---: | ---: | ---: | ---: |
| fp16 | 32 | 1.014x | 0.979x | 0.961x |
| fp16 | 128 | 1.049x | 1.115x | 1.179x |
| fp16 | 256 | 1.143x | 1.174x | 1.285x |
| bf16 | 32 | 1.061x | 1.041x | 1.140x |
| bf16 | 128 | 1.161x | 1.258x | 1.426x |
| bf16 | 256 | 1.371x | 1.429x | 1.493x |

Current benefit assessment:

- bf16 has clear benefit across the swept graph aggregation shapes.
- fp16 has clear benefit once `tasks>=128`; low-task fp16 remains too small/noisy for a strong auto-dispatch claim.
- The current policy is useful for the graph multi-transform experiment, but it is not yet a general RDNA3 sparse-gather autotuner.

## Dim/Tile Extended Policy Table

The policy sweep was expanded beyond fixed `tile_tokens=128, dim=64` to cover:

```text
dtype: fp16, bf16
tasks: 32, 128, 256
tile_tokens: 64, 128, 256
dim: 32, 64, 128
num_transforms: 8, 16, 32
patterns: random, contiguous, page-cross, tail-negative
seeds: 0, 1, 2
```

The current policy table is generated from per-shape median timings across the
four access patterns and three seeds. Raw rows keep each individual
`(shape,pattern,seed)` measurement; median rows collapse them back to the
runtime-visible dispatch key `(dtype,tasks,tile_tokens,dim,num_transforms)`.

Unbiased median policy command:

```bash
python experiments/rdna3_gather/sweep_graph_auto.py \
  --quiet --warmup 2 --iters 10 \
  --output experiments/rdna3_gather/prof/graph_auto_policy_sweep_realistic_raw.csv \
  --aggregate-output experiments/rdna3_gather/prof/graph_auto_policy_sweep_realistic_median.csv \
  --policy-output experiments/rdna3_gather/prof/graph_auto_policy_table.csv
```

This writes an exact-match dispatch table with columns:

```text
dtype,tasks,tile_tokens,dim,num_transforms,variant,chunk_size
```

The table generator uses a conservative margin guard by default:
`--policy-min-speedup-vs-global=1.02`. If the fastest LDS/chunked candidate
does not beat `graph_global` by at least that factor, the emitted policy row is
`graph_global`. This matters because several low-reuse shapes differ by less
than short-run timing noise.

`graph_auto` loads that table from `RDNA3_GATHER_GRAPH_POLICY`; the Python
harness also exposes `--policy-table` and defaults to
`prof/graph_auto_policy_table.csv` when present. Table entries that select
`graph_lds` or `graph_lds_chunked` are still guarded by the dynamic LDS size
check, so oversized shapes fall back to `graph_global`.

Table-driven validation command:

```bash
python experiments/rdna3_gather/sweep_graph_auto.py \
  --quiet --warmup 2 --iters 10 \
  --output experiments/rdna3_gather/prof/graph_auto_policy_sweep_realistic_table_hash_raw.csv \
  --aggregate-output experiments/rdna3_gather/prof/graph_auto_policy_sweep_realistic_table_hash_median.csv \
  --policy-output experiments/rdna3_gather/prof/graph_auto_policy_table_from_hash_table_run.csv \
  --policy-table-for-auto experiments/rdna3_gather/prof/graph_auto_policy_table.csv
```

Summary versus the built-in heuristic on the same 162-shape median grid:

| policy | cases | mean speedup vs global | min speedup vs global | mean auto/best | min auto/best | cases below 95% of best |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| built-in heuristic | 162 | 1.078x | 0.718x | 0.964 | 0.718 | 29 |
| median table-driven | 162 | 1.112x | 0.909x | 0.997 | 0.909 | 6 |

Current conclusion: the LDS/chunked path still has real benefit, but only for
the right shapes. Expanding the sweep exposed several large `tile_tokens/dim`
cases where global is the correct choice. Exact-match table dispatch is now the
more reliable route than adding more hard-coded thresholds.

The active generated median table has 162 rows: 72 `graph_global`, 3
`graph_lds`, and 87 `graph_lds_chunked`. The C++ table lookup now uses an
`unordered_map` rather than a linear scan; on the realistic validation sweep
this improved the raw worst-case table-driven point from 0.650x to 0.873x
versus global. The six median cases below 95% of best all select
`graph_global` and have `best=global`, so they are residual short-kernel timing
noise/wrapper overhead rather than LDS/chunked mis-dispatches.
