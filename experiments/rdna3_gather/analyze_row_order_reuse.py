#!/usr/bin/env python3
import argparse
import csv
import json
import math
from pathlib import Path
from typing import Iterable, List, Sequence


THIS_DIR = Path(__file__).resolve().parent
DEFAULT_TRACE_DIR = (
    THIS_DIR
    / "trace"
    / "vllm_decode_block_table_v2_strict_kvlayout_true"
    / "jsonl_flattened"
)
ROW_ORDERS = (
    "original",
    "first-page",
    "first-2-pages",
    "first-4-pages",
    "lexicographic",
    "prefix-hash-2",
    "prefix-hash-4",
    "lcp-bucket",
)


def percentile(values: Sequence[float], q: float) -> float:
    if not values:
        return float("nan")
    ordered = sorted(values)
    pos = (len(ordered) - 1) * q
    lo = int(pos)
    hi = min(lo + 1, len(ordered) - 1)
    frac = pos - lo
    return ordered[lo] * (1.0 - frac) + ordered[hi] * frac


def trace_files(paths: Iterable[Path]) -> List[Path]:
    out: List[Path] = []
    for path in paths:
        if path.is_dir():
            out.extend(sorted(path.glob("*.jsonl")))
        else:
            out.append(path)
    if not out:
        raise RuntimeError("no JSONL trace files found")
    return out


def parse_int_list(text: str) -> List[int]:
    return [int(piece) for piece in text.replace(",", " ").split() if piece]


def stable_prefix_hash(values: Sequence[int]) -> int:
    value = 1469598103934665603
    for item in values:
        value ^= int(item) & 0xFFFFFFFFFFFFFFFF
        value = (value * 1099511628211) & 0xFFFFFFFFFFFFFFFF
    return value


def layout_scope(obj, path: Path):
    layout = obj.get("kv_cache_layout") or {}
    layer = layout.get("layer", obj.get("layer_ordinal", "unknown"))
    if layout.get("k_data_ptr") is not None and layout.get("v_data_ptr") is not None:
        return ("ptr", layout.get("k_data_ptr"), layout.get("v_data_ptr"), layer)
    return ("fallback", str(path.resolve()), layer)


def load_rows(paths: Sequence[Path], chunk_tokens: int, actual_scale: float):
    scoped_ids = {}
    rows = []
    for path in trace_files(paths):
        with path.open() as f:
            for line_no, line in enumerate(f, start=1):
                if not line.strip():
                    continue
                obj = json.loads(line)
                sequences = obj.get("sequences") or []
                if len(sequences) != 1:
                    raise RuntimeError(f"{path}:{line_no}: expected one flattened sequence row")
                block_ids = sequences[0].get("block_ids")
                if block_ids is None:
                    raise RuntimeError(f"{path}:{line_no}: missing sequences[].block_ids")
                scope = layout_scope(obj, path)
                dense_pages = []
                for block_id in block_ids:
                    key = (scope, int(block_id))
                    dense_pages.append(scoped_ids.setdefault(key, len(scoped_ids)))

                seqlens = obj.get("cache_seqlens") or []
                if len(seqlens) != 1:
                    raise RuntimeError(f"{path}:{line_no}: expected one cache_seqlen")
                seqlen = int(seqlens[0])
                num_kv_heads = int(obj.get("num_kv_heads") or 1)
                actual = math.ceil(max(0, seqlen) / chunk_tokens) * num_kv_heads
                rows.append(
                    {
                        "pages": dense_pages,
                        "actual": int(math.ceil(actual * actual_scale)),
                    }
                )
    return rows


def choose_capacity(actual: int, classes: Sequence[int]) -> int:
    for capacity in classes:
        if actual <= capacity:
            return int(capacity)
    return int(classes[-1])


def prefix(values: Sequence[int], n: int):
    return tuple(values[:n])


def row_order_key(name: str, pages: Sequence[int], row: int):
    if name == "original":
        return (row,)
    if name == "first-page":
        return prefix(pages, 1)
    if name == "first-2-pages":
        return prefix(pages, 2)
    if name == "first-4-pages":
        return prefix(pages, 4)
    if name in ("lexicographic", "lcp-bucket"):
        return tuple(pages)
    if name == "prefix-hash-2":
        return (stable_prefix_hash(prefix(pages, 2)),)
    if name == "prefix-hash-4":
        return (stable_prefix_hash(prefix(pages, 4)),)
    raise RuntimeError(f"unknown row order: {name}")


