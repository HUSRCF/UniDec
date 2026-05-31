#!/usr/bin/env python3
import argparse
import ast
import csv
import json
import math
import statistics
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple

import torch


THIS_DIR = Path(__file__).resolve().parent


@dataclass
class TraceRecord:
    trace_id: str
    counts: Optional[List[int]] = None
    num_transforms: Optional[int] = None
    transform_counts: Optional[List[int]] = None
    edge_limits: Optional[List[List[int]]] = None
    actual_work_size: Optional[int] = None
    reference_capacity: Optional[int] = None


def percentile(values: Sequence[float], q: float) -> float:
    if not values:
        return float("nan")
    ordered = sorted(values)
    pos = (len(ordered) - 1) * q
    lo = int(pos)
    hi = min(lo + 1, len(ordered) - 1)
    frac = pos - lo
    return ordered[lo] * (1.0 - frac) + ordered[hi] * frac


def ceil_div(value: int, divisor: int) -> int:
    return (value + divisor - 1) // divisor


def round_up(value: int, multiple: int) -> int:
    if multiple <= 1:
        return value
    return ceil_div(value, multiple) * multiple


def parse_numeric_list(value: Any) -> List[int]:
    if value is None:
        return []
    if isinstance(value, torch.Tensor):
        return [int(x) for x in value.cpu().reshape(-1).tolist()]
    if isinstance(value, (list, tuple)):
        out = []
        for item in value:
            if isinstance(item, (list, tuple)):
                out.extend(parse_numeric_list(item))
            else:
                out.append(int(item))
        return out
    text = str(value).strip()
    if not text:
        return []
    if text[0] in "[(":
        parsed = ast.literal_eval(text)
        return parse_numeric_list(parsed)
    text = text.replace(";", ",").replace("|", ",").replace(" ", ",")
    return [int(float(piece)) for piece in text.split(",") if piece]


def parse_matrix(value: Any, rows: int, cols: int) -> Optional[List[List[int]]]:
    if value is None:
        return None
    if isinstance(value, torch.Tensor):
        tensor = value.cpu()
        if tensor.numel() == 0:
            return None
        if tensor.dim() == 1:
            values = [int(x) for x in tensor.tolist()]
        else:
            return [[int(x) for x in row] for row in tensor.reshape(rows, cols).tolist()]
    else:
        text = str(value).strip()
        if not text:
            return None
        if text[0] == "[":
            parsed = ast.literal_eval(text)
            if parsed and isinstance(parsed[0], (list, tuple)):
                return [[int(x) for x in row] for row in parsed]
            values = parse_numeric_list(parsed)
        else:
            values = parse_numeric_list(text)
    if len(values) == rows * cols:
        return [values[row * cols : (row + 1) * cols] for row in range(rows)]
    if len(values) == cols:
        return [list(values) for _ in range(rows)]
    if len(values) == rows:
        return [[int(values[row]) for _ in range(cols)] for row in range(rows)]
    raise ValueError(f"cannot reshape edge limits of length {len(values)} to [{rows}, {cols}]")


def counts_from_offsets(offsets: Any) -> List[int]:
    values = parse_numeric_list(offsets)
    if len(values) < 2:
        raise ValueError("offsets must have at least two entries")
    return [max(0, values[i + 1] - values[i]) for i in range(len(values) - 1)]


def tensor_to_python(value: Any) -> Any:
    if isinstance(value, torch.Tensor):
        return value.cpu().tolist()
    return value


