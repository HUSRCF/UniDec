# RDNA3 Gather/Densify Pipeline Plan

目标架构: AMD RDNA3 / gfx11

核心任务: 离散访存的局部稠密化，用于 paged KV decode 或 graph neighbor feature densification。

本计划只关注新的 gather/densify 实验，不依赖历史 D256 BWD 优化结论。历史 FA4/CK 代码只作为可复用工程材料和底层原语来源。

## 设计约束

- 不绑定 CDNA2、MI200、Wave64 或 MFMA 预设。wave size、WMMA/MFMA/VALU/DOT 路径必须按 gfx11 编译产物和 profiler 结果确认。
- VGPR 占用以单个 kernel 的全局最大需求为准。Producer/consumer wave 分工只作为后期 profiling 实验项，不作为第一版基础假设。
- Direct-to-LDS 不作为预设事实。优先尝试 CK/编译器已有封装，逐个 kernel 反汇编确认是否生成 gfx11 可用的 direct-to-LDS 指令；若不成立，退回 global -> VGPR -> LDS 路径。
- waitcnt 不能在计划阶段硬编码。VMEM 路径关注 `vmcnt`，DS/LDS indexed 路径关注 `lgkmcnt`，direct memory-to-LDS 的计数器和同步语义以生成 ISA 与实测行为为准。
- 调度策略先采用单 launch 内排空有限任务队列并退出。暂不实现长期常驻 daemon。

## Phase 0: Specification And Baseline

目标是固定 ABI、baseline 和可观测指标，保证后续 kernel 实验可以被严格比较。

输入 ABI 候选:

- `page_table` 或 `kv_page_indices`: 逻辑块到物理块映射。
- `indptr`: 每个 request 或 graph node 的边界。
- `indices`: 离散 token/page/neighbor 索引。
- `seqlen` 或 `degree`: 每个 request/node 的有效长度。
- `head_dim` 或 `feature_dim`: 特征维度。
- `dtype`: 首批只考虑 fp16/bf16。
- `layout`: KV 或 feature 的物理布局，例如 `[num_blocks, page_size, nheads, dim]`。

基础 baseline:

- CPU reference，用于 correctness。
- naive GPU global gather -> global dense，用于最小性能基线。
- 若目标是 decode，再增加现有 `mha_fwd_kvcache` 或 PyTorch/SDPA 侧可用参考。

成功指标:

- correctness: 输出逐元素对比 CPU/GPU reference。
- latency: kernel time，至少 repeat30。
- bandwidth: 有效 GB/s，按实际读取和写回字节数计算。
- resources: VGPR、SGPR、LDS、scratch。
- ISA: 是否出现预期 global load、DS/LDS、direct-to-LDS 指令。
- profiler: LDS bank conflict、VMEM/LDS stall、occupancy、wavefront behavior。

## Phase 1: Gather-To-LDS Microkernel

目标是只验证离散访存和局部稠密化，不做 attention、softmax、MMA 或图聚合。

最小对比矩阵:

- Baseline A: naive global gather -> global dense。
- Prototype B: global -> VGPR -> LDS -> global dense。
- Prototype C: CK/编译器候选 direct-to-LDS -> global dense。

执行逻辑:

1. Kernel 读取 `indptr/page_table/indices`。
2. 将离散 K/V 或 neighbor feature gather 成一个 LDS dense tile。
3. 从 LDS 读回并写入连续 global dense buffer。
4. host 端校验 dense buffer 是否等于 CPU reference。

验收标准:

- A/B/C 都有相同输入输出语义。
- 反汇编确认 B 和 C 的实际 load/store 形态。
- C 只有在 ISA 真实生成 direct-to-LDS 且 latency/resources 优于 B 时才进入下一阶段。
- 若 C 不成立，后续 pipeline 仍可基于 B 继续，不阻塞整个实验。

## Phase 2: Non-Persistent Fused Prototype

目标是在普通单 kernel 中加入计算，验证 ping-pong LDS 数据流和局部计算正确性。

执行逻辑:

1. 将 LDS 切成 ping/pong 两块。
2. 对 block `i+1` 做 gather/densify，同时对 block `i` 做局部计算。
3. 计算模块先选低风险路径：VALU/DOT 或已验证的小尺寸 WMMA。
4. 对 decode attention，加入局部 score、max/sum 归约和 output accumulation。
5. 对 graph densification，加入邻居 feature 聚合或小矩阵变换。

验收标准:

- 与 unfused reference 数值一致。
- 没有 race condition，边界长度和 page crossing 正确。
- 加入计算后 VGPR/scratch 没有灾难性膨胀。
- ping-pong 版本优于“先 gather dense，再第二个 kernel 计算”的两阶段 baseline，才继续投入。

## Phase 3: Finite Persistent Queue

目标是验证单 launch 内 persistent scheduling 是否改善负载均衡和 launch overhead。

执行逻辑:

1. Host 端准备有限任务数组，每个任务对应一个 request/head/token 或 graph node/tile。
2. GPU 端维护全局 atomic ticket。
3. Launch 固定数量 workgroups。
4. 每个 WG 循环 `atomicAdd` 获取 task id，执行 Phase 2 的 gather/densify/fused compute。
5. task id 越界后 WG 返回，kernel 正常结束。

实验项:

- 不做 wave specialization 的 baseline。
- Producer/consumer wave 分工版本。
- 不同 WG 数量、每 WG wave 数、tile size、queue granularity。

验收标准:

- 有限队列版本的总 latency 优于按 task 或按 chunk 多次 launch。
- 负载不均匀时，atomic ticket 能改善 tail latency。
- wave specialization 只有在 profiler 显示访存/计算隐藏收益超过 VGPR 木桶效应时才保留。

## Phase 4: Persistent Daemon

只有在 Phase 3 证明 launch overhead 或连续 token 调度确实是系统主瓶颈，并且 runtime 能提供稳定协作时才进入。

前置条件:

- 明确 host/device ring buffer ABI。
- 明确 stop flag、heartbeat、timeout 和错误恢复协议。
- 明确 stream/event 同步模型。
- 明确 memory ordering 与可见性要求。

此阶段不属于第一轮实验目标。

## Recommended File Layout

- `experiments/rdna3_gather/`: 独立 microkernel 原型。
- `experiments/rdna3_gather/baseline_global_gather.*`: Baseline A。
- `experiments/rdna3_gather/gather_vgpr_lds.*`: Prototype B。
- `experiments/rdna3_gather/gather_direct_lds.*`: Prototype C。
- `experiments/rdna3_gather/test_gather.py`: correctness 和 latency harness。
- `experiments/rdna3_gather/README.md`: ABI、build、run、profiling 说明。

## First Implementation Target

首个可执行目标:

- dtype: fp16。
- feature/head dim: 64。
- page size: 128。
- batch/request 数: 小规模固定矩阵，例如 16 或 32。
- indices: 同时覆盖连续、随机、跨 page、短尾几种模式。
- 输出: dense buffer `[num_tasks, tile_tokens, dim]`。

第一轮只要求回答一个问题:

> 在 RDNA3/gfx11 上，候选 direct-to-LDS gather 是否真实存在、正确、并且比 global -> VGPR -> LDS 更值得继续？

如果答案是否定的，项目继续走 VGPR->LDS 的稳态路线，不再把 direct-to-LDS 当作核心卖点。
