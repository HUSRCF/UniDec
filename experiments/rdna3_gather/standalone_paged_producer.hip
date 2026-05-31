#include <hip/hip_runtime.h>

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <map>
#include <numeric>
#include <set>
#include <stdexcept>
#include <string>
#include <vector>

namespace fs = std::filesystem;

namespace {

constexpr int kThreads = 256;

#define HIP_CHECK(expr)                                                                          \
    do                                                                                           \
    {                                                                                            \
        hipError_t _err = (expr);                                                                \
        if(_err != hipSuccess)                                                                   \
        {                                                                                        \
            std::cerr << "HIP error at " << __FILE__ << ":" << __LINE__ << ": "              \
                      << hipGetErrorString(_err) << std::endl;                                  \
            std::exit(1);                                                                        \
        }                                                                                        \
    } while(false)

struct TraceMeta
{
    std::vector<int> seqlens;
    std::vector<std::vector<int>> block_ids;
    std::vector<std::string> block_scopes;
    int page_block_size = 0;
    int num_kv_heads = 0;
    int head_dim = 0;
};

struct Args
{
    std::string trace_path =
        "trace/vllm_decode_block_table_v2_strict_kvlayout_true/jsonl_flattened";
    std::string page_locality = "random";
    std::string strategy = "capacity_class";
    std::string row_order = "original";
    std::string restore_mode = "row-indices";
    std::string output_csv;
    bool scheduler_reuse_metadata_buffers = false;
    std::vector<int> classes = {8, 12, 20, 36, 68, 132};
    int chunk_tokens = 32;
    int kv_pages = 256;
    int hot_pages = 1;
    int physical_superblock = 1;
    int seed = 1234;
    int value_dim = 32;
    int work_heads = 0;
    int kv_page_tokens = 0;
    int limit_traces = 0;
    int warmup = 1;
    int iters = 3;
    double actual_scale = 1.0;
    double auto_first_page_max_unique_ratio = 0.50;
    double auto_first_page_max_window128_unique_ratio = 0.75;
    double auto_first_page_min_adjacent_hit = 0.05;
    double auto_first_page_max_window128_unique = 96.0;
    double auto_first_page_min_lcp_mean = 1.0;
    int auto_first_page_min_rows = 0;
};

struct SchedulerTimings
{
    double metrics_ms = 0.0;
    double row_order_key_ms = 0.0;
    double group_build_ms = 0.0;
    double group_h2d_ms = 0.0;
    double scheduler_setup_ms = 0.0;
};

double host_now_ms()
{
    using clock = std::chrono::steady_clock;
    return std::chrono::duration<double, std::milli>(clock::now().time_since_epoch()).count();
}

__device__ __forceinline__ float f32_from_bits(uint32_t bits)
{
    union
    {
        uint32_t u;
        float f;
    } v{bits};
    return v.f;
}

__device__ __forceinline__ float half_bits_to_float(uint16_t h)
{
    const uint32_t sign = (static_cast<uint32_t>(h & 0x8000u)) << 16;
    uint32_t exp        = (h >> 10) & 0x1fu;
    uint32_t mant       = h & 0x03ffu;

    if(exp == 0)
    {
        if(mant == 0)
        {
            return f32_from_bits(sign);
        }

        int normalized_exp = -14;
        while((mant & 0x0400u) == 0)
        {
            mant <<= 1;
            --normalized_exp;
        }
        mant &= 0x03ffu;
        const uint32_t bits =
            sign | (static_cast<uint32_t>(normalized_exp + 127) << 23) | (mant << 13);
        return f32_from_bits(bits);
    }

    if(exp == 0x1fu)
    {
        return f32_from_bits(sign | 0x7f800000u | (mant << 13));
    }

    const uint32_t bits = sign | ((exp + 112u) << 23) | (mant << 13);
    return f32_from_bits(bits);
}

__device__ __forceinline__ float packed_lane_to_float(uint32_t packed, int lane, int dtype_id)
{
    const uint16_t raw =
        static_cast<uint16_t>((packed >> static_cast<uint32_t>(lane * 16)) & 0xffffu);
    if(dtype_id == 0)
    {
        return half_bits_to_float(raw);
    }
    return f32_from_bits(static_cast<uint32_t>(raw) << 16);
}

__device__ __forceinline__ float dot_packed_dword(uint32_t a, uint32_t b, int dtype_id)
{
    return packed_lane_to_float(a, 0, dtype_id) * packed_lane_to_float(b, 0, dtype_id) +
           packed_lane_to_float(a, 1, dtype_id) * packed_lane_to_float(b, 1, dtype_id);
}

__global__ void init_packed_bf16_kernel(uint32_t* data, int64_t n, uint32_t seed)
{
    const int64_t stride = static_cast<int64_t>(blockDim.x) * gridDim.x;
    for(int64_t i = static_cast<int64_t>(blockIdx.x) * blockDim.x + threadIdx.x; i < n;
        i += stride)
    {
        const uint32_t x = static_cast<uint32_t>(i) * 1664525u + seed * 1013904223u;
        const uint16_t lane0 = static_cast<uint16_t>(0x3f00u | (x & 0x7fu));
        const uint16_t lane1 = static_cast<uint16_t>(0x3f00u | ((x >> 7) & 0x7fu));
        data[i] = static_cast<uint32_t>(lane0) | (static_cast<uint32_t>(lane1) << 16);
    }
}

__global__ void replay_paged_kv_chunk_softmax_standalone(float* __restrict__ chunk_m,
                                                         float* __restrict__ chunk_l,
                                                         float* __restrict__ chunk_acc,
                                                         const uint32_t* __restrict__ k_pool,
                                                         const uint32_t* __restrict__ v_pool,
                                                         const uint32_t* __restrict__ q_transforms,
                                                         const int* __restrict__ actual_work_sizes,
                                                         const int* __restrict__ row_indices,
                                                         const int* __restrict__ cache_seqlens,
                                                         const int* __restrict__ block_tables,
                                                         int work_capacity,
                                                         int num_group_rows,
                                                         int64_t num_kv_pages,
                                                         int64_t num_kv_heads,
                                                         int64_t num_work_heads,
                                                         int64_t page_block_size,
                                                         int64_t max_pages_per_seq,
                                                         int64_t dim_dwords,
                                                         int64_t chunk_tokens,
                                                         int64_t max_chunks,
                                                         int64_t value_dim,
                                                         int dtype_id)
{
    extern __shared__ float shared[];
    float* partial_max = shared;
    float* partial_sum = shared + blockDim.x;
    float* token_weight = shared + blockDim.x * 2;

    const int slot = blockIdx.x;
    const int group_row = blockIdx.y;
    if(group_row >= num_group_rows)
    {
        return;
    }

    const int actual = actual_work_sizes[group_row];
    const int active_work = actual < 0 ? 0 : (actual < work_capacity ? actual : work_capacity);
    if(slot >= active_work)
    {
        return;
    }

    const int row = row_indices[group_row];
    const int seqlen = cache_seqlens[row];
    const int64_t work_head = static_cast<int64_t>(slot) % num_work_heads;
    const int64_t kv_head = work_head % num_kv_heads;
    const int64_t chunk = static_cast<int64_t>(slot) / num_work_heads;
    if(chunk >= max_chunks)
    {
        return;
    }

    const int64_t token_base = chunk * chunk_tokens;
    const int64_t transform_base = work_head * dim_dwords;
    const int64_t chunk_index =
        ((static_cast<int64_t>(row) * num_work_heads + work_head) * max_chunks + chunk);
    const int64_t acc_base = chunk_index * value_dim;
    const float scale = rsqrtf(static_cast<float>(dim_dwords * 2));

    float local_max = -3.4028234663852886e38f;
    for(int64_t token = threadIdx.x; token < chunk_tokens; token += blockDim.x)
    {
        const int64_t abs_token = token_base + token;
        float score = -3.4028234663852886e38f;
        if(abs_token < seqlen)
        {
            const int64_t page_idx = abs_token / page_block_size;
            const int64_t page_offset = abs_token - page_idx * page_block_size;
            if(page_idx < max_pages_per_seq)
            {
                const int phys_page =
                    block_tables[static_cast<int64_t>(row) * max_pages_per_seq + page_idx];
                if(phys_page >= 0 && static_cast<int64_t>(phys_page) < num_kv_pages)
                {
                    score = 0.0f;
                    const int64_t base =
                        ((static_cast<int64_t>(phys_page) * num_kv_heads + kv_head) *
                             page_block_size +
                         page_offset) *
                        dim_dwords;
                    for(int64_t dword = 0; dword < dim_dwords; ++dword)
                    {
                        score += dot_packed_dword(k_pool[base + dword],
                                                  q_transforms[transform_base + dword],
                                                  dtype_id);
                    }
                    score *= scale;
                    local_max = score > local_max ? score : local_max;
                }
            }
        }
        if(token < chunk_tokens)
        {
            token_weight[token] = score;
        }
    }

    partial_max[threadIdx.x] = local_max;
    __syncthreads();
    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            const float other = partial_max[threadIdx.x + stride];
            partial_max[threadIdx.x] =
                other > partial_max[threadIdx.x] ? other : partial_max[threadIdx.x];
        }
        __syncthreads();
    }
    const float max_score = partial_max[0];

    float local_l = 0.0f;
    for(int64_t token = threadIdx.x; token < chunk_tokens; token += blockDim.x)
    {
        float weight = 0.0f;
        if(token_base + token < seqlen && max_score > -3.0e38f)
        {
            weight = expf(token_weight[token] - max_score);
        }
        token_weight[token] = weight;
        local_l += weight;
    }

    partial_sum[threadIdx.x] = local_l;
    __syncthreads();
    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            partial_sum[threadIdx.x] += partial_sum[threadIdx.x + stride];
        }
        __syncthreads();
    }

    if(threadIdx.x == 0)
    {
        chunk_m[chunk_index] = max_score > -3.0e38f ? max_score : 0.0f;
        chunk_l[chunk_index] = partial_sum[0];
    }
    __syncthreads();

    for(int64_t value = threadIdx.x; value < value_dim; value += blockDim.x)
    {
        const int64_t dword = value / 2;
        const int lane = static_cast<int>(value - dword * 2);
        float acc = 0.0f;
        for(int64_t token = 0; token < chunk_tokens; ++token)
        {
            const float weight = token_weight[token];
            if(weight == 0.0f)
            {
                continue;
            }

            const int64_t abs_token = token_base + token;
            const int64_t page_idx = abs_token / page_block_size;
            const int64_t page_offset = abs_token - page_idx * page_block_size;
            if(page_idx >= max_pages_per_seq)
            {
                continue;
            }
            const int phys_page =
                block_tables[static_cast<int64_t>(row) * max_pages_per_seq + page_idx];
            if(phys_page < 0 || static_cast<int64_t>(phys_page) >= num_kv_pages)
            {
                continue;
            }

            const int64_t v_index =
                (((static_cast<int64_t>(phys_page) * num_kv_heads + kv_head) *
                      page_block_size +
                  page_offset) *
                     dim_dwords +
                 dword);
            acc += weight * packed_lane_to_float(v_pool[v_index], lane, dtype_id);
        }
        chunk_acc[acc_base + value] = acc;
    }
}

