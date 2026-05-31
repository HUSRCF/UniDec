#include <torch/extension.h>

#include <ATen/cuda/CUDAContext.h>
#include <c10/cuda/CUDACachingAllocator.h>
#include <c10/cuda/CUDAGuard.h>
#include <hip/hip_runtime.h>

#include <cstdlib>
#include <cstdint>
#include <cmath>
#include <fstream>
#include <limits>
#include <mutex>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>

#ifndef RDNA3_GATHER_ENABLE_DIRECT_LDS
#define RDNA3_GATHER_ENABLE_DIRECT_LDS 0
#endif

#if RDNA3_GATHER_ENABLE_DIRECT_LDS
#include <ck_tile/core/arch/amd_buffer_addressing.hpp>
#endif

namespace {

constexpr int kThreads = 256;

#define CHECK_CUDA(x) TORCH_CHECK((x).is_cuda(), #x " must be a CUDA/HIP tensor")
#define CHECK_CONTIGUOUS(x) TORCH_CHECK((x).is_contiguous(), #x " must be contiguous")

__device__ __forceinline__ bool row_is_valid(int row, int64_t num_rows)
{
    return row >= 0 && static_cast<int64_t>(row) < num_rows;
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

__device__ __forceinline__ float consume_packed_dword(uint32_t packed, int dtype_id)
{
    return packed_lane_to_float(packed, 0, dtype_id) + packed_lane_to_float(packed, 1, dtype_id);
}

__device__ __forceinline__ float dot_packed_dword(uint32_t a, uint32_t b, int dtype_id)
{
    return packed_lane_to_float(a, 0, dtype_id) * packed_lane_to_float(b, 0, dtype_id) +
           packed_lane_to_float(a, 1, dtype_id) * packed_lane_to_float(b, 1, dtype_id);
}

__global__ void gather_global_kernel(const uint32_t* __restrict__ features,
                                     const int* __restrict__ indices,
                                     uint32_t* __restrict__ output,
                                     int64_t num_rows,
                                     int64_t num_tasks,
                                     int64_t tile_tokens,
                                     int64_t dim_dwords,
                                     int64_t total_dwords)
{
    const int64_t stride = static_cast<int64_t>(blockDim.x) * gridDim.x;

    for(int64_t linear = static_cast<int64_t>(blockIdx.x) * blockDim.x + threadIdx.x;
        linear < total_dwords;
        linear += stride)
    {
        const int64_t tile_elems = tile_tokens * dim_dwords;
        const int64_t task       = linear / tile_elems;
        const int64_t rem        = linear - task * tile_elems;
        const int64_t token      = rem / dim_dwords;
        const int64_t dword      = rem - token * dim_dwords;
        const int row            = indices[task * tile_tokens + token];

        uint32_t value = 0;
        if(row_is_valid(row, num_rows))
        {
            value = features[static_cast<int64_t>(row) * dim_dwords + dword];
        }
        output[linear] = value;
    }
}

__global__ void gather_vgpr_lds_kernel(const uint32_t* __restrict__ features,
                                       const int* __restrict__ indices,
                                       uint32_t* __restrict__ output,
                                       int64_t num_rows,
                                       int64_t tile_tokens,
                                       int64_t dim_dwords,
                                       int64_t tile_dwords)
{
    extern __shared__ uint32_t smem[];
    const int64_t task = blockIdx.x;

    for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
    {
        const int64_t token = elem / dim_dwords;
        const int64_t dword = elem - token * dim_dwords;
        const int row       = indices[task * tile_tokens + token];

        uint32_t value = 0;
        if(row_is_valid(row, num_rows))
        {
            value = features[static_cast<int64_t>(row) * dim_dwords + dword];
        }
        smem[elem] = value;
    }

    __syncthreads();

    const int64_t out_base = task * tile_dwords;
    for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
    {
        output[out_base + elem] = smem[elem];
    }
}

__device__ __forceinline__ void wait_for_direct_lds_candidate()
{
#if RDNA3_GATHER_ENABLE_DIRECT_LDS && defined(__gfx11__) && !CK_TILE_USE_BUFFER_ADDRESSING_BUILTIN
    ck_tile::async_buffer_load_fence(0);
#endif
}

#if RDNA3_GATHER_ENABLE_DIRECT_LDS && defined(__gfx11__) && !CK_TILE_USE_BUFFER_ADDRESSING_BUILTIN
__device__ __forceinline__ void direct_load_dword_to_lds_inline(const ck_tile::int32x4_t& src_resource,
                                                                uint32_t global_offset_bytes,
                                                                uint32_t* lds_ptr)
{
    const uint32_t lds_addr = ck_tile::amd_wave_read_first_lane(
        static_cast<uint32_t>(reinterpret_cast<uintptr_t>(lds_ptr)));
    asm volatile("s_mov_b32 m0, %0;\n\t"
                 "buffer_load_dword %1, %2, 0 offen lds;\n\t" ::"s"(lds_addr),
                 "v"(global_offset_bytes),
                 "s"(src_resource)
                 : "memory");
}
#endif

__global__ void gather_direct_lds_kernel(const uint32_t* __restrict__ features,
                                         const int* __restrict__ indices,
                                         uint32_t* __restrict__ output,
                                         int64_t num_rows,
                                         int64_t tile_tokens,
                                         int64_t dim_dwords,
                                         int64_t tile_dwords,
                                         int64_t feature_dwords)
{
    extern __shared__ uint32_t smem[];
    const int64_t task = blockIdx.x;

#if RDNA3_GATHER_ENABLE_DIRECT_LDS && defined(__gfx11__) && !CK_TILE_USE_BUFFER_ADDRESSING_BUILTIN
    const auto src_resource = ck_tile::make_wave_buffer_resource(
        features, static_cast<uint32_t>(feature_dwords * sizeof(uint32_t)));
#endif

    for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
    {
        smem[elem] = 0;
    }
    __syncthreads();

    for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
    {
        const int64_t token = elem / dim_dwords;
        const int64_t dword = elem - token * dim_dwords;
        const int row       = indices[task * tile_tokens + token];
        const bool valid    = row_is_valid(row, num_rows);

#if RDNA3_GATHER_ENABLE_DIRECT_LDS && defined(__gfx11__) && !CK_TILE_USE_BUFFER_ADDRESSING_BUILTIN
        const auto offset_bytes = valid
                                      ? static_cast<uint32_t>(
                                            (static_cast<int64_t>(row) * dim_dwords + dword) *
                                            static_cast<int64_t>(sizeof(uint32_t)))
                                      : 0x80000000u;
        direct_load_dword_to_lds_inline(src_resource, offset_bytes, smem + elem);
#else
        if(valid)
        {
            smem[elem] = features[static_cast<int64_t>(row) * dim_dwords + dword];
        }
#endif
    }

    wait_for_direct_lds_candidate();
    __syncthreads();

    const int64_t out_base = task * tile_dwords;
    for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
    {
        output[out_base + elem] = smem[elem];
    }
}

__global__ void fused_global_sum_kernel(const uint32_t* __restrict__ features,
                                        const int* __restrict__ indices,
                                        float* __restrict__ output,
                                        int64_t num_rows,
                                        int64_t tile_tokens,
                                        int64_t dim_dwords,
                                        int64_t tile_dwords,
                                        int consumer_passes,
                                        int dtype_id)
{
    extern __shared__ float partial[];
    const int64_t task = blockIdx.x;

    float acc = 0.0f;
    for(int pass = 0; pass < consumer_passes; ++pass)
    {
        const float weight = static_cast<float>(pass + 1);
        for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
        {
            const int64_t token = elem / dim_dwords;
            const int64_t dword = elem - token * dim_dwords;
            const int row       = indices[task * tile_tokens + token];

            uint32_t packed = 0;
            if(row_is_valid(row, num_rows))
            {
                packed = features[static_cast<int64_t>(row) * dim_dwords + dword];
            }
            acc += weight * consume_packed_dword(packed, dtype_id);
        }
    }

    partial[threadIdx.x] = acc;
    __syncthreads();

    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            partial[threadIdx.x] += partial[threadIdx.x + stride];
        }
        __syncthreads();
    }

    if(threadIdx.x == 0)
    {
        output[task] = partial[0];
    }
}

__global__ void fused_lds_sum_kernel(const uint32_t* __restrict__ features,
                                     const int* __restrict__ indices,
                                     float* __restrict__ output,
                                     int64_t num_rows,
                                     int64_t tile_tokens,
                                     int64_t dim_dwords,
                                     int64_t tile_dwords,
                                     int consumer_passes,
                                     int dtype_id)
{
    extern __shared__ uint32_t smem_u32[];
    uint32_t* tile = smem_u32;
    float* partial =
        reinterpret_cast<float*>(tile + tile_dwords);
    const int64_t task = blockIdx.x;

    for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
    {
        const int64_t token = elem / dim_dwords;
        const int64_t dword = elem - token * dim_dwords;
        const int row       = indices[task * tile_tokens + token];

        uint32_t packed = 0;
        if(row_is_valid(row, num_rows))
        {
            packed = features[static_cast<int64_t>(row) * dim_dwords + dword];
        }
        tile[elem] = packed;
    }

    __syncthreads();

    float acc = 0.0f;
    for(int pass = 0; pass < consumer_passes; ++pass)
    {
        const float weight = static_cast<float>(pass + 1);
        for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
        {
            acc += weight * consume_packed_dword(tile[elem], dtype_id);
        }
    }

    partial[threadIdx.x] = acc;
    __syncthreads();

    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            partial[threadIdx.x] += partial[threadIdx.x + stride];
        }
        __syncthreads();
    }

    if(threadIdx.x == 0)
    {
        output[task] = partial[0];
    }
}

__global__ void dot_global_kernel(const uint32_t* __restrict__ features,
                                  const uint32_t* __restrict__ queries,
                                  const int* __restrict__ indices,
                                  float* __restrict__ output,
                                  int64_t num_rows,
                                  int64_t tile_tokens,
                                  int64_t dim_dwords,
                                  int64_t num_queries,
                                  int dtype_id)
{
    const int64_t task = blockIdx.x;
    const int64_t work_items = num_queries * tile_tokens;

    for(int64_t linear = threadIdx.x; linear < work_items; linear += blockDim.x)
    {
        const int64_t query = linear / tile_tokens;
        const int64_t token = linear - query * tile_tokens;
        const int row       = indices[task * tile_tokens + token];
        const bool valid    = row_is_valid(row, num_rows);

        const int64_t query_base = (task * num_queries + query) * dim_dwords;
        float acc = 0.0f;
        for(int64_t dword = 0; dword < dim_dwords; ++dword)
        {
            const uint32_t feature_packed =
                valid ? features[static_cast<int64_t>(row) * dim_dwords + dword] : 0;
            const uint32_t query_packed = queries[query_base + dword];
            acc += dot_packed_dword(feature_packed, query_packed, dtype_id);
        }

        output[(task * num_queries + query) * tile_tokens + token] = acc;
    }
}

__global__ void dot_lds_kernel(const uint32_t* __restrict__ features,
                               const uint32_t* __restrict__ queries,
                               const int* __restrict__ indices,
                               float* __restrict__ output,
                               int64_t num_rows,
                               int64_t tile_tokens,
                               int64_t dim_dwords,
                               int64_t tile_dwords,
                               int64_t num_queries,
                               int dtype_id)
{
    extern __shared__ uint32_t tile[];
    const int64_t task = blockIdx.x;

    for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
    {
        const int64_t token = elem / dim_dwords;
        const int64_t dword = elem - token * dim_dwords;
        const int row       = indices[task * tile_tokens + token];

        uint32_t packed = 0;
        if(row_is_valid(row, num_rows))
        {
            packed = features[static_cast<int64_t>(row) * dim_dwords + dword];
        }
        tile[elem] = packed;
    }

    __syncthreads();

    const int64_t work_items = num_queries * tile_tokens;
    for(int64_t linear = threadIdx.x; linear < work_items; linear += blockDim.x)
    {
        const int64_t query = linear / tile_tokens;
        const int64_t token = linear - query * tile_tokens;
        const int64_t query_base = (task * num_queries + query) * dim_dwords;
        const int64_t tile_base = token * dim_dwords;

        float acc = 0.0f;
        for(int64_t dword = 0; dword < dim_dwords; ++dword)
        {
            const uint32_t feature_packed = tile[tile_base + dword];
            const uint32_t query_packed = queries[query_base + dword];
            acc += dot_packed_dword(feature_packed, query_packed, dtype_id);
        }

        output[(task * num_queries + query) * tile_tokens + token] = acc;
    }
}

__global__ void graph_global_kernel(const uint32_t* __restrict__ features,
                                    const uint32_t* __restrict__ transforms,
                                    const int* __restrict__ indices,
                                    float* __restrict__ output,
                                    int64_t num_rows,
                                    int64_t tile_tokens,
                                    int64_t dim_dwords,
                                    int64_t tile_dwords,
                                    int64_t num_transforms,
                                    int dtype_id)
{
    extern __shared__ float partial[];
    const int64_t task_transform = blockIdx.x;
    const int64_t task           = task_transform / num_transforms;
    const int64_t transform      = task_transform - task * num_transforms;
    const int64_t transform_base = transform * dim_dwords;

    float acc = 0.0f;
    for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
    {
        const int64_t token = elem / dim_dwords;
        const int64_t dword = elem - token * dim_dwords;
        const int row       = indices[task * tile_tokens + token];

        uint32_t feature_packed = 0;
        if(row_is_valid(row, num_rows))
        {
            feature_packed = features[static_cast<int64_t>(row) * dim_dwords + dword];
        }
        const uint32_t transform_packed = transforms[transform_base + dword];
        acc += dot_packed_dword(feature_packed, transform_packed, dtype_id);
    }

    partial[threadIdx.x] = acc;
    __syncthreads();

    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            partial[threadIdx.x] += partial[threadIdx.x + stride];
        }
        __syncthreads();
    }

    if(threadIdx.x == 0)
    {
        output[task * num_transforms + transform] = partial[0];
    }
}

__global__ void graph_lds_kernel(const uint32_t* __restrict__ features,
                                 const uint32_t* __restrict__ transforms,
                                 const int* __restrict__ indices,
                                 float* __restrict__ output,
                                 int64_t num_rows,
                                 int64_t tile_tokens,
                                 int64_t dim_dwords,
                                 int64_t tile_dwords,
                                 int64_t num_transforms,
                                 int dtype_id)
{
    extern __shared__ uint32_t smem_u32[];
    uint32_t* tile = smem_u32;
    float* partial = reinterpret_cast<float*>(tile + tile_dwords);
    const int64_t task = blockIdx.x;

    for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
    {
        const int64_t token = elem / dim_dwords;
        const int64_t dword = elem - token * dim_dwords;
        const int row       = indices[task * tile_tokens + token];

        uint32_t packed = 0;
        if(row_is_valid(row, num_rows))
        {
            packed = features[static_cast<int64_t>(row) * dim_dwords + dword];
        }
        tile[elem] = packed;
    }

    __syncthreads();

    for(int64_t transform = 0; transform < num_transforms; ++transform)
    {
        const int64_t transform_base = transform * dim_dwords;
        float acc = 0.0f;
        for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
        {
            const int64_t dword = elem % dim_dwords;
            const uint32_t feature_packed = tile[elem];
            const uint32_t transform_packed = transforms[transform_base + dword];
            acc += dot_packed_dword(feature_packed, transform_packed, dtype_id);
        }

        partial[threadIdx.x] = acc;
        __syncthreads();

        for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
        {
            if(threadIdx.x < stride)
            {
                partial[threadIdx.x] += partial[threadIdx.x + stride];
            }
            __syncthreads();
        }

        if(threadIdx.x == 0)
        {
            output[task * num_transforms + transform] = partial[0];
        }
        __syncthreads();
    }
}

__global__ void graph_lds_chunked_kernel(const uint32_t* __restrict__ features,
                                         const uint32_t* __restrict__ transforms,
                                         const int* __restrict__ indices,
                                         float* __restrict__ output,
                                         int64_t num_rows,
                                         int64_t tile_tokens,
                                         int64_t dim_dwords,
                                         int64_t tile_dwords,
                                         int64_t num_transforms,
                                         int64_t num_transform_chunks,
                                         int64_t transform_chunk_size,
                                         int dtype_id)
{
    extern __shared__ uint32_t smem_u32[];
    uint32_t* tile = smem_u32;
    float* partial = reinterpret_cast<float*>(tile + tile_dwords);

    const int64_t task_chunk = blockIdx.x;
    const int64_t task       = task_chunk / num_transform_chunks;
    const int64_t chunk      = task_chunk - task * num_transform_chunks;
    const int64_t begin_transform = chunk * transform_chunk_size;
    const int64_t unchecked_end   = begin_transform + transform_chunk_size;
    const int64_t end_transform =
        unchecked_end < num_transforms ? unchecked_end : num_transforms;

    for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
    {
        const int64_t token = elem / dim_dwords;
        const int64_t dword = elem - token * dim_dwords;
        const int row       = indices[task * tile_tokens + token];

        uint32_t packed = 0;
        if(row_is_valid(row, num_rows))
        {
            packed = features[static_cast<int64_t>(row) * dim_dwords + dword];
        }
        tile[elem] = packed;
    }

    __syncthreads();

    for(int64_t transform = begin_transform; transform < end_transform; ++transform)
    {
        const int64_t transform_base = transform * dim_dwords;
        float acc = 0.0f;
        for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
        {
            const int64_t dword = elem % dim_dwords;
            const uint32_t feature_packed = tile[elem];
            const uint32_t transform_packed = transforms[transform_base + dword];
            acc += dot_packed_dword(feature_packed, transform_packed, dtype_id);
        }

        partial[threadIdx.x] = acc;
        __syncthreads();

        for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
        {
            if(threadIdx.x < stride)
            {
                partial[threadIdx.x] += partial[threadIdx.x + stride];
            }
            __syncthreads();
        }

        if(threadIdx.x == 0)
        {
            output[task * num_transforms + transform] = partial[0];
        }
        __syncthreads();
    }
}

__global__ void graph_persistent_global_kernel(const uint32_t* __restrict__ features,
                                               const uint32_t* __restrict__ transforms,
                                               const int* __restrict__ indices,
                                               float* __restrict__ output,
                                               int* __restrict__ ticket,
                                               int64_t num_rows,
                                               int64_t tile_tokens,
                                               int64_t dim_dwords,
                                               int64_t tile_dwords,
                                               int64_t num_transforms,
                                               int64_t total_work,
                                               int ticket_batch_size,
                                               int dtype_id)
{
    extern __shared__ float partial[];
    __shared__ int ticket_base;

    while(true)
    {
        if(threadIdx.x == 0)
        {
            ticket_base = atomicAdd(ticket, ticket_batch_size);
        }
        __syncthreads();

        const int base = ticket_base;
        if(static_cast<int64_t>(base) >= total_work)
        {
            break;
        }

        for(int local_ticket = 0; local_ticket < ticket_batch_size; ++local_ticket)
        {
            const int64_t task_transform = static_cast<int64_t>(base) + local_ticket;
            if(task_transform >= total_work)
            {
                break;
            }

            const int64_t task = task_transform / num_transforms;
            const int64_t transform = task_transform - task * num_transforms;
            const int64_t transform_base = transform * dim_dwords;

            float acc = 0.0f;
            for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
            {
                const int64_t token = elem / dim_dwords;
                const int64_t dword = elem - token * dim_dwords;
                const int row       = indices[task * tile_tokens + token];

                uint32_t feature_packed = 0;
                if(row_is_valid(row, num_rows))
                {
                    feature_packed = features[static_cast<int64_t>(row) * dim_dwords + dword];
                }
                const uint32_t transform_packed = transforms[transform_base + dword];
                acc += dot_packed_dword(feature_packed, transform_packed, dtype_id);
            }

            partial[threadIdx.x] = acc;
            __syncthreads();

            for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
            {
                if(threadIdx.x < stride)
                {
                    partial[threadIdx.x] += partial[threadIdx.x + stride];
                }
                __syncthreads();
            }

            if(threadIdx.x == 0)
            {
                output[task * num_transforms + transform] = partial[0];
            }
            __syncthreads();
        }
    }
}

__global__ void graph_persistent_lds_kernel(const uint32_t* __restrict__ features,
                                            const uint32_t* __restrict__ transforms,
                                            const int* __restrict__ indices,
                                            float* __restrict__ output,
                                            int* __restrict__ ticket,
                                            int64_t num_rows,
                                            int64_t tile_tokens,
                                            int64_t dim_dwords,
                                            int64_t tile_dwords,
                                            int64_t num_transforms,
                                            int64_t total_work,
                                            int ticket_batch_size,
                                            int dtype_id)
{
    extern __shared__ uint32_t smem_u32[];
    uint32_t* tile = smem_u32;
    float* partial = reinterpret_cast<float*>(tile + tile_dwords);
    __shared__ int ticket_base;

    while(true)
    {
        if(threadIdx.x == 0)
        {
            ticket_base = atomicAdd(ticket, ticket_batch_size);
        }
        __syncthreads();

        const int base = ticket_base;
        if(static_cast<int64_t>(base) >= total_work)
        {
            break;
        }

        for(int local_ticket = 0; local_ticket < ticket_batch_size; ++local_ticket)
        {
            const int64_t task = static_cast<int64_t>(base) + local_ticket;
            if(task >= total_work)
            {
                break;
            }

            for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
            {
                const int64_t token = elem / dim_dwords;
                const int64_t dword = elem - token * dim_dwords;
                const int row       = indices[task * tile_tokens + token];

                uint32_t packed = 0;
                if(row_is_valid(row, num_rows))
                {
                    packed = features[static_cast<int64_t>(row) * dim_dwords + dword];
                }
                tile[elem] = packed;
            }

            __syncthreads();

            for(int64_t transform = 0; transform < num_transforms; ++transform)
            {
                const int64_t transform_base = transform * dim_dwords;
                float acc = 0.0f;
                for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
                {
                    const int64_t dword = elem % dim_dwords;
                    const uint32_t feature_packed = tile[elem];
                    const uint32_t transform_packed = transforms[transform_base + dword];
                    acc += dot_packed_dword(feature_packed, transform_packed, dtype_id);
                }

                partial[threadIdx.x] = acc;
                __syncthreads();

                for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
                {
                    if(threadIdx.x < stride)
                    {
                        partial[threadIdx.x] += partial[threadIdx.x + stride];
                    }
                    __syncthreads();
                }

                if(threadIdx.x == 0)
                {
                    output[task * num_transforms + transform] = partial[0];
                }
                __syncthreads();
            }
        }
    }
}

