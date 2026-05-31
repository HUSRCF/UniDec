#!/usr/bin/env python3
import argparse
import os
from pathlib import Path
from typing import Callable, Dict, Iterable, Tuple

import torch
from torch.utils.cpp_extension import load


THIS_DIR = Path(__file__).resolve().parent
REPO_ROOT = THIS_DIR.parents[1]
CK_INCLUDE = (
    REPO_ROOT
    / "flash-attention-fa4-v4.0.0.beta4_20260319c18_baseline"
    / "csrc"
    / "composable_kernel"
    / "include"
)


def build_extension(args):
    build_dir = THIS_DIR / ".torch_ext"
    build_dir.mkdir(parents=True, exist_ok=True)

    arch = os.environ.get("RDNA3_GATHER_GPU_ARCH", "gfx1100")
    enable_direct = args.enable_direct or os.environ.get("RDNA3_GATHER_ENABLE_DIRECT_LDS") == "1"
    os.environ.setdefault("PYTORCH_ROCM_ARCH", arch)

    extra_cuda_cflags = [
        "-O3",
        "-std=c++17",
        f"--offload-arch={arch}",
        f"-DRDNA3_GATHER_ENABLE_DIRECT_LDS={int(enable_direct)}",
    ]

    return load(
        name=f"rdna3_gather_ext_d{int(enable_direct)}",
        sources=[str(THIS_DIR / "rdna3_gather_kernels.hip")],
        extra_include_paths=[str(CK_INCLUDE)] if enable_direct else [],
        extra_cflags=["-O3", "-std=c++17"],
        extra_cuda_cflags=extra_cuda_cflags,
        build_directory=str(build_dir),
        verbose=True,
    )


