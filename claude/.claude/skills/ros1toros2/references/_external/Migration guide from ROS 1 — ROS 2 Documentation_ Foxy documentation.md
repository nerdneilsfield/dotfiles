**Warning**

**You're reading the documentation for a version of ROS 2 that has reached its EOL (end-of-life), and is no longer officially supported. If you want up-to-date information, please have a look at [Kilted](https://docs.ros.org/en/kilted/index.html).**

Table of Contents

*   [Prerequisites](#prerequisites)
    
*   [Migration steps](#migration-steps)
    
    *   [Package manifests](#package-manifests)
        
    *   [Metapackages](#metapackages)
        
    *   [Message, service, and action definitions](#message-service-and-action-definitions)
        
    *   [Build system](#build-system)
        
    *   [Update source code](#update-source-code)
        
*   [Parameters](#parameters)
    
*   [Launch files](#launch-files)
    
*   [Example: Converting an existing ROS 1 package to use ROS 2](#example-converting-an-existing-ros-1-package-to-use-ros-2)
    
    *   [The ROS 1 code](#the-ros-1-code)
        
    *   [Migrating to ROS 2](#migrating-to-ros-2)
        
    *   [Update scripts](#update-scripts)
        
    *   [More examples and tools](#more-examples-and-tools)
        
*   [Licensing](#licensing)
    
    *   [Changing the License](#changing-the-license)
        

There are two different kinds of package migrations:

*   Migrating the source code of an existing package from ROS 1 to ROS 2 with the intent that a significant part of the source code will stay the same or at least similar. An example for this could be [pluginlib](https://github.com/ros/pluginlib) where the source code is maintained in different branches within the same repository and commonly patches can be ported between those branches when necessary.
    
*   Implementing the same or similar functionality of a ROS 1 package for ROS 2 but with the assumption that the source code will be significantly different. An example for this could be [roscpp](https://github.com/ros/ros_comm/tree/melodic-devel/clients/roscpp) in ROS 1 and [rclcpp](https://github.com/ros2/rclcpp/tree/rolling/rclcpp) in ROS 2 which are separate repositories and don’t share any code.
    

This article focuses on the former case and describes the high-level steps to migrate a ROS 1 package to ROS 2. It does not aim to be a step-by-step migration instruction and is not considered the _final_ “solution”. Future versions will aim to make migration smoother and less effort up to the point of maintaining a single package from the same branch for ROS 1 as well as ROS 2.

[Prerequisites](#id1)[](#prerequisites "Link to this heading")
---------------------------------------------------------------

Before being able to migrate a ROS 1 package to ROS 2 all of its dependencies must be available in ROS 2.

[Migration steps](#id2)[](#migration-steps "Link to this heading")
-------------------------------------------------------------------

*   [Package manifests](#package-manifests)
    
*   [Metapackages](#metapackages)
    
*   [Message, service, and action definitions](#message-service-and-action-definitions)
    
*   [Build system](#build-system)
    
*   [Update source code](#update-source-code)
    

### [Package manifests](#id17)[](#package-manifests "Link to this heading")

ROS 2 doesn’t support format 1 of the package specification but only newer format versions (2 and higher). Therefore the `package.xml` file must be updated to at least format 2 if it uses format 1. Since ROS 1 supports all formats it is safe to perform that conversion in the ROS 1 package.

Some packages might have different names in ROS 2 so the dependencies might need to be updated accordingly.

### [Metapackages](#id18)[](#metapackages "Link to this heading")

ROS 2 doesn’t have a special package type for metapackages. Metapackages can still exist as regular packages that only contain runtime dependencies. When migrating metapackages from ROS 1, simply remove the `<metapackage />` tag in your package manifest.

### [Message, service, and action definitions](#id19)[](#message-service-and-action-definitions "Link to this heading")

Message files must end in `.msg` and must be located in the subfolder `msg`. Service files must end in `.srv` and must be located in the subfolder `srv`. Actions files must end in `.action` and must be located in the subfolder `action`.

These files might need to be updated to comply with the [ROS Interface definition](https://design.ros2.org/articles/interface_definition.html). Some primitive types have been removed and the types `duration` and `time` which were builtin types in ROS 1 have been replaced with normal message definitions and must be used from the [builtin\_interfaces](https://github.com/ros2/rcl_interfaces/tree/foxy/builtin_interfaces) package. Also some naming conventions are stricter than in ROS 1.

In your `package.xml`:

*   Add `<buildtool_depend>rosidl_default_generators</buildtool_depend>`.
    
*   Add `<exec_depend>rosidl_default_runtime</exec_depend>`.
    
*   For each dependent message package, add `<depend>message_package</depend>`.
    

In your `CMakeLists.txt`:

*   Start by enabling C++14
    

set(CMAKE\_CXX\_STANDARD  14)

*   Add `find_package(rosidl_default_generators REQUIRED)`
    
*   For each dependent message package, add `find_package(message_package REQUIRED)` and replace the CMake function call to `generate_messages` with `rosidl_generate_interfaces`.
    

This will replace `add_message_files` and `add_service_files` listing of all the message and service files, which can be removed.

### [Build system](#id20)[](#build-system "Link to this heading")

The build system in ROS 2 is called [ament](https://design.ros2.org/articles/ament.html) and the build tool is [colcon](https://docs.ros.org/en/foxy/Tutorials/Beginner-Client-Libraries/Colcon-Tutorial.html). Ament is built on CMake: `ament_cmake` provides CMake functions to make writing `CMakeLists.txt` files easier.

#### Build tool[](#build-tool "Link to this heading")

Instead of using `catkin_make`, `catkin_make_isolated` or `catkin build` ROS 2 uses the command line tool [colcon](https://design.ros2.org/articles/build_tool.html) to build and install a set of packages.

#### Pure Python package[](#pure-python-package "Link to this heading")

If the ROS 1 package uses CMake only to invoke the `setup.py` file and does not contain anything beside Python code (e.g. also no messages, services, etc.) it should be converted into a pure Python package in ROS 2:

*   Update or add the build type in the `package.xml` file:
    
    <export>
      <build\_type>ament\_python</build\_type>
    </export>
    
*   Remove the `CMakeLists.txt` file
    
*   Update the `setup.py` file to be a standard Python setup script
    

ROS 2 supports Python 3 only. While each package can choose to also support Python 2 it must invoke executables with Python 3 if it uses any API provided by other ROS 2 packages.

#### Update the _CMakeLists.txt_ to use _ament\_cmake_[](#update-the-cmakelists-txt-to-use-ament-cmake "Link to this heading")

Apply the following changes to use `ament_cmake` instead of `catkin`:

*   Set the build type in the `package.xml` file export section:
    
    <export>
      <build\_type>ament\_cmake</build\_type>
    </export>
    
*   Replace the `find_package` invocation with `catkin` and the `COMPONENTS` with:
    
    find\_package(ament\_cmake  REQUIRED)
    find\_package(component1  REQUIRED)
    \# ...
    find\_package(componentN  REQUIRED)
    
*   Move and update the `catkin_package` invocation with:
    
    *   Invoke `ament_package` instead but **after** all targets have been registered.
        
    *   The only valid argument for [ament\_package](https://github.com/ament/ament_cmake/blob/foxy/ament_cmake_core/cmake/core/ament_package.cmake) is `CONFIG_EXTRAS`. All other arguments are covered by separate functions which all need to be invoked _before_ `ament_package`:
        
        *   Instead of passing `CATKIN_DEPENDS ...` call `ament_export_dependencies(...)` before.
            
        *   Instead of passing `INCLUDE_DIRS ...` call `ament_export_include_directories(...)` before.
            
        *   Instead of passing `LIBRARIES ...` call `ament_export_libraries(...)` before.
            
    *   **TODO document ament\_export\_targets (\`\`ament\_export\_interfaces\`\` in Eloquent and older)?**
        
*   Replace the invocation of `add_message_files`, `add_service_files` and `generate_messages` with [rosidl\_generate\_interfaces](https://github.com/ros2/rosidl/blob/foxy/rosidl_cmake/cmake/rosidl_generate_interfaces.cmake).
    
    *   The first argument is the `target_name`. If you’re building just one library it’s `${PROJECT_NAME}`
        
    *   Followed by the list of message filenames, relative to the package root.
        
        *   If you will be using the list of filenames multiple times, it is recommended to compose a list of message files and pass the list to the function for clarity.
            
    *   The final multi-value-keyword argument fpr `generate_messages` is `DEPENDENCIES` which requires the list of dependent message packages.
        
        rosidl\_generate\_interfaces(${PROJECT\_NAME}
          ${msg\_files}
          DEPENDENCIES  std\_msgs
        )
        
*   Remove any occurrences of the _devel space_. Related CMake variables like `CATKIN_DEVEL_PREFIX` do not exist anymore.
    
    *   The `CATKIN_DEPENDS` and `DEPENDS` arguments are passed to the new function [ament\_export\_dependencies](https://github.com/ament/ament_cmake/blob/foxy/ament_cmake_export_dependencies/cmake/ament_export_dependencies.cmake).
        
    *   `CATKIN_GLOBAL_BIN_DESTINATION`: `bin`
        
    *   `CATKIN_GLOBAL_INCLUDE_DESTINATION`: `include`
        
    *   `CATKIN_GLOBAL_LIB_DESTINATION`: `lib`
        
    *   `CATKIN_GLOBAL_LIBEXEC_DESTINATION`: `lib`
        
    *   `CATKIN_GLOBAL_SHARE_DESTINATION`: `share`
        
    *   `CATKIN_PACKAGE_BIN_DESTINATION`: `lib/${PROJECT_NAME}`
        
    *   `CATKIN_PACKAGE_INCLUDE_DESTINATION`: `include/${PROJECT_NAME}`
        
    *   `CATKIN_PACKAGE_LIB_DESTINATION`: `lib`
        
    *   `CATKIN_PACKAGE_SHARE_DESTINATION`: `share/${PROJECT_NAME}`
        

#### Unit tests[](#unit-tests "Link to this heading")

If you are using gtest:

Replace `CATKIN_ENABLE_TESTING` with `BUILD_TESTING`. Replace `catkin_add_gtest` with `ament_add_gtest`.

\-   if (CATKIN\_ENABLE\_TESTING)
\-     find\_package(GTest REQUIRED)  # or rostest
\-     include\_directories(${GTEST\_INCLUDE\_DIRS})
\-     catkin\_add\_gtest(${PROJECT\_NAME}-some-test src/test/some\_test.cpp)
\-     target\_link\_libraries(${PROJECT\_NAME}-some-test
\-       ${PROJECT\_NAME}\_some\_dependency
\-       ${catkin\_LIBRARIES}
\-       ${GTEST\_LIBRARIES})
\-   endif()
\+   if (BUILD\_TESTING)
\+     find\_package(ament\_cmake\_gtest REQUIRED)
\+     ament\_add\_gtest(${PROJECT\_NAME}-some-test src/test/test\_something.cpp)
\+     ament\_target\_dependencies(${PROJECT\_NAME)-some-test
\+       "rclcpp"
\+       "std\_msgs")
\+     target\_link\_libraries(${PROJECT\_NAME}-some-test
\+       ${PROJECT\_NAME}\_some\_dependency)
\+   endif()

Add `<test_depend>ament_cmake_gtest</test_depend>` to your `package.xml`.

\-   <test\_depend>rostest</test\_depend>
\+   <test\_depend>ament\_cmake\_gtest</test\_depend>

#### Linters[](#linters "Link to this heading")

In ROS 2 we are working to maintain clean code using linters. The styles for different languages are defined in our [Developer Guide](https://docs.ros.org/en/foxy/The-ROS2-Project/Contributing/Developer-Guide.html).

If you are starting a project from scratch it is recommended to follow the style guide and turn on the automatic linter unit tests by adding these lines just below `if(BUILD_TESTING)` (until alpha 5 this was `AMENT_ENABLE_TESTING`).

find\_package(ament\_lint\_auto  REQUIRED)
ament\_lint\_auto\_find\_test\_dependencies()

You will also need to add the following dependencies to your `package.xml`:

<test\_depend>ament\_lint\_auto</test\_depend>
<test\_depend>ament\_lint\_common</test\_depend>

#### Continue to use `catkin` in CMake[](#continue-to-use-catkin-in-cmake "Link to this heading")

ROS 2 uses ament as the build system but for backward compatibility ROS 2 has a package called `catkin` which provides almost the same API as catkin in ROS 1. In order to use this backward compatibility API the `CMakeLists.txt` must only be updated to call the function `catkin_ament_package()` _after_ all targets.

**NOTE: This has not been implemented yet and is only an idea at the moment. Due to the number of changes related to dependencies it has not yet been decided if this compatibility API is useful enough to justify the effort.**

### [Update source code](#id21)[](#update-source-code "Link to this heading")

#### Messages, services, and actions[](#messages-services-and-actions "Link to this heading")

The namespace of ROS 2 messages, services, and actions use a subnamespace (`msg`, `srv`, or `action`, respectively) after the package name. Therefore an include looks like: `#include <my_interfaces/msg/my_message.hpp>`. The C++ type is then named: `my_interfaces::msg::MyMessage`.

Shared pointer types are provided as typedefs within the message structs: `my_interfaces::msg::MyMessage::SharedPtr` as well as `my_interfaces::msg::MyMessage::ConstSharedPtr`.

For more details please see the article about the [generated C++ interfaces](https://design.ros2.org/articles/generated_interfaces_cpp.html).

The migration requires includes to change by:

*   inserting the subfolder `msg` between the package name and message datatype
    
*   changing the included filename from CamelCase to underscore separation
    
*   changing from `*.h` to `*.hpp`
    

// ROS 1 style is in comments, ROS 2 follows, uncommented.
// # include <geometry\_msgs/PointStamped.h>
#include  <geometry\_msgs/msg/point\_stamped.hpp>

// geometry\_msgs::PointStamped point\_stamped;
geometry\_msgs::msg::PointStamped  point\_stamped;

The migration requires code to insert the `msg` namespace into all instances.

#### Use of service objects[](#use-of-service-objects "Link to this heading")

Service callbacks in ROS 2 do not have boolean return values. Instead of returning false on failures, throwing exceptions is recommended.

// ROS 1 style is in comments, ROS 2 follows, uncommented.
// #include "nav\_msgs/GetMap.h"
#include  "nav\_msgs/srv/get\_map.hpp"

// bool service\_callback(
//   nav\_msgs::GetMap::Request & request,
//   nav\_msgs::GetMap::Response & response)
void  service\_callback(
  const  std::shared\_ptr<nav\_msgs::srv::GetMap::Request\>  request,
  std::shared\_ptr<nav\_msgs::srv::GetMap::Response\>  response)
{
  // ...
  // return true;  // or false for failure
}

#### Usages of ros::Time[](#usages-of-ros-time "Link to this heading")

For usages of `ros::Time`:

*   Replace all instances of `ros::Time` with `rclcpp::Time`
    
*   If your messages or code makes use of std\_msgs::Time:
    
    *   Convert all instances of std\_msgs::Time to builtin\_interfaces::msg::Time
        
    *   Convert all `#include "std_msgs/time.h` to `#include "builtin_interfaces/msg/time.hpp"`
        
    *   Convert all instances using the std\_msgs::Time field `nsec` to the builtin\_interfaces::msg::Time field `nanosec`
        

#### Usages of ros::Rate[](#usages-of-ros-rate "Link to this heading")

There is an equivalent type `rclcpp::Rate` object which is basically a drop in replacement for `ros::Rate`.

#### ROS client library[](#ros-client-library "Link to this heading")

**NOTE: Others to be written**

#### Boost[](#boost "Link to this heading")

Much of the functionality previously provided by Boost has been integrated into the C++ standard library. As such we would like to take advantage of the new core features and avoid the dependency on boost where possible.

##### Shared Pointers[](#shared-pointers "Link to this heading")

To switch shared pointers from boost to standard C++ replace instances of:

*   `#include <boost/shared_ptr.hpp>` with `#include <memory>`
    
*   `boost::shared_ptr` with `std::shared_ptr`
    

There may also be variants such as `weak_ptr` which you want to convert as well.

Also it is recommended practice to use `using` instead of `typedef`. `using` has the ability to work better in templated logic. For details [see here](https://stackoverflow.com/questions/10747810/what-is-the-difference-between-typedef-and-using-in-c11)

##### Thread/Mutexes[](#thread-mutexes "Link to this heading")

Another common part of boost used in ROS codebases are mutexes in `boost::thread`.

*   Replace `boost::mutex::scoped_lock` with `std::unique_lock<std::mutex>`
    
*   Replace `boost::mutex` with `std::mutex`
    
*   Replace `#include <boost/thread/mutex.hpp>` with `#include <mutex>`
    

##### Unordered Map[](#unordered-map "Link to this heading")

Replace:

*   `#include <boost/unordered_map.hpp>` with `#include <unordered_map>`
    
*   `boost::unordered_map` with `std::unordered_map`
    

##### function[](#function "Link to this heading")

Replace:

*   `#include <boost/function.hpp>` with `#include <functional>`
    
*   `boost::function` with `std::function`
    

[Parameters](#id8)[](#parameters "Link to this heading")
---------------------------------------------------------

In ROS 1, parameters are associated with a central server that allowed retrieving parameters at runtime through the use of the network APIs. In ROS 2, parameters are associated per node and are configurable at runtime with ROS services.

*   See [ROS 2 Parameter design document](https://design.ros2.org/articles/ros_parameters.html) for more details about the system model.
    
*   See [ROS 2 CLI usage](https://docs.ros.org/en/foxy/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Parameters/Understanding-ROS2-Parameters.html) for a better understanding of how the CLI tools work and its differences with ROS 1 tooling.
    
*   See [Migrating YAML parameter files from ROS 1 to ROS 2](https://docs.ros.org/en/foxy/How-To-Guides/Parameters-YAML-files-migration-guide.html) to see how YAML parameter files are parsed in ROS 2 and their differences with ROS implementation.
    

[Launch files](#id9)[](#launch-files "Link to this heading")
-------------------------------------------------------------

While launch files in ROS 1 are always specified using [.xml](https://wiki.ros.org/roslaunch/XML) files, ROS 2 supports Python scripts to enable more flexibility (see [launch package](https://github.com/ros2/launch/tree/foxy/launch)) as well as XML and YAML files. See [separate tutorial](https://docs.ros.org/en/foxy/How-To-Guides/Launch-files-migration-guide.html) on migrating launch files from ROS 1 to ROS 2.

[Example: Converting an existing ROS 1 package to use ROS 2](#id10)[](#example-converting-an-existing-ros-1-package-to-use-ros-2 "Link to this heading")
---------------------------------------------------------------------------------------------------------------------------------------------------------

Let’s say that we have simple ROS 1 package called `talker` that uses `roscpp` in one node, called `talker`. This package is in a catkin workspace, located at `~/ros1_talker`.

### [The ROS 1 code](#id11)[](#the-ros-1-code "Link to this heading")

Here’s the directory layout of our catkin workspace:

$  cd  ~/ros1\_talker
$  find  .
.
./src
./src/talker
./src/talker/package.xml
./src/talker/CMakeLists.txt
./src/talker/talker.cpp

Here is the content of those three files:

`src/talker/package.xml`:

<package>
  <name>talker</name>
  <version>0.0.0</version>
  <description>talker</description>
  <maintainer  email="gerkey@osrfoundation.org"\>Brian  Gerkey</maintainer>
  <license>Apache  2.0</license>
  <buildtool\_depend>catkin</buildtool\_depend>
  <build\_depend>roscpp</build\_depend>
  <build\_depend>std\_msgs</build\_depend>
  <run\_depend>roscpp</run\_depend>
  <run\_depend>std\_msgs</run\_depend>
</package>

`src/talker/CMakeLists.txt`:

cmake\_minimum\_required(VERSION  2.8.3)
project(talker)
find\_package(catkin  REQUIRED  COMPONENTS  roscpp  std\_msgs)
catkin\_package()
include\_directories(${catkin\_INCLUDE\_DIRS})
add\_executable(talker  talker.cpp)
target\_link\_libraries(talker  ${catkin\_LIBRARIES})
install(TARGETS  talker
  RUNTIME  DESTINATION  ${CATKIN\_PACKAGE\_BIN\_DESTINATION})

`src/talker/talker.cpp`:

#include  <sstream>
#include  "ros/ros.h"
#include  "std\_msgs/String.h"
int  main(int  argc,  char  \*\*argv)
{
  ros::init(argc,  argv,  "talker");
  ros::NodeHandle  n;
  ros::Publisher  chatter\_pub  \=  n.advertise<std\_msgs::String\>("chatter",  1000);
  ros::Rate  loop\_rate(10);
  int  count  \=  0;
  std\_msgs::String  msg;
  while  (ros::ok())
  {
  std::stringstream  ss;
  ss  <<  "hello world "  <<  count++;
  msg.data  \=  ss.str();
  ROS\_INFO("%s",  msg.data.c\_str());
  chatter\_pub.publish(msg);
  ros::spinOnce();
  loop\_rate.sleep();
  }
  return  0;
}

#### Building the ROS 1 code[](#building-the-ros-1-code "Link to this heading")

We source an environment setup file (in this case for Jade using bash), then we build our package using `catkin_make install`:

.  /opt/ros/jade/setup.bash
cd  ~/ros1\_talker
catkin\_make  install

#### Running the ROS 1 node[](#running-the-ros-1-node "Link to this heading")

If there’s not already one running, we start a `roscore`, first sourcing the setup file from our `catkin` install tree (the system setup file at `/opt/ros/jade/setup.bash` would also work here):

.  ~/ros1\_talker/install/setup.bash
roscore

In another shell, we run the node from the `catkin` install space using `rosrun`, again sourcing the setup file first (in this case it must be the one from our workspace):

.  ~/ros1\_talker/install/setup.bash
rosrun  talker  talker

### [Migrating to ROS 2](#id12)[](#migrating-to-ros-2 "Link to this heading")

Let’s start by creating a new workspace in which to work:

mkdir  ~/ros2\_talker
cd  ~/ros2\_talker

We’ll copy the source tree from our ROS 1 package into that workspace, where we can modify it:

mkdir  src
cp  \-a  ~/ros1\_talker/src/talker  src

Now we’ll modify the C++ code in the node. The ROS 2 C++ library, called `rclcpp`, provides a different API from that provided by `roscpp`. The concepts are very similar between the two libraries, which makes the changes reasonably straightforward to make.

#### Changing C++ library calls[](#changing-c-library-calls "Link to this heading")

Instead of passing the node’s name to the library initialization call, we do the initialization, then pass the node name to the creation of the node object (we can use the `auto` keyword because now we’re requiring a C++14 compiler):

//  ros::init(argc, argv, "talker");
//  ros::NodeHandle n;
  rclcpp::init(argc,  argv);
  auto  node  \=  rclcpp::Node::make\_shared("talker");

The creation of the publisher and rate objects looks pretty similar, with some changes to the names of namespace and methods.

//  ros::Publisher chatter\_pub = n.advertise<std\_msgs::String>("chatter", 1000);
//  ros::Rate loop\_rate(10);
  auto  chatter\_pub  \=  node\->create\_publisher<std\_msgs::msg::String\>("chatter",
  1000);
  rclcpp::Rate  loop\_rate(10);

To further control how message delivery is handled, a quality of service (`QoS`) profile could be passed in. The default profile is `rmw_qos_profile_default`. For more details, see the [design document](https://design.ros2.org/articles/qos.html) and [concept overview](https://docs.ros.org/en/foxy/Concepts/About-Quality-of-Service-Settings.html).

The creation of the outgoing message is different in the namespace:

//  std\_msgs::String msg;
  std\_msgs::msg::String  msg;

In place of `ros::ok()`, we call `rclcpp::ok()`:

//  while (ros::ok())
  while  (rclcpp::ok())

Inside the publishing loop, we access the `data` field as before:

To print a console message, instead of using `ROS_INFO()`, we use `RCLCPP_INFO()` and its various cousins. The key difference is that `RCLCPP_INFO()` takes a Logger object as the first argument.

//    ROS\_INFO("%s", msg.data.c\_str());
  RCLCPP\_INFO(node\->get\_logger(),  "%s\\n",  msg.data.c\_str());

Publishing the message is the same as before:

chatter\_pub\->publish(msg);

Spinning (i.e., letting the communications system process any pending incoming/outgoing messages) is different in that the call now takes the node as an argument:

//    ros::spinOnce();
  rclcpp::spin\_some(node);

Sleeping using the rate object is unchanged.

Putting it all together, the new `talker.cpp` looks like this:

#include  <sstream>
// #include "ros/ros.h"
#include  "rclcpp/rclcpp.hpp"
// #include "std\_msgs/String.h"
#include  "std\_msgs/msg/string.hpp"
int  main(int  argc,  char  \*\*argv)
{
//  ros::init(argc, argv, "talker");
//  ros::NodeHandle n;
  rclcpp::init(argc,  argv);
  auto  node  \=  rclcpp::Node::make\_shared("talker");
//  ros::Publisher chatter\_pub = n.advertise<std\_msgs::String>("chatter", 1000);
//  ros::Rate loop\_rate(10);
  auto  chatter\_pub  \=  node\->create\_publisher<std\_msgs::msg::String\>("chatter",  1000);
  rclcpp::Rate  loop\_rate(10);
  int  count  \=  0;
//  std\_msgs::String msg;
  std\_msgs::msg::String  msg;
//  while (ros::ok())
  while  (rclcpp::ok())
  {
  std::stringstream  ss;
  ss  <<  "hello world "  <<  count++;
  msg.data  \=  ss.str();
//    ROS\_INFO("%s", msg.data.c\_str());
  RCLCPP\_INFO(node\->get\_logger(),  "%s\\n",  msg.data.c\_str());
  chatter\_pub\->publish(msg);
//    ros::spinOnce();
  rclcpp::spin\_some(node);
  loop\_rate.sleep();
  }
  return  0;
}

#### Changing the `package.xml`[](#changing-the-package-xml "Link to this heading")

ROS 2 doesn’t support format 1 of the package specification but only newer format versions (2 and higher). We start by specifying the format version in the `package` tag:

<!-- <package> -->
<package  format="2"\>

ROS 2 uses a newer version of `catkin`, called `ament_cmake`, which we specify in the `buildtool_depend` tag:

<!--  <buildtool\_depend>catkin</buildtool\_depend> -->
  <buildtool\_depend>ament\_cmake</buildtool\_depend>

In our build dependencies, instead of `roscpp` we use `rclcpp`, which provides the C++ API that we use.

<!--  <build\_depend>roscpp</build\_depend> -->
  <build\_depend>rclcpp</build\_depend>

We make the same addition in the run dependencies and also update from the `run_depend` tag to the `exec_depend` tag (part of the upgrade to version 2 of the package format):

<!--  <run\_depend>roscpp</run\_depend> -->
  <exec\_depend>rclcpp</exec\_depend>
<!--  <run\_depend>std\_msgs</run\_depend> -->
  <exec\_depend>std\_msgs</exec\_depend>

In ROS 1, we use `<depend>` to simplify specifying dependencies for both compile-time and runtime. We can do the same in ROS 2:

<depend>rclcpp</depend>
<depend>std\_msgs</depend>

We also need to tell the build tool what _kind_ of package we are, so that it knows how to build us. Because we’re using `ament` and CMake, we add the following lines to declare our build type to be `ament_cmake`:

<export>
  <build\_type>ament\_cmake</build\_type>
</export>

Putting it all together, our `package.xml` now looks like this:

<!-- <package> -->
<package  format="2"\>
  <name>talker</name>
  <version>0.0.0</version>
  <description>talker</description>
  <maintainer  email="gerkey@osrfoundation.org"\>Brian  Gerkey</maintainer>
  <license>Apache  License  2.0</license>
<!--  <buildtool\_depend>catkin</buildtool\_depend> -->
  <buildtool\_depend>ament\_cmake</buildtool\_depend>
<!--  <build\_depend>roscpp</build\_depend> -->
<!--  <run\_depend>roscpp</run\_depend> -->
<!--  <run\_depend>std\_msgs</run\_depend> -->
  <depend>rclcpp</depend>
  <depend>std\_msgs</depend>
  <export>
  <build\_type>ament\_cmake</build\_type>
  </export>
</package>

**TODO: show simpler version of this file just using the \`\`<depend>\`\` tag, which is enabled by version 2 of the package format (also supported in \`\`catkin\`\` so, strictly speaking, orthogonal to ROS 2).**

#### Changing the CMake code[](#changing-the-cmake-code "Link to this heading")

ROS 2 relies on a higher version of CMake:

#cmake\_minimum\_required(VERSION 2.8.3)
cmake\_minimum\_required(VERSION  3.5)

ROS 2 relies on the C++14 standard. Depending on what compiler you’re using, support for C++14 might not be enabled by default. Using `gcc` 5.3 (which is what is used on Ubuntu Xenial), we need to enable it explicitly, which we do by adding this line near the top of the file:

set(CMAKE\_CXX\_STANDARD  14)

The preferred way to work on all platforms is this:

if(NOT  CMAKE\_CXX\_STANDARD)
  set(CMAKE\_CXX\_STANDARD  14)
endif()
if(CMAKE\_COMPILER\_IS\_GNUCXX  OR  CMAKE\_CXX\_COMPILER\_ID  MATCHES  "Clang")
  add\_compile\_options(\-Wall  \-Wextra  \-Wpedantic)
endif()

Using `catkin`, we specify the packages we want to build against by passing them as `COMPONENTS` arguments when initially finding `catkin` itself. With `ament_cmake`, we find each package individually, starting with `ament_cmake`:

#find\_package(catkin REQUIRED COMPONENTS roscpp std\_msgs)
find\_package(ament\_cmake  REQUIRED)
find\_package(rclcpp  REQUIRED)
find\_package(std\_msgs  REQUIRED)

System dependencies can be found as before:

find\_package(Boost  REQUIRED  COMPONENTS  system  filesystem  thread)

We call `catkin_package()` to auto-generate things like CMake configuration files for other packages that use our package. Whereas that call happens _before_ specifying targets to build, we now call the analogous `ament_package()` _after_ the targets:

\# catkin\_package()
\# At the bottom of the file:
ament\_package()

The only directories that need to be manually included are local directories and dependencies that are not ament packages:

#include\_directories(${catkin\_INCLUDE\_DIRS})
include\_directories(include  ${Boost\_INCLUDE\_DIRS})

A better alternative is to specify include directories for each target individually, rather than including all the directories for all targets:

target\_include\_directories(target  PUBLIC  include  ${Boost\_INCLUDE\_DIRS})

Similar to how we found each dependent package separately, we need to link each one to the build target. To link with dependent packages that are ament packages, instead of using `target_link_libraries()`, `ament_target_dependencies()` is a more concise and more thorough way of handling build flags. It automatically handles both the include directories defined in `_INCLUDE_DIRS` and linking libraries defined in `_LIBRARIES`.

#target\_link\_libraries(talker ${catkin\_LIBRARIES})
ament\_target\_dependencies(talker
  rclcpp
  std\_msgs)

To link with packages that are not ament packages, such as system dependencies like `Boost`, or a library being built in the same `CMakeLists.txt`, use `target_link_libraries()`:

target\_link\_libraries(target  ${Boost\_LIBRARIES})

For installation, `catkin` defines variables like `CATKIN_PACKAGE_BIN_DESTINATION`. With `ament_cmake`, we just give a path relative to the installation root, like `bin` for executables:

#install(TARGETS talker
\#  RUNTIME DESTINATION ${CATKIN\_PACKAGE\_BIN\_DESTINATION})
install(TARGETS  talker
  DESTINATION  lib/${PROJECT\_NAME})

Optionally, we can install and export the included directories for downstream packages:

install(DIRECTORY  include/
  DESTINATION  include)
ament\_export\_include\_directories(include)

Optionally, we can export dependencies for downstream packages:

ament\_export\_dependencies(std\_msgs)

Putting it all together, the new `CMakeLists.txt` looks like this:

#cmake\_minimum\_required(VERSION 2.8.3)
cmake\_minimum\_required(VERSION  3.5)
project(talker)
if(NOT  CMAKE\_CXX\_STANDARD)
  set(CMAKE\_CXX\_STANDARD  14)
endif()
if(CMAKE\_COMPILER\_IS\_GNUCXX  OR  CMAKE\_CXX\_COMPILER\_ID  MATCHES  "Clang")
  add\_compile\_options(\-Wall  \-Wextra  \-Wpedantic)
endif()
#find\_package(catkin REQUIRED COMPONENTS roscpp std\_msgs)
find\_package(ament\_cmake  REQUIRED)
find\_package(rclcpp  REQUIRED)
find\_package(std\_msgs  REQUIRED)
#catkin\_package()
#include\_directories(${catkin\_INCLUDE\_DIRS})
include\_directories(include)
add\_executable(talker  talker.cpp)
#target\_link\_libraries(talker ${catkin\_LIBRARIES})
ament\_target\_dependencies(talker
  rclcpp
  std\_msgs)
#install(TARGETS talker
\#  RUNTIME DESTINATION ${CATKIN\_PACKAGE\_BIN\_DESTINATION})
install(TARGETS  talker
  DESTINATION  lib/${PROJECT\_NAME})
install(DIRECTORY  include/
  DESTINATION  include)
ament\_export\_include\_directories(include)
ament\_export\_dependencies(std\_msgs)
ament\_package()

**TODO: Show what this would look like with \`\`ament\_auto\`\`.**

#### Building the ROS 2 code[](#building-the-ros-2-code "Link to this heading")

We source an environment setup file (in this case the one generated by following the ROS 2 installation tutorial, which builds in `~/ros2_ws`, then we build our package using `colcon build`:

.  ~/ros2\_ws/install/setup.bash
cd  ~/ros2\_talker
colcon  build

#### Running the ROS 2 node[](#running-the-ros-2-node "Link to this heading")

Because we installed the `talker` executable into `bin`, after sourcing the setup file, from our install tree, we can invoke it by name directly (also, there is not yet a ROS 2 equivalent for `rosrun`):

.  ~/ros2\_ws/install/setup.bash
talker

### [Update scripts](#id13)[](#update-scripts "Link to this heading")

#### ROS CLI arguments[](#ros-cli-arguments "Link to this heading")

Since [ROS Eloquent](https://docs.ros.org/en/foxy/Releases/Release-Eloquent-Elusor.html), ROS arguments should be scoped with `--ros-args` and a trailing `--` (the trailing double dash may be elided if no arguments follow it).

Remapping names is similar to ROS 1, taking on the form `from:=to`, except that it must be preceded by a `--remap` (or `-r`) flag. For example:

ros2  run  some\_package  some\_ros\_executable  \--ros-args  \-r  foo:\=bar

We use a similar syntax for parameters, using the `--param` (or `-p`) flag:

ros2  run  some\_package  some\_ros\_executable  \--ros-args  \-p  my\_param:\=value

Note, this is different than using a leading underscore in ROS 1.

To change a node name use `__node` (the ROS 1 equivalent is `__name`):

ros2  run  some\_package  some\_ros\_executable  \--ros-args  \-r  \_\_node:\=new\_node\_name

Note the use of the `-r` flag. The same remap flag is needed for changing the namespace `__ns`:

ros2  run  some\_package  some\_ros\_executable  \--ros-args  \-r  \_\_ns:\=/new/namespace

There is no equivalent in ROS 2 for the following ROS 1 keys:

*   `__log` (but `--log-config-file` can be used to provide a logger configuration file)
    
*   `__ip`
    
*   `__hostname`
    
*   `__master`
    

For more information, see the [design document](https://design.ros2.org/articles/ros_command_line_arguments.html).

##### Quick reference[](#quick-reference "Link to this heading")

| 

Feature

 | 

ROS 1

 | 

ROS 2

 |
| --- | --- | --- |
| 

remapping

 | 

foo:=bar

 | 

\-r foo:=bar

 |
| 

parameters

 | 

\_foo:=bar

 | 

\-p foo:=bar

 |
| 

node name

 | 

\_\_name:=foo

 | 

\-r \_\_node:=foo

 |
| 

namespace

 | 

\_\_ns:=foo

 | 

\-r \_\_ns:=foo

 |

### [More examples and tools](#id14)[](#more-examples-and-tools "Link to this heading")

*   Launch File migrator that converts a ROS 1 XML launch file to a ROS 2 Python launch file: [https://github.com/aws-robotics/ros2-launch-file-migrator](https://github.com/aws-robotics/ros2-launch-file-migrator)
    
*   Amazon has exposed their tools for porting ROS 1 robots to ROS 2 [https://github.com/awslabs/ros2-migration-tools/tree/master/porting\_tools](https://github.com/awslabs/ros2-migration-tools/tree/master/porting_tools)
    

[Licensing](#id15)[](#licensing "Link to this heading")
--------------------------------------------------------

In ROS 2 our recommended license is the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0). In ROS 1 our recommended license was the [3-Clause BSD License](https://opensource.org/licenses/BSD-3-Clause).

For any new project we recommend using the Apache 2.0 License, whether ROS 1 or ROS 2.

However, when migrating code from ROS 1 to ROS 2 we cannot simply change the license. The existing license must be preserved for any preexisting contributions.

To that end if a package is being migrated we recommend keeping the existing license and continuing to contribute to that package under the existing OSI license, which we expect to be the BSD license for core elements.

This will keep things clear and easy to understand.

### [Changing the License](#id16)[](#changing-the-license "Link to this heading")

It is possible to change the license, however you will need to contact all the contributors and get permission. For most packages this is likely to be a significant effort and not worth considering. If the package has a small set of contributors then this may be feasible.