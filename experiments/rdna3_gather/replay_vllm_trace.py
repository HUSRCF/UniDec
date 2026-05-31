#!/usr/bin/env python3
import argparse
import csv
import json
import math
import os
import statistics
import time
from pathlib import Path
from types import SimpleNamespace
from typing import Dict, Iterable, List, Sequence, Tuple

import torch

import test_gather as tg
import trace_capacity_plan as tcp


THIS_DIR = Path(__file__).resolve().parent
DEFAULT_TRACE_DIR = (
    THIS_DIR
    / "trace"
    / "vllm_decode_block_table_v2_strict_kvlayout_true"
    / "jsonl_flattened"
)

ROW_ORDER_CHOICES = (
    "original",
    "first-page",
    "auto-first-page",
    "first-2-pages",
    "first-4-pages",
    "lexicographic",
    "prefix-hash-2",
    "prefix-hash-4",
    "lcp-bucket",
)


def parse_int_list(values: Iterable[str]) -> List[int]:
    out = []
    for value in values:
        for piece in str(value).split(","):
            if piece:
                out.append(int(float(piece)))
    return out


def default_trace_files() -> List[Path]:
    return [
        DEFAULT_TRACE_DIR / f"dolly_plen{prompt_len}_gen64_gpu0.flat.jsonl"
        for prompt_len in (64, 128, 256, 512, 1024, 2048)
    ]


def expand_trace_inputs(paths: Sequence[Path]) -> List[Path]:
    files: List[Path] = []
    for path in paths:
        if path.is_dir():
            files.extend(sorted(path.glob("*.jsonl")))
        else:
            files.append(path)
    if not files:
        raise RuntimeError("no JSONL trace files found")
    return files


def load_trace_metadata(trace_files: Sequence[Path], actual_scale: float, chunk_tokens: int):
    actual_sizes = []
    cache_seqlens = []
    block_id_rows = []
    block_id_scopes = []
    page_block_sizes = []
    num_kv_heads = None
    num_q_heads = None
    head_dim = None
    kv_dtype = None

    for trace_file in trace_files:
        if trace_file.suffix == ".jsonl":
            with trace_file.open() as f:
                for line in f:
                    if not line.strip():
                        continue
                    obj = json.loads(line)
                    records = [tcp.as_record(obj, obj.get("trace_id", "trace"), 1)]
                    record = records[0]
                    seqlens = obj.get("cache_seqlens") or record.counts
                    if not seqlens:
                        raise RuntimeError(f"missing cache_seqlens in {trace_file}")
                    if len(seqlens) != 1:
                        raise RuntimeError(
                            "paged replay currently expects one sequence per trace row; "
                            "use the strict trace jsonl_flattened/ files instead of batched jsonl/"
                        )

                    row_kv_heads = int(obj.get("num_kv_heads") or record.num_transforms or num_kv_heads or 1)
                    # vLLM trace rows may carry actual_work_size generated for the capture-time
                    # chunk size. Recompute from cache_seqlen so tile/chunk sweeps stay coherent.
                    actual = sum(math.ceil(max(0, int(seqlen)) / chunk_tokens) for seqlen in seqlens)
                    actual *= row_kv_heads
                    actual_sizes.append(int(math.ceil(actual * actual_scale)))
                    cache_seqlens.append(int(seqlens[0]))

                    layout = obj.get("kv_cache_layout") or {}
                    row_block_ids = None
                    sequences = obj.get("sequences") or []
                    if sequences:
                        if len(sequences) != 1:
                            raise RuntimeError("paged replay currently expects one sequence per trace row")
                        raw_block_ids = sequences[0].get("block_ids")
                        if raw_block_ids is not None:
                            row_block_ids = [int(x) for x in raw_block_ids]
                    block_id_rows.append(row_block_ids)
                    if layout.get("k_data_ptr") is not None and layout.get("v_data_ptr") is not None:
                        layer_scope = layout.get("layer", obj.get("layer_ordinal", "unknown"))
                        block_id_scopes.append(
                            f"ptr:{layout.get('k_data_ptr')}:{layout.get('v_data_ptr')}:{layer_scope}"
                        )
                    else:
                        block_id_scopes.append(
                            f"file:{trace_file.resolve()}:{obj.get('layer_ordinal', 'unknown')}"
                        )

                    page_block_sizes.append(int(obj.get("block_size_tokens") or obj.get("page_block_size") or chunk_tokens))
                    num_kv_heads = row_kv_heads
                    num_q_heads = int(obj.get("num_q_heads") or num_q_heads or num_kv_heads)
                    head_dim = int(obj.get("head_dim") or head_dim or 256)
                    layout_dtype = layout.get("k_dtype") or layout.get("v_dtype")
                    kv_dtype = str(layout_dtype or obj.get("kv_dtype") or kv_dtype or "unknown")
        else:
            records = tcp.load_traces(trace_file, default_num_transforms=1)
            for record in records:
                actual = tcp.compute_actual_work(record, chunk_tokens=chunk_tokens, default_num_transforms=1)
                actual_sizes.append(int(math.ceil(actual * actual_scale)))
                counts = record.counts or [max(chunk_tokens, actual)]
                if len(counts) != 1:
                    raise RuntimeError("paged replay fallback expects one sequence per trace row")
                cache_seqlens.append(int(counts[0]))
                block_id_rows.append(None)
                block_id_scopes.append(f"file:{trace_file.resolve()}:fallback")
                page_block_sizes.append(chunk_tokens)
                num_kv_heads = int(record.num_transforms or num_kv_heads or 1)
                num_q_heads = int(num_q_heads or num_kv_heads)
                head_dim = int(head_dim or 256)
                kv_dtype = str(kv_dtype or "unknown")

    if not actual_sizes:
        raise RuntimeError("no actual_work_size rows loaded")
    if len(set(page_block_sizes)) != 1:
        raise RuntimeError(f"mixed page_block_size values are not supported: {sorted(set(page_block_sizes))}")
    return SimpleNamespace(
        actual_sizes=actual_sizes,
        cache_seqlens=cache_seqlens,
        block_id_rows=block_id_rows,
        block_id_scopes=block_id_scopes,
        page_block_size=page_block_sizes[0],
        num_kv_heads=int(num_kv_heads or 1),
        num_q_heads=int(num_q_heads or num_kv_heads or 1),
        head_dim=int(head_dim or 256),
        kv_dtype=kv_dtype,
    )


