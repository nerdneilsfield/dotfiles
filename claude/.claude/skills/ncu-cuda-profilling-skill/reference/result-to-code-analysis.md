# Result-To-Code Analysis

Use this workflow when the user wants more than a bottleneck label. The goal is to connect Nsight Compute evidence back to concrete CUDA/C++ code structures and produce code-level optimization guidance.

This workflow is model-driven. Do not rely on the analyzer script to identify root cause in code.

## Preconditions

You need:

- At least one of:
  - `.ncu-rep`
  - raw CSV from `ncu --page raw --csv`
  - `--print-summary per-kernel` output
- Local CUDA/C++ source code for the target kernel
- Enough repository context to find:
  - the kernel definition
  - the launch site
  - nearby helpers, macros, templates, and memory layout code

## Workflow

Copy this checklist and keep it updated:

```text
Result-to-Code Progress:
- [ ] 1. Lock the target kernel and the strongest metric evidence
- [ ] 2. Locate the kernel definition in the local repository
- [ ] 3. Locate the launch site and execution configuration
- [ ] 4. Inspect memory layout, indexing, synchronization, and helper functions
- [ ] 5. Build metric-to-code hypotheses with explicit uncertainty
- [ ] 6. Produce root-cause analysis, code-level suggestions, and validation commands
```

## 1. Lock The Target Kernel

Do not analyze the whole repository.

First identify:

- The kernel to focus on
- The key sections and metrics driving the analysis
- Whether the kernel is custom code or from a library

If the result is mostly library kernels such as cuBLAS or cuDNN, say so and stop the code-level analysis unless the user still wants launch-context analysis.

## 2. Use Source Correlation When Available

Nsight Compute CLI supports source output:

```bash
ncu --import report.ncu-rep --page source --print-source cuda,sass
```

If source files moved, resolve them explicitly:

```bash
ncu --import report.ncu-rep \
  --page source \
  --print-source cuda,sass \
  --resolve-source-file /abs/path/kernel.cu
```

Use source-correlated output to anchor the model’s reasoning when available, especially for `SourceCounters` or source-level metric attribution.

If source correlation is unavailable, fall back to repository code reading plus section evidence.

## 3. Read Only The Smallest Relevant Code Slice

Inspect in this order:

1. Kernel definition
2. Launch site
3. Indexing helpers and tiling constants
4. Shared-memory declarations and synchronization
5. Vectorized load/store paths
6. Template parameters or macros that affect register count, tile size, or block size

Prefer focused repository search instead of broad file loading. Typical search patterns:

```bash
rg "kernel_name|launch_bounds|<<<|__global__|extern __shared__|__shared__" .
rg "blockDim|gridDim|threadIdx|warpSize|float4|half2|int4" .
```

## 4. Map Metrics To Code Structures

Use evidence from Nsight Compute plus CUDA Best Practices to drive the mapping.

### Memory-side symptoms

Look for:

- Strided or scattered global loads and stores
- Missing coalescing
- Repeated global loads that should be re-used
- Shared-memory layouts that may create bank conflicts
- Excessive host-device transfers around the kernel

CUDA Best Practices emphasizes:

- minimize host-device transfers
- keep data on device when possible
- optimize global-memory access patterns first
- treat shared-memory optimization as most useful when bank conflicts are plausible

Do not claim bank conflicts from throughput alone.

### Occupancy / execution configuration symptoms

Look for:

- Large per-thread register footprints
- Shared-memory allocations that limit active blocks
- Execution configurations that under-fill the machine
- `__launch_bounds__`, `-maxrregcount`, or template parameters that may constrain occupancy

Use launch configuration and register usage as evidence. Do not claim that high occupancy is required for good performance.

### Scheduler / latency-hiding symptoms

Only go deep here when `SchedulerStats` suggests poor issue efficiency.

Look for:

- dependency-heavy inner loops
- long-latency memory operations with little independent work
- frequent synchronization points
- serialized reductions or control-flow bottlenecks

Do not over-interpret warp stall categories before confirming scheduler inefficiency.

### Compute / instruction symptoms

Look for:

- narrow instruction mix or pipeline concentration
- expensive math in tight loops
- avoidable precision choices
- poor use of fused math or tensor-core-capable paths when applicable

Per CUDA Best Practices, instruction optimization comes after higher-priority parallelism and memory issues unless the evidence clearly points to instruction throughput.

## 5. Root-Cause Standard

Every claim must be labeled as one of:

- `Supported by evidence`
- `Plausible but unverified`
- `Rejected by current evidence`

The model must explicitly separate:

- what the metrics show
- what the code contains
- why that code likely explains those metrics
- what still needs validation

## 6. Required Output Shape

The final analysis must include:

- `Target kernel`
- `Metric evidence`
- `Code evidence`
- `Likely root cause`
- `Uncertainty / alternative explanations`
- `Optimization suggestions tied to code locations`
- `Next validation command`

Default to Template B in [report-template.md](report-template.md) unless the user asks for another format.

## Suggested Validation Commands

If the hypothesis is memory-related:

```bash
ncu --section SpeedOfLight --section LaunchStats --section Occupancy --section MemoryWorkloadAnalysis --section MemoryWorkloadAnalysis_Tables -k regex:<kernel> -c 1 -- ./your_app
```

If the hypothesis is scheduler-related:

```bash
ncu --section SpeedOfLight --section LaunchStats --section Occupancy --section SchedulerStats --section WarpStateStats --section SourceCounters -k regex:<kernel> -c 1 -- ./your_app
```

If source correlation is important:

```bash
ncu --import report.ncu-rep --page source --print-source cuda,sass --resolve-source-file /abs/path/kernel.cu
```