__global__ void restore_sorted_rows_kernel(const float* __restrict__ sorted_output,
                                           float* __restrict__ original_output,
                                           const int* __restrict__ sorted_to_original,
                                           int num_rows,
                                           int num_work_heads,
                                           int value_dim)
{
    const int64_t total =
        static_cast<int64_t>(num_rows) * num_work_heads * static_cast<int64_t>(value_dim);
    const int64_t stride = static_cast<int64_t>(blockDim.x) * gridDim.x;
    for(int64_t linear = static_cast<int64_t>(blockIdx.x) * blockDim.x + threadIdx.x;
        linear < total;
        linear += stride)
    {
        const int value = static_cast<int>(linear % value_dim);
        const int64_t tmp = linear / value_dim;
        const int work_head = static_cast<int>(tmp % num_work_heads);
        const int sorted_row = static_cast<int>(tmp / num_work_heads);
        const int original_row = sorted_to_original[sorted_row];
        original_output[(static_cast<int64_t>(original_row) * num_work_heads + work_head) *
                            value_dim +
                        value] = sorted_output[linear];
    }
}

int parse_int_after_key(const std::string& line, const std::string& key, int fallback)
{
    const std::string needle = "\"" + key + "\":";
    const auto pos = line.find(needle);
    if(pos == std::string::npos)
    {
        return fallback;
    }
    auto i = pos + needle.size();
    while(i < line.size() && (line[i] == ' ' || line[i] == '['))
    {
        ++i;
    }
    bool neg = false;
    if(i < line.size() && line[i] == '-')
    {
        neg = true;
        ++i;
    }
    int value = 0;
    bool any = false;
    while(i < line.size() && line[i] >= '0' && line[i] <= '9')
    {
        any = true;
        value = value * 10 + (line[i] - '0');
        ++i;
    }
    if(!any)
    {
        return fallback;
    }
    return neg ? -value : value;
}

int64_t parse_int64_after_key(const std::string& line, const std::string& key, int64_t fallback)
{
    const std::string needle = "\"" + key + "\":";
    const auto pos = line.find(needle);
    if(pos == std::string::npos)
    {
        return fallback;
    }
    auto i = pos + needle.size();
    while(i < line.size() && (line[i] == ' ' || line[i] == '['))
    {
        ++i;
    }
    bool neg = false;
    if(i < line.size() && line[i] == '-')
    {
        neg = true;
        ++i;
    }
    int64_t value = 0;
    bool any = false;
    while(i < line.size() && line[i] >= '0' && line[i] <= '9')
    {
        any = true;
        value = value * 10 + static_cast<int64_t>(line[i] - '0');
        ++i;
    }
    if(!any)
    {
        return fallback;
    }
    return neg ? -value : value;
}

