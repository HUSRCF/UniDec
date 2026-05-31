# D256 CK Tile Progress

This snapshot contains the DK-only K^T LDS preload fix plus the D256 gfx11 tile
retune that avoids local memory overflow.

Key points:
- DK-only split path keeps the formal K^T LDS remap/preload structure without
  dummy DQ compute or asm sink.
- D256 gfx11 backward tile changed from `bn0=64, 4 warps` to `bn0=32, 2 warps`
  while preserving WMMA 16x16x16 legality and equal GEMM warp counts.
- Minimal D256 bf16 build passed, then probe passed 12/12 for causal both,
  seqlens 767,768,769,1024,1536,2048 on GPU0.
- Minimal D256 fp16 build passed, then probe passed 12/12 for causal both,
  seqlens 767,768,769,1024,1536,2048 on GPU0.

Important ISA rule:
- Gemm0/Gemm1/Gemm4 total NumWarps must match.
- Per-warp WMMA M/N tile must stay at least 16 on gfx11.
- Do not use probe failures as strong negative evidence when the probe itself
  changes scheduling/register pressure.
