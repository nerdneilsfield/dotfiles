---
source_url: https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.publisher.Publisher
fetched_at: 2026-04-18T00:00:00Z
---

# Topics — rclpy 0.6.1 documentation

Topics — rclpy 0.6.1 documentation

Topics¶

Publisher¶
class `rclpy.publisher.``Publisher`(publisher_handle, msg_type, topic, qos_profile, event_callbacks, callback_group)¶
Create a container for a ROS publisher.

Warning

Users should not create a publisher with this constuctor, instead they should
call `Node.create_publisher()`.

A publisher is used as a primary means of communication in a ROS system by publishing
messages on a ROS topic.
Parameters

-
publisher_handle (`Handle`) – Capsule pointing to the underlying `rcl_publisher_t` object.

-
msg_type (~MsgType) – The type of ROS messages the publisher will publish.

-
topic (`str`) – The name of the topic the publisher will publish to.

-
qos_profile (`QoSProfile`) – The quality of service profile to apply to the publisher.

`assert_liveliness`()¶
Manually assert that this Publisher is alive.

If the QoS Liveliness policy is set to RMW_QOS_POLICY_LIVELINESS_MANUAL_BY_TOPIC, the
application must call this at least as often as `QoSProfile.liveliness_lease_duration`.
Return type
`None`
`destroy`()¶`get_subscription_count`()¶
Get the amount of subscribers that this publisher has.
Return type
`int`
property `handle`¶`publish`(msg)¶
Send a message to the topic for the publisher.
Parameters
msg (`Union`[~MsgType, `bytes`]) – The ROS message to publish.
Raises
TypeError if the type of the passed message isn’t an instance
of the provided type when the publisher was constructed.
Return type
`None`
property `topic_name`¶Return type
`str`

Subscription¶
class `rclpy.subscription.``Subscription`(subscription_handle, msg_type, topic, callback, callback_group, qos_profile, raw, event_callbacks)¶
Create a container for a ROS subscription.

Warning

Users should not create a subscription with this constructor, instead they
should call `Node.create_subscription()`.

Parameters

-
subscription_handle (`Handle`) – `Handle` wrapping the underlying `rcl_subscription_t`
object.

-
msg_type (~MsgType) – The type of ROS messages the subscription will subscribe to.

-
topic (`str`) – The name of the topic the subscription will subscribe to.

-
callback (`Callable`) – A user-defined callback function that is called when a message is
received by the subscription.

-
callback_group (`CallbackGroup`) – The callback group for the subscription. If `None`, then the
nodes default callback group is used.

-
qos_profile (`QoSProfile`) – The quality of service profile to apply to the subscription.

-
raw (`bool`) – If `True`, then received messages will be stored in raw binary
representation.

`destroy`()¶property `handle`¶property `topic_name`¶

rclpy

Navigation

- About
- Examples
- API

- Initialization, Shutdown, and Spinning
- Node
- Topics

- Publisher
- Subscription

- Services
- Actions
- Timer
- Parameters
- Logging
- Context
- Execution and Callbacks
- Utilities
- Quality of Service

Related Topics

- Documentation overview

- API

- Previous: Node
- Next: Services

Quick search

©2016-2019, Open Source Robotics Foundation, Inc..

|
Powered by Sphinx 3.0.4
& Alabaster 0.7.12

|
Page source
