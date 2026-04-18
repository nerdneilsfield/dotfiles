---
source_url: https://docs.ros2.org/latest/api/rclpy/api/node.html
fetched_at: 2026-04-18T00:00:00Z
---

> Snapshot note: upstream source is stale (`rclpy 0.6.1` on `docs.ros2.org`). Use this page as an API-shape reference only; verify exact Jazzy signatures against `https://docs.ros.org/en/jazzy/p/rclpy/` when needed.

# Node — rclpy 0.6.1 documentation

Node — rclpy 0.6.1 documentation

Node¶
class `rclpy.node.``Node`(node_name, *, context=None, cli_args=None, namespace=None, use_global_arguments=True, enable_rosout=True, start_parameter_services=True, parameter_overrides=None, allow_undeclared_parameters=False, automatically_declare_parameters_from_overrides=False)¶
Create a Node.
Parameters

-
node_name (`str`) – A name to give to this node. Validated by `validate_node_name()`.

-
context (`Optional`[`Context`]) – The context to be associated with, or `None` for the default global
context.

-
cli_args (`Optional`[`List`[`str`]]) – A list of strings of command line args to be used only by this node.
These arguments are used to extract remappings used by the node and other ROS specific
settings, as well as user defined non-ROS arguments.

-
namespace (`Optional`[`str`]) – The namespace to which relative topic and service names will be prefixed.
Validated by `validate_namespace()`.

-
use_global_arguments (`bool`) – `False` if the node should ignore process-wide command line
args.

-
enable_rosout (`bool`) – `False` if the node should ignore rosout logging.

-
start_parameter_services (`bool`) – `False` if the node should not create parameter
services.

-
parameter_overrides (`Optional`[`List`[`Parameter`]]) – A list of overrides for initial values for parameters declared
on the node.

-
allow_undeclared_parameters (`bool`) – True if undeclared parameters are allowed.
This flag affects the behavior of parameter-related operations.

-
automatically_declare_parameters_from_overrides (`bool`) – If True, the “parameter overrides”
will be used to implicitly declare parameters on the node during creation.

`PARAM_REL_TOL` = 1e-06¶
A Node in the ROS graph.

A Node is the primary entrypoint in a ROS system for communication.
It can be used to create ROS entities such as publishers, subscribers, services, etc.
`add_on_set_parameters_callback`(callback)¶
Add a callback in front to the list of callbacks.

Calling this function will add a callback in self._parameter_callbacks list.
Parameters
callback (`Callable`[[`List`[`Parameter`]], `SetParametersResult`]) – The function that is called whenever parameters are set for the node.
Return type
`None`
`add_waitable`(waitable)¶
Add a class that is capable of adding things to the wait set.
Parameters
waitable (`Waitable`) – An instance of a waitable that the node will add to the waitset.
Return type
`None`
property `clients`¶
Get clients that have been created on this node.
Return type
`Iterator`[`Client`]
property `context`¶
Get the context associated with the node.
Return type
`Context`
`count_publishers`(topic_name)¶
Return the number of publishers on a given topic.

topic_name may be a relative, private, or fully qualifed topic name.
A relative or private topic is expanded using this node’s namespace and name.
The queried topic name is not remapped.
Parameters
topic_name (`str`) – the topic_name on which to count the number of publishers.
Return type
`int`
Returns
the number of publishers on the topic.
`count_subscribers`(topic_name)¶
Return the number of subscribers on a given topic.

topic_name may be a relative, private, or fully qualifed topic name.
A relative or private topic is expanded using this node’s namespace and name.
The queried topic name is not remapped.
Parameters
topic_name (`str`) – the topic_name on which to count the number of subscribers.
Return type
`int`
Returns
the number of subscribers on the topic.
`create_client`(srv_type, srv_name, *, qos_profile=<rclpy.qos.QoSProfile object>, callback_group=None)¶
Create a new service client.
Parameters

