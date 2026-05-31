#!/usr/bin/env python3
import argparse
import csv
import math
import statistics
import time
from pathlib import Path
from types import SimpleNamespace
from typing import Iterable, Tuple

import torch

import test_gather as tg


THIS_DIR = Path(__file__).resolve().parent


def parse_int_list(values: Iterable[str]) -> Tuple[int, ...]:
    out = []
    for value in values:
        for piece in value.split(","):
            if piece:
                out.append(int(piece))
    return tuple(out)


def parse_float_list(values: Iterable[str]) -> Tuple[float, ...]:
    out = []
    for value in values:
        for piece in value.split(","):
            if piece:
                out.append(float(piece))
    return tuple(out)


def parse_capacity_scales(values: Iterable[str]) -> Tuple[float, ...]:
    out = []
    for value in values:
        for piece in value.split(","):
            if not piece:
                continue
            if piece == "max":
                out.append(0.0)
            else:
                out.append(float(piece))
    return tuple(out)


def capacity_scale_label(scale: float) -> str:
    return "max" if scale == 0.0 else f"{scale:g}x"


def percentile(values, q: float) -> float:
    if not values:
        return float("nan")
    ordered = sorted(values)
    pos = (len(ordered) - 1) * q
    lo = int(pos)
    hi = min(lo + 1, len(ordered) - 1)
    frac = pos - lo
    return ordered[lo] * (1.0 - frac) + ordered[hi] * frac


def make_counts(tasks: int, mean_neighbors: int, max_neighbors: int, skew: float, alpha: float, seed: int):
    gen = torch.Generator(device="cpu").manual_seed(seed)
    if skew <= 0:
        return torch.full((tasks,), max(1, mean_neighbors), dtype=torch.int32)

    u = torch.rand(tasks, generator=gen).clamp(1.0e-6, 1.0 - 1.0e-6)
    pareto = (1.0 - u).pow(-1.0 / alpha)
    weights = (1.0 - skew) * torch.ones_like(pareto) + skew * pareto
    target_edges = max(tasks, tasks * mean_neighbors)
    counts = torch.round(weights / weights.sum() * target_edges).to(torch.int64)
    counts = torch.clamp(counts, min=1, max=max_neighbors)
    return counts.to(torch.int32)


def make_varlen_graph(args, tasks: int, rows: int, mean_neighbors: int, counts: torch.Tensor, seed: int):
    gen = torch.Generator(device="cpu").manual_seed(seed + 104729)
    offsets = torch.zeros(tasks + 1, dtype=torch.int32)
    offsets[1:] = torch.cumsum(counts, dim=0)
    total_edges = int(offsets[-1])
    if args.index_pattern == "contiguous":
        pieces = []
        for task in range(tasks):
            count = int(counts[task])
            start = (task * max(1, mean_neighbors)) % rows
            pieces.append((torch.arange(count, dtype=torch.int64) + start).remainder(rows))
        flat_indices = torch.cat(pieces).to(torch.int32)
    else:
        flat_indices = torch.randint(0, rows, (total_edges,), generator=gen, dtype=torch.int32)
    return offsets, flat_indices


def make_dynamic_costs(
    counts: torch.Tensor,
    num_transforms: int,
    filter_ratio: float,
    transform_active_ratio: float,
    early_exit_ratio: float,
    seed: int,
):
    gen = torch.Generator(device="cpu").manual_seed(seed + 65537)
    tasks = counts.numel()

    if transform_active_ratio >= 1.0:
        transform_counts = torch.full((tasks,), num_transforms, dtype=torch.int32)
    else:
        jitter = 0.5 + torch.rand(tasks, generator=gen)
        active = torch.round(num_transforms * transform_active_ratio * jitter).to(torch.int64)
        transform_counts = torch.clamp(active, min=1, max=num_transforms).to(torch.int32)

    limits = counts.to(torch.float32)[:, None].repeat(1, num_transforms)
    if filter_ratio < 1.0:
        jitter = 0.5 + torch.rand(tasks, num_transforms, generator=gen)
        limits = limits * torch.clamp(filter_ratio * jitter, min=0.0, max=1.0)
    if early_exit_ratio < 1.0:
        jitter = 0.25 + 0.75 * torch.rand(tasks, num_transforms, generator=gen)
        limits = torch.minimum(
            limits,
            counts.to(torch.float32)[:, None] * torch.clamp(early_exit_ratio * jitter, max=1.0),
        )

    edge_limits = torch.round(limits).to(torch.int64)
    edge_limits = torch.minimum(edge_limits, counts.to(torch.int64)[:, None])
    edge_limits = torch.clamp(edge_limits, min=1).to(torch.int32)
    return transform_counts, edge_limits


