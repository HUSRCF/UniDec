import argparse
import csv
import math
import os
import subprocess
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import torch
import torch.nn.functional as F


def force_sdpa_math(q, k, v, is_causal: bool):
    try:
        from torch.nn.attention import sdpa_kernel, SDPBackend

        with sdpa_kernel(backends=[SDPBackend.MATH]):
            return F.scaled_dot_product_attention(q, k, v, is_causal=is_causal)
    except Exception:
        with torch.backends.cuda.sdp_kernel(
            enable_math=True, enable_flash=False, enable_mem_efficient=False
        ):
            return F.scaled_dot_product_attention(q, k, v, is_causal=is_causal)


def sdpa_default(q, k, v, is_causal: bool):
    return F.scaled_dot_product_attention(q, k, v, is_causal=is_causal)


def benchmark_forward(fn, warmup: int, iters: int) -> float:
    for _ in range(warmup):
        _ = fn()
    torch.cuda.synchronize()

    start = torch.cuda.Event(enable_timing=True)
    end = torch.cuda.Event(enable_timing=True)
    start.record()
    for _ in range(iters):
        _ = fn()
    end.record()
    torch.cuda.synchronize()
    return start.elapsed_time(end) / iters


def benchmark_backward(make_tensors, fn, warmup: int, iters: int) -> float:
    def run_once():
        q, k, v, dout = make_tensors()
        out = fn(q, k, v, dout)
        if out is not None:
            out.backward(dout)

    for _ in range(warmup):
        run_once()
    torch.cuda.synchronize()

    start = torch.cuda.Event(enable_timing=True)
    end = torch.cuda.Event(enable_timing=True)
    start.record()
    for _ in range(iters):
        run_once()
    end.record()
    torch.cuda.synchronize()
    return start.elapsed_time(end) / iters


def make_base_tensors(batch, seqlen, nheads, headdim, dtype, device, seed):
    gen = torch.Generator(device=device)
    gen.manual_seed(seed)
    q = torch.randn(batch, seqlen, nheads, headdim, dtype=dtype, device=device, generator=gen)
    k = torch.randn(batch, seqlen, nheads, headdim, dtype=dtype, device=device, generator=gen)
    v = torch.randn(batch, seqlen, nheads, headdim, dtype=dtype, device=device, generator=gen)
    dout = torch.randn(batch, seqlen, nheads, headdim, dtype=dtype, device=device, generator=gen)
    return q, k, v, dout


def clone_with_grad(base_q, base_k, base_v, base_dout):
    q = base_q.detach().clone().requires_grad_(True)
    k = base_k.detach().clone().requires_grad_(True)
    v = base_v.detach().clone().requires_grad_(True)
    dout = base_dout.detach().clone()
    return q, k, v, dout


