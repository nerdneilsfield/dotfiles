# Step 2 - Design

## Goal

Turn the ROS1 inventory into explicit ROS2 Jazzy migration decisions and save them in `docs/ros1-migration/02-design.md`. The design explains what changes structurally, what must remain surface-compatible, and what still needs clarification.

## Inputs

- `docs/ros1-migration/01-inventory.md`
- `docs/ros1-migration/artifacts/inventory.json` *(optional)*
- `references/mappings/*.md`
- `references/api/*.md`
- `templates/design.md.tmpl`

## Agent activities

1. Walk the inventory package by package and classify each area against the matching mapping doc:
   - `package.xml`
   - build system
   - client library
   - launch files
   - parameters
   - QoS
   - TF
   - actions
   - nodelets
   - custom interfaces
2. Choose a structural translation pattern for each package, such as free functions plus `NodeHandle` becoming a `rclcpp::Node` subclass, or nodelets becoming components.
3. Declare the interface surface the migration must preserve by default:
   - topic names and message types
   - service names and service types
   - action names and action types
   - parameter names and semantics
   - TF frame names and publisher/listener responsibilities
4. Declare intentional surface changes only when they are truly visible to downstream nodes, such as:
   - topic or service renames
   - genuine wire-type changes
   - QoS changes that affect external subscribers
   - removed debug endpoints
5. Treat notation normalization as non-surface when the wire-level contract is unchanged, for example `pkg/Foo` versus `pkg/msg/Foo`.
6. If a symbol or idiom is not covered cleanly by the mappings, add it to `Open questions` and call out the missing coverage.
7. Summarize cross-package concerns such as dependency ordering, shared interfaces, and likely migration hotspots.

## Tools available

- `Read`, `Grep`, `Glob`
- `references/mappings/*.md`
- `references/api/*.md`
- `templates/design.md.tmpl`
- `Bash` for light cross-checks

## Outputs

- `<target_project>/docs/ros1-migration/02-design.md`

## Exit criteria

- Every in-scope package has a per-area ROS1 state to ROS2 target decision.
- Structural translation choices are explicit enough for planning.
- Surface-preserving commitments are stated clearly.
- Every intentional surface change is justified and ready to be mirrored into `artifacts/plan-meta.json` during Step 3.
- Open questions are visible and actionable.
