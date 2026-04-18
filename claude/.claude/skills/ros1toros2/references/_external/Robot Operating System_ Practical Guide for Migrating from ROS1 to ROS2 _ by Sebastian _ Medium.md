[

![](https://miro.medium.com/v2/resize:fill:64:64/1*gcv5oj2o-aqerq0XbOZ5Qw.png)






](https://admantium.medium.com/?source=post_page---byline--2fe93aca9363---------------------------------------)

Press enter or click to view image in full size

ROS2 is the ongoing effort to modernize the ROS ecosystem to a modern codebase. It includes several changes: Python-based build system, updated C/C++ language standard, new CLI commands and an updated architecture of nodes, topic and messages.

When I started my robots projec, I used ROS1 exclusively. Therefore, all the codebase regarding my robot — the URDF file und RVIZ launch files — were developed in ROS1. In April 2021, I finished the first moving prototype without any ROS functionality, and then in May started to add ROS to the prototype. I then switched to ROS2 so that my project uses an up-to-data code base.

This article summarizes my lessons learned when moving a robot definition and RVIZ launch file from ROS1 to ROS2.

_This article originally appeared at my blog_ [_admantium.com_](https://admantium.com/blog/ros06_migrating_urdf_to_ros2/).

Create a new ROS2 Package with the Python Build System
------------------------------------------------------

Let’s create a new ROS2 package that uses the Python build system, configure the dependencies, and then migrate an URDF file from ROS1 to ROS2. The following steps loosely follow the [ROS2 navigation](https://navigation.ros.org/setup_guides/urdf/setup_urdf.html) tutorial.

Create the Package
------------------

When you create a new ROS2 package, you can select between two build types. Coming from ROS1, the type `ament_cmake` will create a CMake file that manages your packages build instructions. Embracing the new Python build system, I use `ament_python` that will provide a central Python file instead.

```
ros2 pkg create --build-type ament\_python radu\_bot
```

Add Dependencies to the Package.xml
-----------------------------------

In order to have the new nodes started correctly, we need to add additional dependencies, other [ROS packages](https://index.ros.org/packages/), to the project. You can setup the dependencies already with the `pkg create --add-dependencies` flag, but I like to add them manually,

The dependencies that we need are the following:

*   [rviz2](https://index.ros.org/p/rviz2/#foxy): Contains the RViz simulation tool
*   [urdf](https://index.ros.org/p/urdf/#foxy): C++ parser for the URDF file format
*   [joint\_state\_publisher](https://index.ros.org/p/joint_state_publisher/#foxy): Publishes the state of all non-static joints for an URDF-described robot. This package reads the parameter `robot_description` from the ROS parameter server to build a representation of the robot. Then, it continuously publishes messages that contain name, position, velocity and effort of each joint.
*   [robot\_state\_publisher](https://index.ros.org/p/robot_state_publisher/#foxy): This package reads the `robot_description` parameter and the `joint_states` published by the aforementioned package to calculate a 3D pose estimation of the robot. The messages are published as `tf2` messages, which allow all other ROS nodes to coherently access all coordinate frames (world, links of your robot) over time.
*   [controller\_manager](https://index.ros.org/p/controller_manager/#foxy): This packages allows direct access to a robot, which means that the robots hardware, is actuators and sensors, are wrapped in a common format which can be used by other ROS nodes and tools, including RViz and Gazebo.
*   [xacro](https://index.ros.org/p/xacro/#foxy): With XACRO, you can define XML macros to be used in creating URDF files, which drastically reduces the amount of code you need to write and enables flexible “builds” of your robot, e.g. adding tags specifically required for Gazebo.

The place to define them is the `package.xml` file. As stated in the [ROS documentation](http://wiki.ros.org/catkin/package.xml), you should use `<depend>` tags for all dependencies. For completeness, here is the complete file.

```
<?xml version="1.0"?>  
<?xml-model href="http://download.ros.org/schema/package\_format3.xsd" schematypens="http://www.w3.org/2001/XMLSchema"?>  
<package format="3">  
  <name>radu\_bot</name>  
  <version>0.1.0</version>  
  <description>Simulation of the RADU bot</description> <maintainer email="devcon@admantium.com">devcon</maintainer>  
  <license>UNLICENSED</license> <depend>urdf</depend> <depend>joint\_state\_publisher</depend>  
  <depend>joint\_state\_publisher\_gui</depend>  
  <depend>robot\_state\_publisher</depend>  
  <depend>rviz2</depend>  
  <depend>xacro</depend> <test\_depend>ament\_copyright</test\_depend>  
  <test\_depend>ament\_flake8</test\_depend>  
  <test\_depend>ament\_pep257</test\_depend>  
  <test\_depend>python3-pytest</test\_depend> <export>  
    <build\_type>ament\_python</build\_type>  
  </export>  
</package>
```

After adding the dependencies, run the following two commands in your ros2 workspace directory.

```
sudo apt-get install ros-foxy-joint-state-publisher-gui ros-foxy-xacro  
rosdep update  
rosdep install --from-paths src --ignore-src --rosdistro foxy -y
```

Migrate the Launch File
-----------------------

ROS2 does not support XML files anymore. Instead, you are using Python files to launch and configure ROS nodes as well as to start tools like RVIZ and Gazebo. Since they are scripts, you can build much more logic into launching instead of just declaratively listing. However, the configuration complexity is still high, e.g. you still need to launch special controller or navigation nodes when you want to spawn and move a robot inside a simulation.

The old XML launch file has the following content:

```
<launch>  
  <param name="robot\_description" textfile="$(find car-robot)/urdf/bot.urdf"/>  
  <arg name="rvizconfig" default="$(find urdf\_tutorial)/rviz/urdf.rviz" />  
  <node name="robot\_state\_publisher" pkg="robot\_state\_publisher" type="robot\_state\_publisher"/>  
  <node name="joint\_state\_publisher" pkg="joint\_state\_publisher" type="joint\_state\_publisher"/>  
  <node name="rviz" pkg="rviz" type="rviz" args="-d $(arg rvizconfig)" />  
</launch>
```

It consists of these parts/concepts:

*   The `param` declaration defines the standard parameter name `robot_description`. It refers to the URDF file that contains your robot definition.
*   The `arg` declaration loads the rviz configuration file, it includes the settings so that our robot will be displayed automatically.
*   Two control nodes, the `robot_state_publisher` and the `joint_state_publisher` are created - these nodes are interfaces between the robot and rviz
*   Finally, we start the `rviz` node and pass the configuration file to it.

These parts are translated into ROS2 Python following a simple rule: Each `<node>` gets translated to a Python `Node` object, and the `<param>` and `<arg>` tags are configuration parameters of a `Node`.

Consider this example how the `robot_description` is represented.

```
<param name="robot\_description" textfile="$(find car-robot)/urdf/bot.urdf"/>  
<node name="robot\_state\_publisher" pkg="robot\_state\_publisher" type="robot\_state\_publisher"/>
```

And in Python, this is represented by a `robot_state_publisher` node.

```
robot\_description = open(robot\_description\_path).read()robot\_state\_publisher\_node = launch\_ros.actions.Node(  
  package='robot\_state\_publisher',  
  executable='robot\_state\_publisher',  
  parameters=\[{'robot\_description': robot\_description}\]  
)
```

Once you have all nodes together, you wrap them inside a `LaunchDescription` list:

```
def generate\_launch\_description():  
  return launch.LaunchDescription(\[  
    robot\_state\_publisher\_node  
  \])
```

These are the essential steps. For completeness, here is the complete launch file:

```
import launch  
from launch.substitutions import Command, LaunchConfiguration  
import launch\_ros  
import os  
from ament\_index\_python.packages import get\_package\_share\_directorydef generate\_launch\_description():  
  package\_name = 'radu\_bot' pkg\_share = launch\_ros.substitutions.FindPackageShare(package=package\_name).find(package\_name)  
  robot\_description\_path = os.path.join(pkg\_share, 'urdf/robot.urdf')  
  rviz\_config\_path = os.path.join(pkg\_share, 'config/urdf\_config.rviz') robot\_state\_publisher\_node = launch\_ros.actions.Node(  
    package='robot\_state\_publisher',  
    executable='robot\_state\_publisher',  
    parameters=\[{'robot\_description': robot\_description}\]  
  )  
  joint\_state\_publisher\_node = launch\_ros.actions.Node(  
    package='joint\_state\_publisher',  
    executable='joint\_state\_publisher',  
    name='joint\_state\_publisher'  
  )  
  joint\_state\_publisher\_gui\_node = launch\_ros.actions.Node(  
    package='joint\_state\_publisher\_gui',  
    executable='joint\_state\_publisher\_gui',  
    name='joint\_state\_publisher\_gui'  
  )  
  rviz\_node = launch\_ros.actions.Node(  
    package='rviz2',  
    executable='rviz2',  
    name='rviz2',  
    output='screen',  
    arguments=\['-d', rviz\_config\_path\],  
  ) return launch.LaunchDescription(\[  
    joint\_state\_publisher\_node,  
    joint\_state\_publisher\_gui\_node,  
    robot\_state\_publisher\_node,  
    rviz\_node  
  \])
```

Build Configuration
-------------------

As stated before, I use the Python build system for my robot. Instead of a `CMake` file, you use a Python `setup.py` file. Here, you define various metadata about your project (name, maintainer, version), configure which files are copied to your build, and list commands and executables that can then be called with `ros2 run`.

The following file is sufficient.

```
import os  
from glob import glob  
from setuptools import setuppackage\_name = 'radu\_bot'setup(  
    name=package\_name,  
    version='0.0.0',  
    packages=\[package\_name\],  
    data\_files=\[  
        ('share/' + package\_name, \['package.xml'\]),  
        (os.path.join('share', package\_name, 'launch'), glob('launch/\*')),  
        (os.path.join('share', package\_name, 'urdf'), glob('urdf/\*')),  
        (os.path.join('share', package\_name, 'config'), glob('config/\*')),  
    \],  
    install\_requires=\['setuptools'\],  
    zip\_safe=True,  
    maintainer='devcon',  
    maintainer\_email='devcon@admantium.com',  
    description='Simulation of the RADU robot',  
    license='UNLICENSED',  
    tests\_require=\['pytest'\],  
    entry\_points={  
        'console\_scripts': \[  
        \],  
    },  
)
```

Adding the Robot Model
----------------------

For the robot file, I’m using a complex set of XACRO files that will compile into RVIZ-compatible or Gazebo-compatible robot description files. If you just use RVIZ, there will be no changes. But to be working with Gazebo, you need to add additional properties for links and joints, and add new tags. This complex topic will be explored in future articles.

Building the Package
--------------------

Now that our new package is completely assembled, let’s build it. In ROS2, you are using the `colcon` build tool, which works with C-based and Python-based projects likewise.

Use the following command to start the build.

```
$> colcon build --symlink-install --event-handlers console\_direct+ --packages-up-to radu\_bot
```

When its finished, you can launch the program by using `ros2 launch PACKAGE_NAME LAUNCH_SCRIPT`.

```
$Y ros2 launch radu\_bot rviz.launch.py  
\[INFO\] \[launch\]: All log files can be found below /home/devcon/.ros/log/2021-05-29-18-33-52-275784-giga-20756  
\[INFO\] \[launch\]: Default logging verbosity is set to INFO  
\[INFO\] \[joint\_state\_publisher-1\]: process started with pid \[20758\]  
\[INFO\] \[joint\_state\_publisher\_gui-2\]: process started with pid \[20760\]  
\[INFO\] \[robot\_state\_publisher-3\]: process started with pid \[20762\]  
\[INFO\] \[rviz2-4\]: process started with pid \[20764\]  
\[robot\_state\_publisher-3\] Parsing robot urdf xml string.  
\[robot\_state\_publisher-3\] Link left\_wheel\_backside had 0 children  
\[robot\_state\_publisher-3\] Link left\_wheel\_frontside had 0 children  
\[robot\_state\_publisher-3\] Link right\_wheel\_backside had 0 children  
\[robot\_state\_publisher-3\] Link right\_wheel\_frontside had 0 children  
\[robot\_state\_publisher-3\] \[INFO\] \[1622306032.679044506\] \[robot\_state\_publisher\]: got segment base\_link  
\[robot\_state\_publisher-3\] \[INFO\] \[1622306032.681243514\] \[robot\_state\_publisher\]: got segment left\_wheel\_backside  
\[robot\_state\_publisher-3\] \[INFO\] \[1622306032.681317837\] \[robot\_state\_publisher\]: got segment left\_wheel\_frontside  
\[robot\_state\_publisher-3\] \[INFO\] \[1622306032.681341170\] \[robot\_state\_publisher\]: got segment right\_wheel\_backside  
\[robot\_state\_publisher-3\] \[INFO\] \[1622306032.681363438\] \[robot\_state\_publisher\]: got segment right\_wheel\_frontside  
\[rviz2-4\] \[INFO\] \[1622306033.746836459\] \[rviz2\]: Stereo is NOT SUPPORTED  
\[rviz2-4\] \[INFO\] \[1622306033.750165429\] \[rviz2\]: OpenGl version: 4.6 (GLSL 4.6)  
\[rviz2-4\] \[INFO\] \[1622306033.857522813\] \[rviz2\]: Stereo is NOT SUPPORTED  
\[joint\_state\_publisher-1\] \[INFO\] \[1622306034.345835955\] \[joint\_state\_publisher\]: Waiting for robot\_description to be published on the robot\_description topic...  
\[rviz2-4\] Parsing robot urdf xml string.  
Centering  
\[joint\_state\_publisher\_gui-2\] \[INFO\] \[1622306035.104035974\] \[joint\_state\_publisher\_gui\]: Centering
```

And finally, your robot is rendered.

Press enter or click to view image in full size

Conclusion
----------

ROS2 brought several changes to the ROS ecosystem. This tutorial showed you how to migrate a robot description and RVIZ simulation from ROS1 to ROS2. The major change is to embrace Python: Launch files are imperative Python scripts instead of declarative XML files. This gives you much more control and scripting power to start and run nodes. In addition, you can also use Python as your packages’ build language: In a central `setup.py`, you configure which files are copied from your project to the installed version, manage dependencies, and add files that can be executed with the `ros2 run` command.

The next article continues this ROS2 explanation by taking a closer look to implementing a XACRO-bases URDF representation of a robot that is compatible with both RVIZ and Gazebo simulation.