def write_csv(rows, out_csv: Path, fieldnames):
    with out_csv.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def read_csv_rows(csv_path: Path):
    with csv_path.open("r", newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def _to_float_series(rows, key):
    values = []
    for row in rows:
        v = row[key]
        values.append(float(v) if not isinstance(v, float) else v)
    return values


def _best_positive(*values):
    candidates = [v for v in values if isinstance(v, (int, float)) and math.isfinite(v) and v > 0]
    return min(candidates) if candidates else math.nan


def _speedup(numerator, denominator):
    if (
        isinstance(numerator, (int, float))
        and isinstance(denominator, (int, float))
        and math.isfinite(numerator)
        and math.isfinite(denominator)
        and numerator > 0
        and denominator > 0
    ):
        return numerator / denominator
    return math.nan


def plot_forward_comparison(rows, out_png: Path, title: str):
    if not rows:
        return

    seqlens = [row["seqlen"] for row in rows]
    fig, axes = plt.subplots(2, 1, figsize=(10, 9), sharex=True)

    axes[0].plot(seqlens, _to_float_series(rows, "torch_default_fwd_ms"), marker="o", linewidth=1.8, label="Torch default")
    axes[0].plot(seqlens, _to_float_series(rows, "torch_math_fwd_ms"), marker="o", linewidth=1.8, label="Torch math")
    axes[0].plot(seqlens, _to_float_series(rows, "flash_ck_fwd_ms"), marker="o", linewidth=1.8, label="FlashAttention CK")
    axes[0].plot(seqlens, _to_float_series(rows, "flash_triton_fwd_ms"), marker="o", linewidth=1.8, label="FlashAttention Triton")
    axes[0].set_ylabel("Forward ms")
    axes[0].set_title(title)
    axes[0].grid(True, alpha=0.25)
    axes[0].legend()

    axes[1].axhline(1.0, color="black", linestyle="--", linewidth=1.0, label="Torch best = 1x")
    axes[1].plot(seqlens, _to_float_series(rows, "torch_default_fwd_speedup_vs_best"), marker="o", linewidth=1.8, label="Torch default")
    axes[1].plot(seqlens, _to_float_series(rows, "torch_math_fwd_speedup_vs_best"), marker="o", linewidth=1.8, label="Torch math")
    axes[1].plot(seqlens, _to_float_series(rows, "flash_ck_fwd_speedup_vs_best"), marker="o", linewidth=1.8, label="FlashAttention CK")
    axes[1].plot(seqlens, _to_float_series(rows, "flash_triton_fwd_speedup_vs_best"), marker="o", linewidth=1.8, label="FlashAttention Triton")
    axes[1].set_xlabel("Sequence Length")
    axes[1].set_ylabel("Forward speedup vs Torch best")
    axes[1].grid(True, alpha=0.25)
    axes[1].legend()

    fig.tight_layout()
    fig.savefig(out_png, dpi=160)
    plt.close(fig)


def plot_backward_comparison(rows, out_png: Path, title: str):
    if not rows:
        return

    seqlens = [row["seqlen"] for row in rows]
    fig, axes = plt.subplots(2, 1, figsize=(10, 9), sharex=True)

    axes[0].plot(seqlens, _to_float_series(rows, "torch_default_bwd_ms"), marker="o", linewidth=1.8, label="Torch default")
    axes[0].plot(seqlens, _to_float_series(rows, "torch_math_bwd_ms"), marker="o", linewidth=1.8, label="Torch math")
    axes[0].plot(seqlens, _to_float_series(rows, "flash_ck_bwd_ms"), marker="o", linewidth=1.8, label="FlashAttention CK")
    axes[0].plot(seqlens, _to_float_series(rows, "flash_triton_bwd_ms"), marker="o", linewidth=1.8, label="FlashAttention Triton")
    axes[0].set_ylabel("Backward ms")
    axes[0].set_title(title)
    axes[0].grid(True, alpha=0.25)
    axes[0].legend()

    axes[1].axhline(1.0, color="black", linestyle="--", linewidth=1.0, label="Torch best = 1x")
    axes[1].plot(seqlens, _to_float_series(rows, "torch_default_bwd_speedup_vs_best"), marker="o", linewidth=1.8, label="Torch default")
    axes[1].plot(seqlens, _to_float_series(rows, "torch_math_bwd_speedup_vs_best"), marker="o", linewidth=1.8, label="Torch math")
    axes[1].plot(seqlens, _to_float_series(rows, "flash_ck_bwd_speedup_vs_best"), marker="o", linewidth=1.8, label="FlashAttention CK")
    axes[1].plot(seqlens, _to_float_series(rows, "flash_triton_bwd_speedup_vs_best"), marker="o", linewidth=1.8, label="FlashAttention Triton")
    axes[1].set_xlabel("Sequence Length")
    axes[1].set_ylabel("Backward speedup vs Torch best")
    axes[1].grid(True, alpha=0.25)
    axes[1].legend()

    fig.tight_layout()
    fig.savefig(out_png, dpi=160)
    plt.close(fig)


def plot_speedup_bars(rows, out_png: Path, title: str, phase: str):
    if not rows:
        return

    wanted = [1024, 2048, 4096, 8192, 10240]
    selected = [row for row in rows if row["seqlen"] in wanted]
    if not selected:
        return

    x_labels = [str(row["seqlen"]) for row in selected]
    x = list(range(len(selected)))
    width = 0.25

    if phase == "fwd":
        math_key = "torch_math_fwd_speedup_vs_best"
        ck_key = "flash_ck_fwd_speedup_vs_best"
        triton_key = "flash_triton_fwd_speedup_vs_best"
        ylabel = "Forward speedup vs Torch best"
    else:
        math_key = "torch_math_bwd_speedup_vs_best"
        ck_key = "flash_ck_bwd_speedup_vs_best"
        triton_key = "flash_triton_bwd_speedup_vs_best"
        ylabel = "Backward speedup vs Torch best"

    fig, ax = plt.subplots(figsize=(11, 5.5))
    ax.axhline(1.0, color="black", linestyle="--", linewidth=1.0, label="Torch best = 1x")
    ax.bar([i - width for i in x], _to_float_series(selected, math_key), width=width, label="Torch math")
    ax.bar(x, _to_float_series(selected, ck_key), width=width, label="FlashAttention CK")
    ax.bar([i + width for i in x], _to_float_series(selected, triton_key), width=width, label="FlashAttention Triton")
    ax.set_xticks(x)
    ax.set_xticklabels(x_labels)
    ax.set_xlabel("Sequence Length")
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.grid(True, axis="y", alpha=0.25)
    ax.legend()
    fig.tight_layout()
    fig.savefig(out_png, dpi=160)
    plt.close(fig)


def torch_benchmarks(args, seqlens, dtype):
    rows = []
    for seqlen in seqlens:
        base_q, base_k, base_v, base_dout = make_base_tensors(
            args.batch, seqlen, args.nheads, args.headdim, dtype, "cuda", args.seed
        )

        def torch_default_fwd():
            return sdpa_default(
                base_q.transpose(1, 2),
                base_k.transpose(1, 2),
                base_v.transpose(1, 2),
                is_causal=args.causal,
            ).transpose(1, 2)

        def torch_math_fwd():
            return force_sdpa_math(
                base_q.transpose(1, 2),
                base_k.transpose(1, 2),
                base_v.transpose(1, 2),
                is_causal=args.causal,
            ).transpose(1, 2)

        def make_tensors():
            return clone_with_grad(base_q, base_k, base_v, base_dout)

        def torch_default_bwd(q, k, v, dout):
            return sdpa_default(q.transpose(1, 2), k.transpose(1, 2), v.transpose(1, 2), is_causal=args.causal).transpose(1, 2)

        def torch_math_bwd(q, k, v, dout):
            return force_sdpa_math(q.transpose(1, 2), k.transpose(1, 2), v.transpose(1, 2), is_causal=args.causal).transpose(1, 2)

        try:
            default_fwd_ms = benchmark_forward(torch_default_fwd, args.warmup, args.iters)
            math_fwd_ms = benchmark_forward(torch_math_fwd, args.warmup, args.iters)
            if args.fwd_only:
                default_bwd_ms = math.nan
                math_bwd_ms = math.nan
            else:
                default_bwd_ms = benchmark_backward(make_tensors, torch_default_bwd, args.warmup, args.iters)
                math_bwd_ms = benchmark_backward(make_tensors, torch_math_bwd, args.warmup, args.iters)
        except RuntimeError as exc:
            if "out of memory" in str(exc).lower():
                torch.cuda.empty_cache()
                break
            raise

        row = {
            "seqlen": seqlen,
            "torch_default_fwd_ms": default_fwd_ms,
            "torch_math_fwd_ms": math_fwd_ms,
            "torch_default_bwd_ms": default_bwd_ms,
            "torch_math_bwd_ms": math_bwd_ms,
        }
        rows.append(row)
    return rows


def run_flash_worker(args, backend: str, out_csv: Path):
    env = os.environ.copy()
    if backend == "triton":
        env["FLASH_ATTENTION_TRITON_AMD_ENABLE"] = "TRUE"
    else:
        env.pop("FLASH_ATTENTION_TRITON_AMD_ENABLE", None)

    cmd = [
        sys.executable,
        str(Path(__file__).resolve()),
        "--worker",
        "--backend",
        backend,
        "--batch",
        str(args.batch),
        "--nheads",
        str(args.nheads),
        "--headdim",
        str(args.headdim),
        "--dtype",
        args.dtype,
        "--seqlen-start",
        str(args.seqlen_start),
        "--seqlen-end",
        str(args.seqlen_end),
        "--seqlen-step",
        str(args.seqlen_step),
        "--warmup",
        str(args.warmup),
        "--iters",
        str(args.iters),
        "--seed",
        str(args.seed),
        "--out-csv",
        str(out_csv),
    ]
    if args.causal:
        cmd.append("--causal")
    if args.fwd_only:
        cmd.append("--fwd-only")

    stderr_path = out_csv.with_suffix(".stderr.txt")
    result = subprocess.run(cmd, check=False, env=env, capture_output=True, text=True)
    if result.returncode == 0:
        if result.stderr:
            stderr_path.write_text(result.stderr, encoding="utf-8")
        return

    stderr_text = (
        f"backend={backend}\n"
        f"returncode={result.returncode}\n"
        f"command={' '.join(cmd)}\n\n"
        f"STDOUT:\n{result.stdout}\n\nSTDERR:\n{result.stderr}\n"
    )
    stderr_path.write_text(stderr_text, encoding="utf-8")

    rows = []
    for seqlen in range(args.seqlen_start, args.seqlen_end + 1, args.seqlen_step):
        rows.append(
            {
                "backend": backend,
                "flash_module": "",
                "flash_cuda_module": "",
                "seqlen": seqlen,
                "flash_fwd_ms": math.nan,
                "flash_bwd_ms": math.nan,
                "error": f"worker_failed: see {stderr_path.name}",
            }
        )
    write_csv(
        rows,
        out_csv,
        ["backend", "flash_module", "flash_cuda_module", "seqlen", "flash_fwd_ms", "flash_bwd_ms", "error"],
    )


def worker_main(args):
    import flash_attn
    import flash_attn_2_cuda
    from flash_attn import flash_attn_func
    from flash_attn.flash_attn_triton_amd import interface_v2 as triton_v2

    if not torch.cuda.is_available():
        raise RuntimeError("No HIP/CUDA device available")

    dtype = {"fp16": torch.float16, "bf16": torch.bfloat16}[args.dtype]
    seqlens = list(range(args.seqlen_start, args.seqlen_end + 1, args.seqlen_step))
    rows = []
    softmax_scale = 1.0 / math.sqrt(args.headdim)

    for seqlen in seqlens:
        base_q, base_k, base_v, base_dout = make_base_tensors(
            args.batch, seqlen, args.nheads, args.headdim, dtype, "cuda", args.seed
        )

        def make_tensors():
            return clone_with_grad(base_q, base_k, base_v, base_dout)

        if args.backend == "triton":

            def flash_fwd():
                out, _, _, _ = triton_v2.fwd(
                    base_q,
                    base_k,
                    base_v,
                    None,
                    None,
                    0.0,
                    softmax_scale,
                    args.causal,
                    -1,
                    -1,
                    0.0,
                    False,
                    None,
                )
                return out

            def flash_bwd(q, k, v, dout):
                out, softmax_lse, _, rng_state = triton_v2.fwd(
                    q,
                    k,
                    v,
                    None,
                    None,
                    0.0,
                    softmax_scale,
                    args.causal,
                    -1,
                    -1,
                    0.0,
                    False,
                    None,
                )
                dq, dk, dv, _ = triton_v2.bwd(
                    dout,
                    q,
                    k,
                    v,
                    out,
                    softmax_lse,
                    None,
                    None,
                    None,
                    None,
                    0.0,
                    softmax_scale,
                    args.causal,
                    -1,
                    -1,
                    0.0,
                    False,
                    None,
                    rng_state,
                )
                return None

        else:

            def flash_fwd():
                return flash_attn_func(base_q, base_k, base_v, causal=args.causal, deterministic=False)

            def flash_bwd(q, k, v, dout):
                return flash_attn_func(q, k, v, causal=args.causal, deterministic=False)

        try:
            flash_fwd_ms = benchmark_forward(flash_fwd, args.warmup, args.iters)
            flash_bwd_ms = (
                math.nan
                if args.fwd_only
                else benchmark_backward(make_tensors, flash_bwd, args.warmup, args.iters)
            )
            error = ""
        except RuntimeError as exc:
            if "out of memory" in str(exc).lower():
                torch.cuda.empty_cache()
                flash_fwd_ms = math.nan
                flash_bwd_ms = math.nan
                error = "oom"
            else:
                flash_fwd_ms = math.nan
                flash_bwd_ms = math.nan
                error = str(exc)

        rows.append(
            {
                "backend": args.backend,
                "flash_module": flash_attn.__file__,
                "flash_cuda_module": flash_attn_2_cuda.__file__,
                "seqlen": seqlen,
                "flash_fwd_ms": flash_fwd_ms,
                "flash_bwd_ms": flash_bwd_ms,
                "error": error,
            }
        )

    write_csv(
        rows,
        Path(args.out_csv),
        ["backend", "flash_module", "flash_cuda_module", "seqlen", "flash_fwd_ms", "flash_bwd_ms", "error"],
    )


def main():
    parser = argparse.ArgumentParser(description="Benchmark Torch SDPA vs FlashAttention CK/Triton.")
    parser.add_argument("--batch", type=int, default=2)
    parser.add_argument("--nheads", type=int, default=4)
    parser.add_argument("--headdim", type=int, default=64)
    parser.add_argument("--dtype", choices=["fp16", "bf16"], default="fp16")
    parser.add_argument("--causal", action="store_true")
    parser.add_argument("--seqlen-start", type=int, default=512)
    parser.add_argument("--seqlen-end", type=int, default=10240)
    parser.add_argument("--seqlen-step", type=int, default=512)
    parser.add_argument("--warmup", type=int, default=1)
    parser.add_argument("--iters", type=int, default=3)
    parser.add_argument("--seed", type=int, default=0)
    parser.add_argument("--out-dir", type=str, default="testoutput/torch_vs_flash_attn")
    parser.add_argument("--worker", action="store_true")
    parser.add_argument("--backend", choices=["ck", "triton"], default="ck")
    parser.add_argument("--out-csv", type=str, default="")
    parser.add_argument("--fwd-only", action="store_true")
    args = parser.parse_args()

    if args.worker:
        worker_main(args)
        return

    if not torch.cuda.is_available():
        raise RuntimeError("No HIP/CUDA device available")

    out_dir = Path(args.out_dir).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    dtype = {"fp16": torch.float16, "bf16": torch.bfloat16}[args.dtype]
    seqlens = list(range(args.seqlen_start, args.seqlen_end + 1, args.seqlen_step))

    print("=" * 100)
    print("Torch default/math vs FlashAttention CK/Triton Benchmark")
    print(f"device={torch.cuda.get_device_name(0)}")
    print(f"dtype={args.dtype}, batch={args.batch}, nheads={args.nheads}, headdim={args.headdim}")
    print(f"causal={args.causal}")
    print(f"seqlens={seqlens[0]}..{seqlens[-1]} step={args.seqlen_step}")
    print("=" * 100)

    torch_rows = torch_benchmarks(args, seqlens, dtype)

    ck_csv = out_dir / "flash_ck.csv"
    triton_csv = out_dir / "flash_triton.csv"
    run_flash_worker(args, "ck", ck_csv)
    run_flash_worker(args, "triton", triton_csv)

    ck_rows = {int(row["seqlen"]): row for row in read_csv_rows(ck_csv)}
    triton_rows = {int(row["seqlen"]): row for row in read_csv_rows(triton_csv)}

    merged_rows = []
    for row in torch_rows:
        seqlen = row["seqlen"]
        ck_row = ck_rows.get(seqlen, {})
        triton_row = triton_rows.get(seqlen, {})

        flash_ck_fwd_ms = float(ck_row.get("flash_fwd_ms", "nan"))
        flash_ck_bwd_ms = float(ck_row.get("flash_bwd_ms", "nan"))
        flash_triton_fwd_ms = float(triton_row.get("flash_fwd_ms", "nan"))
        flash_triton_bwd_ms = float(triton_row.get("flash_bwd_ms", "nan"))
        torch_best_fwd_ms = _best_positive(row["torch_default_fwd_ms"], row["torch_math_fwd_ms"])
        torch_best_bwd_ms = _best_positive(row["torch_default_bwd_ms"], row["torch_math_bwd_ms"])

        merged = {
            "seqlen": seqlen,
            **row,
            "torch_best_fwd_ms": torch_best_fwd_ms,
            "torch_best_bwd_ms": torch_best_bwd_ms,
            "flash_ck_fwd_ms": flash_ck_fwd_ms,
            "flash_ck_bwd_ms": flash_ck_bwd_ms,
            "flash_triton_fwd_ms": flash_triton_fwd_ms,
            "flash_triton_bwd_ms": flash_triton_bwd_ms,
            "torch_math_fwd_speedup_vs_default": _speedup(row["torch_default_fwd_ms"], row["torch_math_fwd_ms"]),
            "torch_math_bwd_speedup_vs_default": _speedup(row["torch_default_bwd_ms"], row["torch_math_bwd_ms"]),
            "flash_ck_fwd_speedup_vs_default": _speedup(row["torch_default_fwd_ms"], flash_ck_fwd_ms),
            "flash_ck_bwd_speedup_vs_default": _speedup(row["torch_default_bwd_ms"], flash_ck_bwd_ms),
            "flash_triton_fwd_speedup_vs_default": _speedup(row["torch_default_fwd_ms"], flash_triton_fwd_ms),
            "flash_triton_bwd_speedup_vs_default": _speedup(row["torch_default_bwd_ms"], flash_triton_bwd_ms),
            "torch_default_fwd_speedup_vs_best": _speedup(torch_best_fwd_ms, row["torch_default_fwd_ms"]),
            "torch_default_bwd_speedup_vs_best": _speedup(torch_best_bwd_ms, row["torch_default_bwd_ms"]),
            "torch_math_fwd_speedup_vs_best": _speedup(torch_best_fwd_ms, row["torch_math_fwd_ms"]),
            "torch_math_bwd_speedup_vs_best": _speedup(torch_best_bwd_ms, row["torch_math_bwd_ms"]),
            "flash_ck_fwd_speedup_vs_best": _speedup(torch_best_fwd_ms, flash_ck_fwd_ms),
            "flash_ck_bwd_speedup_vs_best": _speedup(torch_best_bwd_ms, flash_ck_bwd_ms),
            "flash_triton_fwd_speedup_vs_best": _speedup(torch_best_fwd_ms, flash_triton_fwd_ms),
            "flash_triton_bwd_speedup_vs_best": _speedup(torch_best_bwd_ms, flash_triton_bwd_ms),
            "flash_ck_error": ck_row.get("error", ""),
            "flash_triton_error": triton_row.get("error", ""),
        }
        merged_rows.append(merged)

        print(
            f"S={seqlen:<5} "
            f"fwd default={row['torch_default_fwd_ms']:>8.3f} math={row['torch_math_fwd_ms']:>8.3f} best={torch_best_fwd_ms:>8.3f} "
            f"ck={flash_ck_fwd_ms:>8.3f} triton={flash_triton_fwd_ms:>8.3f} | "
            f"bwd default={row['torch_default_bwd_ms']:>8.3f} math={row['torch_math_bwd_ms']:>8.3f} best={torch_best_bwd_ms:>8.3f} "
            f"ck={flash_ck_bwd_ms:>8.3f} triton={flash_triton_bwd_ms:>8.3f}"
        )

    merged_csv = out_dir / "torch_vs_flash_attn.csv"
    write_csv(
        merged_rows,
        merged_csv,
        [
            "seqlen",
            "torch_default_fwd_ms",
            "torch_math_fwd_ms",
            "torch_best_fwd_ms",
            "flash_ck_fwd_ms",
            "flash_triton_fwd_ms",
            "torch_default_bwd_ms",
            "torch_math_bwd_ms",
            "torch_best_bwd_ms",
            "flash_ck_bwd_ms",
            "flash_triton_bwd_ms",
            "torch_math_fwd_speedup_vs_default",
            "torch_math_bwd_speedup_vs_default",
            "flash_ck_fwd_speedup_vs_default",
            "flash_ck_bwd_speedup_vs_default",
            "flash_triton_fwd_speedup_vs_default",
            "flash_triton_bwd_speedup_vs_default",
            "torch_default_fwd_speedup_vs_best",
            "torch_default_bwd_speedup_vs_best",
            "torch_math_fwd_speedup_vs_best",
            "torch_math_bwd_speedup_vs_best",
            "flash_ck_fwd_speedup_vs_best",
            "flash_ck_bwd_speedup_vs_best",
            "flash_triton_fwd_speedup_vs_best",
            "flash_triton_bwd_speedup_vs_best",
            "flash_ck_error",
            "flash_triton_error",
        ],
    )

    forward_png = out_dir / "forward_comparison.png"
    backward_png = out_dir / "backward_comparison.png"
    forward_bar_png = out_dir / "forward_speedup_bars.png"
    backward_bar_png = out_dir / "backward_speedup_bars.png"
    common_title = (
        f"B={args.batch}, H={args.nheads}, D={args.headdim}, {args.dtype}, causal={args.causal}"
    )
    plot_forward_comparison(merged_rows, forward_png, f"Forward | {common_title}")
    plot_backward_comparison(merged_rows, backward_png, f"Backward | {common_title}")
    plot_speedup_bars(
        merged_rows,
        forward_bar_png,
        f"Forward Speedup Bars vs Torch best | {common_title}",
        "fwd",
    )
    plot_speedup_bars(
        merged_rows,
        backward_bar_png,
        f"Backward Speedup Bars vs Torch best | {common_title}",
        "bwd",
    )

    print("-" * 100)
    print(f"merged_csv={merged_csv.resolve()}")
    print(f"flash_ck_csv={ck_csv.resolve()}")
    print(f"flash_triton_csv={triton_csv.resolve()}")
    print(f"flash_ck_stderr={ck_csv.with_suffix('.stderr.txt').resolve()}")
    print(f"flash_triton_stderr={triton_csv.with_suffix('.stderr.txt').resolve()}")
    print(f"forward_png={forward_png.resolve()}")
    print(f"backward_png={backward_png.resolve()}")
    print(f"forward_bar_png={forward_bar_png.resolve()}")
    print(f"backward_bar_png={backward_bar_png.resolve()}")


if __name__ == "__main__":
    main()
