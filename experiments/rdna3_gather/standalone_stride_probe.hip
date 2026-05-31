#include <hip/hip_runtime.h>

#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

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

struct Args
{
    int64_t footprint_mb = 1024;
    int64_t stride_bytes = 2 * 1024 * 1024;
    int64_t refs = 33'554'432;
    int loads_per_ref = 4;
    int blocks = 4096;
    int threads = 256;
    int warmup = 1;
    int iters = 5;
    std::string output_csv;
};

__global__ void init_u32_kernel(uint32_t* data, int64_t n, uint32_t seed)
{
    const int64_t stride = static_cast<int64_t>(blockDim.x) * gridDim.x;
    for(int64_t i = static_cast<int64_t>(blockIdx.x) * blockDim.x + threadIdx.x; i < n;
        i += stride)
    {
        data[i] = static_cast<uint32_t>(i) * 1664525u + seed * 1013904223u;
    }
}

__global__ void stride_probe_kernel(const uint32_t* __restrict__ data,
                                    uint32_t* __restrict__ sink,
                                    int64_t elems,
                                    int64_t stride_elems,
                                    int64_t refs,
                                    int loads_per_ref)
{
    const int64_t tid = static_cast<int64_t>(blockIdx.x) * blockDim.x + threadIdx.x;
    const int64_t grid_stride = static_cast<int64_t>(blockDim.x) * gridDim.x;
    const int64_t clamped_stride = max<int64_t>(1, min<int64_t>(stride_elems, elems));
    const int64_t segments = max<int64_t>(1, elems / clamped_stride);
    const int64_t segment_elems = max<int64_t>(1, min<int64_t>(clamped_stride, elems));

    uint32_t acc = 0;
    for(int64_t r = tid; r < refs; r += grid_stride)
    {
        const int64_t segment = r % segments;
        const int64_t round = r / segments;
        const int64_t base = segment * clamped_stride;
        for(int j = 0; j < loads_per_ref; ++j)
        {
            const int64_t offset =
                (round * 131 + static_cast<int64_t>(j) * 17 + threadIdx.x) % segment_elems;
            int64_t idx = base + offset;
            if(idx >= elems)
            {
                idx %= elems;
            }
            acc += data[idx];
        }
    }
    sink[tid] = acc;
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
        if(key == "--footprint-mb")
            args.footprint_mb = std::stoll(need_value("--footprint-mb"));
        else if(key == "--stride-bytes")
            args.stride_bytes = std::stoll(need_value("--stride-bytes"));
        else if(key == "--refs")
            args.refs = std::stoll(need_value("--refs"));
        else if(key == "--loads-per-ref")
            args.loads_per_ref = std::stoi(need_value("--loads-per-ref"));
        else if(key == "--blocks")
            args.blocks = std::stoi(need_value("--blocks"));
        else if(key == "--threads")
            args.threads = std::stoi(need_value("--threads"));
        else if(key == "--warmup")
            args.warmup = std::stoi(need_value("--warmup"));
        else if(key == "--iters")
            args.iters = std::stoi(need_value("--iters"));
        else if(key == "--output")
            args.output_csv = need_value("--output");
        else
            throw std::runtime_error("unknown argument: " + key);
    }
    if(args.footprint_mb <= 0 || args.stride_bytes <= 0 || args.refs <= 0 ||
       args.loads_per_ref <= 0 || args.blocks <= 0 || args.threads <= 0 || args.iters <= 0)
    {
        throw std::runtime_error("all numeric arguments must be positive");
    }
    if(args.stride_bytes % static_cast<int64_t>(sizeof(uint32_t)) != 0)
    {
        throw std::runtime_error("--stride-bytes must be divisible by 4");
    }
    return args;
}