def load_actual_sizes(trace_files: Sequence[Path], actual_scale: float) -> List[int]:
    return load_trace_metadata(trace_files, actual_scale, 32).actual_sizes


def trim_trace_meta(trace_meta, limit: int):
    if limit is None or limit <= 0:
        return trace_meta
    trace_meta.actual_sizes = trace_meta.actual_sizes[:limit]
    trace_meta.cache_seqlens = trace_meta.cache_seqlens[:limit]
    trace_meta.block_id_rows = trace_meta.block_id_rows[:limit]
    trace_meta.block_id_scopes = trace_meta.block_id_scopes[:limit]
    return trace_meta


def choose_capacities(actual_sizes: Sequence[int], classes: Sequence[int]) -> Tuple[List[int], int]:
    capacities = []
    overflow = 0
    ordered = sorted(classes)
    for actual in actual_sizes:
        selected = None
        for capacity in ordered:
            if actual <= capacity:
                selected = capacity
                break
        if selected is None:
            overflow += 1
            selected = ordered[-1]
        capacities.append(selected)
    return capacities, overflow


def ratio_summary(actual_sizes: Sequence[int], capacities: Sequence[int]):
    ratios = [capacity / actual for actual, capacity in zip(actual_sizes, capacities)]
    return {
        "p50": tcp.percentile(ratios, 0.50),
        "p90": tcp.percentile(ratios, 0.90),
        "p99": tcp.percentile(ratios, 0.99),
        "max": max(ratios),
    }


def make_fused_groups(actual_sizes: Sequence[int], capacities: Sequence[int], order_key: Sequence[object] = None):
    grouped: Dict[int, List[Tuple[int, int]]] = {}
    for row, (actual, capacity) in enumerate(zip(actual_sizes, capacities)):
        grouped.setdefault(int(capacity), []).append((int(row), int(actual)))
    if order_key is not None:
        for capacity, values in grouped.items():
            values.sort(key=lambda item: (order_key[item[0]], item[0]))
    return [(capacity, grouped[capacity]) for capacity in sorted(grouped)]


def materialize_fused_groups(groups):
    out = []
    for capacity, values in groups:
        row_ids = [row for row, _actual in values]
        actuals = [actual for _row, actual in values]
        out.append(
            (
                capacity,
                torch.tensor(actuals, dtype=torch.int32, device="cuda"),
                torch.tensor(row_ids, dtype=torch.int32, device="cuda"),
            )
        )
    return out


def run_fused_self_cull(ext, device_anchor, fused_groups, work_iters: int):
    out = None
    for capacity, actual_gpu, _row_gpu in fused_groups:
        out = ext.replay_self_cull_fused(device_anchor, actual_gpu, capacity, work_iters)
    return out


def run_fused_gather_dot(ext, features, transforms, fused_groups, chunk_tokens: int):
    out = None
    for capacity, actual_gpu, _row_gpu in fused_groups:
        out = ext.replay_gather_dot_fused(features, transforms, actual_gpu, capacity, chunk_tokens)
    return out


def run_fused_paged_dot(ext, paged_state, fused_groups, chunk_tokens: int):
    out = None
    for capacity, actual_gpu, row_gpu in fused_groups:
        out = ext.replay_paged_kv_dot_fused(
            paged_state.k_pool,
            paged_state.q_transforms,
            actual_gpu,
            row_gpu,
            paged_state.cache_seqlens,
            paged_state.block_tables,
            capacity,
            chunk_tokens,
        )
    return out


def run_fused_paged_attn(ext, paged_state, fused_groups, chunk_tokens: int):
    out = None
    for capacity, actual_gpu, row_gpu in fused_groups:
        out = ext.replay_paged_kv_attn_fused(
            paged_state.k_pool,
            paged_state.v_pool,
            paged_state.q_transforms,
            paged_state.v_transforms,
            actual_gpu,
            row_gpu,
            paged_state.cache_seqlens,
            paged_state.block_tables,
            capacity,
            chunk_tokens,
        )
    return out


def make_full_workspace(paged_state, chunk_tokens: int, value_dim: int):
    setup_start = time.perf_counter()
    value_dim = int(value_dim)
    if value_dim <= 0:
        raise RuntimeError("--value-dim must be positive")
    if value_dim > paged_state.dim:
        raise RuntimeError(f"--value-dim={value_dim} exceeds dim={paged_state.dim}")
    max_chunks = max(max(1, math.ceil(seqlen / chunk_tokens)) for seqlen in paged_state.cache_seqlens_cpu)
    num_rows = len(paged_state.cache_seqlens_cpu)
    num_work_heads = paged_state.num_work_heads
    chunk_m = torch.empty((num_rows, num_work_heads, max_chunks), device="cuda", dtype=torch.float32)
    chunk_l = torch.empty_like(chunk_m)
    chunk_acc = torch.empty(
        (num_rows, num_work_heads, max_chunks, value_dim), device="cuda", dtype=torch.float32
    )
    output = torch.empty((num_rows, num_work_heads, value_dim), device="cuda", dtype=torch.float32)
    ml_output = torch.empty((num_rows, num_work_heads, 2), device="cuda", dtype=torch.float32)
    torch.cuda.synchronize()
    setup_ms = (time.perf_counter() - setup_start) * 1.0e3
    return SimpleNamespace(
        chunk_m=chunk_m,
        chunk_l=chunk_l,
        chunk_acc=chunk_acc,
        output=output,
        ml_output=ml_output,
        value_dim=value_dim,
        max_chunks=max_chunks,
        setup_ms=setup_ms,
    )


def run_fused_paged_full_producer(ext, paged_state, workspace, fused_groups, chunk_tokens: int):
    for capacity, actual_gpu, row_gpu in fused_groups:
        ext.replay_paged_kv_chunk_workspace(
            paged_state.k_pool,
            paged_state.v_pool,
            paged_state.q_transforms,
            actual_gpu,
            row_gpu,
            paged_state.cache_seqlens,
            paged_state.block_tables,
            workspace.chunk_m,
            workspace.chunk_l,
            workspace.chunk_acc,
            capacity,
            chunk_tokens,
        )
    return workspace.chunk_acc


