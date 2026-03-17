# NCU Analysis Report Template

Use this exact structure unless the user asks for a different format.

## Template A: Result-Level Analysis

```markdown
# NCU Performance Analysis

## Workload
- Command: `...`
- GPU: `...`
- Kernel focus: `...`
- Report source: `existing .ncu-rep` | `fresh capture`

## Executive Summary
- Primary hypothesis: `...`
- Confidence: `high` | `medium` | `low`
- Why this is the current best explanation: `...`

## Evidence
- Section: `SpeedOfLight`
  - Metric or observation: `...`
  - Why it matters: `...`
- Section: `LaunchStats` / `Occupancy` / `MemoryWorkloadAnalysis` / `SchedulerStats`
  - Metric or observation: `...`
  - Why it matters: `...`

## Code Evidence
- File: `...`
- Kernel / helper / launch site: `...`
- Relevant structure: `indexing` | `shared memory` | `launch config` | `vectorized access` | `sync` | `register pressure source`
- Why it matches the metrics: `...`

## What Is Still Uncertain
- `...`

## Recommended Next Step
- Next command:
  ```bash
  ncu ...
  ```
- What that command should disambiguate: `...`

## Code-Level Experiments
1. `...`
2. `...`
3. `...`

## Pitfalls To Avoid
- `...`
```

## Template B: Result-To-Code Root Cause Analysis

Use this when the user wants the model to trace Nsight Compute findings back into local CUDA/C++ code.

```markdown
# NCU Result-To-Code Analysis

## Target
- Kernel: `...`
- Report source: `...`
- Code path: `...`

## Executive Summary
- Primary root-cause hypothesis: `...`
- Confidence: `high` | `medium` | `low`
- Why this is the current best explanation: `...`

## Metric Evidence
- Section: `...`
  - Metric / observation: `...`
  - Why it matters: `...`
- Section: `...`
  - Metric / observation: `...`
  - Why it matters: `...`

## Code Evidence
- File: `...`
  - Function / kernel: `...`
  - Relevant structure: `...`
  - Why it matches the metrics: `...`
- File: `...`
  - Launch site / helper / macro: `...`
  - Relevant structure: `...`
  - Why it matches the metrics: `...`

## Likely Root Cause
- `Supported by evidence`: `...`
- `Plausible but unverified`: `...`
- `Rejected by current evidence`: `...`

## Optimization Suggestions
1. File / location: `...`
   - Suggested change: `...`
   - Expected effect on metrics: `...`
2. File / location: `...`
   - Suggested change: `...`
   - Expected effect on metrics: `...`

## Validation Plan
- Next command:
  ```bash
  ncu ...
  ```
- What it should prove or disprove: `...`

## Open Questions
- `...`
```

## Authoring Rules

- Keep the executive summary to 3 bullets or fewer.
- Cite sections, not vague impressions.
- Do not claim a root cause from a single metric.
- If evidence is mixed, say so and choose the next smallest experiment.
- In result-to-code analysis, always separate metric evidence from code evidence.
- Every code-level claim must be labeled by confidence, not implied as certain.
