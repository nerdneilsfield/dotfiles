# parameters

## Scope

Maps ROS1 parameter-server usage to ROS2 Jazzy declared-parameter usage. Covers reads, writes, defaults, callbacks, and the runtime consequences of undeclared-parameter assumptions.

## Symbol Mapping Table

| ROS1 | ROS2 (Jazzy) | Notes / Pitfalls | API ref |
|---|---|---|---|
| `ros::NodeHandle::getParam` | `node->get_parameter(...)` after declaration | Parameters must usually be declared first | `api/docs-ros-org-jazzy-concepts-about-parameters.md` |
| `ros::NodeHandle::param` | `declare_parameter(name, default)` plus `get_parameter` | Declaration folds defaulting into the node | `api/docs-ros-org-jazzy-tutorials-using-parameters-cpp.md` |
| `ros::NodeHandle::setParam` | `set_parameter` / `set_parameters` | Runtime mutation semantics differ | `api/docs-ros-org-jazzy-concepts-about-parameters.md` |
| `rospy.get_param` | `declare_parameter` plus `get_parameter(...).value` | Python nodes must also declare by default | `api/docs-ros-org-jazzy-tutorials-using-parameters-python.md` |
| `rospy.set_param` | `set_parameters` or launch/config files | Prefer explicit node-owned params over a shared server | `api/docs-ros-org-jazzy-concepts-about-parameters.md` |
| private namespace `~foo` parameter convention | node-local parameter names | Namespace handling changes with node ownership | `api/docs-ros-org-jazzy-concepts-about-parameters.md` |
| `dynamic_reconfigure` | parameter callbacks / validation logic | No direct drop-in replacement | `api/docs-ros-org-jazzy-how-to-guides-using-callback-groups.md` |
| YAML loaded through `<rosparam file=...>` | node parameter files or launch `parameters=[...]` | Launch and parameter migration often move together | `api/docs-ros-org-jazzy-how-to-guides-launch-files.md` |
| global parameter server assumptions | per-node parameter ownership | Do not assume another node can own your params | `api/docs-ros-org-jazzy-concepts-about-parameters.md` |

## Covered Symbols

`getParam`, `param`, `setParam`, `hasParam`, `deleteParam`, `searchParam`, `rospy.get_param`, `rospy.set_param`, `dynamic_reconfigure`, `<rosparam`, `~private` parameters

## Structural Translation Patterns

- **Static defaults**: declare all known parameters at node startup with defaults and document them in launch/config files.
- **Validated runtime updates**: replace `dynamic_reconfigure` with parameter callbacks and explicit validation or rejection logic.
- **Launch-driven configuration**: shift parameter materialization into ROS2 launch and parameter files, while keeping node-side declarations authoritative.
- **Cross-node shared config**: duplicate only the truly shared settings and make ownership explicit instead of depending on a process-global parameter server.

## Surface-Preserving Rules

Parameter names and externally visible semantics should remain stable unless the plan declares a change. A node moving from server-side lookup to local declaration is structural, not a surface change, as long as downstream users still set the same parameter names and get the same meaning. Rename, removal, or semantic change of a parameter must be declared in `artifacts/plan-meta.json`.

## Edge Cases

- Undeclared parameter access that "worked" in ROS1 often fails in ROS2 unless the node explicitly opts into undeclared behavior, which is usually not the preferred long-term path.
- Parameter callbacks run inside executor context, so long-running validation logic can interfere with responsiveness.
- Some ROS1 code uses `searchParam` or global namespaces to discover configuration from elsewhere in the graph; ROS2 generally wants explicit ownership instead.
- Parameter files and launch files often need to be migrated together so defaults and overrides stay aligned.

## Banned Symbols (Verification Hooks)

`getParam(`, `setParam(`, `hasParam(`, `deleteParam(`, `searchParam(`, `rospy.get_param`, `rospy.set_param`, `dynamic_reconfigure`, `<rosparam`
