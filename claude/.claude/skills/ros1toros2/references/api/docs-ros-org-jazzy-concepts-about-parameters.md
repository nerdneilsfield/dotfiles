---
source_url: https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html
fetched_at: 2026-04-18T10:58:17Z
---

*   [](https://docs.ros.org/en/jazzy/index.html)

*   [Concepts](https://docs.ros.org/en/jazzy/Concepts.html)

*   [Basic Concepts](https://docs.ros.org/en/jazzy/Concepts/Basic.html)

*   Parameters
*   [Edit on GitHub](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Basic/About-Parameters.rst)


* * *

**You're reading the documentation for an older, but still supported, version of ROS 2. For information on the latest version, please have a look at [Kilted](https://docs.ros.org/en/kilted/Concepts/Basic/About-Parameters.html)
.**

Parameters[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#parameters "Link to this heading")

====================================================================================================================

[Overview](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#id1)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#overview "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Parameters in ROS 2 are associated with individual nodes. Parameters are used to configure nodes at startup (and during runtime), without changing the code. The lifetime of a parameter is tied to the lifetime of the node (though the node could implement some sort of persistence to reload values after restart).

Parameters are addressed by node name, node namespace, parameter name, and parameter namespace. Providing a parameter namespace is optional.

Each parameter consists of a key, a value, and a descriptor. The key is a string and the value is one of the following types: `bool`, `int64`, `float64`, `string`, `byte[]`, `bool[]`, `int64[]`, `float64[]` or `string[]`. By default all descriptors are empty, but can contain parameter descriptions, value ranges, type information, and additional constraints.

For a hands-on tutorial with ROS parameters see [Understanding parameters](https://docs.ros.org/en/jazzy/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Parameters/Understanding-ROS2-Parameters.html)
.

[Parameters background](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#id2)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#parameters-background "Link to this heading")

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### [Declaring parameters](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#id3)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#declaring-parameters "Link to this heading")

By default, a node needs to _declare_ all of the parameters that it will accept during its lifetime. This is so that the type and name of the parameters are well-defined at node startup time, which reduces the chances of misconfiguration later on. See [Using parameters in a class (C++)](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html)
 or [Using parameters in a class (Python)](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html)
 for tutorials on declaring and using parameters from a node.

For some types of nodes, not all of the parameters will be known ahead of time. In these cases, the node can be instantiated with `allow_undeclared_parameters` set to `true`, which will allow parameters to be get and set on the node even if they haven’t been declared.

### [Parameter types](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#id4)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#parameter-types "Link to this heading")

Each parameter on a ROS 2 node has one of the pre-defined parameter types as mentioned in the Overview. By default, attempts to change the type of a declared parameter at runtime will fail. This prevents common mistakes, such as putting a boolean value into an integer parameter.

If a parameter needs to be multiple different types, and the code using the parameter can handle it, this default behavior can be changed. When the parameter is declared, it should be declared using a `ParameterDescriptor` with the `dynamic_typing` member variable set to `true`.

### [Parameter callbacks](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#id5)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#parameter-callbacks "Link to this heading")

A ROS 2 node can register three different types of callbacks to be informed when changes are happening to parameters. All three of the callbacks are optional.

The first is known as a “pre set parameter” callback, and can be set by calling `add_pre_set_parameters_callback` from the node API. This callback is passed a list of the `Parameter` objects that are being changed, and returns nothing. When it is called, it can modify the `Parameter` list to change, add, or remove entries. As an example, if `parameter2` should change anytime that `parameter1` changes, that can be implemented with this callback.

The second is known as a “set parameter” callback, and can be set by calling `add_on_set_parameters_callback` from the node API. The callback is passed a list of immutable `Parameter` objects, and returns an `rcl_interfaces/msg/SetParametersResult`. The main purpose of this callback is to give the user the ability to inspect the upcoming change to the parameter and explicitly reject the change.

Note

It is important that “set parameter” callbacks have no side-effects. Since multiple “set parameter” callbacks can be chained, there is no way for an individual callback to know if a later callback will reject the update. If the individual callback were to make changes to the class it is in, for instance, it may get out-of-sync with the actual parameter. To get a callback _after_ a parameter has been successfully changed, see the next type of callback below.

The third type of callback is known as an “post set parameter” callback, and can be set by calling `add_post_set_parameters_callback` from the node API. The callback is passed a list of immutable `Parameter` objects, and returns nothing. The main purpose of this callback is to give the user the ability to react to changes from parameters that have successfully been accepted.

The ROS 2 demos have an [example](https://github.com/ros2/demos/blob/jazzy/demo_nodes_cpp/src/parameters/set_parameters_callback.cpp)
 of all of these callbacks in use.

[Interacting with parameters](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#id6)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#interacting-with-parameters "Link to this heading")

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ROS 2 nodes can perform parameter operations through node APIs as described in [Using parameters in a class (C++)](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html)
 or [Using parameters in a class (Python)](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html)
. External processes can perform parameter operations via parameter services that are created by default when a node is instantiated. The services that are created by default are:

*   `/node_name/describe_parameters`: Uses a service type of `rcl_interfaces/srv/DescribeParameters`. Given a list of parameter names, returns a list of descriptors associated with the parameters.

*   `/node_name/get_parameter_types`: Uses a service type of `rcl_interfaces/srv/GetParameterTypes`. Given a list of parameter names, returns a list of parameter types associated with the parameters.

*   `/node_name/get_parameters`: Uses a service type of `rcl_interfaces/srv/GetParameters`. Given a list of parameter names, returns a list of parameter values associated with the parameters.

*   `/node_name/list_parameters`: Uses a service type of `rcl_interfaces/srv/ListParameters`. Given an optional list of parameter prefixes, returns a list of the available parameters with that prefix. If the prefixes are empty, returns all parameters.

*   `/node_name/set_parameters`: Uses a service type of `rcl_interfaces/srv/SetParameters`. Given a list of parameter names and values, attempts to set the parameters on the node. Returns a list of results from trying to set each parameter; some of them may have succeeded and some may have failed.

*   `/node_name/set_parameters_atomically`: Uses a service type of `rcl_interfaces/srv/SetParametersAtomically`. Given a list of parameter names and values, attempts to set the parameters on the node. Returns a single result from trying to set all parameters, so if one failed, all of them failed.


[Setting initial parameter values when running a node](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#id7)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#setting-initial-parameter-values-when-running-a-node "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Initial parameter values can be set when running the node either through individual command-line arguments, or through YAML files. See [Setting parameters directly from the command line](https://docs.ros.org/en/jazzy/How-To-Guides/Node-arguments.html#nodeargsparameters)
 for examples on how to set initial parameter values.

[Setting initial parameter values when launching nodes](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#id8)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#setting-initial-parameter-values-when-launching-nodes "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Initial parameter values can also be set when running the node through the ROS 2 launch facility. See [this document](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-ROS2-Launch-For-Large-Projects.html)
 for information on how to specify parameters via launch.

[Manipulating parameter values at runtime](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#id9)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#manipulating-parameter-values-at-runtime "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

The `ros2 param` command is the general way to interact with parameters for nodes that are already running. `ros2 param` uses the parameter service API as described above to perform the various operations. See [this how-to guide](https://docs.ros.org/en/jazzy/How-To-Guides/Using-ros2-param.html)
 for details on how to use `ros2 param`.

In addition to the command-line interface, parameters can also be manipulated programmatically at runtime using the ROS 2 client libraries. All client libraries provide APIs to get, set, and react to parameter changes while a node is running.

Client library support includes:

*   **C++ (rclcpp)**: see [Using parameters in a class (C++)](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html)
     and [Monitoring for parameter changes (C++)](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Monitoring-For-Parameter-Changes-CPP.html)
    .

*   **Python (rclpy)**: see [Using parameters in a class (Python)](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html)
     and [Monitoring for parameter changes (Python)](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Monitoring-For-Parameter-Changes-Python.html)
    .


[Migrating from ROS 1](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#id10)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html#migrating-from-ros-1 "Link to this heading")

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

The [Launch file migration guide](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html)
 explains how to migrate `param` and `rosparam` launch tags from ROS 1 to ROS 2.

The [Migration guide](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Parameters.html)
 explains how to migrate parameter from ROS 1 to ROS 2.

Other Versions v: jazzy

Releases

[Kilted (latest)](https://docs.ros.org/en/kilted/Concepts/Basic/About-Parameters.html)

[Jazzy](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Parameters.html)

[Iron (EOL)](https://docs.ros.org/en/iron/Concepts/Basic/About-Parameters.html)

[Humble](https://docs.ros.org/en/humble/Concepts/Basic/About-Parameters.html)

[Galactic (EOL)](https://docs.ros.org/en/galactic/index.html)

[Foxy (EOL)](https://docs.ros.org/en/foxy/index.html)

[Eloquent (EOL)](https://docs.ros.org/en/eloquent/index.html)

[Dashing (EOL)](https://docs.ros.org/en/dashing/index.html)

[Crystal (EOL)](https://docs.ros.org/en/crystal/index.html)

In Development

[Rolling](https://docs.ros.org/en/rolling/Concepts/Basic/About-Parameters.html)
