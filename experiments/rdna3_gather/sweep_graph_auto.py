#!/usr/bin/env python3
import argparse
import csv
import json
import os
import platform
import statistics
import subprocess
import sys
import time
from pathlib import Path
from types import SimpleNamespace
from typing import Callable, Dict, Iterable, List, Tuple

import torch

import test_gather as tg


THIS_DIR = Path(__file__).resolve().parent


def parse_int_list(values: Iterable[str]) -> Tuple[int, ...]:
    parsed = []
    for value in values:
        for piece in value.split(","):
            if piece:
                parsed.append(int(piece))
    return tuple(parsed)


def parse_str_list(values: Iterable[str]) -> Tuple[str, ...]:
    parsed = []
    for value in values:
        for piece in value.split(","):
            piece = piece.strip()
            if piece:
                parsed.append(piece)
    return tuple(parsed)


def make_case_args(
    args,
    dtype: str,
    tasks: int,
    tile_tokens: int,
    dim: int,
    num_transforms: int,
    pattern: str,
) -> SimpleNamespace:
    return SimpleNamespace(
        dtype=dtype,
        rows=args.rows,
        tasks=tasks,
        tile_tokens=tile_tokens,
        dim=dim,
        page_size=args.page_size,
        pattern=pattern,
        num_transforms=num_transforms,
        enable_direct=False,
    )


def time_case(fn: Callable[[], torch.Tensor], warmup: int, iters: int) -> Tuple[torch.Tensor, float]:
    return tg.time_variant(fn, warmup, iters)


def graph_lds_shared_fits(tile_tokens: int, dim: int) -> bool:
    tile_bytes = tile_tokens * dim * 2
    reduction_bytes = 256 * 4
    return tile_bytes + reduction_bytes <= 64 * 1024


def policy_row_from_best(
    row: Dict[str, object], min_speedup_vs_global: float
) -> Dict[str, object]:
    best_variant = str(row["best_variant"])
    best_speedup = float(row["best_speedup_vs_global"])
    use_global = best_variant == "global" or best_speedup < min_speedup_vs_global

    if use_global:
        variant = "graph_global"
        chunk_size = 0
    elif best_variant == "lds":
        variant = "graph_lds"
        chunk_size = 0
    elif best_variant.startswith("chunk"):
        variant = "graph_lds_chunked"
        chunk_size = int(best_variant.removeprefix("chunk"))
    else:
        raise ValueError(f"unsupported best variant: {best_variant}")

    return {
        "dtype": row["dtype"],
        "tasks": row["tasks"],
        "tile_tokens": row["tile_tokens"],
        "dim": row["dim"],
        "num_transforms": row["num_transforms"],
        "variant": variant,
        "chunk_size": chunk_size,
    }


def print_summary(rows) -> None:
    print_summary_with_label("summary", rows)


def print_summary_with_label(label: str, rows) -> None:
    if not rows:
        return

    min_auto_speedup = min(float(row["auto_speedup_vs_global"]) for row in rows)
    mean_auto_speedup = sum(float(row["auto_speedup_vs_global"]) for row in rows) / len(rows)
    min_auto_vs_best = min(float(row["auto_vs_best"]) for row in rows)
    mean_auto_vs_best = sum(float(row["auto_vs_best"]) for row in rows) / len(rows)
    slower_than_global = sum(float(row["auto_speedup_vs_global"]) < 0.99 for row in rows)
    far_from_best = sum(float(row["auto_vs_best"]) < 0.95 for row in rows)
    best_global = sum(str(row["best_variant"]) == "global" for row in rows)
    best_chunked = sum(str(row["best_variant"]).startswith("chunk") for row in rows)
    best_lds = sum(str(row["best_variant"]) == "lds" for row in rows)

    print(
        f"{label} "
        f"cases={len(rows)} "
        f"mean_auto_speedup={mean_auto_speedup:.3f} "
        f"min_auto_speedup={min_auto_speedup:.3f} "
        f"mean_auto_vs_best={mean_auto_vs_best:.3f} "
        f"min_auto_vs_best={min_auto_vs_best:.3f} "
        f"auto_slower_than_global_1pct={slower_than_global} "
        f"auto_below_best_95pct={far_from_best} "
        f"best_global={best_global} best_lds={best_lds} best_chunked={best_chunked}"
    )


