# nodelets

## Scope

Maps ROS1 nodelet patterns to ROS2 Jazzy composition/component patterns. Covers plugin registration, in-process composition, and the difference between a nodelet class and a component-enabled `rclcpp::Node`.

## Symbol Mapping Table

| ROS1 | ROS2 (Jazzy) | Notes / Pitfalls | API ref |
|---|---|---|---|
| `nodelet::Nodelet` | component-friendly `rclcpp::Node` subclass | The runtime concept becomes composition rather than nodelets | `api/docs-ros-org-jazzy-tutorials-composition.md` |
| nodelet plugin XML | component registration macro and composition setup | Registration mechanism changes completely | `api/docs-ros-org-jazzy-tutorials-composition.md` |
| nodelet manager process | component container | In-process loading concept remains, implementation differs | `api/docs-ros-org-jazzy-tutorials-composition.md` |
| `PLUGINLIB_EXPORT_CLASS` for nodelets | `RCLCPP_COMPONENTS_REGISTER_NODE(...)` | ROS2 component registration is explicit | `api/docs-ros-org-jazzy-tutorials-composition.md` |
| shared process for zero-copy-ish pipelines | composition with ROS2 executors and intra-process comms where appropriate | Performance goals may survive, but setup changes | `api/docs-ros-org-jazzy-tutorials-composition.md` |
| nodelet init hook | node constructor / setup methods | Initialization lifetime changes | `api/docs-ros-org-jazzy-tutorials-composition.md` |
| nodelet name + remap surface | component node name + launch/container wiring | Runtime topology should remain stable | `api/docs-ros-org-jazzy-tutorials-composition.md` |

## Covered Symbols

`nodelet::Nodelet`, nodelet plugin XML, nodelet manager, `PLUGINLIB_EXPORT_CLASS`, nodelet init hooks, `getNodeHandle`, `getPrivateNodeHandle`

## Structural Translation Patterns

- **Standalone nodelet**: convert to a `rclcpp::Node` subclass that can run as either a normal node or a component.
- **Managed nodelet family**: migrate a set of cooperating nodelets into one or more ROS2 components loaded into a component container.
- **Performance-sensitive pipeline**: preserve in-process composition goals through ROS2 component containers and, where useful, intra-process communication settings.
- **Pluginlib-backed nodelet package**: replace nodelet registration artifacts with ROS2 component registration and launch/container wiring.

## Surface-Preserving Rules

The runtime surface is the set of published/subscribed topics, services, actions, parameters, frame ids, and externally visible node/container names. Replacing nodelets with components is structural. Renaming nodes, changing how many runtime processes exist in a way users observe, or altering endpoint names requires a declaration in `artifacts/plan-meta.json`.

## Edge Cases

- Some nodelet packages mix pluginlib concerns with ordinary node code and should be split conceptually before migration.
- In-process performance goals may tempt over-complicated ROS2 designs; keep the migration honest to the actual runtime surface needed.
- Component containers and launch wiring should preserve the topology expected by downstream launch users.
- Nodelet private handle usage often migrates into declared parameters and explicit namespace handling.

## Banned Symbols (Verification Hooks)

`nodelet::Nodelet`, `nodelet manager`, `PLUGINLIB_EXPORT_CLASS`, `getNodeHandle(`, `getPrivateNodeHandle(`