-
srv_type – The service type.

-
srv_name (`str`) – The name of the service.

-
qos_profile (`QoSProfile`) – The quality of service profile to apply the service client.

-
callback_group (`Optional`[`CallbackGroup`]) – The callback group for the service client. If `None`, then the
nodes default callback group is used.

Return type
`Client`
`create_guard_condition`(callback, callback_group=None)¶
Create a new guard condition.
Return type
`GuardCondition`
`create_publisher`(msg_type, topic, qos_profile, *, callback_group=None, event_callbacks=None)¶
Create a new publisher.
Parameters

-
msg_type – The type of ROS messages the publisher will publish.

-
topic (`str`) – The name of the topic the publisher will publish to.

-
qos_profile (`Union`[`QoSProfile`, `int`]) – A QoSProfile or a history depth to apply to the publisher.
In the case that a history depth is provided, the QoS history is set to
RMW_QOS_POLICY_HISTORY_KEEP_LAST, the QoS history depth is set to the value
of the parameter, and all other QoS settings are set to their default values.

-
callback_group (`Optional`[`CallbackGroup`]) – The callback group for the publisher’s event handlers.
If `None`, then the node’s default callback group is used.

-
event_callbacks (`Optional`[`PublisherEventCallbacks`]) – User-defined callbacks for middleware events.

Return type
`Publisher`
Returns
The new publisher.
`create_rate`(frequency, clock=None)¶
Create a Rate object.
Parameters

-
frequency (`float`) – The frequency the Rate runs at (Hz).

-
clock (`Optional`[`Clock`]) – The clock the Rate gets time from.

Return type
`Rate`
`create_service`(srv_type, srv_name, callback, *, qos_profile=<rclpy.qos.QoSProfile object>, callback_group=None)¶
Create a new service server.
Parameters

-
srv_type – The service type.

-
srv_name (`str`) – The name of the service.

-
callback (`Callable`[[~SrvTypeRequest, ~SrvTypeResponse], ~SrvTypeResponse]) – A user-defined callback function that is called when a service request
received by the server.

-
qos_profile (`QoSProfile`) – The quality of service profile to apply the service server.

-
callback_group (`Optional`[`CallbackGroup`]) – The callback group for the service server. If `None`, then the
nodes default callback group is used.

Return type
`Service`
`create_subscription`(msg_type, topic, callback, qos_profile, *, callback_group=None, event_callbacks=None, raw=False)¶
Create a new subscription.
Parameters

-
msg_type – The type of ROS messages the subscription will subscribe to.

-
topic (`str`) – The name of the topic the subscription will subscribe to.

-
callback (`Callable`[[~MsgType], `None`]) – A user-defined callback function that is called when a message is
received by the subscription.

-
qos_profile (`Union`[`QoSProfile`, `int`]) – A QoSProfile or a history depth to apply to the subscription.
In the case that a history depth is provided, the QoS history is set to
RMW_QOS_POLICY_HISTORY_KEEP_LAST, the QoS history depth is set to the value
of the parameter, and all other QoS settings are set to their default values.

-
callback_group (`Optional`[`CallbackGroup`]) – The callback group for the subscription. If `None`, then the
nodes default callback group is used.

-
event_callbacks (`Optional`[`SubscriptionEventCallbacks`]) – User-defined callbacks for middleware events.

-
raw (`bool`) – If `True`, then received messages will be stored in raw binary
representation.

Return type
`Subscription`
`create_timer`(timer_period_sec, callback, callback_group=None, clock=None)¶
Create a new timer.

The timer will be started and every `timer_period_sec` number of seconds the provided
callback function will be called.
Parameters

-
timer_period_sec (`float`) – The period (s) of the timer.

-
callback (`Callable`) – A user-defined callback function that is called when the timer expires.

-
callback_group (`Optional`[`CallbackGroup`]) – The callback group for the timer. If `None`, then the nodes
default callback group is used.

