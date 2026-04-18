---
source_url: https://docs.ros2.org/latest/api/rclpy/api/node.html
fetched_at: 2026-04-18T10:58:03Z
---

> Snapshot note: upstream source is stale (`rclpy 0.6.1` on `docs.ros2.org`). Use this page as an API-shape reference only; verify exact Jazzy signatures against `https://docs.ros.org/en/jazzy/p/rclpy/` when needed.

Node[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#module-rclpy.node "Permalink to this headline")

=============================================================================================================

_class_ `rclpy.node.``Node`(_node\_name_, _\*_, _context\=None_, _cli\_args\=None_, _namespace\=None_, _use\_global\_arguments\=True_, _enable\_rosout\=True_, _start\_parameter\_services\=True_, _parameter\_overrides\=None_, _allow\_undeclared\_parameters\=False_, _automatically\_declare\_parameters\_from\_overrides\=False_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node "Permalink to this definition")

Create a Node.

Parameters

*   **node\_name** (`str`) – A name to give to this node. Validated by `validate_node_name()`.

*   **context** (`Optional`\[[`Context`](https://docs.ros2.org/latest/api/rclpy/api/context.html#rclpy.context.Context "rclpy.context.Context")\
    \]) – The context to be associated with, or `None` for the default global context.

*   **cli\_args** (`Optional`\[`List`\[`str`\]\]) – A list of strings of command line args to be used only by this node. These arguments are used to extract remappings used by the node and other ROS specific settings, as well as user defined non-ROS arguments.

*   **namespace** (`Optional`\[`str`\]) – The namespace to which relative topic and service names will be prefixed. Validated by `validate_namespace()`.

*   **use\_global\_arguments** (`bool`) – `False` if the node should ignore process-wide command line args.

*   **enable\_rosout** (`bool`) – `False` if the node should ignore rosout logging.

*   **start\_parameter\_services** (`bool`) – `False` if the node should not create parameter services.

*   **parameter\_overrides** (`Optional`\[`List`\[[`Parameter`](https://docs.ros2.org/latest/api/rclpy/api/parameters.html#rclpy.parameter.Parameter "rclpy.parameter.Parameter")\
    \]\]) – A list of overrides for initial values for parameters declared on the node.

*   **allow\_undeclared\_parameters** (`bool`) – True if undeclared parameters are allowed. This flag affects the behavior of parameter-related operations.

*   **automatically\_declare\_parameters\_from\_overrides** (`bool`) – If True, the “parameter overrides” will be used to implicitly declare parameters on the node during creation.


`PARAM_REL_TOL` _= 1e-06_[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.PARAM_REL_TOL "Permalink to this definition")

A Node in the ROS graph.

A Node is the primary entrypoint in a ROS system for communication. It can be used to create ROS entities such as publishers, subscribers, services, etc.

`add_on_set_parameters_callback`(_callback_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.add_on_set_parameters_callback "Permalink to this definition")

Add a callback in front to the list of callbacks.

Calling this function will add a callback in self.\_parameter\_callbacks list.

Parameters

**callback** (`Callable`\[\[`List`\[[`Parameter`](https://docs.ros2.org/latest/api/rclpy/api/parameters.html#rclpy.parameter.Parameter "rclpy.parameter.Parameter")\
\]\], `SetParametersResult`\]) – The function that is called whenever parameters are set for the node.

Return type

`None`

`add_waitable`(_waitable_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.add_waitable "Permalink to this definition")

Add a class that is capable of adding things to the wait set.

Parameters

**waitable** (`Waitable`) – An instance of a waitable that the node will add to the waitset.

Return type

`None`

_property_ `clients`[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.clients "Permalink to this definition")

Get clients that have been created on this node.

Return type

`Iterator`\[[`Client`](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.client.Client "rclpy.client.Client")\
\]

_property_ `context`[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.context "Permalink to this definition")

Get the context associated with the node.

Return type

[`Context`](https://docs.ros2.org/latest/api/rclpy/api/context.html#rclpy.context.Context "rclpy.context.Context")

`count_publishers`(_topic\_name_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.count_publishers "Permalink to this definition")

Return the number of publishers on a given topic.

topic\_name may be a relative, private, or fully qualifed topic name. A relative or private topic is expanded using this node’s namespace and name. The queried topic name is not remapped.

Parameters

**topic\_name** (`str`) – the topic\_name on which to count the number of publishers.

Return type

`int`

Returns

the number of publishers on the topic.

`count_subscribers`(_topic\_name_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.count_subscribers "Permalink to this definition")

Return the number of subscribers on a given topic.

topic\_name may be a relative, private, or fully qualifed topic name. A relative or private topic is expanded using this node’s namespace and name. The queried topic name is not remapped.

Parameters

**topic\_name** (`str`) – the topic\_name on which to count the number of subscribers.

Return type

`int`

Returns

the number of subscribers on the topic.

`create_client`(_srv\_type_, _srv\_name_, _\*_, _qos\_profile=<rclpy.qos.QoSProfile object>_, _callback\_group=None_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_client "Permalink to this definition")

Create a new service client.

Parameters

*   **srv\_type** – The service type.

*   **srv\_name** (`str`) – The name of the service.

*   **qos\_profile** ([`QoSProfile`](https://docs.ros2.org/latest/api/rclpy/api/qos.html#rclpy.qos.QoSProfile "rclpy.qos.QoSProfile")
    ) – The quality of service profile to apply the service client.

*   **callback\_group** (`Optional`\[[`CallbackGroup`](https://docs.ros2.org/latest/api/rclpy/api/execution_and_callbacks.html#rclpy.callback_groups.CallbackGroup "rclpy.callback_groups.CallbackGroup")\
    \]) – The callback group for the service client. If `None`, then the nodes default callback group is used.


Return type

[`Client`](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.client.Client "rclpy.client.Client")

`create_guard_condition`(_callback_, _callback\_group\=None_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_guard_condition "Permalink to this definition")

Create a new guard condition.

Return type

`GuardCondition`

`create_publisher`(_msg\_type_, _topic_, _qos\_profile_, _\*_, _callback\_group\=None_, _event\_callbacks\=None_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_publisher "Permalink to this definition")

Create a new publisher.

Parameters

*   **msg\_type** – The type of ROS messages the publisher will publish.

*   **topic** (`str`) – The name of the topic the publisher will publish to.

*   **qos\_profile** (`Union`\[[`QoSProfile`](https://docs.ros2.org/latest/api/rclpy/api/qos.html#rclpy.qos.QoSProfile "rclpy.qos.QoSProfile")\
    , `int`\]) – A QoSProfile or a history depth to apply to the publisher. In the case that a history depth is provided, the QoS history is set to RMW\_QOS\_POLICY\_HISTORY\_KEEP\_LAST, the QoS history depth is set to the value of the parameter, and all other QoS settings are set to their default values.

*   **callback\_group** (`Optional`\[[`CallbackGroup`](https://docs.ros2.org/latest/api/rclpy/api/execution_and_callbacks.html#rclpy.callback_groups.CallbackGroup "rclpy.callback_groups.CallbackGroup")\
    \]) – The callback group for the publisher’s event handlers. If `None`, then the node’s default callback group is used.

*   **event\_callbacks** (`Optional`\[`PublisherEventCallbacks`\]) – User-defined callbacks for middleware events.


Return type

[`Publisher`](https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.publisher.Publisher "rclpy.publisher.Publisher")

Returns

The new publisher.

`create_rate`(_frequency_, _clock\=None_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_rate "Permalink to this definition")

Create a Rate object.

Parameters

*   **frequency** (`float`) – The frequency the Rate runs at (Hz).

*   **clock** (`Optional`\[`Clock`\]) – The clock the Rate gets time from.


Return type

[`Rate`](https://docs.ros2.org/latest/api/rclpy/api/timers.html#rclpy.timer.Rate "rclpy.timer.Rate")

`create_service`(_srv\_type_, _srv\_name_, _callback_, _\*_, _qos\_profile=<rclpy.qos.QoSProfile object>_, _callback\_group=None_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_service "Permalink to this definition")

Create a new service server.

Parameters

*   **srv\_type** – The service type.

*   **srv\_name** (`str`) – The name of the service.

*   **callback** (`Callable`\[\[~SrvTypeRequest, ~SrvTypeResponse\], ~SrvTypeResponse\]) – A user-defined callback function that is called when a service request received by the server.

*   **qos\_profile** ([`QoSProfile`](https://docs.ros2.org/latest/api/rclpy/api/qos.html#rclpy.qos.QoSProfile "rclpy.qos.QoSProfile")
    ) – The quality of service profile to apply the service server.

*   **callback\_group** (`Optional`\[[`CallbackGroup`](https://docs.ros2.org/latest/api/rclpy/api/execution_and_callbacks.html#rclpy.callback_groups.CallbackGroup "rclpy.callback_groups.CallbackGroup")\
    \]) – The callback group for the service server. If `None`, then the nodes default callback group is used.


Return type

[`Service`](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.service.Service "rclpy.service.Service")

`create_subscription`(_msg\_type_, _topic_, _callback_, _qos\_profile_, _\*_, _callback\_group\=None_, _event\_callbacks\=None_, _raw\=False_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_subscription "Permalink to this definition")

Create a new subscription.

Parameters

*   **msg\_type** – The type of ROS messages the subscription will subscribe to.

*   **topic** (`str`) – The name of the topic the subscription will subscribe to.

*   **callback** (`Callable`\[\[~MsgType\], `None`\]) – A user-defined callback function that is called when a message is received by the subscription.

*   **qos\_profile** (`Union`\[[`QoSProfile`](https://docs.ros2.org/latest/api/rclpy/api/qos.html#rclpy.qos.QoSProfile "rclpy.qos.QoSProfile")\
    , `int`\]) – A QoSProfile or a history depth to apply to the subscription. In the case that a history depth is provided, the QoS history is set to RMW\_QOS\_POLICY\_HISTORY\_KEEP\_LAST, the QoS history depth is set to the value of the parameter, and all other QoS settings are set to their default values.

*   **callback\_group** (`Optional`\[[`CallbackGroup`](https://docs.ros2.org/latest/api/rclpy/api/execution_and_callbacks.html#rclpy.callback_groups.CallbackGroup "rclpy.callback_groups.CallbackGroup")\
    \]) – The callback group for the subscription. If `None`, then the nodes default callback group is used.

*   **event\_callbacks** (`Optional`\[`SubscriptionEventCallbacks`\]) – User-defined callbacks for middleware events.

*   **raw** (`bool`) – If `True`, then received messages will be stored in raw binary representation.


Return type

[`Subscription`](https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.subscription.Subscription "rclpy.subscription.Subscription")

`create_timer`(_timer\_period\_sec_, _callback_, _callback\_group\=None_, _clock\=None_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_timer "Permalink to this definition")

Create a new timer.

The timer will be started and every `timer_period_sec` number of seconds the provided callback function will be called.

Parameters

*   **timer\_period\_sec** (`float`) – The period (s) of the timer.

*   **callback** (`Callable`) – A user-defined callback function that is called when the timer expires.

*   **callback\_group** (`Optional`\[[`CallbackGroup`](https://docs.ros2.org/latest/api/rclpy/api/execution_and_callbacks.html#rclpy.callback_groups.CallbackGroup "rclpy.callback_groups.CallbackGroup")\
    \]) – The callback group for the timer. If `None`, then the nodes default callback group is used.

*   **clock** (`Optional`\[`Clock`\]) – The clock which the timer gets time from.


Return type

[`Timer`](https://docs.ros2.org/latest/api/rclpy/api/timers.html#rclpy.timer.Timer "rclpy.timer.Timer")

`declare_parameter`(_name_, _value\=None_, _descriptor\=rcl\_interfaces.msg.ParameterDescriptor(name='', type=0, description='', additional\_constraints='', read\_only=False, floating\_point\_range=\[\], integer\_range=\[\])_, _ignore\_override\=False_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.declare_parameter "Permalink to this definition")

Declare and initialize a parameter.

This method, if successful, will result in any callback registered with [`add_on_set_parameters_callback()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.add_on_set_parameters_callback "rclpy.node.Node.add_on_set_parameters_callback")
 to be called.

Parameters

*   **name** (`str`) – Fully-qualified name of the parameter, including its namespace.

*   **value** (`Optional`\[`Any`\]) – Value of the parameter to declare.

*   **descriptor** (`ParameterDescriptor`) – Descriptor for the parameter to declare.

*   **ignore\_override** (`bool`) – True if overrides shall not be taken into account; False otherwise.


Return type

[`Parameter`](https://docs.ros2.org/latest/api/rclpy/api/parameters.html#rclpy.parameter.Parameter "rclpy.parameter.Parameter")

Returns

Parameter with the effectively assigned value.

Raises

ParameterAlreadyDeclaredException if the parameter had already been declared.

Raises

InvalidParameterException if the parameter name is invalid.

Raises

InvalidParameterValueException if the registered callback rejects the parameter.

`declare_parameters`(_namespace_, _parameters_, _ignore\_override\=False_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.declare_parameters "Permalink to this definition")

Declare a list of parameters.

The tuples in the given parameter list shall contain the name for each parameter, optionally providing a value and a descriptor. For each entry in the list, a parameter with a name of “namespace.name” will be declared. The resulting value for each declared parameter will be returned, considering parameter overrides set upon node creation as the first choice, or provided parameter values as the second one.

The name expansion is naive, so if you set the namespace to be “foo.”, then the resulting parameter names will be like “foo..name”. However, if the namespace is an empty string, then no leading ‘.’ will be placed before each name, which would have been the case when naively expanding “namespace.name”. This allows you to declare several parameters at once without a namespace.

This method, if successful, will result in any callback registered with [`add_on_set_parameters_callback()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.add_on_set_parameters_callback "rclpy.node.Node.add_on_set_parameters_callback")
 to be called once for each parameter. If one of those calls fail, an exception will be raised and the remaining parameters will not be declared. Parameters declared up to that point will not be undeclared.

Parameters

*   **namespace** (`str`) – Namespace for parameters.

*   **parameters** (`List`\[`Union`\[`Tuple`\[`str`\], `Tuple`\[`str`, `Any`\], `Tuple`\[`str`, `Any`, `ParameterDescriptor`\]\]\]) – List of tuples with parameters to declare.

*   **ignore\_override** (`bool`) – True if overrides shall not be taken into account; False otherwise.


Return type

`List`\[[`Parameter`](https://docs.ros2.org/latest/api/rclpy/api/parameters.html#rclpy.parameter.Parameter "rclpy.parameter.Parameter")\
\]

Returns

Parameter list with the effectively assigned values for each of them.

Raises

ParameterAlreadyDeclaredException if the parameter had already been declared.

Raises

InvalidParameterException if the parameter name is invalid.

Raises

InvalidParameterValueException if the registered callback rejects any parameter.

Raises

TypeError if any tuple in [:param:\`parameters\`](https://docs.ros2.org/latest/api/rclpy/api/node.html#id1)
 does not match the annotated type.

_property_ `default_callback_group`[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.default_callback_group "Permalink to this definition")

Get the default callback group.

If no other callback group is provided when the a ROS entity is created with the node, then it is added to the default callback group.

Return type

[`CallbackGroup`](https://docs.ros2.org/latest/api/rclpy/api/execution_and_callbacks.html#rclpy.callback_groups.CallbackGroup "rclpy.callback_groups.CallbackGroup")

`describe_parameter`(_name_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.describe_parameter "Permalink to this definition")

Get the parameter descriptor of a given parameter.

Parameters

**name** (`str`) – Fully-qualified name of the parameter, including its namespace.

Return type

`ParameterDescriptor`

Returns

ParameterDescriptor corresponding to the parameter, or default ParameterDescriptor if parameter had not been declared before and undeclared parameters are allowed.

Raises

ParameterNotDeclaredException if parameter had not been declared before and undeclared parameters are not allowed.

`describe_parameters`(_names_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.describe_parameters "Permalink to this definition")

Get the parameter descriptors of a given list of parameters.

Parameters

**name** – List of fully-qualified names of the parameters to describe.

Return type

`List`\[`ParameterDescriptor`\]

Returns

List of ParameterDescriptors corresponding to the given parameters. Default ParameterDescriptors shall be returned for parameters that had not been declared before if undeclared parameters are allowed.

Raises

ParameterNotDeclaredException if at least one parameter had not been declared before and undeclared parameters are not allowed.

`destroy_client`(_client_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.destroy_client "Permalink to this definition")

Destroy a service client created by the node.

Return type

`bool`

Returns

`True` if successful, `False` otherwise.

`destroy_guard_condition`(_guard_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.destroy_guard_condition "Permalink to this definition")

Destroy a guard condition created by the node.

Return type

`bool`

Returns

`True` if successful, `False` otherwise.

`destroy_node`()[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.destroy_node "Permalink to this definition")

Destroy the node.

Frees resources used by the node, including any entities created by the following methods:

*   [`create_publisher()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_publisher "rclpy.node.Node.create_publisher")

*   [`create_subscription()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_subscription "rclpy.node.Node.create_subscription")

*   [`create_client()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_client "rclpy.node.Node.create_client")

*   [`create_service()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_service "rclpy.node.Node.create_service")

*   [`create_timer()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_timer "rclpy.node.Node.create_timer")

*   [`create_guard_condition()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.create_guard_condition "rclpy.node.Node.create_guard_condition")


Return type

`bool`

`destroy_publisher`(_publisher_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.destroy_publisher "Permalink to this definition")

Destroy a publisher created by the node.

Return type

`bool`

Returns

`True` if successful, `False` otherwise.

`destroy_rate`(_rate_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.destroy_rate "Permalink to this definition")

Destroy a Rate object created by the node.

Returns

`True` if successful, `False` otherwise.

`destroy_service`(_service_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.destroy_service "Permalink to this definition")

Destroy a service server created by the node.

Return type

`bool`

Returns

`True` if successful, `False` otherwise.

`destroy_subscription`(_subscription_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.destroy_subscription "Permalink to this definition")

Destroy a subscription created by the node.

Return type

`bool`

Returns

`True` if succesful, `False` otherwise.

`destroy_timer`(_timer_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.destroy_timer "Permalink to this definition")

Destroy a timer created by the node.

Return type

`bool`

Returns

`True` if successful, `False` otherwise.

_property_ `executor`[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.executor "Permalink to this definition")

Get the executor if the node has been added to one, else return `None`.

Return type

`Optional`\[[`Executor`](https://docs.ros2.org/latest/api/rclpy/api/execution_and_callbacks.html#rclpy.executors.Executor "rclpy.executors.Executor")\
\]

`get_client_names_and_types_by_node`(_node\_name_, _node\_namespace_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_client_names_and_types_by_node "Permalink to this definition")

Get a list of discovered service client topics for a remote node.

Parameters

*   **node\_name** (`str`) – Name of a remote node to get service clients for.

*   **node\_namespace** (`str`) – Namespace of the remote node.


Return type

`List`\[`Tuple`\[`str`, `List`\[`str`\]\]\]

Returns

List of tuples. The fist element of each tuple is the service client name and the second element is a list of service client types.

Raises

*   **NodeNameNonExistentError** – If the node wasn’t found.

*   **RuntimeError** – Unexpected failure.


`get_clock`()[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_clock "Permalink to this definition")

Get the clock used by the node.

Return type

`Clock`

`get_logger`()[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_logger "Permalink to this definition")

Get the nodes logger.

`get_name`()[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_name "Permalink to this definition")

Get the name of the node.

Return type

`str`

`get_namespace`()[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_namespace "Permalink to this definition")

Get the namespace of the node.

Return type

`str`

`get_node_names`()[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_node_names "Permalink to this definition")

Get a list of names for discovered nodes.

Return type

`List`\[`str`\]

Returns

List of node names.

`get_node_names_and_namespaces`()[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_node_names_and_namespaces "Permalink to this definition")

Get a list of names and namespaces for discovered nodes.

Return type

`List`\[`Tuple`\[`str`, `str`\]\]

Returns

List of tuples containing two strings: the node name and node namespace.

`get_node_names_and_namespaces_with_enclaves`()[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_node_names_and_namespaces_with_enclaves "Permalink to this definition")

Get a list of names, namespaces and enclaves for discovered nodes.

Return type

`List`\[`Tuple`\[`str`, `str`, `str`\]\]

Returns

List of tuples containing three strings: the node name, node namespace and enclave.

`get_parameter`(_name_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_parameter "Permalink to this definition")

Get a parameter by name.

Parameters

**name** (`str`) – Fully-qualified name of the parameter, including its namespace.

Return type

[`Parameter`](https://docs.ros2.org/latest/api/rclpy/api/parameters.html#rclpy.parameter.Parameter "rclpy.parameter.Parameter")

Returns

The value for the given parameter name. A default Parameter will be returned for an undeclared parameter if undeclared parameters are allowed.

Raises

ParameterNotDeclaredException if undeclared parameters are not allowed, and the parameter hadn’t been declared beforehand.

`get_parameter_or`(_name_, _alternative\_value\=None_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_parameter_or "Permalink to this definition")

Get a parameter or the alternative value.

If the alternative value is None, a default Parameter with the given name and NOT\_SET type will be returned if the parameter was not declared.

Parameters

*   **name** (`str`) – Fully-qualified name of the parameter, including its namespace.

*   **alternative\_value** (`Optional`\[[`Parameter`](https://docs.ros2.org/latest/api/rclpy/api/parameters.html#rclpy.parameter.Parameter "rclpy.parameter.Parameter")\
    \]) – Alternative parameter to get if it had not been declared before.


Return type

[`Parameter`](https://docs.ros2.org/latest/api/rclpy/api/parameters.html#rclpy.parameter.Parameter "rclpy.parameter.Parameter")

Returns

Requested parameter, or alternative value if it hadn’t been declared before.

`get_parameters`(_names_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_parameters "Permalink to this definition")

Get a list of parameters.

Parameters

**names** (`List`\[`str`\]) – Fully-qualified names of the parameters to get, including their namespaces.

Return type

`List`\[[`Parameter`](https://docs.ros2.org/latest/api/rclpy/api/parameters.html#rclpy.parameter.Parameter "rclpy.parameter.Parameter")\
\]

Returns

The values for the given parameter names. A default Parameter will be returned for undeclared parameters if undeclared parameters are allowed.

Raises

ParameterNotDeclaredException if undeclared parameters are not allowed, and at least one parameter hadn’t been declared beforehand.

`get_parameters_by_prefix`(_prefix_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_parameters_by_prefix "Permalink to this definition")

Get parameters that have a given prefix in their names as a dictionary.

The names which are used as keys in the returned dictionary have the prefix removed. For example, if you use the prefix “foo” and the parameters “foo.ping”, “foo.pong” and “bar.baz” exist, then the returned dictionary will have the keys “ping” and “pong”. Note that the parameter separator is also removed from the parameter name to create the keys.

An empty string for the prefix will match all parameters.

If no parameters with the prefix are found, an empty dictionary will be returned.

Parameters

**prefix** (`str`) – The prefix of the parameters to get.

Return type

`List`\[[`Parameter`](https://docs.ros2.org/latest/api/rclpy/api/parameters.html#rclpy.parameter.Parameter "rclpy.parameter.Parameter")\
\]

Returns

Dict of parameters with the given prefix.

`get_publisher_names_and_types_by_node`(_node\_name_, _node\_namespace_, _no\_demangle\=False_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_publisher_names_and_types_by_node "Permalink to this definition")

Get a list of discovered topics for publishers of a remote node.

Parameters

*   **node\_name** (`str`) – Name of a remote node to get publishers for.

*   **node\_namespace** (`str`) – Namespace of the remote node.

*   **no\_demangle** (`bool`) – If `True`, then topic names and types returned will not be demangled.


Return type

`List`\[`Tuple`\[`str`, `List`\[`str`\]\]\]

Returns

List of tuples. The first element of each tuple is the topic name and the second element is a list of topic types.

Raises

*   **NodeNameNonExistentError** – If the node wasn’t found.

*   **RuntimeError** – Unexpected failure.


`get_publishers_info_by_topic`(_topic\_name_, _no\_mangle\=False_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_publishers_info_by_topic "Permalink to this definition")

Return a list of publishers on a given topic.

The returned parameter is a list of TopicEndpointInfo objects, where each will contain the node name, node namespace, topic type, topic endpoint’s GID, and its QoS profile.

When the no\_mangle parameter is true, the provided topic\_name should be a valid topic name for the middleware (useful when combining ROS with native middleware (e.g. DDS) apps). When the no\_mangle parameter is false, the provided topic\_name should follow ROS topic name conventions.

topic\_name may be a relative, private, or fully qualified topic name. A relative or private topic will be expanded using this node’s namespace and name. The queried topic\_name is not remapped.

Parameters

*   **topic\_name** (`str`) – the topic\_name on which to find the publishers.

*   **no\_mangle** (`bool`) – no\_mangle if true, topic\_name needs to be a valid middleware topic name, otherwise it should be a valid ROS topic name. Defaults to false.


Return type

`List`\[`TopicEndpointInfo`\]

Returns

a list of TopicEndpointInfo for all the publishers on this topic.

`get_service_names_and_types`()[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_service_names_and_types "Permalink to this definition")

Get a list of service topics for the node.

Return type

`List`\[`Tuple`\[`str`, `List`\[`str`\]\]\]

Returns

List of tuples. The first element of each tuple is the service name and the second element is a list of service types.

`get_service_names_and_types_by_node`(_node\_name_, _node\_namespace_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_service_names_and_types_by_node "Permalink to this definition")

Get a list of discovered service server topics for a remote node.

Parameters

*   **node\_name** (`str`) – Name of a remote node to get services for.

*   **node\_namespace** (`str`) – Namespace of the remote node.


Return type

`List`\[`Tuple`\[`str`, `List`\[`str`\]\]\]

Returns

List of tuples. The first element of each tuple is the service server name and the second element is a list of service types.

Raises

*   **NodeNameNonExistentError** – If the node wasn’t found.

*   **RuntimeError** – Unexpected failure.


`get_subscriber_names_and_types_by_node`(_node\_name_, _node\_namespace_, _no\_demangle\=False_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_subscriber_names_and_types_by_node "Permalink to this definition")

Get a list of discovered topics for subscriptions of a remote node.

Parameters

*   **node\_name** (`str`) – Name of a remote node to get subscriptions for.

*   **node\_namespace** (`str`) – Namespace of the remote node.

*   **no\_demangle** (`bool`) – If `True`, then topic names and types returned will not be demangled.


Return type

`List`\[`Tuple`\[`str`, `List`\[`str`\]\]\]

Returns

List of tuples. The first element of each tuple is the topic name and the second element is a list of topic types.

Raises

*   **NodeNameNonExistentError** – If the node wasn’t found.

*   **RuntimeError** – Unexpected failure.


`get_subscriptions_info_by_topic`(_topic\_name_, _no\_mangle\=False_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_subscriptions_info_by_topic "Permalink to this definition")

Return a list of subscriptions on a given topic.

The returned parameter is a list of TopicEndpointInfo objects, where each will contain the node name, node namespace, topic type, topic endpoint’s GID, and its QoS profile.

When the no\_mangle parameter is true, the provided topic\_name should be a valid topic name for the middleware (useful when combining ROS with native middleware (e.g. DDS) apps). When the no\_mangle parameter is false, the provided topic\_name should follow ROS topic name conventions.

topic\_name may be a relative, private, or fully qualified topic name. A relative or private topic will be expanded using this node’s namespace and name. The queried topic\_name is not remapped.

Parameters

*   **topic\_name** (`str`) – the topic\_name on which to find the subscriptions.

*   **no\_mangle** (`bool`) – no\_mangle if true, topic\_name needs to be a valid middleware topic name, otherwise it should be a valid ROS topic name. Defaults to false.


Return type

`List`\[`TopicEndpointInfo`\]

Returns

a list of TopicEndpointInfo for all the subscriptions on this topic.

`get_topic_names_and_types`(_no\_demangle\=False_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.get_topic_names_and_types "Permalink to this definition")

Get a list topic names and types for the node.

Parameters

**no\_demangle** (`bool`) – If `True`, then topic names and types returned will not be demangled.

Return type

`List`\[`Tuple`\[`str`, `List`\[`str`\]\]\]

Returns

List of tuples. The first element of each tuple is the topic name and the second element is a list of topic types.

_property_ `guards`[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.guards "Permalink to this definition")

Get guards that have been created on this node.

Return type

`Iterator`\[`GuardCondition`\]

_property_ `handle`[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.handle "Permalink to this definition")

Get the handle to the underlying rcl\_node\_t.

Cannot be modified after node creation.

Raises

AttributeError if modified after creation.

`has_parameter`(_name_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.has_parameter "Permalink to this definition")

Return True if parameter is declared; False otherwise.

Return type

`bool`

_property_ `publishers`[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.publishers "Permalink to this definition")

Get publishers that have been created on this node.

Return type

`Iterator`\[[`Publisher`](https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.publisher.Publisher "rclpy.publisher.Publisher")\
\]

`remove_on_set_parameters_callback`(_callback_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.remove_on_set_parameters_callback "Permalink to this definition")

Remove a callback from list of callbacks.

Calling this function will remove the callback from self.\_parameter\_callbacks list.

Parameters

**callback** (`Callable`\[\[`List`\[[`Parameter`](https://docs.ros2.org/latest/api/rclpy/api/parameters.html#rclpy.parameter.Parameter "rclpy.parameter.Parameter")\
\]\], `SetParametersResult`\]) – The function that is called whenever parameters are set for the node.

Raises

ValueError if a callback is not present in the list of callbacks.

Return type

`None`

`remove_waitable`(_waitable_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.remove_waitable "Permalink to this definition")

Remove a Waitable that was previously added to the node.

Parameters

**waitable** (`Waitable`) – The Waitable to remove.

Return type

`None`

_property_ `services`[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.services "Permalink to this definition")

Get services that have been created on this node.

Return type

`Iterator`\[[`Service`](https://docs.ros2.org/latest/api/rclpy/api/services.html#rclpy.service.Service "rclpy.service.Service")\
\]

`set_descriptor`(_name_, _descriptor_, _alternative\_value\=None_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.set_descriptor "Permalink to this definition")

Set a new descriptor for a given parameter.

The name in the descriptor is ignored and set to [:param:\`name\`](https://docs.ros2.org/latest/api/rclpy/api/node.html#id3)
.

Parameters

*   **name** (`str`) – Fully-qualified name of the parameter to set the descriptor to.

*   **descriptor** (`ParameterDescriptor`) – New descriptor to apply to the parameter.

*   **alternative\_value** (`Optional`\[`ParameterValue`\]) – Value to set to the parameter if the existing value does not comply with the new descriptor.


Return type

`ParameterValue`

Returns

ParameterValue for the given parameter name after applying the new descriptor.

Raises

ParameterNotDeclaredException if parameter had not been declared before and undeclared parameters are not allowed.

Raises

ParameterImmutableException if the parameter exists and is read-only.

Raises

ParameterValueException if neither the existing value nor the alternative value complies with the provided descriptor.

`set_parameters`(_parameter\_list_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.set_parameters "Permalink to this definition")

Set parameters for the node, and return the result for the set action.

If any parameter in the list was not declared beforehand and undeclared parameters are not allowed for the node, this method will raise a ParameterNotDeclaredException exception.

Parameters are set in the order they are declared in the list. If setting a parameter fails due to not being declared, then the parameters which have already been set will stay set, and no attempt will be made to set the parameters which come after.

If undeclared parameters are allowed, then all the parameters will be implicitly declared before being set even if they were not declared beforehand. Parameter overrides are ignored by this method.

If a callback was registered previously with [`add_on_set_parameters_callback()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.add_on_set_parameters_callback "rclpy.node.Node.add_on_set_parameters_callback")
, it will be called prior to setting the parameters for the node, once for each parameter. If the callback prevents a parameter from being set, then it will be reflected in the returned result; no exceptions will be raised in this case. For each successfully set parameter, a `ParameterEvent` message is published.

If the value type of the parameter is NOT\_SET, and the existing parameter type is something else, then the parameter will be implicitly undeclared.

Parameters

**parameter\_list** (`List`\[[`Parameter`](https://docs.ros2.org/latest/api/rclpy/api/parameters.html#rclpy.parameter.Parameter "rclpy.parameter.Parameter")\
\]) – The list of parameters to set.

Return type

`List`\[`SetParametersResult`\]

Returns

The result for each set action as a list.

Raises

ParameterNotDeclaredException if undeclared parameters are not allowed, and at least one parameter in the list hadn’t been declared beforehand.

`set_parameters_atomically`(_parameter\_list_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.set_parameters_atomically "Permalink to this definition")

Set the given parameters, all at one time, and then aggregate result.

If any parameter in the list was not declared beforehand and undeclared parameters are not allowed for the node, this method will raise a ParameterNotDeclaredException exception.

Parameters are set all at once. If setting a parameter fails due to not being declared, then no parameter will be set set. Either all of the parameters are set or none of them are set.

If undeclared parameters are allowed for the node, then all the parameters will be implicitly declared before being set even if they were not declared beforehand.

If a callback was registered previously with [`add_on_set_parameters_callback()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.add_on_set_parameters_callback "rclpy.node.Node.add_on_set_parameters_callback")
, it will be called prior to setting the parameters for the node only once for all parameters. If the callback prevents the parameters from being set, then it will be reflected in the returned result; no exceptions will be raised in this case. For each successfully set parameter, a `ParameterEvent` message is published.

If the value type of the parameter is NOT\_SET, and the existing parameter type is something else, then the parameter will be implicitly undeclared.

Parameters

**parameter\_list** (`List`\[[`Parameter`](https://docs.ros2.org/latest/api/rclpy/api/parameters.html#rclpy.parameter.Parameter "rclpy.parameter.Parameter")\
\]) – The list of parameters to set.

Return type

`SetParametersResult`

Returns

Aggregate result of setting all the parameters atomically.

Raises

ParameterNotDeclaredException if undeclared parameters are not allowed, and at least one parameter in the list hadn’t been declared beforehand.

`set_parameters_callback`(_callback_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.set_parameters_callback "Permalink to this definition")

Register a set parameters callback.

Deprecated since version Foxy: Use [`add_on_set_parameters_callback()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.add_on_set_parameters_callback "rclpy.node.Node.add_on_set_parameters_callback")
 instead.

Calling this function will add a callback to the self.\_parameter\_callbacks list.

Parameters

**callback** (`Callable`\[\[`List`\[[`Parameter`](https://docs.ros2.org/latest/api/rclpy/api/parameters.html#rclpy.parameter.Parameter "rclpy.parameter.Parameter")\
\]\], `SetParametersResult`\]) – The function that is called whenever parameters are set for the node.

Return type

`None`

_property_ `subscriptions`[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.subscriptions "Permalink to this definition")

Get subscriptions that have been created on this node.

Return type

`Iterator`\[[`Subscription`](https://docs.ros2.org/latest/api/rclpy/api/topics.html#rclpy.subscription.Subscription "rclpy.subscription.Subscription")\
\]

_property_ `timers`[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.timers "Permalink to this definition")

Get timers that have been created on this node.

Return type

`Iterator`\[[`Timer`](https://docs.ros2.org/latest/api/rclpy/api/timers.html#rclpy.timer.Timer "rclpy.timer.Timer")\
\]

`undeclare_parameter`(_name_)[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.undeclare_parameter "Permalink to this definition")

Undeclare a previously declared parameter.

This method will not cause a callback registered with [`add_on_set_parameters_callback()`](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.add_on_set_parameters_callback "rclpy.node.Node.add_on_set_parameters_callback")
 to be called.

Parameters

**name** (`str`) – Fully-qualified name of the parameter, including its namespace.

Raises

ParameterNotDeclaredException if parameter had not been declared before.

Raises

ParameterImmutableException if the parameter was created as read-only.

_property_ `waitables`[¶](https://docs.ros2.org/latest/api/rclpy/api/node.html#rclpy.node.Node.waitables "Permalink to this definition")

Get waitables that have been created on this node.

Return type

`Iterator`\[`Waitable`\]

[rclpy](https://docs.ros2.org/latest/api/rclpy/index.html)

===========================================================

### Navigation

*   [About](https://docs.ros2.org/latest/api/rclpy/about.html)

*   [Examples](https://docs.ros2.org/latest/api/rclpy/examples.html)

*   [API](https://docs.ros2.org/latest/api/rclpy/api.html)
    *   [Initialization, Shutdown, and Spinning](https://docs.ros2.org/latest/api/rclpy/api/init_shutdown.html)

    *   [Node](https://docs.ros2.org/latest/api/rclpy/api/node.html#)

    *   [Topics](https://docs.ros2.org/latest/api/rclpy/api/topics.html)

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
        *   Previous: [Initialization, Shutdown, and Spinning](https://docs.ros2.org/latest/api/rclpy/api/init_shutdown.html "previous chapter")

        *   Next: [Topics](https://docs.ros2.org/latest/api/rclpy/api/topics.html "next chapter")


### Quick search
