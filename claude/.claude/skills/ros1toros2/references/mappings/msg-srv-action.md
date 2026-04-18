# msg-srv-action

## Scope

Maps ROS1 message, service, and action definition workflows to ROS2 Jazzy `rosidl` workflows. Covers interface package generation, consumer-side include/import changes, and the distinction between notation-only path changes and genuine wire-type changes.

## Symbol Mapping Table

| ROS1 | ROS2 (Jazzy) | Notes / Pitfalls | API ref |
|---|---|---|---|
| `add_message_files(...)` | `rosidl_generate_interfaces(${PROJECT_NAME} ...)` | ROS2 folds message generation under rosidl | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| `add_service_files(...)` | `rosidl_generate_interfaces(${PROJECT_NAME} ...)` | Same consolidated generator call | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| `add_action_files(...)` | `rosidl_generate_interfaces(${PROJECT_NAME} ...)` | Actions become first-class rosidl interfaces | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| `generate_messages(...)` | `rosidl_generate_interfaces(...)` | Remove old catkin generator glue | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| `message_generation` | `rosidl_default_generators` | Build dependency | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| `message_runtime` | `rosidl_default_runtime` | Runtime dependency | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| C++ include `<pkg/Foo.h>` | C++ include `<pkg/msg/foo.hpp>` | Path changes, wire type normally does not | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| ROS1 type notation `pkg/Foo` | ROS2 type notation `pkg/msg/Foo` | This is notation normalization, not automatically a surface change | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| ROS1 service notation `pkg/DoThing` | ROS2 service notation `pkg/srv/DoThing` | Consumer code changes, wire semantics normally stay aligned | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| ROS1 actionlib message glue | ROS2 native action interfaces | Runtime API change is handled in `actionlib.md` | `api/docs-ros-org-jazzy-tutorials-writing-an-action-server-and-client-cpp.md` |

## Covered Symbols

`add_message_files`, `add_service_files`, `add_action_files`, `generate_messages`, `message_generation`, `message_runtime`, `std_msgs/Header.seq`, ROS1 include paths like `<pkg/Foo.h>`, ROS1 type notation like `pkg/Foo`, ROS1 service notation like `pkg/DoThing`

## Structural Translation Patterns

- **Interface-defining package**: keep `.msg`, `.srv`, and `.action` files under dedicated directories and generate them with one `rosidl_generate_interfaces(...)` call.
- **Pure consumer package**: remove catkin interface-generation macros, depend on the producer package's runtime artifacts, and update include/import forms only.
- **Action-heavy package**: treat `.action` files as interface definitions here, then migrate action client/server runtime code via `actionlib.md`.
- **Shared interface package**: isolate interfaces in one package and let consumer packages depend on it explicitly to avoid duplicated generation logic.

## Surface-Preserving Rules

Message, service, and action names should remain wire-compatible unless the migration plan explicitly declares a real schema or endpoint change. Path normalization such as `pkg/Foo` versus `pkg/msg/Foo` or `<pkg/Foo.h>` versus `<pkg/msg/foo.hpp>` is not a surface change by itself. Declare `type_changed` only when the actual message or service contract seen by downstream nodes changes.

## Edge Cases

- `std_msgs/Header.seq` was dropped in ROS2; code that reads or writes it needs manual migration.
- Action definitions themselves are similar, but action runtime APIs differ substantially; use `actionlib.md` for client/server behavior.
- Some packages rely on generated headers from catkin macros living in include paths that disappear after migration; consumers must be updated together.
- `builtin_interfaces/Time` and `builtin_interfaces/Duration` may surface through generated code even when the original field names stay familiar.

## Banned Symbols (Verification Hooks)

`add_message_files(`, `add_service_files(`, `add_action_files(`, `generate_messages(`, `message_generation`, `message_runtime`, `Header.seq`, `#include <.*\\.h>` for generated ROS1 message headers