-
clock (`Optional`[`Clock`]) – The clock which the timer gets time from.

Return type
`Timer`
`declare_parameter`(name, value=None, descriptor=rcl_interfaces.msg.ParameterDescriptor(name='', type=0, description='', additional_constraints='', read_only=False, floating_point_range=[], integer_range=[]), ignore_override=False)¶
Declare and initialize a parameter.

This method, if successful, will result in any callback registered with
`add_on_set_parameters_callback()` to be called.
Parameters

-
name (`str`) – Fully-qualified name of the parameter, including its namespace.

-
value (`Optional`[`Any`]) – Value of the parameter to declare.

-
descriptor (`ParameterDescriptor`) – Descriptor for the parameter to declare.

-
ignore_override (`bool`) – True if overrides shall not be taken into account; False otherwise.

Return type
`Parameter`
Returns
Parameter with the effectively assigned value.
Raises
ParameterAlreadyDeclaredException if the parameter had already been declared.
Raises
InvalidParameterException if the parameter name is invalid.
Raises
InvalidParameterValueException if the registered callback rejects the parameter.
`declare_parameters`(namespace, parameters, ignore_override=False)¶
Declare a list of parameters.

The tuples in the given parameter list shall contain the name for each parameter,
optionally providing a value and a descriptor.
For each entry in the list, a parameter with a name of “namespace.name”
will be declared.
The resulting value for each declared parameter will be returned, considering
parameter overrides set upon node creation as the first choice,
or provided parameter values as the second one.

The name expansion is naive, so if you set the namespace to be “foo.”,
then the resulting parameter names will be like “foo..name”.
However, if the namespace is an empty string, then no leading ‘.’ will be
placed before each name, which would have been the case when naively
expanding “namespace.name”.
This allows you to declare several parameters at once without a namespace.

This method, if successful, will result in any callback registered with
`add_on_set_parameters_callback()` to be called once for each parameter.
If one of those calls fail, an exception will be raised and the remaining parameters will
not be declared.
Parameters declared up to that point will not be undeclared.
Parameters

-
namespace (`str`) – Namespace for parameters.

-
parameters (`List`[`Union`[`Tuple`[`str`], `Tuple`[`str`, `Any`], `Tuple`[`str`, `Any`, `ParameterDescriptor`]]]) – List of tuples with parameters to declare.

-
ignore_override (`bool`) – True if overrides shall not be taken into account; False otherwise.

Return type
`List`[`Parameter`]
Returns
Parameter list with the effectively assigned values for each of them.
Raises
ParameterAlreadyDeclaredException if the parameter had already been declared.
Raises
InvalidParameterException if the parameter name is invalid.
Raises
InvalidParameterValueException if the registered callback rejects any parameter.
Raises
TypeError if any tuple in :param:`parameters` does not match the annotated type.
property `default_callback_group`¶
Get the default callback group.

If no other callback group is provided when the a ROS entity is created with the node,
then it is added to the default callback group.
Return type
`CallbackGroup`
`describe_parameter`(name)¶
Get the parameter descriptor of a given parameter.
Parameters
name (`str`) – Fully-qualified name of the parameter, including its namespace.
Return type
`ParameterDescriptor`
Returns
ParameterDescriptor corresponding to the parameter,
or default ParameterDescriptor if parameter had not been declared before
and undeclared parameters are allowed.
Raises
ParameterNotDeclaredException if parameter had not been declared before
and undeclared parameters are not allowed.
`describe_parameters`(names)¶
Get the parameter descriptors of a given list of parameters.
Parameters
name – List of fully-qualified names of the parameters to describe.
Return type
`List`[`ParameterDescriptor`]
Returns
List of ParameterDescriptors corresponding to the given parameters.
Default ParameterDescriptors shall be returned for parameters that
had not been declared before if undeclared parameters are allowed.
Raises
ParameterNotDeclaredException if at least one parameter
had not been declared before and undeclared parameters are not allowed.
`destroy_client`(client)¶
Destroy a service client created by the node.
Return type
`bool`
Returns
`True` if successful, `False` otherwise.
`destroy_guard_condition`(guard)¶
Destroy a guard condition created by the node.
Return type
`bool`
Returns
`True` if successful, `False` otherwise.
`destroy_node`()¶
Destroy the node.