std::vector<int> parse_int_array_after_key(const std::string& line, const std::string& key)
{
    const std::string needle = "\"" + key + "\":";
    const auto pos = line.find(needle);
    if(pos == std::string::npos)
    {
        return {};
    }
    auto open = line.find('[', pos + needle.size());
    if(open == std::string::npos)
    {
        return {};
    }
    auto close = line.find(']', open + 1);
    if(close == std::string::npos)
    {
        return {};
    }

    std::vector<int> out;
    std::string cur;
    for(auto i = open + 1; i < close; ++i)
    {
        const char c = line[i];
        if((c >= '0' && c <= '9') || c == '-')
        {
            cur.push_back(c);
        }
        else if(!cur.empty())
        {
            out.push_back(std::stoi(cur));
            cur.clear();
        }
    }
    if(!cur.empty())
    {
        out.push_back(std::stoi(cur));
    }
    return out;
}

std::vector<fs::path> trace_files(const std::string& path)
{
    fs::path p(path);
    std::vector<fs::path> files;
    if(fs::is_regular_file(p))
    {
        files.push_back(p);
    }
    else
    {
        for(const auto& entry : fs::directory_iterator(p))
        {
            if(entry.is_regular_file() && entry.path().extension() == ".jsonl")
            {
                files.push_back(entry.path());
            }
        }
    }
    std::sort(files.begin(), files.end());
    if(files.empty())
    {
        throw std::runtime_error("no JSONL trace files found under " + path);
    }
    return files;
}

TraceMeta load_trace(const std::string& path)
{
    TraceMeta meta;
    for(const auto& file : trace_files(path))
    {
        std::ifstream in(file);
        if(!in)
        {
            throw std::runtime_error("failed to open " + file.string());
        }
        std::string line;
        while(std::getline(in, line))
        {
            if(line.empty())
            {
                continue;
            }
            const std::vector<int> seqlens = parse_int_array_after_key(line, "cache_seqlens");
            if(seqlens.empty())
            {
                throw std::runtime_error("missing cache_seqlens in " + file.string());
            }
            if(seqlens.size() != 1)
            {
                throw std::runtime_error(
                    "standalone replay expects one sequence per trace row; use jsonl_flattened "
                    "instead of batched jsonl in " +
                    file.string());
            }
            const int seqlen = seqlens[0];
            meta.seqlens.push_back(seqlen);
            meta.block_ids.push_back(parse_int_array_after_key(line, "block_ids"));
            const int64_t k_ptr = parse_int64_after_key(line, "k_data_ptr", -1);
            const int64_t v_ptr = parse_int64_after_key(line, "v_data_ptr", -1);
            const int layer = parse_int_after_key(
                line, "layer_ordinal", parse_int_after_key(line, "layer", -1));
            if(k_ptr >= 0 && v_ptr >= 0)
            {
                meta.block_scopes.push_back("ptr:" + std::to_string(k_ptr) + ":" +
                                            std::to_string(v_ptr) + ":" +
                                            std::to_string(layer));
            }
            else
            {
                meta.block_scopes.push_back("file:" + file.string() + ":" +
                                            std::to_string(layer));
            }
            meta.page_block_size = parse_int_after_key(
                line, "block_size_tokens", parse_int_after_key(line, "page_block_size", meta.page_block_size));
            meta.num_kv_heads = parse_int_after_key(line, "num_kv_heads", meta.num_kv_heads);
            meta.head_dim = parse_int_after_key(line, "head_dim", meta.head_dim);
        }
    }
    if(meta.seqlens.empty())
    {
        throw std::runtime_error("empty trace");
    }
    if(meta.page_block_size <= 0 || meta.num_kv_heads <= 0 || meta.head_dim <= 0)
    {
        throw std::runtime_error("trace metadata missing page_block_size/num_kv_heads/head_dim");
    }
    return meta;
}

std::vector<int> parse_int_list(const std::string& s)
{
    std::vector<int> out;
    std::string cur;
    for(char c : s)
    {
        if(c == ',' || c == ' ')
        {
            if(!cur.empty())
            {
                out.push_back(std::stoi(cur));
                cur.clear();
            }
        }
        else
        {
            cur.push_back(c);
        }
    }
    if(!cur.empty())
    {
        out.push_back(std::stoi(cur));
    }
    return out;
}

bool is_supported_row_order(const std::string& value)
{
    return value == "original" || value == "first-page" || value == "auto-first-page" ||
           value == "first-2-pages" || value == "first-4-pages" || value == "lexicographic" ||
           value == "prefix-hash-2" || value == "prefix-hash-4" || value == "lcp-bucket";
}

bool is_supported_restore_mode(const std::string& value)
{
    return value == "row-indices" || value == "explicit-copy";
}

Args parse_args(int argc, char** argv)
{
    Args args;
    for(int i = 1; i < argc; ++i)
    {
        const std::string key = argv[i];
        auto need_value = [&](const char* name) -> std::string {
            if(i + 1 >= argc)
            {
                throw std::runtime_error(std::string("missing value for ") + name);
            }
            return argv[++i];
        };
        if(key == "--trace")
            args.trace_path = need_value("--trace");
        else if(key == "--page-locality")
            args.page_locality = need_value("--page-locality");
        else if(key == "--strategy")
            args.strategy = need_value("--strategy");
        else if(key == "--row-order")
            args.row_order = need_value("--row-order");
        else if(key == "--restore-mode")
            args.restore_mode = need_value("--restore-mode");
        else if(key == "--classes")
            args.classes = parse_int_list(need_value("--classes"));
        else if(key == "--output")
            args.output_csv = need_value("--output");
        else if(key == "--chunk-tokens")
            args.chunk_tokens = std::stoi(need_value("--chunk-tokens"));
        else if(key == "--kv-pages")
            args.kv_pages = std::stoi(need_value("--kv-pages"));
        else if(key == "--hot-pages")
            args.hot_pages = std::stoi(need_value("--hot-pages"));
        else if(key == "--physical-superblock")
            args.physical_superblock = std::stoi(need_value("--physical-superblock"));
        else if(key == "--seed")
            args.seed = std::stoi(need_value("--seed"));
        else if(key == "--value-dim")
            args.value_dim = std::stoi(need_value("--value-dim"));
        else if(key == "--work-heads")
            args.work_heads = std::stoi(need_value("--work-heads"));
        else if(key == "--kv-page-tokens")
            args.kv_page_tokens = std::stoi(need_value("--kv-page-tokens"));
        else if(key == "--limit-traces")
            args.limit_traces = std::stoi(need_value("--limit-traces"));
        else if(key == "--warmup")
            args.warmup = std::stoi(need_value("--warmup"));
        else if(key == "--iters")
            args.iters = std::stoi(need_value("--iters"));
        else if(key == "--actual-scale")
            args.actual_scale = std::stod(need_value("--actual-scale"));
        else if(key == "--auto-first-page-max-unique-ratio")
            args.auto_first_page_max_unique_ratio =
                std::stod(need_value("--auto-first-page-max-unique-ratio"));
        else if(key == "--auto-first-page-max-window128-unique-ratio")
            args.auto_first_page_max_window128_unique_ratio =
                std::stod(need_value("--auto-first-page-max-window128-unique-ratio"));
        else if(key == "--auto-first-page-min-adjacent-hit")
            args.auto_first_page_min_adjacent_hit =
                std::stod(need_value("--auto-first-page-min-adjacent-hit"));
        else if(key == "--auto-first-page-max-window128-unique")
            args.auto_first_page_max_window128_unique =
                std::stod(need_value("--auto-first-page-max-window128-unique"));
        else if(key == "--auto-first-page-min-lcp-mean")
            args.auto_first_page_min_lcp_mean =
                std::stod(need_value("--auto-first-page-min-lcp-mean"));
        else if(key == "--auto-first-page-min-rows")
            args.auto_first_page_min_rows = std::stoi(need_value("--auto-first-page-min-rows"));
        else if(key == "--scheduler-reuse-metadata-buffers")
            args.scheduler_reuse_metadata_buffers = true;
        else
            throw std::runtime_error("unknown argument: " + key);
    }
    if(args.classes.empty())
    {
        throw std::runtime_error("at least one capacity class is required");
    }
    if(args.physical_superblock <= 0)
    {
        throw std::runtime_error("--physical-superblock must be positive");
    }
    if(!is_supported_row_order(args.row_order))
    {
        throw std::runtime_error(
            "--row-order must be one of original, first-page, first-2-pages, first-4-pages, "
            "lexicographic, prefix-hash-2, prefix-hash-4, lcp-bucket, auto-first-page");
    }
    if(!is_supported_restore_mode(args.restore_mode))
    {
        throw std::runtime_error("--restore-mode must be row-indices or explicit-copy");
    }
    std::sort(args.classes.begin(), args.classes.end());
    return args;
}