def as_record(obj: Any, trace_id: str, default_num_transforms: Optional[int]) -> TraceRecord:
    if not isinstance(obj, dict):
        raise TypeError(f"trace {trace_id} must be a dict-like object")
    obj = {str(key): tensor_to_python(value) for key, value in obj.items()}

    counts = None
    if "counts" in obj:
        counts = parse_numeric_list(obj["counts"])
    elif "neighbor_counts" in obj:
        counts = parse_numeric_list(obj["neighbor_counts"])
    elif "offsets" in obj:
        counts = counts_from_offsets(obj["offsets"])
    elif "indptr" in obj:
        counts = counts_from_offsets(obj["indptr"])
    elif "cache_seqlens" in obj:
        counts = parse_numeric_list(obj["cache_seqlens"])
        sliding_window = obj.get("sliding_window")
        if sliding_window not in (None, "", "null", -1, "-1"):
            if isinstance(sliding_window, (list, tuple)):
                sliding_window = max(int(x) for x in sliding_window if int(x) >= 0)
            else:
                sliding_window = int(float(sliding_window))
            counts = [min(int(count), sliding_window) for count in counts]

    inferred_num_transforms = None
    if "num_kv_heads" in obj or "num_q_heads" in obj:
        head_mapping = str(obj.get("head_mapping") or "kv")
        if head_mapping == "q":
            head_count = int(obj.get("num_q_heads") or obj.get("num_kv_heads") or 1)
        else:
            head_count = int(obj.get("num_kv_heads") or obj.get("num_q_heads") or 1)
        q_len = int(obj.get("q_len") or 1)
        inferred_num_transforms = head_count * q_len

    num_transforms = int(obj.get("num_transforms") or inferred_num_transforms or default_num_transforms or 1)
    transform_counts = None
    if "transform_counts" in obj:
        transform_counts = parse_numeric_list(obj["transform_counts"])
    elif "active_transforms" in obj:
        transform_counts = parse_numeric_list(obj["active_transforms"])
    elif counts is not None and "query_lens" in obj and ("num_kv_heads" in obj or "num_q_heads" in obj):
        head_mapping = str(obj.get("head_mapping") or "kv")
        if head_mapping == "q":
            head_count = int(obj.get("num_q_heads") or obj.get("num_kv_heads") or 1)
        else:
            head_count = int(obj.get("num_kv_heads") or obj.get("num_q_heads") or 1)
        query_lens = parse_numeric_list(obj["query_lens"])
        if len(query_lens) == 1 and len(counts) > 1:
            query_lens = query_lens * len(counts)
        if len(query_lens) == len(counts):
            transform_counts = [head_count * int(query_len) for query_len in query_lens]
            num_transforms = max(transform_counts) if transform_counts else num_transforms

    edge_limits = None
    if "edge_limits" in obj and counts is not None:
        edge_limits = parse_matrix(obj["edge_limits"], len(counts), num_transforms)

    actual_work_size = obj.get("actual_work_size")
    reference_capacity = obj.get("work_capacity", obj.get("reference_capacity"))
    return TraceRecord(
        trace_id=str(obj.get("trace_id", obj.get("id", trace_id))),
        counts=counts,
        num_transforms=num_transforms,
        transform_counts=transform_counts,
        edge_limits=edge_limits,
        actual_work_size=int(actual_work_size) if actual_work_size not in (None, "") else None,
        reference_capacity=int(float(reference_capacity)) if reference_capacity not in (None, "") else None,
    )


def load_pt(path: Path, default_num_transforms: Optional[int]) -> List[TraceRecord]:
    data = torch.load(path, map_location="cpu")
    if isinstance(data, dict) and "traces" in data:
        traces = data["traces"]
    else:
        traces = data
    if isinstance(traces, dict):
        if "counts" in traces and torch.as_tensor(traces["counts"]).dim() >= 2:
            counts = torch.as_tensor(traces["counts"])
            out = []
            for idx in range(counts.size(0)):
                item = dict(traces)
                item["counts"] = counts[idx]
                if "transform_counts" in traces:
                    item["transform_counts"] = torch.as_tensor(traces["transform_counts"])[idx]
                if "edge_limits" in traces:
                    item["edge_limits"] = torch.as_tensor(traces["edge_limits"])[idx]
                item["trace_id"] = f"trace_{idx}"
                out.append(as_record(item, f"trace_{idx}", default_num_transforms))
            return out
        return [as_record(traces, "trace_0", default_num_transforms)]
    return [as_record(item, f"trace_{idx}", default_num_transforms) for idx, item in enumerate(traces)]