def run_fused_paged_full_reduce(ext, paged_state, workspace, chunk_tokens: int):
    ext.replay_paged_kv_reduce_workspace(
        workspace.chunk_m,
        workspace.chunk_l,
        workspace.chunk_acc,
        paged_state.cache_seqlens,
        workspace.output,
        chunk_tokens,
    )
    return workspace.output


def run_fused_paged_full_reduce_ml(ext, paged_state, workspace, chunk_tokens: int):
    ext.replay_paged_kv_reduce_ml_workspace(
        workspace.chunk_m,
        workspace.chunk_l,
        paged_state.cache_seqlens,
        workspace.ml_output,
        chunk_tokens,
    )
    return workspace.ml_output


def run_fused_paged_full(ext, paged_state, workspace, fused_groups, chunk_tokens: int):
    run_fused_paged_full_producer(ext, paged_state, workspace, fused_groups, chunk_tokens)
    return run_fused_paged_full_reduce(ext, paged_state, workspace, chunk_tokens)


def prefill_full_workspace(ext, paged_state, workspace, fused_groups, chunk_tokens: int):
    run_fused_paged_full_producer(ext, paged_state, workspace, fused_groups, chunk_tokens)
    torch.cuda.synchronize()
    return workspace


def make_paged_state(trace_meta, args, dtype):
    setup_start = time.perf_counter()
    page_block_size = int(args.kv_page_tokens or trace_meta.page_block_size)
    if page_block_size <= 0:
        raise RuntimeError("page block size must be positive")
    use_trace_blocks = args.page_locality == "trace"
    if use_trace_blocks and args.kv_page_tokens and int(args.kv_page_tokens) != int(trace_meta.page_block_size):
        raise RuntimeError(
            "--page-locality trace requires the trace block_size_tokens; do not override --kv-page-tokens"
        )
    if use_trace_blocks and not any(row is not None for row in trace_meta.block_id_rows):
        raise RuntimeError("--page-locality trace requested, but trace rows do not contain sequences[].block_ids")
    max_pages_per_seq = max(max(1, math.ceil(seqlen / page_block_size)) for seqlen in trace_meta.cache_seqlens)
    num_rows = len(trace_meta.cache_seqlens)
    block_table = torch.empty((num_rows, max_pages_per_seq), dtype=torch.int32)
    block_table.fill_(-1)

    kv_pages = int(args.kv_pages)
    if kv_pages <= 0:
        raise RuntimeError("--kv-pages must be positive")
    trace_page_ids = {}
    for row, seqlen in enumerate(trace_meta.cache_seqlens):
        pages = max(1, math.ceil(seqlen / page_block_size))
        for page in range(pages):
            if use_trace_blocks:
                block_ids = trace_meta.block_id_rows[row]
                if block_ids is None or len(block_ids) != pages:
                    raise RuntimeError(
                        f"trace block_ids length mismatch at row={row}: "
                        f"got {0 if block_ids is None else len(block_ids)} expected {pages}"
                    )
                scope = trace_meta.block_id_scopes[row]
                key = (scope, int(block_ids[page]))
                phys = trace_page_ids.setdefault(key, len(trace_page_ids))
            elif args.page_locality == "contiguous":
                phys = row * max_pages_per_seq + page
            elif args.page_locality == "page-cross":
                phys = page * num_rows + row
            elif args.page_locality == "hot-page" and page < args.hot_pages:
                phys = page
            else:
                phys = (row * 1103515245 + page * 12345 + args.seed) & 0x7FFFFFFF
            block_table[row, page] = phys % kv_pages
    if use_trace_blocks and len(trace_page_ids) > kv_pages:
        kv_pages = len(trace_page_ids)
        for row, seqlen in enumerate(trace_meta.cache_seqlens):
            pages = max(1, math.ceil(seqlen / page_block_size))
            for page in range(pages):
                block_ids = trace_meta.block_id_rows[row]
                scope = trace_meta.block_id_scopes[row]
                block_table[row, page] = trace_page_ids[(scope, int(block_ids[page]))]

    num_kv_heads = int(args.kv_heads or trace_meta.num_kv_heads)
    if args.work_heads is not None:
        num_work_heads = int(args.work_heads)
    else:
        scaled = num_kv_heads * args.actual_scale
        num_work_heads = max(1, int(round(scaled)))
    if num_work_heads <= 0 or num_kv_heads <= 0:
        raise RuntimeError("work heads and kv heads must be positive")

    dim = int(args.dim or trace_meta.head_dim)
    k_pool = torch.randn(kv_pages, num_kv_heads, page_block_size, dim, device="cuda", dtype=dtype)
    v_pool = torch.randn(kv_pages, num_kv_heads, page_block_size, dim, device="cuda", dtype=dtype)
    q_transforms = torch.randn(num_work_heads, dim, device="cuda", dtype=dtype)
    v_transforms = torch.randn(num_work_heads, dim, device="cuda", dtype=dtype)
    cache_seqlens = torch.tensor(trace_meta.cache_seqlens, dtype=torch.int32, device="cuda")
    block_tables = block_table.to(device="cuda", non_blocking=False)
    torch.cuda.synchronize()
    setup_ms = (time.perf_counter() - setup_start) * 1.0e3
    return SimpleNamespace(
        k_pool=k_pool,
        v_pool=v_pool,
        kv_pool=k_pool,
        transforms=q_transforms,
        q_transforms=q_transforms,
        v_transforms=v_transforms,
        cache_seqlens=cache_seqlens,
        block_tables=block_tables,
        block_table_cpu=block_table,
        cache_seqlens_cpu=list(trace_meta.cache_seqlens),
        setup_ms=setup_ms,
        page_block_size=page_block_size,
        max_pages_per_seq=max_pages_per_seq,
        num_kv_heads=num_kv_heads,
        num_work_heads=num_work_heads,
        dim=dim,
        kv_pages=kv_pages,
        page_locality=args.page_locality,
    )


def stable_prefix_hash(values: Sequence[int]) -> int:
    # FNV-1a over signed page ids, kept deterministic across Python processes.
    value = 1469598103934665603
    for item in values:
        value ^= int(item) & 0xFFFFFFFFFFFFFFFF
        value = (value * 1099511628211) & 0xFFFFFFFFFFFFFFFF
    return value


