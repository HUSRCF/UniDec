# RDNA3 Paged-KV Locality Technical Report

## Scope

This report summarizes the RDNA3/gfx11 gather and paged-KV replay experiments in
this directory. It is intentionally conservative: it separates measured results
from plausible microarchitectural explanations, and it avoids attributing gains
to a specific cache or TLB layer unless a counter or an isolated microbench
supports that claim.

The target machine used for the latest replay work is an AMD Radeon Pro W7900
class RDNA3 GPU. The strongest evidence comes from strict vLLM/AWQ decode traces
with real block tables, `kv_cache_layout.available=true`, and layout-scoped block
identity.

## Executive Summary

The current best-supported optimization is locality-aware row scheduling:
grouping replay rows by the first layout-scoped KV block page before launching
the paged-KV gather/attention proxy. On the strict vLLM trace, `first-page`
ordering reduced the full replay from about `544 ms` to about `341 ms` in the
two-kernel paged-full path, and the standalone replay showed the same direction.

The result does not prove that the win comes specifically from L2, MALL, TLB, or
any single hardware layer. The supported claim is narrower and stronger:
original row order has poor layout-scoped KV reuse distance, while `first-page`
ordering reduces reuse distance and unique pages per window enough to produce a
large measured speedup.

The current conclusion is not that RDNA3 has been fully optimized. It is that,
for the tested strict trace and replay kernels, the next useful work should move
from capacity/persistent/gate micro-tuning to system integration and broader
trace validation.

## Evidence Trail

### 1. Persistent Queue Was Not The Main Route

Phase 3 tested a finite persistent queue with workgroup-level atomic ticket
batching. It was correct and ISA-compatible, but it was not competitive on
uniform or predictable skewed graph workloads.

Key observations:

- Uniform graph sweep: persistent queue variants were around `0.17x-0.23x` of
  the single-launch `graph_auto` baseline.
- Increasing persistent blocks recovered some lost parallelism on skewed
  workloads, but static edge-chunk overdecomposition plus sorted dispatch
  remained stronger.
- The precise interpretation is resident WG/wave starvation plus atomic-ticket
  overhead in the tested configuration, not a general statement that hardware
  dispatch always beats software queues.

Persistent remains a fallback candidate for multi-hop or truly runtime-generated
work. It is not the default path for the current paged-KV replay.

### 2. Fixed-Grid Self-Culling Beat Host-Sized Exact Launches

Phase 3E/3F showed that keeping `work_size` on device and launching a fixed
capacity grid avoids host readback and exact-grid sizing. This is useful when
the active worklist is generated on GPU.

Supported claim:

- Fixed-grid self-culling is a good dispatch form for this replay family.
- Capacity overprovisioning has a visible tax, but moderate overprovisioning was
  stable in the tested synthetic graph sweeps.

Unsupported claim:

- This does not prove empty blocks are universally free. It only shows that the
  fixed-grid path was cheaper than the exact host-sized path in the tested
  workload and capacity ranges.

### 3. Capacity Classes Had Conditional Value

Early self-cull-only microbenchmarks showed little benefit from fine capacity
classes when per-row launch overhead dominated. After fused multi-row replay and
two-kernel full softmax/value reduce, capacity classes regained modest value in
some paths by reducing overlaunch and the range of work scanned.

Later row-ordering work became the larger lever. The current recommendation is
to keep capacity classes as a dispatch tool, but not to keep tuning them as the
main research axis.

### 4. Numeric Block IDs Were A False Reuse Signal

The strict trace analysis found:

| metric | value |
| --- | ---: |
| flattened rows | 114,820 |
| block references | 142,840 |
| unique raw numeric block IDs | 101 |
| unique layout-scoped block IDs | 10,180 |
| K block stride bytes | 2,162,688 |

Raw numeric `block_id` values alias across layers and KV-cache allocations. A
valid replay identity must be scoped by KV layout, currently at least:

```text
(k_data_ptr, v_data_ptr, layer, logical_block_id)
```

Add `kv_head` or a derived address component if the kernel ownership model makes
different KV heads point at distinct address ranges.

This namespace fix invalidated earlier "hot-page" style conclusions that were
based on raw block IDs. After scoping, real trace behavior was close to a
same-footprint random baseline until row ordering exposed locality.

### 5. Stride Probe Weakened The Strong TLB Hypothesis

The standalone stride probe tested 4KB, 64KB, 2MB, and 16MB stride streams over
1GB and 4GB footprints. The measured 2MB stride was not uniquely worse; in
several runs it was faster than 4KB or 16MB.

Supported claim:

- A large KV block stride is an address-locality issue worth tracking.
- The replay suffers from layout-scoped KV locality and reuse-distance effects.

Unsupported claim:

- The data does not support calling the 2MB stride direct proof of TLB collapse.
- Linux Transparent HugePages or VRAM page-size tuning should not be a main
  kernel/ISA optimization route without a separate system-level study.