__global__ void graph_persistent_lds_chunked_kernel(const uint32_t* __restrict__ features,
                                                    const uint32_t* __restrict__ transforms,
                                                    const int* __restrict__ indices,
                                                    float* __restrict__ output,
                                                    int* __restrict__ ticket,
                                                    int64_t num_rows,
                                                    int64_t tile_tokens,
                                                    int64_t dim_dwords,
                                                    int64_t tile_dwords,
                                                    int64_t num_transforms,
                                                    int64_t num_transform_chunks,
                                                    int64_t transform_chunk_size,
                                                    int64_t total_work,
                                                    int ticket_batch_size,
                                                    int dtype_id)
{
    extern __shared__ uint32_t smem_u32[];
    uint32_t* tile = smem_u32;
    float* partial = reinterpret_cast<float*>(tile + tile_dwords);
    __shared__ int ticket_base;

    while(true)
    {
        if(threadIdx.x == 0)
        {
            ticket_base = atomicAdd(ticket, ticket_batch_size);
        }
        __syncthreads();

        const int base = ticket_base;
        if(static_cast<int64_t>(base) >= total_work)
        {
            break;
        }

        for(int local_ticket = 0; local_ticket < ticket_batch_size; ++local_ticket)
        {
            const int64_t task_chunk = static_cast<int64_t>(base) + local_ticket;
            if(task_chunk >= total_work)
            {
                break;
            }

            const int64_t task  = task_chunk / num_transform_chunks;
            const int64_t chunk = task_chunk - task * num_transform_chunks;
            const int64_t begin_transform = chunk * transform_chunk_size;
            const int64_t unchecked_end   = begin_transform + transform_chunk_size;
            const int64_t end_transform =
                unchecked_end < num_transforms ? unchecked_end : num_transforms;

            for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
            {
                const int64_t token = elem / dim_dwords;
                const int64_t dword = elem - token * dim_dwords;
                const int row       = indices[task * tile_tokens + token];

                uint32_t packed = 0;
                if(row_is_valid(row, num_rows))
                {
                    packed = features[static_cast<int64_t>(row) * dim_dwords + dword];
                }
                tile[elem] = packed;
            }

            __syncthreads();

            for(int64_t transform = begin_transform; transform < end_transform; ++transform)
            {
                const int64_t transform_base = transform * dim_dwords;
                float acc = 0.0f;
                for(int64_t elem = threadIdx.x; elem < tile_dwords; elem += blockDim.x)
                {
                    const int64_t dword = elem % dim_dwords;
                    const uint32_t feature_packed = tile[elem];
                    const uint32_t transform_packed = transforms[transform_base + dword];
                    acc += dot_packed_dword(feature_packed, transform_packed, dtype_id);
                }

                partial[threadIdx.x] = acc;
                __syncthreads();

                for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
                {
                    if(threadIdx.x < stride)
                    {
                        partial[threadIdx.x] += partial[threadIdx.x + stride];
                    }
                    __syncthreads();
                }

                if(threadIdx.x == 0)
                {
                    output[task * num_transforms + transform] = partial[0];
                }
                __syncthreads();
            }
        }
    }
}

__global__ void graph_varlen_static_kernel(const uint32_t* __restrict__ features,
                                           const uint32_t* __restrict__ transforms,
                                           const int* __restrict__ offsets,
                                           const int* __restrict__ flat_indices,
                                           const int* __restrict__ task_order,
                                           float* __restrict__ output,
                                           int64_t num_rows,
                                           int64_t num_transforms,
                                           int64_t dim_dwords,
                                           int dtype_id)
{
    extern __shared__ float partial[];
    const int64_t ordered_task_transform = blockIdx.x;
    const int64_t ordered_task = ordered_task_transform / num_transforms;
    const int64_t transform = ordered_task_transform - ordered_task * num_transforms;
    const int task = task_order[ordered_task];
    const int begin = offsets[task];
    const int end = offsets[task + 1];
    const int64_t transform_base = transform * dim_dwords;
    const int64_t work_items = static_cast<int64_t>(end - begin) * dim_dwords;

    float acc = 0.0f;
    for(int64_t elem = threadIdx.x; elem < work_items; elem += blockDim.x)
    {
        const int64_t edge = elem / dim_dwords;
        const int64_t dword = elem - edge * dim_dwords;
        const int row = flat_indices[begin + edge];

        uint32_t feature_packed = 0;
        if(row_is_valid(row, num_rows))
        {
            feature_packed = features[static_cast<int64_t>(row) * dim_dwords + dword];
        }
        const uint32_t transform_packed = transforms[transform_base + dword];
        acc += dot_packed_dword(feature_packed, transform_packed, dtype_id);
    }

    partial[threadIdx.x] = acc;
    __syncthreads();

    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            partial[threadIdx.x] += partial[threadIdx.x + stride];
        }
        __syncthreads();
    }

    if(threadIdx.x == 0)
    {
        output[static_cast<int64_t>(task) * num_transforms + transform] = partial[0];
    }
}

__global__ void graph_varlen_static_chunked_kernel(const uint32_t* __restrict__ features,
                                                   const uint32_t* __restrict__ transforms,
                                                   const int* __restrict__ flat_indices,
                                                   const int* __restrict__ work_task,
                                                   const int* __restrict__ work_start,
                                                   const int* __restrict__ work_count,
                                                   const int* __restrict__ work_transform,
                                                   float* __restrict__ output,
                                                   int64_t num_rows,
                                                   int64_t num_transforms,
                                                   int64_t dim_dwords,
                                                   int dtype_id)
{
    extern __shared__ float partial[];
    const int work_item = blockIdx.x;
    const int task = work_task[work_item];
    const int begin = work_start[work_item];
    const int count = work_count[work_item];
    const int transform = work_transform[work_item];
    const int64_t transform_base = static_cast<int64_t>(transform) * dim_dwords;
    const int64_t total = static_cast<int64_t>(count) * dim_dwords;

    float acc = 0.0f;
    for(int64_t elem = threadIdx.x; elem < total; elem += blockDim.x)
    {
        const int64_t edge = elem / dim_dwords;
        const int64_t dword = elem - edge * dim_dwords;
        const int row = flat_indices[begin + edge];

        uint32_t feature_packed = 0;
        if(row_is_valid(row, num_rows))
        {
            feature_packed = features[static_cast<int64_t>(row) * dim_dwords + dword];
        }
        const uint32_t transform_packed = transforms[transform_base + dword];
        acc += dot_packed_dword(feature_packed, transform_packed, dtype_id);
    }

    partial[threadIdx.x] = acc;
    __syncthreads();

    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            partial[threadIdx.x] += partial[threadIdx.x + stride];
        }
        __syncthreads();
    }

    if(threadIdx.x == 0)
    {
        atomicAdd(output + static_cast<int64_t>(task) * num_transforms + transform, partial[0]);
    }
}

__global__ void graph_varlen_static_chunked_fixed_kernel(const uint32_t* __restrict__ features,
                                                         const uint32_t* __restrict__ transforms,
                                                         const int* __restrict__ flat_indices,
                                                         const int* __restrict__ work_task,
                                                         const int* __restrict__ work_start,
                                                         const int* __restrict__ work_count,
                                                         const int* __restrict__ work_transform,
                                                         const int* __restrict__ work_size,
                                                         float* __restrict__ output,
                                                         int64_t num_rows,
                                                         int64_t num_transforms,
                                                         int64_t dim_dwords,
                                                         int64_t work_capacity,
                                                         int dtype_id)
{
    extern __shared__ float partial[];
    const int64_t work_item = static_cast<int64_t>(blockIdx.x);
    int active_work = work_size[0];
    active_work = active_work < 0 ? 0 : active_work;
    const int64_t clamped_work =
        static_cast<int64_t>(active_work) < work_capacity ? active_work : work_capacity;
    if(work_item >= clamped_work)
    {
        return;
    }

    const int task = work_task[work_item];
    const int begin = work_start[work_item];
    const int count = work_count[work_item];
    const int transform = work_transform[work_item];
    const int64_t transform_base = static_cast<int64_t>(transform) * dim_dwords;
    const int64_t total = static_cast<int64_t>(count) * dim_dwords;

    float acc = 0.0f;
    for(int64_t elem = threadIdx.x; elem < total; elem += blockDim.x)
    {
        const int64_t edge = elem / dim_dwords;
        const int64_t dword = elem - edge * dim_dwords;
        const int row = flat_indices[begin + edge];

        uint32_t feature_packed = 0;
        if(row_is_valid(row, num_rows))
        {
            feature_packed = features[static_cast<int64_t>(row) * dim_dwords + dword];
        }
        const uint32_t transform_packed = transforms[transform_base + dword];
        acc += dot_packed_dword(feature_packed, transform_packed, dtype_id);
    }

    partial[threadIdx.x] = acc;
    __syncthreads();

    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            partial[threadIdx.x] += partial[threadIdx.x + stride];
        }
        __syncthreads();
    }

    if(threadIdx.x == 0)
    {
        atomicAdd(output + static_cast<int64_t>(task) * num_transforms + transform, partial[0]);
    }
}

__global__ void replay_self_cull_kernel(float* __restrict__ sink,
                                        int actual_work_size,
                                        int work_capacity,
                                        int work_iters)
{
    const int item = blockIdx.x;
    const int active_work =
        actual_work_size < 0 ? 0 : (actual_work_size < work_capacity ? actual_work_size
                                                                     : work_capacity);
    if(item >= active_work)
    {
        return;
    }

    uint32_t state = static_cast<uint32_t>((item + 1) * 1664525u + threadIdx.x);
    for(int iter = 0; iter < work_iters; ++iter)
    {
        state = state * 1664525u + 1013904223u;
    }

    if(threadIdx.x == 0)
    {
        sink[item] = static_cast<float>((state & 0xffffu) + active_work);
    }
}

__global__ void replay_gather_dot_kernel(float* __restrict__ sink,
                                         const uint32_t* __restrict__ features,
                                         const uint32_t* __restrict__ transforms,
                                         int actual_work_size,
                                         int work_capacity,
                                         int64_t num_rows,
                                         int64_t num_transforms,
                                         int64_t dim_dwords,
                                         int64_t chunk_tokens,
                                         int dtype_id)
{
    extern __shared__ float partial[];
    const int item = blockIdx.x;
    const int active_work =
        actual_work_size < 0 ? 0 : (actual_work_size < work_capacity ? actual_work_size
                                                                     : work_capacity);
    if(item >= active_work)
    {
        return;
    }

    const int64_t transform = static_cast<int64_t>(item) % num_transforms;
    const int64_t transform_base = transform * dim_dwords;
    const int64_t span = num_rows > chunk_tokens ? num_rows - chunk_tokens : 1;
    const int64_t begin_row = (static_cast<int64_t>(item) * chunk_tokens) % span;
    const int64_t total = chunk_tokens * dim_dwords;

    float acc = 0.0f;
    for(int64_t elem = threadIdx.x; elem < total; elem += blockDim.x)
    {
        const int64_t token = elem / dim_dwords;
        const int64_t dword = elem - token * dim_dwords;
        const int64_t row = begin_row + token;
        const uint32_t feature_packed = features[row * dim_dwords + dword];
        const uint32_t transform_packed = transforms[transform_base + dword];
        acc += dot_packed_dword(feature_packed, transform_packed, dtype_id);
    }

    partial[threadIdx.x] = acc;
    __syncthreads();

    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            partial[threadIdx.x] += partial[threadIdx.x + stride];
        }
        __syncthreads();
    }

    if(threadIdx.x == 0)
    {
        sink[item] = partial[0];
    }
}


__global__ void replay_self_cull_fused_kernel(float* __restrict__ sink,
                                              const int* __restrict__ actual_work_sizes,
                                              int work_capacity,
                                              int num_traces,
                                              int work_iters)
{
    const int slot = blockIdx.x;
    const int trace = blockIdx.y;
    if(trace >= num_traces)
    {
        return;
    }

    const int actual = actual_work_sizes[trace];
    const int active_work = actual < 0 ? 0 : (actual < work_capacity ? actual : work_capacity);
    if(slot >= active_work)
    {
        return;
    }

    uint32_t state = static_cast<uint32_t>((slot + 1) * 1664525u +
                                           (trace + 1) * 1013904223u + threadIdx.x);
    for(int iter = 0; iter < work_iters; ++iter)
    {
        state = state * 1664525u + 1013904223u;
    }

    if(threadIdx.x == 0)
    {
        const int64_t out = static_cast<int64_t>(trace) * work_capacity + slot;
        sink[out] = static_cast<float>((state & 0xffffu) + active_work);
    }
}

__global__ void replay_gather_dot_fused_kernel(float* __restrict__ sink,
                                               const uint32_t* __restrict__ features,
                                               const uint32_t* __restrict__ transforms,
                                               const int* __restrict__ actual_work_sizes,
                                               int work_capacity,
                                               int num_traces,
                                               int64_t num_rows,
                                               int64_t num_transforms,
                                               int64_t dim_dwords,
                                               int64_t chunk_tokens,
                                               int dtype_id)
{
    extern __shared__ float partial[];
    const int slot = blockIdx.x;
    const int trace = blockIdx.y;
    if(trace >= num_traces)
    {
        return;
    }

    const int actual = actual_work_sizes[trace];
    const int active_work = actual < 0 ? 0 : (actual < work_capacity ? actual : work_capacity);
    if(slot >= active_work)
    {
        return;
    }

    const int64_t transform = static_cast<int64_t>(slot) % num_transforms;
    const int64_t transform_base = transform * dim_dwords;
    const int64_t span = num_rows > chunk_tokens ? num_rows - chunk_tokens : 1;
    const int64_t begin_row =
        (static_cast<int64_t>(trace) * 1315423911ll + static_cast<int64_t>(slot) * chunk_tokens) %
        span;
    const int64_t total = chunk_tokens * dim_dwords;

    float acc = 0.0f;
    for(int64_t elem = threadIdx.x; elem < total; elem += blockDim.x)
    {
        const int64_t token = elem / dim_dwords;
        const int64_t dword = elem - token * dim_dwords;
        const int64_t row = begin_row + token;
        const uint32_t feature_packed = features[row * dim_dwords + dword];
        const uint32_t transform_packed = transforms[transform_base + dword];
        acc += dot_packed_dword(feature_packed, transform_packed, dtype_id);
    }

    partial[threadIdx.x] = acc;
    __syncthreads();

    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            partial[threadIdx.x] += partial[threadIdx.x + stride];
        }
        __syncthreads();
    }

    if(threadIdx.x == 0)
    {
        const int64_t out = static_cast<int64_t>(trace) * work_capacity + slot;
        sink[out] = partial[0];
    }
}


__global__ void replay_paged_kv_dot_fused_kernel(float* __restrict__ sink,
                                                 const uint32_t* __restrict__ kv_pool,
                                                 const uint32_t* __restrict__ transforms,
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
                                                 int dtype_id)
{
    extern __shared__ float partial[];
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
    const int64_t token_base = chunk * chunk_tokens;
    const int64_t transform_base = work_head * dim_dwords;
    const int64_t total = chunk_tokens * dim_dwords;

    float acc = 0.0f;
    for(int64_t elem = threadIdx.x; elem < total; elem += blockDim.x)
    {
        const int64_t token = elem / dim_dwords;
        const int64_t dword = elem - token * dim_dwords;
        const int64_t abs_token = token_base + token;
        if(abs_token >= seqlen)
        {
            continue;
        }

        const int64_t page_idx = abs_token / page_block_size;
        const int64_t page_offset = abs_token - page_idx * page_block_size;
        if(page_idx >= max_pages_per_seq)
        {
            continue;
        }
        const int phys_page = block_tables[static_cast<int64_t>(row) * max_pages_per_seq + page_idx];
        if(phys_page < 0 || static_cast<int64_t>(phys_page) >= num_kv_pages)
        {
            continue;
        }

        const int64_t kv_index =
            (((static_cast<int64_t>(phys_page) * num_kv_heads + kv_head) * page_block_size +
              page_offset) *
                 dim_dwords +
             dword);
        const uint32_t kv_packed = kv_pool[kv_index];
        const uint32_t transform_packed = transforms[transform_base + dword];
        acc += dot_packed_dword(kv_packed, transform_packed, dtype_id);
    }

    partial[threadIdx.x] = acc;
    __syncthreads();

    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            partial[threadIdx.x] += partial[threadIdx.x + stride];
        }
        __syncthreads();
    }

    if(threadIdx.x == 0)
    {
        const int64_t out = static_cast<int64_t>(group_row) * work_capacity + slot;
        sink[out] = partial[0];
    }
}


__global__ void replay_paged_kv_attn_fused_kernel(float* __restrict__ sink,
                                                  const uint32_t* __restrict__ k_pool,
                                                  const uint32_t* __restrict__ v_pool,
                                                  const uint32_t* __restrict__ q_transforms,
                                                  const uint32_t* __restrict__ v_transforms,
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
                                                  int dtype_id)
{
    extern __shared__ float shared[];
    float* partial_max = shared;
    float* partial_sum = shared + blockDim.x;
    float* partial_val = shared + blockDim.x * 2;

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
    const int64_t token_base = chunk * chunk_tokens;
    const int64_t transform_base = work_head * dim_dwords;
    const float scale = rsqrtf(static_cast<float>(dim_dwords * 2));

    float local_max = -3.4028234663852886e38f;
    for(int64_t token = threadIdx.x; token < chunk_tokens; token += blockDim.x)
    {
        const int64_t abs_token = token_base + token;
        if(abs_token >= seqlen)
        {
            continue;
        }

        const int64_t page_idx = abs_token / page_block_size;
        const int64_t page_offset = abs_token - page_idx * page_block_size;
        if(page_idx >= max_pages_per_seq)
        {
            continue;
        }
        const int phys_page = block_tables[static_cast<int64_t>(row) * max_pages_per_seq + page_idx];
        if(phys_page < 0 || static_cast<int64_t>(phys_page) >= num_kv_pages)
        {
            continue;
        }

        float score = 0.0f;
        const int64_t base =
            ((static_cast<int64_t>(phys_page) * num_kv_heads + kv_head) * page_block_size +
             page_offset) *
            dim_dwords;
        for(int64_t dword = 0; dword < dim_dwords; ++dword)
        {
            score += dot_packed_dword(k_pool[base + dword], q_transforms[transform_base + dword], dtype_id);
        }
        score *= scale;
        local_max = score > local_max ? score : local_max;
    }

    partial_max[threadIdx.x] = local_max;
    __syncthreads();
    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            const float other = partial_max[threadIdx.x + stride];
            partial_max[threadIdx.x] = other > partial_max[threadIdx.x] ? other : partial_max[threadIdx.x];
        }
        __syncthreads();
    }
    const float max_score = partial_max[0];

    float local_sum = 0.0f;
    float local_val = 0.0f;
    for(int64_t token = threadIdx.x; token < chunk_tokens; token += blockDim.x)
    {
        const int64_t abs_token = token_base + token;
        if(abs_token >= seqlen)
        {
            continue;
        }

        const int64_t page_idx = abs_token / page_block_size;
        const int64_t page_offset = abs_token - page_idx * page_block_size;
        if(page_idx >= max_pages_per_seq)
        {
            continue;
        }
        const int phys_page = block_tables[static_cast<int64_t>(row) * max_pages_per_seq + page_idx];
        if(phys_page < 0 || static_cast<int64_t>(phys_page) >= num_kv_pages)
        {
            continue;
        }

        float score = 0.0f;
        float vproj = 0.0f;
        const int64_t base =
            ((static_cast<int64_t>(phys_page) * num_kv_heads + kv_head) * page_block_size +
             page_offset) *
            dim_dwords;
        for(int64_t dword = 0; dword < dim_dwords; ++dword)
        {
            score += dot_packed_dword(k_pool[base + dword], q_transforms[transform_base + dword], dtype_id);
            vproj += dot_packed_dword(v_pool[base + dword], v_transforms[transform_base + dword], dtype_id);
        }
        score *= scale;
        const float weight = expf(score - max_score);
        local_sum += weight;
        local_val += weight * vproj;
    }

    partial_sum[threadIdx.x] = local_sum;
    partial_val[threadIdx.x] = local_val;
    __syncthreads();
    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            partial_sum[threadIdx.x] += partial_sum[threadIdx.x + stride];
            partial_val[threadIdx.x] += partial_val[threadIdx.x + stride];
        }
        __syncthreads();
    }

    if(threadIdx.x == 0)
    {
        const float denom = partial_sum[0] > 0.0f ? partial_sum[0] : 1.0f;
        const int64_t out = static_cast<int64_t>(group_row) * work_capacity + slot;
        sink[out] = partial_val[0] / denom;
    }
}

__global__ void replay_paged_kv_chunk_softmax_kernel(float* __restrict__ chunk_m,
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
            partial_max[threadIdx.x] = other > partial_max[threadIdx.x] ? other : partial_max[threadIdx.x];
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

__global__ void replay_paged_kv_chunk_reduce_kernel(float* __restrict__ output,
                                                    const float* __restrict__ chunk_m,
                                                    const float* __restrict__ chunk_l,
                                                    const float* __restrict__ chunk_acc,
                                                    const int* __restrict__ cache_seqlens,
                                                    int64_t num_rows,
                                                    int64_t num_work_heads,
                                                    int64_t max_chunks,
                                                    int64_t value_dim,
                                                    int64_t chunk_tokens)
{
    extern __shared__ float partial[];
    const int64_t row_head = blockIdx.x;
    const int64_t row = row_head / num_work_heads;
    const int64_t work_head = row_head - row * num_work_heads;
    if(row >= num_rows)
    {
        return;
    }

    const int seqlen = cache_seqlens[row];
    int64_t valid_chunks = (static_cast<int64_t>(seqlen) + chunk_tokens - 1) / chunk_tokens;
    valid_chunks = valid_chunks < max_chunks ? valid_chunks : max_chunks;

    float local_m = -3.4028234663852886e38f;
    for(int64_t chunk = threadIdx.x; chunk < valid_chunks; chunk += blockDim.x)
    {
        const int64_t index = ((row * num_work_heads + work_head) * max_chunks + chunk);
        const float candidate = chunk_l[index] > 0.0f ? chunk_m[index] : -3.4028234663852886e38f;
        local_m = candidate > local_m ? candidate : local_m;
    }

    partial[threadIdx.x] = local_m;
    __syncthreads();
    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            const float other = partial[threadIdx.x + stride];
            partial[threadIdx.x] = other > partial[threadIdx.x] ? other : partial[threadIdx.x];
        }
        __syncthreads();
    }
    const float total_m = partial[0];

    float local_l = 0.0f;
    if(total_m > -3.0e38f)
    {
        for(int64_t chunk = threadIdx.x; chunk < valid_chunks; chunk += blockDim.x)
        {
            const int64_t index = ((row * num_work_heads + work_head) * max_chunks + chunk);
            const float l = chunk_l[index];
            if(l > 0.0f)
            {
                local_l += l * expf(chunk_m[index] - total_m);
            }
        }
    }

    partial[threadIdx.x] = local_l;
    __syncthreads();
    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            partial[threadIdx.x] += partial[threadIdx.x + stride];
        }
        __syncthreads();
    }
    const float total_l = partial[0];

    for(int64_t value = threadIdx.x; value < value_dim; value += blockDim.x)
    {
        float acc = 0.0f;
        if(total_l > 0.0f && total_m > -3.0e38f)
        {
            for(int64_t chunk = 0; chunk < valid_chunks; ++chunk)
            {
                const int64_t index = ((row * num_work_heads + work_head) * max_chunks + chunk);
                const float l = chunk_l[index];
                if(l > 0.0f)
                {
                    const float scale = expf(chunk_m[index] - total_m);
                    acc += chunk_acc[index * value_dim + value] * scale;
                }
            }
            acc /= total_l;
        }
        output[(row * num_work_heads + work_head) * value_dim + value] = acc;
    }
}

