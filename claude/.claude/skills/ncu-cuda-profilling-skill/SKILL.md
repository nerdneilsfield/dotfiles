---
name: ncu-cuda-profiling
description: Profiles CUDA kernels with Nsight Compute CLI, imports .ncu-rep reports, and turns NCU metrics into structured bottleneck and code-level analysis. Use when the user asks to diagnose CUDA kernel performance, interpret Nsight Compute output, compare optimization runs, or trace Nsight Compute findings back into local CUDA/C++ kernel code.
---

# NCU CUDA Profiling

Use this skill for kernel-level GPU performance work with Nsight Compute CLI (`ncu`).

Do not use this skill for timeline-level CPU/GPU interaction analysis, startup latency, stream overlap, or end-to-end pipeline tracing. Those cases belong to Nsight Systems.

## Working Rules

- Prefer importing an existing `.ncu-rep` report over re-running the workload.
- Start with focused sections. Do not default to `--set full`; it increases replay passes and overhead.
- Narrow the profile scope with `-k`, `-c`, `-s`, `--kernel-id`, or NVTX filters before asking for more metrics.
- Use `--target-processes all` only when child processes or MPI ranks must be profiled.
- Separate reproducibility goals from realism:
  - For stable comparisons, prefer `--cache-control all` and fixed clocks when available.
  - For cache-sensitive behavior, consider `--cache-control none` and explain the tradeoff.
- Treat automated diagnosis as heuristic. Every conclusion must cite concrete metrics or sections.

## Inputs To Gather

Collect the minimum missing context before choosing commands:

- Existing artifacts: `.ncu-rep`, raw CSV, summary text, screenshots.
- Exact launch command and arguments.
- Target kernel name or NVTX range, if known.
- GPU model and whether the workload is single-process, child-process, MPI, MPS, or communication-heavy.
- Whether the goal is first-pass triage, memory diagnosis, scheduler/latency diagnosis, or before/after comparison.
- Whether local CUDA/C++ source code is available and which repository contains the kernel implementation.

## Workflow

Copy this checklist and keep it updated:

```text
NCU Profiling Progress:
- [ ] 1. Determine whether an existing report can be imported
- [ ] 2. Choose the lowest-overhead collection strategy that answers the question
- [ ] 3. Filter to the relevant kernel launches or NVTX ranges
- [ ] 4. Export raw data and a readable summary
- [ ] 5. Form a bottleneck hypothesis with evidence
- [ ] 6. Propose the next profiling or code-change experiment
```

### 1. Reuse Existing Reports First

If the user already has a report:

```bash
ncu --import profile.ncu-rep --print-summary per-kernel
ncu --import profile.ncu-rep --page raw --csv --print-units base > profile_raw.csv
python3 examples/ncu_analyzer.py --import profile.ncu-rep -o profile_analysis.md
```

Do not re-run the application unless the report is missing the sections needed for the current question.

### 2. Pick A Collection Strategy

Use the smallest useful data set:

- First-pass triage:
  - `SpeedOfLight`, `LaunchStats`, `Occupancy`
- Memory deep dive:
  - Add `MemoryWorkloadAnalysis` and `MemoryWorkloadAnalysis_Tables`
- Scheduler or latency deep dive:
  - Add `SchedulerStats`, `WarpStateStats`, `SourceCounters`
- Full archival capture:
  - Use `--set full` only when the narrower sets are insufficient

Command recipes live in [reference/command-recipes.md](reference/command-recipes.md).

### 3. Filter Before Expanding

Use one or more of these before collecting more metrics:

- `-k regex:<pattern>` for kernel-name filtering
- `-c <count>` and `-s <skip>` for launch slicing
- `--kernel-id` when stream/context/invocation disambiguation matters
- `--nvtx --nvtx-include ...` when the application already emits NVTX ranges

If the workload contains child processes that launch CUDA kernels, add `--target-processes all`.

### 4. Export Machine-Readable And Human-Readable Outputs

Always keep both:

- Human summary:
  - `ncu --import report.ncu-rep --print-summary per-kernel`
- Structured raw data:
  - `ncu --import report.ncu-rep --page raw --csv --print-units base > report_raw.csv`
- Optional section detail dump:
  - `ncu --import report.ncu-rep --page details > report_details.txt`

### 5. Diagnose With Evidence

Follow [reference/diagnosis-playbook.md](reference/diagnosis-playbook.md).

Non-negotiable interpretation rules:

- Do not chase warp stall reasons unless scheduler issue efficiency is actually poor.
- Low occupancy can matter; high occupancy alone does not prove a kernel is healthy.
- High throughput can mean saturation or waste. Pair throughput with access-pattern evidence.
- If metrics are `n/a`, verify the metric name with `--query-metrics` and confirm the GPU architecture supports it.

### 6. Respond With A Tight Deliverable

Use [reference/report-template.md](reference/report-template.md).

The response must include:

- Bottleneck hypothesis
- Exact evidence used
- Confidence level and uncertainty
- Concrete next experiments or code changes
- The next `ncu` command when more data is needed

### 7. Trace Results Back Into Code

If the user wants root-cause analysis or optimization ideas, and local CUDA/C++ source is available, switch to the model-driven result-to-code workflow in [reference/result-to-code-analysis.md](reference/result-to-code-analysis.md).

Use this path when:

- The result-level diagnosis is not enough by itself.
- The user asks which code structure likely caused the metrics.
- The user asks for code-level optimization ideas tied to the current report.

Do not use this path when:

- Only high-level profiling commands are requested.
- The local repository does not contain the target kernel implementation.
- The workload is mostly library kernels and no custom CUDA/C++ kernel source is available.

## Scripts

Prefer executing the bundled utilities instead of re-typing ad hoc commands:

- `examples/auto_profile.sh`
  - Collects a focused or full report, exports summary/detail/raw artifacts, and runs the analyzer.
- `examples/ncu_analyzer.py`
  - Imports `.ncu-rep` or raw CSV, normalizes common metrics, and writes a structured Markdown report.

Example:

```bash
./examples/auto_profile.sh --mode memory --kernel-regex "matmul.*" -o matmul_mem -- ./build/matmul
python3 examples/ncu_analyzer.py --import ncu_reports/matmul_mem.ncu-rep -o ncu_reports/matmul_mem_analysis.md
```

## References

- Command recipes: [reference/command-recipes.md](reference/command-recipes.md)
- Diagnosis playbook: [reference/diagnosis-playbook.md](reference/diagnosis-playbook.md)
- Result-to-code workflow: [reference/result-to-code-analysis.md](reference/result-to-code-analysis.md)
- Report template: [reference/report-template.md](reference/report-template.md)
- Evaluation scenarios: [reference/evaluations.md](reference/evaluations.md)
- Example workflows: [examples/README.md](examples/README.md)

## Best-Practice Notes

- Nsight Compute CLI and Profiling Guide:
  - Start small; sets/sections directly control replay overhead.
  - Application replay helps when kernel replay would hang or distort host-dependent kernels.
  - Narrow NVTX ranges reduce capture and replay overhead.
  - `--target-processes all` is required when CUDA work moves into child processes.
  - `--page source` with `--print-source cuda,sass` can correlate collected metrics back to source and disassembly.
- Claude skill authoring:
  - Keep `SKILL.md` short and executable.
  - Put heavier details in one-level-deep reference files.
  - Prefer deterministic scripts for repeatable operations.
