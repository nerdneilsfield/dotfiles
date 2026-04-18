# roscpp-to-rclcpp

## Scope

Maps common ROS1 `roscpp` node patterns to ROS2 Jazzy `rclcpp` patterns. Covers node lifecycle, publishers, subscriptions, services, clients, timers, parameters, logging, spinning, callback groups, and executor-related concurrency assumptions.

## Symbol Mapping Table

| ROS1 | ROS2 (Jazzy) | Notes / Pitfalls | API ref |
|---|---|---|---|
| `#include <ros/ros.h>` | `#include <rclcpp/rclcpp.hpp>` | Primary umbrella include changes | `api/docs-ros2-org-api-rclcpp-rclcpp-hpp.md` |
| `ros::init(argc, argv, "name")` | `rclcpp::init(argc, argv)` | Node name moves into node construction | `api/docs-ros-org-jazzy-api-rclcpp-index.md` |
| `ros::NodeHandle nh;` | `auto node = std::make_shared<rclcpp::Node>("name")` | Node ownership becomes explicit | `api/docs-ros2-org-api-rclcpp-classrclcpp_1_1_node.md` |
| `ros::NodeHandle("~")` | same node plus declared parameters | Private-namespace habits often migrate into node-owned parameters | `api/docs-ros-org-jazzy-concepts-about-parameters.md` |
| `nh.advertise<T>("topic", 10)` | `node->create_publisher<T>("topic", 10)` | QoS profile is explicit in ROS2 terms | `api/docs-ros2-org-api-rclcpp-classrclcpp_1_1_publisher.md` |
| `nh.subscribe<T>("topic", 10, cb)` | `node->create_subscription<T>("topic", 10, cb)` | Callback signatures often need `SharedPtr` updates | `api/docs-ros2-org-api-rclcpp-classrclcpp_1_1_subscription.md` |
| `ros::ServiceServer` + `nh.advertiseService(...)` | `node->create_service<T>(...)` | Service callback signature changes | `api/docs-ros2-org-api-rclcpp-classrclcpp_1_1_service.md` |
| `ros::ServiceClient` + `nh.serviceClient<T>(...)` | `node->create_client<T>(...)` | Async request patterns are more common in ROS2 | `api/docs-ros2-org-api-rclcpp-classrclcpp_1_1_client.md` |
| `ros::Rate rate(hz)` | `rclcpp::WallRate rate(hz)` | Commonly replaced by timers instead of manual loops | `api/docs-ros-org-jazzy-api-rclcpp-index.md` |
| `ros::Timer` | `node->create_wall_timer(...)` | Timer callbacks are first-class node constructs | `api/docs-ros2-org-api-rclcpp-classrclcpp_1_1_node.md` |
| `ros::spin()` | `rclcpp::spin(node)` | Executor model becomes explicit if concurrency matters | `api/docs-ros-org-jazzy-concepts-about-executors.md` |
| `ros::spinOnce()` | `rclcpp::spin_some(node)` or executor-specific calls | Prefer timer/executor designs over hand-rolled spin loops | `api/docs-ros-org-jazzy-concepts-about-executors.md` |
| `ros::AsyncSpinner` | `rclcpp::executors::MultiThreadedExecutor` | Threading decisions move to executor choice | `api/docs-ros-org-jazzy-concepts-about-executors.md` |
| `ros::CallbackQueue` | callback groups plus executor control | No direct one-line replacement | `api/docs-ros-org-jazzy-how-to-guides-using-callback-groups.md` |
| `ROS_INFO(...)` | `RCLCPP_INFO(node->get_logger(), ...)` | Logging macros now require a logger | `api/docs-ros-org-jazzy-api-rclcpp-index.md` |
| `ROS_WARN(...)` | `RCLCPP_WARN(node->get_logger(), ...)` | Same logger requirement | `api/docs-ros-org-jazzy-api-rclcpp-index.md` |
| `ROS_ERROR(...)` | `RCLCPP_ERROR(node->get_logger(), ...)` | Same logger requirement | `api/docs-ros-org-jazzy-api-rclcpp-index.md` |
| `ros::Time::now()` | `node->now()` | Time source is node/context-aware | `api/docs-ros2-org-api-rclcpp-classrclcpp_1_1_node.md` |
| `ros::Duration(x)` | `rclcpp::Duration::from_seconds(x)` or chrono durations | API shape differs | `api/docs-ros-org-jazzy-api-rclcpp-index.md` |
| `nh.getParam("k", v)` | `node->get_parameter("k", v)` after declaration | Declaration is usually required | `api/docs-ros-org-jazzy-concepts-about-parameters.md` |
| `nh.param("k", v, default)` | `node->declare_parameter("k", default)` plus `get_parameter` | Declaration folds defaulting into node setup | `api/docs-ros-org-jazzy-tutorials-using-parameters-cpp.md` |
| `nh.setParam("k", v)` | `node->set_parameter(...)` | Parameter mutation validation may reject updates | `api/docs-ros-org-jazzy-concepts-about-parameters.md` |
| `ros::ok()` | `rclcpp::ok()` | Often used in loops that should be reconsidered in executor/timer form | `api/docs-ros-org-jazzy-api-rclcpp-index.md` |
| `boost::bind(&Cls::cb, this, _1)` | lambda or `std::bind` with placeholders | Lambdas are often cleaner in ROS2 | `api/docs-ros2-org-api-rclcpp-classrclcpp_1_1_subscription.md` |
| `sensor_msgs::LaserScan::ConstPtr` callback args | `sensor_msgs::msg::LaserScan::SharedPtr` | Message namespace and pointer aliases change | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |

## Covered Symbols

`ros::init`, `ros::NodeHandle`, `advertise`, `subscribe`, `advertiseService`, `serviceClient`, `ros::Rate`, `ros::Timer`, `ros::spin`, `ros::spinOnce`, `ros::AsyncSpinner`, `ros::CallbackQueue`, `ROS_INFO`, `ROS_WARN`, `ROS_ERROR`, `ros::Time::now`, `ros::Duration`, `getParam`, `param`, `setParam`, `ros::ok`, `boost::bind`, `ConstPtr`

## Structural Translation Patterns

- **Procedural node**: replace free-standing initialization plus `NodeHandle` with an explicit `rclcpp::Node` instance and move publishers/subscribers into member fields or setup helpers.
- **Class-based node**: convert the class to inherit from or own a `rclcpp::Node`, then create publishers, subscriptions, services, and timers from that node context.
- **Spin loop with rate**: prefer timers and executor-driven callbacks over `while (ros::ok()) { ...; rate.sleep(); }` loops unless the loop truly models a periodic job.
- **Async callback-heavy node**: map custom callback queues or async spinners to callback groups plus an explicit executor choice.

## Surface-Preserving Rules

The default goal is to preserve topic names, service names, action names, parameter names, TF frames, and actual wire-level message/service types. Changing a callback signature, class layout, smart-pointer type, or timer implementation is structural only. Changing QoS in a way external subscribers see, renaming endpoints, or swapping a real message type requires a declaration in `artifacts/plan-meta.json`.

## Edge Cases

- ROS2 parameters must usually be declared before they are read; ports that only swap `getParam` to `get_parameter` usually fail.
- Single-threaded executors can deadlock designs that used ROS1 async spinners or custom callback queues implicitly.
- `spin_some` can be useful during migration, but it should not become an excuse to preserve brittle ROS1 control loops forever.
- Sensor-topic QoS often needs explicit `SensorDataQoS()` instead of the default profile.
- Logging now needs a logger, which means helper utilities that were previously static may need access to node context or a passed logger.

## Banned Symbols (Verification Hooks)

`#include <ros/ros.h>`, `ros::init`, `ros::NodeHandle`, `.advertise(`, `.subscribe(`, `.advertiseService(`, `.serviceClient(`, `ros::Rate`, `ros::Timer`, `ros::spin(`, `ros::spinOnce(`, `ros::AsyncSpinner`, `ros::CallbackQueue`, `ROS_INFO`, `ROS_WARN`, `ROS_ERROR`, `ros::Time::now`, `ros::Duration`, `getParam(`, `param(`, `setParam(`, `ros::ok(`