__global__ void replay_paged_kv_chunk_reduce_ml_kernel(float* __restrict__ output,
                                                       const float* __restrict__ chunk_m,
                                                       const float* __restrict__ chunk_l,
                                                       const int* __restrict__ cache_seqlens,
                                                       int64_t num_rows,
                                                       int64_t num_work_heads,
                                                       int64_t max_chunks,
                                                       int64_t chunk_tokens)
{
    extern __shared__ float partial[];
    const int64_t row_head = blockIdx.x;
    const int64_t row = row_head / num_work_heads;
    const int64_t work_head = row_head - row * num_work_heads;
    if(row >= num_rows)
    {
        return;
    }

    const int seqlen = cache_seqlens[row];
    int64_t valid_chunks = (static_cast<int64_t>(seqlen) + chunk_tokens - 1) / chunk_tokens;
    valid_chunks = valid_chunks < max_chunks ? valid_chunks : max_chunks;

    float local_m = -3.4028234663852886e38f;
    for(int64_t chunk = threadIdx.x; chunk < valid_chunks; chunk += blockDim.x)
    {
        const int64_t index = ((row * num_work_heads + work_head) * max_chunks + chunk);
        const float candidate = chunk_l[index] > 0.0f ? chunk_m[index] : -3.4028234663852886e38f;
        local_m = candidate > local_m ? candidate : local_m;
    }

    partial[threadIdx.x] = local_m;
    __syncthreads();
    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            const float other = partial[threadIdx.x + stride];
            partial[threadIdx.x] = other > partial[threadIdx.x] ? other : partial[threadIdx.x];
        }
        __syncthreads();
    }
    const float total_m = partial[0];

    float local_l = 0.0f;
    if(total_m > -3.0e38f)
    {
        for(int64_t chunk = threadIdx.x; chunk < valid_chunks; chunk += blockDim.x)
        {
            const int64_t index = ((row * num_work_heads + work_head) * max_chunks + chunk);
            const float l = chunk_l[index];
            if(l > 0.0f)
            {
                local_l += l * expf(chunk_m[index] - total_m);
            }
        }
    }

    partial[threadIdx.x] = local_l;
    __syncthreads();
    for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if(threadIdx.x < stride)
        {
            partial[threadIdx.x] += partial[threadIdx.x + stride];
        }
        __syncthreads();
    }

    if(threadIdx.x == 0)
    {
        output[row_head * 2] = total_m > -3.0e38f ? total_m : 0.0f;
        output[row_head * 2 + 1] = partial[0];
    }
}

__global__ void graph_varlen_persistent_node_kernel(const uint32_t* __restrict__ features,
                                                    const uint32_t* __restrict__ transforms,
                                                    const int* __restrict__ offsets,
                                                    const int* __restrict__ flat_indices,
                                                    const int* __restrict__ task_order,
                                                    float* __restrict__ output,
                                                    int* __restrict__ ticket,
                                                    int64_t num_rows,
                                                    int64_t num_transforms,
                                                    int64_t dim_dwords,
                                                    int64_t total_work,
                                                    int ticket_batch_size,
                                                    int dtype_id)
{
    extern __shared__ float partial[];
    __shared__ int ticket_base;

    while(true)
    {
        if(threadIdx.x == 0)
        {
            ticket_base = atomicAdd(ticket, ticket_batch_size);
        }
        __syncthreads();

        const int base = ticket_base;
        if(static_cast<int64_t>(base) >= total_work)
        {
            break;
        }

        for(int local_ticket = 0; local_ticket < ticket_batch_size; ++local_ticket)
        {
            const int64_t ordered_task_transform = static_cast<int64_t>(base) + local_ticket;
            if(ordered_task_transform >= total_work)
            {
                break;
            }

            const int64_t ordered_task = ordered_task_transform / num_transforms;
            const int64_t transform = ordered_task_transform - ordered_task * num_transforms;
            const int task = task_order[ordered_task];
            const int begin = offsets[task];
            const int end = offsets[task + 1];
            const int64_t transform_base = transform * dim_dwords;
            const int64_t work_items = static_cast<int64_t>(end - begin) * dim_dwords;

            float acc = 0.0f;
            for(int64_t elem = threadIdx.x; elem < work_items; elem += blockDim.x)
            {
                const int64_t edge = elem / dim_dwords;
                const int64_t dword = elem - edge * dim_dwords;
                const int row = flat_indices[begin + edge];

                uint32_t feature_packed = 0;
                if(row_is_valid(row, num_rows))
                {
                    feature_packed = features[static_cast<int64_t>(row) * dim_dwords + dword];
                }
                const uint32_t transform_packed = transforms[transform_base + dword];
                acc += dot_packed_dword(feature_packed, transform_packed, dtype_id);
            }

            partial[threadIdx.x] = acc;
            __syncthreads();

            for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
            {
                if(threadIdx.x < stride)
                {
                    partial[threadIdx.x] += partial[threadIdx.x + stride];
                }
                __syncthreads();
            }

            if(threadIdx.x == 0)
            {
                output[static_cast<int64_t>(task) * num_transforms + transform] = partial[0];
            }
            __syncthreads();
        }
    }
}

__global__ void graph_varlen_persistent_chunked_kernel(const uint32_t* __restrict__ features,
                                                       const uint32_t* __restrict__ transforms,
                                                       const int* __restrict__ flat_indices,
                                                       const int* __restrict__ work_task,
                                                       const int* __restrict__ work_start,
                                                       const int* __restrict__ work_count,
                                                       const int* __restrict__ work_transform,
                                                       float* __restrict__ output,
                                                       int* __restrict__ ticket,
                                                       int64_t num_rows,
                                                       int64_t num_transforms,
                                                       int64_t dim_dwords,
                                                       int64_t total_work,
                                                       int ticket_batch_size,
                                                       int dtype_id)
{
    extern __shared__ float partial[];
    __shared__ int ticket_base;

    while(true)
    {
        if(threadIdx.x == 0)
        {
            ticket_base = atomicAdd(ticket, ticket_batch_size);
        }
        __syncthreads();

        const int base = ticket_base;
        if(static_cast<int64_t>(base) >= total_work)
        {
            break;
        }

        for(int local_ticket = 0; local_ticket < ticket_batch_size; ++local_ticket)
        {
            const int64_t work_item = static_cast<int64_t>(base) + local_ticket;
            if(work_item >= total_work)
            {
                break;
            }

            const int task = work_task[work_item];
            const int begin = work_start[work_item];
            const int count = work_count[work_item];
            const int transform = work_transform[work_item];
            const int64_t transform_base = static_cast<int64_t>(transform) * dim_dwords;
            const int64_t total = static_cast<int64_t>(count) * dim_dwords;

            float acc = 0.0f;
            for(int64_t elem = threadIdx.x; elem < total; elem += blockDim.x)
            {
                const int64_t edge = elem / dim_dwords;
                const int64_t dword = elem - edge * dim_dwords;
                const int row = flat_indices[begin + edge];

                uint32_t feature_packed = 0;
                if(row_is_valid(row, num_rows))
                {
                    feature_packed = features[static_cast<int64_t>(row) * dim_dwords + dword];
                }
                const uint32_t transform_packed = transforms[transform_base + dword];
                acc += dot_packed_dword(feature_packed, transform_packed, dtype_id);
            }

            partial[threadIdx.x] = acc;
            __syncthreads();

            for(int stride = blockDim.x / 2; stride > 0; stride >>= 1)
            {
                if(threadIdx.x < stride)
                {
                    partial[threadIdx.x] += partial[threadIdx.x + stride];
                }
                __syncthreads();
            }

            if(threadIdx.x == 0)
            {
                atomicAdd(output + static_cast<int64_t>(task) * num_transforms + transform,
                          partial[0]);
            }
            __syncthreads();
        }
    }
}

__global__ void graph_varlen_work_chunk_counts_kernel(const int* __restrict__ offsets,
                                                      const int* __restrict__ task_order,
                                                      const int* __restrict__ transform_counts,
                                                      const int* __restrict__ edge_limits,
                                                      int* __restrict__ pair_chunk_counts,
                                                      int64_t num_tasks,
                                                      int64_t num_transforms,
                                                      int chunk_tokens)
{
    const int64_t pair = static_cast<int64_t>(blockIdx.x) * blockDim.x + threadIdx.x;
    const int64_t total_pairs = num_tasks * num_transforms;
    if(pair >= total_pairs)
    {
        return;
    }

    const int64_t ordered_task = pair / num_transforms;
    const int transform = static_cast<int>(pair - ordered_task * num_transforms);
    const int task = task_order[ordered_task];
    const int active_transforms = transform_counts[task];
    int chunks = 0;

    if(transform < active_transforms)
    {
        const int begin = offsets[task];
        const int count = offsets[task + 1] - begin;
        int limit = edge_limits[static_cast<int64_t>(task) * num_transforms + transform];
        limit = limit < 0 ? 0 : limit;
        limit = limit > count ? count : limit;
        chunks = (limit + chunk_tokens - 1) / chunk_tokens;
    }

    pair_chunk_counts[pair] = chunks;
}

__global__ void graph_varlen_fill_work_items_kernel(const int* __restrict__ offsets,
                                                    const int* __restrict__ task_order,
                                                    const int* __restrict__ edge_limits,
                                                    const int* __restrict__ pair_chunk_ends,
                                                    int* __restrict__ work_task,
                                                    int* __restrict__ work_start,
                                                    int* __restrict__ work_count,
                                                    int* __restrict__ work_transform,
                                                    int64_t num_tasks,
                                                    int64_t num_transforms,
                                                    int chunk_tokens)
{
    const int64_t pair = static_cast<int64_t>(blockIdx.x) * blockDim.x + threadIdx.x;
    const int64_t total_pairs = num_tasks * num_transforms;
    if(pair >= total_pairs)
    {
        return;
    }

    const int end_chunk = pair_chunk_ends[pair];
    const int begin_chunk = pair == 0 ? 0 : pair_chunk_ends[pair - 1];
    const int chunks = end_chunk - begin_chunk;
    if(chunks <= 0)
    {
        return;
    }

    const int64_t ordered_task = pair / num_transforms;
    const int transform = static_cast<int>(pair - ordered_task * num_transforms);
    const int task = task_order[ordered_task];
    const int begin = offsets[task];
    const int count = offsets[task + 1] - begin;
    int limit = edge_limits[static_cast<int64_t>(task) * num_transforms + transform];
    limit = limit < 0 ? 0 : limit;
    limit = limit > count ? count : limit;

    for(int chunk = 0; chunk < chunks; ++chunk)
    {
        const int rel = chunk * chunk_tokens;
        const int item = begin_chunk + chunk;
        work_task[item] = task;
        work_start[item] = begin + rel;
        const int remaining = limit - rel;
        work_count[item] = remaining < chunk_tokens ? remaining : chunk_tokens;
        work_transform[item] = transform;
    }
}

__global__ void graph_varlen_store_work_size_kernel(const int* __restrict__ pair_chunk_ends,
                                                    int* __restrict__ work_size,
                                                    int64_t total_pairs)
{
    if(threadIdx.x == 0 && blockIdx.x == 0)
    {
        work_size[0] = pair_chunk_ends[total_pairs - 1];
    }
}

__global__ void graph_varlen_fill_work_items_fixed_kernel(const int* __restrict__ offsets,
                                                          const int* __restrict__ task_order,
                                                          const int* __restrict__ edge_limits,
                                                          const int* __restrict__ pair_chunk_ends,
                                                          int* __restrict__ work_task,
                                                          int* __restrict__ work_start,
                                                          int* __restrict__ work_count,
                                                          int* __restrict__ work_transform,
                                                          int64_t num_tasks,
                                                          int64_t num_transforms,
                                                          int64_t work_capacity,
                                                          int chunk_tokens)
{
    const int64_t pair = static_cast<int64_t>(blockIdx.x) * blockDim.x + threadIdx.x;
    const int64_t total_pairs = num_tasks * num_transforms;
    if(pair >= total_pairs)
    {
        return;
    }

    const int end_chunk = pair_chunk_ends[pair];
    const int begin_chunk = pair == 0 ? 0 : pair_chunk_ends[pair - 1];
    const int chunks = end_chunk - begin_chunk;
    if(chunks <= 0)
    {
        return;
    }

    const int64_t ordered_task = pair / num_transforms;
    const int transform = static_cast<int>(pair - ordered_task * num_transforms);
    const int task = task_order[ordered_task];
    const int begin = offsets[task];
    const int count = offsets[task + 1] - begin;
    int limit = edge_limits[static_cast<int64_t>(task) * num_transforms + transform];
    limit = limit < 0 ? 0 : limit;
    limit = limit > count ? count : limit;

    for(int chunk = 0; chunk < chunks; ++chunk)
    {
        const int rel = chunk * chunk_tokens;
        const int64_t item = static_cast<int64_t>(begin_chunk) + chunk;
        if(item >= work_capacity)
        {
            return;
        }
        work_task[item] = task;
        work_start[item] = begin + rel;
        const int remaining = limit - rel;
        work_count[item] = remaining < chunk_tokens ? remaining : chunk_tokens;
        work_transform[item] = transform;
    }
}

__device__ __forceinline__ uint32_t mix_u32(uint32_t x)
{
    x ^= x >> 16;
    x *= 0x7feb352du;
    x ^= x >> 15;
    x *= 0x846ca68bu;
    x ^= x >> 16;
    return x;
}

__device__ __forceinline__ float unit_random_u32(uint32_t seed, uint32_t a, uint32_t b)
{
    const uint32_t mixed = mix_u32(seed ^ (a * 0x9e3779b9u) ^ (b * 0x85ebca6bu));
    return static_cast<float>(mixed & 0x00ffffffu) * (1.0f / 16777216.0f);
}

__device__ __forceinline__ int count_bucket_for(int count, int max_neighbors, int num_buckets)
{
    const int denom = max_neighbors > 0 ? max_neighbors : 1;
    int bucket = (count * num_buckets) / (denom + 1);
    bucket = bucket < 0 ? 0 : bucket;
    bucket = bucket >= num_buckets ? num_buckets - 1 : bucket;
    return bucket;
}

__global__ void graph_generate_counts_kernel(int* __restrict__ counts,
                                             int64_t num_tasks,
                                             int mean_neighbors,
                                             int max_neighbors,
                                             float skew,
                                             float pareto_alpha,
                                             uint32_t seed)
{
    const int task = static_cast<int>(blockIdx.x) * blockDim.x + threadIdx.x;
    if(static_cast<int64_t>(task) >= num_tasks)
    {
        return;
    }

    int count = mean_neighbors;
    if(skew > 0.0f)
    {
        const float u = fminf(0.999999f, fmaxf(0.000001f, unit_random_u32(seed, task, 17u)));
        const float alpha = fmaxf(1.01f, pareto_alpha);
        const float expected = alpha / (alpha - 1.0f);
        float pareto = powf(fmaxf(0.000001f, 1.0f - u), -1.0f / alpha);
        const float max_scale =
            static_cast<float>(max_neighbors > mean_neighbors ? max_neighbors : mean_neighbors) /
            static_cast<float>(mean_neighbors > 0 ? mean_neighbors : 1);
        pareto = fminf(pareto / expected, max_scale);
        const float scale = (1.0f - skew) + skew * pareto;
        count = static_cast<int>(roundf(static_cast<float>(mean_neighbors) * scale));
    }

    count = count < 1 ? 1 : count;
    count = count > max_neighbors ? max_neighbors : count;
    counts[task] = count;
}

__global__ void graph_offsets_from_counts_kernel(const int* __restrict__ count_prefix,
                                                 int* __restrict__ offsets,
                                                 int64_t num_tasks)
{
    const int idx = static_cast<int>(blockIdx.x) * blockDim.x + threadIdx.x;
    if(idx == 0)
    {
        offsets[0] = 0;
    }
    if(static_cast<int64_t>(idx) < num_tasks)
    {
        offsets[idx + 1] = count_prefix[idx];
    }
}

__global__ void graph_fill_identity_order_kernel(int* __restrict__ order, int64_t num_tasks)
{
    const int task = static_cast<int>(blockIdx.x) * blockDim.x + threadIdx.x;
    if(static_cast<int64_t>(task) < num_tasks)
    {
        order[task] = task;
    }
}

__global__ void graph_fill_flat_indices_kernel(const int* __restrict__ offsets,
                                               int* __restrict__ flat_indices,
                                               int64_t num_tasks,
                                               int64_t rows,
                                               int mean_neighbors,
                                               int index_pattern_id,
                                               uint32_t seed)
{
    const int task = static_cast<int>(blockIdx.x);
    if(static_cast<int64_t>(task) >= num_tasks)
    {
        return;
    }

    const int begin = offsets[task];
    const int end = offsets[task + 1];
    const int count = end - begin;
    const int64_t contiguous_start =
        (static_cast<int64_t>(task) * static_cast<int64_t>(mean_neighbors > 0 ? mean_neighbors : 1)) %
        rows;

    for(int rel = threadIdx.x; rel < count; rel += blockDim.x)
    {
        int row = 0;
        if(index_pattern_id == 1)
        {
            row = static_cast<int>((contiguous_start + rel) % rows);
        }
        else
        {
            row = static_cast<int>(mix_u32(seed ^ (task * 0x9e3779b9u) ^ rel) %
                                   static_cast<uint32_t>(rows));
        }
        flat_indices[begin + rel] = row;
    }
}

__global__ void graph_generate_dynamic_costs_kernel(const int* __restrict__ offsets,
                                                    int* __restrict__ transform_counts,
                                                    int* __restrict__ edge_limits,
                                                    int64_t num_tasks,
                                                    int64_t num_transforms,
                                                    float filter_ratio,
                                                    float transform_active_ratio,
                                                    float early_exit_ratio,
                                                    uint32_t seed)
{
    const int64_t linear = static_cast<int64_t>(blockIdx.x) * blockDim.x + threadIdx.x;
    const int64_t total = num_tasks * num_transforms;
    if(linear >= total)
    {
        return;
    }

    const int task = static_cast<int>(linear / num_transforms);
    const int transform = static_cast<int>(linear - static_cast<int64_t>(task) * num_transforms);
    const int count = offsets[task + 1] - offsets[task];

    if(transform == 0)
    {
        int active = static_cast<int>(num_transforms);
        if(transform_active_ratio < 1.0f)
        {
            const float jitter = 0.5f + unit_random_u32(seed + 101u, task, 3u);
            active = static_cast<int>(roundf(static_cast<float>(num_transforms) *
                                             transform_active_ratio * jitter));
            active = active < 1 ? 1 : active;
            active = active > num_transforms ? static_cast<int>(num_transforms) : active;
        }
        transform_counts[task] = active;
    }

    float limit = static_cast<float>(count);
    if(filter_ratio < 1.0f)
    {
        const float jitter = 0.5f + unit_random_u32(seed + 211u, task, transform);
        limit *= fminf(1.0f, filter_ratio * jitter);
    }
    if(early_exit_ratio < 1.0f)
    {
        const float jitter = 0.25f + 0.75f * unit_random_u32(seed + 307u, task, transform);
        const float early_limit =
            static_cast<float>(count) * fminf(1.0f, early_exit_ratio * jitter);
        limit = fminf(limit, early_limit);
    }

    int int_limit = static_cast<int>(roundf(limit));
    int_limit = int_limit < 1 ? 1 : int_limit;
    int_limit = int_limit > count ? count : int_limit;
    edge_limits[linear] = int_limit;
}

__global__ void graph_count_buckets_kernel(const int* __restrict__ counts,
                                           int* __restrict__ bucket_counts,
                                           int64_t num_tasks,
                                           int max_neighbors,
                                           int num_buckets)
{
    const int task = static_cast<int>(blockIdx.x) * blockDim.x + threadIdx.x;
    if(static_cast<int64_t>(task) >= num_tasks)
    {
        return;
    }
    const int bucket = count_bucket_for(counts[task], max_neighbors, num_buckets);
    atomicAdd(bucket_counts + bucket, 1);
}

__global__ void graph_bucket_offsets_desc_kernel(const int* __restrict__ bucket_prefix,
                                                 int* __restrict__ bucket_offsets,
                                                 int total_tasks,
                                                 int num_buckets)
{
    const int bucket = static_cast<int>(blockIdx.x) * blockDim.x + threadIdx.x;
    if(bucket >= num_buckets)
    {
        return;
    }
    bucket_offsets[bucket] = total_tasks - bucket_prefix[bucket];
}

__global__ void graph_fill_bucket_order_kernel(const int* __restrict__ counts,
                                               const int* __restrict__ bucket_offsets,
                                               int* __restrict__ bucket_write,
                                               int* __restrict__ order,
                                               int64_t num_tasks,
                                               int max_neighbors,
                                               int num_buckets)
{
    const int task = static_cast<int>(blockIdx.x) * blockDim.x + threadIdx.x;
    if(static_cast<int64_t>(task) >= num_tasks)
    {
        return;
    }
    const int bucket = count_bucket_for(counts[task], max_neighbors, num_buckets);
    const int pos = atomicAdd(bucket_write + bucket, 1);
    order[bucket_offsets[bucket] + pos] = task;
}

void check_launch()
{
    const hipError_t err = hipGetLastError();
    TORCH_CHECK(err == hipSuccess, "HIP kernel launch failed: ", hipGetErrorString(err));
}

void validate_inputs(const at::Tensor& features, const at::Tensor& indices)
{
    CHECK_CUDA(features);
    CHECK_CUDA(indices);
    CHECK_CONTIGUOUS(features);
    CHECK_CONTIGUOUS(indices);
    TORCH_CHECK(features.dim() == 2, "features must have shape [num_rows, dim]");
    TORCH_CHECK(indices.dim() == 2, "indices must have shape [num_tasks, tile_tokens]");
    TORCH_CHECK(indices.scalar_type() == at::kInt, "indices must be int32");
    TORCH_CHECK(features.scalar_type() == at::kHalf || features.scalar_type() == at::kBFloat16,
                "features must be fp16 or bf16");
    TORCH_CHECK(features.size(1) % 2 == 0, "dim must be even for DWORD copy kernels");
    TORCH_CHECK(reinterpret_cast<uintptr_t>(features.data_ptr()) % alignof(uint32_t) == 0,
                "features pointer must be DWORD-aligned");
}

void validate_queries(const at::Tensor& features,
                      const at::Tensor& indices,
                      const at::Tensor& queries)
{
    validate_inputs(features, indices);
    CHECK_CUDA(queries);
    CHECK_CONTIGUOUS(queries);
    TORCH_CHECK(queries.dim() == 3, "queries must have shape [num_tasks, num_queries, dim]");
    TORCH_CHECK(queries.scalar_type() == features.scalar_type(),
                "queries dtype must match features dtype");
    TORCH_CHECK(queries.size(0) == indices.size(0),
                "queries num_tasks must match indices num_tasks");
    TORCH_CHECK(queries.size(1) > 0, "queries must contain at least one query per task");
    TORCH_CHECK(queries.size(2) == features.size(1),
                "queries dim must match features dim");
    TORCH_CHECK(reinterpret_cast<uintptr_t>(queries.data_ptr()) % alignof(uint32_t) == 0,
                "queries pointer must be DWORD-aligned");
}

void validate_transforms(const at::Tensor& features,
                         const at::Tensor& indices,
                         const at::Tensor& transforms)
{
    validate_inputs(features, indices);
    CHECK_CUDA(transforms);
    CHECK_CONTIGUOUS(transforms);
    TORCH_CHECK(transforms.dim() == 2,
                "transforms must have shape [num_transforms, dim]");
    TORCH_CHECK(transforms.scalar_type() == features.scalar_type(),
                "transforms dtype must match features dtype");
    TORCH_CHECK(transforms.size(0) > 0, "transforms must contain at least one transform");
    TORCH_CHECK(transforms.size(1) == features.size(1),
                "transforms dim must match features dim");
    TORCH_CHECK(reinterpret_cast<uintptr_t>(transforms.data_ptr()) % alignof(uint32_t) == 0,
                "transforms pointer must be DWORD-aligned");
}

