#!/usr/bin/env python3
import argparse
import csv
import os
import statistics
from pathlib import Path
from types import SimpleNamespace
from typing import Iterable, Tuple

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


def make_case_args(args, tasks: int, tile_tokens: int, dim: int, pattern: str):
    return SimpleNamespace(
        rows=args.rows,
        tasks=tasks,
        tile_tokens=tile_tokens,
        dim=dim,
        page_size=args.page_size,
        pattern=pattern,
    )


def run_case(ext, args, dtype_name, tasks, tile_tokens, dim, num_transforms, pattern, seed):
    dtype = {"fp16": torch.float16, "bf16": torch.bfloat16}[dtype_name]
    case_args = make_case_args(args, tasks, tile_tokens, dim, pattern)

    torch.manual_seed(seed)
    features = torch.randn(args.rows, dim, device="cuda", dtype=dtype)
    indices = tg.make_indices(case_args)
    transforms = torch.randn(num_transforms, dim, device="cuda", dtype=dtype)

    policy = ext.graph_auto_policy(features, indices, transforms)
    baseline_out, baseline_ms = tg.time_variant(
        lambda: ext.graph_auto(features, indices, transforms), args.warmup, args.iters
    )

    rows = []
    for batch_size in args.ticket_batch_sizes:
        persistent_out, persistent_ms = tg.time_variant(
            lambda: ext.graph_persistent_auto(
                features,
                indices,
                transforms,
                args.persistent_blocks,
                batch_size,
            ),
            args.warmup,
            args.iters,
        )
        diff = tg.max_abs_diff(persistent_out, baseline_out)
        if diff > args.tolerance:
            raise AssertionError(
                f"persistent mismatch: dtype={dtype_name} tasks={tasks} tile={tile_tokens} "
                f"dim={dim} transforms={num_transforms} pattern={pattern} seed={seed} "
                f"batch={batch_size} diff={diff}"
            )

        rows.append(
            {
                "dtype": dtype_name,
                "tasks": tasks,
                "tile_tokens": tile_tokens,
                "dim": dim,
                "num_transforms": num_transforms,
                "pattern": pattern,
                "seed": seed,
                "policy": policy,
                "persistent_blocks": args.persistent_blocks,
                "ticket_batch_size": batch_size,
                "graph_auto_ms": baseline_ms,
                "graph_persistent_auto_ms": persistent_ms,
                "persistent_speedup_vs_auto": baseline_ms / persistent_ms,
                "max_abs_diff_vs_auto": diff,
            }
        )
    return rows


def print_summary(rows):
    if not rows:
        return
    by_batch = {}
    for row in rows:
        by_batch.setdefault(int(row["ticket_batch_size"]), []).append(
            float(row["persistent_speedup_vs_auto"])
        )
    for batch_size in sorted(by_batch):
        values = by_batch[batch_size]
        print(
            "summary "
            f"ticket_batch_size={batch_size} "
            f"cases={len(values)} "
            f"median_speedup={statistics.median(values):.3f} "
            f"mean_speedup={statistics.mean(values):.3f} "
            f"min_speedup={min(values):.3f}"
        )


def main():
    parser = argparse.ArgumentParser(description="Phase 3 finite persistent graph queue sweep")
    parser.add_argument("--dtypes", nargs="+", default=("fp16", "bf16"), choices=("fp16", "bf16"))
    parser.add_argument("--tasks-list", nargs="+", default=("32", "128", "256"))
    parser.add_argument("--tile-tokens-list", nargs="+", default=("64", "128", "256"))
    parser.add_argument("--dims-list", nargs="+", default=("32", "64", "128"))
    parser.add_argument("--num-transforms-list", nargs="+", default=("8", "16", "32"))
    parser.add_argument(
        "--patterns-list",
        nargs="+",
        default=("random", "contiguous", "page-cross", "tail-negative"),
    )
    parser.add_argument("--seeds-list", nargs="+", default=("0", "1", "2"))
    parser.add_argument("--ticket-batch-sizes", nargs="+", type=int, default=(1, 2, 4, 8))
    parser.add_argument("--persistent-blocks", type=int, default=0)
    parser.add_argument("--rows", type=int, default=4096)
    parser.add_argument("--page-size", type=int, default=128)
    parser.add_argument("--warmup", type=int, default=3)
    parser.add_argument("--iters", type=int, default=20)
    parser.add_argument("--tolerance", type=float, default=1.0e-4)
    parser.add_argument(
        "--policy-table",
        type=Path,
        default=THIS_DIR / "prof" / "graph_auto_policy_table.csv",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=THIS_DIR / "prof" / "graph_persistent_ticket_sweep.csv",
    )
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args()

    if args.policy_table.exists():
        os.environ["RDNA3_GATHER_GRAPH_POLICY"] = str(args.policy_table)

    ext = tg.build_extension(SimpleNamespace(enable_direct=False))
    tasks_list = parse_int_list(args.tasks_list)
    tile_tokens_list = parse_int_list(args.tile_tokens_list)
    dims_list = parse_int_list(args.dims_list)
    transforms_list = parse_int_list(args.num_transforms_list)
    patterns_list = parse_str_list(args.patterns_list)
    seeds_list = parse_int_list(args.seeds_list)

    all_rows = []
    for dtype in args.dtypes:
        for tasks in tasks_list:
            for tile_tokens in tile_tokens_list:
                for dim in dims_list:
                    for num_transforms in transforms_list:
                        for pattern in patterns_list:
                            for seed in seeds_list:
                                rows = run_case(
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
                                all_rows.extend(rows)
                                if not args.quiet:
                                    best = max(rows, key=lambda row: row["persistent_speedup_vs_auto"])
                                    print(
                                        f"{dtype} tasks={tasks} tile={tile_tokens} dim={dim} "
                                        f"transforms={num_transforms} pattern={pattern} seed={seed} "
                                        f"policy={best['policy']} best_batch={best['ticket_batch_size']} "
                                        f"speedup={best['persistent_speedup_vs_auto']:.3f}"
                                    )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = list(all_rows[0].keys()) if all_rows else []
    with args.output.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(all_rows)
    print(f"wrote {args.output}")
    print_summary(all_rows)


if __name__ == "__main__":
    main()
