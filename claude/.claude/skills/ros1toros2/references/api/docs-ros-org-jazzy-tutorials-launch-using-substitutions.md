---
source_url: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html
fetched_at: 2026-04-18T10:58:49Z
---

*   [](https://docs.ros.org/en/jazzy/index.html)

*   [Tutorials](https://docs.ros.org/en/jazzy/Tutorials.html)

*   [Intermediate](https://docs.ros.org/en/jazzy/Tutorials/Intermediate.html)

*   [Launch](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Launch-Main.html)

*   Using substitutions
*   [Edit on GitHub](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Tutorials/Intermediate/Launch/Using-Substitutions.rst)


* * *

**You're reading the documentation for an older, but still supported, version of ROS 2. For information on the latest version, please have a look at [Kilted](https://docs.ros.org/en/kilted/Tutorials/Intermediate/Launch/Using-Substitutions.html)
.**

Using substitutions[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#using-substitutions "Link to this heading")

========================================================================================================================================================

**Goal:** Learn about substitutions in ROS 2 launch files.

**Tutorial level:** Intermediate

**Time:** 15 minutes

[Background](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#id2)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#background "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Launch files are used to start nodes, services and execute processes. This set of actions may have arguments, which affect their behavior. Substitutions can be used in arguments to provide more flexibility when describing reusable launch files. Substitutions are variables that are only evaluated during execution of the launch description and can be used to acquire specific information like a launch configuration, an environment variable, or to evaluate an arbitrary Python expression.

This tutorial shows usage examples of substitutions in ROS 2 launch files.

[Prerequisites](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#id3)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#prerequisites "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

This tutorial uses the [turtlesim](https://docs.ros.org/en/jazzy/Tutorials/Beginner-CLI-Tools/Introducing-Turtlesim/Introducing-Turtlesim.html)
 package. This tutorial also assumes you are familiar with [creating packages](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Creating-Your-First-ROS2-Package.html)
.

As always, don’t forget to source ROS 2 in [every new terminal you open](https://docs.ros.org/en/jazzy/Tutorials/Beginner-CLI-Tools/Configuring-ROS2-Environment.html)
.

[Using substitutions](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#id4)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#id1 "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### [1 Create and setup the package](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#id5)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#create-and-setup-the-package "Link to this heading")

First, create a new package with the name `launch_tutorial`:

Python packageC++ package

Create a new package of build\_type `ament_python`:

$ ros2 pkg create \--build-type ament\_python \--license Apache-2.0 launch\_tutorial

Copy to clipboard

Create a new package of build\_type `ament_cmake`:

$ ros2 pkg create \--build-type ament\_cmake \--license Apache-2.0 launch\_tutorial

Copy to clipboard

Inside of that package, create a directory called `launch`:

LinuxmacOSWindows

$ mkdir launch\_tutorial/launch

Copy to clipboard

$ mkdir launch\_tutorial/launch

Copy to clipboard

$ md launch\_tutorial/launch

Copy to clipboard

Finally, make sure to install the launch files:

Python packageC++ package

Add in following changes to the `setup.py` of the package:

import os
from glob import glob
from setuptools import find\_packages, setup

package\_name \= 'launch\_tutorial'

setup(
    \# Other parameters ...
    data\_files\=\[\
        \# ... Other data files\
        \# Include all launch files.\
        (os.path.join('share', package\_name, 'launch'), glob('launch/\*'))\
    \]
)

Copy to clipboard

Append following code to the `CMakeLists.txt` just before `ament_package()`:

install(DIRECTORY
        launch
        DESTINATION share/${PROJECT\_NAME}/
)

Copy to clipboard

### [2 Parent launch file](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#id6)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#parent-launch-file "Link to this heading")

Let’s create a launch file that will call and pass arguments to another launch file. This launch file can either be in YAML, XML, or in Python.

To do this, create following file in the `launch` folder of the `launch_tutorial` package.

XMLYAMLPython

Copy and paste the complete code into the `launch/example_main_launch.xml` file:

<?xml version="1.0" encoding="UTF-8"?>
<launch>
  <let name="background\_r" value="200" />
  <include file="$(find-pkg-share launch\_tutorial)/launch/example\_substitutions\_launch.xml"\>
    <let name="turtlesim\_ns" value="turtlesim2" />
    <let name="use\_provided\_red" value="True" />
    <let name="new\_background\_r" value="$(var background\_r)" />
  </include>
</launch>

Copy to clipboard

The `$(find-pkg-share launch_tutorial)` substitution is used to find the path to the `launch_tutorial` package. The path substitution is then joined with the `example_substitutions_launch.xml` file name.

  <include file="$(find-pkg-share launch\_tutorial)/launch/example\_substitutions\_launch.xml"\>

Copy to clipboard

The `background_r` variable with `turtlesim_ns` and `use_provided_red` arguments is passed to the `include` action. The `$(var background_r)` substitution is used to define the `new_background_r` argument with the value of the `background_r` variable.

    <let name="turtlesim\_ns" value="turtlesim2" />
    <let name="use\_provided\_red" value="True" />
    <let name="new\_background\_r" value="$(var background\_r)" />

Copy to clipboard

Copy and paste the complete code into the `launch/example_main_launch.yaml` file:

%YAML 1.2
\---
launch:
  \- let:
      name: "background\_r"
      value: "200"
  \- include:
      file: "$(find-pkg-share launch\_tutorial)/launch/example\_substitutions\_launch.yaml"
      let:
        \- name: "turtlesim\_ns"
          value: "turtlesim2"
        \- name: "use\_provided\_red"
          value: "True"
        \- name: "new\_background\_r"
          value: "$(var background\_r)"

Copy to clipboard

The `$(find-pkg-share launch_tutorial)` substitution is used to find the path to the `launch_tutorial` package. The path substitution is then joined with the `example_substitutions_launch.yaml` file name.

      file: "$(find-pkg-share launch\_tutorial)/launch/example\_substitutions\_launch.yaml"

Copy to clipboard

The `background_r` variable with `turtlesim_ns` and `use_provided_red` arguments is passed to the `include` action. The `$(var background_r)` substitution is used to define the `new_background_r` argument with the value of the `background_r` variable.

      let:
        \- name: "turtlesim\_ns"
          value: "turtlesim2"
        \- name: "use\_provided\_red"
          value: "True"
        \- name: "new\_background\_r"
          value: "$(var background\_r)"

Copy to clipboard

Copy and paste the complete code into the `launch/example_main_launch.py` file:

from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
from launch.substitutions import PathJoinSubstitution
from launch\_ros.substitutions import FindPackageShare

def generate\_launch\_description():
    colors \= {
        'background\_r': '200'
    }

    return LaunchDescription(\[\
        IncludeLaunchDescription(\
            PathJoinSubstitution(\[\
                FindPackageShare('launch\_tutorial'),\
                'launch',\
                'example\_substitutions\_launch.py'\
            \]),\
            launch\_arguments\={\
                'turtlesim\_ns': 'turtlesim2',\
                'use\_provided\_red': 'True',\
                'new\_background\_r': colors\['background\_r'\],\
            }.items()\
        )\
    \])

Copy to clipboard

The `FindPackageShare` substitution is used to find the path to the `launch_tutorial` package. The `PathJoinSubstitution` substitution is then used to join the path to that package path with the `example_substitutions_launch.py` file name.

            PathJoinSubstitution(\[\
                FindPackageShare('launch\_tutorial'),\
                'launch',\
                'example\_substitutions\_launch.py'\
            \]),

Copy to clipboard

The `launch_arguments` dictionary with `turtlesim_ns` and `use_provided_red` arguments is passed to the `IncludeLaunchDescription` action.

            launch\_arguments\={
                'turtlesim\_ns': 'turtlesim2',
                'use\_provided\_red': 'True',
                'new\_background\_r': colors\['background\_r'\],
            }.items()

Copy to clipboard

### [3 Substitutions example launch file](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#id7)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#substitutions-example-launch-file "Link to this heading")

Now create the substitution launch file in the same folder:

XMLYAMLPython

Create the file `launch/example_substitutions_launch.xml` and insert the following code:

<?xml version="1.0" encoding="UTF-8"?>
<launch>
  <arg name="turtlesim\_ns" default="turtlesim1" />
  <arg name="use\_provided\_red" default="False" />
  <arg name="new\_background\_r" default="200" />

  <node pkg="turtlesim" namespace="$(var turtlesim\_ns)" exec="turtlesim\_node" name="sim" />
  <executable cmd="ros2 service call $(var turtlesim\_ns)/spawn turtlesim/srv/Spawn '{x: 5, y: 2, theta: 0.2}'" />
  <executable cmd="ros2 param set $(var turtlesim\_ns)/sim background\_r 120" />
  <timer period="2.0"\>
    <executable cmd="ros2 param set $(var turtlesim\_ns)/sim background\_r $(var new\_background\_r)"
      if="$(eval '$(var new\_background\_r) == 200 and $(var use\_provided\_red)')" />
  </timer>
</launch>

Copy to clipboard

The `turtlesim_ns`, `use_provided_red`, and `new_background_r` launch configurations are defined. They are used to store values of launch arguments in the above variables and to pass them to required actions. The launch configuration arguments can later be used with the `$(var <name>)` substitution to acquire the value of the launch argument in any part of the launch description.

The `arg` tag is used to define the launch argument that can be passed from the above launch file or from the console.

  <arg name="turtlesim\_ns" default="turtlesim1" />
  <arg name="use\_provided\_red" default="False" />
  <arg name="new\_background\_r" default="200" />

Copy to clipboard

The `turtlesim_node` node with the `namespace` set to the `turtlesim_ns` launch configuration value using the `$(var <name>)` substitution is defined.

  <node pkg="turtlesim" namespace="$(var turtlesim\_ns)" exec="turtlesim\_node" name="sim" />

Copy to clipboard

Afterwards, an `executable` action is defined with the corresponding `cmd` tag. This command makes a call to the spawn service of the turtlesim node.

Additionally, the `$(var <name>)` substitution is used to get the value of the `turtlesim_ns` launch argument to construct a command string.

  <executable cmd="ros2 service call $(var turtlesim\_ns)/spawn turtlesim/srv/Spawn '{x: 5, y: 2, theta: 0.2}'" />

Copy to clipboard

The same approach is used for the `ros2 param` `executable` actions that change the turtlesim background’s red color parameter. The difference is that the second action inside of the timer is only executed if the provided `new_background_r` argument equals `200` and the `use_provided_red` launch argument is set to `True`. The evaluation of the `if` predicate is done using the `$(eval <python-expression>)` substitution.

  <executable cmd="ros2 param set $(var turtlesim\_ns)/sim background\_r 120" />
  <timer period="2.0"\>
    <executable cmd="ros2 param set $(var turtlesim\_ns)/sim background\_r $(var new\_background\_r)"
      if="$(eval '$(var new\_background\_r) == 200 and $(var use\_provided\_red)')" />
  </timer>

Copy to clipboard

Create the file `launch/example_substitutions_launch.yaml` and insert the following code:

%YAML 1.2
\---
launch:
  \- arg:
      name: "turtlesim\_ns"
      default: "turtlesim1"
  \- arg:
      name: "use\_provided\_red"
      default: "False"
  \- arg:
      name: "new\_background\_r"
      default: "200"

  \- node:
      pkg: "turtlesim"
      namespace: "$(var turtlesim\_ns)"
      exec: "turtlesim\_node"
      name: "sim"
  \- executable:
      cmd: 'ros2 service call $(var turtlesim\_ns)/spawn turtlesim/srv/Spawn "{x: 5, y: 2, theta: 0.2}"'
  \- executable:
      cmd: "ros2 param set $(var turtlesim\_ns)/sim background\_r 120"
  \- timer:
      period: 2.0
      children:
        \- executable:
            cmd: "ros2 param set $(var turtlesim\_ns)/sim background\_r $(var new\_background\_r)"
            if: '$(eval "$(var new\_background\_r) \== 200 and $(var use\_provided\_red)")'

Copy to clipboard

The `turtlesim_ns`, `use_provided_red`, and `new_background_r` launch configurations are defined. They are used to store values of launch arguments in the above variables and to pass them to required actions. The launch configuration arguments can later be used with the `$(var <name>)` substitution to acquire the value of the launch argument in any part of the launch description.

The `arg` tag is used to define the launch argument that can be passed from the above launch file or from the console.

  \- arg:
      name: "turtlesim\_ns"
      default: "turtlesim1"
  \- arg:
      name: "use\_provided\_red"
      default: "False"
  \- arg:
      name: "new\_background\_r"
      default: "200"

Copy to clipboard

The `turtlesim_node` node with the `namespace` set to the `turtlesim_ns` launch configuration value using the `$(var <name>)` substitution is defined.

  \- node:
      pkg: "turtlesim"
      namespace: "$(var turtlesim\_ns)"
      exec: "turtlesim\_node"
      name: "sim"

Copy to clipboard

Afterwards, an `executable` action is defined with the corresponding `cmd` tag. This command makes a call to the spawn service of the turtlesim node.

Additionally, the `$(var <name>)` substitution is used to get the value of the `turtlesim_ns` launch argument to construct a command string.

  \- executable:
      cmd: 'ros2 service call $(var turtlesim\_ns)/spawn turtlesim/srv/Spawn "{x: 5, y: 2, theta: 0.2}"'

Copy to clipboard

The same approach is used for the `ros2 param` `executable` actions that change the turtlesim background’s red color parameter. The difference is that the second action inside of the timer is only executed if the provided `new_background_r` argument equals `200` and the `use_provided_red` launch argument is set to `True`. The evaluation of the `if` predicate is done using the `$(eval <python-expression>)` substitution.

  \- executable:
      cmd: "ros2 param set $(var turtlesim\_ns)/sim background\_r 120"
  \- timer:
      period: 2.0
      children:
        \- executable:
            cmd: "ros2 param set $(var turtlesim\_ns)/sim background\_r $(var new\_background\_r)"
            if: '$(eval "$(var new\_background\_r) \== 200 and $(var use\_provided\_red)")'

Copy to clipboard

Create the file `launch/example_substitutions_launch.py` and insert the following code:

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, ExecuteProcess, TimerAction
from launch.conditions import IfCondition
from launch.substitutions import LaunchConfiguration, PythonExpression
from launch\_ros.actions import Node

def generate\_launch\_description():
    turtlesim\_ns \= LaunchConfiguration('turtlesim\_ns')
    use\_provided\_red \= LaunchConfiguration('use\_provided\_red')
    new\_background\_r \= LaunchConfiguration('new\_background\_r')

    return LaunchDescription(\[\
        DeclareLaunchArgument(\
            'turtlesim\_ns',\
            default\_value\='turtlesim1'\
        ),\
        DeclareLaunchArgument(\
            'use\_provided\_red',\
            default\_value\='False'\
        ),\
        DeclareLaunchArgument(\
            'new\_background\_r',\
            default\_value\='200'\
        ),\
        Node(\
            package\='turtlesim',\
            namespace\=turtlesim\_ns,\
            executable\='turtlesim\_node',\
            name\='sim'\
        ),\
        ExecuteProcess(\
            cmd\=\[\[\
                'ros2 service call ',\
                turtlesim\_ns,\
                '/spawn ',\
                'turtlesim/srv/Spawn ',\
                '"{x: 2, y: 2, theta: 0.2}"'\
            \]\],\
            shell\=True\
        ),\
        ExecuteProcess(\
            cmd\=\[\[\
                'ros2 param set ',\
                turtlesim\_ns,\
                '/sim background\_r ',\
                '120'\
            \]\],\
            shell\=True\
        ),\
        TimerAction(\
            period\=2.0,\
            actions\=\[\
                ExecuteProcess(\
                    condition\=IfCondition(\
                        PythonExpression(\[\
                            new\_background\_r,\
                            ' == 200',\
                            ' and ',\
                            use\_provided\_red\
                        \])\
                    ),\
                    cmd\=\[\[\
                        'ros2 param set ',\
                        turtlesim\_ns,\
                        '/sim background\_r ',\
                        new\_background\_r\
                    \]\],\
                    shell\=True\
                ),\
            \],\
        )\
    \])

Copy to clipboard

The `turtlesim_ns`, `use_provided_red`, and `new_background_r` launch configurations are defined. They are used to represent values of launch arguments in the above variables and to pass them to required actions. These `LaunchConfiguration` substitutions allow us to acquire the value of the launch argument in any part of the launch description.

`DeclareLaunchArgument` is used to define the launch argument that can be passed from the above launch file or from the console.

        DeclareLaunchArgument(
            'turtlesim\_ns',
            default\_value\='turtlesim1'
        ),
        DeclareLaunchArgument(
            'use\_provided\_red',
            default\_value\='False'
        ),
        DeclareLaunchArgument(
            'new\_background\_r',
            default\_value\='200'
        ),

Copy to clipboard

The `turtlesim_node` node with the `namespace` set to `turtlesim_ns` `LaunchConfiguration` substitution is defined.

        Node(
            package\='turtlesim',
            namespace\=turtlesim\_ns,
            executable\='turtlesim\_node',
            name\='sim'
        ),

Copy to clipboard

The next action, `ExecuteProcess`, is defined with the corresponding `cmd` argument to call the spawn service of the turtlesim node.

Additionally, the `LaunchConfiguration` substitution is used to provide the value of the `turtlesim_ns` launch argument in the command string.

        ExecuteProcess(
            cmd\=\[\[\
                'ros2 service call ',\
                turtlesim\_ns,\
                '/spawn ',\
                'turtlesim/srv/Spawn ',\
                '"{x: 2, y: 2, theta: 0.2}"'\
            \]\],
            shell\=True
        ),

Copy to clipboard

The same approach is used for the `change_background_r` and `change_background_r_conditioned` actions that change the turtlesim background’s red color parameter. The difference is that the next action is only executed if the provided `new_background_r` argument equals `200` and the `use_provided_red` launch argument is set to `True`. The evaluation inside the `IfCondition` is done using the `PythonExpression` substitution.

        TimerAction(
            period\=2.0,
            actions\=\[\
                ExecuteProcess(\
                    condition\=IfCondition(\
                        PythonExpression(\[\
                            new\_background\_r,\
                            ' == 200',\
                            ' and ',\
                            use\_provided\_red\
                        \])\
                    ),\
                    cmd\=\[\[\
                        'ros2 param set ',\
                        turtlesim\_ns,\
                        '/sim background\_r ',\
                        new\_background\_r\
                    \]\],\
                    shell\=True\
                ),\
            \],
        )

Copy to clipboard

### [4 Build the package](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#id8)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#build-the-package "Link to this heading")

Go to the root of the workspace, and build the package:

$ colcon build

Copy to clipboard

Also remember to source the workspace after building.

[Launching example](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#id9)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#launching-example "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Now you can launch using the `ros2 launch` command.

YAMLXMLPython

$ ros2 launch launch\_tutorial example\_main\_launch.yaml

Copy to clipboard

$ ros2 launch launch\_tutorial example\_main\_launch.xml

Copy to clipboard

$ ros2 launch launch\_tutorial example\_main\_launch.py

Copy to clipboard

This will do the following:

1.  Start a turtlesim node with a blue background

2.  Spawn the second turtle

3.  Change the color to purple

4.  Change the color to pink after two seconds if the provided `background_r` argument is `200` and `use_provided_red` argument is `True`


[Modifying launch arguments](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#id10)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#modifying-launch-arguments "Link to this heading")

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

YAMLXMLPython

If you want to change the provided launch arguments, you can either update the `background_r` variable in the `example_main_launch.yaml` or launch the `example_substitutions_launch.yaml` with preferred arguments. To see arguments that may be given to the launch file, run the following command:

$ ros2 launch launch\_tutorial example\_substitutions\_launch.yaml \--show-args

Copy to clipboard

If you want to change the provided launch arguments, you can either update the `background_r` variable in the `example_main_launch.xml` or launch the `example_substitutions_launch.xml` with preferred arguments. To see arguments that may be given to the launch file, run the following command:

$ ros2 launch launch\_tutorial example\_substitutions\_launch.xml \--show-args

Copy to clipboard

If you want to change the provided launch arguments, you can either update them in `launch_arguments` dictionary in the `example_main_launch.py` or launch the `example_substitutions_launch.py` with preferred arguments. To see arguments that may be given to the launch file, run the following command:

$ ros2 launch launch\_tutorial example\_substitutions\_launch.py \--show-args

Copy to clipboard

This will show the arguments that may be given to the launch file and their default values.

Arguments (pass arguments as '<name>:=<value>'):

    'turtlesim\_ns':
        no description given
        (default: 'turtlesim1')

    'use\_provided\_red':
        no description given
        (default: 'False')

    'new\_background\_r':
        no description given
        (default: '200')

Copy to clipboard

Now you can pass the desired arguments to the launch file as follows:

YAMLXMLPython

$ ros2 launch launch\_tutorial example\_substitutions\_launch.yaml turtlesim\_ns:\='turtlesim3' use\_provided\_red:\='True' new\_background\_r:\=200

Copy to clipboard

$ ros2 launch launch\_tutorial example\_substitutions\_launch.xml turtlesim\_ns:\='turtlesim3' use\_provided\_red:\='True' new\_background\_r:\=200

Copy to clipboard

$ ros2 launch launch\_tutorial example\_substitutions\_launch.py turtlesim\_ns:\='turtlesim3' use\_provided\_red:\='True' new\_background\_r:\=200

Copy to clipboard

[Documentation](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#id11)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#documentation "Link to this heading")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

[The launch documentation](https://docs.ros.org/en/jazzy/p/launch/doc/source/architecture.html)
 provides detailed information about available substitutions.

[Summary](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#id12)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html#summary "Link to this heading")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

In this tutorial, you learned about using substitutions in launch files. You learned about their possibilities and capabilities to create reusable launch files.

You can now learn more about [using event handlers in launch files](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Event-Handlers.html)
 which are used to define a complex set of rules which can be used to dynamically modify the launch file.

Other Versions v: jazzy

Releases

[Kilted (latest)](https://docs.ros.org/en/kilted/Tutorials/Intermediate/Launch/Using-Substitutions.html)

[Jazzy](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html)

[Iron (EOL)](https://docs.ros.org/en/iron/Tutorials/Intermediate/Launch/Using-Substitutions.html)

[Humble](https://docs.ros.org/en/humble/Tutorials/Intermediate/Launch/Using-Substitutions.html)

[Galactic (EOL)](https://docs.ros.org/en/galactic/Tutorials/Intermediate/Launch/Using-Substitutions.html)

[Foxy (EOL)](https://docs.ros.org/en/foxy/Tutorials/Intermediate/Launch/Using-Substitutions.html)

[Eloquent (EOL)](https://docs.ros.org/en/eloquent/index.html)

[Dashing (EOL)](https://docs.ros.org/en/dashing/index.html)

[Crystal (EOL)](https://docs.ros.org/en/crystal/index.html)

In Development

[Rolling](https://docs.ros.org/en/rolling/Tutorials/Intermediate/Launch/Using-Substitutions.html)
