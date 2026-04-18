---
source_url: https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.client.Client
fetched_at: 2026-04-18T00:00:00Z
---

# Services — rclpy 0.6.1 documentation

Services — rclpy 0.6.1 documentation

Services¶

Client¶
class `rclpy.client.``Client`(context, client_handle, srv_type, srv_name, qos_profile, callback_group)¶
Create a container for a ROS service client.

Warning

Users should not create a service client with this constuctor, instead they
should call `Node.create_client()`.

Parameters

-
context (`Context`) – The context associated with the service client.

-
client_handle – `Handle` wrapping the underlying `rcl_client_t` object.

-
srv_type (~SrvType) – The service type.

-
srv_name (`str`) – The name of the service.

-
qos_profile (`QoSProfile`) – The quality of service profile to apply the service client.

-
callback_group (`CallbackGroup`) – The callback group for the service client. If `None`, then the
nodes default callback group is used.

`call`(request)¶
Make a service request and wait for the result.

Warning

Do not call this method in a callback or a deadlock may occur.

Parameters
request (~SrvTypeRequest) – The service request.
Return type
~SrvTypeResponse
Returns
The service response.
Raises
TypeError if the type of the passed request isn’t an instance
of the Request type of the provided service when the client was
constructed.
`call_async`(request)¶
Make a service request and asyncronously get the result.
Parameters
request (~SrvTypeRequest) – The service request.
Return type
`Future`
Returns
A future that completes when the request does.
Raises
TypeError if the type of the passed request isn’t an instance
of the Request type of the provided service when the client was
constructed.
`destroy`()¶property `handle`¶`remove_pending_request`(future)¶
Remove a future from the list of pending requests.

This prevents a future from receiving a response and executing its done callbacks.
Parameters
future (`Future`) – A future returned from `call_async()`
Return type
`None`
`service_is_ready`()¶
Check if there is a service server ready.
Return type
`bool`
Returns
`True` if a server is ready, `False` otherwise.
`wait_for_service`(timeout_sec=None)¶
Wait for a service server to become ready.

Returns as soon as a server becomes ready or if the timeout expires.
Parameters
timeout_sec (`Optional`[`float`]) – Seconds to wait. If `None`, then wait forever.
Return type
`bool`
Returns
`True` if server became ready while waiting or `False` on a timeout.

Service¶
class `rclpy.service.``Service`(service_handle, srv_type, srv_name, callback, callback_group, qos_profile)¶
Create a container for a ROS service server.

Warning

Users should not create a service server with this constuctor, instead they
should call `Node.create_service()`.

Parameters

-
context – The context associated with the service server.

-
service_handle – Capsule pointing to the underlying `rcl_service_t` object.

-
srv_type (~SrvType) – The service type.

-
srv_name (`str`) – The name of the service.

-
callback_group (`CallbackGroup`) – The callback group for the service server. If `None`, then the
nodes default callback group is used.

-
qos_profile (`QoSProfile`) – The quality of service profile to apply the service server.

`destroy`()¶property `handle`¶`send_response`(response, header)¶
Send a service response.
Parameters

-
response (~SrvTypeResponse) – The service response.

-
header – Capsule pointing to the service header from the original request.

Raises
TypeError if the type of the passed response isn’t an instance
of the Response type of the provided service when the service was
constructed.
Return type
`None`

rclpy

Navigation

- About
- Examples
- API

- Initialization, Shutdown, and Spinning
- Node
- Topics
- Services

- Client
- Service

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

- Previous: Topics
- Next: Actions

Quick search

©2016-2019, Open Source Robotics Foundation, Inc..

|
Powered by Sphinx 3.0.4
& Alabaster 0.7.12

|
Page source
