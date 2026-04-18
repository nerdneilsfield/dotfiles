---
source_url: https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html
fetched_at: 2026-04-18T10:58:54Z
---

*   [](https://docs.ros.org/en/jazzy/index.html)

*   [Tutorials](https://docs.ros.org/en/jazzy/Tutorials.html)

*   [Beginner: Client libraries](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries.html)

*   Using parameters in a class (Python)
*   [Edit on GitHub](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.rst)


* * *

**You're reading the documentation for an older, but still supported, version of ROS 2. For information on the latest version, please have a look at [Kilted](https://docs.ros.org/en/kilted/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html)
.**

Using parameters in a class (Python)[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#using-parameters-in-a-class-python "Link to this heading")

=============================================================================================================================================================================================================

**Goal:** Create and run a class with ROS parameters using Python.

**Tutorial level:** Beginner

**Time:** 20 minutes

[Background](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#id1)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#background "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

When making your own [nodes](https://docs.ros.org/en/jazzy/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Nodes/Understanding-ROS2-Nodes.html)
 you will sometimes need to add parameters that can be set from the launch file.

This tutorial will show you how to create those parameters in a Python class, and how to set them in a launch file.

[Prerequisites](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#id2)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#prerequisites "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

In previous tutorials, you learned how to [create a workspace](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Creating-A-Workspace/Creating-A-Workspace.html)
 and [create a package](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Creating-Your-First-ROS2-Package.html)
. You have also learned about [parameters](https://docs.ros.org/en/jazzy/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Parameters/Understanding-ROS2-Parameters.html)
 and their function in a ROS 2 system.

[Tasks](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#id3)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#tasks "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### [1 Create a package](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#id4)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#create-a-package "Link to this heading")

Open a new terminal and [source your ROS 2 installation](https://docs.ros.org/en/jazzy/Tutorials/Beginner-CLI-Tools/Configuring-ROS2-Environment.html)
 so that `ros2` commands will work.

Follow [these instructions](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Creating-A-Workspace/Creating-A-Workspace.html#new-directory)
 to create a new workspace named `ros2_ws`.

Recall that packages should be created in the `src` directory, not the root of the workspace. Navigate into `ros2_ws/src` and create a new package:

$ ros2 pkg create \--build-type ament\_python \--license Apache-2.0 python\_parameters \--dependencies rclpy

Copy to clipboard

Your terminal will return a message verifying the creation of your package `python_parameters` and all its necessary files and folders.

The `--dependencies` argument will automatically add the necessary dependency lines to `package.xml`.

#### 1.1 Update `package.xml`[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#update-package-xml "Link to this heading")

Because you used the `--dependencies` option during package creation, you don’t have to manually add dependencies to `package.xml`.

As always, though, make sure to add the description, maintainer email and name, and license information to `package.xml`.

<description>Python parameter tutorial</description>
<maintainer email="you@email.com"\>Your Name</maintainer>
<license>Apache-2.0</license>

Copy to clipboard

### [2 Write the Python node](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#id5)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#write-the-python-node "Link to this heading")

Inside the `ros2_ws/src/python_parameters/python_parameters` directory, create a new file called `python_parameters_node.py` and paste the following code within:

import rclpy
from rclpy.node import Node

class MinimalParam(Node):
    def \_\_init\_\_(self):
        super().\_\_init\_\_('minimal\_param\_node')

        self.declare\_parameter('my\_parameter', 'world')

        self.timer \= self.create\_timer(1, self.timer\_callback)

    def timer\_callback(self):
        my\_param \= self.get\_parameter('my\_parameter').get\_parameter\_value().string\_value

        self.get\_logger().info('Hello %s!' % my\_param)

        my\_new\_param \= rclpy.parameter.Parameter(
            'my\_parameter',
            rclpy.Parameter.Type.STRING,
            'world'
        )
        all\_new\_parameters \= \[my\_new\_param\]
        self.set\_parameters(all\_new\_parameters)

def main():
    rclpy.init()
    node \= MinimalParam()
    rclpy.spin(node)

if \_\_name\_\_ \== '\_\_main\_\_':
    main()

Copy to clipboard

#### 2.1 Examine the code[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#examine-the-code "Link to this heading")

The `import` statements at the top are used to import the package dependencies.

The next piece of code creates the class and the constructor. The line `self.declare_parameter('my_parameter', 'world')` of the constructor creates a parameter with the name `my_parameter` and a default value of `world`. The parameter type is inferred from the default value, so in this case it would be set to a string type. Next the `timer` is initialized with a period of 1, which causes the `timer_callback` function to be executed once a second.

class MinimalParam(Node):
    def \_\_init\_\_(self):
        super().\_\_init\_\_('minimal\_param\_node')

        self.declare\_parameter('my\_parameter', 'world')

        self.timer \= self.create\_timer(1, self.timer\_callback)

Copy to clipboard

The first line of our `timer_callback` function gets the parameter `my_parameter` from the node, and stores it in `my_param`. Next the `get_logger` function ensures the event is logged. The `set_parameters` function then sets the parameter `my_parameter` back to the default string value `world`. In the case that the user changed the parameter externally, this ensures it is always reset back to the original.

def timer\_callback(self):
    my\_param \= self.get\_parameter('my\_parameter').get\_parameter\_value().string\_value

    self.get\_logger().info('Hello %s!' % my\_param)

    my\_new\_param \= rclpy.parameter.Parameter(
        'my\_parameter',
        rclpy.Parameter.Type.STRING,
        'world'
    )
    all\_new\_parameters \= \[my\_new\_param\]
    self.set\_parameters(all\_new\_parameters)

Copy to clipboard

Following the `timer_callback` is our `main`. Here ROS 2 is initialized, an instance of the `MinimalParam` class is constructed, and `rclpy.spin` starts processing data from the node.

def main():
    rclpy.init()
    node \= MinimalParam()
    rclpy.spin(node)

if \_\_name\_\_ \== '\_\_main\_\_':
    main()

Copy to clipboard

##### 2.1.1 (Optional) Add ParameterDescriptor[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#optional-add-parameterdescriptor "Link to this heading")

Optionally, you can set a descriptor for the parameter. Descriptors allow you to specify a text description of the parameter and its constraints, like making it read-only, specifying a range, etc. For that to work, the `__init__` code has to be changed to:

\# ...

class MinimalParam(Node):
    def \_\_init\_\_(self):
        super().\_\_init\_\_('minimal\_param\_node')

        from rcl\_interfaces.msg import ParameterDescriptor
        my\_parameter\_descriptor \= ParameterDescriptor(description\='This parameter is mine!')

        self.declare\_parameter('my\_parameter', 'world', my\_parameter\_descriptor)

        self.timer \= self.create\_timer(1, self.timer\_callback)

Copy to clipboard

Since we are importing `rcl_interfaces`, we need to add the dependency to `package.xml` to avoid any dependency issue in the future:

# ...
<depend>rclpy</depend>
<depend>rcl\_interfaces</depend>

Copy to clipboard

The rest of the code remains the same. Once you run the node, you can then run `ros2 param describe /minimal_param_node my_parameter` to see the type and description.

#### 2.2 Add an entry point[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#add-an-entry-point "Link to this heading")

Open the `setup.py` file. Again, match the `maintainer`, `maintainer_email`, `description` and `license` fields to your `package.xml`:

maintainer\='YourName',
maintainer\_email\='you@email.com',
description\='Python parameter tutorial',
license\='Apache-2.0',

Copy to clipboard

Add the following line within the `console_scripts` brackets of the `entry_points` field:

entry\_points\={
    'console\_scripts': \[\
        'minimal\_param\_node = python\_parameters.python\_parameters\_node:main',\
    \],
},

Copy to clipboard

Don’t forget to save.

### [3 Build and run](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#id6)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#build-and-run "Link to this heading")

It’s good practice to run `rosdep` in the root of your workspace (`ros2_ws`) to check for missing dependencies before building:

LinuxmacOSWindows

$ rosdep install \-i \--from-path src \--rosdistro jazzy \-y

Copy to clipboard

rosdep only runs on Linux, so you can skip ahead to next step.

rosdep only runs on Linux, so you can skip ahead to next step.

Navigate back to the root of your workspace, `ros2_ws`, and build your new package:

LinuxmacOSWindows

$ colcon build \--packages-select python\_parameters

Copy to clipboard

$ colcon build \--packages-select python\_parameters

Copy to clipboard

$ colcon build \--merge-install \--packages-select python\_parameters

Copy to clipboard

Open a new terminal, navigate to `ros2_ws`, and source the setup files:

LinuxmacOSWindows

$ source install/setup.bash

Copy to clipboard

$ . install/setup.bash

Copy to clipboard

$ call install/setup.bat

Copy to clipboard

Now run the node. The terminal should return `Hello world!` every second:

 $ ros2 run python\_parameters minimal\_param\_node
\[INFO\] \[parameter\_node\]: Hello world!

Copy to clipboard

Now you can see the default value of your parameter, but you want to be able to set it yourself. There are two ways to accomplish this.

#### 3.1 Change via the console[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#change-via-the-console "Link to this heading")

This part will use the knowledge you have gained from the [tutorial about parameters](https://docs.ros.org/en/jazzy/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Parameters/Understanding-ROS2-Parameters.html)
 and apply it to the node you have just created.

Make sure the node is running:

$ ros2 run python\_parameters minimal\_param\_node

Copy to clipboard

Open another terminal, source the setup files from inside `ros2_ws` again, and enter the following line:

$ ros2 param list

Copy to clipboard

There you will see the custom parameter `my_parameter`. To change it, simply run the following line in the console:

$ ros2 param set /minimal\_param\_node my\_parameter earth

Copy to clipboard

You know it went well if you get the output `Set parameter successful`. If you look at the other terminal, you should see the output change to `[INFO] [minimal_param_node]: Hello earth!`

Since the node afterwards set the parameter back to `world`, further outputs show `[INFO] [minimal_param_node]: Hello world!`

#### 3.2 Change via a launch file[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#change-via-a-launch-file "Link to this heading")

You can also set parameters in a launch file, but first you will need to add a launch directory. Inside the `ros2_ws/src/python_parameters/` directory, create a new directory called `launch`. In there, create a new file called `python_parameters_launch.py`

from launch import LaunchDescription
from launch\_ros.actions import Node

def generate\_launch\_description():
    return LaunchDescription(\[\
        Node(\
            package\='python\_parameters',\
            executable\='minimal\_param\_node',\
            name\='custom\_minimal\_param\_node',\
            output\='screen',\
            emulate\_tty\=True,\
            parameters\=\[\
                {'my\_parameter': 'earth'}\
            \]\
        )\
    \])

Copy to clipboard

Here you can see that we set `my_parameter` to `earth` when we launch our node `parameter_node`. By adding the two lines below, we ensure our output is printed in our console.

output="screen",
emulate\_tty=True,

Copy to clipboard

Now open the `setup.py` file. Add the `import` statements to the top of the file, and the other new statement to the `data_files` parameter to include all launch files:

import os
from glob import glob
\# ...

setup(
  \# ...
  data\_files\=\[\
      \# ...\
      (os.path.join('share', package\_name, 'launch'), glob('launch/\*')),\
    \]
  )

Copy to clipboard

Open a console and navigate to the root of your workspace, `ros2_ws`, and build your new package:

LinuxmacOSWindows

$ colcon build \--packages-select python\_parameters

Copy to clipboard

$ colcon build \--packages-select python\_parameters

Copy to clipboard

$ colcon build \--merge-install \--packages-select python\_parameters

Copy to clipboard

Then source the setup files in a new terminal:

LinuxmacOSWindows

$ source install/setup.bash

Copy to clipboard

$ . install/setup.bash

Copy to clipboard

$ call install/setup.bat

Copy to clipboard

Now run the node using the launch file we have just created:

 $ ros2 launch python\_parameters python\_parameters\_launch.py
\[INFO\] \[custom\_minimal\_param\_node\]: Hello earth!

Copy to clipboard

Further outputs should show `[INFO] [minimal_param_node]: Hello world!` every second.

[Summary](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#id7)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#summary "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

You created a node with a custom parameter that can be set either from a launch file or the command line. You added the dependencies, executables, and a launch file to the package configuration files so that you could build and run them, and see the parameter in action.

[Next steps](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#id8)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html#next-steps "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Now that you have some packages and ROS 2 systems of your own, the [next tutorial](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Getting-Started-With-Ros2doctor.html)
 will show you how to examine issues in your environment and systems in case you have problems.

Other Versions v: jazzy

Releases

[Kilted (latest)](https://docs.ros.org/en/kilted/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html)

[Jazzy](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html)

[Iron (EOL)](https://docs.ros.org/en/iron/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html)

[Humble](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html)

[Galactic (EOL)](https://docs.ros.org/en/galactic/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html)

[Foxy (EOL)](https://docs.ros.org/en/foxy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html)

[Eloquent (EOL)](https://docs.ros.org/en/eloquent/index.html)

[Dashing (EOL)](https://docs.ros.org/en/dashing/index.html)

[Crystal (EOL)](https://docs.ros.org/en/crystal/index.html)

In Development

[Rolling](https://docs.ros.org/en/rolling/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-Python.html)
