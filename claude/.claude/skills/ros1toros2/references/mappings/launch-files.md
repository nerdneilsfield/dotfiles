# launch-files

## Scope

Maps ROS1 XML launch patterns to ROS2 Jazzy launch patterns, with Python launch files as the default target shape. Covers node declarations, includes, substitutions, parameters, remaps, and topology-visible launch behavior. It does not cover runtime node API migration; see the client-library mappings for that.

## Symbol Mapping Table

| ROS1 | ROS2 (Jazzy) | Notes / Pitfalls | API ref |
|---|---|---|---|
| `<launch>` | Python launch module returning `LaunchDescription([...])` | ROS2 also supports XML, but Python is the recommended migration target for flexibility | `api/docs-ros-org-jazzy-how-to-guides-launch-files.md` |
| `<node pkg="p" type="n" name="x">` | `Node(package='p', executable='n', name='x')` | `type` becomes `executable` | `api/docs-ros-org-jazzy-tutorials-launch-creating-launch-files.md` |
| `<include file="...">` | `IncludeLaunchDescription(...)` | Use a concrete launch description source | `api/docs-ros-org-jazzy-tutorials-launch-creating-launch-files.md` |
| `<arg name="x" default="y">` | `DeclareLaunchArgument('x', default_value='y')` | Arguments stay part of launch-surface behavior | `api/docs-ros-org-jazzy-tutorials-launch-using-substitutions.md` |
| `$(arg foo)` | `LaunchConfiguration('foo')` | Substitution syntax changes | `api/docs-ros-org-jazzy-tutorials-launch-using-substitutions.md` |
| `$(find pkg)` | `FindPackageShare('pkg')` or `PathJoinSubstitution(...)` | Prefer ROS2 substitution helpers | `api/docs-ros-org-jazzy-tutorials-launch-using-substitutions.md` |
| `<param name="k" value="v">` | `parameters=[{'k': v}]` | Launch migration and parameter migration interact | `api/docs-ros-org-jazzy-how-to-guides-launch-files.md` |
| `<rosparam file="config.yaml">` | `parameters=['config.yaml']` or explicit path substitution | Keep node parameter ownership explicit | `api/docs-ros-org-jazzy-how-to-guides-launch-files.md` |
| `<remap from="/a" to="/b">` | `remappings=[('/a', '/b')]` | Remaps are surface-visible and usually must stay identical | `api/docs-ros-org-jazzy-how-to-guides-launch-files.md` |
| `<group ns="robot1">` | namespacing via `GroupAction`, `PushRosNamespace`, or namespaced `Node` actions | Namespace behavior is part of the runtime surface | `api/docs-ros-org-jazzy-tutorials-launch-creating-launch-files.md` |

## Covered Symbols

`<launch>`, `<node`, `<include`, `<arg`, `$(arg`, `$(find`, `$(eval`, `<param`, `<rosparam`, `<remap`, `<group ns=...>`

## Structural Translation Patterns

- **Simple single-node launch**: one Python file with a `LaunchDescription` and one `Node(...)` action.
- **Composable launch**: use `IncludeLaunchDescription(...)` for nested launch trees and keep argument forwarding explicit.
- **Namespaced launch**: use `GroupAction` and namespace helpers when the ROS1 XML grouped multiple nodes under a namespace.
- **Config-driven launch**: move ROS1 `<rosparam file=...>` usage into explicit `parameters=[...]` lists or substitutions in the Python launch file.

## Surface-Preserving Rules

Launch files define visible runtime topology. Preserve node names, namespaces, remaps, launched executables, parameter values, and included launch composition unless the migration plan explicitly declares a surface change in `artifacts/plan-meta.json`. The launch filename itself may change from `foo.launch` to `foo.launch.py` without counting as a surface change.

## Edge Cases

- ROS1 XML can hide implicit namespace or substitution behavior that must be made explicit in ROS2 Python launch code.
- Python launch files are more expressive, which makes it easy to accidentally add extra behavior not present in ROS1.
- `$(eval ...)` often needs manual re-expression with launch substitutions or Python logic.
- Parameter-file paths should be built from package-share helpers rather than hard-coded relative paths.

## Banned Symbols (Verification Hooks)

`<launch>`, `<node `, `<include `, `<rosparam`, `$(arg `, `$(find `, `$(eval `, `<remap `
