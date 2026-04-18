---
name: ros1toros2
description: Use when porting ROS1 packages (roscpp, rospy, msg/srv/action, launch, CMakeLists.txt, package.xml) to ROS2 Jazzy, or reviewing mixed ROS1/ROS2 code for API drift.
---

# ros1toros2

## What this skill does

Guides the host agent through migrating a ROS1 (Noetic / Melodic / Kinetic) package or workspace to ROS2 **Jazzy** via a strict 5-step workflow. The skill ships knowledge (mappings, API snapshots), scaffolding (templates), and (from M2 onward) a small toolbox (scripts for comprehensive scanning and post-migration verification).

## Core principle

**Skill augments the agent; does not replace it.** Every document, decision, and edit is authored by the agent. Scripts (when they arrive in M2) sit in the agent's toolbox alongside Read / Grep / Edit / Bash — tools the agent reaches for when comprehensive AST coverage or bundled verification is more efficient than grep alone. There is no fixed "pipeline"; the agent picks per situation.

## The 5-step workflow

All outputs land under `<target_project>/docs/ros1-migration/`.

1. **Inventory** -> `01-inventory.md` (+ `artifacts/inventory.json` once M2 ships). Agent enumerates packages, ROS1 API usage, interface surface. See `references/workflow/step1-inventory.md`.
2. **Design** -> `02-design.md`. Agent classifies each inventory entry against `references/mappings/`, declares structural and surface translations. See `references/workflow/step2-design.md`.
3. **Plan** -> `03-plan.md` (+ `artifacts/plan-meta.json`). Agent breaks the design into ordered tasks respecting the package dependency graph, then dispatches a reviewer (or runs the self-review checklist). See `references/workflow/step3-plan.md`.
4. **Execute** -> migrated ROS2 source. Agent edits source, package.xml, CMakeLists.txt, launch files, etc., per plan and mappings. See `references/workflow/step4-execute.md`.
5. **Verify** -> `05-verify-report.md` (+ `artifacts/verify-report.json` once M2 ships). Agent runs residual scan, interface-surface diff, `colcon build`, `ament_lint`, then writes the report with diagnosis. See `references/workflow/step5-verify.md`.

## Toolbox the agent draws from

| Tool | Provided by | Reach for it when |
|---|---|---|
| `Read`, `Grep`, `Glob` | host agent | Default inspection, targeted lookups, small files |
| `Edit`, `Write` | host agent | Apply migration edits, author markdown |
| `Bash` | host agent | `colcon`, `git`, manual scans, `ripgrep` with `references/grep-patterns.md` |
| `references/mappings/*.md` | this skill | ROS1->ROS2 symbol translations, structural patterns, surface-preserving rules |
| `references/api/*.md` | this skill | Baked Jazzy API / concept / design snapshots |
| `references/grep-patterns.md` | this skill | Canonical ripgrep patterns for ROS1 residuals |
| `templates/*.tmpl` | this skill | Scaffolding for each output document |
| `scripts/scan_ros1.py` *(M2)* | this skill | Comprehensive AST-level extraction when grep alone misses macros / templates / multi-line |
| `scripts/verify_ros2.py` *(M2)* | this skill | Bundled residual scan + surface diff + build + lint |

## Functional correspondence, not structural

A ROS1 class does **not** need to become a ROS2 class. What the verify step enforces is **interface-surface preservation**: topics, services, actions, params, types, tf frames. Internal structure (class layout, file organization, helpers) may change freely unless it affects the surface. Any intentional surface change (rename, type change, QoS change, removal) must be declared in `artifacts/plan-meta.json` under `surface_changes`.

## Out of scope

- `ros1_bridge`-based incremental coexistence (this skill assumes full cutover; see [ROS 2 bridge docs](https://docs.ros.org/en/jazzy/How-To-Guides/Using-ros1_bridge-Jammy-upstream.html) if you need coexistence)
- Runtime smoke tests of migrated nodes (verification stops at build + lint)
- Msg/srv/action field-level migration (file-level tracking only)

## Quick start for the agent

1. Read `references/workflow/step1-inventory.md`.
2. Use Read/Grep/Glob (plus `scan_ros1.py` once M2 ships) to produce `01-inventory.md` under the target project's `docs/ros1-migration/`.
3. Proceed through steps 2-5, consulting the workflow and mapping docs at each step.

See `README.md` for dependencies, manual script invocation, and troubleshooting.