def percentile_float(values: Sequence[float], q: float) -> float:
    if not values:
        return 0.0
    ordered = sorted(values)
    pos = q * (len(ordered) - 1)
    lo = int(pos)
    hi = min(lo + 1, len(ordered) - 1)
    frac = pos - lo
    return ordered[lo] * (1.0 - frac) + ordered[hi] * frac


def row_order_reuse_predictor(paged_state, num_rows: int, window: int = 128):
    if paged_state is None or num_rows <= 0:
        return {
            "first_page_unique": num_rows,
            "first_page_unique_ratio": 1.0,
            "adjacent_first_page_hit_ratio": 0.0,
            "first_page_unique_w128_p50": float(window),
            "first_page_unique_w128_ratio_p50": 1.0,
            "adjacent_lcp_mean": 0.0,
        }
    first_pages = [int(x) for x in paged_state.block_table_cpu[:, 0].tolist()]
    unique_first_pages = len(set(first_pages))
    adjacent_hits = sum(1 for lhs, rhs in zip(first_pages, first_pages[1:]) if lhs == rhs)
    window_unique = [
        len(set(first_pages[start : start + window])) for start in range(0, len(first_pages), window)
    ]
    table = paged_state.block_table_cpu.tolist()
    lcp_total = 0
    for prev, cur in zip(table, table[1:]):
        lcp = 0
        for lhs, rhs in zip(prev, cur):
            if int(lhs) != int(rhs):
                break
            lcp += 1
        lcp_total += lcp
    window_p50 = percentile_float(window_unique, 0.50)
    return {
        "first_page_unique": unique_first_pages,
        "first_page_unique_ratio": unique_first_pages / num_rows if num_rows else 1.0,
        "adjacent_first_page_hit_ratio": adjacent_hits / (num_rows - 1) if num_rows > 1 else 0.0,
        "first_page_unique_w128_p50": window_p50,
        "first_page_unique_w128_ratio_p50": window_p50 / float(window),
        "adjacent_lcp_mean": lcp_total / (num_rows - 1) if num_rows > 1 else 0.0,
    }


def resolve_row_order(row_order: str, predictor: Dict[str, float], args) -> str:
    if row_order != "auto-first-page":
        return row_order
    if predictor["first_page_unique"] < args.auto_first_page_min_rows:
        return "original"
    if (
        predictor["first_page_unique_ratio"] <= args.auto_first_page_max_unique_ratio
        or predictor["first_page_unique_w128_ratio_p50"]
        <= args.auto_first_page_max_window128_unique_ratio
        or predictor["adjacent_first_page_hit_ratio"] >= args.auto_first_page_min_adjacent_hit
        or predictor["adjacent_lcp_mean"] >= args.auto_first_page_min_lcp_mean
        or predictor["first_page_unique_w128_p50"] <= args.auto_first_page_max_window128_unique
    ):
        return "first-page"
    return "original"


def make_row_order_key(row_order: str, paged_state, num_rows: int):
    if row_order == "original" or paged_state is None:
        return list(range(num_rows))

    table = paged_state.block_table_cpu.tolist()

    def prefix(row: int, n: int):
        return tuple(int(x) for x in table[row][:n])

    if row_order == "first-page":
        return [prefix(row, 1) for row in range(num_rows)]
    if row_order == "first-2-pages":
        return [prefix(row, 2) for row in range(num_rows)]
    if row_order == "first-4-pages":
        return [prefix(row, 4) for row in range(num_rows)]
    if row_order in ("lexicographic", "lcp-bucket"):
        return [tuple(int(x) for x in table[row]) for row in range(num_rows)]
    if row_order == "prefix-hash-2":
        return [(stable_prefix_hash(prefix(row, 2)),) for row in range(num_rows)]
    if row_order == "prefix-hash-4":
        return [(stable_prefix_hash(prefix(row, 4)),) for row in range(num_rows)]
    raise RuntimeError(f"unsupported row order: {row_order}")


def check_paged_attn(ext, paged_state, actual_sizes, chunk_tokens: int, check_rows: int, check_slots: int):
    rows = min(check_rows, len(actual_sizes))
    actual_subset = [int(x) for x in actual_sizes[:rows]]
    capacity = max(actual_subset)
    actual_gpu = torch.tensor(actual_subset, dtype=torch.int32, device="cuda")
    row_gpu = torch.arange(rows, dtype=torch.int32, device="cuda")
    out = ext.replay_paged_kv_attn_fused(
        paged_state.k_pool,
        paged_state.v_pool,
        paged_state.q_transforms,
        paged_state.v_transforms,
        actual_gpu,
        row_gpu,
        paged_state.cache_seqlens,
        paged_state.block_tables,
        capacity,
        chunk_tokens,
    )
    torch.cuda.synchronize()
    out = out.reshape(rows, capacity)
    scale = 1.0 / math.sqrt(float(paged_state.dim))
    max_abs = 0.0
    checked = 0
    for local_row in range(rows):
        seqlen = int(paged_state.cache_seqlens_cpu[local_row])
        for slot in range(min(actual_subset[local_row], check_slots)):
            work_head = slot % paged_state.num_work_heads
            kv_head = work_head % paged_state.num_kv_heads
            chunk = slot // paged_state.num_work_heads
            token_base = chunk * chunk_tokens
            scores = []
            vals = []
            for token in range(chunk_tokens):
                abs_token = token_base + token
                if abs_token >= seqlen:
                    continue
                page_idx = abs_token // paged_state.page_block_size
                page_offset = abs_token - page_idx * paged_state.page_block_size
                phys = int(paged_state.block_table_cpu[local_row, page_idx])
                if phys < 0 or phys >= paged_state.kv_pages:
                    continue
                k = paged_state.k_pool[phys, kv_head, page_offset].float()
                v = paged_state.v_pool[phys, kv_head, page_offset].float()
                q = paged_state.q_transforms[work_head].float()
                vt = paged_state.v_transforms[work_head].float()
                scores.append(torch.dot(k, q) * scale)
                vals.append(torch.dot(v, vt))
            if scores:
                score_t = torch.stack(scores)
                val_t = torch.stack(vals)
                ref = (torch.softmax(score_t, dim=0) * val_t).sum()
            else:
                ref = torch.tensor(0.0, device="cuda")
            got = out[local_row, slot]
            diff = float((got - ref).abs().item())
            max_abs = max(max_abs, diff)
            checked += 1
    print(f"paged_attn_check rows={rows} checked={checked} max_abs={max_abs:.6g}")
    return max_abs