struct LaunchMeta
{
    int64_t num_rows;
    int64_t num_tasks;
    int64_t tile_tokens;
    int64_t dim;
    int64_t dim_dwords;
    int64_t tile_dwords;
    int64_t total_dwords;
    int64_t shared_bytes;
};

LaunchMeta make_meta(const at::Tensor& features, const at::Tensor& indices)
{
    LaunchMeta meta;
    meta.num_rows     = features.size(0);
    meta.num_tasks    = indices.size(0);
    meta.tile_tokens  = indices.size(1);
    meta.dim          = features.size(1);
    meta.dim_dwords   = meta.dim / 2;
    meta.tile_dwords  = meta.tile_tokens * meta.dim_dwords;
    meta.total_dwords = meta.num_tasks * meta.tile_dwords;
    meta.shared_bytes = meta.tile_dwords * static_cast<int64_t>(sizeof(uint32_t));

    TORCH_CHECK(meta.num_rows > 0, "features must contain at least one row");
    TORCH_CHECK(meta.num_tasks > 0, "indices must contain at least one task");
    TORCH_CHECK(meta.tile_tokens > 0, "indices must contain at least one token per task");
    TORCH_CHECK(meta.shared_bytes <= 64 * 1024,
                "per-task LDS tile exceeds 64 KiB: ",
                meta.shared_bytes);
    return meta;
}

int dtype_id_for(const at::Tensor& features)
{
    return features.scalar_type() == at::kHalf ? 0 : 1;
}

enum class GraphVariantKind
{
    Global,
    Lds,
    Chunked
};

struct GraphPolicyKey
{
    int dtype_id;
    int64_t tasks;
    int64_t tile_tokens;
    int64_t dim;
    int64_t num_transforms;

    bool operator==(const GraphPolicyKey& other) const
    {
        return dtype_id == other.dtype_id && tasks == other.tasks &&
               tile_tokens == other.tile_tokens && dim == other.dim &&
               num_transforms == other.num_transforms;
    }
};

struct GraphPolicyKeyHash
{
    std::size_t operator()(const GraphPolicyKey& key) const
    {
        std::size_t seed = 0;
        hash_combine(seed, std::hash<int>{}(key.dtype_id));
        hash_combine(seed, std::hash<int64_t>{}(key.tasks));
        hash_combine(seed, std::hash<int64_t>{}(key.tile_tokens));
        hash_combine(seed, std::hash<int64_t>{}(key.dim));
        hash_combine(seed, std::hash<int64_t>{}(key.num_transforms));
        return seed;
    }

    static void hash_combine(std::size_t& seed, std::size_t value)
    {
        seed ^= value + 0x9e3779b97f4a7c15ULL + (seed << 6) + (seed >> 2);
    }
};

struct GraphPolicyEntry
{
    GraphVariantKind variant;
    int64_t chunk_size;
};

using GraphPolicyTable =
    std::unordered_map<GraphPolicyKey, GraphPolicyEntry, GraphPolicyKeyHash>;

bool graph_lds_dynamic_shared_fits(int64_t tile_tokens, int64_t dim)
{
    const int64_t dim_dwords = dim / 2;
    const int64_t tile_dwords = tile_tokens * dim_dwords;
    const int64_t tile_bytes = tile_dwords * static_cast<int64_t>(sizeof(uint32_t));
    const int64_t reduction_bytes = static_cast<int64_t>(kThreads) * sizeof(float);
    return tile_bytes + reduction_bytes <= 64 * 1024;
}

bool parse_graph_variant(const std::string& value,
                         GraphVariantKind* variant,
                         int64_t* chunk_size)
{
    if(value == "global" || value == "graph_global")
    {
        *variant = GraphVariantKind::Global;
        *chunk_size = 0;
        return true;
    }
    if(value == "lds" || value == "graph_lds")
    {
        *variant = GraphVariantKind::Lds;
        *chunk_size = 0;
        return true;
    }
    if(value == "chunk2")
    {
        *variant = GraphVariantKind::Chunked;
        *chunk_size = 2;
        return true;
    }
    if(value == "chunk4")
    {
        *variant = GraphVariantKind::Chunked;
        *chunk_size = 4;
        return true;
    }
    if(value == "chunk8")
    {
        *variant = GraphVariantKind::Chunked;
        *chunk_size = 8;
        return true;
    }
    if(value == "graph_lds_chunked")
    {
        *variant = GraphVariantKind::Chunked;
        return *chunk_size > 0;
    }
    return false;
}

std::vector<std::string> split_csv_line(const std::string& line)
{
    std::vector<std::string> fields;
    std::stringstream ss(line);
    std::string field;
    while(std::getline(ss, field, ','))
    {
        fields.push_back(field);
    }
    return fields;
}

const GraphPolicyTable& graph_policy_table()
{
    static std::once_flag once;
    static GraphPolicyTable table;

    std::call_once(once, []() {
        const char* path = std::getenv("RDNA3_GATHER_GRAPH_POLICY");
        if(path == nullptr || path[0] == '\0')
        {
            return;
        }

        std::ifstream file(path);
        if(!file.good())
        {
            return;
        }

        std::string line;
        bool first = true;
        while(std::getline(file, line))
        {
            if(line.empty())
            {
                continue;
            }
            if(first)
            {
                first = false;
                if(line.find("dtype") != std::string::npos)
                {
                    continue;
                }
            }

            const auto fields = split_csv_line(line);
            if(fields.size() < 7)
            {
                continue;
            }

            GraphPolicyKey key;
            if(fields[0] == "fp16")
            {
                key.dtype_id = 0;
            }
            else if(fields[0] == "bf16")
            {
                key.dtype_id = 1;
            }
            else
            {
                continue;
            }

            GraphPolicyEntry entry;
            try
            {
                key.tasks = std::stoll(fields[1]);
                key.tile_tokens = std::stoll(fields[2]);
                key.dim = std::stoll(fields[3]);
                key.num_transforms = std::stoll(fields[4]);
                entry.chunk_size = std::stoll(fields[6]);
            }
            catch(...)
            {
                continue;
            }

            if(!parse_graph_variant(fields[5], &entry.variant, &entry.chunk_size))
            {
                continue;
            }
            table[key] = entry;
        }
    });

    return table;
}

bool lookup_graph_policy_table(int dtype_id,
                               int64_t tasks,
                               int64_t tile_tokens,
                               int64_t dim,
                               int64_t num_transforms,
                               GraphVariantKind* variant,
                               int64_t* chunk_size)
{
    const auto& table = graph_policy_table();
    const GraphPolicyKey key{dtype_id, tasks, tile_tokens, dim, num_transforms};
    const auto it = table.find(key);
    if(it != table.end())
    {
        *variant = it->second.variant;
        *chunk_size = it->second.chunk_size;
        return true;
    }
    return false;
}

GraphVariantKind choose_graph_auto_variant(const at::Tensor& features,
                                           int64_t num_tasks,
                                           int64_t tile_tokens,
                                           int64_t dim,
                                           int64_t num_transforms,
                                           int64_t* transform_chunk_size)
{
    constexpr int64_t small_task_count = 128;
    const int dtype_id = dtype_id_for(features);
    const bool is_bf16 = dtype_id == 1;

    *transform_chunk_size = 0;

    GraphVariantKind table_variant = GraphVariantKind::Global;
    int64_t table_chunk_size = 0;
    if(lookup_graph_policy_table(dtype_id,
                                 num_tasks,
                                 tile_tokens,
                                 dim,
                                 num_transforms,
                                 &table_variant,
                                 &table_chunk_size))
    {
        if(table_variant == GraphVariantKind::Global ||
           graph_lds_dynamic_shared_fits(tile_tokens, dim))
        {
            *transform_chunk_size = table_chunk_size;
            return table_variant;
        }
        return GraphVariantKind::Global;
    }

    if(!graph_lds_dynamic_shared_fits(tile_tokens, dim))
    {
        return GraphVariantKind::Global;
    }

    if(num_tasks < small_task_count)
    {
        if(is_bf16 && num_transforms >= 32)
        {
            *transform_chunk_size = 4;
            return GraphVariantKind::Chunked;
        }

        if(is_bf16 && num_transforms >= 16)
        {
            *transform_chunk_size = 2;
            return GraphVariantKind::Chunked;
        }

        if(!is_bf16 && num_transforms >= 64)
        {
            *transform_chunk_size = 2;
            return GraphVariantKind::Chunked;
        }

        return GraphVariantKind::Global;
    }

    if(num_transforms >= 32)
    {
        *transform_chunk_size = 8;
        return GraphVariantKind::Chunked;
    }

    if(num_transforms >= 16)
    {
        *transform_chunk_size = num_tasks >= 256 ? 8 : 4;
        return GraphVariantKind::Chunked;
    }

    if(num_transforms >= 8)
    {
        *transform_chunk_size = (is_bf16 && num_tasks >= 256) ? 8 : 4;
        return GraphVariantKind::Chunked;
    }

    return GraphVariantKind::Global;
}

std::string graph_variant_kind_name(GraphVariantKind kind, int64_t transform_chunk_size)
{
    if(kind == GraphVariantKind::Global)
    {
        return "graph_global";
    }
    if(kind == GraphVariantKind::Lds)
    {
        return "graph_lds";
    }
    return "graph_lds_chunked(chunk=" + std::to_string(transform_chunk_size) + ")";
}

at::Tensor launch_common(const at::Tensor& features,
                         const at::Tensor& indices,
                         const std::string& variant)
{
    validate_inputs(features, indices);
    const auto meta = make_meta(features, indices);

    auto output = torch::empty({meta.num_tasks, meta.tile_tokens, meta.dim}, features.options());
    TORCH_CHECK(reinterpret_cast<uintptr_t>(output.data_ptr()) % alignof(uint32_t) == 0,
                "output pointer must be DWORD-aligned");

    at::cuda::CUDAGuard device_guard{features.device()};
    auto stream = at::cuda::getCurrentCUDAStream().stream();

    const auto* feature_u32 = reinterpret_cast<const uint32_t*>(features.data_ptr());
    const auto* index_i32   = indices.data_ptr<int>();
    auto* output_u32        = reinterpret_cast<uint32_t*>(output.data_ptr());

    if(variant == "baseline")
    {
        const int64_t blocks64 = (meta.total_dwords + kThreads - 1) / kThreads;
        const int blocks       = static_cast<int>(std::min<int64_t>(blocks64, 65535));
        hipLaunchKernelGGL(gather_global_kernel,
                           dim3(blocks),
                           dim3(kThreads),
                           0,
                           stream,
                           feature_u32,
                           index_i32,
                           output_u32,
                           meta.num_rows,
                           meta.num_tasks,
                           meta.tile_tokens,
                           meta.dim_dwords,
                           meta.total_dwords);
    }
    else if(variant == "vgpr_lds")
    {
        hipLaunchKernelGGL(gather_vgpr_lds_kernel,
                           dim3(meta.num_tasks),
                           dim3(kThreads),
                           static_cast<uint32_t>(meta.shared_bytes),
                           stream,
                           feature_u32,
                           index_i32,
                           output_u32,
                           meta.num_rows,
                           meta.tile_tokens,
                           meta.dim_dwords,
                           meta.tile_dwords);
    }
    else if(variant == "direct_lds")
    {
        hipLaunchKernelGGL(gather_direct_lds_kernel,
                           dim3(meta.num_tasks),
                           dim3(kThreads),
                           static_cast<uint32_t>(meta.shared_bytes),
                           stream,
                           feature_u32,
                           index_i32,
                           output_u32,
                           meta.num_rows,
                           meta.tile_tokens,
                           meta.dim_dwords,
                           meta.tile_dwords,
                           meta.num_rows * meta.dim_dwords);
    }
    else
    {
        TORCH_CHECK(false, "unknown variant: ", variant);
    }

    check_launch();
    return output;
}

at::Tensor launch_fused_common(const at::Tensor& features,
                               const at::Tensor& indices,
                               int64_t consumer_passes,
                               const std::string& variant)
{
    validate_inputs(features, indices);
    TORCH_CHECK(consumer_passes > 0, "consumer_passes must be positive");
    TORCH_CHECK(consumer_passes <= std::numeric_limits<int>::max(),
                "consumer_passes exceeds int range");
    const auto meta = make_meta(features, indices);
    const auto reduction_shared_bytes = static_cast<int64_t>(kThreads) * sizeof(float);
    const auto lds_fused_shared_bytes = meta.shared_bytes + reduction_shared_bytes;
    TORCH_CHECK(lds_fused_shared_bytes <= 64 * 1024,
                "Phase 2 fused LDS shared memory exceeds 64 KiB: ",
                lds_fused_shared_bytes);

    auto output = torch::empty({meta.num_tasks}, features.options().dtype(at::kFloat));

    at::cuda::CUDAGuard device_guard{features.device()};
    auto stream = at::cuda::getCurrentCUDAStream().stream();

    const auto* feature_u32 = reinterpret_cast<const uint32_t*>(features.data_ptr());
    const auto* index_i32   = indices.data_ptr<int>();
    auto* output_f32        = output.data_ptr<float>();
    const int passes        = static_cast<int>(consumer_passes);
    const int dtype_id      = dtype_id_for(features);

    if(variant == "fused_global")
    {
        hipLaunchKernelGGL(fused_global_sum_kernel,
                           dim3(meta.num_tasks),
                           dim3(kThreads),
                           static_cast<uint32_t>(reduction_shared_bytes),
                           stream,
                           feature_u32,
                           index_i32,
                           output_f32,
                           meta.num_rows,
                           meta.tile_tokens,
                           meta.dim_dwords,
                           meta.tile_dwords,
                           passes,
                           dtype_id);
    }
    else if(variant == "fused_lds")
    {
        hipLaunchKernelGGL(fused_lds_sum_kernel,
                           dim3(meta.num_tasks),
                           dim3(kThreads),
                           static_cast<uint32_t>(lds_fused_shared_bytes),
                           stream,
                           feature_u32,
                           index_i32,
                           output_f32,
                           meta.num_rows,
                           meta.tile_tokens,
                           meta.dim_dwords,
                           meta.tile_dwords,
                           passes,
                           dtype_id);
    }
    else
    {
        TORCH_CHECK(false, "unknown fused variant: ", variant);
    }

    check_launch();
    return output;
}

at::Tensor launch_dot_common(const at::Tensor& features,
                             const at::Tensor& indices,
                             const at::Tensor& queries,
                             const std::string& variant)
{
    validate_queries(features, indices, queries);
    const auto meta = make_meta(features, indices);
    const int64_t num_queries = queries.size(1);

    auto output =
        torch::empty({meta.num_tasks, num_queries, meta.tile_tokens},
                     features.options().dtype(at::kFloat));

    at::cuda::CUDAGuard device_guard{features.device()};
    auto stream = at::cuda::getCurrentCUDAStream().stream();

    const auto* feature_u32 = reinterpret_cast<const uint32_t*>(features.data_ptr());
    const auto* query_u32   = reinterpret_cast<const uint32_t*>(queries.data_ptr());
    const auto* index_i32   = indices.data_ptr<int>();
    auto* output_f32        = output.data_ptr<float>();
    const int dtype_id      = dtype_id_for(features);

    if(variant == "dot_global")
    {
        hipLaunchKernelGGL(dot_global_kernel,
                           dim3(meta.num_tasks),
                           dim3(kThreads),
                           0,
                           stream,
                           feature_u32,
                           query_u32,
                           index_i32,
                           output_f32,
                           meta.num_rows,
                           meta.tile_tokens,
                           meta.dim_dwords,
                           num_queries,
                           dtype_id);
    }
    else if(variant == "dot_lds")
    {
        hipLaunchKernelGGL(dot_lds_kernel,
                           dim3(meta.num_tasks),
                           dim3(kThreads),
                           static_cast<uint32_t>(meta.shared_bytes),
                           stream,
                           feature_u32,
                           query_u32,
                           index_i32,
                           output_f32,
                           meta.num_rows,
                           meta.tile_tokens,
                           meta.dim_dwords,
                           meta.tile_dwords,
                           num_queries,
                           dtype_id);
    }
    else
    {
        TORCH_CHECK(false, "unknown dot variant: ", variant);
    }

    check_launch();
    return output;
}

at::Tensor launch_graph_common(const at::Tensor& features,
                               const at::Tensor& indices,
                               const at::Tensor& transforms,
                               int64_t transform_chunk_size,
                               const std::string& variant)
{
    validate_transforms(features, indices, transforms);
    const auto meta = make_meta(features, indices);
    const int64_t num_transforms = transforms.size(0);
    const auto reduction_shared_bytes = static_cast<int64_t>(kThreads) * sizeof(float);
    const auto lds_graph_shared_bytes = meta.shared_bytes + reduction_shared_bytes;
    TORCH_CHECK(meta.num_tasks * num_transforms <= std::numeric_limits<int>::max(),
                "graph_global grid exceeds int range");
    if(variant == "graph_lds_chunked")
    {
        TORCH_CHECK(transform_chunk_size > 0,
                    "transform_chunk_size must be positive for graph_lds_chunked");
        TORCH_CHECK(transform_chunk_size <= std::numeric_limits<int>::max(),
                    "transform_chunk_size exceeds int range");
    }

    auto output =
        torch::empty({meta.num_tasks, num_transforms},
                     features.options().dtype(at::kFloat));

    at::cuda::CUDAGuard device_guard{features.device()};
    auto stream = at::cuda::getCurrentCUDAStream().stream();

    const auto* feature_u32   = reinterpret_cast<const uint32_t*>(features.data_ptr());
    const auto* transform_u32 = reinterpret_cast<const uint32_t*>(transforms.data_ptr());
    const auto* index_i32     = indices.data_ptr<int>();
    auto* output_f32          = output.data_ptr<float>();
    const int dtype_id        = dtype_id_for(features);
    GraphVariantKind effective_variant = GraphVariantKind::Global;
    int64_t effective_chunk_size = transform_chunk_size;

    if(variant == "graph_global")
    {
        effective_variant = GraphVariantKind::Global;
    }
    else if(variant == "graph_lds")
    {
        effective_variant = GraphVariantKind::Lds;
    }
    else if(variant == "graph_lds_chunked")
    {
        effective_variant = GraphVariantKind::Chunked;
    }
    else if(variant == "graph_auto")
    {
        effective_variant = choose_graph_auto_variant(features,
                                                      meta.num_tasks,
                                                      meta.tile_tokens,
                                                      meta.dim,
                                                      num_transforms,
                                                      &effective_chunk_size);
    }
    else
    {
        TORCH_CHECK(false, "unknown graph variant: ", variant);
    }

    if(effective_variant == GraphVariantKind::Global)
    {
        hipLaunchKernelGGL(graph_global_kernel,
                           dim3(static_cast<uint32_t>(meta.num_tasks * num_transforms)),
                           dim3(kThreads),
                           static_cast<uint32_t>(reduction_shared_bytes),
                           stream,
                           feature_u32,
                           transform_u32,
                           index_i32,
                           output_f32,
                           meta.num_rows,
                           meta.tile_tokens,
                           meta.dim_dwords,
                           meta.tile_dwords,
                           num_transforms,
                           dtype_id);
    }
    else if(effective_variant == GraphVariantKind::Lds)
    {
        TORCH_CHECK(lds_graph_shared_bytes <= 64 * 1024,
                    "Phase 2 graph LDS shared memory exceeds 64 KiB: ",
                    lds_graph_shared_bytes);
        hipLaunchKernelGGL(graph_lds_kernel,
                           dim3(meta.num_tasks),
                           dim3(kThreads),
                           static_cast<uint32_t>(lds_graph_shared_bytes),
                           stream,
                           feature_u32,
                           transform_u32,
                           index_i32,
                           output_f32,
                           meta.num_rows,
                           meta.tile_tokens,
                           meta.dim_dwords,
                           meta.tile_dwords,
                           num_transforms,
                           dtype_id);
    }
    else
    {
        TORCH_CHECK(lds_graph_shared_bytes <= 64 * 1024,
                    "Phase 2 graph chunked LDS shared memory exceeds 64 KiB: ",
                    lds_graph_shared_bytes);
        TORCH_CHECK(effective_chunk_size > 0,
                    "transform_chunk_size must be positive for graph_lds_chunked");
        const int64_t num_transform_chunks =
            (num_transforms + effective_chunk_size - 1) / effective_chunk_size;
        TORCH_CHECK(meta.num_tasks * num_transform_chunks <= std::numeric_limits<int>::max(),
                    "graph_lds_chunked grid exceeds int range");
        hipLaunchKernelGGL(graph_lds_chunked_kernel,
                           dim3(static_cast<uint32_t>(meta.num_tasks * num_transform_chunks)),
                           dim3(kThreads),
                           static_cast<uint32_t>(lds_graph_shared_bytes),
                           stream,
                           feature_u32,
                           transform_u32,
                           index_i32,
                           output_f32,
                           meta.num_rows,
                           meta.tile_tokens,
                           meta.dim_dwords,
                           meta.tile_dwords,
                           num_transforms,
                           num_transform_chunks,
                           effective_chunk_size,
                           dtype_id);
    }

    check_launch();
    return output;
}

int default_persistent_block_count()
{
    int device = 0;
    hipError_t err = hipGetDevice(&device);
    TORCH_CHECK(err == hipSuccess, "hipGetDevice failed: ", hipGetErrorString(err));

    int multiprocessor_count = 0;
    err = hipDeviceGetAttribute(
        &multiprocessor_count, hipDeviceAttributeMultiprocessorCount, device);
    TORCH_CHECK(err == hipSuccess,
                "hipDeviceGetAttribute(MultiprocessorCount) failed: ",
                hipGetErrorString(err));
    return multiprocessor_count > 0 ? multiprocessor_count : 1;
}

void validate_varlen_graph_inputs(const at::Tensor& features,
                                  const at::Tensor& offsets,
                                  const at::Tensor& flat_indices,
                                  const at::Tensor& transforms,
                                  const at::Tensor& task_order)
{
    CHECK_CUDA(features);
    CHECK_CUDA(offsets);
    CHECK_CUDA(flat_indices);
    CHECK_CUDA(transforms);
    CHECK_CUDA(task_order);
    CHECK_CONTIGUOUS(features);
    CHECK_CONTIGUOUS(offsets);
    CHECK_CONTIGUOUS(flat_indices);
    CHECK_CONTIGUOUS(transforms);
    CHECK_CONTIGUOUS(task_order);
    TORCH_CHECK(features.dim() == 2, "features must have shape [num_rows, dim]");
    TORCH_CHECK(offsets.dim() == 1, "offsets must have shape [num_tasks + 1]");
    TORCH_CHECK(flat_indices.dim() == 1, "flat_indices must have shape [num_edges]");
    TORCH_CHECK(transforms.dim() == 2, "transforms must have shape [num_transforms, dim]");
    TORCH_CHECK(task_order.dim() == 1, "task_order must have shape [num_tasks]");
    TORCH_CHECK(offsets.scalar_type() == at::kInt, "offsets must be int32");
    TORCH_CHECK(flat_indices.scalar_type() == at::kInt, "flat_indices must be int32");
    TORCH_CHECK(task_order.scalar_type() == at::kInt, "task_order must be int32");
    TORCH_CHECK(features.scalar_type() == at::kHalf || features.scalar_type() == at::kBFloat16,
                "features must be fp16 or bf16");
    TORCH_CHECK(transforms.scalar_type() == features.scalar_type(),
                "transforms dtype must match features dtype");
    TORCH_CHECK(transforms.size(1) == features.size(1),
                "transforms dim must match features dim");
    TORCH_CHECK(features.size(1) % 2 == 0, "dim must be even for DWORD graph kernels");
    TORCH_CHECK(offsets.size(0) >= 2, "offsets must contain at least one task");
    TORCH_CHECK(task_order.size(0) == offsets.size(0) - 1,
                "task_order length must match num_tasks");
    TORCH_CHECK(transforms.size(0) > 0, "transforms must contain at least one transform");
}

