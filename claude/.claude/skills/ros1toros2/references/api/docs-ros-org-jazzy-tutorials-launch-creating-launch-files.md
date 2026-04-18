---
source_url: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html
fetched_at: 2026-04-18T10:58:43Z
---

*   [](https://docs.ros.org/en/jazzy/index.html)

*   [Tutorials](https://docs.ros.org/en/jazzy/Tutorials.html)

*   [Intermediate](https://docs.ros.org/en/jazzy/Tutorials/Intermediate.html)

*   [Launch](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Launch-Main.html)

*   Creating a launch file
*   [Edit on GitHub](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Tutorials/Intermediate/Launch/Creating-Launch-Files.rst)


* * *

**You're reading the documentation for an older, but still supported, version of ROS 2. For information on the latest version, please have a look at [Kilted](https://docs.ros.org/en/kilted/Tutorials/Intermediate/Launch/Creating-Launch-Files.html)
.**

Creating a launch file[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#creating-a-launch-file "Link to this heading")

================================================================================================================================================================

**Goal:** Create a launch file to run a complex ROS 2 system.

**Tutorial level:** Intermediate

**Time:** 10 minutes

[Prerequisites](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#id1)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#prerequisites "Link to this heading")

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

This tutorial uses the [rqt\_graph and turtlesim](https://docs.ros.org/en/jazzy/Tutorials/Beginner-CLI-Tools/Introducing-Turtlesim/Introducing-Turtlesim.html)
 packages.

You will also need to use a text editor of your preference.

As always, don’t forget to source ROS 2 in [every new terminal you open](https://docs.ros.org/en/jazzy/Tutorials/Beginner-CLI-Tools/Configuring-ROS2-Environment.html)
.

[Background](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#id2)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#background "Link to this heading")

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

The launch system in ROS 2 is responsible for helping the user describe the configuration of their system and then execute it as described. The configuration of the system includes what programs to run, where to run them, what arguments to pass them, and ROS-specific conventions which make it easy to reuse components throughout the system by giving them each a different configuration. It is also responsible for monitoring the state of the processes launched, and reporting and/or reacting to changes in the state of those processes.

Launch files written in XML, YAML, or Python can start and stop different nodes as well as trigger and act on various events. See [Using XML, YAML, and Python for ROS 2 Launch Files](https://docs.ros.org/en/jazzy/How-To-Guides/Launch-file-different-formats.html)
 for a description of the different formats. The package providing this framework is `launch_ros`, which uses the non-ROS-specific `launch` framework underneath.

The [design document](https://design.ros2.org/articles/roslaunch.html)
 details the goal of the design of ROS 2’s launch system (not all functionality is currently available).

[Tasks](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#id3)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#tasks "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### [1 Setup](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#id4)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#setup "Link to this heading")

Create a new directory to store your launch files:

$ mkdir launch

Copy to clipboard

### [2 Write the launch file](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#id5)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#write-the-launch-file "Link to this heading")

Let’s put together a ROS 2 launch file using the `turtlesim` package and its executables. As mentioned above, this can either be in XML, YAML, or Python.

XMLYAMLPython

Copy and paste the complete code into the `launch/turtlesim_mimic_launch.xml` file:

<?xml version="1.0" encoding="UTF-8"?>
<launch>
  <node pkg="turtlesim" exec="turtlesim\_node" name="sim" namespace="turtlesim1" args="--ros-args --log-level info" />
  <node pkg="turtlesim" exec="turtlesim\_node" name="sim" namespace="turtlesim2" ros\_args="--log-level warn" />
  <node pkg="turtlesim" exec="mimic" name="mimic"\>
    <remap from="/input/pose" to="/turtlesim1/turtle1/pose" />
    <remap from="/output/cmd\_vel" to="/turtlesim2/turtle1/cmd\_vel" />
  </node>
</launch>

Copy to clipboard

Copy and paste the complete code into the `launch/turtlesim_mimic_launch.yaml` file:

%YAML 1.2
\---
launch:
  \- node:
      pkg: "turtlesim"
      exec: "turtlesim\_node"
      name: "sim"
      namespace: "turtlesim1"
      args: "--ros-args \--log-level info"

  \- node:
      pkg: "turtlesim"
      exec: "turtlesim\_node"
      name: "sim"
      namespace: "turtlesim2"
      ros\_args: "--log-level warn"

  \- node:
      pkg: "turtlesim"
      exec: "mimic"
      name: "mimic"
      remap:
        \- from: "/input/pose"
          to: "/turtlesim1/turtle1/pose"
        \- from: "/output/cmd\_vel"
          to: "/turtlesim2/turtle1/cmd\_vel"

Copy to clipboard

Copy and paste the complete code into the `launch/turtlesim_mimic_launch.py` file:

from launch import LaunchDescription
from launch\_ros.actions import Node

def generate\_launch\_description():
    return LaunchDescription(\[\
        Node(\
            package\='turtlesim',\
            namespace\='turtlesim1',\
            executable\='turtlesim\_node',\
            name\='sim',\
            arguments\=\['--ros-args', '--log-level', 'info'\]\
        ),\
        Node(\
            package\='turtlesim',\
            namespace\='turtlesim2',\
            executable\='turtlesim\_node',\
            name\='sim',\
            ros\_arguments\=\['--log-level', 'warn'\]\
        ),\
        Node(\
            package\='turtlesim',\
            executable\='mimic',\
            name\='mimic',\
            remappings\=\[\
                ('/input/pose', '/turtlesim1/turtle1/pose'),\
                ('/output/cmd\_vel', '/turtlesim2/turtle1/cmd\_vel'),\
            \]\
        )\
    \])

Copy to clipboard

#### 2.1 Examine the launch file[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#examine-the-launch-file "Link to this heading")

All of the launch files above are launching a system of three nodes, all from the `turtlesim` package. The goal of the system is to launch two turtlesim windows, and have one turtle mimic the movements of the other.

When launching the two turtlesim nodes, the primary difference between them is their namespace values. Unique namespaces allow the system to start two nodes without node name or topic name conflicts. Both turtles in this system receive commands over the same topic and publish their pose over the same topic. With unique namespaces, messages meant for different turtles can be distinguished.

The two turtlesim nodes also demonstrate different ways to pass arguments to nodes. The first node uses `args` to pass arguments directly to the executable, requiring the `--ros-args` flag for ROS-specific arguments. The second node uses `ros_args` (`ros_arguments` in Python), designed specifically for ROS arguments. Use `args` when mixing ROS and non-ROS arguments (e.g., `my_custom_arg --ros-args --log-level info`), or `ros_args` for cleaner syntax with only ROS arguments like remappings, parameters, or log levels.

The final node is also from the `turtlesim` package, but a different executable: `mimic`. This node has added configuration details in the form of remappings. `mimic`’s `/input/pose` topic is remapped to `/turtlesim1/turtle1/pose` and it’s `/output/cmd_vel` topic to `/turtlesim2/turtle1/cmd_vel`. This means `mimic` will subscribe to `/turtlesim1/sim`’s pose topic and republish it for `/turtlesim2/sim`’s velocity command topic to subscribe to. In other words, `turtlesim2` will mimic `turtlesim1`’s movements.

XMLYAMLPython

The first two actions launch the two turtlesim windows with different argument passing approaches:

  <node pkg="turtlesim" exec="turtlesim\_node" name="sim" namespace="turtlesim1" args="--ros-args --log-level info" />
  <node pkg="turtlesim" exec="turtlesim\_node" name="sim" namespace="turtlesim2" ros\_args="--log-level warn" />

Copy to clipboard

The final action launches the mimic node with the remaps:

  <node pkg="turtlesim" exec="mimic" name="mimic"\>
    <remap from="/input/pose" to="/turtlesim1/turtle1/pose" />
    <remap from="/output/cmd\_vel" to="/turtlesim2/turtle1/cmd\_vel" />
  </node>

Copy to clipboard

The first two actions launch the two turtlesim windows with different argument passing approaches:

  \- node:
      pkg: "turtlesim"
      exec: "turtlesim\_node"
      name: "sim"
      namespace: "turtlesim1"
      args: "--ros-args \--log-level info"

  \- node:
      pkg: "turtlesim"
      exec: "turtlesim\_node"
      name: "sim"
      namespace: "turtlesim2"
      ros\_args: "--log-level warn"

Copy to clipboard

The final action launches the mimic node with the remaps:

  \- node:
      pkg: "turtlesim"
      exec: "mimic"
      name: "mimic"
      remap:
        \- from: "/input/pose"
          to: "/turtlesim1/turtle1/pose"
        \- from: "/output/cmd\_vel"
          to: "/turtlesim2/turtle1/cmd\_vel"

Copy to clipboard

These import statements pull in some Python `launch` modules.

from launch import LaunchDescription
from launch\_ros.actions import Node

Copy to clipboard

Next, the launch description itself begins:

def generate\_launch\_description():
    return LaunchDescription(\[\
    \])

Copy to clipboard

The first two actions in the launch description launch the two turtlesim windows with different argument passing approaches:

        Node(
            package\='turtlesim',
            namespace\='turtlesim1',
            executable\='turtlesim\_node',
            name\='sim',
            arguments\=\['--ros-args', '--log-level', 'info'\]
        ),
        Node(
            package\='turtlesim',
            namespace\='turtlesim2',
            executable\='turtlesim\_node',
            name\='sim',
            ros\_arguments\=\['--log-level', 'warn'\]
        ),

Copy to clipboard

The final action launches the mimic node with the remaps:

        Node(
            package\='turtlesim',
            executable\='mimic',
            name\='mimic',
            remappings\=\[\
                ('/input/pose', '/turtlesim1/turtle1/pose'),\
                ('/output/cmd\_vel', '/turtlesim2/turtle1/cmd\_vel'),\
            \]
        )

Copy to clipboard

### [3 ros2 launch](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#id6)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#ros2-launch "Link to this heading")

To run the launch file created above, enter into the directory you created earlier and run the following command:

XMLYAMLPython

$ cd launch
$ ros2 launch turtlesim\_mimic\_launch.xml

Copy to clipboard

$ cd launch
$ ros2 launch turtlesim\_mimic\_launch.yaml

Copy to clipboard

$ cd launch
$ ros2 launch turtlesim\_mimic\_launch.py

Copy to clipboard

Note

It is possible to launch a launch file directly (as we do above), or provided by a package. When it is provided by a package, the syntax is:

$ ros2 launch <package\_name> <launch\_file\_name>

Copy to clipboard

You learned about creating packages in [Creating a package](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Creating-Your-First-ROS2-Package.html)
.

Note

For packages with launch files, it is a good idea to add an `exec_depend` dependency on the `ros2launch` package in your package’s `package.xml`:

<exec\_depend>ros2launch</exec\_depend>

Copy to clipboard

This helps make sure that the `ros2 launch` command is available after building your package. It also ensures that all [launch file formats](https://docs.ros.org/en/jazzy/How-To-Guides/Launch-file-different-formats.html)
 are recognized.

Two turtlesim windows will open, and you will see the following `[INFO]` messages telling you which nodes your launch file has started:

\[INFO\] \[launch\]: Default logging verbosity is set to INFO
\[INFO\] \[turtlesim\_node-1\]: process started with pid \[11714\]
\[INFO\] \[turtlesim\_node-2\]: process started with pid \[11715\]
\[INFO\] \[mimic-3\]: process started with pid \[11716\]

Copy to clipboard

To see the system in action, open a new terminal and run the `ros2 topic pub` command on the `/turtlesim1/turtle1/cmd_vel` topic to get the first turtle moving:

$ ros2 topic pub \-r 1 /turtlesim1/turtle1/cmd\_vel geometry\_msgs/msg/Twist "{linear: {x: 2.0, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: -1.8}}"

Copy to clipboard

You will see both turtles following the same path.

![../../../_images/mimic.png](https://docs.ros.org/en/jazzy/_images/mimic.png)

### [4 Introspect the system with rqt\_graph](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#id7)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#introspect-the-system-with-rqt-graph "Link to this heading")

While the system is still running, open a new terminal and run `rqt_graph` to get a better idea of the relationship between the nodes in your launch file.

Run the command:

$ ros2 run rqt\_graph rqt\_graph

Copy to clipboard

![../../../_images/mimic_graph.png](https://docs.ros.org/en/jazzy/_images/mimic_graph.png)

A hidden node (the `ros2 topic pub` command you ran) is publishing data to the `/turtlesim1/turtle1/cmd_vel` topic on the left, which the `/turtlesim1/sim` node is subscribed to. The rest of the graph shows what was described earlier: `mimic` is subscribed to `/turtlesim1/sim`’s pose topic, and publishes to `/turtlesim2/sim`’s velocity command topic.

[Summary](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#id8)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html#summary "Link to this heading")

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Launch files simplify running complex systems with many nodes and specific configuration details. You can create launch files using XML, YAML, or Python, and run them using the `ros2 launch` command.

Other Versions v: jazzy

Releases

[Kilted (latest)](https://docs.ros.org/en/kilted/Tutorials/Intermediate/Launch/Creating-Launch-Files.html)

[Jazzy](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html)

[Iron (EOL)](https://docs.ros.org/en/iron/Tutorials/Intermediate/Launch/Creating-Launch-Files.html)

[Humble](https://docs.ros.org/en/humble/Tutorials/Intermediate/Launch/Creating-Launch-Files.html)

[Galactic (EOL)](https://docs.ros.org/en/galactic/Tutorials/Intermediate/Launch/Creating-Launch-Files.html)

[Foxy (EOL)](https://docs.ros.org/en/foxy/Tutorials/Intermediate/Launch/Creating-Launch-Files.html)

[Eloquent (EOL)](https://docs.ros.org/en/eloquent/index.html)

[Dashing (EOL)](https://docs.ros.org/en/dashing/index.html)

[Crystal (EOL)](https://docs.ros.org/en/crystal/index.html)

In Development

[Rolling](https://docs.ros.org/en/rolling/Tutorials/Intermediate/Launch/Creating-Launch-Files.html)
