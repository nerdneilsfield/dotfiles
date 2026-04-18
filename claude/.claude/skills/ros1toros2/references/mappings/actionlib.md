# actionlib

## Scope

Maps ROS1 `actionlib` usage to ROS2 Jazzy action usage for both C++ and Python nodes. Covers server/client setup, goal handling, feedback/result reporting, and the migration split between interface definitions and runtime APIs.

## Symbol Mapping Table

| ROS1 | ROS2 (Jazzy) | Notes / Pitfalls | API ref |
|---|---|---|---|
| `actionlib::SimpleActionServer<Action>` | `rclcpp_action::Server<Action>` | Callback model becomes more explicit | `api/docs-ros2-org-api-rclcpp_action-classrclcpp__action_1_1_server.md` |
| `actionlib::SimpleActionClient<Action>` | `rclcpp_action::Client<Action>` | Async flow is first-class | `api/docs-ros2-org-api-rclcpp_action-classrclcpp__action_1_1_client.md` |
| Python `actionlib.SimpleActionServer` | `rclpy.action.ActionServer` | Python server API follows ROS2 action framework | `api/docs-ros-org-jazzy-tutorials-writing-an-action-server-and-client-python.md` |
| Python `actionlib.SimpleActionClient` | `rclpy.action.ActionClient` | Goal/result handling is async | `api/docs-ros-org-jazzy-tutorials-writing-an-action-server-and-client-python.md` |
| `registerGoalCallback` / `registerPreemptCallback` | goal/cancel/accepted callbacks | ROS2 splits lifecycle callbacks explicitly | `api/docs-ros-org-jazzy-tutorials-writing-an-action-server-and-client-cpp.md` |
| `setSucceeded(...)` | succeed goal handle and return result | Result completion is tied to goal handles | `api/docs-ros-org-jazzy-tutorials-writing-an-action-server-and-client-cpp.md` |
| `setAborted(...)` | abort goal handle and return result | Same goal-handle model | `api/docs-ros-org-jazzy-tutorials-writing-an-action-server-and-client-cpp.md` |
| `setPreempted(...)` | cancel / abort flow depending semantics | Preemption is not a one-word drop-in concept | `api/docs-ros-org-jazzy-tutorials-writing-an-action-server-and-client-cpp.md` |
| `publishFeedback(...)` | publish feedback through goal handle | Feedback path is tied to the executing goal | `api/docs-ros2-org-api-rclcpp_action-classrclcpp__action_1_1_server.md` |
| action message glue in ROS1 | native ROS2 action interface package | Interface definition itself is handled in `msg-srv-action.md` | `api/docs-ros-org-jazzy-tutorials-actions.md` |

## Covered Symbols

`actionlib::SimpleActionServer`, `actionlib::SimpleActionClient`, `registerGoalCallback`, `registerPreemptCallback`, `setSucceeded`, `setAborted`, `setPreempted`, `publishFeedback`, Python `actionlib.SimpleActionServer`, Python `actionlib.SimpleActionClient`

## Structural Translation Patterns

- **Single-goal simple server**: migrate to a ROS2 action server with explicit goal, cancel, and accepted handlers.
- **Polling client**: replace blocking wait patterns with async goal handles and explicit result futures where possible.
- **Python action server/client**: move to `rclpy.action` APIs and keep the action name stable unless intentionally changed.
- **Interface plus runtime split**: treat `.action` files as interface concerns in `msg-srv-action.md`, then migrate server/client code here.

## Surface-Preserving Rules

Action names and actual action types should stay stable unless the plan declares a change. Server/client class replacement is structural only. Changing the action name, replacing one action interface with another, or dropping feedback/result behavior in a way external clients observe must be declared in `artifacts/plan-meta.json`.

## Edge Cases

- ROS1 preemption logic often maps imperfectly to ROS2 cancel handling and may need semantic decisions rather than blind translation.
- Action servers that assumed one simple callback may need to be refactored into multiple explicit handlers.
- Mixed C++/Python action ecosystems should keep the action interface package stable while runtime APIs change independently.
- Long-running action execution may need executor-awareness if feedback and cancel handling must stay responsive.

## Banned Symbols (Verification Hooks)

`actionlib::SimpleActionServer`, `actionlib::SimpleActionClient`, `registerGoalCallback`, `registerPreemptCallback`, `setSucceeded`, `setAborted`, `setPreempted`, `publishFeedback`, `import actionlib`