void validate_varlen_work_items(const at::Tensor& work_task,
                                const at::Tensor& work_start,
                                const at::Tensor& work_count,
                                const at::Tensor& work_transform)
{
    CHECK_CUDA(work_task);
    CHECK_CUDA(work_start);
    CHECK_CUDA(work_count);
    CHECK_CUDA(work_transform);
    CHECK_CONTIGUOUS(work_task);
    CHECK_CONTIGUOUS(work_start);
    CHECK_CONTIGUOUS(work_count);
    CHECK_CONTIGUOUS(work_transform);
    TORCH_CHECK(work_task.dim() == 1, "work_task must be 1D");
    TORCH_CHECK(work_start.dim() == 1, "work_start must be 1D");
    TORCH_CHECK(work_count.dim() == 1, "work_count must be 1D");
    TORCH_CHECK(work_transform.dim() == 1, "work_transform must be 1D");
    TORCH_CHECK(work_task.scalar_type() == at::kInt, "work_task must be int32");
    TORCH_CHECK(work_start.scalar_type() == at::kInt, "work_start must be int32");
    TORCH_CHECK(work_count.scalar_type() == at::kInt, "work_count must be int32");
    TORCH_CHECK(work_transform.scalar_type() == at::kInt, "work_transform must be int32");
    TORCH_CHECK(work_task.size(0) == work_start.size(0), "work item tensor sizes must match");
    TORCH_CHECK(work_task.size(0) == work_count.size(0), "work item tensor sizes must match");
    TORCH_CHECK(work_task.size(0) == work_transform.size(0), "work item tensor sizes must match");
    TORCH_CHECK(work_task.size(0) > 0, "work item list must not be empty");
}

void validate_varlen_worklist_inputs(const at::Tensor& offsets,
                                     const at::Tensor& task_order,
                                     const at::Tensor& transform_counts,
                                     const at::Tensor& edge_limits,
                                     int64_t num_transforms,
                                     int64_t chunk_tokens)
{
    CHECK_CUDA(offsets);
    CHECK_CUDA(task_order);
    CHECK_CUDA(transform_counts);
    CHECK_CUDA(edge_limits);
    CHECK_CONTIGUOUS(offsets);
    CHECK_CONTIGUOUS(task_order);
    CHECK_CONTIGUOUS(transform_counts);
    CHECK_CONTIGUOUS(edge_limits);
    TORCH_CHECK(offsets.dim() == 1, "offsets must be 1D");
    TORCH_CHECK(task_order.dim() == 1, "task_order must be 1D");
    TORCH_CHECK(transform_counts.dim() == 1, "transform_counts must be 1D");
    TORCH_CHECK(edge_limits.dim() == 2, "edge_limits must have shape [num_tasks, num_transforms]");
    TORCH_CHECK(offsets.scalar_type() == at::kInt, "offsets must be int32");
    TORCH_CHECK(task_order.scalar_type() == at::kInt, "task_order must be int32");
    TORCH_CHECK(transform_counts.scalar_type() == at::kInt, "transform_counts must be int32");
    TORCH_CHECK(edge_limits.scalar_type() == at::kInt, "edge_limits must be int32");
    TORCH_CHECK(offsets.size(0) > 1, "offsets must contain at least one task");
    const int64_t num_tasks = offsets.size(0) - 1;
    TORCH_CHECK(task_order.size(0) == num_tasks, "task_order length must match num_tasks");
    TORCH_CHECK(transform_counts.size(0) == num_tasks,
                "transform_counts length must match num_tasks");
    TORCH_CHECK(edge_limits.size(0) == num_tasks, "edge_limits num_tasks mismatch");
    TORCH_CHECK(edge_limits.size(1) == num_transforms, "edge_limits num_transforms mismatch");
    TORCH_CHECK(num_transforms > 0, "num_transforms must be positive");
    TORCH_CHECK(chunk_tokens > 0, "chunk_tokens must be positive");
    TORCH_CHECK(num_tasks * num_transforms <= std::numeric_limits<int>::max(),
                "worklist pair count exceeds int range");
}

std::vector<at::Tensor> launch_graph_build_varlen_work_items(const at::Tensor& offsets,
                                                             const at::Tensor& task_order,
                                                             const at::Tensor& transform_counts,
                                                             const at::Tensor& edge_limits,
                                                             int64_t num_transforms,
                                                             int64_t chunk_tokens)
{
    validate_varlen_worklist_inputs(offsets,
                                    task_order,
                                    transform_counts,
                                    edge_limits,
                                    num_transforms,
                                    chunk_tokens);
    const int64_t num_tasks = offsets.size(0) - 1;
    const int64_t total_pairs = num_tasks * num_transforms;
    const auto options = offsets.options().dtype(at::kInt);
    auto pair_chunk_counts = torch::empty({total_pairs}, options);

    at::cuda::CUDAGuard device_guard{offsets.device()};
    auto stream = at::cuda::getCurrentCUDAStream().stream();
    const int blocks = static_cast<int>((total_pairs + kThreads - 1) / kThreads);

    hipLaunchKernelGGL(graph_varlen_work_chunk_counts_kernel,
                       dim3(blocks),
                       dim3(kThreads),
                       0,
                       stream,
                       offsets.data_ptr<int>(),
                       task_order.data_ptr<int>(),
                       transform_counts.data_ptr<int>(),
                       edge_limits.data_ptr<int>(),
                       pair_chunk_counts.data_ptr<int>(),
                       num_tasks,
                       num_transforms,
                       static_cast<int>(chunk_tokens));
    check_launch();

    auto pair_chunk_ends = at::cumsum(pair_chunk_counts, 0, at::kInt);
    const int total_chunks =
        pair_chunk_ends.index({total_pairs - 1}).item<int>();
    TORCH_CHECK(total_chunks > 0, "generated work item list must not be empty");

    auto work_task = torch::empty({total_chunks}, options);
    auto work_start = torch::empty({total_chunks}, options);
    auto work_count = torch::empty({total_chunks}, options);
    auto work_transform = torch::empty({total_chunks}, options);

    hipLaunchKernelGGL(graph_varlen_fill_work_items_kernel,
                       dim3(blocks),
                       dim3(kThreads),
                       0,
                       stream,
                       offsets.data_ptr<int>(),
                       task_order.data_ptr<int>(),
                       edge_limits.data_ptr<int>(),
                       pair_chunk_ends.data_ptr<int>(),
                       work_task.data_ptr<int>(),
                       work_start.data_ptr<int>(),
                       work_count.data_ptr<int>(),
                       work_transform.data_ptr<int>(),
                       num_tasks,
                       num_transforms,
                       static_cast<int>(chunk_tokens));
    check_launch();

    return {work_task, work_start, work_count, work_transform};
}

std::vector<at::Tensor> launch_graph_build_varlen_work_items_fixed(
    const at::Tensor& offsets,
    const at::Tensor& task_order,
    const at::Tensor& transform_counts,
    const at::Tensor& edge_limits,
    int64_t num_transforms,
    int64_t chunk_tokens,
    int64_t work_capacity)
{
    validate_varlen_worklist_inputs(offsets,
                                    task_order,
                                    transform_counts,
                                    edge_limits,
                                    num_transforms,
                                    chunk_tokens);
    TORCH_CHECK(work_capacity > 0, "work_capacity must be positive");
    TORCH_CHECK(work_capacity <= std::numeric_limits<uint32_t>::max(),
                "work_capacity exceeds uint32 launch range");
    const int64_t num_tasks = offsets.size(0) - 1;
    const int64_t total_pairs = num_tasks * num_transforms;
    const auto options = offsets.options().dtype(at::kInt);
    auto pair_chunk_counts = torch::empty({total_pairs}, options);

    at::cuda::CUDAGuard device_guard{offsets.device()};
    auto stream = at::cuda::getCurrentCUDAStream().stream();
    const int blocks = static_cast<int>((total_pairs + kThreads - 1) / kThreads);

    hipLaunchKernelGGL(graph_varlen_work_chunk_counts_kernel,
                       dim3(blocks),
                       dim3(kThreads),
                       0,
                       stream,
                       offsets.data_ptr<int>(),
                       task_order.data_ptr<int>(),
                       transform_counts.data_ptr<int>(),
                       edge_limits.data_ptr<int>(),
                       pair_chunk_counts.data_ptr<int>(),
                       num_tasks,
                       num_transforms,
                       static_cast<int>(chunk_tokens));
    check_launch();

    auto pair_chunk_ends = at::cumsum(pair_chunk_counts, 0, at::kInt);
    auto work_size = torch::empty({1}, options);
    hipLaunchKernelGGL(graph_varlen_store_work_size_kernel,
                       dim3(1),
                       dim3(1),
                       0,
                       stream,
                       pair_chunk_ends.data_ptr<int>(),
                       work_size.data_ptr<int>(),
                       total_pairs);
    check_launch();

    auto work_task = torch::empty({work_capacity}, options);
    auto work_start = torch::empty({work_capacity}, options);
    auto work_count = torch::empty({work_capacity}, options);
    auto work_transform = torch::empty({work_capacity}, options);

    hipLaunchKernelGGL(graph_varlen_fill_work_items_fixed_kernel,
                       dim3(blocks),
                       dim3(kThreads),
                       0,
                       stream,
                       offsets.data_ptr<int>(),
                       task_order.data_ptr<int>(),
                       edge_limits.data_ptr<int>(),
                       pair_chunk_ends.data_ptr<int>(),
                       work_task.data_ptr<int>(),
                       work_start.data_ptr<int>(),
                       work_count.data_ptr<int>(),
                       work_transform.data_ptr<int>(),
                       num_tasks,
                       num_transforms,
                       work_capacity,
                       static_cast<int>(chunk_tokens));
    check_launch();

    return {work_task, work_start, work_count, work_transform, work_size};
}

std::vector<at::Tensor> launch_graph_generate_varlen_metadata(const at::Tensor& device_anchor,
                                                              int64_t num_tasks,
                                                              int64_t rows,
                                                              int64_t mean_neighbors,
                                                              int64_t max_neighbors,
                                                              double skew,
                                                              double pareto_alpha,
                                                              int64_t seed,
                                                              const std::string& index_pattern,
                                                              int64_t num_transforms,
                                                              double filter_ratio,
                                                              double transform_active_ratio,
                                                              double early_exit_ratio,
                                                              int64_t num_buckets)
{
    CHECK_CUDA(device_anchor);
    TORCH_CHECK(num_tasks > 0, "num_tasks must be positive");
    TORCH_CHECK(rows > 0, "rows must be positive");
    TORCH_CHECK(mean_neighbors > 0, "mean_neighbors must be positive");
    TORCH_CHECK(max_neighbors > 0, "max_neighbors must be positive");
    TORCH_CHECK(num_transforms > 0, "num_transforms must be positive");
    TORCH_CHECK(num_buckets > 0, "num_buckets must be positive");
    TORCH_CHECK(num_tasks <= std::numeric_limits<int>::max(),
                "num_tasks exceeds int range");
    TORCH_CHECK(rows <= std::numeric_limits<int>::max(), "rows exceeds int range");
    TORCH_CHECK(mean_neighbors <= std::numeric_limits<int>::max(),
                "mean_neighbors exceeds int range");
    TORCH_CHECK(max_neighbors <= std::numeric_limits<int>::max(),
                "max_neighbors exceeds int range");
    TORCH_CHECK(num_transforms <= std::numeric_limits<int>::max(),
                "num_transforms exceeds int range");
    TORCH_CHECK(num_buckets <= std::numeric_limits<int>::max(),
                "num_buckets exceeds int range");
    TORCH_CHECK(num_tasks * num_transforms <= std::numeric_limits<int>::max(),
                "dynamic metadata pair count exceeds int range");

    int index_pattern_id = 0;
    if(index_pattern == "contiguous")
    {
        index_pattern_id = 1;
    }
    else
    {
        TORCH_CHECK(index_pattern == "random",
                    "GPU metadata builder supports random or contiguous index_pattern");
    }

    const auto options = device_anchor.options().dtype(at::kInt);
    auto counts = torch::empty({num_tasks}, options);
    auto offsets = torch::empty({num_tasks + 1}, options);
    auto identity_order = torch::empty({num_tasks}, options);
    auto bucket_order = torch::empty({num_tasks}, options);
    auto transform_counts = torch::empty({num_tasks}, options);
    auto edge_limits = torch::empty({num_tasks, num_transforms}, options);

    at::cuda::CUDAGuard device_guard{device_anchor.device()};
    auto stream = at::cuda::getCurrentCUDAStream().stream();
    const int task_blocks = static_cast<int>((num_tasks + kThreads - 1) / kThreads);

    hipLaunchKernelGGL(graph_generate_counts_kernel,
                       dim3(task_blocks),
                       dim3(kThreads),
                       0,
                       stream,
                       counts.data_ptr<int>(),
                       num_tasks,
                       static_cast<int>(mean_neighbors),
                       static_cast<int>(max_neighbors),
                       static_cast<float>(skew),
                       static_cast<float>(pareto_alpha),
                       static_cast<uint32_t>(seed));
    check_launch();

    auto count_prefix = at::cumsum(counts, 0, at::kInt);
    hipLaunchKernelGGL(graph_offsets_from_counts_kernel,
                       dim3(task_blocks),
                       dim3(kThreads),
                       0,
                       stream,
                       count_prefix.data_ptr<int>(),
                       offsets.data_ptr<int>(),
                       num_tasks);
    check_launch();

    const int total_edges = count_prefix.index({num_tasks - 1}).item<int>();
    TORCH_CHECK(total_edges > 0, "generated graph must contain at least one edge");
    auto flat_indices = torch::empty({total_edges}, options);

    hipLaunchKernelGGL(graph_fill_identity_order_kernel,
                       dim3(task_blocks),
                       dim3(kThreads),
                       0,
                       stream,
                       identity_order.data_ptr<int>(),
                       num_tasks);
    check_launch();

    hipLaunchKernelGGL(graph_fill_flat_indices_kernel,
                       dim3(static_cast<uint32_t>(num_tasks)),
                       dim3(kThreads),
                       0,
                       stream,
                       offsets.data_ptr<int>(),
                       flat_indices.data_ptr<int>(),
                       num_tasks,
                       rows,
                       static_cast<int>(mean_neighbors),
                       index_pattern_id,
                       static_cast<uint32_t>(seed + 104729));
    check_launch();

    const int pair_blocks =
        static_cast<int>((num_tasks * num_transforms + kThreads - 1) / kThreads);
    hipLaunchKernelGGL(graph_generate_dynamic_costs_kernel,
                       dim3(pair_blocks),
                       dim3(kThreads),
                       0,
                       stream,
                       offsets.data_ptr<int>(),
                       transform_counts.data_ptr<int>(),
                       edge_limits.data_ptr<int>(),
                       num_tasks,
                       num_transforms,
                       static_cast<float>(filter_ratio),
                       static_cast<float>(transform_active_ratio),
                       static_cast<float>(early_exit_ratio),
                       static_cast<uint32_t>(seed + 65537));
    check_launch();

    auto bucket_counts = torch::empty({num_buckets}, options);
    auto bucket_write = torch::empty({num_buckets}, options);
    hipError_t err =
        hipMemsetAsync(bucket_counts.data_ptr<int>(), 0, num_buckets * sizeof(int), stream);
    TORCH_CHECK(err == hipSuccess,
                "hipMemsetAsync(bucket_counts) failed: ",
                hipGetErrorString(err));
    err = hipMemsetAsync(bucket_write.data_ptr<int>(), 0, num_buckets * sizeof(int), stream);
    TORCH_CHECK(err == hipSuccess,
                "hipMemsetAsync(bucket_write) failed: ",
                hipGetErrorString(err));

    hipLaunchKernelGGL(graph_count_buckets_kernel,
                       dim3(task_blocks),
                       dim3(kThreads),
                       0,
                       stream,
                       counts.data_ptr<int>(),
                       bucket_counts.data_ptr<int>(),
                       num_tasks,
                       static_cast<int>(max_neighbors),
                       static_cast<int>(num_buckets));
    check_launch();

    auto bucket_prefix = at::cumsum(bucket_counts, 0, at::kInt);
    auto bucket_offsets = torch::empty({num_buckets}, options);
    const int bucket_blocks = static_cast<int>((num_buckets + kThreads - 1) / kThreads);
    hipLaunchKernelGGL(graph_bucket_offsets_desc_kernel,
                       dim3(bucket_blocks),
                       dim3(kThreads),
                       0,
                       stream,
                       bucket_prefix.data_ptr<int>(),
                       bucket_offsets.data_ptr<int>(),
                       static_cast<int>(num_tasks),
                       static_cast<int>(num_buckets));
    check_launch();

    hipLaunchKernelGGL(graph_fill_bucket_order_kernel,
                       dim3(task_blocks),
                       dim3(kThreads),
                       0,
                       stream,
                       counts.data_ptr<int>(),
                       bucket_offsets.data_ptr<int>(),
                       bucket_write.data_ptr<int>(),
                       bucket_order.data_ptr<int>(),
                       num_tasks,
                       static_cast<int>(max_neighbors),
                       static_cast<int>(num_buckets));
    check_launch();

    return {counts,
            offsets,
            flat_indices,
            identity_order,
            bucket_order,
            transform_counts,
            edge_limits};
}

at::Tensor launch_graph_varlen_static(const at::Tensor& features,
                                      const at::Tensor& offsets,
                                      const at::Tensor& flat_indices,
                                      const at::Tensor& transforms,
                                      const at::Tensor& task_order)
{
    validate_varlen_graph_inputs(features, offsets, flat_indices, transforms, task_order);
    const int64_t num_tasks = offsets.size(0) - 1;
    const int64_t num_transforms = transforms.size(0);
    TORCH_CHECK(num_tasks * num_transforms <= std::numeric_limits<uint32_t>::max(),
                "graph_varlen_static grid exceeds uint32 range");

    auto output =
        torch::empty({num_tasks, num_transforms}, features.options().dtype(at::kFloat));

    at::cuda::CUDAGuard device_guard{features.device()};
    auto stream = at::cuda::getCurrentCUDAStream().stream();

    hipLaunchKernelGGL(graph_varlen_static_kernel,
                       dim3(static_cast<uint32_t>(num_tasks * num_transforms)),
                       dim3(kThreads),
                       static_cast<uint32_t>(kThreads * sizeof(float)),
                       stream,
                       reinterpret_cast<const uint32_t*>(features.data_ptr()),
                       reinterpret_cast<const uint32_t*>(transforms.data_ptr()),
                       offsets.data_ptr<int>(),
                       flat_indices.data_ptr<int>(),
                       task_order.data_ptr<int>(),
                       output.data_ptr<float>(),
                       features.size(0),
                       num_transforms,
                       features.size(1) / 2,
                       dtype_id_for(features));

    check_launch();
    return output;
}

at::Tensor launch_graph_varlen_static_chunked(const at::Tensor& features,
                                              const at::Tensor& flat_indices,
                                              const at::Tensor& transforms,
                                              const at::Tensor& work_task,
                                              const at::Tensor& work_start,
                                              const at::Tensor& work_count,
                                              const at::Tensor& work_transform,
                                              int64_t num_tasks)
{
    validate_varlen_work_items(work_task, work_start, work_count, work_transform);
    CHECK_CUDA(features);
    CHECK_CUDA(flat_indices);
    CHECK_CUDA(transforms);
    CHECK_CONTIGUOUS(features);
    CHECK_CONTIGUOUS(flat_indices);
    CHECK_CONTIGUOUS(transforms);
    TORCH_CHECK(features.scalar_type() == at::kHalf || features.scalar_type() == at::kBFloat16,
                "features must be fp16 or bf16");
    TORCH_CHECK(flat_indices.scalar_type() == at::kInt, "flat_indices must be int32");
    TORCH_CHECK(transforms.scalar_type() == features.scalar_type(),
                "transforms dtype must match features dtype");
    TORCH_CHECK(features.dim() == 2, "features must have shape [num_rows, dim]");
    TORCH_CHECK(transforms.dim() == 2, "transforms must have shape [num_transforms, dim]");
    TORCH_CHECK(transforms.size(1) == features.size(1),
                "transforms dim must match features dim");
    TORCH_CHECK(features.size(1) % 2 == 0, "dim must be even for DWORD graph kernels");
    TORCH_CHECK(num_tasks > 0, "num_tasks must be positive");
    TORCH_CHECK(work_task.size(0) <= std::numeric_limits<uint32_t>::max(),
                "graph_varlen_static_chunked grid exceeds uint32 range");

    const int64_t num_transforms = transforms.size(0);
    auto output =
        torch::empty({num_tasks, num_transforms}, features.options().dtype(at::kFloat));

    at::cuda::CUDAGuard device_guard{features.device()};
    auto stream = at::cuda::getCurrentCUDAStream().stream();
    hipError_t err =
        hipMemsetAsync(output.data_ptr<float>(), 0, output.numel() * sizeof(float), stream);
    TORCH_CHECK(err == hipSuccess,
                "hipMemsetAsync(varlen chunked output) failed: ",
                hipGetErrorString(err));

    hipLaunchKernelGGL(graph_varlen_static_chunked_kernel,
                       dim3(static_cast<uint32_t>(work_task.size(0))),
                       dim3(kThreads),
                       static_cast<uint32_t>(kThreads * sizeof(float)),
                       stream,
                       reinterpret_cast<const uint32_t*>(features.data_ptr()),
                       reinterpret_cast<const uint32_t*>(transforms.data_ptr()),
                       flat_indices.data_ptr<int>(),
                       work_task.data_ptr<int>(),
                       work_start.data_ptr<int>(),
                       work_count.data_ptr<int>(),
                       work_transform.data_ptr<int>(),
                       output.data_ptr<float>(),
                       features.size(0),
                       num_transforms,
                       features.size(1) / 2,
                       dtype_id_for(features));

    check_launch();
    return output;
}