double percentile(std::vector<int> values, double q)
{
    if(values.empty())
    {
        return 0.0;
    }
    std::sort(values.begin(), values.end());
    const double pos = q * static_cast<double>(values.size() - 1);
    const auto lo = static_cast<size_t>(pos);
    const auto hi = std::min(lo + 1, values.size() - 1);
    const double frac = pos - static_cast<double>(lo);
    return static_cast<double>(values[lo]) * (1.0 - frac) + static_cast<double>(values[hi]) * frac;
}

std::vector<int> select_capacities(const std::vector<int>& actual, const Args& args)
{
    std::vector<int> caps;
    caps.reserve(actual.size());
    if(args.strategy == "single_max")
    {
        const int max_actual = *std::max_element(actual.begin(), actual.end());
        caps.assign(actual.size(), max_actual);
        return caps;
    }
    if(args.strategy != "capacity_class")
    {
        throw std::runtime_error("supported strategies: single_max, capacity_class");
    }
    for(int x : actual)
    {
        int chosen = args.classes.back();
        for(int c : args.classes)
        {
            if(x <= c)
            {
                chosen = c;
                break;
            }
        }
        caps.push_back(chosen);
    }
    return caps;
}

struct Group
{
    int capacity = 0;
    std::vector<int> rows;
    std::vector<int> actual;
    int* d_rows = nullptr;
    int* d_actual = nullptr;
};

struct RowOrderMetrics
{
    int rows = 0;
    int first_page_unique = 0;
    double first_page_unique_ratio = 1.0;
    double adjacent_first_page_hit_ratio = 0.0;
    double first_page_unique_w128_p50 = 128.0;
    double first_page_unique_w128_ratio_p50 = 1.0;
    double adjacent_lcp_mean = 0.0;
};

double percentile_double(std::vector<double> values, double q)
{
    if(values.empty())
    {
        return 0.0;
    }
    std::sort(values.begin(), values.end());
    const double pos = q * static_cast<double>(values.size() - 1);
    const auto lo = static_cast<size_t>(pos);
    const auto hi = std::min(lo + 1, values.size() - 1);
    const double frac = pos - static_cast<double>(lo);
    return values[lo] * (1.0 - frac) + values[hi] * frac;
}

RowOrderMetrics compute_row_order_metrics(const std::vector<int>& block_table,
                                          int num_rows,
                                          int max_pages_per_seq)
{
    RowOrderMetrics metrics;
    metrics.rows = num_rows;
    if(num_rows <= 0)
    {
        return metrics;
    }
    std::vector<int> first_pages(num_rows);
    for(int row = 0; row < num_rows; ++row)
    {
        first_pages[row] = block_table[static_cast<size_t>(row) * max_pages_per_seq];
    }
    std::set<int> unique(first_pages.begin(), first_pages.end());
    metrics.first_page_unique = static_cast<int>(unique.size());
    metrics.first_page_unique_ratio =
        static_cast<double>(metrics.first_page_unique) / static_cast<double>(num_rows);
    int adjacent_hits = 0;
    for(int row = 1; row < num_rows; ++row)
    {
        adjacent_hits += first_pages[row] == first_pages[row - 1] ? 1 : 0;
    }
    metrics.adjacent_first_page_hit_ratio =
        num_rows > 1 ? static_cast<double>(adjacent_hits) / static_cast<double>(num_rows - 1)
                     : 0.0;
    std::vector<double> window_unique;
    for(int start = 0; start < num_rows; start += 128)
    {
        const int end = std::min(start + 128, num_rows);
        std::set<int> window(first_pages.begin() + start, first_pages.begin() + end);
        window_unique.push_back(static_cast<double>(window.size()));
    }
    metrics.first_page_unique_w128_p50 = percentile_double(window_unique, 0.50);
    metrics.first_page_unique_w128_ratio_p50 = metrics.first_page_unique_w128_p50 / 128.0;
    int64_t total_lcp = 0;
    for(int row = 1; row < num_rows; ++row)
    {
        int lcp = 0;
        for(int page = 0; page < max_pages_per_seq; ++page)
        {
            const int lhs = block_table[static_cast<size_t>(row - 1) * max_pages_per_seq + page];
            const int rhs = block_table[static_cast<size_t>(row) * max_pages_per_seq + page];
            if(lhs != rhs)
            {
                break;
            }
            ++lcp;
        }
        total_lcp += lcp;
    }
    metrics.adjacent_lcp_mean =
        num_rows > 1 ? static_cast<double>(total_lcp) / static_cast<double>(num_rows - 1) : 0.0;
    return metrics;
}

std::string resolve_row_order(const Args& args, const RowOrderMetrics& metrics)
{
    if(args.row_order != "auto-first-page")
    {
        return args.row_order;
    }
    if(metrics.rows < args.auto_first_page_min_rows)
    {
        return "original";
    }
    if(metrics.first_page_unique_ratio <= args.auto_first_page_max_unique_ratio ||
       metrics.first_page_unique_w128_ratio_p50 <= args.auto_first_page_max_window128_unique_ratio ||
       metrics.adjacent_first_page_hit_ratio >= args.auto_first_page_min_adjacent_hit ||
       metrics.adjacent_lcp_mean >= args.auto_first_page_min_lcp_mean ||
       metrics.first_page_unique_w128_p50 <= args.auto_first_page_max_window128_unique)
    {
        return "first-page";
    }
    return "original";
}

