# tf2

## Scope

Maps ROS1 TF usage to ROS2 Jazzy `tf2_ros` usage. Covers broadcasters, listeners, buffer/listener ownership, stamped transform helpers, and the runtime surface implications of frame naming.

## Symbol Mapping Table

| ROS1 | ROS2 (Jazzy) | Notes / Pitfalls | API ref |
|---|---|---|---|
| `tf::TransformBroadcaster` | `tf2_ros::TransformBroadcaster` | Broadcaster type changes but frame names should not | `api/docs-ros-org-jazzy-tutorials-tf2.md` |
| `tf::TransformListener` | `tf2_ros::TransformListener` attached to a `tf2_ros::Buffer` | Listener ownership is explicit in ROS2 | `api/docs-ros-org-jazzy-tutorials-tf2.md` |
| `tf::StampedTransform` | `geometry_msgs::msg::TransformStamped` | Message type moves into geometry messages | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| `tf::Quaternion` helpers | `tf2::Quaternion` helpers plus conversion utilities | Math helper namespace changes | `api/docs-ros-org-jazzy-tutorials-tf2.md` |
| `/tf` and `/tf_static` assumptions | same topics, but ROS2 broadcaster/listener APIs | Surface topics normally stay identical | `api/docs-ros-org-jazzy-tutorials-tf2.md` |
| latched static transform habits | `StaticTransformBroadcaster` | ROS2 uses a dedicated static broadcaster path | `api/docs-ros-org-jazzy-tutorials-tf2.md` |
| `waitForTransform` style logic | buffer lookup / timeout APIs | Blocking semantics often need redesign | `api/docs-ros-org-jazzy-tutorials-tf2.md` |

## Covered Symbols

`tf::TransformBroadcaster`, `tf::TransformListener`, `tf::StampedTransform`, `tf::Quaternion`, `/tf`, `/tf_static`, `waitForTransform`, `lookupTransform`

## Structural Translation Patterns

- **Simple broadcaster node**: replace the ROS1 broadcaster object with a `tf2_ros::TransformBroadcaster` owned by the ROS2 node and keep publishing the same frame ids.
- **Listener-driven node**: create a `tf2_ros::Buffer` and attach a `tf2_ros::TransformListener` to it during node setup.
- **Static frame publisher**: switch to `StaticTransformBroadcaster` and keep the same static frame contract.
- **Math-heavy transform code**: migrate math helpers to `tf2` utilities while keeping stamped message payloads in ROS2 message types.

## Surface-Preserving Rules

Frame ids, parent-child relationships, and the existence of `/tf` versus `/tf_static` are part of the interface surface. Class replacements and helper-namespace changes are structural. Any rename of a frame id or shift between dynamic and static publishing must be declared in `artifacts/plan-meta.json`.

## Edge Cases

- ROS2 listener setup is easy to get wrong if the buffer/listener lifetime is shorter than the node lifetime.
- Static transforms should be migrated intentionally rather than left on dynamic broadcasters out of convenience.
- Timeout and blocking behavior around transform lookup often needs redesign instead of direct API substitution.
- Stamped transform message types are usually wire-compatible as long as frame ids and timestamps preserve meaning.

## Banned Symbols (Verification Hooks)

`tf::TransformBroadcaster`, `tf::TransformListener`, `tf::StampedTransform`, `tf::Quaternion`, `waitForTransform`, `lookupTransform(` with ROS1 `tf::` types