def load_npz(path: Path, default_num_transforms: Optional[int]) -> List[TraceRecord]:
    import numpy as np

    data = np.load(path, allow_pickle=True)
    keys = set(data.files)
    if "traces" in keys:
        return [
            as_record(item.item() if hasattr(item, "item") else item, f"trace_{idx}", default_num_transforms)
            for idx, item in enumerate(data["traces"])
        ]
    if "counts" in keys:
        counts = data["counts"]
        if counts.ndim == 1:
            obj = {key: data[key] for key in keys}
            return [as_record(obj, "trace_0", default_num_transforms)]
        out = []
        for idx in range(counts.shape[0]):
            obj = {key: data[key] for key in keys if data[key].shape[:1] != counts.shape[:1]}
            obj["counts"] = counts[idx]
            if "transform_counts" in keys:
                obj["transform_counts"] = data["transform_counts"][idx]
            if "edge_limits" in keys:
                obj["edge_limits"] = data["edge_limits"][idx]
            obj["trace_id"] = f"trace_{idx}"
            out.append(as_record(obj, f"trace_{idx}", default_num_transforms))
        return out

    grouped: Dict[str, Dict[str, Any]] = {}
    for key in data.files:
        if "_" not in key:
            continue
        prefix, suffix = key.rsplit("_", 1)
        grouped.setdefault(prefix, {})[suffix] = data[key]
    if not grouped:
        raise ValueError(f"{path} does not contain counts or grouped trace arrays")
    return [as_record({"trace_id": name, **obj}, name, default_num_transforms) for name, obj in grouped.items()]


def load_csv(path: Path, default_num_transforms: Optional[int]) -> List[TraceRecord]:
    with path.open(newline="") as f:
        rows = list(csv.DictReader(f))
    if not rows:
        return []

    if "counts" in rows[0] or "neighbor_counts" in rows[0] or "offsets" in rows[0] or "indptr" in rows[0]:
        return [as_record(row, f"trace_{idx}", default_num_transforms) for idx, row in enumerate(rows)]

    count_key = "count" if "count" in rows[0] else "neighbor_count" if "neighbor_count" in rows[0] else None
    if count_key is not None:
        grouped: Dict[str, List[Dict[str, str]]] = {}
        for idx, row in enumerate(rows):
            trace_id = row.get("trace_id") or row.get("batch_id") or "trace_0"
            grouped.setdefault(trace_id, []).append(row)
        out = []
        for trace_id, group in grouped.items():
            counts = [int(float(row[count_key])) for row in group]
            obj: Dict[str, Any] = {
                "trace_id": trace_id,
                "counts": counts,
                "num_transforms": default_num_transforms or int(group[0].get("num_transforms") or 1),
            }
            if "transform_count" in group[0]:
                obj["transform_counts"] = [int(float(row["transform_count"])) for row in group]
            if "active_transforms" in group[0]:
                obj["transform_counts"] = [int(float(row["active_transforms"])) for row in group]
            if "edge_limits" in group[0]:
                limits = []
                for row in group:
                    parsed = parse_numeric_list(row["edge_limits"])
                    limits.append(parsed)
                obj["edge_limits"] = limits
            out.append(as_record(obj, trace_id, default_num_transforms))
        return out

    if "actual_work_size" in rows[0]:
        out = []
        for idx, row in enumerate(rows):
            out.append(
                TraceRecord(
                    trace_id=row.get("trace_id") or row.get("seed") or f"trace_{idx}",
                    actual_work_size=int(float(row["actual_work_size"])),
                    reference_capacity=(
                        int(float(row["work_capacity"])) if row.get("work_capacity") else None
                    ),
                    num_transforms=default_num_transforms,
                )
            )
        return out

    raise ValueError(
        "CSV must contain counts/neighbor_counts/offsets/indptr, row-wise count, or actual_work_size"
    )