std::vector<Group> make_groups(const std::vector<int>& actual,
                               const std::vector<int>& capacities,
                               const std::vector<std::vector<int64_t>>& order_key)
{
    std::vector<int> unique = capacities;
    std::sort(unique.begin(), unique.end());
    unique.erase(std::unique(unique.begin(), unique.end()), unique.end());
    std::vector<Group> groups;
    for(int cap : unique)
    {
        Group g;
        g.capacity = cap;
        for(size_t row = 0; row < actual.size(); ++row)
        {
            if(capacities[row] == cap)
            {
                g.rows.push_back(static_cast<int>(row));
            }
        }
        if(!g.rows.empty())
        {
            std::sort(g.rows.begin(), g.rows.end(), [&](int lhs, int rhs) {
                if(order_key[lhs] != order_key[rhs])
                {
                    return order_key[lhs] < order_key[rhs];
                }
                return lhs < rhs;
            });
            g.actual.reserve(g.rows.size());
            for(int row : g.rows)
            {
                g.actual.push_back(actual[row]);
            }
            groups.push_back(std::move(g));
        }
    }
    return groups;
}

uint64_t stable_prefix_hash(const std::vector<int>& block_table,
                            int row,
                            int max_pages_per_seq,
                            int prefix_pages)
{
    uint64_t value = 1469598103934665603ull;
    for(int page = 0; page < prefix_pages; ++page)
    {
        const int64_t item = page < max_pages_per_seq
                                 ? block_table[static_cast<size_t>(row) * max_pages_per_seq + page]
                                 : -1;
        value ^= static_cast<uint64_t>(item);
        value *= 1099511628211ull;
    }
    return value;
}

std::vector<std::vector<int64_t>> make_row_order_keys(const std::string& row_order,
                                                      const std::vector<int>& block_table,
                                                      int num_rows,
                                                      int max_pages_per_seq)
{
    std::vector<std::vector<int64_t>> keys(num_rows);
    for(int row = 0; row < num_rows; ++row)
    {
        if(row_order == "original")
        {
            keys[row] = {row};
        }
        else if(row_order == "first-page")
        {
            keys[row] = {block_table[static_cast<size_t>(row) * max_pages_per_seq]};
        }
        else if(row_order == "first-2-pages" || row_order == "first-4-pages")
        {
            const int prefix_pages = row_order == "first-2-pages" ? 2 : 4;
            keys[row].reserve(prefix_pages);
            for(int page = 0; page < prefix_pages; ++page)
            {
                keys[row].push_back(page < max_pages_per_seq
                                        ? block_table[static_cast<size_t>(row) *
                                                      max_pages_per_seq + page]
                                        : -1);
            }
        }
        else if(row_order == "prefix-hash-2" || row_order == "prefix-hash-4")
        {
            const int prefix_pages = row_order == "prefix-hash-2" ? 2 : 4;
            keys[row] = {static_cast<int64_t>(
                stable_prefix_hash(block_table, row, max_pages_per_seq, prefix_pages) &
                0x7fffffffffffffffull)};
        }
        else if(row_order == "lexicographic" || row_order == "lcp-bucket")
        {
            keys[row].reserve(max_pages_per_seq);
            for(int page = 0; page < max_pages_per_seq; ++page)
            {
                keys[row].push_back(
                    block_table[static_cast<size_t>(row) * max_pages_per_seq + page]);
            }
        }
        else
        {
            throw std::runtime_error("unsupported row order: " + row_order);
        }
    }
    return keys;
}

std::vector<int> flatten_group_rows(const std::vector<Group>& groups)
{
    std::vector<int> rows;
    for(const auto& group : groups)
    {
        rows.insert(rows.end(), group.rows.begin(), group.rows.end());
    }
    return rows;
}

std::vector<int> flatten_group_actual(const std::vector<Group>& groups)
{
    std::vector<int> actual;
    for(const auto& group : groups)
    {
        actual.insert(actual.end(), group.actual.begin(), group.actual.end());
    }
    return actual;
}

template <typename T>
T* copy_to_device(const std::vector<T>& host)
{
    T* ptr = nullptr;
    HIP_CHECK(hipMalloc(&ptr, host.size() * sizeof(T)));
    HIP_CHECK(hipMemcpy(ptr, host.data(), host.size() * sizeof(T), hipMemcpyHostToDevice));
    return ptr;
}

template <typename T>
void copy_to_existing_device(T* ptr, const std::vector<T>& host)
{
    HIP_CHECK(hipMemcpy(ptr, host.data(), host.size() * sizeof(T), hipMemcpyHostToDevice));
}

void launch_init(uint32_t* data, int64_t n, uint32_t seed)
{
    const int block = 256;
    const int grid = static_cast<int>(std::min<int64_t>((n + block - 1) / block, 65535));
    init_packed_bf16_kernel<<<grid, block>>>(data, n, seed);
    HIP_CHECK(hipGetLastError());
}

void launch_groups(const std::vector<Group>& groups,
                   float* chunk_m,
                   float* chunk_l,
                   float* chunk_acc,
                   const uint32_t* k_pool,
                   const uint32_t* v_pool,
                   const uint32_t* q_transforms,
                   const int* cache_seqlens,
                   const int* block_tables,
                   int64_t num_kv_pages,
                   int64_t num_kv_heads,
                   int64_t num_work_heads,
                   int64_t page_block_size,
                   int64_t max_pages_per_seq,
                   int64_t dim_dwords,
                   int64_t chunk_tokens,
                   int64_t max_chunks,
                   int64_t value_dim)
{
    const size_t shmem = static_cast<size_t>(kThreads * 2 + chunk_tokens) * sizeof(float);
    for(const auto& group : groups)
    {
        const dim3 grid(group.capacity, static_cast<unsigned int>(group.rows.size()));
        replay_paged_kv_chunk_softmax_standalone<<<grid, kThreads, shmem>>>(
            chunk_m,
            chunk_l,
            chunk_acc,
            k_pool,
            v_pool,
            q_transforms,
            group.d_actual,
            group.d_rows,
            cache_seqlens,
            block_tables,
            group.capacity,
            static_cast<int>(group.rows.size()),
            num_kv_pages,
            num_kv_heads,
            num_work_heads,
            page_block_size,
            max_pages_per_seq,
            dim_dwords,
            chunk_tokens,
            max_chunks,
            value_dim,
            1);
        HIP_CHECK(hipGetLastError());
    }
}

void launch_restore(float* sorted_output,
                    float* original_output,
                    const int* sorted_to_original,
                    int num_rows,
                    int num_work_heads,
                    int value_dim)
{
    const int block = 256;
    const int64_t total =
        static_cast<int64_t>(num_rows) * num_work_heads * static_cast<int64_t>(value_dim);
    const int grid = static_cast<int>(std::min<int64_t>((total + block - 1) / block, 65535));
    restore_sorted_rows_kernel<<<grid, block>>>(
        sorted_output, original_output, sorted_to_original, num_rows, num_work_heads, value_dim);
    HIP_CHECK(hipGetLastError());
}