### 6. First-Page Row Ordering Was The Strongest Lever

Phase 5 tested row-order policies on the layout-scoped strict trace:

| row order | standalone event ms | standalone speedup | paged-full event ms | paged-full speedup |
| --- | ---: | ---: | ---: | ---: |
| original | 541.053 | 1.000x | 544.302 | 1.000x |
| first-page | 337.523 | 1.603x | 341.293 | 1.595x |
| first-2-pages | 337.624 | 1.602x | 341.233 | 1.595x |
| lexicographic | 337.598 | 1.603x | 341.266 | 1.595x |
| prefix-hash-2 | 344.105 | 1.572x | 347.771 | 1.565x |

Reuse metrics explain why deeper sorting had little extra value on this trace:

| row order | adjacent LCP mean | reuse distance p50 | unique pages/window-128 p50 |
| --- | ---: | ---: | ---: |
| original | 0.000 | 1240.0 | 128.0 |
| first-page | 1.155 | 1.0 | 10.0 |
| lexicographic | 1.155 | 1.0 | 10.0 |

The supported claim is that `first-page` captures almost all observable reuse in
this strict trace. Deeper prefix or lexicographic sorting may still matter for a
different trace with longer shared block-table prefixes.

### 7. Scheduler And Restore Costs Did Not Eat The Gain

The standalone scheduler path measured row permutation, H2D row metadata update,
and optional restore. The preferred restore mode passes `row_indices` to the
kernel and writes output by original row id.

This is not physically zero cost. The cost is fused into the kernel's output
scatter and was not a bottleneck in the measured replay. Explicit unpermute was
about `0.06 ms` for the full `114,820 x 2 x 32` float output case.

Same-row-count E2E validation showed conditional value:

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

Therefore `first-page` should be conditional. It should not be forced when the
batch has little first-page reuse.

### 8. Simple Physical Remap Policies Did Not Open A New Upper Bound

Phase 7/8 tested replay-only virtual-to-physical remap policies:

- numeric superblock grouping;
- first-touch compact remap;
- an oracle-style access-order remap in standalone replay.

Initial 8,192-row result:

| remap policy | row order | kernel ms | scheduler ms | online E2E ms |
| --- | --- | ---: | ---: | ---: |
| first-touch-compact | original | 59.117 | 10.920 | 70.037 |
| first-touch-compact | first-page | 40.153 | 10.368 | 50.521 |
| first-touch-compact | auto-first-page | 39.987 | 10.325 | 50.312 |
| oracle-access-order | original | 58.871 | 14.847 | 73.718 |
| oracle-access-order | first-page | 40.108 | 14.583 | 54.690 |
| oracle-access-order | auto-first-page | 40.103 | 14.269 | 54.372 |

The oracle-style policy did not improve kernel time on this slice and added
scheduler work. This does not prove all allocator layouts are exhausted. It only
rules out these cheap replay remaps as immediate wins on this trace.

## Current Recommended Policy

Freeze the row-ordering gate for now:

```text
default:
  enable first-page when rows >= min_rows
  and first_page_unique / rows <= 0.50

aggressive:
  use threshold 0.75 when accepting small borderline wins
```

Keep auxiliary predictors available:

- window-128 unique first-page ratio;
- adjacent first-page hit ratio;
- adjacent shared-prefix length mean.

Always keep original-order fallback. The policy should be framed as a
locality-aware scheduling candidate, not as a universal replacement.

## Claims To Avoid

Do not write these as conclusions:

- "2MB stride proves TLB collapse."
- "The win is definitely MALL/L2/TLB."
- "Scatter restore is zero cost."
- "Oracle-access-order is the theoretical global optimum."
- "RDNA3 physical potential is exhausted."
- "16-token blocks create a 32B cache-line curse."

Use these instead:

- "The measured problem is layout-scoped KV block locality and reuse distance."
- "The hardware layer responsible for the win remains unresolved."
- "Row-index scatter writeback avoids a separate restore kernel and was not a
  bottleneck in this replay."
- "The tested oracle-style replay remap did not add kernel benefit."
- "The current trace and replay kernels are row-ordering limited under the
  tested remap policies."

## Remaining Work

1. Validate `first-page` and the auto gate on more trace mixes:
   high prefix reuse, low prefix reuse, mixed prompt lengths, small online
   batches, large online batches, and multi-layer/multi-KV-head mappings.
2. Design a vLLM integration prototype at the decode scheduler boundary.
3. If reliable sequence/request provenance is available, test allocator replay
   policies that are closer to production:
   `sequence_append` and `prefix_group_compact`.
4. Continue split-K/chunked full attention sweeps for low-reuse workloads where
   row ordering cannot manufacture reuse.
5. Keep software prefetch as a narrow microkernel experiment only after C++
   unrolled code shows no VGPR/scratch regression.