def check_paged_full(
    ext,
    paged_state,
    actual_sizes,
    chunk_tokens: int,
    value_dim: int,
    check_rows: int,
    check_heads: int,
):
    rows = min(check_rows, len(actual_sizes))
    actual_subset = [int(x) for x in actual_sizes[:rows]]
    capacity = max(actual_subset)
    actual_gpu = torch.tensor(actual_subset, dtype=torch.int32, device="cuda")
    row_gpu = torch.arange(rows, dtype=torch.int32, device="cuda")
    workspace = make_full_workspace(paged_state, chunk_tokens, value_dim)
    workspace.chunk_m.zero_()
    workspace.chunk_l.zero_()
    workspace.chunk_acc.zero_()
    workspace.output.zero_()
    ext.replay_paged_kv_chunk_workspace(
        paged_state.k_pool,
        paged_state.v_pool,
        paged_state.q_transforms,
        actual_gpu,
        row_gpu,
        paged_state.cache_seqlens,
        paged_state.block_tables,
        workspace.chunk_m,
        workspace.chunk_l,
        workspace.chunk_acc,
        capacity,
        chunk_tokens,
    )
    ext.replay_paged_kv_reduce_workspace(
        workspace.chunk_m,
        workspace.chunk_l,
        workspace.chunk_acc,
        paged_state.cache_seqlens,
        workspace.output,
        chunk_tokens,
    )
    torch.cuda.synchronize()

    scale = 1.0 / math.sqrt(float(paged_state.dim))
    max_abs = 0.0
    checked = 0
    for row in range(rows):
        seqlen = int(paged_state.cache_seqlens_cpu[row])
        for work_head in range(min(check_heads, paged_state.num_work_heads)):
            kv_head = work_head % paged_state.num_kv_heads
            scores = []
            vals = []
            for abs_token in range(seqlen):
                page_idx = abs_token // paged_state.page_block_size
                page_offset = abs_token - page_idx * paged_state.page_block_size
                phys = int(paged_state.block_table_cpu[row, page_idx])
                if phys < 0 or phys >= paged_state.kv_pages:
                    continue
                k = paged_state.k_pool[phys, kv_head, page_offset].float()
                v = paged_state.v_pool[phys, kv_head, page_offset, :value_dim].float()
                q = paged_state.q_transforms[work_head].float()
                scores.append(torch.dot(k, q) * scale)
                vals.append(v)
            if scores:
                score_t = torch.stack(scores)
                val_t = torch.stack(vals)
                ref = (torch.softmax(score_t, dim=0).reshape(-1, 1) * val_t).sum(dim=0)
            else:
                ref = torch.zeros((value_dim,), device="cuda")
            got = workspace.output[row, work_head]
            diff = float((got - ref).abs().max().item())
            max_abs = max(max_abs, diff)
            checked += value_dim
    print(f"paged_full_check rows={rows} heads={min(check_heads, paged_state.num_work_heads)} "
          f"checked={checked} max_abs={max_abs:.6g}")
    return max_abs


def time_cuda(fn, warmup: int, iters: int):
    for _ in range(warmup):
        out = fn()
    torch.cuda.synchronize()

    wall_start = time.perf_counter()
    event_values = []
    for _ in range(iters):
        start = torch.cuda.Event(enable_timing=True)
        end = torch.cuda.Event(enable_timing=True)
        start.record()
        out = fn()
        end.record()
        torch.cuda.synchronize()
        event_values.append(start.elapsed_time(end))
    wall_ms = (time.perf_counter() - wall_start) * 1.0e3 / iters
    event_ms = statistics.median(event_values)
    return out, event_ms, wall_ms


def make_strategy_capacities(args, actual_sizes: Sequence[int]):
    max_actual = max(actual_sizes)
    strategies = []

    max_capacity = args.max_capacity or max_actual
    strategies.append(("single_max", [max_capacity], [max_capacity] * len(actual_sizes)))

    class_caps = (
        parse_int_list(args.class_capacities)
        if args.class_capacities
        else tcp.choose_ratio_classes(actual_sizes, args.num_classes, args.capacity_round, 2048)
    )
    class_capacities, class_overflow = choose_capacities(actual_sizes, class_caps)
    if class_overflow:
        raise RuntimeError(f"class capacities overflowed {class_overflow} traces: {class_caps}")
    strategies.append(("capacity_class", class_caps, class_capacities))

    round64_caps = (
        parse_int_list(args.round64_capacities)
        if args.round64_capacities
        else tcp.choose_ratio_classes(actual_sizes, 2, 64, 2048)
    )
    round64_capacities, round64_overflow = choose_capacities(actual_sizes, round64_caps)
    if round64_overflow:
        raise RuntimeError(f"round64 capacities overflowed {round64_overflow} traces: {round64_caps}")
    strategies.append(("round64_class", round64_caps, round64_capacities))

    if getattr(args, "include_exact", False):
        exact_caps = sorted(set(int(x) for x in actual_sizes))
        strategies.append(("exact_work_sim", exact_caps, list(actual_sizes)))
    return strategies


