# D256 Hybrid Fast Candidate

Date: 2026-05-20

Scope:
- gfx1100 / AMD Radeon PRO W7900
- CK Tile backward split path
- D256 fp16/bf16 minimal full matrix

Validated build preset:
- `scripts/build_ck_d256_hybrid_fast.sh`

Important compile choices:
- `CK_TILE_DEBUG_BWD_SPLIT_PARALLEL_STREAMS=2`
- `CK_TILE_DEBUG_BWD_SPLIT_DQ_INPLACE_DS=1`
- `CK_TILE_DEBUG_BWD_SPLIT_DQ_LATE_DO_D_PREFETCH=0`
- `CK_TILE_DEBUG_BWD_SPLIT_DQ_LATE_REG_LOAD=0`
- `CK_TILE_DEBUG_BWD_SPLIT_DKDV_USE_GENERIC_LDS_LAYOUT=1`
- `CK_TILE_DEBUG_BWD_SPLIT_DKDV_FRESH_P=1`
- `CK_TILE_USE_AMD_BUFFER_ATOMIC_ADD_FLOAT_ONLY=1`

Why this combination:
- Generic DKDV LDS lowers DK-only LDS footprint under split stream overlap.
- Late DQ scheduling is bad for D256. It increases DQ scratch and time.
- Inplace dS is safe for tested fp16 cases and lowers DQ resource pressure when combined with old-style DQ scheduling.
- `DQ_FIRST=1` was tested and did not improve end-to-end time.

Key precision result:
- `testoutput/d256_hybrid_fullmatrix_scale100_gpu0.csv`
- fp16 D256 S=1024/2048 causal and noncausal passed.
- bf16 strict absolute threshold still reports BAD, but relative error remained about 0.0056-0.0063, matching the prior D256 bf16 behavior rather than a new logic failure.

Path check:
- `testoutput/d256_hybrid_pathcheck` was run with `FLASH_ATTN_CK_LOG_LEVEL=1`.
- Active backward path:
  `dot_do_o @ split_dv @ split_dk @ split_dq @ convert_dq_parallel_streams`
- Active D256 split tile:
  `b16x32x256x16x256x16x32x256x256_r1x2x1_r2x1x1_r1x2x1_w16x16x16_w16x16x16`

Key performance result:
- fp16 D256 noncausal S1024: flash 6.620 ms, SDPA 4.291 ms.
- fp16 D256 causal S1024: flash 4.197 ms, SDPA 3.252 ms.
- fp16 D256 noncausal S2048: flash 25.693 ms, SDPA 16.420 ms.

Key rocprof result:
- `testoutput/rocprof_fp16_d256_hybrid_fullmatrix_flash_nc_s1024_gpu0/results_results.csv`
- split_dv: 2.7892 ms, LDS 32768, scratch 808
- split_dkdv_or_dk: 5.2907 ms, LDS 42496, scratch 1452
- split_dq: 5.2756 ms, LDS 34304, scratch 1904
- This improves over the previous generic+late DQ build where split_dq had scratch 2312 and time about 5.90 ms.

Do not overgeneralize:
- These flags are global compile flags in current `setup.py`; applying them to D64/D128 without separate validation may regress those paths.
- A real default implementation should make the D256 behavior Problem-aware inside the pipelines instead of relying on global `-D` flags.
Checkpoint:
- Saved as `/home/husrcf/Code/ProtBind/fa4/flash-attention-fa4-v4.0.0.beta4_20260319c13`.