def load_jsonl(path: Path, default_num_transforms: Optional[int]) -> List[TraceRecord]:
    out = []
    with path.open() as f:
        for idx, line in enumerate(f):
            line = line.strip()
            if not line:
                continue
            out.append(as_record(json.loads(line), f"trace_{idx}", default_num_transforms))
    return out


def load_traces(path: Path, default_num_transforms: Optional[int]) -> List[TraceRecord]:
    suffix = path.suffix.lower()
    if suffix in (".pt", ".pth"):
        return load_pt(path, default_num_transforms)
    if suffix == ".npz":
        return load_npz(path, default_num_transforms)
    if suffix == ".csv":
        return load_csv(path, default_num_transforms)
    if suffix == ".jsonl":
        return load_jsonl(path, default_num_transforms)
    raise ValueError(f"unsupported trace format: {path}")


def compute_actual_work(record: TraceRecord, chunk_tokens: int, default_num_transforms: int) -> int:
    if record.actual_work_size is not None:
        return record.actual_work_size
    if record.counts is None:
        raise ValueError(f"{record.trace_id}: no counts or actual_work_size")

    counts = [max(0, int(x)) for x in record.counts]
    num_transforms = int(record.num_transforms or default_num_transforms)
    transform_counts = record.transform_counts or [num_transforms] * len(counts)
    if len(transform_counts) != len(counts):
        raise ValueError(f"{record.trace_id}: transform_counts length mismatch")

    total = 0
    for task, count in enumerate(counts):
        active = max(0, min(int(transform_counts[task]), num_transforms))
        for transform in range(active):
            limit = count
            if record.edge_limits is not None:
                limit = min(limit, int(record.edge_limits[task][transform]))
            if limit > 0:
                total += ceil_div(limit, chunk_tokens)
    return total


def static_max_capacity(record: TraceRecord, chunk_tokens: int, default_num_transforms: int, max_neighbors: Optional[int]) -> Optional[int]:
    if record.counts is None:
        return record.reference_capacity
    count_max = int(max_neighbors) if max_neighbors is not None else max(record.counts or [0])
    num_transforms = int(record.num_transforms or default_num_transforms)
    return len(record.counts) * num_transforms * ceil_div(max(0, count_max), chunk_tokens)


def summarize(values: Sequence[float]) -> Dict[str, float]:
    if not values:
        return {}
    return {
        "min": min(values),
        "p50": percentile(values, 0.50),
        "p90": percentile(values, 0.90),
        "p95": percentile(values, 0.95),
        "p99": percentile(values, 0.99),
        "max": max(values),
        "mean": statistics.fmean(values),
    }


def parse_float_list(values: Iterable[str]) -> List[float]:
    out = []
    for value in values:
        for piece in str(value).split(","):
            if piece:
                out.append(float(piece))
    return out


def parse_int_list(values: Iterable[str]) -> List[int]:
    out = []
    for value in values:
        for piece in str(value).split(","):
            if piece:
                out.append(int(float(piece)))
    return out


def choose_quantile_classes(actual_sizes: Sequence[int], quantiles: Sequence[float], align: int) -> List[int]:
    classes = []
    for q in quantiles:
        capacity = round_up(int(math.ceil(percentile(actual_sizes, q))), align)
        if not classes or capacity > classes[-1]:
            classes.append(capacity)
    return classes