at::Tensor launch_graph_varlen_static_chunked_fixed(const at::Tensor& features,
                                                    const at::Tensor& flat_indices,
                                                    const at::Tensor& transforms,
                                                    const at::Tensor& work_task,
                                                    const at::Tensor& work_start,
                                                    const at::Tensor& work_count,
                                                    const at::Tensor& work_transform,
                                                    const at::Tensor& work_size,
                                                    int64_t num_tasks)
{
    validate_varlen_work_items(work_task, work_start, work_count, work_transform);
    CHECK_CUDA(work_size);
    CHECK_CONTIGUOUS(work_size);
    CHECK_CUDA(features);
    CHECK_CUDA(flat_indices);
    CHECK_CUDA(transforms);
    CHECK_CONTIGUOUS(features);
    CHECK_CONTIGUOUS(flat_indices);
    CHECK_CONTIGUOUS(transforms);
    TORCH_CHECK(work_size.dim() == 1 && work_size.size(0) == 1,
                "work_size must have shape [1]");
    TORCH_CHECK(work_size.scalar_type() == at::kInt, "work_size must be int32");
    TORCH_CHECK(features.scalar_type() == at::kHalf || features.scalar_type() == at::kBFloat16,
                "features must be fp16 or bf16");
    TORCH_CHECK(flat_indices.scalar_type() == at::kInt, "flat_indices must be int32");
    TORCH_CHECK(transforms.scalar_type() == features.scalar_type(),
                "transforms dtype must match features dtype");
    TORCH_CHECK(features.dim() == 2, "features must have shape [num_rows, dim]");
    TORCH_CHECK(transforms.dim() == 2, "transforms must have shape [num_transforms, dim]");
    TORCH_CHECK(transforms.size(1) == features.size(1),
                "transforms dim must match features dim");
    TORCH_CHECK(features.size(1) % 2 == 0, "dim must be even for DWORD graph kernels");
    TORCH_CHECK(num_tasks > 0, "num_tasks must be positive");
    TORCH_CHECK(work_task.size(0) <= std::numeric_limits<uint32_t>::max(),
                "graph_varlen_static_chunked_fixed grid exceeds uint32 range");

    const int64_t num_transforms = transforms.size(0);
    const int64_t work_capacity = work_task.size(0);
    auto output =
        torch::empty({num_tasks, num_transforms}, features.options().dtype(at::kFloat));

    at::cuda::CUDAGuard device_guard{features.device()};
    auto stream = at::cuda::getCurrentCUDAStream().stream();
    hipError_t err =
        hipMemsetAsync(output.data_ptr<float>(), 0, output.numel() * sizeof(float), stream);
    TORCH_CHECK(err == hipSuccess,
                "hipMemsetAsync(varlen fixed chunked output) failed: ",
                hipGetErrorString(err));

    hipLaunchKernelGGL(graph_varlen_static_chunked_fixed_kernel,
                       dim3(static_cast<uint32_t>(work_capacity)),
                       dim3(kThreads),
                       static_cast<uint32_t>(kThreads * sizeof(float)),
                       stream,
                       reinterpret_cast<const uint32_t*>(features.data_ptr()),
                       reinterpret_cast<const uint32_t*>(transforms.data_ptr()),
                       flat_indices.data_ptr<int>(),
                       work_task.data_ptr<int>(),
                       work_start.data_ptr<int>(),
                       work_count.data_ptr<int>(),
                       work_transform.data_ptr<int>(),
                       work_size.data_ptr<int>(),
                       output.data_ptr<float>(),
                       features.size(0),
                       num_transforms,
                       features.size(1) / 2,
                       work_capacity,
                       dtype_id_for(features));

    check_launch();
    return output;
}

at::Tensor launch_graph_persistent_common(const at::Tensor& features,
                                          const at::Tensor& indices,
                                          const at::Tensor& transforms,
                                          int64_t transform_chunk_size,
                                          int64_t persistent_blocks,
                                          int64_t ticket_batch_size,
                                          const std::string& variant)
{
    validate_transforms(features, indices, transforms);
    const auto meta = make_meta(features, indices);
    const int64_t num_transforms = transforms.size(0);
    const auto reduction_shared_bytes = static_cast<int64_t>(kThreads) * sizeof(float);
    const auto lds_graph_shared_bytes = meta.shared_bytes + reduction_shared_bytes;
    const auto persistent_static_shared_bytes = static_cast<int64_t>(sizeof(int));
    const auto persistent_lds_total_shared_bytes =
        lds_graph_shared_bytes + persistent_static_shared_bytes;

    TORCH_CHECK(ticket_batch_size > 0, "ticket_batch_size must be positive");
    TORCH_CHECK(ticket_batch_size <= std::numeric_limits<int>::max(),
                "ticket_batch_size exceeds int range");

    auto output =
        torch::empty({meta.num_tasks, num_transforms},
                     features.options().dtype(at::kFloat));

    at::cuda::CUDAGuard device_guard{features.device()};
    const auto cuda_stream = at::cuda::getCurrentCUDAStream();
    auto stream = cuda_stream.stream();

    const int64_t launch_blocks =
        persistent_blocks > 0 ? persistent_blocks : default_persistent_block_count();
    TORCH_CHECK(launch_blocks > 0, "persistent_blocks must be positive");
    TORCH_CHECK(launch_blocks <= std::numeric_limits<uint32_t>::max(),
                "persistent_blocks exceeds uint32 launch range");

    const auto ticket_options =
        indices.options().dtype(at::kInt).memory_format(c10::MemoryFormat::Contiguous);
    auto ticket = torch::empty({1}, ticket_options);
    c10::cuda::CUDACachingAllocator::recordStream(ticket.storage().data_ptr(), cuda_stream);
    hipError_t err = hipMemsetAsync(ticket.data_ptr<int>(), 0, sizeof(int), stream);
    TORCH_CHECK(err == hipSuccess, "hipMemsetAsync(ticket) failed: ", hipGetErrorString(err));

    const auto* feature_u32   = reinterpret_cast<const uint32_t*>(features.data_ptr());
    const auto* transform_u32 = reinterpret_cast<const uint32_t*>(transforms.data_ptr());
    const auto* index_i32     = indices.data_ptr<int>();
    auto* output_f32          = output.data_ptr<float>();
    auto* ticket_i32          = ticket.data_ptr<int>();
    const int dtype_id        = dtype_id_for(features);
    GraphVariantKind effective_variant = GraphVariantKind::Global;
    int64_t effective_chunk_size = transform_chunk_size;

    if(variant == "graph_persistent_global")
    {
        effective_variant = GraphVariantKind::Global;
    }
    else if(variant == "graph_persistent_lds")
    {
        effective_variant = GraphVariantKind::Lds;
    }
    else if(variant == "graph_persistent_lds_chunked")
    {
        effective_variant = GraphVariantKind::Chunked;
    }
    else if(variant == "graph_persistent_auto")
    {
        effective_variant = choose_graph_auto_variant(features,
                                                      meta.num_tasks,
                                                      meta.tile_tokens,
                                                      meta.dim,
                                                      num_transforms,
                                                      &effective_chunk_size);
    }
    else
    {
        TORCH_CHECK(false, "unknown persistent graph variant: ", variant);
    }

    if(effective_variant == GraphVariantKind::Global)
    {
        const int64_t total_work = meta.num_tasks * num_transforms;
        TORCH_CHECK(total_work <= std::numeric_limits<int>::max(),
                    "graph_persistent_global total work exceeds int range");
        hipLaunchKernelGGL(graph_persistent_global_kernel,
                           dim3(static_cast<uint32_t>(launch_blocks)),
                           dim3(kThreads),
                           static_cast<uint32_t>(reduction_shared_bytes),
                           stream,
                           feature_u32,
                           transform_u32,
                           index_i32,
                           output_f32,
                           ticket_i32,
                           meta.num_rows,
                           meta.tile_tokens,
                           meta.dim_dwords,
                           meta.tile_dwords,
                           num_transforms,
                           total_work,
                           static_cast<int>(ticket_batch_size),
                           dtype_id);
    }
    else if(effective_variant == GraphVariantKind::Lds)
    {
        TORCH_CHECK(persistent_lds_total_shared_bytes <= 64 * 1024,
                    "Phase 3 persistent graph LDS shared memory exceeds 64 KiB: ",
                    persistent_lds_total_shared_bytes);
        TORCH_CHECK(meta.num_tasks <= std::numeric_limits<int>::max(),
                    "graph_persistent_lds total work exceeds int range");
        hipLaunchKernelGGL(graph_persistent_lds_kernel,
                           dim3(static_cast<uint32_t>(launch_blocks)),
                           dim3(kThreads),
                           static_cast<uint32_t>(lds_graph_shared_bytes),
                           stream,
                           feature_u32,
                           transform_u32,
                           index_i32,
                           output_f32,
                           ticket_i32,
                           meta.num_rows,
                           meta.tile_tokens,
                           meta.dim_dwords,
                           meta.tile_dwords,
                           num_transforms,
                           meta.num_tasks,
                           static_cast<int>(ticket_batch_size),
                           dtype_id);
    }
    else
    {
        TORCH_CHECK(persistent_lds_total_shared_bytes <= 64 * 1024,
                    "Phase 3 persistent graph chunked LDS shared memory exceeds 64 KiB: ",
                    persistent_lds_total_shared_bytes);
        TORCH_CHECK(effective_chunk_size > 0,
                    "transform_chunk_size must be positive for graph_persistent_lds_chunked");
        const int64_t num_transform_chunks =
            (num_transforms + effective_chunk_size - 1) / effective_chunk_size;
        const int64_t total_work = meta.num_tasks * num_transform_chunks;
        TORCH_CHECK(total_work <= std::numeric_limits<int>::max(),
                    "graph_persistent_lds_chunked total work exceeds int range");
        hipLaunchKernelGGL(graph_persistent_lds_chunked_kernel,
                           dim3(static_cast<uint32_t>(launch_blocks)),
                           dim3(kThreads),
                           static_cast<uint32_t>(lds_graph_shared_bytes),
                           stream,
                           feature_u32,
                           transform_u32,
                           index_i32,
                           output_f32,
                           ticket_i32,
                           meta.num_rows,
                           meta.tile_tokens,
                           meta.dim_dwords,
                           meta.tile_dwords,
                           num_transforms,
                           num_transform_chunks,
                           effective_chunk_size,
                           total_work,
                           static_cast<int>(ticket_batch_size),
                           dtype_id);
    }

    check_launch();
    return output;
}

at::Tensor launch_graph_varlen_persistent_node(const at::Tensor& features,
                                               const at::Tensor& offsets,
                                               const at::Tensor& flat_indices,
                                               const at::Tensor& transforms,
                                               const at::Tensor& task_order,
                                               int64_t persistent_blocks,
                                               int64_t ticket_batch_size)
{
    validate_varlen_graph_inputs(features, offsets, flat_indices, transforms, task_order);
    TORCH_CHECK(ticket_batch_size > 0, "ticket_batch_size must be positive");
    TORCH_CHECK(ticket_batch_size <= std::numeric_limits<int>::max(),
                "ticket_batch_size exceeds int range");
    const int64_t num_tasks = offsets.size(0) - 1;
    const int64_t num_transforms = transforms.size(0);
    const int64_t total_work = num_tasks * num_transforms;
    TORCH_CHECK(total_work <= std::numeric_limits<int>::max(),
                "graph_varlen_persistent_node total work exceeds int range");

    auto output =
        torch::empty({num_tasks, num_transforms}, features.options().dtype(at::kFloat));

    at::cuda::CUDAGuard device_guard{features.device()};
    const auto cuda_stream = at::cuda::getCurrentCUDAStream();
    auto stream = cuda_stream.stream();
    const int64_t launch_blocks =
        persistent_blocks > 0 ? persistent_blocks : default_persistent_block_count();
    TORCH_CHECK(launch_blocks > 0, "persistent_blocks must be positive");
    TORCH_CHECK(launch_blocks <= std::numeric_limits<uint32_t>::max(),
                "persistent_blocks exceeds uint32 launch range");

    auto ticket = torch::empty({1}, offsets.options().dtype(at::kInt));
    c10::cuda::CUDACachingAllocator::recordStream(ticket.storage().data_ptr(), cuda_stream);
    hipError_t err = hipMemsetAsync(ticket.data_ptr<int>(), 0, sizeof(int), stream);
    TORCH_CHECK(err == hipSuccess, "hipMemsetAsync(ticket) failed: ", hipGetErrorString(err));

    hipLaunchKernelGGL(graph_varlen_persistent_node_kernel,
                       dim3(static_cast<uint32_t>(launch_blocks)),
                       dim3(kThreads),
                       static_cast<uint32_t>(kThreads * sizeof(float)),
                       stream,
                       reinterpret_cast<const uint32_t*>(features.data_ptr()),
                       reinterpret_cast<const uint32_t*>(transforms.data_ptr()),
                       offsets.data_ptr<int>(),
                       flat_indices.data_ptr<int>(),
                       task_order.data_ptr<int>(),
                       output.data_ptr<float>(),
                       ticket.data_ptr<int>(),
                       features.size(0),
                       num_transforms,
                       features.size(1) / 2,
                       total_work,
                       static_cast<int>(ticket_batch_size),
                       dtype_id_for(features));

    check_launch();
    return output;
}

at::Tensor launch_graph_varlen_persistent_chunked(const at::Tensor& features,
                                                  const at::Tensor& flat_indices,
                                                  const at::Tensor& transforms,
                                                  const at::Tensor& work_task,
                                                  const at::Tensor& work_start,
                                                  const at::Tensor& work_count,
                                                  const at::Tensor& work_transform,
                                                  int64_t num_tasks,
                                                  int64_t persistent_blocks,
                                                  int64_t ticket_batch_size)
{
    validate_varlen_work_items(work_task, work_start, work_count, work_transform);
    TORCH_CHECK(ticket_batch_size > 0, "ticket_batch_size must be positive");
    TORCH_CHECK(ticket_batch_size <= std::numeric_limits<int>::max(),
                "ticket_batch_size exceeds int range");
    CHECK_CUDA(features);
    CHECK_CUDA(flat_indices);
    CHECK_CUDA(transforms);
    CHECK_CONTIGUOUS(features);
    CHECK_CONTIGUOUS(flat_indices);
    CHECK_CONTIGUOUS(transforms);
    TORCH_CHECK(features.scalar_type() == at::kHalf || features.scalar_type() == at::kBFloat16,
                "features must be fp16 or bf16");
    TORCH_CHECK(flat_indices.scalar_type() == at::kInt, "flat_indices must be int32");
    TORCH_CHECK(transforms.scalar_type() == features.scalar_type(),
                "transforms dtype must match features dtype");
    TORCH_CHECK(features.dim() == 2, "features must have shape [num_rows, dim]");
    TORCH_CHECK(transforms.dim() == 2, "transforms must have shape [num_transforms, dim]");
    TORCH_CHECK(transforms.size(1) == features.size(1),
                "transforms dim must match features dim");
    TORCH_CHECK(features.size(1) % 2 == 0, "dim must be even for DWORD graph kernels");
    TORCH_CHECK(num_tasks > 0, "num_tasks must be positive");
    TORCH_CHECK(work_task.size(0) <= std::numeric_limits<int>::max(),
                "graph_varlen_persistent_chunked total work exceeds int range");

    const int64_t num_transforms = transforms.size(0);
    const int64_t total_work = work_task.size(0);
    auto output =
        torch::empty({num_tasks, num_transforms}, features.options().dtype(at::kFloat));

    at::cuda::CUDAGuard device_guard{features.device()};
    const auto cuda_stream = at::cuda::getCurrentCUDAStream();
    auto stream = cuda_stream.stream();
    const int64_t launch_blocks =
        persistent_blocks > 0 ? persistent_blocks : default_persistent_block_count();
    TORCH_CHECK(launch_blocks > 0, "persistent_blocks must be positive");
    TORCH_CHECK(launch_blocks <= std::numeric_limits<uint32_t>::max(),
                "persistent_blocks exceeds uint32 launch range");

    hipError_t err =
        hipMemsetAsync(output.data_ptr<float>(), 0, output.numel() * sizeof(float), stream);
    TORCH_CHECK(err == hipSuccess,
                "hipMemsetAsync(varlen persistent chunked output) failed: ",
                hipGetErrorString(err));

    auto ticket = torch::empty({1}, work_task.options().dtype(at::kInt));
    c10::cuda::CUDACachingAllocator::recordStream(ticket.storage().data_ptr(), cuda_stream);
    err = hipMemsetAsync(ticket.data_ptr<int>(), 0, sizeof(int), stream);
    TORCH_CHECK(err == hipSuccess, "hipMemsetAsync(ticket) failed: ", hipGetErrorString(err));

    hipLaunchKernelGGL(graph_varlen_persistent_chunked_kernel,
                       dim3(static_cast<uint32_t>(launch_blocks)),
                       dim3(kThreads),
                       static_cast<uint32_t>(kThreads * sizeof(float)),
                       stream,
                       reinterpret_cast<const uint32_t*>(features.data_ptr()),
                       reinterpret_cast<const uint32_t*>(transforms.data_ptr()),
                       flat_indices.data_ptr<int>(),
                       work_task.data_ptr<int>(),
                       work_start.data_ptr<int>(),
                       work_count.data_ptr<int>(),
                       work_transform.data_ptr<int>(),
                       output.data_ptr<float>(),
                       ticket.data_ptr<int>(),
                       features.size(0),
                       num_transforms,
                       features.size(1) / 2,
                       total_work,
                       static_cast<int>(ticket_batch_size),
                       dtype_id_for(features));

    check_launch();
    return output;
}

template <typename Fn>
void for_each_replay_launch(const at::Tensor& actual_work_sizes,
                            const at::Tensor& work_capacities,
                            int64_t max_capacity,
                            Fn&& launch_fn)
{
    TORCH_CHECK(!actual_work_sizes.is_cuda(), "actual_work_sizes must be a CPU tensor");
    TORCH_CHECK(!work_capacities.is_cuda(), "work_capacities must be a CPU tensor");
    CHECK_CONTIGUOUS(actual_work_sizes);
    CHECK_CONTIGUOUS(work_capacities);
    TORCH_CHECK(actual_work_sizes.scalar_type() == at::kLong,
                "actual_work_sizes must be int64");
    TORCH_CHECK(work_capacities.scalar_type() == at::kLong,
                "work_capacities must be int64");
    TORCH_CHECK(actual_work_sizes.dim() == 1, "actual_work_sizes must be 1D");
    TORCH_CHECK(work_capacities.dim() == 1, "work_capacities must be 1D");
    TORCH_CHECK(actual_work_sizes.size(0) == work_capacities.size(0),
                "actual_work_sizes and work_capacities length mismatch");
    TORCH_CHECK(max_capacity > 0, "max_capacity must be positive");
    TORCH_CHECK(max_capacity <= std::numeric_limits<uint32_t>::max(),
                "max_capacity exceeds uint32 launch range");

    const auto* actual_ptr = actual_work_sizes.data_ptr<int64_t>();
    const auto* capacity_ptr = work_capacities.data_ptr<int64_t>();
    const int64_t traces = actual_work_sizes.size(0);
    for(int64_t trace = 0; trace < traces; ++trace)
    {
        const int64_t actual = actual_ptr[trace];
        const int64_t capacity = capacity_ptr[trace];
        TORCH_CHECK(capacity > 0, "work capacity must be positive");
        TORCH_CHECK(capacity <= max_capacity,
                    "work capacity exceeds max_capacity at trace ",
                    trace);
        TORCH_CHECK(capacity <= std::numeric_limits<uint32_t>::max(),
                    "work capacity exceeds uint32 launch range");
        launch_fn(static_cast<int>(actual), static_cast<int>(capacity));
    }
}

at::Tensor launch_replay_self_cull_many(const at::Tensor& device_anchor,
                                        const at::Tensor& actual_work_sizes,
                                        const at::Tensor& work_capacities,
                                        int64_t max_capacity,
                                        int64_t work_iters)
{
    CHECK_CUDA(device_anchor);
    TORCH_CHECK(work_iters >= 0, "work_iters must be non-negative");
    TORCH_CHECK(work_iters <= std::numeric_limits<int>::max(), "work_iters exceeds int range");

    at::cuda::CUDAGuard device_guard{device_anchor.device()};
    auto stream = at::cuda::getCurrentCUDAStream().stream();
    const auto cuda_stream = at::cuda::getCurrentCUDAStream();
    auto sink = torch::empty({max_capacity}, device_anchor.options().dtype(at::kFloat));
    c10::cuda::CUDACachingAllocator::recordStream(sink.storage().data_ptr(), cuda_stream);

    for_each_replay_launch(
        actual_work_sizes,
        work_capacities,
        max_capacity,
        [&](int actual, int capacity) {
            hipLaunchKernelGGL(replay_self_cull_kernel,
                               dim3(static_cast<uint32_t>(capacity)),
                               dim3(kThreads),
                               0,
                               stream,
                               sink.data_ptr<float>(),
                               actual,
                               capacity,
                               static_cast<int>(work_iters));
        });
    check_launch();
    return sink;
}

at::Tensor launch_replay_gather_dot_many(const at::Tensor& features,
                                         const at::Tensor& transforms,
                                         const at::Tensor& actual_work_sizes,
                                         const at::Tensor& work_capacities,
                                         int64_t max_capacity,
                                         int64_t chunk_tokens)
{
    CHECK_CUDA(features);
    CHECK_CUDA(transforms);
    CHECK_CONTIGUOUS(features);
    CHECK_CONTIGUOUS(transforms);
    TORCH_CHECK(features.scalar_type() == at::kHalf || features.scalar_type() == at::kBFloat16,
                "features must be fp16 or bf16");
    TORCH_CHECK(transforms.scalar_type() == features.scalar_type(),
                "transforms dtype must match features dtype");
    TORCH_CHECK(features.dim() == 2, "features must have shape [num_rows, dim]");
    TORCH_CHECK(transforms.dim() == 2, "transforms must have shape [num_transforms, dim]");
    TORCH_CHECK(transforms.size(1) == features.size(1),
                "transforms dim must match features dim");
    TORCH_CHECK(features.size(1) % 2 == 0, "dim must be even for replay_gather_dot");
    TORCH_CHECK(chunk_tokens > 0, "chunk_tokens must be positive");
    TORCH_CHECK(chunk_tokens <= features.size(0), "chunk_tokens exceeds feature rows");

    at::cuda::CUDAGuard device_guard{features.device()};
    const auto cuda_stream = at::cuda::getCurrentCUDAStream();
    auto stream = cuda_stream.stream();
    auto sink = torch::empty({max_capacity}, features.options().dtype(at::kFloat));
    c10::cuda::CUDACachingAllocator::recordStream(sink.storage().data_ptr(), cuda_stream);

    const auto* feature_u32 = reinterpret_cast<const uint32_t*>(features.data_ptr());
    const auto* transform_u32 = reinterpret_cast<const uint32_t*>(transforms.data_ptr());
    const int dtype_id = dtype_id_for(features);
    const int64_t num_rows = features.size(0);
    const int64_t num_transforms = transforms.size(0);
    const int64_t dim_dwords = features.size(1) / 2;

    for_each_replay_launch(
        actual_work_sizes,
        work_capacities,
        max_capacity,
        [&](int actual, int capacity) {
            hipLaunchKernelGGL(replay_gather_dot_kernel,
                               dim3(static_cast<uint32_t>(capacity)),
                               dim3(kThreads),
                               static_cast<uint32_t>(kThreads * sizeof(float)),
                               stream,
                               sink.data_ptr<float>(),
                               feature_u32,
                               transform_u32,
                               actual,
                               capacity,
                               num_rows,
                               num_transforms,
                               dim_dwords,
                               chunk_tokens,
                               dtype_id);
        });
    check_launch();
    return sink;
}


void validate_replay_actuals_cuda(const at::Tensor& actual_work_sizes)
{
    CHECK_CUDA(actual_work_sizes);
    CHECK_CONTIGUOUS(actual_work_sizes);
    TORCH_CHECK(actual_work_sizes.scalar_type() == at::kInt,
                "actual_work_sizes must be int32 for fused replay");
    TORCH_CHECK(actual_work_sizes.dim() == 1, "actual_work_sizes must be 1D");
    TORCH_CHECK(actual_work_sizes.size(0) > 0, "actual_work_sizes must not be empty");
    TORCH_CHECK(actual_work_sizes.size(0) <= std::numeric_limits<uint32_t>::max(),
                "too many fused replay traces");
}