def launch_order(rows, classes: Sequence[int], order_name: str) -> List[int]:
    by_capacity = {}
    for row, item in enumerate(rows):
        capacity = choose_capacity(item["actual"], classes)
        by_capacity.setdefault(capacity, []).append(row)

    ordered = []
    for capacity in sorted(by_capacity):
        group = by_capacity[capacity]
        group.sort(key=lambda row: (row_order_key(order_name, rows[row]["pages"], row), row))
        ordered.extend(group)
    return ordered


def lcp(a: Sequence[int], b: Sequence[int]) -> int:
    out = 0
    for lhs, rhs in zip(a, b):
        if lhs != rhs:
            break
        out += 1
    return out


def window_unique_stats(rows, order: Sequence[int], window: int):
    values = []
    for start in range(0, len(order), window):
        pages = set()
        for row in order[start : start + window]:
            pages.update(rows[row]["pages"])
        values.append(len(pages))
    return {
        f"unique_pages_w{window}_mean": sum(values) / len(values) if values else float("nan"),
        f"unique_pages_w{window}_p50": percentile(values, 0.50),
        f"unique_pages_w{window}_p90": percentile(values, 0.90),
    }


def reuse_distance_stats(rows, order: Sequence[int]):
    last_seen = {}
    distances = []
    refs = 0
    hits_within_32 = 0
    hits_within_128 = 0
    hits_within_512 = 0
    for row in order:
        for page in rows[row]["pages"]:
            if page in last_seen:
                dist = refs - last_seen[page]
                distances.append(dist)
                hits_within_32 += int(dist <= 32)
                hits_within_128 += int(dist <= 128)
                hits_within_512 += int(dist <= 512)
            last_seen[page] = refs
            refs += 1
    hit_count = len(distances)
    return {
        "block_refs": refs,
        "reuse_hits": hit_count,
        "reuse_hit_rate": hit_count / refs if refs else 0.0,
        "reuse_distance_p50": percentile(distances, 0.50),
        "reuse_distance_p90": percentile(distances, 0.90),
        "reuse_distance_p99": percentile(distances, 0.99),
        "reuse_distance_max": max(distances) if distances else 0,
        "reuse_hit_within_32_rate": hits_within_32 / hit_count if hit_count else 0.0,
        "reuse_hit_within_128_rate": hits_within_128 / hit_count if hit_count else 0.0,
        "reuse_hit_within_512_rate": hits_within_512 / hit_count if hit_count else 0.0,
    }


def summarize_order(rows, order: Sequence[int], order_name: str):
    lcps = [lcp(rows[a]["pages"], rows[b]["pages"]) for a, b in zip(order, order[1:])]
    out = {
        "row_order": order_name,
        "rows": len(order),
        "adjacent_lcp_mean": sum(lcps) / len(lcps) if lcps else 0.0,
        "adjacent_lcp_p50": percentile(lcps, 0.50),
        "adjacent_lcp_p90": percentile(lcps, 0.90),
        "adjacent_lcp_max": max(lcps) if lcps else 0,
        "adjacent_lcp_ge1_rate": sum(1 for value in lcps if value >= 1) / len(lcps)
        if lcps
        else 0.0,
        "adjacent_lcp_ge2_rate": sum(1 for value in lcps if value >= 2) / len(lcps)
        if lcps
        else 0.0,
    }
    for window in (32, 128, 512):
        out.update(window_unique_stats(rows, order, window))
    out.update(reuse_distance_stats(rows, order))
    return out


def main():
    parser = argparse.ArgumentParser(description="Analyze locality reuse under row-order policies")
    parser.add_argument("--trace", type=Path, nargs="+", default=[DEFAULT_TRACE_DIR])
    parser.add_argument("--classes", default="8,12,20,36,68,132")
    parser.add_argument("--chunk-tokens", type=int, default=32)
    parser.add_argument("--actual-scale", type=float, default=1.0)
    parser.add_argument("--row-orders", nargs="+", default=list(ROW_ORDERS), choices=ROW_ORDERS)
    parser.add_argument("--output", type=Path, default=THIS_DIR / "prof" / "strict_trace_row_order_reuse.csv")
    args = parser.parse_args()

    classes = sorted(parse_int_list(args.classes))
    rows = load_rows(args.trace, args.chunk_tokens, args.actual_scale)
    summaries = []
    for order_name in args.row_orders:
        order = launch_order(rows, classes, order_name)
        summaries.append(summarize_order(rows, order, order_name))

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(summaries[0].keys()))
        writer.writeheader()
        writer.writerows(summaries)

    print(f"loaded rows={len(rows)} wrote {args.output}")
    for row in summaries:
        print(
            "{row_order}: lcp_mean={adjacent_lcp_mean:.3f} "
            "reuse_p50={reuse_distance_p50:.1f} unique_w128_p50={unique_pages_w128_p50:.1f}".format(
                **row
            )
        )


if __name__ == "__main__":
    main()
