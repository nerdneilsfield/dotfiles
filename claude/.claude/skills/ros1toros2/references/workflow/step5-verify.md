# Step 5 - Verify

## Goal

Confirm that the migrated ROS2 workspace preserves the intended interface surface, contains no ROS1 residuals, and builds cleanly enough to support handoff. In M1 this is a manual verification path; in M2 the same logic becomes the canonical `scripts/verify_ros2.py` path.

## Inputs

- `docs/ros1-migration/01-inventory.md`
- `docs/ros1-migration/02-design.md`
- `docs/ros1-migration/03-plan.md`
- `docs/ros1-migration/artifacts/plan-meta.json`
- `references/grep-patterns.md`
- `references/mappings/*.md`

## Agent activities

1. Run residual scans using `references/grep-patterns.md` and the mapping docs' banned symbols.
2. Compare the migrated interface surface against the original inventory:
   - topics
   - services
   - actions
   - parameters
   - TF frames
3. For any missing or changed surface item, check whether `plan-meta.json.surface_changes[]` declares it. Undeclared changes are failures.
4. Confirm every task in `plan-meta.json.tasks[]` is marked `completed`.
5. Run `colcon build` for the migrated packages.
6. Run `colcon test` and inspect lint-related results where available.
7. Write `05-verify-report.md` with:
   - PASS / FAIL summary
   - residual findings
   - surface-diff findings
   - build and lint results
   - recommended next actions if the migration is not yet clean

## Tools available

- `Read`, `Grep`, `Glob`
- `Bash` for `rg`, `colcon build`, `colcon test`, `jq`, and small audits
- `references/grep-patterns.md`
- `references/mappings/*.md`
- `docs/ros1-migration/artifacts/plan-meta.json`
- `scripts/verify_ros2.py` *(M2 canonical path)*

## Outputs

- `<target_project>/docs/ros1-migration/05-verify-report.md`
- `<target_project>/docs/ros1-migration/artifacts/verify-report.json` *(M2)*

## Exit criteria

- Residual ROS1 symbols are zero, or every remaining hit is explicitly explained as a blocker.
- Every surface mismatch is either declared in `plan-meta.json` or reported as a failure.
- Every planned task is complete.
- Build and lint outcomes are recorded with enough detail for the next iteration.
- The report is actionable for either handoff or another fix cycle.