def record_result(
    rows,
    mode,
    launch_mode,
    strategy,
    classes,
    actual_sizes,
    capacities,
    event_ms,
    wall_ms,
    overflow,
    launch_count=None,
    metadata_setup_ms=0.0,
    row_order="original",
    effective_row_order="original",
    row_order_setup_ms=0.0,
    group_setup_ms=0.0,
    row_order_metrics=None,
):
    row_order_metrics = row_order_metrics or {}
    ratios = ratio_summary(actual_sizes, capacities)
    total_capacity = sum(capacities)
    total_actual = sum(actual_sizes)
    rows.append(
        {
            "mode": mode,
            "launch_mode": launch_mode,
            "strategy": strategy,
            "row_order": row_order,
            "effective_row_order": effective_row_order,
            "classes": " ".join(str(x) for x in classes),
            "traces": len(actual_sizes),
            "actual_min": min(actual_sizes),
            "actual_p50": tcp.percentile(actual_sizes, 0.50),
            "actual_p90": tcp.percentile(actual_sizes, 0.90),
            "actual_max": max(actual_sizes),
            "total_actual_blocks": total_actual,
            "total_capacity_blocks": total_capacity,
            "empty_blocks": total_capacity - total_actual,
            "empty_block_fraction": (total_capacity - total_actual) / total_capacity
            if total_capacity
            else 0.0,
            "capacity_actual_ratio_p50": ratios["p50"],
            "capacity_actual_ratio_p90": ratios["p90"],
            "capacity_actual_ratio_p99": ratios["p99"],
            "capacity_actual_ratio_max": ratios["max"],
            "overflow": overflow,
            "launch_count": launch_count if launch_count is not None else 0,
            "metadata_setup_ms": metadata_setup_ms,
            "row_order_setup_ms": row_order_setup_ms,
            "group_setup_ms": group_setup_ms,
            "first_page_unique": row_order_metrics.get("first_page_unique", 0),
            "first_page_unique_ratio": row_order_metrics.get("first_page_unique_ratio", 0.0),
            "adjacent_first_page_hit_ratio": row_order_metrics.get(
                "adjacent_first_page_hit_ratio", 0.0
            ),
            "first_page_unique_w128_p50": row_order_metrics.get(
                "first_page_unique_w128_p50", 0.0
            ),
            "first_page_unique_w128_ratio_p50": row_order_metrics.get(
                "first_page_unique_w128_ratio_p50", 0.0
            ),
            "adjacent_lcp_mean": row_order_metrics.get("adjacent_lcp_mean", 0.0),
            "event_ms": event_ms,
            "wall_ms": wall_ms,
            "per_trace_event_us": event_ms * 1000.0 / len(actual_sizes),
            "per_trace_wall_us": wall_ms * 1000.0 / len(actual_sizes),
        }
    )


