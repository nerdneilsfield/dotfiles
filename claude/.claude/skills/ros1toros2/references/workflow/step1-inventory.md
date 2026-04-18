# Step 1 - Inventory

## Goal

Produce a reliable ROS1 snapshot for the target workspace and save it as `docs/ros1-migration/01-inventory.md`. In M1 the inventory is agent-authored from native inspection tools; in M2 the agent may also attach `artifacts/inventory.json` from `scripts/scan_ros1.py`.

## Inputs

- Target ROS1 workspace path
- `SKILL.md`
- `references/mappings/*.md`
- `references/grep-patterns.md`
- Native inspection tools (`Read`, `Grep`, `Glob`, `Bash`)

## Agent activities

1. Enumerate packages by finding each `package.xml`.
2. For each package, inspect `package.xml`, `CMakeLists.txt`, Python entrypoints, launch XML, and any `msg/`, `srv/`, or `action/` files.
3. Record ROS1 API usage such as `roscpp`, `rospy`, `actionlib`, `tf`, `dynamic_reconfigure`, `catkin`, `rosparam`, and launch constructs.
4. Derive the package's interface surface:
   - published and subscribed topics
   - services provided and called
   - actions provided and called
   - parameters read and written
   - TF frames published and consumed
5. Note risky areas that can affect migration design:
   - nodelets
   - callback threading assumptions
   - implicit QoS expectations for sensor topics
   - custom interfaces shared across packages
6. If the host has M2 scripts available, the agent may run `scripts/scan_ros1.py` to accelerate broad extraction, but it still writes the narrative inventory itself.
7. Record any uncertainty as an explicit open question instead of guessing.

## Tools available

- `Read`, `Grep`, `Glob`
- `Bash` for `find`, `rg`, and small summaries
- `references/grep-patterns.md`
- `references/mappings/*.md` for coverage checks
- `templates/inventory.md.tmpl`
- `scripts/scan_ros1.py` *(M2, optional)*

## Outputs

- `<target_project>/docs/ros1-migration/01-inventory.md`
- `<target_project>/docs/ros1-migration/artifacts/inventory.json` *(M2, when script path is used)*

## Exit criteria

- Every in-scope package is listed.
- Every package has a concise summary of build type, client library, launch/interface files, and key ROS1 symbols.
- The aggregate interface surface is explicit enough for Step 2 design work.
- Cross-package dependencies and shared custom interfaces are called out.
- Unknown or custom symbols are listed as open questions instead of being silently classified.
- The document states whether the inventory came from manual inspection only or from manual inspection plus `scan_ros1.py`.
