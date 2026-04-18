# References Index

## workflow/
Per-step guides the agent reads when executing each of the 5 migration steps.

- [step1-inventory.md](workflow/step1-inventory.md) - Produce `01-inventory.md`
- [step2-design.md](workflow/step2-design.md) - Produce `02-design.md`
- [step3-plan.md](workflow/step3-plan.md) - Produce `03-plan.md` + `artifacts/plan-meta.json`; includes Reviewer Prompt + Self-Review Checklist
- [step4-execute.md](workflow/step4-execute.md) - Execute edits; includes safe-editing guidance
- [step5-verify.md](workflow/step5-verify.md) - Produce `05-verify-report.md`

## mappings/
One file per ROS1->ROS2 subsystem. Each contains Symbol Mapping Table, Covered Symbols, Structural Translation Patterns, Surface-Preserving Rules, Edge Cases, and Banned Symbols.

- [package-xml.md](mappings/package-xml.md) - catkin -> ament format 3
- [cmakelists.md](mappings/cmakelists.md) - catkin CMake -> ament_cmake
- [roscpp-to-rclcpp.md](mappings/roscpp-to-rclcpp.md) - C++ client library
- [rospy-to-rclpy.md](mappings/rospy-to-rclpy.md) - Python client library
- [msg-srv-action.md](mappings/msg-srv-action.md) - interface definitions
- [launch-files.md](mappings/launch-files.md) - XML launch -> Python launch
- [parameters.md](mappings/parameters.md) - rosparam -> declared node parameters
- [qos.md](mappings/qos.md) - implicit reliable -> explicit QoS profiles
- [tf2.md](mappings/tf2.md) - tf/tf2 -> tf2_ros
- [actionlib.md](mappings/actionlib.md) - actionlib -> rclcpp_action / rclpy.action
- [nodelets.md](mappings/nodelets.md) - nodelets -> rclcpp components

## api/
Firecrawl-baked Jazzy documentation snapshots. Every URL referenced by any mapping is present here. See `_manifest.md` for the full list.

## grep-patterns.md
Ripgrep patterns for ROS1 residual scanning. Consumed by Step 5 and (from M2) by `verify_ros2.py`.

## _external/
Archived third-party migration guides. Reference-only; mappings were authored independently.
