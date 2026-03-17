# Evaluation Scenarios

Use these scenarios to pressure-test the skill after edits.

## Eval 1: Existing Report, No Re-Run

- User request:
  - "I already have `profile.ncu-rep`. Tell me why my GEMM kernel is slow."
- Expected behavior:
  - Import the report instead of re-running the workload.
  - Export summary plus raw CSV.
  - Provide an evidence-based bottleneck hypothesis and a next command only if more data is genuinely needed.

## Eval 2: Unknown Bottleneck, Many Warmup Launches

- User request:
  - "Profile this CUDA app. The target kernel is `matmul_optimized`, but it runs after several warmups."
- Expected behavior:
  - Use a focused section set, not `--set full`.
  - Filter with kernel regex and launch slicing (`-k`, `-s`, `-c`).
  - Explain why the chosen capture is lower overhead and sufficient for first-pass triage.

## Eval 3: Child Processes Or MPI

- User request:
  - "My launcher spawns child processes and the kernels do not appear in the report."
- Expected behavior:
  - Recognize that collection scope is the likely issue.
  - Recommend `--target-processes all`.
  - If the workload is MPI or mandatory concurrent communication, mention the advanced communicator and lockstep options only as needed.

## Eval 4: Misleading Stall Analysis

- User request:
  - "Warp stalls are high. Should I optimize stalls first?"
- Expected behavior:
  - Check scheduler issue evidence first.
  - Refuse to over-interpret stall reasons if scheduler efficiency is already healthy.
  - Recommend the next smallest section set that can prove or disprove a scheduler bottleneck.

## Eval 5: Result-To-Code Root Cause Analysis

- User request:
  - "Here is my `.ncu-rep`. Go back to the local CUDA code and tell me which code structure likely causes the bottleneck."
- Expected behavior:
  - Lock onto one target kernel instead of scanning the whole repository.
  - Read the kernel definition, launch site, and only the smallest relevant helper code.
  - Separate metric evidence from code evidence.
  - Label claims as supported, plausible, or still unverified.
  - Produce optimization suggestions tied to code locations plus the next validation command.
