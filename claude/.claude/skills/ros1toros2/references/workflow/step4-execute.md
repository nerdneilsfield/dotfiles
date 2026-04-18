# Step 4 - Execute

## Goal

Apply the migration plan to the ROS1 codebase, one task at a time, while keeping `artifacts/plan-meta.json` up to date and preserving the declared interface surface.

## Inputs

- `docs/ros1-migration/03-plan.md`
- `docs/ros1-migration/artifacts/plan-meta.json`
- `docs/ros1-migration/02-design.md`
- `references/mappings/*.md`
- `references/api/*.md`

## Agent activities

1. Pick the next task whose dependencies are complete.
2. Re-read the current target files before editing so plan assumptions are refreshed against the live tree.
3. Prefer string-based edits anchored by distinctive nearby text over brittle line-number edits.
4. Consult mapping docs and API snapshots for the subsystem being changed.
5. Preserve the interface surface by default. Only make a wire-level change if it is already declared in `plan-meta.json`.
6. If a new surface change becomes necessary, stop execution, return to Step 3, update both `03-plan.md` and `plan-meta.json`, and only then continue.
7. After finishing a task, flip its `status` in `plan-meta.json` to `completed`.
8. Build and sanity-check the affected package when the task says to do so.
9. Per-package commits are recommended to keep the migration reviewable, but they are not mandatory.
10. In M2, the agent may re-run `scripts/scan_ros1.py` on partially migrated code when a refreshed view is helpful.

## Tools available

- `Read`, `Grep`, `Glob`, `Edit`, `Write`
- `Bash` for `colcon`, `git`, and targeted scans
- `references/mappings/*.md`
- `references/api/*.md`
- `docs/ros1-migration/artifacts/plan-meta.json`
- `scripts/scan_ros1.py` *(M2, optional refresh path)*

## Outputs

- Migrated ROS2 source tree
- Updated `<target_project>/docs/ros1-migration/artifacts/plan-meta.json`

## Exit criteria

- Every executed task has `status == "completed"` in `plan-meta.json`.
- No undeclared surface change was introduced.
- Task-local verification commands from the plan have been run.
- The working tree matches the intended scope of the executed tasks.
