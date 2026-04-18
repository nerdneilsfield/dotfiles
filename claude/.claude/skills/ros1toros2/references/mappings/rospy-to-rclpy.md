# rospy-to-rclpy

## Scope

Maps common ROS1 `rospy` patterns to ROS2 Jazzy `rclpy` patterns. Covers node setup, publishers, subscriptions, services, clients, timers, parameters, logging, spinning, and the places where Python ROS2 semantics differ enough to require explicit design attention.

## Symbol Mapping Table

| ROS1 | ROS2 (Jazzy) | Notes / Pitfalls | API ref |
|---|---|---|---|
| `import rospy` | `import rclpy` | The top-level module changes | `api/docs-ros2-org-api-rclpy-index.md` |
| `rospy.init_node("name")` | `rclpy.init(); node = MyNode()` | Node creation moves into an explicit `Node` subclass or instance | `api/docs-ros2-org-api-rclpy-node.md` |
| `rospy.Publisher(topic, T, queue_size=10)` | `self.create_publisher(T, topic, 10)` | QoS profile becomes the transport knob | `api/docs-ros2-org-api-rclpy-publisher.md` |
| `rospy.Subscriber(topic, T, cb)` | `self.create_subscription(T, topic, cb, 10)` | Callback receives ROS2 message objects | `api/docs-ros2-org-api-rclpy-subscription.md` |
| `rospy.Service(name, T, cb)` | `self.create_service(T, name, cb)` | Service callback signatures differ | `api/docs-ros2-org-api-rclpy-service.md` |
| `rospy.ServiceProxy(name, T)` | `self.create_client(T, name)` | ROS2 favors async client workflows | `api/docs-ros2-org-api-rclpy-client.md` |
| `rospy.Rate(hz)` | `self.create_timer(period, cb)` or explicit rate objects in controlled loops | Timers are usually the better migration target | `api/docs-ros2-org-api-rclpy-node.md` |
| `rospy.Timer(...)` | `self.create_timer(...)` | Timer semantics move under the node | `api/docs-ros2-org-api-rclpy-node.md` |
| `rospy.spin()` | `rclpy.spin(node)` | Executor is implicit in the convenience path | `api/docs-ros2-org-api-rclpy-index.md` |
| `rospy.is_shutdown()` | `rclpy.ok()` | Often appears in loops that should become timers | `api/docs-ros2-org-api-rclpy-index.md` |
| `rospy.loginfo(...)` | `self.get_logger().info(...)` | Logger comes from the node | `api/docs-ros2-org-api-rclpy-node.md` |
| `rospy.logwarn(...)` | `self.get_logger().warn(...)` | Same logger pattern | `api/docs-ros2-org-api-rclpy-node.md` |
| `rospy.logerr(...)` | `self.get_logger().error(...)` | Same logger pattern | `api/docs-ros2-org-api-rclpy-node.md` |
| `rospy.get_param("k")` | `self.get_parameter("k").value` after declaration | ROS2 usually requires declaration | `api/docs-ros-org-jazzy-concepts-about-parameters.md` |
| `rospy.get_param("k", default)` | `self.declare_parameter("k", default)` plus `get_parameter` | Defaulting migrates into declaration | `api/docs-ros-org-jazzy-tutorials-using-parameters-python.md` |
| `rospy.set_param("k", v)` | `self.set_parameters([...])` | Parameter mutation is node-local and explicit | `api/docs-ros-org-jazzy-concepts-about-parameters.md` |
| `rospy.has_param("k")` | inspect declared parameters or catch lookup failures | There is no identical shared-parameter-server behavior | `api/docs-ros-org-jazzy-concepts-about-parameters.md` |
| `rospy.Time.now()` | `self.get_clock().now()` | Time comes from the node clock | `api/docs-ros2-org-api-rclpy-node.md` |
| `rospy.Duration(x)` | `Duration(seconds=x)` or built time utilities | API shape changes | `api/docs-ros2-org-api-rclpy-index.md` |
| `rospy.sleep(x)` | timers, futures, or controlled sleeps outside callbacks | Sleeping inside callbacks is especially risky in ROS2 | `api/docs-ros-org-jazzy-concepts-about-executors.md` |
| `rospy.on_shutdown(cb)` | context-managed shutdown or explicit cleanup before `destroy_node()` | Cleanup orchestration differs | `api/docs-ros2-org-api-rclpy-index.md` |
| `rospy.wait_for_service(name)` | `client.wait_for_service()` | Usually paired with async request flow | `api/docs-ros2-org-api-rclpy-client.md` |
| implicit callback concurrency assumptions | executor and callback-group aware design | Python ROS2 still needs explicit concurrency thinking | `api/docs-ros-org-jazzy-concepts-about-executors.md` |

## Covered Symbols

`rospy.init_node`, `rospy.Publisher`, `rospy.Subscriber`, `rospy.Service`, `rospy.ServiceProxy`, `rospy.Rate`, `rospy.Timer`, `rospy.spin`, `rospy.is_shutdown`, `rospy.loginfo`, `rospy.logwarn`, `rospy.logerr`, `rospy.get_param`, `rospy.set_param`, `rospy.has_param`, `rospy.Time.now`, `rospy.Duration`, `rospy.sleep`, `rospy.on_shutdown`, `rospy.wait_for_service`

## Structural Translation Patterns

- **Single-file script node**: wrap the old module-level script in a `Node` subclass with explicit setup in `__init__`.
- **Loop-driven node**: replace `while not rospy.is_shutdown(): ... rate.sleep()` with timers when the loop represents periodic work.
- **Parameter-heavy script**: declare parameters once in the node constructor, then read and validate them through the node API.
- **Service client utility**: create the client once on node startup and use async requests instead of repeatedly constructing proxies.

## Surface-Preserving Rules

Preserve externally visible topic names, service names, action names, parameter names, TF frames, and real wire-level types unless the migration plan explicitly declares a change. Python import-path changes, object model changes, and `Node` subclassing are structural. QoS or true message-type changes that affect downstream consumers must be declared in `artifacts/plan-meta.json`.

## Edge Cases

- Declared-parameter rules catch many ROS1 patterns that relied on a shared parameter server.
- `rospy.sleep()` inside callbacks or executor-sensitive code can create responsiveness problems in ROS2.
- `ServiceProxy` ports often work better when rewritten around an explicit client object and async request flow.
- Mixed launch/parameter migration can hide configuration regressions if parameter files are not updated alongside code.
- Logger access is node-scoped, which means static helper functions often need a logger or node passed in.

## Banned Symbols (Verification Hooks)

`import rospy`, `rospy.init_node`, `rospy.Publisher`, `rospy.Subscriber`, `rospy.Service`, `rospy.ServiceProxy`, `rospy.Rate`, `rospy.Timer`, `rospy.spin`, `rospy.is_shutdown`, `rospy.loginfo`, `rospy.logwarn`, `rospy.logerr`, `rospy.get_param`, `rospy.set_param`, `rospy.has_param`, `rospy.Time.now`, `rospy.Duration`, `rospy.sleep`, `rospy.on_shutdown`, `rospy.wait_for_service`