void write_csv(const Args& args,
               const TraceMeta& meta,
               const std::vector<int>& actual,
               const std::vector<int>& capacities,
               const std::vector<Group>& groups,
               double event_ms,
               int64_t grid_threads,
               const std::string& effective_row_order,
               const RowOrderMetrics& row_order_metrics,
               const SchedulerTimings& scheduler_timings,
               double restore_event_ms)
{
    if(args.output_csv.empty())
    {
        return;
    }
    std::ofstream out(args.output_csv);
    out << "strategy,page_locality,row_order,effective_row_order,restore_mode,"
           "physical_superblock,scheduler_reuse_metadata_buffers,traces,actual_min,actual_p50,actual_p90,actual_max,"
           "total_actual_blocks,total_capacity_blocks,empty_blocks,empty_block_fraction,"
           "launch_count,grid_threads,event_ms,per_trace_us,page_block_size,num_kv_heads,"
           "head_dim,chunk_tokens,value_dim,first_page_unique,first_page_unique_ratio,"
           "adjacent_first_page_hit_ratio,first_page_unique_w128_p50,"
           "first_page_unique_w128_ratio_p50,adjacent_lcp_mean,scheduler_metrics_ms,"
           "scheduler_row_order_key_ms,scheduler_group_build_ms,scheduler_group_h2d_ms,"
           "scheduler_setup_ms,restore_event_ms,online_e2e_ms\n";
    const int total_actual = std::accumulate(actual.begin(), actual.end(), 0);
    const int total_capacity = std::accumulate(capacities.begin(), capacities.end(), 0);
    const int empty = total_capacity - total_actual;
    out << args.strategy << "," << args.page_locality << "," << args.row_order << ","
        << effective_row_order << "," << args.restore_mode << ","
        << args.physical_superblock << ","
        << (args.scheduler_reuse_metadata_buffers ? 1 : 0) << ","
        << actual.size() << ","
        << *std::min_element(actual.begin(), actual.end()) << "," << percentile(actual, 0.50)
        << "," << percentile(actual, 0.90) << "," << *std::max_element(actual.begin(), actual.end())
        << "," << total_actual << "," << total_capacity << "," << empty << ","
        << std::setprecision(12)
        << (total_capacity ? static_cast<double>(empty) / static_cast<double>(total_capacity) : 0.0)
        << "," << groups.size() << "," << grid_threads << "," << event_ms << ","
        << (event_ms * 1000.0 / static_cast<double>(actual.size())) << ","
        << meta.page_block_size << "," << meta.num_kv_heads << "," << meta.head_dim << ","
        << args.chunk_tokens << "," << args.value_dim << "," << row_order_metrics.first_page_unique
        << "," << row_order_metrics.first_page_unique_ratio << ","
        << row_order_metrics.adjacent_first_page_hit_ratio << ","
        << row_order_metrics.first_page_unique_w128_p50 << ","
        << row_order_metrics.first_page_unique_w128_ratio_p50 << ","
        << row_order_metrics.adjacent_lcp_mean << ","
        << scheduler_timings.metrics_ms << "," << scheduler_timings.row_order_key_ms << ","
        << scheduler_timings.group_build_ms << "," << scheduler_timings.group_h2d_ms << ","
        << scheduler_timings.scheduler_setup_ms << "," << restore_event_ms << ","
        << (scheduler_timings.scheduler_setup_ms + event_ms + restore_event_ms) << "\n";
}

} // namespace