def print_policy_summary(policy_rows, min_speedup_vs_global: float) -> None:
    if not policy_rows:
        return

    global_count = sum(row["variant"] == "graph_global" for row in policy_rows)
    lds_count = sum(row["variant"] == "graph_lds" for row in policy_rows)
    chunked_count = sum(row["variant"] == "graph_lds_chunked" for row in policy_rows)
    print(
        "policy_table "
        f"min_speedup_vs_global={min_speedup_vs_global:.3f} "
        f"rows={len(policy_rows)} "
        f"global={global_count} lds={lds_count} chunked={chunked_count}"
    )


def write_bad_cases(path: Path, rows, threshold: float) -> None:
    bad_rows = [row for row in rows if float(row["auto_vs_best"]) < threshold]
    fieldnames = list(rows[0].keys()) if rows else []
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(bad_rows)
    print(f"wrote {path} bad_cases={len(bad_rows)} threshold={threshold:.3f}")


def run_text_command(command):
    try:
        return subprocess.check_output(command, text=True, stderr=subprocess.STDOUT).strip()
    except Exception:
        return "unavailable"


def write_metadata(path: Path, args, raw_rows, aggregate_rows, policy_rows) -> None:
    device_index = torch.cuda.current_device()
    props = torch.cuda.get_device_properties(device_index)
    metadata = {
        "schema": "rdna3_gather_policy_table_v1",
        "created_unix_time": time.time(),
        "command": sys.argv,
        "python": sys.version,
        "platform": platform.platform(),
        "torch_version": torch.__version__,
        "torch_hip_version": getattr(torch.version, "hip", None),
        "gpu_name": torch.cuda.get_device_name(device_index),
        "gpu_gcn_arch": getattr(props, "gcnArchName", "unknown"),
        "gfx_target_env": os.environ.get("RDNA3_GATHER_GPU_ARCH", "gfx1100"),
        "rocm_hipcc_version": run_text_command(["/opt/rocm/bin/hipcc", "--version"]),
        "kernel_git_commit": run_text_command(["git", "rev-parse", "HEAD"]),
        "clock_profile": os.environ.get("RDNA3_GATHER_CLOCK_PROFILE", "not_captured"),
        "power_profile": os.environ.get("RDNA3_GATHER_POWER_PROFILE", "not_captured"),
        "rows": args.rows,
        "page_size": args.page_size,
        "dtypes": list(args.dtypes),
        "tasks_list": list(parse_int_list(args.tasks_list)),
        "tile_tokens_list": list(parse_int_list(args.tile_tokens_list)),
        "dims_list": list(parse_int_list(args.dims_list)),
        "num_transforms_list": list(parse_int_list(args.num_transforms_list)),
        "patterns_list": list((args.pattern,) if args.pattern is not None else parse_str_list(args.patterns_list)),
        "seeds_list": list((args.seed,) if args.seed is not None else parse_int_list(args.seeds_list)),
        "warmup": args.warmup,
        "iters": args.iters,
        "policy_min_speedup_vs_global": args.policy_min_speedup_vs_global,
        "bad_cases_threshold": args.bad_cases_threshold,
        "policy_table_for_auto": str(args.policy_table_for_auto) if args.policy_table_for_auto else None,
        "raw_rows": len(raw_rows),
        "aggregate_rows": len(aggregate_rows),
        "policy_rows": len(policy_rows),
        "policy_variant_counts": {
            "graph_global": sum(row["variant"] == "graph_global" for row in policy_rows),
            "graph_lds": sum(row["variant"] == "graph_lds" for row in policy_rows),
            "graph_lds_chunked": sum(row["variant"] == "graph_lds_chunked" for row in policy_rows),
        },
    }
    with path.open("w") as f:
        json.dump(metadata, f, indent=2, sort_keys=True)
    print(f"wrote {path}")