def choose_ratio_classes(
    actual_sizes: Sequence[int],
    num_classes: int,
    align: int,
    max_points: int,
) -> List[int]:
    values = sorted(set(int(x) for x in actual_sizes if x > 0))
    if not values:
        return []
    if max_points > 0 and len(values) > max_points:
        sampled = []
        for idx in range(max_points):
            pos = round(idx * (len(values) - 1) / (max_points - 1))
            sampled.append(values[pos])
        values = sorted(set(sampled))
    if num_classes <= 1:
        return [round_up(values[-1], align)]
    if num_classes >= len(values):
        return sorted(set(round_up(value, align) for value in values))

    n = len(values)
    inf = float("inf")
    dp = [[inf] * (n + 1) for _ in range(num_classes + 1)]
    split = [[0] * (n + 1) for _ in range(num_classes + 1)]
    dp[0][0] = 0.0

    def group_cost(start: int, end: int) -> float:
        capacity = round_up(values[end - 1], align)
        return capacity / values[start]

    for groups in range(1, num_classes + 1):
        for end in range(1, n + 1):
            best = inf
            best_start = 0
            for start in range(groups - 1, end):
                previous = dp[groups - 1][start]
                if previous == inf:
                    continue
                cost = max(previous, group_cost(start, end))
                if cost < best:
                    best = cost
                    best_start = start
            dp[groups][end] = best
            split[groups][end] = best_start

    classes = []
    end = n
    groups = num_classes
    while groups > 0 and end > 0:
        start = split[groups][end]
        classes.append(round_up(values[end - 1], align))
        end = start
        groups -= 1
    return sorted(set(classes))


def evaluate_classes(actual_sizes: Sequence[int], classes: Sequence[int]) -> Tuple[List[Dict[str, Any]], Dict[str, Any]]:
    class_counts = {capacity: 0 for capacity in classes}
    rows = []
    ratios = []
    overflowed = 0
    for idx, actual in enumerate(actual_sizes):
        selected = None
        for capacity in classes:
            if actual <= capacity:
                selected = capacity
                break
        if selected is None:
            overflowed += 1
            ratio = float("nan")
        else:
            class_counts[selected] += 1
            ratio = selected / actual if actual > 0 else 0.0
            ratios.append(ratio)
        rows.append(
            {
                "trace_index": idx,
                "actual_work_size": actual,
                "selected_capacity": selected or 0,
                "class_capacity_actual_ratio": ratio,
                "class_overflowed": int(selected is None),
            }
        )
    return rows, {
        "classes": list(classes),
        "class_counts": class_counts,
        "overflow_count": overflowed,
        "overflow_rate": overflowed / len(actual_sizes) if actual_sizes else 0.0,
        "ratio_summary": summarize(ratios),
    }


