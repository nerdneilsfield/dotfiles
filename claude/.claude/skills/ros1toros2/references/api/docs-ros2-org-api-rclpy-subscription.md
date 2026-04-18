---
source_url: https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.subscription.Subscription
fetched_at: 2026-04-18T10:58:08Z
---

> Snapshot note: upstream source is stale (`rclpy 0.6.1` on `docs.ros2.org`). Use this page as an API-shape reference only; verify exact Jazzy signatures against `https://docs.ros.org/en/jazzy/p/rclpy/` when needed.

Topics[¶](https://docs.ros2.org/latest/api/rclpy/api/topics.html#topics "Permalink to this headline")

======================================================================================================

Publisher[¶](https://docs.ros2.org/latest/api/rclpy/api/topics.html#module-rclpy.publisher "Permalink to this headline")

-------------------------------------------------------------------------------------------------------------------------

_class_ `rclpy.publisher.``Publisher`(_publisher\_handle_, _msg\_type_, _topic_, _qos\_profile_, _event\_callbacks_, _callback\_group_)[¶](https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.publisher.Publisher "Permalink to this definition")

Create a container for a ROS publisher.

Warning

Users should not create a publisher with this constuctor, instead they should call [`Node.create_publisher()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_publisher "rclpy.node.Node.create_publisher")
.

A publisher is used as a primary means of communication in a ROS system by publishing messages on a ROS topic.

Parameters

*   **publisher\_handle** (`Handle`) – Capsule pointing to the underlying `rcl_publisher_t` object.

*   **msg\_type** (_~MsgType_) – The type of ROS messages the publisher will publish.

*   **topic** (`str`) – The name of the topic the publisher will publish to.

*   **qos\_profile** ([`QoSProfile`](https://docs.ros2.org/latest/api/rclpy/api/qos.html#rclpy.qos.QoSProfile "rclpy.qos.QoSProfile")
    ) – The quality of service profile to apply to the publisher.


`assert_liveliness`()[¶](https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.publisher.Publisher.assert_liveliness "Permalink to this definition")

Manually assert that this Publisher is alive.

If the QoS Liveliness policy is set to RMW\_QOS\_POLICY\_LIVELINESS\_MANUAL\_BY\_TOPIC, the application must call this at least as often as `QoSProfile.liveliness_lease_duration`.

Return type

`None`

`destroy`()[¶](https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.publisher.Publisher.destroy "Permalink to this definition")

`get_subscription_count`()[¶](https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.publisher.Publisher.get_subscription_count "Permalink to this definition")

Get the amount of subscribers that this publisher has.

Return type

`int`

_property_ `handle`[¶](https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.publisher.Publisher.handle "Permalink to this definition")

`publish`(_msg_)[¶](https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.publisher.Publisher.publish "Permalink to this definition")

Send a message to the topic for the publisher.

Parameters

**msg** (`Union`\[~MsgType, `bytes`\]) – The ROS message to publish.

Raises

TypeError if the type of the passed message isn’t an instance of the provided type when the publisher was constructed.

Return type

`None`

_property_ `topic_name`[¶](https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.publisher.Publisher.topic_name "Permalink to this definition")

Return type

`str`

Subscription[¶](https://docs.ros2.org/latest/api/rclpy/api/topics.html#module-rclpy.subscription "Permalink to this headline")

-------------------------------------------------------------------------------------------------------------------------------

_class_ `rclpy.subscription.``Subscription`(_subscription\_handle_, _msg\_type_, _topic_, _callback_, _callback\_group_, _qos\_profile_, _raw_, _event\_callbacks_)[¶](https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.subscription.Subscription "Permalink to this definition")

Create a container for a ROS subscription.

Warning

Users should not create a subscription with this constructor, instead they should call [`Node.create_subscription()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_subscription "rclpy.node.Node.create_subscription")
.

Parameters

*   **subscription\_handle** (`Handle`) – `Handle` wrapping the underlying `rcl_subscription_t` object.

*   **msg\_type** (_~MsgType_) – The type of ROS messages the subscription will subscribe to.

*   **topic** (`str`) – The name of the topic the subscription will subscribe to.

*   **callback** (`Callable`) – A user-defined callback function that is called when a message is received by the subscription.

*   **callback\_group** ([`CallbackGroup`](https://docs.ros2.org/latest/api/rclpy/api/execution_and_callbacks.html#rclpy.callback_groups.CallbackGroup "rclpy.callback_groups.CallbackGroup")
    ) – The callback group for the subscription. If `None`, then the nodes default callback group is used.

*   **qos\_profile** ([`QoSProfile`](https://docs.ros2.org/latest/api/rclpy/api/qos.html#rclpy.qos.QoSProfile "rclpy.qos.QoSProfile")
    ) – The quality of service profile to apply to the subscription.

*   **raw** (`bool`) – If `True`, then received messages will be stored in raw binary representation.


`destroy`()[¶](https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.subscription.Subscription.destroy "Permalink to this definition")

_property_ `handle`[¶](https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.subscription.Subscription.handle "Permalink to this definition")

_property_ `topic_name`[¶](https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.subscription.Subscription.topic_name "Permalink to this definition")

[rclpy](https://docs.ros2.org/latest/api/rclpy/index.html)

===========================================================

### Navigation

*   [About](https://docs.ros2.org/latest/api/rclpy/about.html)

*   [Examples](https://docs.ros2.org/latest/api/rclpy/examples.html)

*   [API](https://docs.ros2.org/latest/api/rclpy/api.html)
    *   [Initialization, Shutdown, and Spinning](https://docs.ros2.org/latest/api/rclpy/api/init_shutdown.html)

    *   [Node](https://docs.ros2.org/latest/api/rclpy/api/node.html)

    *   [Topics](https://docs.ros2.org/latest/api/rclpy/api/topics.html#)
        *   [Publisher](https://docs.ros2.org/latest/api/rclpy/api/topics.html#module-rclpy.publisher)

        *   [Subscription](https://docs.ros2.org/latest/api/rclpy/api/topics.html#module-rclpy.subscription)

    *   [Services](https://docs.ros2.org/latest/api/rclpy/api/services.html)

    *   [Actions](https://docs.ros2.org/latest/api/rclpy/api/actions.html)

    *   [Timer](https://docs.ros2.org/latest/api/rclpy/api/timers.html)

    *   [Parameters](https://docs.ros2.org/latest/api/rclpy/api/parameters.html)

    *   [Logging](https://docs.ros2.org/latest/api/rclpy/api/logging.html)

    *   [Context](https://docs.ros2.org/latest/api/rclpy/api/context.html)

    *   [Execution and Callbacks](https://docs.ros2.org/latest/api/rclpy/api/execution_and_callbacks.html)

    *   [Utilities](https://docs.ros2.org/latest/api/rclpy/api/utilities.html)

    *   [Quality of Service](https://docs.ros2.org/latest/api/rclpy/api/qos.html)


### Related Topics

*   [Documentation overview](https://docs.ros2.org/latest/api/rclpy/index.html)
    *   [API](https://docs.ros2.org/latest/api/rclpy/api.html)
        *   Previous: [Node](https://docs.ros2.org/latest/api/rclpy/api/node.html "previous chapter")

        *   Next: [Services](https://docs.ros2.org/latest/api/rclpy/api/services.html "next chapter")


### Quick search