Frees resources used by the node, including any entities created by the following methods:

-
`create_publisher()`

-
`create_subscription()`

-
`create_client()`

-
`create_service()`

-
`create_timer()`

-
`create_guard_condition()`

Return type
`bool`
`destroy_publisher`(publisher)¶
Destroy a publisher created by the node.
Return type
`bool`
Returns
`True` if successful, `False` otherwise.
`destroy_rate`(rate)¶
Destroy a Rate object created by the node.
Returns
`True` if successful, `False` otherwise.
`destroy_service`(service)¶
Destroy a service server created by the node.
Return type
`bool`
Returns
`True` if successful, `False` otherwise.
`destroy_subscription`(subscription)¶
Destroy a subscription created by the node.
Return type
`bool`
Returns
`True` if succesful, `False` otherwise.
`destroy_timer`(timer)¶
Destroy a timer created by the node.
Return type
`bool`
Returns
`True` if successful, `False` otherwise.
property `executor`¶
Get the executor if the node has been added to one, else return `None`.
Return type
`Optional`[`Executor`]
`get_client_names_and_types_by_node`(node_name, node_namespace)¶
Get a list of discovered service client topics for a remote node.
Parameters

-
node_name (`str`) – Name of a remote node to get service clients for.

-
node_namespace (`str`) – Namespace of the remote node.

Return type
`List`[`Tuple`[`str`, `List`[`str`]]]
Returns
List of tuples.
The fist element of each tuple is the service client name
and the second element is a list of service client types.
Raises

-
NodeNameNonExistentError – If the node wasn’t found.

-
RuntimeError – Unexpected failure.

`get_clock`()¶
Get the clock used by the node.
Return type
`Clock`
`get_logger`()¶
Get the nodes logger.
`get_name`()¶
Get the name of the node.
Return type
`str`
`get_namespace`()¶
Get the namespace of the node.
Return type
`str`
`get_node_names`()¶
Get a list of names for discovered nodes.
Return type
`List`[`str`]
Returns
List of node names.
`get_node_names_and_namespaces`()¶
Get a list of names and namespaces for discovered nodes.
Return type
`List`[`Tuple`[`str`, `str`]]
Returns
List of tuples containing two strings: the node name and node namespace.
`get_node_names_and_namespaces_with_enclaves`()¶
Get a list of names, namespaces and enclaves for discovered nodes.
Return type
`List`[`Tuple`[`str`, `str`, `str`]]
Returns
List of tuples containing three strings: the node name, node namespace
and enclave.
`get_parameter`(name)¶
Get a parameter by name.
Parameters
name (`str`) – Fully-qualified name of the parameter, including its namespace.
Return type
`Parameter`
Returns
The value for the given parameter name.
A default Parameter will be returned for an undeclared parameter if
undeclared parameters are allowed.
Raises
ParameterNotDeclaredException if undeclared parameters are not allowed,
and the parameter hadn’t been declared beforehand.
`get_parameter_or`(name, alternative_value=None)¶
Get a parameter or the alternative value.

If the alternative value is None, a default Parameter with the given name and NOT_SET
type will be returned if the parameter was not declared.
Parameters

-
name (`str`) – Fully-qualified name of the parameter, including its namespace.

-
alternative_value (`Optional`[`Parameter`]) – Alternative parameter to get if it had not been declared before.

