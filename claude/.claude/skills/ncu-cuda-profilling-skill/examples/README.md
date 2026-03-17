# NCU CUDA Profiling Examples

This directory contains the executable examples used by the skill.

## Files

| File | Purpose |
| --- | --- |
| `auto_profile.sh` | Run a focused or full Nsight Compute capture, or import an existing report and export standard artifacts |
| `ncu_analyzer.py` | Analyze `raw.csv` plus optional summary text, or import a `.ncu-rep` directly |

## Recommended Workflows

### 1. Quick triage for an unknown bottleneck

```bash
./examples/auto_profile.sh \
  --mode quick \
  --kernel-regex 'matmul.*' \
  -s 5 \
  -c 1 \
  -- ./build/matmul
```

This keeps profiling overhead low and answers the first question: does the kernel look compute-limited, memory-limited, or launch-constrained?

### 2. Memory-focused deep dive

```bash
./examples/auto_profile.sh \
  --mode memory \
  --kernel-regex 'matmul.*' \
  -s 5 \
  -c 1 \
  -- ./build/matmul
```

Use this when quick triage suggests memory pressure or when you need cache and throughput evidence.

### 3. Scheduler / latency deep dive

```bash
./examples/auto_profile.sh \
  --mode scheduler \
  --kernel-regex 'attention.*' \
  -c 1 \
  -- ./build/attention
```

Use this when issue efficiency looks poor and you need scheduler and warp-state context.

### 4. Import-first workflow

```bash
./examples/auto_profile.sh --import ncu_reports/baseline.ncu-rep -o baseline
```

This is the preferred path when a report already exists.

## Output Artifacts

Each run writes files under `ncu_reports/` by default:

```text
<prefix>.ncu-rep          fresh capture only
<prefix>_profile.log      fresh capture only
<prefix>_summary.txt
<prefix>_details.txt
<prefix>_raw.csv
<prefix>_analysis.md
<prefix>_stderr.log
<prefix>_commands.txt
```

`commands.txt` records the exact `ncu` and analyzer commands used, which makes before/after comparison reproducible.

## `auto_profile.sh` Options

```bash
./examples/auto_profile.sh --help
```

Most useful flags:

- `--mode quick|memory|scheduler|full`
- `--import <report.ncu-rep>`
- `--kernel-regex <regex>`
- `-s <skip>` and `-c <count>` for warmup trimming
- `--nvtx-include <expr>` for range-based filtering
- `--target-processes application-only|all`
- `--cache-control all|none`
- `--clock-control <mode>`

## `ncu_analyzer.py` Usage

Analyze artifacts exported by the shell wrapper:

```bash
python3 examples/ncu_analyzer.py \
  --csv ncu_reports/quick_20260317_120000_raw.csv \
  --summary-file ncu_reports/quick_20260317_120000_summary.txt \
  --report-file ncu_reports/quick_20260317_120000.ncu-rep
```

Or import a report directly:

```bash
python3 examples/ncu_analyzer.py --import ncu_reports/baseline.ncu-rep
```

Useful flags:

- `--kernel-name <exact-name>`
- `--kernel-regex <regex>`
- `--json`
- `-o <analysis.md>`

## Best Practices

- Start with `quick`, not `full`.
- Filter kernels before adding more sections.
- Use `--target-processes all` only when CUDA work runs in child processes or a multi-process launch.
- Use imported reports when available instead of re-running the workload.
- Treat analyzer output as heuristic. Confirm strong claims with the relevant NCU sections.

## References

- [SKILL.md](../SKILL.md)
- [reference/command-recipes.md](../reference/command-recipes.md)
- [reference/diagnosis-playbook.md](../reference/diagnosis-playbook.md)