int main(int argc, char** argv)
{
    try
    {
        Args args = parse_args(argc, argv);
        TraceMeta meta = load_trace(args.trace_path);
        if(args.limit_traces > 0 && args.limit_traces < static_cast<int>(meta.seqlens.size()))
        {
            meta.seqlens.resize(args.limit_traces);
            meta.block_ids.resize(args.limit_traces);
            meta.block_scopes.resize(args.limit_traces);
        }
        if(args.kv_page_tokens > 0)
        {
            meta.page_block_size = args.kv_page_tokens;
        }
        const int num_rows = static_cast<int>(meta.seqlens.size());
        const int num_kv_heads = meta.num_kv_heads;
        const bool use_trace_blocks = args.page_locality == "trace";
        if(use_trace_blocks && args.kv_page_tokens > 0 && args.kv_page_tokens != meta.page_block_size)
        {
            throw std::runtime_error(
                "--page-locality trace requires the trace block_size_tokens; do not override --kv-page-tokens");
        }
        if(use_trace_blocks)
        {
            bool any = false;
            for(const auto& row : meta.block_ids)
            {
                any = any || !row.empty();
            }
            if(!any)
            {
                throw std::runtime_error(
                    "--page-locality trace requested, but trace rows do not contain block_ids");
            }
        }
        const int num_work_heads =
            args.work_heads > 0 ? args.work_heads
                                : std::max(1, static_cast<int>(std::llround(num_kv_heads *
                                                                             args.actual_scale)));
        const int dim_dwords = meta.head_dim / 2;
        if(meta.head_dim % 2 != 0 || args.value_dim <= 0 || args.value_dim > meta.head_dim)
        {
            throw std::runtime_error("invalid head_dim/value_dim");
        }
        const int max_seqlen = *std::max_element(meta.seqlens.begin(), meta.seqlens.end());
        const int max_pages_per_seq = std::max(1, (max_seqlen + meta.page_block_size - 1) /
                                                      meta.page_block_size);
        const int max_chunks = std::max(1, (max_seqlen + args.chunk_tokens - 1) /
                                                args.chunk_tokens);

        std::vector<int> actual;
        actual.reserve(meta.seqlens.size());
        for(int seqlen : meta.seqlens)
        {
            const int chunks = std::max(1, (seqlen + args.chunk_tokens - 1) / args.chunk_tokens);
            actual.push_back(static_cast<int>(std::ceil(chunks * num_kv_heads * args.actual_scale)));
        }
        std::vector<int> capacities = select_capacities(actual, args);

        std::vector<int> block_table(static_cast<size_t>(num_rows) * max_pages_per_seq, -1);
        std::map<std::pair<std::string, int>, int> trace_page_ids;
        if(use_trace_blocks && args.physical_superblock > 1)
        {
            std::map<std::string, std::set<int>> blocks_by_scope;
            for(int row = 0; row < num_rows; ++row)
            {
                const int pages = std::max(1, (meta.seqlens[row] + meta.page_block_size - 1) /
                                                 meta.page_block_size);
                const auto& row_blocks = meta.block_ids[row];
                if(static_cast<int>(row_blocks.size()) != pages)
                {
                    throw std::runtime_error("trace block_ids length mismatch at row " +
                                             std::to_string(row));
                }
                auto& ids = blocks_by_scope[meta.block_scopes[row]];
                for(int page = 0; page < pages; ++page)
                {
                    if(row_blocks[page] < 0)
                    {
                        throw std::runtime_error(
                            "--physical-superblock requires non-negative trace block_ids");
                    }
                    ids.insert(row_blocks[page]);
                }
            }

            int next_phys = 0;
            for(const auto& scope_and_ids : blocks_by_scope)
            {
                int current_group = std::numeric_limits<int>::min();
                int group_base = 0;
                for(int block_id : scope_and_ids.second)
                {
                    const int group = block_id / args.physical_superblock;
                    const int offset = block_id % args.physical_superblock;
                    if(group != current_group)
                    {
                        current_group = group;
                        group_base = next_phys;
                        next_phys += args.physical_superblock;
                    }
                    trace_page_ids.emplace(std::make_pair(scope_and_ids.first, block_id),
                                           group_base + offset);
                }
            }
        }
        for(int row = 0; row < num_rows; ++row)
        {
            const int pages = std::max(1, (meta.seqlens[row] + meta.page_block_size - 1) /
                                             meta.page_block_size);
            for(int page = 0; page < pages; ++page)
            {
                int phys = 0;
                if(use_trace_blocks)
                {
                    const auto& row_blocks = meta.block_ids[row];
                    if(static_cast<int>(row_blocks.size()) != pages)
                    {
                        throw std::runtime_error("trace block_ids length mismatch at row " +
                                                 std::to_string(row));
                    }
                    const auto key = std::make_pair(meta.block_scopes[row], row_blocks[page]);
                    if(args.physical_superblock > 1)
                    {
                        phys = trace_page_ids.at(key);
                    }
                    else
                    {
                        auto it = trace_page_ids.find(key);
                        if(it == trace_page_ids.end())
                        {
                            phys = static_cast<int>(trace_page_ids.size());
                            trace_page_ids.emplace(key, phys);
                        }
                        else
                        {
                            phys = it->second;
                        }
                    }
                }
                else if(args.page_locality == "contiguous")
                {
                    phys = row * max_pages_per_seq + page;
                }
                else if(args.page_locality == "page-cross")
                {
                    phys = page * num_rows + row;
                }
                else if(args.page_locality == "hot-page" && page < args.hot_pages)
                {
                    phys = page;
                }
                else
                {
                    phys = (row * 1103515245 + page * 12345 + args.seed) & 0x7fffffff;
                }
                block_table[static_cast<size_t>(row) * max_pages_per_seq + page] =
                    phys % args.kv_pages;
            }
        }
        int trace_required_pages = 0;
        if(use_trace_blocks)
        {
            for(const auto& item : trace_page_ids)
            {
                trace_required_pages = std::max(trace_required_pages, item.second + 1);
            }
        }
        if(use_trace_blocks && trace_required_pages > args.kv_pages)
        {
            args.kv_pages = trace_required_pages;
            for(int row = 0; row < num_rows; ++row)
            {
                const int pages = std::max(1, (meta.seqlens[row] + meta.page_block_size - 1) /
                                                 meta.page_block_size);
                for(int page = 0; page < pages; ++page)
                {
                    const auto key = std::make_pair(meta.block_scopes[row], meta.block_ids[row][page]);
                    block_table[static_cast<size_t>(row) * max_pages_per_seq + page] =
                        trace_page_ids.at(key);
                }
            }
        }

        void* hip_warmup = nullptr;
        int warmup_value = 0;
        HIP_CHECK(hipMalloc(&hip_warmup, 4));
        HIP_CHECK(hipMemcpy(hip_warmup, &warmup_value, sizeof(warmup_value), hipMemcpyHostToDevice));
        HIP_CHECK(hipFree(hip_warmup));
        HIP_CHECK(hipDeviceSynchronize());

        int *prealloc_rows_all = nullptr, *prealloc_actual_all = nullptr;
        if(args.scheduler_reuse_metadata_buffers)
        {
            HIP_CHECK(hipMalloc(&prealloc_rows_all, static_cast<size_t>(num_rows) * sizeof(int)));
            HIP_CHECK(hipMalloc(&prealloc_actual_all, static_cast<size_t>(num_rows) * sizeof(int)));
            HIP_CHECK(hipDeviceSynchronize());
        }

        SchedulerTimings scheduler_timings;
        const double scheduler_start_ms = host_now_ms();

        double stage_start_ms = host_now_ms();
        const RowOrderMetrics row_order_metrics =
            compute_row_order_metrics(block_table, num_rows, max_pages_per_seq);
        scheduler_timings.metrics_ms = host_now_ms() - stage_start_ms;
        const std::string effective_row_order = resolve_row_order(args, row_order_metrics);

        stage_start_ms = host_now_ms();
        std::vector<std::vector<int64_t>> order_key =
            make_row_order_keys(effective_row_order, block_table, num_rows, max_pages_per_seq);
        scheduler_timings.row_order_key_ms = host_now_ms() - stage_start_ms;

        stage_start_ms = host_now_ms();
        std::vector<Group> groups = make_groups(actual, capacities, order_key);
        std::vector<int> sorted_to_original = flatten_group_rows(groups);
        std::vector<int> grouped_actual = flatten_group_actual(groups);
        scheduler_timings.group_build_ms = host_now_ms() - stage_start_ms;

        stage_start_ms = host_now_ms();
        int* d_rows_all = nullptr;
        int* d_actual_all = nullptr;
        if(args.scheduler_reuse_metadata_buffers)
        {
            d_rows_all = prealloc_rows_all;
            d_actual_all = prealloc_actual_all;
            copy_to_existing_device(d_rows_all, sorted_to_original);
            copy_to_existing_device(d_actual_all, grouped_actual);
        }
        else
        {
            d_rows_all = copy_to_device(sorted_to_original);
            d_actual_all = copy_to_device(grouped_actual);
        }
        int* d_sorted_to_original = d_rows_all;
        size_t group_offset = 0;
        for(auto& group : groups)
        {
            group.d_rows = d_rows_all + group_offset;
            group.d_actual = d_actual_all + group_offset;
            group_offset += group.rows.size();
        }
        HIP_CHECK(hipDeviceSynchronize());
        scheduler_timings.group_h2d_ms = host_now_ms() - stage_start_ms;
        scheduler_timings.scheduler_setup_ms = host_now_ms() - scheduler_start_ms;
        int* d_cache_seqlens = copy_to_device(meta.seqlens);
        int* d_block_tables = copy_to_device(block_table);

        const int64_t pool_dwords = static_cast<int64_t>(args.kv_pages) * num_kv_heads *
                                    meta.page_block_size * dim_dwords;
        const int64_t q_dwords = static_cast<int64_t>(num_work_heads) * dim_dwords;
        const int64_t chunk_count = static_cast<int64_t>(num_rows) * num_work_heads * max_chunks;
        const int64_t acc_count = chunk_count * args.value_dim;

        uint32_t *d_k = nullptr, *d_v = nullptr, *d_q = nullptr;
        float *d_m = nullptr, *d_l = nullptr, *d_acc = nullptr;
        float *d_sorted_output = nullptr, *d_original_output = nullptr;
        HIP_CHECK(hipMalloc(&d_k, pool_dwords * sizeof(uint32_t)));
        HIP_CHECK(hipMalloc(&d_v, pool_dwords * sizeof(uint32_t)));
        HIP_CHECK(hipMalloc(&d_q, q_dwords * sizeof(uint32_t)));
        HIP_CHECK(hipMalloc(&d_m, chunk_count * sizeof(float)));
        HIP_CHECK(hipMalloc(&d_l, chunk_count * sizeof(float)));
        HIP_CHECK(hipMalloc(&d_acc, acc_count * sizeof(float)));
        if(args.restore_mode == "explicit-copy")
        {
            const int64_t output_count =
                static_cast<int64_t>(num_rows) * num_work_heads * args.value_dim;
            HIP_CHECK(hipMalloc(&d_sorted_output, output_count * sizeof(float)));
            HIP_CHECK(hipMalloc(&d_original_output, output_count * sizeof(float)));
            HIP_CHECK(hipMemset(d_sorted_output, 0, output_count * sizeof(float)));
            HIP_CHECK(hipMemset(d_original_output, 0, output_count * sizeof(float)));
        }

        launch_init(d_k, pool_dwords, 1);
        launch_init(d_v, pool_dwords, 2);
        launch_init(d_q, q_dwords, 3);
        HIP_CHECK(hipDeviceSynchronize());

        auto run_once = [&]() {
            launch_groups(groups,
                          d_m,
                          d_l,
                          d_acc,
                          d_k,
                          d_v,
                          d_q,
                          d_cache_seqlens,
                          d_block_tables,
                          args.kv_pages,
                          num_kv_heads,
                          num_work_heads,
                          meta.page_block_size,
                          max_pages_per_seq,
                          dim_dwords,
                          args.chunk_tokens,
                          max_chunks,
                          args.value_dim);
        };

        for(int i = 0; i < args.warmup; ++i)
        {
            run_once();
        }
        HIP_CHECK(hipDeviceSynchronize());

        std::vector<float> times;
        times.reserve(args.iters);
        hipEvent_t start = nullptr, stop = nullptr;
        HIP_CHECK(hipEventCreate(&start));
        HIP_CHECK(hipEventCreate(&stop));
        for(int i = 0; i < args.iters; ++i)
        {
            HIP_CHECK(hipEventRecord(start));
            run_once();
            HIP_CHECK(hipEventRecord(stop));
            HIP_CHECK(hipEventSynchronize(stop));
            float ms = 0.0f;
            HIP_CHECK(hipEventElapsedTime(&ms, start, stop));
            times.push_back(ms);
        }
        std::sort(times.begin(), times.end());
        const double event_ms = times[times.size() / 2];

        double restore_event_ms = 0.0;
        if(args.restore_mode == "explicit-copy")
        {
            for(int i = 0; i < args.warmup; ++i)
            {
                launch_restore(d_sorted_output,
                               d_original_output,
                               d_sorted_to_original,
                               num_rows,
                               num_work_heads,
                               args.value_dim);
            }
            HIP_CHECK(hipDeviceSynchronize());
            std::vector<float> restore_times;
            restore_times.reserve(args.iters);
            for(int i = 0; i < args.iters; ++i)
            {
                HIP_CHECK(hipEventRecord(start));
                launch_restore(d_sorted_output,
                               d_original_output,
                               d_sorted_to_original,
                               num_rows,
                               num_work_heads,
                               args.value_dim);
                HIP_CHECK(hipEventRecord(stop));
                HIP_CHECK(hipEventSynchronize(stop));
                float ms = 0.0f;
                HIP_CHECK(hipEventElapsedTime(&ms, start, stop));
                restore_times.push_back(ms);
            }
            std::sort(restore_times.begin(), restore_times.end());
            restore_event_ms = restore_times[restore_times.size() / 2];
        }

        const int total_actual = std::accumulate(actual.begin(), actual.end(), 0);
        const int total_capacity = std::accumulate(capacities.begin(), capacities.end(), 0);
        const int empty = total_capacity - total_actual;
        int64_t grid_threads = 0;
        for(const auto& group : groups)
        {
            grid_threads += static_cast<int64_t>(group.capacity) *
                            static_cast<int64_t>(group.rows.size()) * kThreads;
        }

        std::cout << "standalone_paged_full_producer"
                  << " strategy=" << args.strategy
                  << " locality=" << args.page_locality
                  << " row_order=" << args.row_order
                  << " effective=" << effective_row_order
                  << " restore_mode=" << args.restore_mode
                  << " physical_superblock=" << args.physical_superblock
                  << " traces=" << num_rows
                  << " actual_min=" << *std::min_element(actual.begin(), actual.end())
                  << " actual_p50=" << percentile(actual, 0.50)
                  << " actual_p90=" << percentile(actual, 0.90)
                  << " actual_max=" << *std::max_element(actual.begin(), actual.end())
                  << " total_actual=" << total_actual
                  << " total_capacity=" << total_capacity
                  << " empty_frac="
                  << (total_capacity ? static_cast<double>(empty) / total_capacity : 0.0)
                  << " launches=" << groups.size()
                  << " grid_threads=" << grid_threads
                  << " event_ms=" << event_ms
                  << " restore_event_ms=" << restore_event_ms
                  << " scheduler_setup_ms=" << scheduler_timings.scheduler_setup_ms
                  << " online_e2e_ms="
                  << (scheduler_timings.scheduler_setup_ms + event_ms + restore_event_ms)
                  << " per_trace_us=" << (event_ms * 1000.0 / num_rows)
                  << " page_block_size=" << meta.page_block_size
                  << " kv_heads=" << num_kv_heads
                  << " work_heads=" << num_work_heads
                  << " head_dim=" << meta.head_dim
                  << " value_dim=" << args.value_dim
                  << std::endl;

        write_csv(args,
                  meta,
                  actual,
                  capacities,
                  groups,
                  event_ms,
                  grid_threads,
                  effective_row_order,
                  row_order_metrics,
                  scheduler_timings,
                  restore_event_ms);

        HIP_CHECK(hipEventDestroy(start));
        HIP_CHECK(hipEventDestroy(stop));
        HIP_CHECK(hipFree(d_rows_all));
        HIP_CHECK(hipFree(d_actual_all));
        HIP_CHECK(hipFree(d_cache_seqlens));
        HIP_CHECK(hipFree(d_block_tables));
        HIP_CHECK(hipFree(d_k));
        HIP_CHECK(hipFree(d_v));
        HIP_CHECK(hipFree(d_q));
        HIP_CHECK(hipFree(d_m));
        HIP_CHECK(hipFree(d_l));
        HIP_CHECK(hipFree(d_acc));
        if(d_sorted_output)
        {
            HIP_CHECK(hipFree(d_sorted_output));
        }
        if(d_original_output)
        {
            HIP_CHECK(hipFree(d_original_output));
        }
    }
    catch(const std::exception& e)
    {
        std::cerr << "error: " << e.what() << std::endl;
        return 1;
    }
    return 0;
}