Return type
`Parameter`
Returns
Requested parameter, or alternative value if it hadn’t been declared before.
`get_parameters`(names)¶
Get a list of parameters.
Parameters
names (`List`[`str`]) – Fully-qualified names of the parameters to get, including their namespaces.
Return type
`List`[`Parameter`]
Returns
The values for the given parameter names.
A default Parameter will be returned for undeclared parameters if
undeclared parameters are allowed.
Raises
ParameterNotDeclaredException if undeclared parameters are not allowed,
and at least one parameter hadn’t been declared beforehand.
`get_parameters_by_prefix`(prefix)¶
Get parameters that have a given prefix in their names as a dictionary.

The names which are used as keys in the returned dictionary have the prefix removed.
For example, if you use the prefix “foo” and the parameters “foo.ping”, “foo.pong”
and “bar.baz” exist, then the returned dictionary will have the keys “ping” and “pong”.
Note that the parameter separator is also removed from the parameter name to create the
keys.

An empty string for the prefix will match all parameters.

If no parameters with the prefix are found, an empty dictionary will be returned.
Parameters
prefix (`str`) – The prefix of the parameters to get.
Return type
`List`[`Parameter`]
Returns
Dict of parameters with the given prefix.
`get_publisher_names_and_types_by_node`(node_name, node_namespace, no_demangle=False)¶
Get a list of discovered topics for publishers of a remote node.
Parameters

-
node_name (`str`) – Name of a remote node to get publishers for.

-
node_namespace (`str`) – Namespace of the remote node.

-
no_demangle (`bool`) – If `True`, then topic names and types returned will not be demangled.

Return type
`List`[`Tuple`[`str`, `List`[`str`]]]
Returns
List of tuples.
The first element of each tuple is the topic name and the second element is a list of
topic types.
Raises

-
NodeNameNonExistentError – If the node wasn’t found.

-
RuntimeError – Unexpected failure.

`get_publishers_info_by_topic`(topic_name, no_mangle=False)¶
Return a list of publishers on a given topic.

The returned parameter is a list of TopicEndpointInfo objects, where each will contain
the node name, node namespace, topic type, topic endpoint’s GID, and its QoS profile.

When the no_mangle parameter is true, the provided topic_name should be a valid topic
name for the middleware (useful when combining ROS with native middleware (e.g. DDS) apps).
When the no_mangle parameter is false, the provided topic_name should follow
ROS topic name conventions.

topic_name may be a relative, private, or fully qualified topic name.
A relative or private topic will be expanded using this node’s namespace and name.
The queried topic_name is not remapped.
Parameters

-
topic_name (`str`) – the topic_name on which to find the publishers.

-
no_mangle (`bool`) – no_mangle if true, topic_name needs to be a valid middleware topic
name, otherwise it should be a valid ROS topic name. Defaults to false.

Return type
`List`[`TopicEndpointInfo`]
Returns
a list of TopicEndpointInfo for all the publishers on this topic.
`get_service_names_and_types`()¶
Get a list of service topics for the node.
Return type
`List`[`Tuple`[`str`, `List`[`str`]]]
Returns
List of tuples.
The first element of each tuple is the service name and the second element is a list of
service types.
`get_service_names_and_types_by_node`(node_name, node_namespace)¶
Get a list of discovered service server topics for a remote node.
Parameters

-
node_name (`str`) – Name of a remote node to get services for.

-
node_namespace (`str`) – Namespace of the remote node.

Return type
`List`[`Tuple`[`str`, `List`[`str`]]]
Returns
List of tuples.
The first element of each tuple is the service server name
and the second element is a list of service types.
Raises

-
NodeNameNonExistentError – If the node wasn’t found.

-
RuntimeError – Unexpected failure.

`get_subscriber_names_and_types_by_node`(node_name, node_namespace, no_demangle=False)¶
Get a list of discovered topics for subscriptions of a remote node.
Parameters

-
node_name (`str`) – Name of a remote node to get subscriptions for.

-
node_namespace (`str`) – Namespace of the remote node.