def run_case(
    ext,
    args,
    dtype_name: str,
    tasks: int,
    tile_tokens: int,
    dim: int,
    num_transforms: int,
    pattern: str,
    seed: int,
) -> Dict[str, object]:
    dtype = {"fp16": torch.float16, "bf16": torch.bfloat16}[dtype_name]
    case_args = make_case_args(args, dtype_name, tasks, tile_tokens, dim, num_transforms, pattern)
    lds_fits = graph_lds_shared_fits(tile_tokens, dim)

    torch.manual_seed(seed)
    features = torch.randn(args.rows, dim, device="cuda", dtype=dtype)
    indices = tg.make_indices(case_args)
    transforms = torch.randn(num_transforms, dim, device="cuda", dtype=dtype)

    funcs = {
        "global": lambda: ext.graph_global(features, indices, transforms),
        "auto": lambda: ext.graph_auto(features, indices, transforms),
    }
    if lds_fits:
        funcs.update(
            {
                "lds": lambda: ext.graph_lds(features, indices, transforms),
                "chunk2": lambda: ext.graph_lds_chunked(features, indices, transforms, 2),
                "chunk4": lambda: ext.graph_lds_chunked(features, indices, transforms, 4),
                "chunk8": lambda: ext.graph_lds_chunked(features, indices, transforms, 8),
            }
        )

    outputs: Dict[str, torch.Tensor] = {}
    timings: Dict[str, float] = {}
    for name, fn in funcs.items():
        outputs[name], timings[name] = time_case(fn, args.warmup, args.iters)

    global_out = outputs["global"]
    diffs = {name: tg.max_abs_diff(out, global_out) for name, out in outputs.items()}
    for name, diff in diffs.items():
        if diff > args.tolerance:
            raise AssertionError(
                f"{dtype_name} tasks={tasks} tile={tile_tokens} dim={dim} "
                f"transforms={num_transforms} pattern={pattern} seed={seed} "
                f"{name} mismatch vs global: {diff}"
            )

    candidates = {
        name: timings[name]
        for name in ("global", "lds", "chunk2", "chunk4", "chunk8")
        if name in timings
    }
    best_variant = min(candidates, key=candidates.get)
    best_ms = candidates[best_variant]
    global_ms = timings["global"]
    auto_ms = timings["auto"]
    policy = ext.graph_auto_policy(features, indices, transforms)

    return {
        "dtype": dtype_name,
        "tasks": tasks,
        "tile_tokens": tile_tokens,
        "dim": dim,
        "num_transforms": num_transforms,
        "pattern": pattern,
        "seed": seed,
        "lds_fits": int(lds_fits),
        "policy": policy,
        "best_variant": best_variant,
        "global_ms": global_ms,
        "lds_ms": timings.get("lds", ""),
        "chunk2_ms": timings.get("chunk2", ""),
        "chunk4_ms": timings.get("chunk4", ""),
        "chunk8_ms": timings.get("chunk8", ""),
        "auto_ms": auto_ms,
        "auto_speedup_vs_global": global_ms / auto_ms,
        "best_speedup_vs_global": global_ms / best_ms,
        "auto_vs_best": best_ms / auto_ms,
        "max_abs_diff_auto": diffs["auto"],
    }


def shape_key(row: Dict[str, object]) -> Tuple[object, ...]:
    return (
        row["dtype"],
        int(row["tasks"]),
        int(row["tile_tokens"]),
        int(row["dim"]),
        int(row["num_transforms"]),
    )


def median_latency(rows: List[Dict[str, object]], field: str):
    values = [float(row[field]) for row in rows if row[field] != ""]
    if not values:
        return ""
    return statistics.median(values)


