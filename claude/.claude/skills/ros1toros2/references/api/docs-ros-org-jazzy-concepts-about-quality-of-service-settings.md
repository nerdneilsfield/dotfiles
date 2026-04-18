---
source_url: https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html
fetched_at: 2026-04-18T10:58:20Z
---

*   [](https://docs.ros.org/en/jazzy/index.html)

*   [Concepts](https://docs.ros.org/en/jazzy/Concepts.html)

*   [Intermediate Concepts](https://docs.ros.org/en/jazzy/Concepts/Intermediate.html)

*   Quality of Service settings
*   [Edit on GitHub](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Intermediate/About-Quality-of-Service-Settings.rst)


* * *

**You're reading the documentation for an older, but still supported, version of ROS 2. For information on the latest version, please have a look at [Kilted](https://docs.ros.org/en/kilted/Concepts/Intermediate/About-Quality-of-Service-Settings.html)
.**

Quality of Service settings[](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#quality-of-service-settings "Link to this heading")

==============================================================================================================================================================================

[Overview](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#id2)
[](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#overview "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ROS 2 offers a rich variety of Quality of Service (QoS) policies that allow you to tune communication between nodes. With the right set of Quality of Service policies, ROS 2 can be as reliable as TCP or as best-effort as UDP, with many, many possible states in between. Unlike ROS 1, which primarily only supported TCP, ROS 2 benefits from the flexibility of the underlying DDS transport in environments with lossy wireless networks where a “best effort” policy would be more suitable, or in real-time computing systems where the right Quality of Service profile is needed to meet deadlines.

A set of QoS “policies” combine to form a QoS “profile”. Given the complexity of choosing the correct QoS policies for a given scenario, ROS 2 provides a set of predefined QoS profiles for common use cases (e.g. sensor data). At the same time, developers are given the flexibility to control specific policies of the QoS profiles.

QoS profiles can be specified for publishers, subscriptions, service servers and clients. A QoS profile can be applied independently to each instance of the aforementioned entities, but if different profiles are used, it is possible that they will be incompatible, preventing the delivery of messages.

[QoS policies](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#id3)
[](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#qos-policies "Link to this heading")

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

The base QoS profile currently includes settings for the following policies:

*   History

    *   _Keep last_: only store up to N samples, configurable via the queue depth option.

    *   _Keep all_: store all samples, subject to the configured resource limits of the underlying middleware.

*   Depth

    *   _Queue size_: only honored if the “history” policy was set to “keep last”.

*   Reliability

    *   _Best effort_: attempt to deliver samples, but may lose them if the network is not robust.

    *   _Reliable_: guarantee that samples are delivered, may retry multiple times.

*   Durability

    *   _Transient local_: the publisher becomes responsible for persisting samples for “late-joining” subscriptions.

    *   _Volatile_: no attempt is made to persist samples.

*   Deadline

    *   _Duration_: the expected maximum amount of time between subsequent messages being published to a topic

*   Lifespan

    *   _Duration_: the maximum amount of time between the publishing and the reception of a message without the message being considered stale or expired (expired messages are silently dropped and are effectively never received).

*   Liveliness

    *   _Automatic_: the system will consider all of the node’s publishers to be alive for another “lease duration” when any one of its publishers has published a message.

    *   _Manual by topic_: the system will consider the publisher to be alive for another “lease duration” if it manually asserts that it is still alive (via a call to the publisher API).

*   Lease Duration

    *   _Duration_: the maximum period of time a publisher has to indicate that it is alive before the system considers it to have lost liveliness (losing liveliness could be an indication of a failure).


For each of the policies that is not a duration, there is also the option of “system default”, which uses the default of the underlying middleware. For each of the policies that is a duration, there also exists a “default” option that means the duration is unspecified, which the underlying middleware will usually interpret as an infinitely long duration.

### [Comparison to ROS 1](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#id4)
[](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#comparison-to-ros-1 "Link to this heading")

The “history” and “depth” policies in ROS 2 combine to provide functionality akin to the queue size in ROS 1.

The “reliability” policy in ROS 2 is akin to the use of either UDPROS (only in `roscpp`) for “best effort”, or TCPROS (ROS 1 default) for “reliable”. Note however that even the reliable policy in ROS 2 is implemented using UDP, which allows for multicasting if appropriate.

The “durability” policy “transient local”, combined with any depth, provides functionality similar to that of “latching” publishers. The remaining policies in ROS 2 are not akin to anything that is available in ROS 1, meaning that ROS 2 is more featureful than ROS 1 in this respect. It is possible that in the future, even more QoS policies will be available in ROS 2.

[QoS profiles](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#id5)
[](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#qos-profiles "Link to this heading")

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Profiles allow developers to focus on their applications without worrying about every QoS setting possible. A QoS profile defines a set of policies that are expected to go well together for a particular use case.

The currently defined QoS profiles are:

*   Default QoS settings for publishers and subscriptions

    In order to make the transition from ROS 1 to ROS 2 easier, exercising a similar network behavior is desirable. By default, publishers and subscriptions in ROS 2 have “keep last” for history with a queue size of 10, “reliable” for reliability, “volatile” for durability, and “system default” for liveliness. Deadline, lifespan, and lease durations are also all set to “default”.

*   Services

    In the same vein as publishers and subscriptions, services are reliable. It is especially important for services to use volatile durability, as otherwise service servers that re-start may receive outdated requests. While the client is protected from receiving multiple responses, the server is not protected from side-effects of receiving the outdated requests.

*   Sensor data

    For sensor data, in most cases it’s more important to receive readings in a timely fashion, rather than ensuring that all of them arrive. That is, developers want the latest samples as soon as they are captured, at the expense of maybe losing some. For that reason the sensor data profile uses best effort reliability and a smaller queue size.

*   Parameters

    Parameters in ROS 2 are based on services, and as such have a similar profile. The difference is that parameters use a much larger queue depth so that requests do not get lost when, for example, the parameter client is unable to reach the parameter service server.

*   System default

    This uses the RMW implementation’s default values for all of the policies. Different RMW implementations may have different defaults.


[Click here](https://github.com/ros2/rmw/blob/jazzy/rmw/include/rmw/qos_profiles.h)
 for the specific policies in use for the above profiles. The settings in these profiles are subject to further tweaks, based on the feedback from the community.

[QoS compatibilities](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#id6)
[](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#qos-compatibilities "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

**Note:** This section refers to publishers and subscriptions but the content applies to service servers and clients in the same manner.

QoS profiles may be configured for publishers and subscriptions independently. A connection between a publisher and a subscription is only made if the pair has compatible QoS profiles.

QoS profile compatibility is determined based on a “Request vs Offered” model. Subscriptions _request_ a QoS profile that is the “minimum quality” that it is willing to accept, and publishers _offer_ a QoS profile that is the “maximum quality” that it is able to provide. Connections are only made if every policy of the requested QoS profile is not more stringent than that of the offered QoS profile. Multiple subscriptions can be connected to a single publisher simultaneously even if their requested QoS profiles are different. The compatibility between a publisher and a subscription is unaffected by the presence of other publishers and subscriptions.

The following tables show the compatibility of the different policy settings and the result:

_Compatibility of reliability QoS policies:_

| Publisher | Subscription | Compatible |
| --- | --- | --- |
| Best effort | Best effort | Yes |
| Best effort | Reliable | No  |
| Reliable | Best effort | Yes |
| Reliable | Reliable | Yes |

_Compatibility of durability QoS policies:_

| Publisher | Subscription | Compatible | Result |
| --- | --- | --- | --- |
| Volatile | Volatile | Yes | New messages only |
| Volatile | Transient local | No  | No communication |
| Transient local | Volatile | Yes | New messages only |
| Transient local | Transient local | Yes | New and old messages |

To achieve a “latched” topic that is visible to late subscribers, both the publisher and subscriber must agree to use ‘Transient Local’.

_Compatibility of deadline QoS policies:_

> Assume _x_ and _y_ are arbitrary valid duration values.

| Publisher | Subscription | Compatible |
| --- | --- | --- |
| Default | Default | Yes |
| Default | _x_ | No  |
| _x_ | Default | Yes |
| _x_ | _x_ | Yes |
| _x_ | _y_ (where _y_ > _x_) | Yes |
| _x_ | _y_ (where _y_ < _x_) | No  |

_Compatibility of liveliness QoS policies:_

| Publisher | Subscription | Compatible |
| --- | --- | --- |
| Automatic | Automatic | Yes |
| Automatic | Manual by topic | No  |
| Manual by topic | Automatic | Yes |
| Manual by topic | Manual by topic | Yes |

_Compatibility of lease duration QoS policies:_

> Assume _x_ and _y_ are arbitrary valid duration values.

| Publisher | Subscription | Compatible |
| --- | --- | --- |
| Default | Default | Yes |
| Default | _x_ | No  |
| _x_ | Default | Yes |
| _x_ | _x_ | Yes |
| _x_ | _y_ (where _y_ > _x_) | Yes |
| _x_ | _y_ (where _y_ < _x_) | No  |

In order for a connection to be made, all of the policies that affect compatibility must be compatible. For example, even if a requested and offered QoS profile pair has compatible reliability QoS policies, but they have incompatible durability QoS policies, a connection will still not be made.

When connections are not made, no messages will be passed between the publisher and subscription. There are mechanisms to detect this situation, which will be covered in a later section.

### [Comparison to ROS 1](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#id7)
[](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#id1 "Link to this heading")

Historically in ROS 1, any publisher and subscriber with the same message type on the same topic would be connected. The possibility of incompatible requested and offered QoS profiles is something new to be aware of when using ROS 2.

[QoS events](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#id8)
[](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#qos-events "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Some QoS policies have possible events related to them. Developers may provide each publisher and subscription with callback functions that are triggered by these QoS events and handle them in a way they see fit, similar to how messages received on a topic are handled.

Developers may subscribe to the following QoS events that are associated with a publisher:

*   Offered deadline missed

    The publisher has not published a message within the expected duration that was set out by the deadline QoS policy.

*   Liveliness lost

    The publisher has failed to indicate its liveliness within the lease duration.

*   Offered incompatible QoS

    The publisher has encountered a subscription on the same topic that is requesting a QoS profile that the offered QoS profile cannot satisfy, resulting in no connection between the publisher and that subscription.


Developers may subscribe to the following QoS events that are associated with a subscription:

*   Requested deadline missed

    The subscription has not received a message within the expected duration that was set out by the deadline QoS policy.

*   Liveliness changed

    The subscription has noticed that one or more publishers on the subscribed topic has failed to indicate their liveliness within the lease duration.

*   Requested incompatible QoS

    The subscription has encountered a publisher on the same topic that is offering a QoS profile that does not satisfy the requested QoS profile, resulting in no connection between the subscription and that publisher.


[Matched events](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#id9)
[](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html#matched-events "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

In addition to QoS events, matched events can be generated when any publisher and subscription establishes or drops the connection between them. Developers may provide each publisher and subscription with callback functions that are triggered by matched events and handle them in a way they see fit, similar to how messages received on a topic are handled.

Developers can subscribe to this event with a publisher or a subscription.

*   publisher: this event happens when it finds a subscription which matches the topic and has compatible QoS or a connected subscription is disconnected

*   subscription: this event happens when it finds a publisher which matches the topic and has compatible QoS or a connected publisher is disconnected


There are demos showing how to use the event:

*   rclcpp: [demo code](https://github.com/ros2/demos/blob/jazzy/demo_nodes_cpp/src/events/matched_event_detect.cpp)

*   rclpy: [demo code](https://github.com/ros2/demos/blob/jazzy/demo_nodes_py/demo_nodes_py/events/matched_event_detect.py)


Other Versions v: jazzy

Releases

[Kilted (latest)](https://docs.ros.org/en/kilted/Concepts/Intermediate/About-Quality-of-Service-Settings.html)

[Jazzy](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Quality-of-Service-Settings.html)

[Iron (EOL)](https://docs.ros.org/en/iron/Concepts/Intermediate/About-Quality-of-Service-Settings.html)

[Humble](https://docs.ros.org/en/humble/Concepts/Intermediate/About-Quality-of-Service-Settings.html)

[Galactic (EOL)](https://docs.ros.org/en/galactic/index.html)

[Foxy (EOL)](https://docs.ros.org/en/foxy/index.html)

[Eloquent (EOL)](https://docs.ros.org/en/eloquent/index.html)

[Dashing (EOL)](https://docs.ros.org/en/dashing/index.html)

[Crystal (EOL)](https://docs.ros.org/en/crystal/index.html)

In Development

[Rolling](https://docs.ros.org/en/rolling/Concepts/Intermediate/About-Quality-of-Service-Settings.html)