-
no_demangle (`bool`) – If `True`, then topic names and types returned will not be demangled.

Return type
`List`[`Tuple`[`str`, `List`[`str`]]]
Returns
List of tuples.
The first element of each tuple is the topic name and the second element is a list of
topic types.
Raises

-
NodeNameNonExistentError – If the node wasn’t found.

-
RuntimeError – Unexpected failure.

`get_subscriptions_info_by_topic`(topic_name, no_mangle=False)¶
Return a list of subscriptions on a given topic.

The returned parameter is a list of TopicEndpointInfo objects, where each will contain
the node name, node namespace, topic type, topic endpoint’s GID, and its QoS profile.

When the no_mangle parameter is true, the provided topic_name should be a valid topic
name for the middleware (useful when combining ROS with native middleware (e.g. DDS) apps).
When the no_mangle parameter is false, the provided topic_name should follow
ROS topic name conventions.

topic_name may be a relative, private, or fully qualified topic name.
A relative or private topic will be expanded using this node’s namespace and name.
The queried topic_name is not remapped.
Parameters

-
topic_name (`str`) – the topic_name on which to find the subscriptions.

-
no_mangle (`bool`) – no_mangle if true, topic_name needs to be a valid middleware topic
name, otherwise it should be a valid ROS topic name. Defaults to false.

Return type
`List`[`TopicEndpointInfo`]
Returns
a list of TopicEndpointInfo for all the subscriptions on this topic.
`get_topic_names_and_types`(no_demangle=False)¶
Get a list topic names and types for the node.
Parameters
no_demangle (`bool`) – If `True`, then topic names and types returned will not be demangled.
Return type
`List`[`Tuple`[`str`, `List`[`str`]]]
Returns
List of tuples.
The first element of each tuple is the topic name and the second element is a list of
topic types.
property `guards`¶
Get guards that have been created on this node.
Return type
`Iterator`[`GuardCondition`]
property `handle`¶
Get the handle to the underlying rcl_node_t.

Cannot be modified after node creation.
Raises
AttributeError if modified after creation.
`has_parameter`(name)¶
Return True if parameter is declared; False otherwise.
Return type
`bool`
property `publishers`¶
Get publishers that have been created on this node.
Return type
`Iterator`[`Publisher`]
`remove_on_set_parameters_callback`(callback)¶
Remove a callback from list of callbacks.

Calling this function will remove the callback from self._parameter_callbacks list.
Parameters
callback (`Callable`[[`List`[`Parameter`]], `SetParametersResult`]) – The function that is called whenever parameters are set for the node.
Raises
ValueError if a callback is not present in the list of callbacks.
Return type
`None`
`remove_waitable`(waitable)¶
Remove a Waitable that was previously added to the node.
Parameters
waitable (`Waitable`) – The Waitable to remove.
Return type
`None`
property `services`¶
Get services that have been created on this node.
Return type
`Iterator`[`Service`]
`set_descriptor`(name, descriptor, alternative_value=None)¶
Set a new descriptor for a given parameter.

The name in the descriptor is ignored and set to :param:`name`.
Parameters

-
name (`str`) – Fully-qualified name of the parameter to set the descriptor to.

-
descriptor (`ParameterDescriptor`) – New descriptor to apply to the parameter.

-
alternative_value (`Optional`[`ParameterValue`]) – Value to set to the parameter if the existing value does not
comply with the new descriptor.

Return type
`ParameterValue`
Returns
ParameterValue for the given parameter name after applying the new descriptor.
Raises
ParameterNotDeclaredException if parameter had not been declared before
and undeclared parameters are not allowed.
Raises
ParameterImmutableException if the parameter exists and is read-only.
Raises
ParameterValueException if neither the existing value nor the alternative value
complies with the provided descriptor.
`set_parameters`(parameter_list)¶
Set parameters for the node, and return the result for the set action.

