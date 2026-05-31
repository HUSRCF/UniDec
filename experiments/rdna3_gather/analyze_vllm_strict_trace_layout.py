#!/usr/bin/env python3
import argparse
import csv
import json
from collections import Counter, defaultdict
from pathlib import Path
from typing import Iterable, List


THIS_DIR = Path(__file__).resolve().parent
DEFAULT_TRACE_DIR = (
    THIS_DIR
    / "trace"
    / "vllm_decode_block_table_v2_strict_kvlayout_true"
    / "jsonl_flattened"
)


def percentile(values: List[int], q: float) -> float:
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


def layout_signature(layout):
    return (
        tuple(layout.get("k_shape") or []),
        tuple(layout.get("k_stride") or []),
        tuple(layout.get("v_shape") or []),
        tuple(layout.get("v_stride") or []),
        layout.get("k_dtype"),
        layout.get("v_dtype"),
        layout.get("k_element_size"),
        layout.get("v_element_size"),
    )


def main():
    parser = argparse.ArgumentParser(description="Analyze strict vLLM paged-KV trace locality/layout")
    parser.add_argument("--trace", type=Path, nargs="+", default=[DEFAULT_TRACE_DIR])
    parser.add_argument("--output", type=Path, default=THIS_DIR / "prof" / "strict_trace_layout_summary.csv")
    parser.add_argument(
        "--summary-output",
        type=Path,
        default=THIS_DIR / "prof" / "strict_trace_layout_summary.json",
    )
    parser.add_argument(
        "--assert-layout-scoped-remap",
        action="store_true",
        help=(
            "fail if the trace has multiple KV layouts but scoped block IDs do not expand "
            "beyond raw numeric block IDs; use this as a regression guard against naked "
            "numeric block_id reuse analysis"
        ),
    )
    args = parser.parse_args()

    by_prompt = {}
    layout_sigs = Counter()
    layer_counts = Counter()
    block_counts = Counter()
    scoped_block_counts = Counter()
    page_position_counts = defaultdict(Counter)
    block_stride_bytes = Counter()
    ptr_pairs_by_layer = defaultdict(set)
    total_rows = 0

    for path in trace_files(args.trace):
        with path.open() as f:
            for line_no, line in enumerate(f, start=1):
                if not line.strip():
                    continue
                obj = json.loads(line)
                sequences = obj.get("sequences") or []
                if len(sequences) != 1:
                    raise RuntimeError(
                        f"{path}:{line_no}: expected one sequence per flattened row, got {len(sequences)}"
                    )

                prompt_len = int(obj.get("prompt_len") or obj.get("prompt_lens", [0])[0])
                stats = by_prompt.setdefault(
                    prompt_len,
                    {
                        "rows": 0,
                        "samples": set(),
                        "layers": set(),
                        "decode_steps": set(),
                        "block_refs": 0,
                        "blocks": Counter(),
                        "valid_counts": [],
                    },
                )
                stats["rows"] += 1
                total_rows += 1
                if obj.get("sample_idx") is not None:
                    stats["samples"].add(int(obj["sample_idx"]))
                layer = obj.get("layer_ordinal")
                layout = obj.get("kv_cache_layout") or {}
                if layer is None:
                    layer = layout.get("layer")
                if layer is not None:
                    layer = int(layer)
                    stats["layers"].add(layer)
                    layer_counts[layer] += 1
                    if layout.get("k_data_ptr") is not None:
                        ptr_pairs_by_layer[layer].add((layout.get("k_data_ptr"), layout.get("v_data_ptr")))
                if obj.get("decode_step") is not None:
                    stats["decode_steps"].add(int(obj["decode_step"]))

                sig = layout_signature(layout)
                layout_sigs[sig] += 1
                k_stride = layout.get("k_stride") or []
                elem_size = layout.get("k_element_size")
                if k_stride and elem_size:
                    block_stride_bytes[int(k_stride[0]) * int(elem_size)] += 1

                if layout.get("k_data_ptr") is not None and layout.get("v_data_ptr") is not None:
                    block_scope = (
                        "ptr",
                        layout.get("k_data_ptr"),
                        layout.get("v_data_ptr"),
                        layout.get("layer", layer),
                    )
                else:
                    block_scope = ("fallback", str(path), layer)

                block_ids = [int(x) for x in (sequences[0].get("block_ids") or [])]
                stats["valid_counts"].append(len(block_ids))
                for pos, block_id in enumerate(block_ids):
                    stats["block_refs"] += 1
                    stats["blocks"][block_id] += 1
                    block_counts[block_id] += 1
                    scoped_block_counts[(block_scope, block_id)] += 1
                    page_position_counts[pos][block_id] += 1

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="") as f:
        fieldnames = [
            "prompt_len",
            "rows",
            "samples",
            "layers",
            "decode_steps",
            "block_refs",
            "unique_blocks",
            "block_reuse_ratio",
            "valid_blocks_min",
            "valid_blocks_p50",
            "valid_blocks_p90",
            "valid_blocks_max",
            "top_blocks",
        ]
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for prompt_len, stats in sorted(by_prompt.items()):
            refs = int(stats["block_refs"])
            unique_blocks = len(stats["blocks"])
            valid_counts = stats["valid_counts"]
            writer.writerow(
                {
                    "prompt_len": prompt_len,
                    "rows": stats["rows"],
                    "samples": len(stats["samples"]),
                    "layers": len(stats["layers"]),
                    "decode_steps": len(stats["decode_steps"]),
                    "block_refs": refs,
                    "unique_blocks": unique_blocks,
                    "block_reuse_ratio": 1.0 - unique_blocks / refs if refs else 0.0,
                    "valid_blocks_min": min(valid_counts) if valid_counts else 0,
                    "valid_blocks_p50": percentile(valid_counts, 0.50),
                    "valid_blocks_p90": percentile(valid_counts, 0.90),
                    "valid_blocks_max": max(valid_counts) if valid_counts else 0,
                    "top_blocks": ";".join(
                        f"{block_id}:{count}" for block_id, count in stats["blocks"].most_common(8)
                    ),
                }
            )

    summary = {
        "total_rows": total_rows,
        "total_unique_blocks": len(block_counts),
        "total_unique_scoped_blocks": len(scoped_block_counts),
        "total_block_refs": sum(block_counts.values()),
        "global_block_reuse_ratio": (
            1.0 - len(block_counts) / sum(block_counts.values()) if block_counts else 0.0
        ),
        "global_scoped_block_reuse_ratio": (
            1.0 - len(scoped_block_counts) / sum(scoped_block_counts.values())
            if scoped_block_counts
            else 0.0
        ),
        "layout_signature_count": len(layout_sigs),
        "layout_signatures": [
            {
                "count": count,
                "k_shape": list(sig[0]),
                "k_stride": list(sig[1]),
                "v_shape": list(sig[2]),
                "v_stride": list(sig[3]),
                "k_dtype": sig[4],
                "v_dtype": sig[5],
                "k_element_size": sig[6],
                "v_element_size": sig[7],
            }
            for sig, count in layout_sigs.most_common()
        ],
        "layer_count": len(layer_counts),
        "layer_rows_min": min(layer_counts.values()) if layer_counts else 0,
        "layer_rows_max": max(layer_counts.values()) if layer_counts else 0,
        "kv_pointer_pairs_per_layer_min": min(len(v) for v in ptr_pairs_by_layer.values())
        if ptr_pairs_by_layer
        else 0,
        "kv_pointer_pairs_per_layer_max": max(len(v) for v in ptr_pairs_by_layer.values())
        if ptr_pairs_by_layer
        else 0,
        "k_block_stride_bytes": [
            {"bytes": stride, "count": count} for stride, count in block_stride_bytes.most_common()
        ],
        "page_position_summary": {
            str(pos): {
                "unique_blocks": len(counter),
                "top_blocks": [
                    {"block_id": block_id, "count": count}
                    for block_id, count in counter.most_common(8)
                ],
            }
            for pos, counter in sorted(page_position_counts.items())
        },
    }
    with args.summary_output.open("w") as f:
        json.dump(summary, f, indent=2, sort_keys=True)
        f.write("\n")

    if args.assert_layout_scoped_remap:
        if summary["layout_signature_count"] <= 1 and summary["layer_count"] <= 1:
            raise RuntimeError("layout-scoped remap assertion requires multiple layouts or layers")
        if summary["total_unique_scoped_blocks"] <= summary["total_unique_blocks"]:
            raise RuntimeError(
                "layout-scoped unique block count did not exceed raw numeric block count; "
                "this trace may be missing layout scope or the analyzer regressed"
            )

    print(f"wrote {args.output}")
    print(f"wrote {args.summary_output}")
    print(
        "rows={rows} unique_blocks={blocks} layout_sigs={sigs} reuse={reuse:.6f}".format(
            rows=summary["total_rows"],
            blocks=summary["total_unique_scoped_blocks"],
            sigs=summary["layout_signature_count"],
            reuse=summary["global_scoped_block_reuse_ratio"],
        )
    )


if __name__ == "__main__":
    main()