void write_csv(const Args& args, int64_t elems, double event_ms)
{
    if(args.output_csv.empty())
    {
        return;
    }
    const int64_t stride_elems = args.stride_bytes / static_cast<int64_t>(sizeof(uint32_t));
    const int64_t clamped_stride = std::max<int64_t>(1, std::min<int64_t>(stride_elems, elems));
    const int64_t segments = std::max<int64_t>(1, elems / clamped_stride);
    const double bytes_read =
        static_cast<double>(args.refs) * static_cast<double>(args.loads_per_ref) *
        static_cast<double>(sizeof(uint32_t));
    std::ofstream out(args.output_csv);
    out << "footprint_mb,stride_bytes,segments,refs,loads_per_ref,blocks,threads,"
           "bytes_read,event_ms,effective_gib_s,ns_per_load\n";
    out << args.footprint_mb << "," << args.stride_bytes << "," << segments << ","
        << args.refs << "," << args.loads_per_ref << "," << args.blocks << ","
        << args.threads << "," << std::fixed << std::setprecision(0) << bytes_read << ","
        << std::setprecision(6) << event_ms << ","
        << (bytes_read / (1024.0 * 1024.0 * 1024.0)) / (event_ms / 1000.0) << ","
        << (event_ms * 1.0e6) /
               (static_cast<double>(args.refs) * static_cast<double>(args.loads_per_ref))
        << "\n";
}

} // namespace

int main(int argc, char** argv)
{
    try
    {
        const Args args = parse_args(argc, argv);
        const int64_t bytes = args.footprint_mb * 1024ll * 1024ll;
        const int64_t elems = bytes / static_cast<int64_t>(sizeof(uint32_t));
        const int64_t stride_elems = args.stride_bytes / static_cast<int64_t>(sizeof(uint32_t));

        uint32_t* d_data = nullptr;
        uint32_t* d_sink = nullptr;
        HIP_CHECK(hipMalloc(&d_data, elems * sizeof(uint32_t)));
        HIP_CHECK(hipMalloc(&d_sink, static_cast<size_t>(args.blocks) * args.threads *
                                         sizeof(uint32_t)));
        init_u32_kernel<<<args.blocks, args.threads>>>(d_data, elems, 17);
        HIP_CHECK(hipGetLastError());
        HIP_CHECK(hipDeviceSynchronize());

        auto run_once = [&]() {
            stride_probe_kernel<<<args.blocks, args.threads>>>(
                d_data, d_sink, elems, stride_elems, args.refs, args.loads_per_ref);
            HIP_CHECK(hipGetLastError());
        };

        for(int i = 0; i < args.warmup; ++i)
        {
            run_once();
        }
        HIP_CHECK(hipDeviceSynchronize());

        hipEvent_t start = nullptr;
        hipEvent_t stop = nullptr;
        HIP_CHECK(hipEventCreate(&start));
        HIP_CHECK(hipEventCreate(&stop));
        std::vector<float> times;
        times.reserve(args.iters);
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
        const double loads = static_cast<double>(args.refs) * args.loads_per_ref;
        const double bytes_read = loads * sizeof(uint32_t);
        const int64_t segments = std::max<int64_t>(
            1, elems / std::max<int64_t>(1, std::min<int64_t>(stride_elems, elems)));

        std::cout << "standalone_stride_probe"
                  << " footprint_mb=" << args.footprint_mb
                  << " stride_bytes=" << args.stride_bytes
                  << " segments=" << segments
                  << " refs=" << args.refs
                  << " loads_per_ref=" << args.loads_per_ref
                  << " event_ms=" << event_ms
                  << " effective_gib_s="
                  << (bytes_read / (1024.0 * 1024.0 * 1024.0)) / (event_ms / 1000.0)
                  << " ns_per_load=" << (event_ms * 1.0e6) / loads << std::endl;

        write_csv(args, elems, event_ms);

        HIP_CHECK(hipEventDestroy(start));
        HIP_CHECK(hipEventDestroy(stop));
        HIP_CHECK(hipFree(d_data));
        HIP_CHECK(hipFree(d_sink));
    }
    catch(const std::exception& e)
    {
        std::cerr << "error: " << e.what() << std::endl;
        return 1;
    }
    return 0;
}
