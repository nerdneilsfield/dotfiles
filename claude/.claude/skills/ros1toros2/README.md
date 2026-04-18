# ros1toros2 Skill

A documentation-driven assistant for migrating ROS1 packages to ROS2 Jazzy. The skill guides the host agent through a 5-step workflow and supplies the knowledge references, templates, and helper scripts the agent reaches for during the work.

## What the skill produces

All outputs land under `<target_project>/docs/ros1-migration/`:

```
01-inventory.md          # ROS1 snapshot of the target workspace
02-design.md             # Mapping decisions per subsystem
03-plan.md               # Ordered task breakdown (human prose)
05-verify-report.md      # Verification outcome
artifacts/
  inventory.json         # scanner output
  plan-meta.json         # Machine contract: tasks + surface_changes
  verify-report.json     # verifier output
```

## Requirements

### Authoring (always needed)
- A host agent capable of reading files, editing files, and running shell commands.

### Verification (Step 5)
- ROS2 Jazzy installed and sourced in the shell where the agent runs `colcon build`.
- `colcon` and `ament_lint_auto` available.

### Scripts
- Python 3.9+
- Optional AST mode: `pip install libclang parse_cmake`
  - Without these, `scan_ros1.py` falls back to regex and marks each affected file `parser: "regex"`.

## Usage

Point the host agent at this skill and tell it which workspace to migrate. It will:
1. Read `SKILL.md` and step-by-step workflow docs under `references/workflow/`.
2. Produce each of the five output documents.
3. Consult `references/mappings/` and `references/api/` as it translates.

## Scripts

### `scripts/scan_ros1.py`

Walks a ROS1 workspace, dispatches per-language parsers, and emits
`inventory.json` plus an optional markdown digest.

```bash
python scripts/scan_ros1.py \
    --workspace <ws> \
    [--package <pkg>] \
    [--output <ws>/docs/ros1-migration/artifacts/inventory.json] \
    [--md <ws>/docs/ros1-migration/inventory-digest.md] \
    [--source-distro noetic] [--target-distro jazzy]
```

Requires Python 3.9+. Optional: `pip install libclang parse_cmake` for AST
parsing. Without them, affected files are marked `parser: "regex"` and the
scanner continues with degraded coverage.

### `scripts/verify_ros2.py`

Runs residual scan, interface-surface diff, `colcon build`, and
`colcon test`, emitting a structured JSON report plus an optional markdown
digest. Consumes `plan-meta.json` to decide which surface changes are
declared.

```bash
python scripts/verify_ros2.py \
    --workspace <ws> \
    --inventory <ws>/docs/ros1-migration/artifacts/inventory.json \
    --plan-meta <ws>/docs/ros1-migration/artifacts/plan-meta.json \
    [--output <ws>/docs/ros1-migration/artifacts/verify-report.json] \
    [--md <ws>/docs/ros1-migration/05-verify-report.md] \
    [--skip-build] [--skip-lint]
```

Requires ROS2 Jazzy sourced in the shell for build + lint. Use
`--skip-build --skip-lint` for quick residual + surface diffing without
a full build.

## Troubleshooting

| Symptom | Diagnosis / Fix |
|---|---|
| Agent reports "mapping not found for symbol X" | Symbol is custom or missing from `references/mappings/*.md`. Add it to the relevant mapping's Covered Symbols list, or triage in `02-design.md` "Open Questions". |
| `colcon build` fails with missing `<ros2-pkg>` | The ROS2 package name may differ from ROS1. Check `references/mappings/package-xml.md` and `references/mappings/cmakelists.md`. |
| `ament_lint` warnings on migrated code | Warnings don't block verification PASS. Fix at your convenience. |
| Verification reports undeclared surface change | Either restore the original topic/service/type/QoS, or declare the change in `artifacts/plan-meta.json` `surface_changes[]` with a justification. |
| Parser reports `parser: "regex"` | `libclang` or `parse_cmake` is unavailable or failed on that file. Install the optional deps if you want deeper AST coverage, or continue with the degraded scan and review the flagged files manually. |

## Structure

```
SKILL.md                           # Entry point (read first)
README.md                          # This file
references/
  README.md                        # Index
  workflow/                        # 5 step-by-step guides
  mappings/                        # 11 subsystem ROS1 → ROS2 mapping tables
  api/                             # Baked Jazzy documentation snapshots
  grep-patterns.md                 # Ripgrep patterns for residual scanning
  _external/                       # Archived third-party material
templates/                         # Scaffolds for output documents
scripts/                           # scan_ros1.py + verify_ros2.py + parsers
```