def aggregate_shape_rows(rows: List[Dict[str, object]]) -> List[Dict[str, object]]:
    grouped: Dict[Tuple[object, ...], List[Dict[str, object]]] = {}
    for row in rows:
        grouped.setdefault(shape_key(row), []).append(row)

    aggregate_rows = []
    for key in sorted(grouped):
        group = grouped[key]
        first = group[0]
        global_ms = median_latency(group, "global_ms")
        auto_ms = median_latency(group, "auto_ms")
        lds_ms = median_latency(group, "lds_ms")
        chunk2_ms = median_latency(group, "chunk2_ms")
        chunk4_ms = median_latency(group, "chunk4_ms")
        chunk8_ms = median_latency(group, "chunk8_ms")
        candidate_ms = {
            "global": global_ms,
            "lds": lds_ms,
            "chunk2": chunk2_ms,
            "chunk4": chunk4_ms,
            "chunk8": chunk8_ms,
        }
        candidate_ms = {name: value for name, value in candidate_ms.items() if value != ""}
        best_variant = min(candidate_ms, key=lambda name: float(candidate_ms[name]))
        best_ms = float(candidate_ms[best_variant])
        global_ms_float = float(global_ms)
        auto_ms_float = float(auto_ms)

        aggregate_rows.append(
            {
                "dtype": first["dtype"],
                "tasks": first["tasks"],
                "tile_tokens": first["tile_tokens"],
                "dim": first["dim"],
                "num_transforms": first["num_transforms"],
                "samples": len(group),
                "patterns": ";".join(sorted({str(row["pattern"]) for row in group})),
                "seeds": ";".join(str(seed) for seed in sorted({int(row["seed"]) for row in group})),
                "lds_fits": first["lds_fits"],
                "policy": first["policy"],
                "best_variant": best_variant,
                "global_ms": global_ms_float,
                "lds_ms": lds_ms,
                "chunk2_ms": chunk2_ms,
                "chunk4_ms": chunk4_ms,
                "chunk8_ms": chunk8_ms,
                "auto_ms": auto_ms_float,
                "auto_speedup_vs_global": global_ms_float / auto_ms_float,
                "best_speedup_vs_global": global_ms_float / best_ms,
                "auto_vs_best": best_ms / auto_ms_float,
                "max_abs_diff_auto": max(float(row["max_abs_diff_auto"]) for row in group),
            }
        )

    return aggregate_rows