def main():
    parser = argparse.ArgumentParser(description="Plan fixed-grid capacity classes from real trace metadata")
    parser.add_argument("--trace", type=Path, nargs="+", required=True, help="CSV, JSONL, NPZ, PT, or PTH trace file(s)")
    parser.add_argument("--chunk-tokens", type=int, default=32)
    parser.add_argument("--num-transforms", type=int, default=8)
    parser.add_argument("--max-neighbors", type=int, default=None)
    parser.add_argument(
        "--actual-scale",
        type=float,
        default=1.0,
        help=(
            "multiply computed actual_work_size before planning capacity classes; "
            "useful for fused decode mappings that split each KV chunk across Q-head/transform chunks"
        ),
    )
    parser.add_argument("--capacity-round", type=int, default=64)
    parser.add_argument("--class-plan", choices=("ratio", "quantile"), default="ratio")
    parser.add_argument("--num-classes", type=int, default=4)
    parser.add_argument("--max-class-points", type=int, default=2048)
    parser.add_argument("--class-quantiles", nargs="+", default=("0.50", "0.90", "0.99", "1.0"))
    parser.add_argument("--manual-capacities", nargs="+", default=None)
    parser.add_argument(
        "--output",
        type=Path,
        default=THIS_DIR / "prof" / "real_trace_capacity_plan.csv",
    )
    parser.add_argument(
        "--summary-output",
        type=Path,
        default=THIS_DIR / "prof" / "real_trace_capacity_plan.json",
    )
    args = parser.parse_args()

    records = []
    for trace_path in args.trace:
        records.extend(load_traces(trace_path, args.num_transforms))
    if not records:
        raise RuntimeError(f"no trace records loaded from {args.trace}")

    per_trace_rows = []
    actual_sizes = []
    static_ratios = []
    for idx, record in enumerate(records):
        raw_actual = compute_actual_work(record, args.chunk_tokens, args.num_transforms)
        actual = int(math.ceil(raw_actual * args.actual_scale))
        capacity = static_max_capacity(record, args.chunk_tokens, args.num_transforms, args.max_neighbors)
        if capacity is not None:
            capacity = int(math.ceil(capacity * args.actual_scale))
        ratio = capacity / actual if capacity and actual > 0 else float("nan")
        actual_sizes.append(actual)
        if not math.isnan(ratio):
            static_ratios.append(ratio)
        per_trace_rows.append(
            {
                "trace_index": idx,
                "trace_id": record.trace_id,
                "tasks": len(record.counts) if record.counts is not None else 0,
                "num_transforms": record.num_transforms or args.num_transforms,
                "chunk_tokens": args.chunk_tokens,
                "total_edges": sum(record.counts) if record.counts is not None else 0,
                "max_count": max(record.counts) if record.counts else 0,
                "raw_actual_work_size": raw_actual,
                "actual_work_size": actual,
                "static_max_capacity": capacity or 0,
                "static_capacity_actual_ratio": ratio,
            }
        )

    if args.manual_capacities:
        classes = sorted(set(round_up(value, args.capacity_round) for value in parse_int_list(args.manual_capacities)))
    elif args.class_plan == "ratio":
        classes = choose_ratio_classes(
            actual_sizes, args.num_classes, args.capacity_round, args.max_class_points
        )
    else:
        quantiles = parse_float_list(args.class_quantiles)
        classes = choose_quantile_classes(actual_sizes, quantiles, args.capacity_round)

    class_rows, class_summary = evaluate_classes(actual_sizes, classes)
    for row, class_row in zip(per_trace_rows, class_rows):
        row.update(
            {
                "selected_capacity": class_row["selected_capacity"],
                "class_capacity_actual_ratio": class_row["class_capacity_actual_ratio"],
                "class_overflowed": class_row["class_overflowed"],
            }
        )

    summary = {
        "trace": [str(trace_path) for trace_path in args.trace],
        "records": len(records),
        "chunk_tokens": args.chunk_tokens,
        "num_transforms_default": args.num_transforms,
        "actual_scale": args.actual_scale,
        "capacity_round": args.capacity_round,
        "class_plan": args.class_plan,
        "num_classes": args.num_classes,
        "max_class_points": args.max_class_points,
        "actual_work_size": summarize(actual_sizes),
        "static_capacity_actual_ratio": summarize(static_ratios),
        "recommended_classes": class_summary,
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(per_trace_rows[0].keys()))
        writer.writeheader()
        writer.writerows(per_trace_rows)
    with args.summary_output.open("w") as f:
        json.dump(summary, f, indent=2, sort_keys=True)

    actual_summary = summary["actual_work_size"]
    static_summary = summary["static_capacity_actual_ratio"]
    class_ratio = class_summary["ratio_summary"]
    print(f"loaded {len(records)} traces from {', '.join(str(trace_path) for trace_path in args.trace)}")
    print(
        "actual_work_size "
        f"p50={actual_summary['p50']:.1f} p90={actual_summary['p90']:.1f} "
        f"p99={actual_summary['p99']:.1f} max={actual_summary['max']:.1f}"
    )
    if static_summary:
        print(
            "static_max_capacity/actual "
            f"p50={static_summary['p50']:.3f} p90={static_summary['p90']:.3f} "
            f"p99={static_summary['p99']:.3f} max={static_summary['max']:.3f}"
        )
    print(f"recommended_classes={classes}")
    print(
        "class_capacity/actual "
        f"p50={class_ratio.get('p50', float('nan')):.3f} "
        f"p90={class_ratio.get('p90', float('nan')):.3f} "
        f"p99={class_ratio.get('p99', float('nan')):.3f} "
        f"max={class_ratio.get('max', float('nan')):.3f} "
        f"overflow_rate={class_summary['overflow_rate']:.3%}"
    )
    print(f"wrote {args.output}")
    print(f"wrote {args.summary_output}")


if __name__ == "__main__":
    main()
