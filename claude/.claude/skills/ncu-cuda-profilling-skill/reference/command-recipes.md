# NCU Command Recipes

Use these recipes as defaults. Prefer the smallest collection scope that answers the question.

## 1. Import Existing Reports

```bash
ncu --import profile.ncu-rep --print-summary per-kernel
ncu --import profile.ncu-rep --page raw --csv --print-units base > profile_raw.csv
ncu --import profile.ncu-rep --page details > profile_details.txt
```

Use `--import` whenever the user already has a `.ncu-rep`. This avoids re-running the workload and preserves the original capture.

## 2. Quick Triage

```bash
ncu \
  --section SpeedOfLight \
  --section LaunchStats \
  --section Occupancy \
  --cache-control all \
  --force-overwrite \
  -o triage \
  ./your_app
```

Use this when the bottleneck is unknown. It captures the first useful layer without paying the cost of `--set full`.

## 3. Memory Deep Dive

```bash
ncu \
  --section SpeedOfLight \
  --section LaunchStats \
  --section Occupancy \
  --section MemoryWorkloadAnalysis \
  --section MemoryWorkloadAnalysis_Tables \
  --cache-control all \
  --force-overwrite \
  -o memory_dive \
  ./your_app
```

Use this when speed-of-light metrics point toward memory pressure, or when you need coalescing, hit-rate, and sector/request evidence.

## 4. Scheduler / Latency Deep Dive

```bash
ncu \
  --section SpeedOfLight \
  --section LaunchStats \
  --section Occupancy \
  --section SchedulerStats \
  --section WarpStateStats \
  --section SourceCounters \
  --cache-control all \
  --force-overwrite \
  -o scheduler_dive \
  ./your_app
```

Use this when the issue looks like poor latency hiding, low eligible warps, or skipped issue slots.

## 5. Full Capture

```bash
ncu --set full --force-overwrite -o full_capture ./your_app
```

Reserve this for final archival captures or when the narrower section sets still leave the question unanswered. Full capture often requires many replay passes.

## 6. Filter Kernels Before Adding Metrics

Kernel name filter:

```bash
ncu -k regex:matmul.* -c 1 -s 5 -o matmul_slice ./your_app
```

Use:

- `-k regex:<pattern>` to isolate the kernel family
- `-s <skip>` to skip warmup launches
- `-c <count>` to profile only the relevant launches

If you know the precise launch identity, prefer `--kernel-id`.

## 7. Use NVTX To Capture The Right Range

```bash
ncu \
  --nvtx \
  --nvtx-include "train_step/" \
  --section SpeedOfLight \
  --section LaunchStats \
  --section Occupancy \
  -o train_step \
  ./your_app
```

This is better than broad profiling when the app already emits NVTX ranges.

## 8. Child Processes And Multi-Process Workloads

Child processes:

```bash
ncu --target-processes all -o multi_proc ./launcher
```

Use `--target-processes all` when CUDA kernels run in child processes; otherwise the target kernels may never appear in the report.

MPI or communication-heavy workloads with mandatory concurrent kernels:

```bash
mpirun -np 4 ncu \
  --communicator tcp \
  --communicator-num-peers 4 \
  --lockstep-kernel-launch \
  -o report \
  ./your_app
```

For single-node same-process-tree communication kernels, `--communicator shmem` may be appropriate instead. Keep this as an advanced path, not the default.

## 9. Reproducibility Knobs

Stable comparisons:

```bash
ncu --cache-control all -o stable_run ./your_app
```

Cache-sensitive realism:

```bash
ncu --cache-control none -o realistic_run ./your_app
```

Clock control can also be set explicitly:

```bash
ncu --clock-control base -o stable_run ./your_app
```

Use stable settings when comparing before/after changes. Use realistic settings only when the cache state created by earlier work is part of the workload itself.

## 10. Response Files For Repeatable Runs

Put stable options in a response file:

```text
--section SpeedOfLight
--section LaunchStats
--section Occupancy
--cache-control all
--force-overwrite
```

Then run:

```bash
ncu @triage.rsp -o triage ./your_app
```

Response files are useful when the same profile recipe must be re-run across multiple revisions.

## 11. Slice Big Reports After The Fact

```bash
ncu --import big_report.ncu-rep -k regex:matmul.* -c 1 --export matmul_only.ncu-rep
```

Use filtered export when the original report is large but only a subset matters.

## 12. Source Correlation For Code Analysis

Show CUDA source correlated with SASS for the profiled kernel:

```bash
ncu --import report.ncu-rep --page source --print-source cuda,sass
```

If the source file has moved, resolve it explicitly:

```bash
ncu --import report.ncu-rep \
  --page source \
  --print-source cuda,sass \
  --resolve-source-file /abs/path/kernel.cu
```

Use this when tracing Nsight Compute findings back into local CUDA/C++ code.
