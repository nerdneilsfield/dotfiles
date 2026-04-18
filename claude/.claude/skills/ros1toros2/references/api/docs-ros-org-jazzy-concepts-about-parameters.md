---
source_url: https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html
fetched_at: 2026-04-18T00:00:00Z
---

# Parameters — ROS 2 Documentation: Jazzy  documentation

Parameters — ROS 2 Documentation: Jazzy  documentation

-
- Concepts
- Basic Concepts
- Parameters
-  Edit on GitHub


You're reading the documentation for an older, but still supported, version of ROS 2.
For information on the latest version, please have a look at Kilted.



Parameters

Overview

Parameters in ROS 2 are associated with individual nodes.
Parameters are used to configure nodes at startup (and during runtime), without changing the code.
The lifetime of a parameter is tied to the lifetime of the node (though the node could implement some sort of persistence to reload values after restart).

Parameters are addressed by node name, node namespace, parameter name, and parameter namespace.
Providing a parameter namespace is optional.

Each parameter consists of a key, a value, and a descriptor.
The key is a string and the value is one of the following types: `bool`, `int64`, `float64`, `string`, `byte[]`, `bool[]`, `int64[]`, `float64[]` or `string[]`.
By default all descriptors are empty, but can contain parameter descriptions, value ranges, type information, and additional constraints.

For a hands-on tutorial with ROS parameters see Understanding parameters.

Parameters background

Declaring parameters

By default, a node needs to declare all of the parameters that it will accept during its lifetime.
This is so that the type and name of the parameters are well-defined at node startup time, which reduces the chances of misconfiguration later on.
See Using parameters in a class (C++) or Using parameters in a class (Python) for tutorials on declaring and using parameters from a node.

For some types of nodes, not all of the parameters will be known ahead of time.
In these cases, the node can be instantiated with `allow_undeclared_parameters` set to `true`, which will allow parameters to be get and set on the node even if they haven’t been declared.

Parameter types

Each parameter on a ROS 2 node has one of the pre-defined parameter types as mentioned in the Overview.
By default, attempts to change the type of a declared parameter at runtime will fail.
This prevents common mistakes, such as putting a boolean value into an integer parameter.

If a parameter needs to be multiple different types, and the code using the parameter can handle it, this default behavior can be changed.
When the parameter is declared, it should be declared using a `ParameterDescriptor` with the `dynamic_typing` member variable set to `true`.

Parameter callbacks

A ROS 2 node can register three different types of callbacks to be informed when changes are happening to parameters.
All three of the callbacks are optional.

The first is known as a “pre set parameter” callback, and can be set by calling `add_pre_set_parameters_callback` from the node API.
This callback is passed a list of the `Parameter` objects that are being changed, and returns nothing.
When it is called, it can modify the `Parameter` list to change, add, or remove entries.
As an example, if `parameter2` should change anytime that `parameter1` changes, that can be implemented with this callback.

The second is known as a “set parameter” callback, and can be set by calling `add_on_set_parameters_callback` from the node API.
The callback is passed a list of immutable `Parameter` objects, and returns an `rcl_interfaces/msg/SetParametersResult`.
The main purpose of this callback is to give the user the ability to inspect the upcoming change to the parameter and explicitly reject the change.

Note

It is important that “set parameter” callbacks have no side-effects.
Since multiple “set parameter” callbacks can be chained, there is no way for an individual callback to know if a later callback will reject the update.
If the individual callback were to make changes to the class it is in, for instance, it may get out-of-sync with the actual parameter.
To get a callback after a parameter has been successfully changed, see the next type of callback below.

The third type of callback is known as an “post set parameter” callback, and can be set by calling `add_post_set_parameters_callback` from the node API.
The callback is passed a list of immutable `Parameter` objects, and returns nothing.
The main purpose of this callback is to give the user the ability to react to changes from parameters that have successfully been accepted.

The ROS 2 demos have an example of all of these callbacks in use.

Interacting with parameters

ROS 2 nodes can perform parameter operations through node APIs as described in Using parameters in a class (C++) or Using parameters in a class (Python).
External processes can perform parameter operations via parameter services that are created by default when a node is instantiated.
The services that are created by default are:

-
`/node_name/describe_parameters`: Uses a service type of `rcl_interfaces/srv/DescribeParameters`.
Given a list of parameter names, returns a list of descriptors associated with the parameters.

-
`/node_name/get_parameter_types`: Uses a service type of `rcl_interfaces/srv/GetParameterTypes`.
Given a list of parameter names, returns a list of parameter types associated with the parameters.

-
`/node_name/get_parameters`: Uses a service type of `rcl_interfaces/srv/GetParameters`.
Given a list of parameter names, returns a list of parameter values associated with the parameters.

-
`/node_name/list_parameters`: Uses a service type of `rcl_interfaces/srv/ListParameters`.
Given an optional list of parameter prefixes, returns a list of the available parameters with that prefix.
If the prefixes are empty, returns all parameters.

-
`/node_name/set_parameters`: Uses a service type of `rcl_interfaces/srv/SetParameters`.
Given a list of parameter names and values, attempts to set the parameters on the node.
Returns a list of results from trying to set each parameter; some of them may have succeeded and some may have failed.

-
`/node_name/set_parameters_atomically`: Uses a service type of `rcl_interfaces/srv/SetParametersAtomically`.
Given a list of parameter names and values, attempts to set the parameters on the node.
Returns a single result from trying to set all parameters, so if one failed, all of them failed.

Setting initial parameter values when running a node

Initial parameter values can be set when running the node either through individual command-line arguments, or through YAML files.
See Setting parameters directly from the command line for examples on how to set initial parameter values.

Setting initial parameter values when launching nodes

Initial parameter values can also be set when running the node through the ROS 2 launch facility.
See this document for information on how to specify parameters via launch.

Manipulating parameter values at runtime

The `ros2param` command is the general way to interact with parameters for nodes that are already running.
`ros2param` uses the parameter service API as described above to perform the various operations.
See this how-to guide for details on how to use `ros2param`.

In addition to the command-line interface, parameters can also be manipulated programmatically at runtime using the ROS 2 client libraries.
All client libraries provide APIs to get, set, and react to parameter changes while a node is running.
Client library support includes:

-
C++ (rclcpp): see Using parameters in a class (C++) and Monitoring for parameter changes (C++).

-
Python (rclpy): see Using parameters in a class (Python) and Monitoring for parameter changes (Python).

Migrating from ROS 1

The Launch file migration guide explains how to migrate `param` and `rosparam` launch tags from ROS 1 to ROS 2.

The Migration guide explains how to migrate parameter from ROS 1 to ROS 2.

PreviousNext

© Copyright 2026, Open Robotics.

Built with Sphinx using a
theme
provided by Read the Docs.


Other Versions
v: jazzy

ReleasesKilted (latest)JazzyIron (EOL)HumbleGalactic (EOL)Foxy (EOL)Eloquent (EOL)Dashing (EOL)Crystal (EOL)In DevelopmentRolling
