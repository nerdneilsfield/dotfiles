# Step 3 - Plan

## Goal

Convert the design into an ordered, reviewable execution plan and produce both:

- `docs/ros1-migration/03-plan.md` for humans
- `docs/ros1-migration/artifacts/plan-meta.json` for machine checks

## Inputs

- `docs/ros1-migration/02-design.md`
- `docs/ros1-migration/01-inventory.md`
- `docs/ros1-migration/artifacts/inventory.json` *(optional)*
- `references/mappings/*.md`
- `templates/plan.md.tmpl`
- `templates/plan-meta.json.tmpl`

## Agent activities

1. Split work into topologically ordered tasks that respect package dependencies.
2. For each task, specify:
   - packages in scope
   - prerequisite tasks
   - mapping sections to consult
   - concrete edit steps
   - which parts of the interface surface are preserved
   - any intentional surface changes
3. Author `03-plan.md` as readable prose for a future executor or reviewer.
4. Author `artifacts/plan-meta.json` as the machine contract:
   - `tasks[]` with ids, packages, dependencies, mapping refs, and status
   - `surface_changes[]` with any wire-level changes that Step 5 should tolerate
5. Do not encode routine ROS1-to-ROS2 notation normalization as `type_changed`.
6. Review the plan before execution:
   - use a subagent or reviewer if the host provides one
   - otherwise run the self-review checklist in the same session
7. Fix plan gaps before moving on to execution.

## Tools available

- `Read`, `Grep`, `Glob`
- `references/mappings/*.md`
- `templates/plan.md.tmpl`
- `templates/plan-meta.json.tmpl`
- `Bash` for counts and sanity checks
- Host-provided subagent or review mechanism when available

## Outputs

- `<target_project>/docs/ros1-migration/03-plan.md`
- `<target_project>/docs/ros1-migration/artifacts/plan-meta.json`

## Exit criteria

- `03-plan.md` covers every package and subsystem in the design.
- `plan-meta.json` is valid JSON.
- Every task in `03-plan.md` has a corresponding `tasks[]` entry.
- Every intentional surface change in the design has a corresponding `surface_changes[]` entry.
- The review path used, reviewer or self-review, is recorded.

## Reviewer Prompt Template

Use this prompt when the host environment provides a subagent, reviewer, or fresh-context helper:

```text
Review this ROS1 -> ROS2 Jazzy migration plan for spec compliance only.

Inputs:
- docs/ros1-migration/01-inventory.md
- docs/ros1-migration/02-design.md
- docs/ros1-migration/03-plan.md
- docs/ros1-migration/artifacts/plan-meta.json
- references/mappings/

Check:
1. Every package and subsystem in the design is covered by at least one task.
2. Task order respects dependency edges from the inventory.
3. Each task cites the mapping sections it depends on.
4. Every intentional surface change appears in plan-meta.json.
5. No routine notation normalization is mis-declared as a surface change.

Return:
- PASS or FAIL
- Missing coverage
- Ordering problems
- Surface-change mismatches
- Any task that is too vague to execute safely
```

## Self-Review Checklist

- [ ] Does every package in the inventory appear in at least one task?
- [ ] Does every risky area from the design have an owning task?
- [ ] Does each task reference the mapping docs it depends on?
- [ ] Does `plan-meta.json.tasks[]` match the task list in `03-plan.md`?
- [ ] Does `plan-meta.json.surface_changes[]` include every intentional wire-level change from the design?
- [ ] Did I avoid declaring notation-only ROS2 path differences as `type_changed`?
- [ ] Would another agent know what to edit first without guessing?