If any parameter in the list was not declared beforehand and undeclared parameters are not
allowed for the node, this method will raise a ParameterNotDeclaredException exception.

Parameters are set in the order they are declared in the list.
If setting a parameter fails due to not being declared, then the
parameters which have already been set will stay set, and no attempt will
be made to set the parameters which come after.

If undeclared parameters are allowed, then all the parameters will be implicitly
declared before being set even if they were not declared beforehand.
Parameter overrides are ignored by this method.

If a callback was registered previously with `add_on_set_parameters_callback()`, it
will be called prior to setting the parameters for the node, once for each parameter.
If the callback prevents a parameter from being set, then it will be reflected in the
returned result; no exceptions will be raised in this case.
For each successfully set parameter, a `ParameterEvent` message is
published.

If the value type of the parameter is NOT_SET, and the existing parameter type is
something else, then the parameter will be implicitly undeclared.
Parameters
parameter_list (`List`[`Parameter`]) – The list of parameters to set.
Return type
`List`[`SetParametersResult`]
Returns
The result for each set action as a list.
Raises
ParameterNotDeclaredException if undeclared parameters are not allowed,
and at least one parameter in the list hadn’t been declared beforehand.
`set_parameters_atomically`(parameter_list)¶
Set the given parameters, all at one time, and then aggregate result.

If any parameter in the list was not declared beforehand and undeclared parameters are not
allowed for the node, this method will raise a ParameterNotDeclaredException exception.

Parameters are set all at once.
If setting a parameter fails due to not being declared, then no parameter will be set set.
Either all of the parameters are set or none of them are set.

If undeclared parameters are allowed for the node, then all the parameters will be
implicitly declared before being set even if they were not declared beforehand.

If a callback was registered previously with `add_on_set_parameters_callback()`, it
will be called prior to setting the parameters for the node only once for all parameters.
If the callback prevents the parameters from being set, then it will be reflected in the
returned result; no exceptions will be raised in this case.
For each successfully set parameter, a `ParameterEvent` message is published.

If the value type of the parameter is NOT_SET, and the existing parameter type is
something else, then the parameter will be implicitly undeclared.
Parameters
parameter_list (`List`[`Parameter`]) – The list of parameters to set.
Return type
`SetParametersResult`
Returns
Aggregate result of setting all the parameters atomically.
Raises
ParameterNotDeclaredException if undeclared parameters are not allowed,
and at least one parameter in the list hadn’t been declared beforehand.
`set_parameters_callback`(callback)¶
Register a set parameters callback.

Deprecated since version Foxy: Use `add_on_set_parameters_callback()` instead.

Calling this function will add a callback to the self._parameter_callbacks list.
Parameters
callback (`Callable`[[`List`[`Parameter`]], `SetParametersResult`]) – The function that is called whenever parameters are set for the node.
Return type
`None`
property `subscriptions`¶
Get subscriptions that have been created on this node.
Return type
`Iterator`[`Subscription`]
property `timers`¶
Get timers that have been created on this node.
Return type
`Iterator`[`Timer`]
`undeclare_parameter`(name)¶
Undeclare a previously declared parameter.

This method will not cause a callback registered with
`add_on_set_parameters_callback()` to be called.
Parameters
name (`str`) – Fully-qualified name of the parameter, including its namespace.
Raises
ParameterNotDeclaredException if parameter had not been declared before.
Raises
ParameterImmutableException if the parameter was created as read-only.
property `waitables`¶
Get waitables that have been created on this node.
Return type
`Iterator`[`Waitable`]

rclpy

Navigation

- About
- Examples
- API

- Initialization, Shutdown, and Spinning
- Node
- Topics
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

- Previous: Initialization, Shutdown, and Spinning
- Next: Topics

Quick search

©2016-2019, Open Source Robotics Foundation, Inc..

|
Powered by Sphinx 3.0.4
& Alabaster 0.7.12

|
Page source
