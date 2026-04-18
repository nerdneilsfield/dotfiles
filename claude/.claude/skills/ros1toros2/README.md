# ros1toros2 Skill

A documentation-driven assistant for migrating ROS1 packages to ROS2 Jazzy. The skill guides the host agent through a 5-step workflow and supplies the knowledge references, templates, and (from M2) helper scripts the agent reaches for during the work.

## What the skill produces

All outputs land under `<target_project>/docs/ros1-migration/`:

```
01-inventory.md          # ROS1 snapshot of the target workspace
02-design.md             # Mapping decisions per subsystem
03-plan.md               # Ordered task breakdown (human prose)
05-verify-report.md      # Verification outcome
artifacts/
  inventory.json         # (M2) scanner output
  plan-meta.json         # Machine contract: tasks + surface_changes
  verify-report.json     # (M2) verifier output
```

## Requirements

### Authoring (always needed)
- A host agent capable of reading files, editing files, and running shell commands.

### Verification (Step 5)
- ROS2 Jazzy installed and sourced in the shell where the agent runs `colcon build`.
- `colcon` and `ament_lint_auto` available.

### M2 scripts (not yet shipped)
- Python 3.9+
- Optional AST mode: `pip install libclang parse_cmake`
  - Without these, `scan_ros1.py` falls back to regex and marks each affected file `parser: "regex"`.

## Usage

Point the host agent at this skill and tell it which workspace to migrate. It will:
1. Read `SKILL.md` and step-by-step workflow docs under `references/workflow/`.
2. Produce each of the five output documents.
3. Consult `references/mappings/` and `references/api/` as it translates.

### Manual invocation (M2, placeholder)

Once M2 ships:

```bash
# Step 1 — comprehensive ROS1 scan
python scripts/scan_ros1.py \
    --workspace /path/to/ros1_ws \
    --output /path/to/target/docs/ros1-migration/artifacts/inventory.json

# Step 5 — post-migration verification
python scripts/verify_ros2.py \
    --workspace /path/to/ros2_ws \
    --inventory /path/to/target/docs/ros1-migration/artifacts/inventory.json \
    --output /path/to/target/docs/ros1-migration/artifacts/verify-report.json
```

## Troubleshooting

| Symptom | Diagnosis / Fix |
|---|---|
| Agent reports "mapping not found for symbol X" | Symbol is custom or missing from `references/mappings/*.md`. Add it to the relevant mapping's Covered Symbols list, or triage in `02-design.md` "Open Questions". |
| `colcon build` fails with missing `<ros2-pkg>` | The ROS2 package name may differ from ROS1. Check `references/mappings/package-xml.md` and `references/mappings/cmakelists.md`. |
| `ament_lint` warnings on migrated code | Warnings don't block verification PASS. Fix at your convenience. |
| Verification reports undeclared surface change | Either restore the original topic/service/type/QoS, or declare the change in `artifacts/plan-meta.json` `surface_changes[]` with a justification. |
| M2 scripts missing | The skill is currently at Milestone 1. The agent can run the full workflow using its native Read/Grep/Edit/Bash tools; workflow docs describe the manual path. |

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
scripts/                           # (M2) scan_ros1.py + verify_ros2.py + parsers
```
