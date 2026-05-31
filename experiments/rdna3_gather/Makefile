HIPCC ?= hipcc
GPU_ARCH ?= gfx1100
CXXFLAGS ?= -O3 -std=c++17

.PHONY: all standalone clean

all: standalone

standalone: standalone_paged_producer standalone_stride_probe

standalone_paged_producer: standalone_paged_producer.hip
	$(HIPCC) $(CXXFLAGS) --offload-arch=$(GPU_ARCH) $< -o $@

standalone_stride_probe: standalone_stride_probe.hip
	$(HIPCC) $(CXXFLAGS) --offload-arch=$(GPU_ARCH) $< -o $@

clean:
	rm -f standalone_paged_producer standalone_stride_probe