def main() -> None:
    parser = argparse.ArgumentParser(description="Sweep graph_auto policy quality")
    parser.add_argument("--dtypes", nargs="+", default=("fp16", "bf16"), choices=("fp16", "bf16"))
    parser.add_argument("--tasks-list", nargs="+", default=("32", "128", "256"))
    parser.add_argument("--num-transforms-list", nargs="+", default=("8", "16", "32"))
    parser.add_argument("--tile-tokens-list", nargs="+", default=("64", "128", "256"))
    parser.add_argument("--dims-list", nargs="+", default=("32", "64", "128"))
    parser.add_argument("--rows", type=int, default=4096)
    parser.add_argument("--page-size", type=int, default=128)
    parser.add_argument(
        "--patterns-list",
        nargs="+",
        default=("random", "contiguous", "page-cross", "tail-negative"),
        help="synthetic access distributions used to build median policy rows",
    )
    parser.add_argument(
        "--pattern",
        choices=["random", "contiguous", "page-cross", "tail-negative"],
        default=None,
        help="legacy shortcut for a single pattern; overrides --patterns-list",
    )
    parser.add_argument("--warmup", type=int, default=5)
    parser.add_argument("--iters", type=int, default=50)
    parser.add_argument("--quiet", action="store_true", help="suppress per-case progress lines")
    parser.add_argument("--seed", type=int, default=None, help="legacy shortcut for one seed")
    parser.add_argument("--seeds-list", nargs="+", default=("0", "1", "2"))
    parser.add_argument("--tolerance", type=float, default=1.0e-4)
    parser.add_argument(
        "--output",
        type=Path,
        default=THIS_DIR / "prof" / "graph_auto_policy_sweep.csv",
    )
    parser.add_argument(
        "--aggregate-output",
        type=Path,
        default=THIS_DIR / "prof" / "graph_auto_policy_median.csv",
    )
    parser.add_argument(
        "--bad-cases-output",
        type=Path,
        default=THIS_DIR / "prof" / "graph_auto_policy_bad_cases.csv",
    )
    parser.add_argument(
        "--metadata-output",
        type=Path,
        default=THIS_DIR / "prof" / "graph_auto_policy_table.meta.json",
    )
    parser.add_argument(
        "--policy-output",
        type=Path,
        default=THIS_DIR / "prof" / "graph_auto_policy_table.csv",
    )
    parser.add_argument(
        "--policy-table-for-auto",
        type=Path,
        default=None,
        help="optional existing table to use when timing graph_auto; unset by default for unbiased sweeps",
    )
    parser.add_argument(
        "--policy-min-speedup-vs-global",
        type=float,
        default=1.02,
        help="write graph_global unless the measured best candidate beats graph_global by this factor",
    )
    parser.add_argument(
        "--bad-cases-threshold",
        type=float,
        default=0.95,
        help="write median aggregate rows whose auto_vs_best falls below this threshold",
    )
    args = parser.parse_args()

    if not torch.cuda.is_available():
        raise RuntimeError("CUDA/HIP device is not available to PyTorch")

    if args.policy_table_for_auto is None:
        os.environ.pop("RDNA3_GATHER_GRAPH_POLICY", None)
    else:
        os.environ["RDNA3_GATHER_GRAPH_POLICY"] = str(args.policy_table_for_auto)

    build_args = SimpleNamespace(enable_direct=False)
    ext = tg.build_extension(build_args)

    tasks_list = parse_int_list(args.tasks_list)
    tile_tokens_list = parse_int_list(args.tile_tokens_list)
    dims_list = parse_int_list(args.dims_list)
    transforms_list = parse_int_list(args.num_transforms_list)
    patterns_list = (args.pattern,) if args.pattern is not None else parse_str_list(args.patterns_list)
    allowed_patterns = {"random", "contiguous", "page-cross", "tail-negative"}
    unknown_patterns = sorted(set(patterns_list) - allowed_patterns)
    if unknown_patterns:
        raise ValueError(f"unknown patterns: {unknown_patterns}")
    seeds_list = (args.seed,) if args.seed is not None else parse_int_list(args.seeds_list)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.aggregate_output.parent.mkdir(parents=True, exist_ok=True)
    args.bad_cases_output.parent.mkdir(parents=True, exist_ok=True)
    args.metadata_output.parent.mkdir(parents=True, exist_ok=True)
    args.policy_output.parent.mkdir(parents=True, exist_ok=True)

    rows = []
    for dtype in args.dtypes:
        for tasks in tasks_list:
            for tile_tokens in tile_tokens_list:
                for dim in dims_list:
                    for num_transforms in transforms_list:
                        for pattern in patterns_list:
                            for seed in seeds_list:
                                row = run_case(
                                    ext,
                                    args,
                                    dtype,
                                    tasks,
                                    tile_tokens,
                                    dim,
                                    num_transforms,
                                    pattern,
                                    seed,
                                )
                                rows.append(row)
                                if not args.quiet:
                                    print(
                                        f"{dtype} tasks={tasks} tile={tile_tokens} dim={dim} "
                                        f"transforms={num_transforms} pattern={pattern} seed={seed} "
                                        f"policy={row['policy']} best={row['best_variant']} "
                                        f"auto_speedup={row['auto_speedup_vs_global']:.3f} "
                                        f"auto_vs_best={row['auto_vs_best']:.3f}"
                                    )

    aggregate_rows = aggregate_shape_rows(rows)
    policy_rows = [
        policy_row_from_best(row, args.policy_min_speedup_vs_global)
        for row in aggregate_rows
    ]

    fieldnames = list(rows[0].keys()) if rows else []
    with args.output.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    print(f"wrote {args.output}")

    aggregate_fieldnames = list(aggregate_rows[0].keys()) if aggregate_rows else []
    with args.aggregate_output.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=aggregate_fieldnames)
        writer.writeheader()
        writer.writerows(aggregate_rows)
    print(f"wrote {args.aggregate_output}")
    write_bad_cases(args.bad_cases_output, aggregate_rows, args.bad_cases_threshold)

    policy_fieldnames = list(policy_rows[0].keys()) if policy_rows else []
    with args.policy_output.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=policy_fieldnames)
        writer.writeheader()
        writer.writerows(policy_rows)
    print(f"wrote {args.policy_output}")
    write_metadata(args.metadata_output, args, rows, aggregate_rows, policy_rows)
    print_summary_with_label("raw_summary", rows)
    print_summary_with_label("median_summary", aggregate_rows)
    print_policy_summary(policy_rows, args.policy_min_speedup_vs_global)


if __name__ == "__main__":
    main()