def make_work_items(
    counts: torch.Tensor,
    offsets_cpu: torch.Tensor,
    num_transforms: int,
    chunk_tokens: int,
    order_cpu: torch.Tensor,
    transform_counts: torch.Tensor,
    edge_limits: torch.Tensor,
):
    work_task = []
    work_start = []
    work_count = []
    work_transform = []
    for task in order_cpu.tolist():
        count = int(counts[task])
        base = int(offsets_cpu[task])
        active_transforms = int(transform_counts[task])
        for transform in range(active_transforms):
            limit = min(count, int(edge_limits[task, transform]))
            for rel in range(0, limit, chunk_tokens):
                current = min(chunk_tokens, limit - rel)
                work_task.append(task)
                work_start.append(base + rel)
                work_count.append(current)
                work_transform.append(transform)
    return (
        torch.tensor(work_task, dtype=torch.int32),
        torch.tensor(work_start, dtype=torch.int32),
        torch.tensor(work_count, dtype=torch.int32),
        torch.tensor(work_transform, dtype=torch.int32),
    )


def to_cuda_timed(*tensors):
    start = time.perf_counter()
    device_tensors = tuple(tensor.cuda() for tensor in tensors)
    torch.cuda.synchronize()
    return device_tensors, (time.perf_counter() - start) * 1.0e3


def time_cuda_op(fn):
    torch.cuda.synchronize()
    start_wall = time.perf_counter()
    start = torch.cuda.Event(enable_timing=True)
    end = torch.cuda.Event(enable_timing=True)
    start.record()
    result = fn()
    end.record()
    torch.cuda.synchronize()
    return result, (time.perf_counter() - start_wall) * 1.0e3, start.elapsed_time(end)


def warmup_metadata_copy():
    _ = torch.empty(1, dtype=torch.int32).cuda()
    torch.cuda.synchronize()


def warmup_gpu_metadata(ext):
    anchor = torch.empty((), device="cuda", dtype=torch.int32)
    _ = ext.graph_generate_varlen_metadata(
        anchor,
        4,
        128,
        8,
        32,
        0.5,
        1.3,
        0,
        "random",
        4,
        0.8,
        0.8,
        0.8,
        4,
    )
    torch.cuda.synchronize()


def build_gpu_work_timed(
    ext,
    offsets,
    order,
    transform_counts,
    edge_limits,
    num_transforms: int,
    chunk_tokens: int,
):
    work, wall_ms, event_ms = time_cuda_op(
        lambda: tuple(
            ext.graph_build_varlen_work_items(
                offsets, order, transform_counts, edge_limits, num_transforms, chunk_tokens
            )
        )
    )
    return work, wall_ms, event_ms


def build_fixed_gpu_work_timed(
    ext,
    offsets,
    order,
    transform_counts,
    edge_limits,
    num_transforms: int,
    chunk_tokens: int,
    work_capacity: int,
):
    work, wall_ms, event_ms = time_cuda_op(
        lambda: tuple(
            ext.graph_build_varlen_work_items_fixed(
                offsets,
                order,
                transform_counts,
                edge_limits,
                num_transforms,
                chunk_tokens,
                work_capacity,
            )
        )
    )
    return work, wall_ms, event_ms


def time_and_check(name, fn, ref, args):
    out, ms = tg.time_variant(fn, args.warmup, args.iters)
    diff = tg.max_abs_diff(out, ref)
    if diff > args.tolerance:
        raise AssertionError(f"{name} mismatch vs static_node_identity: {diff}")
    return ms, diff