at::Tensor launch_replay_self_cull_fused(const at::Tensor& device_anchor,
                                         const at::Tensor& actual_work_sizes,
                                         int64_t work_capacity,
                                         int64_t work_iters)
{
    CHECK_CUDA(device_anchor);
    validate_replay_actuals_cuda(actual_work_sizes);
    TORCH_CHECK(work_capacity > 0, "work_capacity must be positive");
    TORCH_CHECK(work_capacity <= std::numeric_limits<uint32_t>::max(),
                "work_capacity exceeds uint32 launch range");
    TORCH_CHECK(work_iters >= 0, "work_iters must be non-negative");
    TORCH_CHECK(work_iters <= std::numeric_limits<int>::max(), "work_iters exceeds int range");

    at::cuda::CUDAGuard device_guard{actual_work_sizes.device()};
    const auto cuda_stream = at::cuda::getCurrentCUDAStream();
    auto stream = cuda_stream.stream();
    const int64_t num_traces = actual_work_sizes.size(0);
    const int64_t total_capacity = num_traces * work_capacity;
    TORCH_CHECK(total_capacity <= std::numeric_limits<int64_t>::max() / 2,
                "fused replay capacity overflow");

    auto sink = torch::empty({total_capacity}, device_anchor.options().dtype(at::kFloat));
    c10::cuda::CUDACachingAllocator::recordStream(sink.storage().data_ptr(), cuda_stream);

    hipLaunchKernelGGL(replay_self_cull_fused_kernel,
                       dim3(static_cast<uint32_t>(work_capacity),
                            static_cast<uint32_t>(num_traces)),
                       dim3(kThreads),
                       0,
                       stream,
                       sink.data_ptr<float>(),
                       actual_work_sizes.data_ptr<int>(),
                       static_cast<int>(work_capacity),
                       static_cast<int>(num_traces),
                       static_cast<int>(work_iters));

    check_launch();
    return sink;
}

at::Tensor launch_replay_gather_dot_fused(const at::Tensor& features,
                                          const at::Tensor& transforms,
                                          const at::Tensor& actual_work_sizes,
                                          int64_t work_capacity,
                                          int64_t chunk_tokens)
{
    CHECK_CUDA(features);
    CHECK_CUDA(transforms);
    CHECK_CONTIGUOUS(features);
    CHECK_CONTIGUOUS(transforms);
    validate_replay_actuals_cuda(actual_work_sizes);
    TORCH_CHECK(features.scalar_type() == at::kHalf || features.scalar_type() == at::kBFloat16,
                "features must be fp16 or bf16");
    TORCH_CHECK(transforms.scalar_type() == features.scalar_type(),
                "transforms dtype must match features dtype");
    TORCH_CHECK(features.dim() == 2, "features must have shape [num_rows, dim]");
    TORCH_CHECK(transforms.dim() == 2, "transforms must have shape [num_transforms, dim]");
    TORCH_CHECK(transforms.size(1) == features.size(1),
                "transforms dim must match features dim");
    TORCH_CHECK(features.size(1) % 2 == 0, "dim must be even for replay_gather_dot_fused");
    TORCH_CHECK(chunk_tokens > 0, "chunk_tokens must be positive");
    TORCH_CHECK(chunk_tokens <= features.size(0), "chunk_tokens exceeds feature rows");
    TORCH_CHECK(work_capacity > 0, "work_capacity must be positive");
    TORCH_CHECK(work_capacity <= std::numeric_limits<uint32_t>::max(),
                "work_capacity exceeds uint32 launch range");

    at::cuda::CUDAGuard device_guard{features.device()};
    const auto cuda_stream = at::cuda::getCurrentCUDAStream();
    auto stream = cuda_stream.stream();
    const int64_t num_traces = actual_work_sizes.size(0);
    const int64_t total_capacity = num_traces * work_capacity;

    auto sink = torch::empty({total_capacity}, features.options().dtype(at::kFloat));
    c10::cuda::CUDACachingAllocator::recordStream(sink.storage().data_ptr(), cuda_stream);

    hipLaunchKernelGGL(replay_gather_dot_fused_kernel,
                       dim3(static_cast<uint32_t>(work_capacity),
                            static_cast<uint32_t>(num_traces)),
                       dim3(kThreads),
                       static_cast<uint32_t>(kThreads * sizeof(float)),
                       stream,
                       sink.data_ptr<float>(),
                       reinterpret_cast<const uint32_t*>(features.data_ptr()),
                       reinterpret_cast<const uint32_t*>(transforms.data_ptr()),
                       actual_work_sizes.data_ptr<int>(),
                       static_cast<int>(work_capacity),
                       static_cast<int>(num_traces),
                       features.size(0),
                       transforms.size(0),
                       features.size(1) / 2,
                       chunk_tokens,
                       dtype_id_for(features));

    check_launch();
    return sink;
}


at::Tensor launch_replay_paged_kv_dot_fused(const at::Tensor& kv_pool,
                                            const at::Tensor& transforms,
                                            const at::Tensor& actual_work_sizes,
                                            const at::Tensor& row_indices,
                                            const at::Tensor& cache_seqlens,
                                            const at::Tensor& block_tables,
                                            int64_t work_capacity,
                                            int64_t chunk_tokens)
{
    CHECK_CUDA(kv_pool);
    CHECK_CUDA(transforms);
    CHECK_CUDA(row_indices);
    CHECK_CUDA(cache_seqlens);
    CHECK_CUDA(block_tables);
    CHECK_CONTIGUOUS(kv_pool);
    CHECK_CONTIGUOUS(transforms);
    CHECK_CONTIGUOUS(row_indices);
    CHECK_CONTIGUOUS(cache_seqlens);
    CHECK_CONTIGUOUS(block_tables);
    validate_replay_actuals_cuda(actual_work_sizes);
    TORCH_CHECK(row_indices.scalar_type() == at::kInt, "row_indices must be int32");
    TORCH_CHECK(cache_seqlens.scalar_type() == at::kInt, "cache_seqlens must be int32");
    TORCH_CHECK(block_tables.scalar_type() == at::kInt, "block_tables must be int32");
    TORCH_CHECK(row_indices.dim() == 1, "row_indices must be 1D");
    TORCH_CHECK(row_indices.size(0) == actual_work_sizes.size(0),
                "row_indices and actual_work_sizes length mismatch");
    TORCH_CHECK(cache_seqlens.dim() == 1, "cache_seqlens must be 1D");
    TORCH_CHECK(block_tables.dim() == 2, "block_tables must have shape [rows, max_pages]");
    TORCH_CHECK(block_tables.size(0) == cache_seqlens.size(0),
                "block_tables rows must match cache_seqlens");
    TORCH_CHECK(kv_pool.scalar_type() == at::kHalf || kv_pool.scalar_type() == at::kBFloat16,
                "kv_pool must be fp16 or bf16");
    TORCH_CHECK(transforms.scalar_type() == kv_pool.scalar_type(),
                "transforms dtype must match kv_pool dtype");
    TORCH_CHECK(kv_pool.dim() == 4,
                "kv_pool must have shape [num_pages, num_kv_heads, page_block_size, dim]");
    TORCH_CHECK(transforms.dim() == 2, "transforms must have shape [num_work_heads, dim]");
    TORCH_CHECK(kv_pool.size(3) == transforms.size(1), "transform dim must match kv dim");
    TORCH_CHECK(kv_pool.size(3) % 2 == 0, "dim must be even for replay_paged_kv_dot_fused");
    TORCH_CHECK(work_capacity > 0, "work_capacity must be positive");
    TORCH_CHECK(work_capacity <= std::numeric_limits<uint32_t>::max(),
                "work_capacity exceeds uint32 launch range");
    TORCH_CHECK(chunk_tokens > 0, "chunk_tokens must be positive");

    at::cuda::CUDAGuard device_guard{kv_pool.device()};
    const auto cuda_stream = at::cuda::getCurrentCUDAStream();
    auto stream = cuda_stream.stream();
    const int64_t num_group_rows = actual_work_sizes.size(0);
    const int64_t total_capacity = num_group_rows * work_capacity;

    auto sink = torch::empty({total_capacity}, kv_pool.options().dtype(at::kFloat));
    c10::cuda::CUDACachingAllocator::recordStream(sink.storage().data_ptr(), cuda_stream);

    hipLaunchKernelGGL(replay_paged_kv_dot_fused_kernel,
                       dim3(static_cast<uint32_t>(work_capacity),
                            static_cast<uint32_t>(num_group_rows)),
                       dim3(kThreads),
                       static_cast<uint32_t>(kThreads * sizeof(float)),
                       stream,
                       sink.data_ptr<float>(),
                       reinterpret_cast<const uint32_t*>(kv_pool.data_ptr()),
                       reinterpret_cast<const uint32_t*>(transforms.data_ptr()),
                       actual_work_sizes.data_ptr<int>(),
                       row_indices.data_ptr<int>(),
                       cache_seqlens.data_ptr<int>(),
                       block_tables.data_ptr<int>(),
                       static_cast<int>(work_capacity),
                       static_cast<int>(num_group_rows),
                       kv_pool.size(0),
                       kv_pool.size(1),
                       transforms.size(0),
                       kv_pool.size(2),
                       block_tables.size(1),
                       kv_pool.size(3) / 2,
                       chunk_tokens,
                       dtype_id_for(kv_pool));

    check_launch();
    return sink;
}


at::Tensor launch_replay_paged_kv_attn_fused(const at::Tensor& k_pool,
                                             const at::Tensor& v_pool,
                                             const at::Tensor& q_transforms,
                                             const at::Tensor& v_transforms,
                                             const at::Tensor& actual_work_sizes,
                                             const at::Tensor& row_indices,
                                             const at::Tensor& cache_seqlens,
                                             const at::Tensor& block_tables,
                                             int64_t work_capacity,
                                             int64_t chunk_tokens)
{
    CHECK_CUDA(k_pool);
    CHECK_CUDA(v_pool);
    CHECK_CUDA(q_transforms);
    CHECK_CUDA(v_transforms);
    CHECK_CUDA(row_indices);
    CHECK_CUDA(cache_seqlens);
    CHECK_CUDA(block_tables);
    CHECK_CONTIGUOUS(k_pool);
    CHECK_CONTIGUOUS(v_pool);
    CHECK_CONTIGUOUS(q_transforms);
    CHECK_CONTIGUOUS(v_transforms);
    CHECK_CONTIGUOUS(row_indices);
    CHECK_CONTIGUOUS(cache_seqlens);
    CHECK_CONTIGUOUS(block_tables);
    validate_replay_actuals_cuda(actual_work_sizes);
    TORCH_CHECK(row_indices.scalar_type() == at::kInt, "row_indices must be int32");
    TORCH_CHECK(cache_seqlens.scalar_type() == at::kInt, "cache_seqlens must be int32");
    TORCH_CHECK(block_tables.scalar_type() == at::kInt, "block_tables must be int32");
    TORCH_CHECK(row_indices.dim() == 1, "row_indices must be 1D");
    TORCH_CHECK(row_indices.size(0) == actual_work_sizes.size(0),
                "row_indices and actual_work_sizes length mismatch");
    TORCH_CHECK(cache_seqlens.dim() == 1, "cache_seqlens must be 1D");
    TORCH_CHECK(block_tables.dim() == 2, "block_tables must have shape [rows, max_pages]");
    TORCH_CHECK(k_pool.scalar_type() == at::kHalf || k_pool.scalar_type() == at::kBFloat16,
                "k_pool must be fp16 or bf16");
    TORCH_CHECK(v_pool.scalar_type() == k_pool.scalar_type(), "v_pool dtype must match k_pool");
    TORCH_CHECK(q_transforms.scalar_type() == k_pool.scalar_type(),
                "q_transforms dtype must match k_pool");
    TORCH_CHECK(v_transforms.scalar_type() == k_pool.scalar_type(),
                "v_transforms dtype must match k_pool");
    TORCH_CHECK(k_pool.dim() == 4,
                "k_pool must have shape [num_pages, num_kv_heads, page_block_size, dim]");
    TORCH_CHECK(v_pool.sizes() == k_pool.sizes(), "v_pool shape must match k_pool");
    TORCH_CHECK(q_transforms.dim() == 2, "q_transforms must have shape [num_work_heads, dim]");
    TORCH_CHECK(v_transforms.sizes() == q_transforms.sizes(),
                "v_transforms shape must match q_transforms");
    TORCH_CHECK(k_pool.size(3) == q_transforms.size(1), "transform dim must match kv dim");
    TORCH_CHECK(k_pool.size(3) % 2 == 0, "dim must be even for replay_paged_kv_attn_fused");
    TORCH_CHECK(work_capacity > 0, "work_capacity must be positive");
    TORCH_CHECK(work_capacity <= std::numeric_limits<uint32_t>::max(),
                "work_capacity exceeds uint32 launch range");
    TORCH_CHECK(chunk_tokens > 0, "chunk_tokens must be positive");

    at::cuda::CUDAGuard device_guard{k_pool.device()};
    const auto cuda_stream = at::cuda::getCurrentCUDAStream();
    auto stream = cuda_stream.stream();
    const int64_t num_group_rows = actual_work_sizes.size(0);
    const int64_t total_capacity = num_group_rows * work_capacity;

    auto sink = torch::empty({total_capacity}, k_pool.options().dtype(at::kFloat));
    c10::cuda::CUDACachingAllocator::recordStream(sink.storage().data_ptr(), cuda_stream);

    hipLaunchKernelGGL(replay_paged_kv_attn_fused_kernel,
                       dim3(static_cast<uint32_t>(work_capacity),
                            static_cast<uint32_t>(num_group_rows)),
                       dim3(kThreads),
                       static_cast<uint32_t>(kThreads * sizeof(float) * 3),
                       stream,
                       sink.data_ptr<float>(),
                       reinterpret_cast<const uint32_t*>(k_pool.data_ptr()),
                       reinterpret_cast<const uint32_t*>(v_pool.data_ptr()),
                       reinterpret_cast<const uint32_t*>(q_transforms.data_ptr()),
                       reinterpret_cast<const uint32_t*>(v_transforms.data_ptr()),
                       actual_work_sizes.data_ptr<int>(),
                       row_indices.data_ptr<int>(),
                       cache_seqlens.data_ptr<int>(),
                       block_tables.data_ptr<int>(),
                       static_cast<int>(work_capacity),
                       static_cast<int>(num_group_rows),
                       k_pool.size(0),
                       k_pool.size(1),
                       q_transforms.size(0),
                       k_pool.size(2),
                       block_tables.size(1),
                       k_pool.size(3) / 2,
                       chunk_tokens,
                       dtype_id_for(k_pool));

    check_launch();
    return sink;
}

void launch_replay_paged_kv_chunk_workspace(const at::Tensor& k_pool,
                                            const at::Tensor& v_pool,
                                            const at::Tensor& q_transforms,
                                            const at::Tensor& actual_work_sizes,
                                            const at::Tensor& row_indices,
                                            const at::Tensor& cache_seqlens,
                                            const at::Tensor& block_tables,
                                            const at::Tensor& chunk_m,
                                            const at::Tensor& chunk_l,
                                            const at::Tensor& chunk_acc,
                                            int64_t work_capacity,
                                            int64_t chunk_tokens)
{
    CHECK_CUDA(k_pool);
    CHECK_CUDA(v_pool);
    CHECK_CUDA(q_transforms);
    CHECK_CUDA(row_indices);
    CHECK_CUDA(cache_seqlens);
    CHECK_CUDA(block_tables);
    CHECK_CUDA(chunk_m);
    CHECK_CUDA(chunk_l);
    CHECK_CUDA(chunk_acc);
    CHECK_CONTIGUOUS(k_pool);
    CHECK_CONTIGUOUS(v_pool);
    CHECK_CONTIGUOUS(q_transforms);
    CHECK_CONTIGUOUS(row_indices);
    CHECK_CONTIGUOUS(cache_seqlens);
    CHECK_CONTIGUOUS(block_tables);
    CHECK_CONTIGUOUS(chunk_m);
    CHECK_CONTIGUOUS(chunk_l);
    CHECK_CONTIGUOUS(chunk_acc);
    validate_replay_actuals_cuda(actual_work_sizes);
    TORCH_CHECK(row_indices.scalar_type() == at::kInt, "row_indices must be int32");
    TORCH_CHECK(cache_seqlens.scalar_type() == at::kInt, "cache_seqlens must be int32");
    TORCH_CHECK(block_tables.scalar_type() == at::kInt, "block_tables must be int32");
    TORCH_CHECK(chunk_m.scalar_type() == at::kFloat, "chunk_m must be float32");
    TORCH_CHECK(chunk_l.scalar_type() == at::kFloat, "chunk_l must be float32");
    TORCH_CHECK(chunk_acc.scalar_type() == at::kFloat, "chunk_acc must be float32");
    TORCH_CHECK(row_indices.dim() == 1, "row_indices must be 1D");
    TORCH_CHECK(row_indices.size(0) == actual_work_sizes.size(0),
                "row_indices and actual_work_sizes length mismatch");
    TORCH_CHECK(cache_seqlens.dim() == 1, "cache_seqlens must be 1D");
    TORCH_CHECK(block_tables.dim() == 2, "block_tables must have shape [rows, max_pages]");
    TORCH_CHECK(block_tables.size(0) == cache_seqlens.size(0),
                "block_tables rows must match cache_seqlens");
    TORCH_CHECK(k_pool.scalar_type() == at::kHalf || k_pool.scalar_type() == at::kBFloat16,
                "k_pool must be fp16 or bf16");
    TORCH_CHECK(v_pool.scalar_type() == k_pool.scalar_type(), "v_pool dtype must match k_pool");
    TORCH_CHECK(q_transforms.scalar_type() == k_pool.scalar_type(),
                "q_transforms dtype must match k_pool");
    TORCH_CHECK(k_pool.dim() == 4,
                "k_pool must have shape [num_pages, num_kv_heads, page_block_size, dim]");
    TORCH_CHECK(v_pool.sizes() == k_pool.sizes(), "v_pool shape must match k_pool");
    TORCH_CHECK(q_transforms.dim() == 2, "q_transforms must have shape [num_work_heads, dim]");
    TORCH_CHECK(k_pool.size(3) == q_transforms.size(1), "q dim must match kv dim");
    TORCH_CHECK(k_pool.size(3) % 2 == 0, "dim must be even for chunk workspace kernel");
    TORCH_CHECK(chunk_m.dim() == 3, "chunk_m must have shape [rows, work_heads, max_chunks]");
    TORCH_CHECK(chunk_l.sizes() == chunk_m.sizes(), "chunk_l shape must match chunk_m");
    TORCH_CHECK(chunk_acc.dim() == 4,
                "chunk_acc must have shape [rows, work_heads, max_chunks, value_dim]");
    TORCH_CHECK(chunk_acc.size(0) == chunk_m.size(0) &&
                    chunk_acc.size(1) == chunk_m.size(1) &&
                    chunk_acc.size(2) == chunk_m.size(2),
                "chunk_acc leading shape must match chunk_m");
    TORCH_CHECK(chunk_m.size(0) == cache_seqlens.size(0), "workspace rows mismatch");
    TORCH_CHECK(chunk_m.size(1) == q_transforms.size(0), "workspace work_heads mismatch");
    TORCH_CHECK(chunk_acc.size(3) > 0, "value_dim must be positive");
    TORCH_CHECK(chunk_acc.size(3) <= k_pool.size(3), "value_dim exceeds kv dim");
    TORCH_CHECK(work_capacity > 0, "work_capacity must be positive");
    TORCH_CHECK(work_capacity <= std::numeric_limits<uint32_t>::max(),
                "work_capacity exceeds uint32 launch range");
    TORCH_CHECK(chunk_tokens > 0, "chunk_tokens must be positive");
    TORCH_CHECK(chunk_tokens <= 1024, "chunk_tokens is unexpectedly large for shared weights");

    at::cuda::CUDAGuard device_guard{k_pool.device()};
    auto stream = at::cuda::getCurrentCUDAStream().stream();
    const int64_t num_group_rows = actual_work_sizes.size(0);
    const auto shared_bytes = static_cast<int64_t>(sizeof(float)) *
                              (static_cast<int64_t>(kThreads) * 2 + chunk_tokens);
    TORCH_CHECK(shared_bytes <= 64 * 1024,
                "chunk softmax shared memory exceeds 64 KiB: ",
                shared_bytes);

    hipLaunchKernelGGL(replay_paged_kv_chunk_softmax_kernel,
                       dim3(static_cast<uint32_t>(work_capacity),
                            static_cast<uint32_t>(num_group_rows)),
                       dim3(kThreads),
                       static_cast<uint32_t>(shared_bytes),
                       stream,
                       chunk_m.data_ptr<float>(),
                       chunk_l.data_ptr<float>(),
                       chunk_acc.data_ptr<float>(),
                       reinterpret_cast<const uint32_t*>(k_pool.data_ptr()),
                       reinterpret_cast<const uint32_t*>(v_pool.data_ptr()),
                       reinterpret_cast<const uint32_t*>(q_transforms.data_ptr()),
                       actual_work_sizes.data_ptr<int>(),
                       row_indices.data_ptr<int>(),
                       cache_seqlens.data_ptr<int>(),
                       block_tables.data_ptr<int>(),
                       static_cast<int>(work_capacity),
                       static_cast<int>(num_group_rows),
                       k_pool.size(0),
                       k_pool.size(1),
                       q_transforms.size(0),
                       k_pool.size(2),
                       block_tables.size(1),
                       k_pool.size(3) / 2,
                       chunk_tokens,
                       chunk_m.size(2),
                       chunk_acc.size(3),
                       dtype_id_for(k_pool));
    check_launch();
}

void launch_replay_paged_kv_reduce_workspace(const at::Tensor& chunk_m,
                                             const at::Tensor& chunk_l,
                                             const at::Tensor& chunk_acc,
                                             const at::Tensor& cache_seqlens,
                                             const at::Tensor& output,
                                             int64_t chunk_tokens)
{
    CHECK_CUDA(chunk_m);
    CHECK_CUDA(chunk_l);
    CHECK_CUDA(chunk_acc);
    CHECK_CUDA(cache_seqlens);
    CHECK_CUDA(output);
    CHECK_CONTIGUOUS(chunk_m);
    CHECK_CONTIGUOUS(chunk_l);
    CHECK_CONTIGUOUS(chunk_acc);
    CHECK_CONTIGUOUS(cache_seqlens);
    CHECK_CONTIGUOUS(output);
    TORCH_CHECK(chunk_m.scalar_type() == at::kFloat, "chunk_m must be float32");
    TORCH_CHECK(chunk_l.scalar_type() == at::kFloat, "chunk_l must be float32");
    TORCH_CHECK(chunk_acc.scalar_type() == at::kFloat, "chunk_acc must be float32");
    TORCH_CHECK(output.scalar_type() == at::kFloat, "output must be float32");
    TORCH_CHECK(cache_seqlens.scalar_type() == at::kInt, "cache_seqlens must be int32");
    TORCH_CHECK(chunk_m.dim() == 3, "chunk_m must have shape [rows, work_heads, max_chunks]");
    TORCH_CHECK(chunk_l.sizes() == chunk_m.sizes(), "chunk_l shape must match chunk_m");
    TORCH_CHECK(chunk_acc.dim() == 4,
                "chunk_acc must have shape [rows, work_heads, max_chunks, value_dim]");
    TORCH_CHECK(chunk_acc.size(0) == chunk_m.size(0) &&
                    chunk_acc.size(1) == chunk_m.size(1) &&
                    chunk_acc.size(2) == chunk_m.size(2),
                "chunk_acc leading shape must match chunk_m");
    TORCH_CHECK(output.dim() == 3, "output must have shape [rows, work_heads, value_dim]");
    TORCH_CHECK(output.size(0) == chunk_m.size(0) &&
                    output.size(1) == chunk_m.size(1) &&
                    output.size(2) == chunk_acc.size(3),
                "output shape must match workspace rows/work_heads/value_dim");
    TORCH_CHECK(cache_seqlens.dim() == 1 && cache_seqlens.size(0) == chunk_m.size(0),
                "cache_seqlens shape mismatch");
    TORCH_CHECK(chunk_tokens > 0, "chunk_tokens must be positive");
    TORCH_CHECK(chunk_m.size(0) * chunk_m.size(1) <= std::numeric_limits<uint32_t>::max(),
                "reduce grid exceeds uint32 range");

    at::cuda::CUDAGuard device_guard{chunk_m.device()};
    auto stream = at::cuda::getCurrentCUDAStream().stream();

    hipLaunchKernelGGL(replay_paged_kv_chunk_reduce_kernel,
                       dim3(static_cast<uint32_t>(chunk_m.size(0) * chunk_m.size(1))),
                       dim3(kThreads),
                       static_cast<uint32_t>(kThreads * sizeof(float)),
                       stream,
                       output.data_ptr<float>(),
                       chunk_m.data_ptr<float>(),
                       chunk_l.data_ptr<float>(),
                       chunk_acc.data_ptr<float>(),
                       cache_seqlens.data_ptr<int>(),
                       chunk_m.size(0),
                       chunk_m.size(1),
                       chunk_m.size(2),
                       chunk_acc.size(3),
                       chunk_tokens);
    check_launch();
}

