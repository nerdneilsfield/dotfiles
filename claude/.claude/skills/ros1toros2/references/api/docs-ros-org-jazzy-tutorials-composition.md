---
source_url: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html
fetched_at: 2026-04-18T10:58:41Z
---

*   [](https://docs.ros.org/en/jazzy/index.html)

*   [Tutorials](https://docs.ros.org/en/jazzy/Tutorials.html)

*   [Intermediate](https://docs.ros.org/en/jazzy/Tutorials/Intermediate.html)

*   Composing multiple nodes in a single process
*   [Edit on GitHub](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Tutorials/Intermediate/Composition.rst)


* * *

**You're reading the documentation for an older, but still supported, version of ROS 2. For information on the latest version, please have a look at [Kilted](https://docs.ros.org/en/kilted/Tutorials/Intermediate/Composition.html)
.**

Composing multiple nodes in a single process[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#composing-multiple-nodes-in-a-single-process "Link to this heading")

===========================================================================================================================================================================================

**Goal:** Compose multiple nodes into a single process.

**Tutorial level:** Intermediate

**Time:** 20 minutes

[Background](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id2)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#background "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

See the [conceptual article](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Composition.html)
.

For information on how to write a composable node, [check out this tutorial](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-a-Composable-Node.html)
.

[Prerequisites](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id3)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#prerequisites "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

This tutorial uses executables from the [rclcpp\_components](https://github.com/ros2/rclcpp/tree/jazzy/rclcpp_components)
, [ros2component](https://github.com/ros2/ros2cli/tree/jazzy/ros2component)
, [composition](https://github.com/ros2/demos/tree/jazzy/composition)
, and [image\_tools](https://github.com/ros2/demos/tree/jazzy/image_tools)
 packages. If you’ve followed the [installation instructions](https://docs.ros.org/en/jazzy/Installation.html)
 for your platform, these should already be installed.

[Run the demos](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id4)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#run-the-demos "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### [Discover available components](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id5)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#discover-available-components "Link to this heading")

To see what components are registered and available in the workspace, execute the following in a shell:

$ ros2 component types
(... components of other packages here)
composition
  composition::Talker
  composition::Listener
  composition::NodeLikeListener
  composition::Server
  composition::Client
(... components of other packages here)

Copy to clipboard

### [Run-time composition using ROS services with a publisher and subscriber](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id6)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#run-time-composition-using-ros-services-with-a-publisher-and-subscriber "Link to this heading")

In the first shell, start the component container:

$ ros2 run rclcpp\_components component\_container

Copy to clipboard

Open the second shell and verify that the container is running via `ros2` command line tools. You should see a name of the component:

$ ros2 component list
/ComponentManager

Copy to clipboard

In the second shell load the talker component (see [talker](https://github.com/ros2/demos/blob/jazzy/composition/src/talker_component.cpp)
 source code). The command will return the unique ID of the loaded component as well as the node name:

$ ros2 component load /ComponentManager composition composition::Talker
Loaded component 1 into '/ComponentManager' container node as '/talker'

Copy to clipboard

Now the first shell should show a message that the component was loaded as well as repeated message for publishing a message.

Run another command in the second shell to load the listener component (see [listener](https://github.com/ros2/demos/blob/jazzy/composition/src/listener_component.cpp)
 source code):

$ ros2 component load /ComponentManager composition composition::Listener
Loaded component 2 into '/ComponentManager' container node as '/listener'

Copy to clipboard

The `ros2` command line utility can now be used to inspect the state of the container:

$ ros2 component list
/ComponentManager
   1  /talker
   2  /listener

Copy to clipboard

Now the first shell should show repeated output for each received message.

### [Run-time composition using ROS services with a server and client](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id7)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#run-time-composition-using-ros-services-with-a-server-and-client "Link to this heading")

The example with a server and a client is very similar.

In the first shell:

$ ros2 run rclcpp\_components component\_container

Copy to clipboard

In the second shell (see [server](https://github.com/ros2/demos/blob/jazzy/composition/src/server_component.cpp)
 and [client](https://github.com/ros2/demos/blob/jazzy/composition/src/client_component.cpp)
 source code):

$ ros2 component load /ComponentManager composition composition::Server
$ ros2 component load /ComponentManager composition composition::Client

Copy to clipboard

In this case the client sends a request to the server, the server processes the request and replies with a response, and the client prints the received response.

### [Compile-time composition with hardcoded nodes](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id8)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#compile-time-composition-with-hardcoded-nodes "Link to this heading")

This demo shows that the same shared libraries can be reused to compile a single executable running multiple components without using ROS interfaces. The executable contains all four components from above: talker and listener as well as server and client, which is hardcoded in the main function.

In the shell call (see [source code](https://github.com/ros2/demos/blob/jazzy/composition/src/manual_composition.cpp)
):

$ ros2 run composition manual\_composition

Copy to clipboard

This should show repeated messages from both pairs, the talker and the listener as well as the server and the client.

Note

Manually-composed components will not be reflected in the `ros2 component list` command line tool output.

### [Run-time composition using dlopen](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id9)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#run-time-composition-using-dlopen "Link to this heading")

This demo presents an alternative to run-time composition by creating a generic container process and explicitly passing the libraries to load without using ROS interfaces. The process will open each library and create one instance of each “rclcpp::Node” class in the library ([source code](https://github.com/ros2/demos/blob/jazzy/composition/src/dlopen_composition.cpp)
).

LinuxmacOSWindows

$ ros2 run composition dlopen\_composition \`ros2 pkg prefix composition\`/lib/libtalker\_component.so \`ros2 pkg prefix composition\`/lib/liblistener\_component.so

Copy to clipboard

$ ros2 run composition dlopen\_composition \`ros2 pkg prefix composition\`/lib/libtalker\_component.dylib \`ros2 pkg prefix composition\`/lib/liblistener\_component.dylib

Copy to clipboard

$ ros2 pkg prefix composition

Copy to clipboard

to get the path to where composition is installed. Then call

$ ros2 run composition dlopen\_composition <path\_to\_composition\_install>\\bin\\talker\_component.dll <path\_to\_composition\_install>\\bin\\listener\_component.dll

Copy to clipboard

Now the shell should show repeated output for each sent and received message.

Note

dlopen-composed components will not be reflected in the `ros2 component list` command line tool output.

### [Composition using launch actions](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id10)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#composition-using-launch-actions "Link to this heading")

While the command line tools are useful for debugging and diagnosing component configurations, it is frequently more convenient to start a set of components at the same time. To automate this action, we can use a [launch file](https://github.com/ros2/demos/blob/jazzy/composition/launch/composition_demo_launch.py)
:

$ ros2 launch composition composition\_demo\_launch.py

Copy to clipboard

[Advanced Topics](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id11)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#advanced-topics "Link to this heading")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Now that we have seen the basic operation of components, we can discuss a few more advanced topics.

### [Component container types](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id12)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#component-container-types "Link to this heading")

As introduced in [Component Container](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Composition.html#componentcontainer)
, there are a few component container types with different options. You can choose the most appropriate component container type for your requirement.

*   `component_container` (No options / parameters available)

    > $ ros2 run rclcpp\_components component\_container
    >
    > Copy to clipboard

*   `component_container_mt` with `MultiThreadedExecutor` composed of 4 threads.

    *   `thread_num` parameter option is available to specify the number of threads in `MultiThreadedExecutor`.


    $ ros2 run rclcpp\_components component\_container\_mt \--ros-args \-p thread\_num:\=4

    Copy to clipboard

*   `component_container_isolated` with `MultiThreadedExecutor` for each component.

    *   `--use_multi_threaded_executor` argument specifies executor type used for each component to `MultiThreadedExecutor`.


    $ ros2 run rclcpp\_components component\_container\_isolated \--use\_multi\_threaded\_executor

    Copy to clipboard


### [Unloading components](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id13)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#unloading-components "Link to this heading")

In the first shell, start the component container:

$ ros2 run rclcpp\_components component\_container

Copy to clipboard

Verify that the container is running via `ros2` command line tools:

$ ros2 component list
/ComponentManager

Copy to clipboard

In the second shell load both the talker and listener as we have before:

$ ros2 component load /ComponentManager composition composition::Talker
Loaded component 1 into '/ComponentManager' container node as '/talker'
$ ros2 component load /ComponentManager composition composition::Listener
Loaded component 2 into '/ComponentManager' container node as '/listener'

Copy to clipboard

The unique ID of a component is printed when it gets loaded. You can also get the unique IDs of all components by just listing them now that they are loaded:

$ ros2 component list
/ComponentManager
  1  /talker
  2  /listener

Copy to clipboard

Use the unique ID to unload the component from the component container.

$ ros2 component unload /ComponentManager 1 2
Unloaded component 1 from '/ComponentManager' container
Unloaded component 2 from '/ComponentManager' container

Copy to clipboard

In the first shell, verify that the repeated messages from talker and listener have stopped.

### [Remapping container name and namespace](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id14)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#remapping-container-name-and-namespace "Link to this heading")

The component manager name and namespace can be remapped via standard command line arguments:

$ ros2 run rclcpp\_components component\_container \--ros-args \-r \_\_node:\=MyContainer \-r \_\_ns:\=/ns

Copy to clipboard

In a second shell, components can be loaded by using the updated container name:

$ ros2 component load /ns/MyContainer composition composition::Listener

Copy to clipboard

Note

Namespace remappings of the container do not affect loaded components.

### [Remap component names and namespaces](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id15)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#remap-component-names-and-namespaces "Link to this heading")

Component names and namespaces may be adjusted via arguments to the load command.

In the first shell, start the component container:

$ ros2 run rclcpp\_components component\_container

Copy to clipboard

Some examples of how to remap names and namespaces.

Remap node name:

$ ros2 component load /ComponentManager composition composition::Talker \--node-name talker2

Copy to clipboard

Remap namespace:

$ ros2 component load /ComponentManager composition composition::Talker \--node-namespace /ns

Copy to clipboard

Remap both:

$ ros2 component load /ComponentManager composition composition::Talker \--node-name talker3 \--node-namespace /ns2

Copy to clipboard

Now use `ros2` command line utility:

$ ros2 component list
/ComponentManager
   1  /talker2
   2  /ns/talker
   3  /ns2/talker3

Copy to clipboard

Note

Namespace remappings of the container do not affect loaded components.

### [Passing parameter values into components](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id16)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#passing-parameter-values-into-components "Link to this heading")

The `ros2 component load` command-line supports passing arbitrary parameters to the node as it is constructed. This functionality can be used as follows:

$ ros2 component load /ComponentManager image\_tools image\_tools::Cam2Image \-p burger\_mode:\=true
$ ros2 run rqt\_image\_view rqt\_image\_view  \# Shows burgers bouncing, instead of image from camera

Copy to clipboard

### [Passing additional arguments into components](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id17)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#passing-additional-arguments-into-components "Link to this heading")

The `ros2 component load` command-line supports passing particular options to the component manager for use when constructing the node.

The following example shows the use of the extra arguments `use_intra_process_comms` and `forward_global_arguments`:

$ ros2 component load /ComponentManager composition composition::Talker \-e use\_intra\_process\_comms:\=true \-e forward\_global\_arguments:\=false

Copy to clipboard

The following extra arguments are supported.

|     |     |     |     |
| --- | --- | --- | --- |Extra Arguments for Component Manager[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id1 "Link to this table")

| Argument | Type | Default | Description |
| --- | --- | --- | --- |
| `forward_global_arguments` | Boolean | True | Apply global arguments to the component node when loading. |
| `use_intra_process_comms` | Boolean | False | Enable intra-process communication in the component node. |

[Composable nodes as shared libraries](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id18)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#composable-nodes-as-shared-libraries "Link to this heading")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

If you want to export a composable node as a shared library from a package and use that node in another package that does link-time composition, add code to the CMake file which imports the actual targets in downstream packages.

Then install the generated file and export the generated file.

A practical example can be seen here: [ROS Discourse - Ament best practice for sharing libraries](https://discourse.ros.org/t/ament-best-practice-for-sharing-libraries/3602)

[Composing Non-Node Derived Components](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#id19)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html#composing-non-node-derived-components "Link to this heading")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

In ROS 2, components allow for more efficient use of system resources and provide a powerful feature that enables you to create reusable functionality that is not tied to a specific node.

One advantage of using components is that they allow you to create non-node derived functionality as standalone executables or shared libraries that can be loaded into the ROS system as needed.

To create a component that is not derived from a node, follow these guidelines:

1.  Implement a constructor that takes `const rclcpp::NodeOptions&` as its argument.

2.  Implement the `get_node_base_interface()` method, which should return a `NodeBaseInterface::SharedPtr`. You can use the `get_node_base_interface()` method of a node that you create in your constructor to provide this interface.


Here’s an example of a component that is not derived from a node, which listens to a ROS topic: [node\_like\_listener\_component](https://github.com/ros2/demos/blob/jazzy/composition/src/node_like_listener_component.cpp)
.

For more information on this topic, you can refer to this [discussion](https://github.com/ros2/rclcpp/issues/2110#issuecomment-1454228192)
.

Other Versions v: jazzy

Releases

[Kilted (latest)](https://docs.ros.org/en/kilted/Tutorials/Intermediate/Composition.html)

[Jazzy](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Composition.html)

[Iron (EOL)](https://docs.ros.org/en/iron/Tutorials/Intermediate/Composition.html)

[Humble](https://docs.ros.org/en/humble/Tutorials/Intermediate/Composition.html)

[Galactic (EOL)](https://docs.ros.org/en/galactic/Tutorials/Intermediate/Composition.html)

[Foxy (EOL)](https://docs.ros.org/en/foxy/Tutorials/Intermediate/Composition.html)

[Eloquent (EOL)](https://docs.ros.org/en/eloquent/index.html)

[Dashing (EOL)](https://docs.ros.org/en/dashing/index.html)

[Crystal (EOL)](https://docs.ros.org/en/crystal/index.html)

In Development

[Rolling](https://docs.ros.org/en/rolling/Tutorials/Intermediate/Composition.html)