def run_case(
    ext,
    args,
    dtype_name,
    tasks,
    dim,
    num_transforms,
    mean_neighbors,
    max_neighbors,
    skew,
    filter_ratio,
    transform_active_ratio,
    early_exit_ratio,
    metadata_builder,
    seed,
    persistent_blocks,
):
    dtype = {"fp16": torch.float16, "bf16": torch.bfloat16}[dtype_name]
    graph_prep_ms = 0.0
    sort_ms = 0.0
    dynamic_cpu_ms = 0.0
    graph_h2d_ms = 0.0
    dynamic_h2d_ms = 0.0
    gpu_metadata_ms = 0.0
    gpu_metadata_event_ms = 0.0

    if metadata_builder == "cpu":
        graph_prep_start = time.perf_counter()
        counts = make_counts(tasks, mean_neighbors, max_neighbors, skew, args.pareto_alpha, seed)
        offsets_cpu, flat_indices_cpu = make_varlen_graph(
            args, tasks, args.rows, mean_neighbors, counts, seed
        )
        graph_prep_ms = (time.perf_counter() - graph_prep_start) * 1.0e3

        identity_cpu = torch.arange(tasks, dtype=torch.int32)
        sort_start = time.perf_counter()
        sorted_cpu = torch.argsort(counts, descending=True).to(torch.int32)
        sort_ms = (time.perf_counter() - sort_start) * 1.0e3
        dynamic_start = time.perf_counter()
        transform_counts_cpu, edge_limits_cpu = make_dynamic_costs(
            counts,
            num_transforms,
            filter_ratio,
            transform_active_ratio,
            early_exit_ratio,
            seed,
        )
        dynamic_cpu_ms = (time.perf_counter() - dynamic_start) * 1.0e3

        (offsets, flat_indices), graph_h2d_ms = to_cuda_timed(offsets_cpu, flat_indices_cpu)
        (identity,), identity_h2d_ms = to_cuda_timed(identity_cpu)
        (sorted_order,), sorted_h2d_ms = to_cuda_timed(sorted_cpu)
        (transform_counts, edge_limits), dynamic_h2d_ms = to_cuda_timed(
            transform_counts_cpu, edge_limits_cpu
        )
        order_inputs = (
            ("identity", identity_cpu, identity, 0.0, identity_h2d_ms),
            ("sorted", sorted_cpu, sorted_order, sort_ms, sorted_h2d_ms),
        )
    else:
        anchor = torch.empty((), device="cuda", dtype=torch.int32)
        (
            counts,
            offsets,
            flat_indices,
            identity,
            bucket_order,
            transform_counts,
            edge_limits,
        ), gpu_metadata_ms, gpu_metadata_event_ms = time_cuda_op(
            lambda: tuple(
                ext.graph_generate_varlen_metadata(
                    anchor,
                    tasks,
                    args.rows,
                    mean_neighbors,
                    max_neighbors,
                    skew,
                    args.pareto_alpha,
                    seed,
                    args.index_pattern,
                    num_transforms,
                    filter_ratio,
                    transform_active_ratio,
                    early_exit_ratio,
                    args.order_buckets,
                )
            )
        )
        counts_cpu = counts.cpu()
        torch.cuda.synchronize()
        order_inputs = (
            ("identity", None, identity, 0.0, 0.0),
            ("bucket", None, bucket_order, 0.0, 0.0),
        )

    _warmup_work = ext.graph_build_varlen_work_items(
        offsets, identity, transform_counts, edge_limits, num_transforms, args.chunk_tokens
    )
    fixed_capacity_scales = parse_capacity_scales(args.fixed_capacity_scales)
    max_chunks_per_pair = (max_neighbors + args.chunk_tokens - 1) // args.chunk_tokens
    max_work_capacity = tasks * num_transforms * max_chunks_per_pair
    _warmup_fixed_work = ext.graph_build_varlen_work_items_fixed(
        offsets,
        identity,
        transform_counts,
        edge_limits,
        num_transforms,
        args.chunk_tokens,
        max_work_capacity,
    )
    torch.cuda.synchronize()

    torch.manual_seed(seed)
    features = torch.randn(args.rows, dim, device="cuda", dtype=dtype)
    transforms = torch.randn(num_transforms, dim, device="cuda", dtype=dtype)

    if metadata_builder == "cpu":
        counts_cpu = counts
        total_edges = int(offsets_cpu[-1])
    else:
        total_edges = int(offsets[-1].item())
    max_count = int(counts_cpu.max())
    mean_count = float(counts_cpu.float().mean())
    p90_count = percentile([int(x) for x in counts_cpu.tolist()], 0.90)
    rows = []
    work_by_order = {}
    for order_name, order_cpu, order_dev, order_cpu_ms, order_h2d_ms in order_inputs:
        if metadata_builder == "cpu":
            work_start_time = time.perf_counter()
            work_cpu = make_work_items(
                counts,
                offsets_cpu,
                num_transforms,
                args.chunk_tokens,
                order_cpu,
                transform_counts_cpu,
                edge_limits_cpu,
            )
            work_cpu_ms = (time.perf_counter() - work_start_time) * 1.0e3
            work_dev, work_h2d_ms = to_cuda_timed(*work_cpu)
        else:
            work_cpu = None
            work_cpu_ms = 0.0
            work_dev = None
            work_h2d_ms = 0.0
        gpu_work_dev, gpu_work_build_ms, gpu_work_build_event_ms = build_gpu_work_timed(
            ext,
            offsets,
            order_dev,
            transform_counts,
            edge_limits,
            num_transforms,
            args.chunk_tokens,
        )
        actual_work_size = int(gpu_work_dev[0].numel())
        fixed_work_by_scale = []
        for capacity_scale in fixed_capacity_scales:
            capacity_label = capacity_scale_label(capacity_scale)
            work_capacity = (
                max_work_capacity
                if capacity_scale == 0.0
                else max(1, int(math.ceil(actual_work_size * capacity_scale)))
            )
            overflowed = int(actual_work_size > work_capacity)
            if overflowed:
                if args.overflow_policy == "error":
                    raise RuntimeError(
                        f"fixed worklist overflow: actual={actual_work_size} "
                        f"capacity={work_capacity} scale={capacity_label}"
                    )
                if args.overflow_policy == "skip":
                    continue
                fixed_work_by_scale.append(
                    {
                        "work": gpu_work_dev,
                        "build_ms": gpu_work_build_ms,
                        "build_event_ms": gpu_work_build_event_ms,
                        "builder": "fixed_overflow_exact",
                        "capacity_scale": capacity_label,
                        "work_capacity": work_capacity,
                        "actual_work_size": actual_work_size,
                        "overflowed": overflowed,
                        "uses_fixed_kernel": False,
                    }
                )
                continue

            fixed_work_dev, fixed_work_build_ms, fixed_work_build_event_ms = (
                build_fixed_gpu_work_timed(
                    ext,
                    offsets,
                    order_dev,
                    transform_counts,
                    edge_limits,
                    num_transforms,
                    args.chunk_tokens,
                    work_capacity,
                )
            )
            fixed_work_by_scale.append(
                {
                    "work": fixed_work_dev,
                    "build_ms": fixed_work_build_ms,
                    "build_event_ms": fixed_work_build_event_ms,
                    "builder": "fixed",
                    "capacity_scale": capacity_label,
                    "work_capacity": work_capacity,
                    "actual_work_size": actual_work_size,
                    "overflowed": overflowed,
                    "uses_fixed_kernel": True,
                }
            )
        work_by_order[order_name] = {
            "cpu": work_cpu,
            "dev": work_dev,
            "cpu_ms": work_cpu_ms,
            "h2d_ms": work_h2d_ms,
            "gpu_dev": gpu_work_dev,
            "gpu_build_ms": gpu_work_build_ms,
            "gpu_build_event_ms": gpu_work_build_event_ms,
            "actual_work_size": actual_work_size,
            "fixed_by_scale": fixed_work_by_scale,
        }

    dynamic_enabled = (
        filter_ratio < 1.0 or transform_active_ratio < 1.0 or early_exit_ratio < 1.0
    )
    if dynamic_enabled:
        ref_work = work_by_order["identity"]["dev"] or work_by_order["identity"]["gpu_dev"]
        ref = ext.graph_varlen_static_chunked(
            features, flat_indices, transforms, *ref_work, tasks
        )
    else:
        ref = ext.graph_varlen_static(features, offsets, flat_indices, transforms, identity)
    torch.cuda.synchronize()

    order_costs = {
        order_name: {"cpu_ms": order_cpu_ms, "h2d_ms": order_h2d_ms, "dev": order_dev}
        for order_name, _order_cpu, order_dev, order_cpu_ms, order_h2d_ms in order_inputs
    }

    variants = []
    if not dynamic_enabled:
        for order_name, _order_cpu, order_dev, order_cpu_ms, order_h2d_ms in order_inputs:
            variants.append(
                (
                    "static_node",
                    "none",
                    order_name,
                    0,
                    graph_prep_ms + order_cpu_ms,
                    graph_h2d_ms + order_h2d_ms,
                    gpu_metadata_ms,
                    lambda order_dev=order_dev: ext.graph_varlen_static(
                        features, offsets, flat_indices, transforms, order_dev
                    ),
                    {
                        "capacity_scale": "none",
                        "actual_work_size": 0,
                        "work_capacity": 0,
                        "overflowed": 0,
                        "metadata_build_event_ms": gpu_metadata_event_ms,
                        "worklist_build_ms": 0.0,
                        "worklist_build_event_ms": 0.0,
                    },
                )
            )

    for order_name, _order_cpu, _order_dev, _order_cpu_ms, _order_h2d_ms in order_inputs:
        work = work_by_order[order_name]["dev"]
        gpu_work = work_by_order[order_name]["gpu_dev"]
        order_cpu_ms = order_costs[order_name]["cpu_ms"]
        work_cpu_ms = work_by_order[order_name]["cpu_ms"]
        work_h2d_ms = work_by_order[order_name]["h2d_ms"]
        gpu_work_build_ms = work_by_order[order_name]["gpu_build_ms"]
        gpu_work_build_event_ms = work_by_order[order_name]["gpu_build_event_ms"]
        actual_work_size = work_by_order[order_name]["actual_work_size"]
        exact_extra = {
            "capacity_scale": "exact",
            "actual_work_size": actual_work_size,
            "work_capacity": actual_work_size,
            "overflowed": 0,
            "metadata_build_event_ms": gpu_metadata_event_ms,
            "worklist_build_ms": 0.0,
            "worklist_build_event_ms": 0.0,
        }
        if work is not None:
            variants.append(
                (
                    "static_chunked",
                    "cpu",
                    order_name,
                    0,
                    graph_prep_ms + dynamic_cpu_ms + order_cpu_ms + work_cpu_ms,
                    graph_h2d_ms + work_h2d_ms,
                    gpu_metadata_ms,
                    lambda work=work: ext.graph_varlen_static_chunked(
                        features, flat_indices, transforms, *work, tasks
                    ),
                    exact_extra,
                )
            )
        variants.append(
            (
                "static_chunked",
                "gpu",
                order_name,
                0,
                graph_prep_ms + dynamic_cpu_ms + order_cpu_ms,
                graph_h2d_ms + order_costs[order_name]["h2d_ms"] + dynamic_h2d_ms,
                gpu_metadata_ms + gpu_work_build_ms,
                lambda work=gpu_work: ext.graph_varlen_static_chunked(
                    features, flat_indices, transforms, *work, tasks
                ),
                {
                    **exact_extra,
                    "worklist_build_ms": gpu_work_build_ms,
                    "worklist_build_event_ms": gpu_work_build_event_ms,
                },
            )
        )
        for fixed_entry in work_by_order[order_name]["fixed_by_scale"]:
            if fixed_entry["uses_fixed_kernel"]:
                fixed_fn = lambda work=fixed_entry["work"]: ext.graph_varlen_static_chunked_fixed(
                    features, flat_indices, transforms, *work, tasks
                )
            else:
                fixed_fn = lambda work=fixed_entry["work"]: ext.graph_varlen_static_chunked(
                    features, flat_indices, transforms, *work, tasks
                )
            variants.append(
                (
                    "static_chunked_fixed",
                    fixed_entry["builder"],
                    order_name,
                    0,
                    graph_prep_ms + dynamic_cpu_ms + order_cpu_ms,
                    graph_h2d_ms + order_costs[order_name]["h2d_ms"] + dynamic_h2d_ms,
                    gpu_metadata_ms + fixed_entry["build_ms"],
                    fixed_fn,
                    {
                        "capacity_scale": fixed_entry["capacity_scale"],
                        "actual_work_size": fixed_entry["actual_work_size"],
                        "work_capacity": fixed_entry["work_capacity"],
                        "overflowed": fixed_entry["overflowed"],
                        "metadata_build_event_ms": gpu_metadata_event_ms,
                        "worklist_build_ms": fixed_entry["build_ms"],
                        "worklist_build_event_ms": fixed_entry["build_event_ms"],
                    },
                )
            )
        for batch_size in args.ticket_batch_sizes:
            if not dynamic_enabled:
                order_dev = order_costs[order_name]["dev"]
                variants.append(
                    (
                        "persistent_node",
                        "none",
                        order_name,
                        batch_size,
                        graph_prep_ms + order_cpu_ms,
                        graph_h2d_ms + order_costs[order_name]["h2d_ms"],
                        gpu_metadata_ms,
                        lambda batch_size=batch_size, order_dev=order_dev: ext.graph_varlen_persistent_node(
                            features,
                            offsets,
                            flat_indices,
                            transforms,
                            order_dev,
                            persistent_blocks,
                            batch_size,
                        ),
                        exact_extra,
                    )
                )
            if work is not None:
                variants.append(
                    (
                        "persistent_chunked",
                        "cpu",
                        order_name,
                        batch_size,
                        graph_prep_ms + dynamic_cpu_ms + order_cpu_ms + work_cpu_ms,
                        graph_h2d_ms + work_h2d_ms,
                        gpu_metadata_ms,
                        lambda batch_size=batch_size, work=work: ext.graph_varlen_persistent_chunked(
                            features,
                            flat_indices,
                            transforms,
                            *work,
                            tasks,
                            persistent_blocks,
                            batch_size,
                        ),
                        exact_extra,
                    )
                )
            variants.append(
                (
                    "persistent_chunked",
                    "gpu",
                    order_name,
                    batch_size,
                    graph_prep_ms + dynamic_cpu_ms + order_cpu_ms,
                    graph_h2d_ms + order_costs[order_name]["h2d_ms"] + dynamic_h2d_ms,
                    gpu_metadata_ms + gpu_work_build_ms,
                    lambda batch_size=batch_size, work=gpu_work: ext.graph_varlen_persistent_chunked(
                        features,
                        flat_indices,
                        transforms,
                        *work,
                        tasks,
                        persistent_blocks,
                        batch_size,
                    ),
                    {
                        **exact_extra,
                        "worklist_build_ms": gpu_work_build_ms,
                        "worklist_build_event_ms": gpu_work_build_event_ms,
                    },
                )
            )

    baseline_ms = None
    baseline_e2e_ms = None
    for (
        variant,
        worklist_builder,
        order_name,
        batch_size,
        cpu_preprocess_ms,
        h2d_metadata_ms,
        gpu_preprocess_ms,
        fn,
        extra,
    ) in variants:
        ms, diff = time_and_check(
            f"{variant}/{worklist_builder}/{order_name}/{batch_size}", fn, ref, args
        )
        end_to_end_ms = cpu_preprocess_ms + h2d_metadata_ms + gpu_preprocess_ms + ms
        if variant == "static_node" and order_name == "identity":
            baseline_ms = ms
            baseline_e2e_ms = end_to_end_ms
        if baseline_ms is None and variant == "static_chunked" and order_name == "identity":
            baseline_ms = ms
            baseline_e2e_ms = end_to_end_ms
        rows.append(
            {
                "dtype": dtype_name,
                "tasks": tasks,
                "dim": dim,
                "num_transforms": num_transforms,
                "mean_neighbors_target": mean_neighbors,
                "max_neighbors": max_neighbors,
                "skew": skew,
                "filter_ratio": filter_ratio,
                "transform_active_ratio": transform_active_ratio,
                "early_exit_ratio": early_exit_ratio,
                "pareto_alpha": args.pareto_alpha,
                "seed": seed,
                "total_edges": total_edges,
                "mean_count": mean_count,
                "p90_count": p90_count,
                "max_count": max_count,
                "chunk_tokens": args.chunk_tokens,
                "capacity_scale": extra["capacity_scale"],
                "actual_work_size": extra["actual_work_size"],
                "work_capacity": extra["work_capacity"],
                "capacity_actual_ratio": (
                    extra["work_capacity"] / extra["actual_work_size"]
                    if extra["actual_work_size"]
                    else 0.0
                ),
                "overflowed": extra["overflowed"],
                "persistent_blocks": persistent_blocks,
                "metadata_builder": metadata_builder,
                "variant": variant,
                "worklist_builder": worklist_builder,
                "order": order_name,
                "ticket_batch_size": batch_size,
                "gpu_kernel_ms": ms,
                "cpu_preprocess_ms": cpu_preprocess_ms,
                "h2d_metadata_ms": h2d_metadata_ms,
                "gpu_preprocess_ms": gpu_preprocess_ms,
                "gpu_metadata_ms": gpu_metadata_ms,
                "metadata_build_event_ms": extra["metadata_build_event_ms"],
                "worklist_build_ms": extra["worklist_build_ms"],
                "worklist_build_event_ms": extra["worklist_build_event_ms"],
                "level2_compute_ms": ms,
                "end_to_end_ms": end_to_end_ms,
                "speedup_vs_static_node": baseline_ms / ms if baseline_ms else 1.0,
                "end_to_end_speedup_vs_static_node": (
                    baseline_e2e_ms / end_to_end_ms if baseline_e2e_ms else 1.0
                ),
                "max_abs_diff": diff,
            }
        )
    return rows