def main():
    parser = argparse.ArgumentParser(description="Replay vLLM decode actual_work_size traces")
    parser.add_argument("--trace", type=Path, nargs="+", default=None)
    parser.add_argument("--limit-traces", type=int, default=0)
    parser.add_argument("--actual-scale", type=float, default=1.0)
    parser.add_argument("--capacity-round", type=int, default=4)
    parser.add_argument("--num-classes", type=int, default=6)
    parser.add_argument("--class-capacities", nargs="+", default=None)
    parser.add_argument("--max-capacity", type=int, default=None)
    parser.add_argument("--round64-capacities", nargs="+", default=None)
    parser.add_argument("--strategy-filter", nargs="+", default=None)
    parser.add_argument("--strategy-order", choices=("default", "reverse"), default="default")
    parser.add_argument("--row-order", choices=ROW_ORDER_CHOICES, default="original")
    parser.add_argument("--auto-first-page-max-unique-ratio", type=float, default=0.50)
    parser.add_argument("--auto-first-page-max-window128-unique-ratio", type=float, default=0.75)
    parser.add_argument("--auto-first-page-min-adjacent-hit", type=float, default=0.05)
    parser.add_argument("--auto-first-page-max-window128-unique", type=float, default=96.0)
    parser.add_argument("--auto-first-page-min-lcp-mean", type=float, default=1.0)
    parser.add_argument("--auto-first-page-min-rows", type=int, default=0)
    parser.add_argument("--include-exact", action="store_true")
    parser.add_argument("--launch-mode", choices=("per-row", "fused", "both"), default="per-row")
    parser.add_argument("--work-iters-list", nargs="+", default=("0", "16"))
    parser.add_argument("--modes", nargs="+", default=("self-cull", "gather-dot"))
    parser.add_argument("--dtype", choices=("fp16", "bf16"), default="bf16")
    parser.add_argument("--rows", type=int, default=65536)
    parser.add_argument("--dim", type=int, default=256)
    parser.add_argument("--consumer-transforms", type=int, default=2)
    parser.add_argument("--kv-pages", type=int, default=256)
    parser.add_argument("--kv-page-tokens", type=int, default=None)
    parser.add_argument("--kv-heads", type=int, default=None)
    parser.add_argument("--work-heads", type=int, default=None)
    parser.add_argument("--value-dim", type=int, default=32)
    parser.add_argument("--page-locality", choices=("random", "contiguous", "page-cross", "hot-page", "trace"), default="random")
    parser.add_argument("--hot-pages", type=int, default=1)
    parser.add_argument("--chunk-tokens", type=int, default=32)
    parser.add_argument("--warmup", type=int, default=1)
    parser.add_argument("--iters", type=int, default=5)
    parser.add_argument("--seed", type=int, default=0)
    parser.add_argument("--pre-profile-sleep", type=float, default=0.0)
    parser.add_argument("--check-paged-attn", action="store_true")
    parser.add_argument("--check-paged-full", action="store_true")
    parser.add_argument("--check-rows", type=int, default=4)
    parser.add_argument("--check-slots", type=int, default=8)
    parser.add_argument("--check-heads", type=int, default=2)
    parser.add_argument("--check-atol", type=float, default=1.0e-2)
    parser.add_argument("--output", type=Path, default=THIS_DIR / "prof" / "vllm_trace_replay.csv")
    args = parser.parse_args()

    if not torch.cuda.is_available():
        raise RuntimeError("CUDA/HIP device is not available to PyTorch")

    trace_files = expand_trace_inputs(args.trace) if args.trace else default_trace_files()
    trace_meta = load_trace_metadata(trace_files, args.actual_scale, args.chunk_tokens)
    trace_meta = trim_trace_meta(trace_meta, args.limit_traces)
    actual_sizes = trace_meta.actual_sizes
    strategies = make_strategy_capacities(args, actual_sizes)
    if args.strategy_filter:
        selected = set(args.strategy_filter)
        strategies = [item for item in strategies if item[0] in selected]
        if not strategies:
            raise RuntimeError(f"--strategy-filter matched no strategies: {sorted(selected)}")
    if args.strategy_order == "reverse":
        strategies = list(reversed(strategies))

    ext = tg.build_extension(SimpleNamespace(enable_direct=False))
    device_anchor = torch.empty((), device="cuda", dtype=torch.int32)
    actual_cpu = torch.tensor(actual_sizes, dtype=torch.int64)

    dtype = {"fp16": torch.float16, "bf16": torch.bfloat16}[args.dtype]
    torch.manual_seed(args.seed)
    features = torch.randn(args.rows, args.dim, device="cuda", dtype=dtype)
    transforms = torch.randn(args.consumer_transforms, args.dim, device="cuda", dtype=dtype)
    full_modes = {
        "paged-full",
        "paged-full-producer",
        "paged-full-reduce",
        "paged-full-reduce-ml",
    }
    paged_modes = {"paged-dot", "paged-attn"} | full_modes
    needs_paged = bool(paged_modes.intersection(args.modes)) or args.check_paged_attn or args.check_paged_full
    paged_state = make_paged_state(trace_meta, args, dtype) if needs_paged else None
    row_order_setup_start = time.perf_counter()
    row_order_metrics = row_order_reuse_predictor(paged_state, len(actual_sizes))
    effective_row_order = resolve_row_order(args.row_order, row_order_metrics, args)
    row_order_key = make_row_order_key(effective_row_order, paged_state, len(actual_sizes))
    row_order_setup_ms = (time.perf_counter() - row_order_setup_start) * 1.0e3
    if args.check_paged_attn:
        max_abs = check_paged_attn(ext, paged_state, actual_sizes, args.chunk_tokens, args.check_rows, args.check_slots)
        if max_abs > args.check_atol:
            raise RuntimeError(f"paged attention check failed: max_abs={max_abs} > atol={args.check_atol}")
    if args.check_paged_full:
        max_abs = check_paged_full(
            ext,
            paged_state,
            actual_sizes,
            args.chunk_tokens,
            args.value_dim,
            args.check_rows,
            args.check_heads,
        )
        if max_abs > args.check_atol:
            raise RuntimeError(f"paged full check failed: max_abs={max_abs} > atol={args.check_atol}")
    full_workspace = make_full_workspace(paged_state, args.chunk_tokens, args.value_dim) if full_modes.intersection(args.modes) else None
    if args.pre_profile_sleep > 0:
        print(f"pre_profile_sleep pid={os.getpid()} seconds={args.pre_profile_sleep}", flush=True)
        time.sleep(args.pre_profile_sleep)

    launch_modes = ["per_row"] if args.launch_mode == "per-row" else [args.launch_mode]
    if args.launch_mode == "both":
        launch_modes = ["per_row", "fused"]

    rows = []
    group_setup_ms_by_strategy = {}
    for strategy_name, classes, capacities in strategies:
        capacity_cpu = torch.tensor(capacities, dtype=torch.int64)
        max_capacity = max(capacities)
        overflow = sum(1 for actual, capacity in zip(actual_sizes, capacities) if actual > capacity)
        fused_groups = None
        if "fused" in launch_modes:
            group_setup_start = time.perf_counter()
            fused_groups = materialize_fused_groups(make_fused_groups(actual_sizes, capacities, row_order_key))
            torch.cuda.synchronize()
            group_setup_ms_by_strategy[strategy_name] = (time.perf_counter() - group_setup_start) * 1.0e3

        if "self-cull" in args.modes:
            for work_iters in parse_int_list(args.work_iters_list):
                if "per_row" in launch_modes:
                    _out, event_ms, wall_ms = time_cuda(
                        lambda capacity_cpu=capacity_cpu, max_capacity=max_capacity, work_iters=work_iters: ext.replay_self_cull_many(
                            device_anchor, actual_cpu, capacity_cpu, max_capacity, work_iters
                        ),
                        args.warmup,
                        args.iters,
                    )
                    record_result(
                        rows,
                        f"self_cull_iters_{work_iters}",
                        "per_row",
                        strategy_name,
                        classes,
                        actual_sizes,
                        capacities,
                        event_ms,
                        wall_ms,
                        overflow,
                    )

                if "fused" in launch_modes:
                    _out, event_ms, wall_ms = time_cuda(
                        lambda fused_groups=fused_groups, work_iters=work_iters: run_fused_self_cull(
                            ext, device_anchor, fused_groups, work_iters
                        ),
                        args.warmup,
                        args.iters,
                    )
                    record_result(
                        rows,
                        f"self_cull_iters_{work_iters}",
                        "fused",
                        strategy_name,
                        classes,
                        actual_sizes,
                        capacities,
                        event_ms,
                        wall_ms,
                        overflow,
                        launch_count=len(fused_groups) if fused_groups is not None else None,
                        row_order=args.row_order,
                    )

        if "gather-dot" in args.modes:
            if "per_row" in launch_modes:
                _out, event_ms, wall_ms = time_cuda(
                    lambda capacity_cpu=capacity_cpu, max_capacity=max_capacity: ext.replay_gather_dot_many(
                        features,
                        transforms,
                        actual_cpu,
                        capacity_cpu,
                        max_capacity,
                        args.chunk_tokens,
                    ),
                    args.warmup,
                    args.iters,
                )
                record_result(
                    rows,
                    "gather_dot",
                    "per_row",
                    strategy_name,
                    classes,
                    actual_sizes,
                    capacities,
                    event_ms,
                    wall_ms,
                    overflow,
                        launch_count=len(actual_sizes),
                        row_order=args.row_order,
                )

            if "fused" in launch_modes:
                _out, event_ms, wall_ms = time_cuda(
                    lambda fused_groups=fused_groups: run_fused_gather_dot(
                        ext, features, transforms, fused_groups, args.chunk_tokens
                    ),
                    args.warmup,
                    args.iters,
                )
                record_result(
                    rows,
                    "gather_dot",
                    "fused",
                    strategy_name,
                    classes,
                    actual_sizes,
                    capacities,
                    event_ms,
                    wall_ms,
                    overflow,
                        launch_count=len(fused_groups) if fused_groups is not None else None,
                        row_order=args.row_order,
                )

        if "paged-dot" in args.modes:
            if "per_row" in launch_modes:
                raise RuntimeError("paged-dot currently requires --launch-mode fused")
            _out, event_ms, wall_ms = time_cuda(
                lambda fused_groups=fused_groups: run_fused_paged_dot(
                    ext, paged_state, fused_groups, args.chunk_tokens
                ),
                args.warmup,
                args.iters,
            )
            record_result(
                rows,
                "paged_kv_dot",
                "fused",
                strategy_name,
                classes,
                actual_sizes,
                capacities,
                event_ms,
                wall_ms,
                overflow,
                launch_count=len(fused_groups) if fused_groups is not None else None,
                metadata_setup_ms=paged_state.setup_ms if paged_state is not None else 0.0,
                row_order=args.row_order,
            )

        if "paged-attn" in args.modes:
            if "per_row" in launch_modes:
                raise RuntimeError("paged-attn currently requires --launch-mode fused")
            _out, event_ms, wall_ms = time_cuda(
                lambda fused_groups=fused_groups: run_fused_paged_attn(
                    ext, paged_state, fused_groups, args.chunk_tokens
                ),
                args.warmup,
                args.iters,
            )
            record_result(
                rows,
                "paged_kv_attn",
                "fused",
                strategy_name,
                classes,
                actual_sizes,
                capacities,
                event_ms,
                wall_ms,
                overflow,
                launch_count=len(fused_groups) if fused_groups is not None else None,
                metadata_setup_ms=paged_state.setup_ms if paged_state is not None else 0.0,
                row_order=args.row_order,
            )

        if "paged-full" in args.modes:
            if "per_row" in launch_modes:
                raise RuntimeError("paged-full currently requires --launch-mode fused")
            _out, event_ms, wall_ms = time_cuda(
                lambda fused_groups=fused_groups: run_fused_paged_full(
                    ext, paged_state, full_workspace, fused_groups, args.chunk_tokens
                ),
                args.warmup,
                args.iters,
            )
            record_result(
                rows,
                "paged_kv_full",
                "fused",
                strategy_name,
                classes,
                actual_sizes,
                capacities,
                event_ms,
                wall_ms,
                overflow,
                launch_count=(len(fused_groups) + 1) if fused_groups is not None else None,
                metadata_setup_ms=(paged_state.setup_ms if paged_state is not None else 0.0)
                + (full_workspace.setup_ms if full_workspace is not None else 0.0),
                row_order=args.row_order,
            )

        if "paged-full-producer" in args.modes:
            if "per_row" in launch_modes:
                raise RuntimeError("paged-full-producer currently requires --launch-mode fused")
            _out, event_ms, wall_ms = time_cuda(
                lambda fused_groups=fused_groups: run_fused_paged_full_producer(
                    ext, paged_state, full_workspace, fused_groups, args.chunk_tokens
                ),
                args.warmup,
                args.iters,
            )
            record_result(
                rows,
                "paged_kv_full_producer",
                "fused",
                strategy_name,
                classes,
                actual_sizes,
                capacities,
                event_ms,
                wall_ms,
                overflow,
                launch_count=len(fused_groups) if fused_groups is not None else None,
                metadata_setup_ms=(paged_state.setup_ms if paged_state is not None else 0.0)
                + (full_workspace.setup_ms if full_workspace is not None else 0.0),
                row_order=args.row_order,
            )

        if "paged-full-reduce" in args.modes:
            if "per_row" in launch_modes:
                raise RuntimeError("paged-full-reduce currently requires --launch-mode fused")
            prefill_full_workspace(ext, paged_state, full_workspace, fused_groups, args.chunk_tokens)
            _out, event_ms, wall_ms = time_cuda(
                lambda: run_fused_paged_full_reduce(
                    ext, paged_state, full_workspace, args.chunk_tokens
                ),
                args.warmup,
                args.iters,
            )
            record_result(
                rows,
                "paged_kv_full_reduce",
                "fused",
                strategy_name,
                classes,
                actual_sizes,
                capacities,
                event_ms,
                wall_ms,
                overflow,
                launch_count=1,
                metadata_setup_ms=(paged_state.setup_ms if paged_state is not None else 0.0)
                + (full_workspace.setup_ms if full_workspace is not None else 0.0),
                row_order=args.row_order,
            )

        if "paged-full-reduce-ml" in args.modes:
            if "per_row" in launch_modes:
                raise RuntimeError("paged-full-reduce-ml currently requires --launch-mode fused")
            prefill_full_workspace(ext, paged_state, full_workspace, fused_groups, args.chunk_tokens)
            _out, event_ms, wall_ms = time_cuda(
                lambda: run_fused_paged_full_reduce_ml(
                    ext, paged_state, full_workspace, args.chunk_tokens
                ),
                args.warmup,
                args.iters,
            )
            record_result(
                rows,
                "paged_kv_full_reduce_ml",
                "fused",
                strategy_name,
                classes,
                actual_sizes,
                capacities,
                event_ms,
                wall_ms,
                overflow,
                launch_count=1,
                metadata_setup_ms=(paged_state.setup_ms if paged_state is not None else 0.0)
                + (full_workspace.setup_ms if full_workspace is not None else 0.0),
                row_order=args.row_order,
            )

    for row in rows:
        row["effective_row_order"] = effective_row_order
        row["row_order_setup_ms"] = row_order_setup_ms
        row["first_page_unique"] = row_order_metrics["first_page_unique"]
        row["first_page_unique_ratio"] = row_order_metrics["first_page_unique_ratio"]
        row["adjacent_first_page_hit_ratio"] = row_order_metrics["adjacent_first_page_hit_ratio"]
        row["first_page_unique_w128_p50"] = row_order_metrics["first_page_unique_w128_p50"]
        row["first_page_unique_w128_ratio_p50"] = row_order_metrics[
            "first_page_unique_w128_ratio_p50"
        ]
        row["adjacent_lcp_mean"] = row_order_metrics["adjacent_lcp_mean"]
        if row["launch_mode"] == "fused":
            row["group_setup_ms"] = group_setup_ms_by_strategy.get(row["strategy"], 0.0)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)

    print(f"loaded traces={len(actual_sizes)} actual_min={min(actual_sizes)} "
          f"actual_p50={statistics.median(actual_sizes):.1f} actual_max={max(actual_sizes)}")
    for row in rows:
        print(
            f"{row['mode']} {row['launch_mode']} {row['strategy']} "
            f"row_order={row['row_order']} effective={row['effective_row_order']} "
            f"classes=[{row['classes']}] "
            f"empty={row['empty_block_fraction']:.3f} "
            f"event_ms={row['event_ms']:.3f} "
            f"per_trace_us={row['per_trace_event_us']:.3f}"
        )
    print(f"wrote {args.output}")


if __name__ == "__main__":
    main()
