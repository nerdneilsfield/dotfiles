---
source_url: https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.client.Client
fetched_at: 2026-04-18T10:57:58Z
---

> Snapshot note: upstream source is stale (`rclpy 0.6.1` on `docs.ros2.org`). Use this page as an API-shape reference only; verify exact Jazzy signatures against `https://docs.ros.org/en/jazzy/p/rclpy/` when needed.

Services[¶](https://docs.ros2.org/latest/api/rclpy/api/services.html#services "Permalink to this headline")

============================================================================================================

Client[¶](https://docs.ros2.org/latest/api/rclpy/api/services.html#module-rclpy.client "Permalink to this headline")

---------------------------------------------------------------------------------------------------------------------

_class_ `rclpy.client.``Client`(_context_, _client\_handle_, _srv\_type_, _srv\_name_, _qos\_profile_, _callback\_group_)[¶](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.client.Client "Permalink to this definition")

Create a container for a ROS service client.

Warning

Users should not create a service client with this constuctor, instead they should call [`Node.create_client()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_client "rclpy.node.Node.create_client")
.

Parameters

*   **context** ([`Context`](https://docs.ros2.org/latest/api/rclpy/api/context.html#rclpy.context.Context "rclpy.context.Context")
    ) – The context associated with the service client.

*   **client\_handle** – `Handle` wrapping the underlying `rcl_client_t` object.

*   **srv\_type** (_~SrvType_) – The service type.

*   **srv\_name** (`str`) – The name of the service.

*   **qos\_profile** ([`QoSProfile`](https://docs.ros2.org/latest/api/rclpy/api/qos.html#rclpy.qos.QoSProfile "rclpy.qos.QoSProfile")
    ) – The quality of service profile to apply the service client.

*   **callback\_group** ([`CallbackGroup`](https://docs.ros2.org/latest/api/rclpy/api/execution_and_callbacks.html#rclpy.callback_groups.CallbackGroup "rclpy.callback_groups.CallbackGroup")
    ) – The callback group for the service client. If `None`, then the nodes default callback group is used.


`call`(_request_)[¶](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.client.Client.call "Permalink to this definition")

Make a service request and wait for the result.

Warning

Do not call this method in a callback or a deadlock may occur.

Parameters

**request** (_~SrvTypeRequest_) – The service request.

Return type

~SrvTypeResponse

Returns

The service response.

Raises

TypeError if the type of the passed request isn’t an instance of the Request type of the provided service when the client was constructed.

`call_async`(_request_)[¶](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.client.Client.call_async "Permalink to this definition")

Make a service request and asyncronously get the result.

Parameters

**request** (_~SrvTypeRequest_) – The service request.

Return type

`Future`

Returns

A future that completes when the request does.

Raises

TypeError if the type of the passed request isn’t an instance of the Request type of the provided service when the client was constructed.

`destroy`()[¶](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.client.Client.destroy "Permalink to this definition")

_property_ `handle`[¶](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.client.Client.handle "Permalink to this definition")

`remove_pending_request`(_future_)[¶](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.client.Client.remove_pending_request "Permalink to this definition")

Remove a future from the list of pending requests.

This prevents a future from receiving a response and executing its done callbacks.

Parameters

**future** (`Future`) – A future returned from [`call_async()`](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.client.Client.call_async "rclpy.client.Client.call_async")

Return type

`None`

`service_is_ready`()[¶](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.client.Client.service_is_ready "Permalink to this definition")

Check if there is a service server ready.

Return type

`bool`

Returns

`True` if a server is ready, `False` otherwise.

`wait_for_service`(_timeout\_sec\=None_)[¶](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.client.Client.wait_for_service "Permalink to this definition")

Wait for a service server to become ready.

Returns as soon as a server becomes ready or if the timeout expires.

Parameters

**timeout\_sec** (`Optional`\[`float`\]) – Seconds to wait. If `None`, then wait forever.

Return type

`bool`

Returns

`True` if server became ready while waiting or `False` on a timeout.

Service[¶](https://docs.ros2.org/latest/api/rclpy/api/services.html#module-rclpy.service "Permalink to this headline")

-----------------------------------------------------------------------------------------------------------------------

_class_ `rclpy.service.``Service`(_service\_handle_, _srv\_type_, _srv\_name_, _callback_, _callback\_group_, _qos\_profile_)[¶](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.service.Service "Permalink to this definition")

Create a container for a ROS service server.

Warning

Users should not create a service server with this constuctor, instead they should call [`Node.create_service()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_service "rclpy.node.Node.create_service")
.

Parameters

*   **context** – The context associated with the service server.

*   **service\_handle** – Capsule pointing to the underlying `rcl_service_t` object.

*   **srv\_type** (_~SrvType_) – The service type.

*   **srv\_name** (`str`) – The name of the service.

*   **callback\_group** ([`CallbackGroup`](https://docs.ros2.org/latest/api/rclpy/api/execution_and_callbacks.html#rclpy.callback_groups.CallbackGroup "rclpy.callback_groups.CallbackGroup")
    ) – The callback group for the service server. If `None`, then the nodes default callback group is used.

*   **qos\_profile** ([`QoSProfile`](https://docs.ros2.org/latest/api/rclpy/api/qos.html#rclpy.qos.QoSProfile "rclpy.qos.QoSProfile")
    ) – The quality of service profile to apply the service server.


`destroy`()[¶](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.service.Service.destroy "Permalink to this definition")

_property_ `handle`[¶](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.service.Service.handle "Permalink to this definition")

`send_response`(_response_, _header_)[¶](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.service.Service.send_response "Permalink to this definition")

Send a service response.

Parameters

*   **response** (_~SrvTypeResponse_) – The service response.

*   **header** – Capsule pointing to the service header from the original request.


Raises

TypeError if the type of the passed response isn’t an instance of the Response type of the provided service when the service was constructed.

Return type

`None`

[rclpy](https://docs.ros2.org/latest/api/rclpy/index.html)

===========================================================

### Navigation

*   [About](https://docs.ros2.org/latest/api/rclpy/about.html)

*   [Examples](https://docs.ros2.org/latest/api/rclpy/examples.html)

*   [API](https://docs.ros2.org/latest/api/rclpy/api.html)
    *   [Initialization, Shutdown, and Spinning](https://docs.ros2.org/latest/api/rclpy/api/init_shutdown.html)

    *   [Node](https://docs.ros2.org/latest/api/rclpy/api/node.html)

    *   [Topics](https://docs.ros2.org/latest/api/rclpy/api/topics.html)

    *   [Services](https://docs.ros2.org/latest/api/rclpy/api/services.html#)
        *   [Client](https://docs.ros2.org/latest/api/rclpy/api/services.html#module-rclpy.client)

        *   [Service](https://docs.ros2.org/latest/api/rclpy/api/services.html#module-rclpy.service)

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
        *   Previous: [Topics](https://docs.ros2.org/latest/api/rclpy/api/topics.html "previous chapter")

        *   Next: [Actions](https://docs.ros2.org/latest/api/rclpy/api/actions.html "next chapter")


### Quick search