def print_summary(rows):
    grouped = {}
    for row in rows:
        key = (
            row["metadata_builder"],
            row["variant"],
            row["worklist_builder"],
            row["order"],
            int(row["ticket_batch_size"]),
            int(row["persistent_blocks"]),
            row.get("capacity_scale", ""),
        )
        grouped.setdefault(key, []).append(float(row["speedup_vs_static_node"]))
    for key in sorted(grouped):
        kernel_values = grouped[key]
        e2e_values = [
            float(row["end_to_end_speedup_vs_static_node"])
            for row in rows
            if (
                row["metadata_builder"],
                row["variant"],
                row["worklist_builder"],
                row["order"],
                int(row["ticket_batch_size"]),
                int(row["persistent_blocks"]),
                row.get("capacity_scale", ""),
            )
            == key
        ]
        print(
            "summary "
            f"metadata={key[0]} variant={key[1]} worklist={key[2]} order={key[3]} "
            f"ticket_batch={key[4]} persistent_blocks={key[5]} capacity={key[6]} "
            f"cases={len(kernel_values)} "
            f"kernel_median={statistics.median(kernel_values):.3f} "
            f"kernel_p10={percentile(kernel_values, 0.10):.3f} "
            f"kernel_min={min(kernel_values):.3f} "
            f"e2e_median={statistics.median(e2e_values):.3f} "
            f"e2e_p10={percentile(e2e_values, 0.10):.3f} "
            f"e2e_min={min(e2e_values):.3f}"
        )