def make_indices(args) -> torch.Tensor:
    device = torch.device("cuda")
    if args.pattern == "random":
        return torch.randint(
            0, args.rows, (args.tasks, args.tile_tokens), device=device, dtype=torch.int32
        )

    if args.pattern == "contiguous":
        base = (
            torch.arange(args.tasks, device=device, dtype=torch.int64) * args.tile_tokens
        ) % max(1, args.rows - args.tile_tokens + 1)
        offs = torch.arange(args.tile_tokens, device=device, dtype=torch.int64)
        return (base[:, None] + offs[None, :]).to(torch.int32)

    if args.pattern == "page-cross":
        page = max(2, args.page_size)
        starts = (
            torch.arange(args.tasks, device=device, dtype=torch.int64) * page + page - 8
        ) % args.rows
        offs = torch.arange(args.tile_tokens, device=device, dtype=torch.int64)
        return ((starts[:, None] + offs[None, :]) % args.rows).to(torch.int32)

    if args.pattern == "tail-negative":
        idx = torch.randint(
            0, args.rows, (args.tasks, args.tile_tokens), device=device, dtype=torch.int32
        )
        tail = max(1, args.tile_tokens // 4)
        idx[-1, -tail:] = -1
        return idx

    raise ValueError(f"unknown pattern: {args.pattern}")


def reference(features: torch.Tensor, indices: torch.Tensor) -> torch.Tensor:
    valid = (indices >= 0) & (indices < features.shape[0])
    safe = indices.clamp_min(0).clamp_max(features.shape[0] - 1).long()
    gathered = features[safe]
    return torch.where(valid[..., None], gathered, torch.zeros_like(gathered))


def max_abs_diff(a: torch.Tensor, b: torch.Tensor) -> float:
    if a.numel() == 0:
        return 0.0
    return (a.float() - b.float()).abs().max().item()


def time_variant(fn: Callable[[], torch.Tensor], warmup: int, iters: int) -> Tuple[torch.Tensor, float]:
    for _ in range(warmup):
        out = fn()
    torch.cuda.synchronize()

    start = torch.cuda.Event(enable_timing=True)
    end = torch.cuda.Event(enable_timing=True)
    start.record()
    for _ in range(iters):
        out = fn()
    end.record()
    torch.cuda.synchronize()
    return out, start.elapsed_time(end) / iters


def fused_reference(features: torch.Tensor, indices: torch.Tensor, consumer_passes: int) -> torch.Tensor:
    scale = consumer_passes * (consumer_passes + 1) / 2
    return reference(features, indices).float().sum(dim=(1, 2)) * scale


def dot_reference(features: torch.Tensor, indices: torch.Tensor, queries: torch.Tensor) -> torch.Tensor:
    gathered = reference(features, indices).float()
    return torch.einsum("btd,bqd->bqt", gathered, queries.float())


def graph_reference(
    features: torch.Tensor, indices: torch.Tensor, transforms: torch.Tensor
) -> torch.Tensor:
    gathered = reference(features, indices).float()
    return torch.einsum("btd,md->bm", gathered, transforms.float())


def selected_variants(name: str, mode: str) -> Iterable[str]:
    if name == "all":
        if mode == "gather":
            return ("baseline", "vgpr_lds", "direct_lds")
        if mode == "dot":
            return ("dot_global", "dot_lds")
        if mode == "graph":
            return ("graph_global", "graph_lds", "graph_lds_chunked", "graph_auto")
        return ("fused_global", "fused_lds")
    if name == "phase3":
        return (
            "graph_persistent_global",
            "graph_persistent_lds",
            "graph_persistent_lds_chunked",
            "graph_persistent_auto",
        )
    return (name,)


def run(args) -> None:
    if not torch.cuda.is_available():
        raise RuntimeError("CUDA/HIP device is not available to PyTorch")

    if args.policy_table is not None:
        policy_table = Path(args.policy_table)
        if policy_table.exists():
            os.environ["RDNA3_GATHER_GRAPH_POLICY"] = str(policy_table)

    ext = build_extension(args)
    print(f"direct_lds_compiled={ext.direct_lds_compiled()}")

    if args.build_only:
        return

    dtype = {"fp16": torch.float16, "bf16": torch.bfloat16}[args.dtype]
    torch.manual_seed(args.seed)
    features = torch.randn(args.rows, args.dim, device="cuda", dtype=dtype)
    indices = make_indices(args)

    if args.mode == "gather":
        ref = reference(features, indices)
        funcs: Dict[str, Callable[[], torch.Tensor]] = {
            "baseline": lambda: ext.gather_baseline(features, indices),
            "vgpr_lds": lambda: ext.gather_vgpr_lds(features, indices),
            "direct_lds": lambda: ext.gather_direct_lds(features, indices),
        }

        moved_bytes = (
            ref.numel() * ref.element_size() * 2
            + indices.numel() * indices.element_size()
        )

        print(
            "variant, dtype, rows, tasks, tile_tokens, dim, pattern, ms, effective_GBps, max_abs_diff"
        )
        for variant in selected_variants(args.variant, args.mode):
            if variant not in funcs:
                raise ValueError(f"{variant} is not a gather variant")
            out, ms = time_variant(funcs[variant], args.warmup, args.iters)
            diff = max_abs_diff(out, ref)
            gbps = moved_bytes / (ms * 1.0e-3) / 1.0e9
            print(
                f"{variant}, {args.dtype}, {args.rows}, {args.tasks}, "
                f"{args.tile_tokens}, {args.dim}, {args.pattern}, "
                f"{ms:.6f}, {gbps:.3f}, {diff:.6g}"
            )
            if diff != 0.0:
                raise AssertionError(f"{variant} mismatch: max_abs_diff={diff}")
        return

    if args.mode == "dot":
        queries = torch.randn(args.tasks, args.num_queries, args.dim, device="cuda", dtype=dtype)
        ref = dot_reference(features, indices, queries)
        funcs = {
            "dot_global": lambda: ext.dot_global(features, indices, queries),
            "dot_lds": lambda: ext.dot_lds(features, indices, queries),
        }
        global_ref = funcs["dot_global"]()
        torch.cuda.synchronize()

        logical_bytes = (
            args.tasks
            * args.num_queries
            * args.tile_tokens
            * (args.dim * features.element_size() * 2 + indices.element_size() + 4)
        )

        print(
            "variant, dtype, rows, tasks, tile_tokens, dim, pattern, num_queries, "
            "ms, logical_GBps, max_abs_diff_vs_ref, max_abs_diff_vs_dot_global"
        )
        for variant in selected_variants(args.variant, args.mode):
            if variant not in funcs:
                raise ValueError(f"{variant} is not a dot variant")
            out, ms = time_variant(funcs[variant], args.warmup, args.iters)
            diff_ref = max_abs_diff(out, ref)
            diff_global = max_abs_diff(out, global_ref)
            gbps = logical_bytes / (ms * 1.0e-3) / 1.0e9
            print(
                f"{variant}, {args.dtype}, {args.rows}, {args.tasks}, "
                f"{args.tile_tokens}, {args.dim}, {args.pattern}, {args.num_queries}, "
                f"{ms:.6f}, {gbps:.3f}, {diff_ref:.6g}, {diff_global:.6g}"
            )
            if diff_global > args.tolerance:
                raise AssertionError(
                    f"{variant} mismatch vs dot_global: max_abs_diff={diff_global}"
                )
            if diff_ref > args.ref_tolerance:
                raise AssertionError(
                    f"{variant} mismatch vs PyTorch reference: max_abs_diff={diff_ref}"
            )
        return

    if args.mode == "graph":
        transforms = torch.randn(args.num_transforms, args.dim, device="cuda", dtype=dtype)
        ref = graph_reference(features, indices, transforms)
        funcs = {
            "graph_global": lambda: ext.graph_global(features, indices, transforms),
            "graph_lds": lambda: ext.graph_lds(features, indices, transforms),
            "graph_lds_chunked": lambda: ext.graph_lds_chunked(
                features, indices, transforms, args.transform_chunk_size
            ),
            "graph_auto": lambda: ext.graph_auto(features, indices, transforms),
            "graph_persistent_global": lambda: ext.graph_persistent_global(
                features, indices, transforms, args.persistent_blocks, args.ticket_batch_size
            ),
            "graph_persistent_lds": lambda: ext.graph_persistent_lds(
                features, indices, transforms, args.persistent_blocks, args.ticket_batch_size
            ),
            "graph_persistent_lds_chunked": lambda: ext.graph_persistent_lds_chunked(
                features,
                indices,
                transforms,
                args.transform_chunk_size,
                args.persistent_blocks,
                args.ticket_batch_size,
            ),
            "graph_persistent_auto": lambda: ext.graph_persistent_auto(
                features, indices, transforms, args.persistent_blocks, args.ticket_batch_size
            ),
        }
        global_ref = funcs["graph_global"]()
        torch.cuda.synchronize()
        auto_policy = ext.graph_auto_policy(features, indices, transforms)

        logical_bytes = (
            args.tasks
            * args.num_transforms
            * (
                args.tile_tokens
                * (args.dim * features.element_size() + indices.element_size())
                + args.dim * features.element_size()
                + 4
            )
        )

        print(
            "variant, dtype, rows, tasks, tile_tokens, dim, pattern, num_transforms, "
            "transform_chunk_size, persistent_blocks, ticket_batch_size, ms, "
            "logical_GBps, max_abs_diff_vs_ref, max_abs_diff_vs_graph_global"
        )
        print(f"graph_auto_policy={auto_policy}")
        for variant in selected_variants(args.variant, args.mode):
            if variant not in funcs:
                raise ValueError(f"{variant} is not a graph variant")
            out, ms = time_variant(funcs[variant], args.warmup, args.iters)
            diff_ref = max_abs_diff(out, ref)
            diff_global = max_abs_diff(out, global_ref)
            gbps = logical_bytes / (ms * 1.0e-3) / 1.0e9
            print(
                f"{variant}, {args.dtype}, {args.rows}, {args.tasks}, "
                f"{args.tile_tokens}, {args.dim}, {args.pattern}, {args.num_transforms}, "
                f"{args.transform_chunk_size}, {args.persistent_blocks}, "
                f"{args.ticket_batch_size}, "
                f"{ms:.6f}, {gbps:.3f}, {diff_ref:.6g}, {diff_global:.6g}"
            )
            if diff_global > args.tolerance:
                raise AssertionError(
                    f"{variant} mismatch vs graph_global: max_abs_diff={diff_global}"
                )
            if diff_ref > args.ref_tolerance:
                raise AssertionError(
                    f"{variant} mismatch vs PyTorch reference: max_abs_diff={diff_ref}"
                )
        return

    ref = fused_reference(features, indices, args.consumer_passes)
    funcs = {
        "fused_global": lambda: ext.fused_global_sum(features, indices, args.consumer_passes),
        "fused_lds": lambda: ext.fused_lds_sum(features, indices, args.consumer_passes),
    }
    global_ref = funcs["fused_global"]()
    torch.cuda.synchronize()

    logical_bytes = (
        (features.element_size() * args.tile_tokens * args.dim + args.tile_tokens * indices.element_size())
        * args.tasks
        * args.consumer_passes
        + args.tasks * 4
    )

    print(
        "variant, dtype, rows, tasks, tile_tokens, dim, pattern, consumer_passes, "
        "ms, logical_GBps, max_abs_diff_vs_ref, max_abs_diff_vs_fused_global"
    )
    for variant in selected_variants(args.variant, args.mode):
        if variant not in funcs:
            raise ValueError(f"{variant} is not a fused variant")
        out, ms = time_variant(funcs[variant], args.warmup, args.iters)
        diff_ref = max_abs_diff(out, ref)
        diff_global = max_abs_diff(out, global_ref)
        gbps = logical_bytes / (ms * 1.0e-3) / 1.0e9
        print(
            f"{variant}, {args.dtype}, {args.rows}, {args.tasks}, "
            f"{args.tile_tokens}, {args.dim}, {args.pattern}, {args.consumer_passes}, "
            f"{ms:.6f}, {gbps:.3f}, {diff_ref:.6g}, {diff_global:.6g}"
        )
        if diff_global > args.tolerance:
            raise AssertionError(
                f"{variant} mismatch vs fused_global: max_abs_diff={diff_global}"
            )
        if diff_ref > args.ref_tolerance:
            raise AssertionError(
                f"{variant} mismatch vs PyTorch reference: max_abs_diff={diff_ref}"
            )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="RDNA3 gather/densify Phase 1/2 harness")
    parser.add_argument("--mode", choices=["gather", "fused", "dot", "graph"], default="gather")
    parser.add_argument(
        "--variant",
        choices=[
            "all",
            "baseline",
            "vgpr_lds",
            "direct_lds",
            "fused_global",
            "fused_lds",
            "dot_global",
            "dot_lds",
            "graph_global",
            "graph_lds",
            "graph_lds_chunked",
            "graph_auto",
            "phase3",
            "graph_persistent_global",
            "graph_persistent_lds",
            "graph_persistent_lds_chunked",
            "graph_persistent_auto",
        ],
        default="all",
    )
    parser.add_argument("--dtype", choices=["fp16", "bf16"], default="fp16")
    parser.add_argument("--rows", type=int, default=4096)
    parser.add_argument("--tasks", type=int, default=32)
    parser.add_argument("--tile-tokens", type=int, default=128)
    parser.add_argument("--dim", type=int, default=64)
    parser.add_argument("--page-size", type=int, default=128)
    parser.add_argument(
        "--pattern",
        choices=["random", "contiguous", "page-cross", "tail-negative"],
        default="random",
    )
    parser.add_argument("--warmup", type=int, default=5)
    parser.add_argument("--iters", type=int, default=30)
    parser.add_argument("--seed", type=int, default=0)
    parser.add_argument(
        "--consumer-passes",
        type=int,
        default=4,
        help="number of repeated compute-consumer passes in Phase 2 fused mode",
    )
    parser.add_argument(
        "--num-queries",
        type=int,
        default=4,
        help="number of per-task query vectors in Phase 2 dot mode",
    )
    parser.add_argument(
        "--num-transforms",
        type=int,
        default=4,
        help="number of graph transform vectors in Phase 2 graph mode",
    )
    parser.add_argument(
        "--transform-chunk-size",
        type=int,
        default=4,
        help="number of transform vectors consumed per task block in graph_lds_chunked",
    )
    parser.add_argument(
        "--persistent-blocks",
        type=int,
        default=0,
        help="number of Phase 3 persistent workgroups; 0 uses the device multiprocessor count",
    )
    parser.add_argument(
        "--ticket-batch-size",
        type=int,
        default=1,
        help="number of logical graph tickets each persistent workgroup claims per atomicAdd",
    )
    parser.add_argument(
        "--policy-table",
        type=Path,
        default=THIS_DIR / "prof" / "graph_auto_policy_table.csv",
        help="optional graph_auto policy CSV; used when the file exists",
    )
    parser.add_argument(
        "--tolerance",
        type=float,
        default=1.0e-4,
        help="max_abs_diff tolerance against fused_global in Phase 2 fused mode",
    )
    parser.add_argument(
        "--ref-tolerance",
        type=float,
        default=2.0e-1,
        help="max_abs_diff tolerance against PyTorch reference in Phase 2 fused mode",
    )
    parser.add_argument("--build-only", action="store_true")
    parser.add_argument(
        "--enable-direct",
        action="store_true",
        help="compile the experimental direct-to-LDS inline-asm probe; may fail on gfx11",
    )
    return parser.parse_args()


if __name__ == "__main__":
    run(parse_args())
