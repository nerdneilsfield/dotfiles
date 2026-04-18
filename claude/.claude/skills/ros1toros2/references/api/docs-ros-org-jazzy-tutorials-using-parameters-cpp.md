---
source_url: https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html
fetched_at: 2026-04-18T10:58:52Z
---

*   [](https://docs.ros.org/en/jazzy/index.html)

*   [Tutorials](https://docs.ros.org/en/jazzy/Tutorials.html)

*   [Beginner: Client libraries](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries.html)

*   Using parameters in a class (C++)
*   [Edit on GitHub](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.rst)


* * *

**You're reading the documentation for an older, but still supported, version of ROS 2. For information on the latest version, please have a look at [Kilted](https://docs.ros.org/en/kilted/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html)
.**

Using parameters in a class (C++)[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#using-parameters-in-a-class-c "Link to this heading")

==================================================================================================================================================================================================

**Goal:** Create and run a class with ROS parameters using C++.

**Tutorial level:** Beginner

**Time:** 20 minutes

[Background](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#id1)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#background "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

When making your own [nodes](https://docs.ros.org/en/jazzy/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Nodes/Understanding-ROS2-Nodes.html)
 you will sometimes need to add parameters that can be set from the launch file.

This tutorial will show you how to create those parameters in a C++ class, and how to set them in a launch file.

[Prerequisites](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#id2)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#prerequisites "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

In previous tutorials, you learned how to [create a workspace](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Creating-A-Workspace/Creating-A-Workspace.html)
 and [create a package](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Creating-Your-First-ROS2-Package.html)
. You have also learned about [parameters](https://docs.ros.org/en/jazzy/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Parameters/Understanding-ROS2-Parameters.html)
 and their function in a ROS 2 system.

[Tasks](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#id3)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#tasks "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### [1 Create a package](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#id4)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#create-a-package "Link to this heading")

Open a new terminal and [source your ROS 2 installation](https://docs.ros.org/en/jazzy/Tutorials/Beginner-CLI-Tools/Configuring-ROS2-Environment.html)
 so that `ros2` commands will work.

Follow [these instructions](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Creating-A-Workspace/Creating-A-Workspace.html#new-directory)
 to create a new workspace named `ros2_ws`.

Recall that packages should be created in the `src` directory, not the root of the workspace. Navigate into `ros2_ws/src` and create a new package:

$ ros2 pkg create \--build-type ament\_cmake \--license Apache-2.0 cpp\_parameters \--dependencies rclcpp

Copy to clipboard

Your terminal will return a message verifying the creation of your package `cpp_parameters` and all its necessary files and folders.

The `--dependencies` argument will automatically add the necessary dependency lines to `package.xml` and `CMakeLists.txt`.

#### 1.1 Update `package.xml`[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#update-package-xml "Link to this heading")

Because you used the `--dependencies` option during package creation, you don’t have to manually add dependencies to `package.xml` or `CMakeLists.txt`.

As always, though, make sure to add the description, maintainer email and name, and license information to `package.xml`.

<description>C++ parameter tutorial</description>
<maintainer email="you@email.com"\>Your Name</maintainer>
<license>Apache-2.0</license>

Copy to clipboard

### [2 Write the C++ node](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#id5)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#write-the-c-node "Link to this heading")

Inside the `ros2_ws/src/cpp_parameters/src` directory, create a new file called `cpp_parameters_node.cpp` and paste the following code within:

#include <chrono>
#include <functional>
#include <string>

#include <rclcpp/rclcpp.hpp>

using namespace std::chrono\_literals;

class MinimalParam : public rclcpp::Node
{
public:
  MinimalParam()
  : Node("minimal\_param\_node")
  {
    this\->declare\_parameter("my\_parameter", "world");

    auto timer\_callback \= \[this\](){
      std::string my\_param \= this\->get\_parameter("my\_parameter").as\_string();

      RCLCPP\_INFO(this\->get\_logger(), "Hello %s!", my\_param.c\_str());

      std::vector<rclcpp::Parameter\> all\_new\_parameters{rclcpp::Parameter("my\_parameter", "world")};
      this\->set\_parameters(all\_new\_parameters);
    };
    timer\_ \= this\->create\_wall\_timer(1000ms, timer\_callback);
  }

private:
  rclcpp::TimerBase::SharedPtr timer\_;
};

int main(int argc, char \*\* argv)
{
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make\_shared<MinimalParam\>());
  rclcpp::shutdown();
  return 0;
}

Copy to clipboard

#### 2.1 Examine the code[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#examine-the-code "Link to this heading")

The `#include` statements at the top are the package dependencies.

The next piece of code creates the class and the constructor. The first line of this constructor creates a parameter with the name `my_parameter` and a default value of `world`. The parameter type is inferred from the default value, so in this case it would be set to a string type. Next, a [lambda function](https://en.cppreference.com/w/cpp/language/lambda)
 called `timer_callback` is declared. It performs a by-reference capture of the current object `this`, takes no input arguments and returns void. The first line of our `timer_callback` function gets the parameter `my_parameter` from the node, and stores it in `my_param`. Then the `RCLCPP_INFO` function ensures the event is logged. The `set_parameters` function sets the parameter `my_parameter` back to the default string value `world`. In the case that the user changed the parameter externally, this ensures it is always reset back to the original. In the end, `timer_` is initialized with a period of 1000ms, which causes the `timer_callback` function to be executed once a second.

class MinimalParam : public rclcpp::Node
{
public:
  MinimalParam()
  : Node("minimal\_param\_node")
  {
    this\->declare\_parameter("my\_parameter", "world");

    auto timer\_callback \= \[this\](){
      std::string my\_param \= this\->get\_parameter("my\_parameter").as\_string();

      RCLCPP\_INFO(this\->get\_logger(), "Hello %s!", my\_param.c\_str());

      std::vector<rclcpp::Parameter\> all\_new\_parameters{rclcpp::Parameter("my\_parameter", "world")};
      this\->set\_parameters(all\_new\_parameters);
    };
    timer\_ \= this\->create\_wall\_timer(1000ms, timer\_callback);
  }

Copy to clipboard

Last is the declaration of `timer_`.

private:
  rclcpp::TimerBase::SharedPtr timer\_;

Copy to clipboard

Following our `MinimalParam` is our `main`. Here ROS 2 is initialized, an instance of the `MinimalParam` class is constructed, and `rclcpp::spin` starts processing data from the node.

int main(int argc, char \*\* argv)
{
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make\_shared<MinimalParam\>());
  rclcpp::shutdown();
  return 0;
}

Copy to clipboard

##### 2.1.1 (Optional) Add ParameterDescriptor[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#optional-add-parameterdescriptor "Link to this heading")

Optionally, you can set a descriptor for the parameter. Descriptors allow you to specify a text description of the parameter and its constraints, like making it read-only, specifying a range, etc. For that to work, the code in the constructor has to be changed to:

// ...

class MinimalParam : public rclcpp::Node
{
public:
  MinimalParam()
  : Node("minimal\_param\_node")
  {
    auto param\_desc \= rcl\_interfaces::msg::ParameterDescriptor{};
    param\_desc.description \= "This parameter is mine!";

    this\->declare\_parameter("my\_parameter", "world", param\_desc);

    auto timer\_callback \= \[this\](){
      std::string my\_param \= this\->get\_parameter("my\_parameter").as\_string();

      RCLCPP\_INFO(this\->get\_logger(), "Hello %s!", my\_param.c\_str());

      std::vector<rclcpp::Parameter\> all\_new\_parameters{rclcpp::Parameter("my\_parameter", "world")};
      this\->set\_parameters(all\_new\_parameters);
    };
    timer\_ \= this\->create\_wall\_timer(1000ms, timer\_callback);

  }

Copy to clipboard

The rest of the code remains the same. Once you run the node, you can then run `ros2 param describe /minimal_param_node my_parameter` to see the type and description.

#### 2.2 Add executable[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#add-executable "Link to this heading")

Now open the `CMakeLists.txt` file. Below the dependency `find_package(rclcpp REQUIRED)` add the following lines of code.

add\_executable(minimal\_param\_node src/cpp\_parameters\_node.cpp)
ament\_target\_dependencies(minimal\_param\_node rclcpp)

install(TARGETS
    minimal\_param\_node
  DESTINATION lib/${PROJECT\_NAME}
)

Copy to clipboard

### [3 Build and run](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#id6)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#build-and-run "Link to this heading")

It’s good practice to run `rosdep` in the root of your workspace (`ros2_ws`) to check for missing dependencies before building:

LinuxmacOSWindows

$ rosdep install \-i \--from-path src \--rosdistro jazzy \-y

Copy to clipboard

rosdep only runs on Linux, so you can skip ahead to next step.

rosdep only runs on Linux, so you can skip ahead to next step.

Navigate back to the root of your workspace, `ros2_ws`, and build your new package:

LinuxmacOSWindows

$ colcon build \--packages-select cpp\_parameters

Copy to clipboard

$ colcon build \--packages-select cpp\_parameters

Copy to clipboard

$ colcon build \--merge-install \--packages-select cpp\_parameters

Copy to clipboard

Open a new terminal, navigate to `ros2_ws`, and source the setup files:

LinuxmacOSWindows

$ source install/setup.bash

Copy to clipboard

$ . install/setup.bash

Copy to clipboard

$ call install/setup.bat

Copy to clipboard

Now run the node. The terminal should return the `Hello World` message every second:

 $ ros2 run cpp\_parameters minimal\_param\_node
\[INFO\] \[minimal\_param\_node\]: Hello world!

Copy to clipboard

Now you can see the default value of your parameter, but you want to be able to set it yourself. There are two ways to accomplish this.

#### 3.1 Change via the console[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#change-via-the-console "Link to this heading")

This part will use the knowledge you have gained from the [tutorial about parameters](https://docs.ros.org/en/jazzy/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Parameters/Understanding-ROS2-Parameters.html)
 and apply it to the node you have just created.

Make sure the node is running:

$ ros2 run cpp\_parameters minimal\_param\_node

Copy to clipboard

Open another terminal, source the setup files from inside `ros2_ws` again, and enter the following line:

$ ros2 param list

Copy to clipboard

There you will see the custom parameter `my_parameter`. To change it, simply run the following line in the console:

$ ros2 param set /minimal\_param\_node my\_parameter earth

Copy to clipboard

You know it went well if you got the output `Set parameter successful`. If you look at the other terminal, you should see the output change to `[INFO] [minimal_param_node]: Hello earth!`

#### 3.2 Change via a launch file[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#change-via-a-launch-file "Link to this heading")

You can also set the parameter in a launch file, but first you will need to add the launch directory. Inside the `ros2_ws/src/cpp_parameters/` directory, create a new directory called `launch`. In there, create a new file called `cpp_parameters_launch.py`

from launch import LaunchDescription
from launch\_ros.actions import Node

def generate\_launch\_description():
    return LaunchDescription(\[\
        Node(\
            package\='cpp\_parameters',\
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

Here you can see that we set `my_parameter` to `earth` when we launch our node `minimal_param_node`. By adding the two lines below, we ensure our output is printed in our console.

output\="screen",
emulate\_tty\=True,

Copy to clipboard

Now open the `CMakeLists.txt` file. Below the lines you added earlier, add the following lines of code.

install(
  DIRECTORY launch
  DESTINATION share/${PROJECT\_NAME}
)

Copy to clipboard

Open a console and navigate to the root of your workspace, `ros2_ws`, and build your new package:

LinuxmacOSWindows

$ colcon build \--packages-select cpp\_parameters

Copy to clipboard

$ colcon build \--packages-select cpp\_parameters

Copy to clipboard

$ colcon build \--merge-install \--packages-select cpp\_parameters

Copy to clipboard

Then source the setup files in a new terminal:

LinuxmacOSWindows

$ source install/setup.bash

Copy to clipboard

$ . install/setup.bash

Copy to clipboard

$ call install/setup.bat

Copy to clipboard

Now run the node using the launch file we have just created. The terminal should return the following message the first time:

$ ros2 launch cpp\_parameters cpp\_parameters\_launch.py
\[INFO\] \[custom\_minimal\_param\_node\]: Hello earth!

Copy to clipboard

Further outputs should show `[INFO] [minimal_param_node]: Hello world!` every second.

[Summary](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#id7)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#summary "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

You created a node with a custom parameter that can be set either from a launch file or the command line. You added the dependencies, executables, and a launch file to the package configuration files so that you could build and run them, and see the parameter in action.

[Next steps](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#id8)
[](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html#next-steps "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Now that you have some packages and ROS 2 systems of your own, the [next tutorial](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Getting-Started-With-Ros2doctor.html)
 will show you how to examine issues in your environment and systems in case you have problems.

Other Versions v: jazzy

Releases

[Kilted (latest)](https://docs.ros.org/en/kilted/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html)

[Jazzy](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html)

[Iron (EOL)](https://docs.ros.org/en/iron/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html)

[Humble](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html)

[Galactic (EOL)](https://docs.ros.org/en/galactic/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html)

[Foxy (EOL)](https://docs.ros.org/en/foxy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html)

[Eloquent (EOL)](https://docs.ros.org/en/eloquent/index.html)

[Dashing (EOL)](https://docs.ros.org/en/dashing/index.html)

[Crystal (EOL)](https://docs.ros.org/en/crystal/index.html)

In Development

[Rolling](https://docs.ros.org/en/rolling/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html)