def main():
    parser = argparse.ArgumentParser(description="Phase 3B skewed varlen graph scheduling sweep")
    parser.add_argument("--dtypes", nargs="+", default=("fp16", "bf16"), choices=("fp16", "bf16"))
    parser.add_argument("--tasks-list", nargs="+", default=("32", "128", "256"))
    parser.add_argument("--dims-list", nargs="+", default=("64", "128"))
    parser.add_argument("--num-transforms-list", nargs="+", default=("8", "32"))
    parser.add_argument("--mean-neighbors-list", nargs="+", default=("64",))
    parser.add_argument("--max-neighbors-list", nargs="+", default=("512",))
    parser.add_argument("--skews-list", nargs="+", default=("0", "0.5", "0.8", "0.95"))
    parser.add_argument("--filter-ratios-list", nargs="+", default=("1.0",))
    parser.add_argument("--transform-active-ratios-list", nargs="+", default=("1.0",))
    parser.add_argument("--early-exit-ratios-list", nargs="+", default=("1.0",))
    parser.add_argument("--metadata-builders", nargs="+", default=("cpu",), choices=("cpu", "gpu"))
    parser.add_argument("--order-buckets", type=int, default=8)
    parser.add_argument(
        "--fixed-capacity-scales",
        nargs="+",
        default=("max",),
        help=(
            "fixed worklist capacity scale relative to exact work size; "
            "use 'max' for tasks*num_transforms*ceil(max_neighbors/chunk_tokens)"
        ),
    )
    parser.add_argument(
        "--overflow-policy",
        choices=("skip", "exact", "error"),
        default="skip",
        help="handling when fixed capacity is smaller than exact work size",
    )
    parser.add_argument("--seeds-list", nargs="+", default=("0", "1", "2"))
    parser.add_argument("--rows", type=int, default=65536)
    parser.add_argument("--index-pattern", choices=("random", "contiguous"), default="random")
    parser.add_argument("--pareto-alpha", type=float, default=1.3)
    parser.add_argument("--chunk-tokens", type=int, default=64)
    parser.add_argument("--ticket-batch-sizes", nargs="+", type=int, default=(1, 2, 4, 8))
    parser.add_argument("--persistent-blocks", type=int, default=0)
    parser.add_argument(
        "--persistent-blocks-list",
        nargs="+",
        default=None,
        help="optional list of persistent block counts; overrides --persistent-blocks",
    )
    parser.add_argument("--warmup", type=int, default=3)
    parser.add_argument("--iters", type=int, default=20)
    parser.add_argument("--tolerance", type=float, default=2.0e-2)
    parser.add_argument("--quiet", action="store_true")
    parser.add_argument(
        "--output",
        type=Path,
        default=THIS_DIR / "prof" / "graph_skew_scheduling_sweep.csv",
    )
    args = parser.parse_args()

    ext = tg.build_extension(SimpleNamespace(enable_direct=False))
    warmup_metadata_copy()
    warmup_gpu_metadata(ext)
    persistent_blocks_list = (
        parse_int_list(args.persistent_blocks_list)
        if args.persistent_blocks_list is not None
        else (args.persistent_blocks,)
    )
    all_rows = []
    for dtype in args.dtypes:
        for tasks in parse_int_list(args.tasks_list):
            for dim in parse_int_list(args.dims_list):
                for num_transforms in parse_int_list(args.num_transforms_list):
                    for mean_neighbors in parse_int_list(args.mean_neighbors_list):
                        for max_neighbors in parse_int_list(args.max_neighbors_list):
                            for skew in parse_float_list(args.skews_list):
                                for filter_ratio in parse_float_list(args.filter_ratios_list):
                                    for transform_active_ratio in parse_float_list(
                                        args.transform_active_ratios_list
                                    ):
                                        for early_exit_ratio in parse_float_list(
                                            args.early_exit_ratios_list
                                        ):
                                            for metadata_builder in args.metadata_builders:
                                                for seed in parse_int_list(args.seeds_list):
                                                    for persistent_blocks in persistent_blocks_list:
                                                        rows = run_case(
                                                            ext,
                                                            args,
                                                            dtype,
                                                            tasks,
                                                            dim,
                                                            num_transforms,
                                                            mean_neighbors,
                                                            max_neighbors,
                                                            skew,
                                                            filter_ratio,
                                                            transform_active_ratio,
                                                            early_exit_ratio,
                                                            metadata_builder,
                                                            seed,
                                                            persistent_blocks,
                                                        )
                                                        all_rows.extend(rows)
                                                        if not args.quiet:
                                                            best = max(
                                                                rows,
                                                                key=lambda row: row[
                                                                    "speedup_vs_static_node"
                                                                ],
                                                            )
                                                            print(
                                                                f"{dtype} tasks={tasks} dim={dim} "
                                                                f"transforms={num_transforms} "
                                                                f"mean={mean_neighbors} max={max_neighbors} "
                                                                f"skew={skew} filter={filter_ratio} "
                                                                f"transform_active={transform_active_ratio} "
                                                                f"early_exit={early_exit_ratio} "
                                                                f"metadata={metadata_builder} seed={seed} "
                                                                f"pblocks={persistent_blocks} "
                                                                f"best={best['variant']}/"
                                                                f"{best['worklist_builder']}/"
                                                                f"{best['order']}/b{best['ticket_batch_size']} "
                                                                f"speedup={best['speedup_vs_static_node']:.3f}"
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
