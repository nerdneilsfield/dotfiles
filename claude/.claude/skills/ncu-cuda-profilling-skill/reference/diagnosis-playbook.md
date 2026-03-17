# NCU Diagnosis Playbook

Use this file after you have either an imported report or a fresh focused capture.

## Start With The Question, Not The Metric Dump

Always answer these in order:

1. Is the kernel mostly limited by compute issue rate, memory movement, or launch/occupancy constraints?
2. Which section contains the strongest evidence?
3. What is the next smallest profile that would disambiguate the remaining uncertainty?

## Section-To-Question Map

| Section | Use it to answer |
| --- | --- |
| `SpeedOfLight` | Is the pressure mostly on compute or memory resources? |
| `LaunchStats` | Is launch geometry or resource usage obviously poor? |
| `Occupancy` | Is low active-warp capacity limiting latency hiding? |
| `MemoryWorkloadAnalysis` | Is the bottleneck caused by DRAM, L2, or L1/TEX behavior? |
| `MemoryWorkloadAnalysis_Tables` | Are accesses coalesced, cache-friendly, and re-used well? |
| `SchedulerStats` | Are schedulers finding enough eligible warps to issue work? |
| `WarpStateStats` | Which warp states dominate when issue efficiency is poor? |
| `SourceCounters` | Where do sampled stalls or branch issues appear in code? |
| `ComputeWorkloadAnalysis` | Are specific SM pipelines saturated? |

## Evidence Rules

### Memory-bound signals

Look for a combination of:

- High memory-side speed-of-light pressure
- High DRAM or cache throughput
- Poor sector/request behavior or poor hit rate
- Evidence that extra traffic is caused by access pattern inefficiency, not just necessary bandwidth

Do not conclude "memory bound" from a single high throughput number alone.

### Occupancy or launch-constraint signals

Look for:

- Low achieved occupancy
- Resource-driven occupancy limits from registers, shared memory, or block size
- Low warp availability that plausibly explains poor latency hiding

Interpretation rule:

- Low occupancy can hurt.
- High occupancy is not automatically good.

### Scheduler / latency-hiding signals

Use `SchedulerStats` first. Only then use `WarpStateStats` and `SourceCounters`.

Interpretation rule from Nsight Compute guidance:

- Focus on stall reasons only when schedulers are failing to issue every cycle.

If schedulers already issue effectively, stall distributions are usually secondary noise, not the primary bottleneck.

### Compute-pipeline signals

Look for:

- High compute-side speed-of-light pressure
- Pipeline concentration in `ComputeWorkloadAnalysis`
- Instruction mix that suggests a narrow or overloaded pipeline

Then propose instruction-level or math-path experiments, not memory optimizations by default.

## Common Misreads

- High throughput is not the same as high efficiency.
- Lower DRAM throughput after an optimization can be good if cache reuse improved.
- A low cache hit rate matters only when it is consistent with the actual throughput and stall evidence.
- `n/a` metrics often mean the metric name is wrong, the suffix is wrong, or the GPU does not support it.
- If the profiled app moved CUDA work into child processes and `--target-processes all` was not used, missing kernels are a collection problem, not a performance finding.

## Replay-Aware Reasoning

Replay mode changes how you should interpret results:

- Kernel replay:
  - Default choice for many profiles.
  - Save/restore overhead grows with the amount of memory accessed and written.
- Application replay:
  - Better when kernels interact with the host during execution or when kernel replay hangs.
  - Requires deterministic kernel activity and matching behavior across runs.
- Range replay:
  - Useful when correctness or performance depends on concurrent kernels inside a CUDA range.

If overhead or hangs look suspicious, propose switching replay strategy before proposing code changes.

## Bottleneck-To-Next-Step Mapping

| Likely issue | Next smallest useful action |
| --- | --- |
| Memory pressure but cause unclear | Add `MemoryWorkloadAnalysis_Tables` |
| Low occupancy but cause unclear | Re-run with `LaunchStats` and inspect occupancy limits |
| Suspected scheduler stalls | Add `SchedulerStats` before `WarpStateStats` |
| Host interaction breaks kernel replay | Try application replay |
| Concurrent communication kernels do not make progress | Consider `--communicator tcp|shmem` and `--lockstep-kernel-launch` |

## Required Response Shape

Every diagnosis must include:

- `Hypothesis`
- `Evidence`
- `What this does not prove yet`
- `Next command`
- `Likely code-level experiment`

## When To Escalate Into Code Analysis

Escalate from result-only diagnosis into local code analysis when:

- The user asks for root cause in the kernel implementation.
- The next useful step is clearly code change rather than another capture.
- Metrics and sections are strong enough to inspect specific code structures.

When escalating:

- Follow [result-to-code-analysis.md](result-to-code-analysis.md).
- Use Nsight Compute source correlation if available.
- Keep the repository read scope narrow and tied to the target kernel.