void launch_replay_paged_kv_reduce_ml_workspace(const at::Tensor& chunk_m,
                                                const at::Tensor& chunk_l,
                                                const at::Tensor& cache_seqlens,
                                                const at::Tensor& output,
                                                int64_t chunk_tokens)
{
    CHECK_CUDA(chunk_m);
    CHECK_CUDA(chunk_l);
    CHECK_CUDA(cache_seqlens);
    CHECK_CUDA(output);
    CHECK_CONTIGUOUS(chunk_m);
    CHECK_CONTIGUOUS(chunk_l);
    CHECK_CONTIGUOUS(cache_seqlens);
    CHECK_CONTIGUOUS(output);
    TORCH_CHECK(chunk_m.scalar_type() == at::kFloat, "chunk_m must be float32");
    TORCH_CHECK(chunk_l.scalar_type() == at::kFloat, "chunk_l must be float32");
    TORCH_CHECK(output.scalar_type() == at::kFloat, "output must be float32");
    TORCH_CHECK(cache_seqlens.scalar_type() == at::kInt, "cache_seqlens must be int32");
    TORCH_CHECK(chunk_m.dim() == 3, "chunk_m must have shape [rows, work_heads, max_chunks]");
    TORCH_CHECK(chunk_l.sizes() == chunk_m.sizes(), "chunk_l shape must match chunk_m");
    TORCH_CHECK(output.dim() == 3, "output must have shape [rows, work_heads, 2]");
    TORCH_CHECK(output.size(0) == chunk_m.size(0) &&
                    output.size(1) == chunk_m.size(1) &&
                    output.size(2) == 2,
                "output shape must be [rows, work_heads, 2]");
    TORCH_CHECK(cache_seqlens.dim() == 1 && cache_seqlens.size(0) == chunk_m.size(0),
                "cache_seqlens shape mismatch");
    TORCH_CHECK(chunk_tokens > 0, "chunk_tokens must be positive");
    TORCH_CHECK(chunk_m.size(0) * chunk_m.size(1) <= std::numeric_limits<uint32_t>::max(),
                "reduce ml grid exceeds uint32 range");

    at::cuda::CUDAGuard device_guard{chunk_m.device()};
    auto stream = at::cuda::getCurrentCUDAStream().stream();

    hipLaunchKernelGGL(replay_paged_kv_chunk_reduce_ml_kernel,
                       dim3(static_cast<uint32_t>(chunk_m.size(0) * chunk_m.size(1))),
                       dim3(kThreads),
                       static_cast<uint32_t>(kThreads * sizeof(float)),
                       stream,
                       output.data_ptr<float>(),
                       chunk_m.data_ptr<float>(),
                       chunk_l.data_ptr<float>(),
                       cache_seqlens.data_ptr<int>(),
                       chunk_m.size(0),
                       chunk_m.size(1),
                       chunk_m.size(2),
                       chunk_tokens);
    check_launch();
}

} // namespace

at::Tensor gather_baseline(const at::Tensor& features, const at::Tensor& indices)
{
    return launch_common(features, indices, "baseline");
}

at::Tensor gather_vgpr_lds(const at::Tensor& features, const at::Tensor& indices)
{
    return launch_common(features, indices, "vgpr_lds");
}

at::Tensor gather_direct_lds(const at::Tensor& features, const at::Tensor& indices)
{
    return launch_common(features, indices, "direct_lds");
}

at::Tensor fused_global_sum(const at::Tensor& features,
                            const at::Tensor& indices,
                            int64_t consumer_passes)
{
    return launch_fused_common(features, indices, consumer_passes, "fused_global");
}

at::Tensor fused_lds_sum(const at::Tensor& features,
                         const at::Tensor& indices,
                         int64_t consumer_passes)
{
    return launch_fused_common(features, indices, consumer_passes, "fused_lds");
}

at::Tensor dot_global(const at::Tensor& features,
                      const at::Tensor& indices,
                      const at::Tensor& queries)
{
    return launch_dot_common(features, indices, queries, "dot_global");
}

at::Tensor dot_lds(const at::Tensor& features,
                   const at::Tensor& indices,
                   const at::Tensor& queries)
{
    return launch_dot_common(features, indices, queries, "dot_lds");
}

at::Tensor graph_global(const at::Tensor& features,
                        const at::Tensor& indices,
                        const at::Tensor& transforms)
{
    return launch_graph_common(features, indices, transforms, 0, "graph_global");
}

at::Tensor graph_lds(const at::Tensor& features,
                     const at::Tensor& indices,
                     const at::Tensor& transforms)
{
    return launch_graph_common(features, indices, transforms, 0, "graph_lds");
}

at::Tensor graph_lds_chunked(const at::Tensor& features,
                             const at::Tensor& indices,
                             const at::Tensor& transforms,
                             int64_t transform_chunk_size)
{
    return launch_graph_common(features,
                               indices,
                               transforms,
                               transform_chunk_size,
                               "graph_lds_chunked");
}

at::Tensor graph_auto(const at::Tensor& features,
                      const at::Tensor& indices,
                      const at::Tensor& transforms)
{
    return launch_graph_common(features, indices, transforms, 0, "graph_auto");
}

at::Tensor graph_persistent_global(const at::Tensor& features,
                                   const at::Tensor& indices,
                                   const at::Tensor& transforms,
                                   int64_t persistent_blocks,
                                   int64_t ticket_batch_size)
{
    return launch_graph_persistent_common(features,
                                          indices,
                                          transforms,
                                          0,
                                          persistent_blocks,
                                          ticket_batch_size,
                                          "graph_persistent_global");
}

at::Tensor graph_persistent_lds(const at::Tensor& features,
                                const at::Tensor& indices,
                                const at::Tensor& transforms,
                                int64_t persistent_blocks,
                                int64_t ticket_batch_size)
{
    return launch_graph_persistent_common(features,
                                          indices,
                                          transforms,
                                          0,
                                          persistent_blocks,
                                          ticket_batch_size,
                                          "graph_persistent_lds");
}

at::Tensor graph_persistent_lds_chunked(const at::Tensor& features,
                                        const at::Tensor& indices,
                                        const at::Tensor& transforms,
                                        int64_t transform_chunk_size,
                                        int64_t persistent_blocks,
                                        int64_t ticket_batch_size)
{
    return launch_graph_persistent_common(features,
                                          indices,
                                          transforms,
                                          transform_chunk_size,
                                          persistent_blocks,
                                          ticket_batch_size,
                                          "graph_persistent_lds_chunked");
}

at::Tensor graph_persistent_auto(const at::Tensor& features,
                                 const at::Tensor& indices,
                                 const at::Tensor& transforms,
                                 int64_t persistent_blocks,
                                 int64_t ticket_batch_size)
{
    return launch_graph_persistent_common(features,
                                          indices,
                                          transforms,
                                          0,
                                          persistent_blocks,
                                          ticket_batch_size,
                                          "graph_persistent_auto");
}

at::Tensor graph_varlen_static(const at::Tensor& features,
                               const at::Tensor& offsets,
                               const at::Tensor& flat_indices,
                               const at::Tensor& transforms,
                               const at::Tensor& task_order)
{
    return launch_graph_varlen_static(features, offsets, flat_indices, transforms, task_order);
}

at::Tensor graph_varlen_static_chunked(const at::Tensor& features,
                                       const at::Tensor& flat_indices,
                                       const at::Tensor& transforms,
                                       const at::Tensor& work_task,
                                       const at::Tensor& work_start,
                                       const at::Tensor& work_count,
                                       const at::Tensor& work_transform,
                                       int64_t num_tasks)
{
    return launch_graph_varlen_static_chunked(features,
                                             flat_indices,
                                             transforms,
                                             work_task,
                                             work_start,
                                             work_count,
                                             work_transform,
                                             num_tasks);
}

std::vector<at::Tensor> graph_build_varlen_work_items(const at::Tensor& offsets,
                                                      const at::Tensor& task_order,
                                                      const at::Tensor& transform_counts,
                                                      const at::Tensor& edge_limits,
                                                      int64_t num_transforms,
                                                      int64_t chunk_tokens)
{
    return launch_graph_build_varlen_work_items(offsets,
                                                task_order,
                                                transform_counts,
                                                edge_limits,
                                                num_transforms,
                                                chunk_tokens);
}

std::vector<at::Tensor> graph_build_varlen_work_items_fixed(
    const at::Tensor& offsets,
    const at::Tensor& task_order,
    const at::Tensor& transform_counts,
    const at::Tensor& edge_limits,
    int64_t num_transforms,
    int64_t chunk_tokens,
    int64_t work_capacity)
{
    return launch_graph_build_varlen_work_items_fixed(offsets,
                                                      task_order,
                                                      transform_counts,
                                                      edge_limits,
                                                      num_transforms,
                                                      chunk_tokens,
                                                      work_capacity);
}

std::vector<at::Tensor> graph_generate_varlen_metadata(const at::Tensor& device_anchor,
                                                       int64_t num_tasks,
                                                       int64_t rows,
                                                       int64_t mean_neighbors,
                                                       int64_t max_neighbors,
                                                       double skew,
                                                       double pareto_alpha,
                                                       int64_t seed,
                                                       const std::string& index_pattern,
                                                       int64_t num_transforms,
                                                       double filter_ratio,
                                                       double transform_active_ratio,
                                                       double early_exit_ratio,
                                                       int64_t num_buckets)
{
    return launch_graph_generate_varlen_metadata(device_anchor,
                                                 num_tasks,
                                                 rows,
                                                 mean_neighbors,
                                                 max_neighbors,
                                                 skew,
                                                 pareto_alpha,
                                                 seed,
                                                 index_pattern,
                                                 num_transforms,
                                                 filter_ratio,
                                                 transform_active_ratio,
                                                 early_exit_ratio,
                                                 num_buckets);
}

at::Tensor graph_varlen_static_chunked_fixed(const at::Tensor& features,
                                             const at::Tensor& flat_indices,
                                             const at::Tensor& transforms,
                                             const at::Tensor& work_task,
                                             const at::Tensor& work_start,
                                             const at::Tensor& work_count,
                                             const at::Tensor& work_transform,
                                             const at::Tensor& work_size,
                                             int64_t num_tasks)
{
    return launch_graph_varlen_static_chunked_fixed(features,
                                                   flat_indices,
                                                   transforms,
                                                   work_task,
                                                   work_start,
                                                   work_count,
                                                   work_transform,
                                                   work_size,
                                                   num_tasks);
}

at::Tensor graph_varlen_persistent_node(const at::Tensor& features,
                                        const at::Tensor& offsets,
                                        const at::Tensor& flat_indices,
                                        const at::Tensor& transforms,
                                        const at::Tensor& task_order,
                                        int64_t persistent_blocks,
                                        int64_t ticket_batch_size)
{
    return launch_graph_varlen_persistent_node(features,
                                              offsets,
                                              flat_indices,
                                              transforms,
                                              task_order,
                                              persistent_blocks,
                                              ticket_batch_size);
}

at::Tensor graph_varlen_persistent_chunked(const at::Tensor& features,
                                           const at::Tensor& flat_indices,
                                           const at::Tensor& transforms,
                                           const at::Tensor& work_task,
                                           const at::Tensor& work_start,
                                           const at::Tensor& work_count,
                                           const at::Tensor& work_transform,
                                           int64_t num_tasks,
                                           int64_t persistent_blocks,
                                           int64_t ticket_batch_size)
{
    return launch_graph_varlen_persistent_chunked(features,
                                                 flat_indices,
                                                 transforms,
                                                 work_task,
                                                 work_start,
                                                 work_count,
                                                 work_transform,
                                                 num_tasks,
                                                 persistent_blocks,
                                                 ticket_batch_size);
}

at::Tensor replay_self_cull_many(const at::Tensor& device_anchor,
                                 const at::Tensor& actual_work_sizes,
                                 const at::Tensor& work_capacities,
                                 int64_t max_capacity,
                                 int64_t work_iters)
{
    return launch_replay_self_cull_many(device_anchor,
                                        actual_work_sizes,
                                        work_capacities,
                                        max_capacity,
                                        work_iters);
}

at::Tensor replay_gather_dot_many(const at::Tensor& features,
                                  const at::Tensor& transforms,
                                  const at::Tensor& actual_work_sizes,
                                  const at::Tensor& work_capacities,
                                  int64_t max_capacity,
                                  int64_t chunk_tokens)
{
    return launch_replay_gather_dot_many(features,
                                         transforms,
                                         actual_work_sizes,
                                         work_capacities,
                                         max_capacity,
                                         chunk_tokens);
}


at::Tensor replay_self_cull_fused(const at::Tensor& device_anchor,
                                  const at::Tensor& actual_work_sizes,
                                  int64_t work_capacity,
                                  int64_t work_iters)
{
    return launch_replay_self_cull_fused(device_anchor,
                                         actual_work_sizes,
                                         work_capacity,
                                         work_iters);
}

at::Tensor replay_gather_dot_fused(const at::Tensor& features,
                                   const at::Tensor& transforms,
                                   const at::Tensor& actual_work_sizes,
                                   int64_t work_capacity,
                                   int64_t chunk_tokens)
{
    return launch_replay_gather_dot_fused(features,
                                          transforms,
                                          actual_work_sizes,
                                          work_capacity,
                                          chunk_tokens);
}


at::Tensor replay_paged_kv_dot_fused(const at::Tensor& kv_pool,
                                     const at::Tensor& transforms,
                                     const at::Tensor& actual_work_sizes,
                                     const at::Tensor& row_indices,
                                     const at::Tensor& cache_seqlens,
                                     const at::Tensor& block_tables,
                                     int64_t work_capacity,
                                     int64_t chunk_tokens)
{
    return launch_replay_paged_kv_dot_fused(kv_pool,
                                            transforms,
                                            actual_work_sizes,
                                            row_indices,
                                            cache_seqlens,
                                            block_tables,
                                            work_capacity,
                                            chunk_tokens);
}


at::Tensor replay_paged_kv_attn_fused(const at::Tensor& k_pool,
                                      const at::Tensor& v_pool,
                                      const at::Tensor& q_transforms,
                                      const at::Tensor& v_transforms,
                                      const at::Tensor& actual_work_sizes,
                                      const at::Tensor& row_indices,
                                      const at::Tensor& cache_seqlens,
                                      const at::Tensor& block_tables,
                                      int64_t work_capacity,
                                      int64_t chunk_tokens)
{
    return launch_replay_paged_kv_attn_fused(k_pool,
                                             v_pool,
                                             q_transforms,
                                             v_transforms,
                                             actual_work_sizes,
                                             row_indices,
                                             cache_seqlens,
                                             block_tables,
                                             work_capacity,
                                             chunk_tokens);
}

void replay_paged_kv_chunk_workspace(const at::Tensor& k_pool,
                                     const at::Tensor& v_pool,
                                     const at::Tensor& q_transforms,
                                     const at::Tensor& actual_work_sizes,
                                     const at::Tensor& row_indices,
                                     const at::Tensor& cache_seqlens,
                                     const at::Tensor& block_tables,
                                     const at::Tensor& chunk_m,
                                     const at::Tensor& chunk_l,
                                     const at::Tensor& chunk_acc,
                                     int64_t work_capacity,
                                     int64_t chunk_tokens)
{
    launch_replay_paged_kv_chunk_workspace(k_pool,
                                           v_pool,
                                           q_transforms,
                                           actual_work_sizes,
                                           row_indices,
                                           cache_seqlens,
                                           block_tables,
                                           chunk_m,
                                           chunk_l,
                                           chunk_acc,
                                           work_capacity,
                                           chunk_tokens);
}

void replay_paged_kv_reduce_workspace(const at::Tensor& chunk_m,
                                      const at::Tensor& chunk_l,
                                      const at::Tensor& chunk_acc,
                                      const at::Tensor& cache_seqlens,
                                      const at::Tensor& output,
                                      int64_t chunk_tokens)
{
    launch_replay_paged_kv_reduce_workspace(chunk_m,
                                            chunk_l,
                                            chunk_acc,
                                            cache_seqlens,
                                            output,
                                            chunk_tokens);
}

void replay_paged_kv_reduce_ml_workspace(const at::Tensor& chunk_m,
                                         const at::Tensor& chunk_l,
                                         const at::Tensor& cache_seqlens,
                                         const at::Tensor& output,
                                         int64_t chunk_tokens)
{
    launch_replay_paged_kv_reduce_ml_workspace(chunk_m,
                                               chunk_l,
                                               cache_seqlens,
                                               output,
                                               chunk_tokens);
}

std::string graph_auto_policy(const at::Tensor& features,
                              const at::Tensor& indices,
                              const at::Tensor& transforms)
{
    validate_transforms(features, indices, transforms);
    const auto meta = make_meta(features, indices);
    int64_t transform_chunk_size = 0;
    const auto variant = choose_graph_auto_variant(features,
                                                   meta.num_tasks,
                                                   meta.tile_tokens,
                                                   meta.dim,
                                                   transforms.size(0),
                                                   &transform_chunk_size);
    return graph_variant_kind_name(variant, transform_chunk_size);
}

bool direct_lds_compiled()
{
#if RDNA3_GATHER_ENABLE_DIRECT_LDS && defined(__gfx11__) && !CK_TILE_USE_BUFFER_ADDRESSING_BUILTIN
    return true;
#else
    return false;
#endif
}

PYBIND11_MODULE(TORCH_EXTENSION_NAME, m)
{
    m.def("gather_baseline", &gather_baseline, "global gather -> global dense");
    m.def("gather_vgpr_lds", &gather_vgpr_lds, "global -> VGPR -> LDS -> global dense");
    m.def("gather_direct_lds", &gather_direct_lds, "candidate direct-to-LDS -> global dense");
    m.def("fused_global_sum", &fused_global_sum, "Phase 2 global gather + repeated sum consumer");
    m.def("fused_lds_sum", &fused_lds_sum, "Phase 2 LDS densify + repeated sum consumer");
    m.def("dot_global", &dot_global, "Phase 2 decode-like global gather + query dot products");
    m.def("dot_lds", &dot_lds, "Phase 2 decode-like LDS densify + query dot products");
    m.def("graph_global", &graph_global, "Phase 2 graph global gather + transform aggregation");
    m.def("graph_lds", &graph_lds, "Phase 2 graph LDS densify + transform aggregation");
    m.def("graph_lds_chunked",
          &graph_lds_chunked,
          "Phase 2 graph LDS densify + chunked transform aggregation");
    m.def("graph_auto", &graph_auto, "Phase 2 graph shape-based dispatch");
    m.def("graph_persistent_global",
          &graph_persistent_global,
          "Phase 3 finite persistent queue graph global aggregation");
    m.def("graph_persistent_lds",
          &graph_persistent_lds,
          "Phase 3 finite persistent queue graph LDS aggregation");
    m.def("graph_persistent_lds_chunked",
          &graph_persistent_lds_chunked,
          "Phase 3 finite persistent queue graph chunked LDS aggregation");
    m.def("graph_persistent_auto",
          &graph_persistent_auto,
          "Phase 3 finite persistent queue graph table-driven aggregation");
    m.def("graph_varlen_static",
          &graph_varlen_static,
          "Phase 3B varlen graph static node dispatch");
    m.def("graph_varlen_static_chunked",
          &graph_varlen_static_chunked,
          "Phase 3B varlen graph static edge-chunk dispatch");
    m.def("graph_build_varlen_work_items",
          &graph_build_varlen_work_items,
          "Phase 3C GPU-side varlen graph edge-chunk worklist generation");
    m.def("graph_build_varlen_work_items_fixed",
          &graph_build_varlen_work_items_fixed,
          "Phase 3E fixed-capacity GPU-side varlen graph worklist generation");
    m.def("graph_generate_varlen_metadata",
          &graph_generate_varlen_metadata,
          "Phase 3D GPU-side synthetic varlen graph metadata generation");
    m.def("graph_varlen_static_chunked_fixed",
          &graph_varlen_static_chunked_fixed,
          "Phase 3E fixed-grid self-culling varlen graph static chunked dispatch");
    m.def("graph_varlen_persistent_node",
          &graph_varlen_persistent_node,
          "Phase 3B varlen graph persistent node dispatch");
    m.def("graph_varlen_persistent_chunked",
          &graph_varlen_persistent_chunked,
          "Phase 3B varlen graph persistent edge-chunk dispatch");
    m.def("replay_self_cull_many",
          &replay_self_cull_many,
          "Trace replay: fixed-grid self-cull with minimal simulated work");
    m.def("replay_gather_dot_many",
          &replay_gather_dot_many,
          "Trace replay: fixed-grid self-cull with synthetic gather-dot consumer");
    m.def("replay_self_cull_fused",
          &replay_self_cull_fused,
          "Trace replay: fused multi-row fixed-grid self-cull");
    m.def("replay_gather_dot_fused",
          &replay_gather_dot_fused,
          "Trace replay: fused multi-row fixed-grid gather-dot consumer");
    m.def("replay_paged_kv_dot_fused",
          &replay_paged_kv_dot_fused,
          "Trace replay: fused multi-row vLLM-like paged KV gather-dot consumer");
    m.def("replay_paged_kv_attn_fused",
          &replay_paged_kv_attn_fused,
          "Trace replay: fused multi-row paged K/V attention-proxy consumer");
    m.def("replay_paged_kv_chunk_workspace",
          &replay_paged_kv_chunk_workspace,
          "Trace replay: paged K/V chunk-local softmax workspace writer");
    m.def("replay_paged_kv_reduce_workspace",
          &replay_paged_kv_reduce_workspace,
          "Trace replay: row/head online softmax workspace reduce");
    m.def("replay_paged_kv_reduce_ml_workspace",
          &replay_paged_kv_reduce_ml_workspace,
          "Trace replay: row/head online softmax m/l-only reduce ablation");
    m.def("graph_auto_policy", &graph_auto_policy, "Describe graph_auto dispatch decision");
    m.def("direct_lds_compiled", &direct_lds_compiled);
}
