---
source_url: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html
fetched_at: 2026-04-18T00:00:00Z
---

# Writing an action server and client (C++) — ROS 2 Documentation: Jazzy  documentation

Writing an action server and client (C++) — ROS 2 Documentation: Jazzy  documentation

-
- Tutorials
- Intermediate
- Writing an action server and client (C++)
-  Edit on GitHub


You're reading the documentation for an older, but still supported, version of ROS 2.
For information on the latest version, please have a look at Kilted.



Writing an action server and client (C++)

Goal: Implement an action server and client in C++.

Tutorial level: Intermediate

Time: 15 minutes

Background

Actions are a form of asynchronous communication in ROS.
Action clients send goal requests to action servers.
Action servers send goal feedback and results to action clients.

Prerequisites

You will need the `custom_action_interfaces` package and the `Fibonacci.action`
interface defined in the previous tutorial, Creating an action.

Tasks

1 Creating the custom_action_cpp package

As we saw in the Creating a package tutorial, we need to create a new package to hold our C++ and supporting code.

1.1 Creating the custom_action_cpp package

Go into the action workspace you created in the previous tutorial (remember to source the workspace), and create a new package for the C++ action server:

LinuxmacOSWindows

```
$ cd ~/ros2_ws/src
$ ros2 pkg create --dependencies custom_action_interfaces rclcpp rclcpp_action rclcpp_components --license Apache-2.0 -- custom_action_cpp

```

```
$ cd ~/ros2_ws/src
$ ros2 pkg create --dependencies custom_action_interfaces rclcpp rclcpp_action rclcpp_components --license Apache-2.0 -- custom_action_cpp

```

```
$ cd \ros2_ws\src
$ ros2 pkg create --dependencies custom_action_interfaces rclcpp rclcpp_action rclcpp_components --license Apache-2.0 -- custom_action_cpp

```

1.2 Adding in visibility control

In order to make the package compile and work on Windows, we need to add in some “visibility control”.
For more details, see Windows Symbol Visibility in the Windows Tips and Tricks document.

Open up `custom_action_cpp/include/custom_action_cpp/visibility_control.h`, and put the following code in:

```
#ifndef CUSTOM_ACTION_CPP__VISIBILITY_CONTROL_H_
#define CUSTOM_ACTION_CPP__VISIBILITY_CONTROL_H_

#ifdef __cplusplus
extern "C"
{
#endif

// This logic was borrowed (then namespaced) from the examples on the gcc wiki:
//     https://gcc.gnu.org/wiki/Visibility

#if defined _WIN32 || defined __CYGWIN__
#ifdef __GNUC__
#define CUSTOM_ACTION_CPP_EXPORT __attribute__ ((dllexport))
#define CUSTOM_ACTION_CPP_IMPORT __attribute__ ((dllimport))
#else
#define CUSTOM_ACTION_CPP_EXPORT __declspec(dllexport)
#define CUSTOM_ACTION_CPP_IMPORT __declspec(dllimport)
#endif
#ifdef CUSTOM_ACTION_CPP_BUILDING_DLL
#define CUSTOM_ACTION_CPP_PUBLIC CUSTOM_ACTION_CPP_EXPORT
#else
#define CUSTOM_ACTION_CPP_PUBLIC CUSTOM_ACTION_CPP_IMPORT
#endif
#define CUSTOM_ACTION_CPP_PUBLIC_TYPE CUSTOM_ACTION_CPP_PUBLIC
#define CUSTOM_ACTION_CPP_LOCAL
#else
#define CUSTOM_ACTION_CPP_EXPORT __attribute__ ((visibility("default")))
#define CUSTOM_ACTION_CPP_IMPORT
#if __GNUC__ >= 4
#define CUSTOM_ACTION_CPP_PUBLIC __attribute__ ((visibility("default")))
#define CUSTOM_ACTION_CPP_LOCAL  __attribute__ ((visibility("hidden")))
#else
#define CUSTOM_ACTION_CPP_PUBLIC
#define CUSTOM_ACTION_CPP_LOCAL
#endif
#define CUSTOM_ACTION_CPP_PUBLIC_TYPE
#endif

#ifdef __cplusplus
}
#endif

#endif  // CUSTOM_ACTION_CPP__VISIBILITY_CONTROL_H_

```

2 Writing an action server

Let’s focus on writing an action server that computes the Fibonacci sequence using the action we created in the Creating an action tutorial.

2.1 Writing the action server code

Open up `custom_action_cpp/src/fibonacci_action_server.cpp`, and put the following code in:

```
#include <functional>
#include <memory>
#include <thread>

#include "custom_action_interfaces/action/fibonacci.hpp"
#include "rclcpp/rclcpp.hpp"
#include "rclcpp_action/rclcpp_action.hpp"
#include "rclcpp_components/register_node_macro.hpp"

#include "custom_action_cpp/visibility_control.hpp"

namespace custom_action_cpp
{
class FibonacciActionServer : public rclcpp::Node
{
public:
using Fibonacci = custom_action_interfaces::action::Fibonacci;
using GoalHandleFibonacci = rclcpp_action::ServerGoalHandle<Fibonacci>;

CUSTOM_ACTION_CPP_PUBLIC
explicit FibonacciActionServer(const rclcpp::NodeOptions & options = rclcpp::NodeOptions())
: Node("fibonacci_action_server", options)
{
using namespace std::placeholders;

auto handle_goal = [this](
const rclcpp_action::GoalUUID & uuid,
std::shared_ptr<const Fibonacci::Goal> goal)
{
RCLCPP_INFO(this->get_logger(), "Received goal request with order %d", goal->order);
(void)uuid;
return rclcpp_action::GoalResponse::ACCEPT_AND_EXECUTE;
};

auto handle_cancel = [this](
const std::shared_ptr<GoalHandleFibonacci> goal_handle)
{
RCLCPP_INFO(this->get_logger(), "Received request to cancel goal");
(void)goal_handle;
return rclcpp_action::CancelResponse::ACCEPT;
};

auto handle_accepted = [this](
const std::shared_ptr<GoalHandleFibonacci> goal_handle)
{
// this needs to return quickly to avoid blocking the executor,
// so we declare a lambda function to be called inside a new thread
auto execute_in_thread = [this, goal_handle](){return this->execute(goal_handle);};
std::thread{execute_in_thread}.detach();
};

this->action_server_ = rclcpp_action::create_server<Fibonacci>(
this,
"fibonacci",
handle_goal,
handle_cancel,
handle_accepted);
}

private:
rclcpp_action::Server<Fibonacci>::SharedPtr action_server_;

void execute(const std::shared_ptr<GoalHandleFibonacci> goal_handle) {
RCLCPP_INFO(this->get_logger(), "Executing goal");
rclcpp::Rate loop_rate(1);
const auto goal = goal_handle->get_goal();
auto feedback = std::make_shared<Fibonacci::Feedback>();
auto & sequence = feedback->partial_sequence;
sequence.push_back(0);
sequence.push_back(1);
auto result = std::make_shared<Fibonacci::Result>();

for (int i = 1; (i < goal->order) && rclcpp::ok(); ++i) {
// Check if there is a cancel request
if (goal_handle->is_canceling()) {
result->sequence = sequence;
goal_handle->canceled(result);
RCLCPP_INFO(this->get_logger(), "Goal canceled");
return;
}
// Update sequence
sequence.push_back(sequence[i] + sequence[i - 1]);
// Publish feedback
goal_handle->publish_feedback(feedback);
RCLCPP_INFO(this->get_logger(), "Publish feedback");

loop_rate.sleep();
}

// Check if goal is done
if (rclcpp::ok()) {
result->sequence = sequence;
goal_handle->succeed(result);
RCLCPP_INFO(this->get_logger(), "Goal succeeded");
}
};

};  // class FibonacciActionServer

}  // namespace custom_action_cpp

RCLCPP_COMPONENTS_REGISTER_NODE(custom_action_cpp::FibonacciActionServer)

```

The first few lines include all of the headers we need to compile.

Next we create a class that is a derived class of `rclcpp::Node`:

```
class FibonacciActionServer : public rclcpp::Node

```

The constructor for the `FibonacciActionServer` class initializes the node name as `fibonacci_action_server`:

```
explicit FibonacciActionServer(const rclcpp::NodeOptions & options = rclcpp::NodeOptions())
: Node("fibonacci_action_server", options)

```

The constructor also instantiates a new action server:

```
this->action_server_ = rclcpp_action::create_server<Fibonacci>(
this,
"fibonacci",
handle_goal,
handle_cancel,
handle_accepted);

```

An action server requires 6 things:

-
The templated action type name: `Fibonacci`.

-
A ROS 2 node to add the action to: `this`.

-
The action name: `'fibonacci'`.

-
A callback function for handling goals: `handle_goal`

-
A callback function for handling cancellation: `handle_cancel`.

-
A callback function for handling goal accept: `handle_accept`.

The implementation of the various callbacks is done with lambda expressions within the constructor.
Note that all of the callbacks need to return quickly, otherwise we risk starving the executor.

We start with the callback for handling new goals:

```
auto handle_goal = [this](
const rclcpp_action::GoalUUID & uuid,
std::shared_ptr<const Fibonacci::Goal> goal)
{
RCLCPP_INFO(this->get_logger(), "Received goal request with order %d", goal->order);
(void)uuid;
return rclcpp_action::GoalResponse::ACCEPT_AND_EXECUTE;
};

```

This implementation just accepts all goals.

Next up is the callback for dealing with cancellation:

```
auto handle_cancel = [this](
const std::shared_ptr<GoalHandleFibonacci> goal_handle)
{
RCLCPP_INFO(this->get_logger(), "Received request to cancel goal");
(void)goal_handle;
return rclcpp_action::CancelResponse::ACCEPT;
};

```

This implementation just tells the client that it accepted the cancellation.

The last of the callbacks accepts a new goal and starts processing it:

```
auto handle_accepted = [this](
const std::shared_ptr<GoalHandleFibonacci> goal_handle)
{
// this needs to return quickly to avoid blocking the executor,
// so we declare a lambda function to be called inside a new thread
auto execute_in_thread = [this, goal_handle](){return this->execute(goal_handle);};
std::thread{execute_in_thread}.detach();
};

```

Since the execution is a long-running operation, we spawn off a thread to do the actual work and return from `handle_accepted` quickly.

All further processing and updates are done in the `execute` method in the new thread:

```
void execute(const std::shared_ptr<GoalHandleFibonacci> goal_handle) {
RCLCPP_INFO(this->get_logger(), "Executing goal");
rclcpp::Rate loop_rate(1);
const auto goal = goal_handle->get_goal();
auto feedback = std::make_shared<Fibonacci::Feedback>();
auto & sequence = feedback->partial_sequence;
sequence.push_back(0);
sequence.push_back(1);
auto result = std::make_shared<Fibonacci::Result>();

for (int i = 1; (i < goal->order) && rclcpp::ok(); ++i) {
// Check if there is a cancel request
if (goal_handle->is_canceling()) {
result->sequence = sequence;
goal_handle->canceled(result);
RCLCPP_INFO(this->get_logger(), "Goal canceled");
return;
}
// Update sequence
sequence.push_back(sequence[i] + sequence[i - 1]);
// Publish feedback
goal_handle->publish_feedback(feedback);
RCLCPP_INFO(this->get_logger(), "Publish feedback");

loop_rate.sleep();
}

// Check if goal is done
if (rclcpp::ok()) {
result->sequence = sequence;
goal_handle->succeed(result);
RCLCPP_INFO(this->get_logger(), "Goal succeeded");
}
};

```

This work thread processes one sequence number of the Fibonacci sequence every second, publishing a feedback update for each step.
When it has finished processing, it marks the `goal_handle` as succeeded, and quits.

We now have a fully functioning action server.
Let’s get it built and running.

2.2 Compiling the action server

In the previous section we put the action server code into place.
To get it to compile and run, we need to do a couple of additional things.

First we need to setup the CMakeLists.txt so that the action server is compiled.
Open up `custom_action_cpp/CMakeLists.txt`, and add the following right after the `find_package` calls:

```
add_library(action_server SHARED
src/fibonacci_action_server.cpp)
target_include_directories(action_server PRIVATE
$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
$<INSTALL_INTERFACE:include>)
target_compile_definitions(action_server
PRIVATE "CUSTOM_ACTION_CPP_BUILDING_DLL")
ament_target_dependencies(action_server
"custom_action_interfaces"
"rclcpp"
"rclcpp_action"
"rclcpp_components")
rclcpp_components_register_node(action_server PLUGIN "custom_action_cpp::FibonacciActionServer" EXECUTABLE fibonacci_action_server)
install(TARGETS
action_server
ARCHIVE DESTINATION lib
LIBRARY DESTINATION lib
RUNTIME DESTINATION bin)

```

And now we can compile the package.
Go to the top-level of the `ros2_ws`, and run:

```
$ colcon build

```

This should compile the entire workspace, including the `fibonacci_action_server` in the `custom_action_cpp` package.

2.3 Running the action server

Now that we have the action server built, we can run it.
Source the workspace we just built (`ros2_ws`), and try to run the action server:

```
$ ros2 run custom_action_cpp fibonacci_action_server

```

3 Writing an action client

3.1 Writing the action client code

Open up `custom_action_cpp/src/fibonacci_action_client.cpp`, and put the following code in:

```
#include <functional>
#include <future>
#include <memory>
#include <string>
#include <sstream>

#include "custom_action_interfaces/action/fibonacci.hpp"

#include "rclcpp/rclcpp.hpp"
#include "rclcpp_action/rclcpp_action.hpp"
#include "rclcpp_components/register_node_macro.hpp"

namespace custom_action_cpp
{
class FibonacciActionClient : public rclcpp::Node
{
public:
using Fibonacci = custom_action_interfaces::action::Fibonacci;
using GoalHandleFibonacci = rclcpp_action::ClientGoalHandle<Fibonacci>;

explicit FibonacciActionClient(const rclcpp::NodeOptions & options)
: Node("fibonacci_action_client", options)
{
this->client_ptr_ = rclcpp_action::create_client<Fibonacci>(
this,
"fibonacci");

auto timer_callback_lambda = [this](){ return this->send_goal(); };
this->timer_ = this->create_wall_timer(
std::chrono::milliseconds(500),
timer_callback_lambda);
}

void send_goal()
{
using namespace std::placeholders;

this->timer_->cancel();

if (!this->client_ptr_->wait_for_action_server()) {
RCLCPP_ERROR(this->get_logger(), "Action server not available after waiting");
rclcpp::shutdown();
}

auto goal_msg = Fibonacci::Goal();
goal_msg.order = 10;

RCLCPP_INFO(this->get_logger(), "Sending goal");

auto send_goal_options = rclcpp_action::Client<Fibonacci>::SendGoalOptions();
send_goal_options.goal_response_callback = [this](const GoalHandleFibonacci::SharedPtr & goal_handle)
{
if (!goal_handle) {
RCLCPP_ERROR(this->get_logger(), "Goal was rejected by server");
} else {
RCLCPP_INFO(this->get_logger(), "Goal accepted by server, waiting for result");
}
};

send_goal_options.feedback_callback = [this](
GoalHandleFibonacci::SharedPtr,
const std::shared_ptr<const Fibonacci::Feedback> feedback)
{
std::stringstream ss;
ss << "Next number in sequence received: ";
for (auto number : feedback->partial_sequence) {
ss << number << " ";
}
RCLCPP_INFO(this->get_logger(), ss.str().c_str());
};

send_goal_options.result_callback = [this](const GoalHandleFibonacci::WrappedResult & result)
{
switch (result.code) {
case rclcpp_action::ResultCode::SUCCEEDED:
break;
case rclcpp_action::ResultCode::ABORTED:
RCLCPP_ERROR(this->get_logger(), "Goal was aborted");
return;
case rclcpp_action::ResultCode::CANCELED:
RCLCPP_ERROR(this->get_logger(), "Goal was canceled");
return;
default:
RCLCPP_ERROR(this->get_logger(), "Unknown result code");
return;
}
std::stringstream ss;
ss << "Result received: ";
for (auto number : result.result->sequence) {
ss << number << " ";
}
RCLCPP_INFO(this->get_logger(), ss.str().c_str());
rclcpp::shutdown();
};
this->client_ptr_->async_send_goal(goal_msg, send_goal_options);
}

private:
rclcpp_action::Client<Fibonacci>::SharedPtr client_ptr_;
rclcpp::TimerBase::SharedPtr timer_;
};  // class FibonacciActionClient

}  // namespace custom_action_cpp

RCLCPP_COMPONENTS_REGISTER_NODE(custom_action_cpp::FibonacciActionClient)

```

The first few lines include all of the headers we need to compile.

Next we create a class that is a derived class of `rclcpp::Node`:

```
class FibonacciActionClient : public rclcpp::Node

```

The constructor for the `FibonacciActionClient` class initializes the node name as `fibonacci_action_client`:

```
explicit FibonacciActionClient(const rclcpp::NodeOptions & options)
: Node("fibonacci_action_client", options)

```

The constructor also instantiates a new action client:

```
this->client_ptr_ = rclcpp_action::create_client<Fibonacci>(
this,
"fibonacci");

```

An action client requires 3 things:

-
The templated action type name: `Fibonacci`.

-
A ROS 2 node to add the action client to: `this`.

-
The action name: `'fibonacci'`.

We also instantiate a ROS timer that will kick off the one and only call to `send_goal`:

```
auto timer_callback_lambda = [this](){ return this->send_goal(); };
this->timer_ = this->create_wall_timer(
std::chrono::milliseconds(500),
timer_callback_lambda);

```

When the timer expires, it will call `send_goal`:

```
void send_goal()
{
using namespace std::placeholders;

this->timer_->cancel();

if (!this->client_ptr_->wait_for_action_server()) {
RCLCPP_ERROR(this->get_logger(), "Action server not available after waiting");
rclcpp::shutdown();
}

auto goal_msg = Fibonacci::Goal();
goal_msg.order = 10;

RCLCPP_INFO(this->get_logger(), "Sending goal");

auto send_goal_options = rclcpp_action::Client<Fibonacci>::SendGoalOptions();
send_goal_options.goal_response_callback = [this](const GoalHandleFibonacci::SharedPtr & goal_handle)
{
if (!goal_handle) {
RCLCPP_ERROR(this->get_logger(), "Goal was rejected by server");
} else {
RCLCPP_INFO(this->get_logger(), "Goal accepted by server, waiting for result");
}
};

send_goal_options.feedback_callback = [this](
GoalHandleFibonacci::SharedPtr,
const std::shared_ptr<const Fibonacci::Feedback> feedback)
{
std::stringstream ss;
ss << "Next number in sequence received: ";
for (auto number : feedback->partial_sequence) {
ss << number << " ";
}
RCLCPP_INFO(this->get_logger(), ss.str().c_str());
};

send_goal_options.result_callback = [this](const GoalHandleFibonacci::WrappedResult & result)
{
switch (result.code) {
case rclcpp_action::ResultCode::SUCCEEDED:
break;
case rclcpp_action::ResultCode::ABORTED:
RCLCPP_ERROR(this->get_logger(), "Goal was aborted");
return;
case rclcpp_action::ResultCode::CANCELED:
RCLCPP_ERROR(this->get_logger(), "Goal was canceled");
return;
default:
RCLCPP_ERROR(this->get_logger(), "Unknown result code");
return;
}
std::stringstream ss;
ss << "Result received: ";
for (auto number : result.result->sequence) {
ss << number << " ";
}
RCLCPP_INFO(this->get_logger(), ss.str().c_str());
rclcpp::shutdown();
};
this->client_ptr_->async_send_goal(goal_msg, send_goal_options);
}

```

This function does the following:

-
Cancels the timer (so it is only called once).

-
Waits for the action server to come up.

-
Instantiates a new `Fibonacci::Goal`.

-
Sets the response, feedback, and result callbacks.

-
Sends the goal to the server.

When the server receives and accepts the goal, it will send a response to the client.
That response is handled by `goal_response_callback`:

```
send_goal_options.goal_response_callback = [this](const GoalHandleFibonacci::SharedPtr & goal_handle)
{
if (!goal_handle) {
RCLCPP_ERROR(this->get_logger(), "Goal was rejected by server");
} else {
RCLCPP_INFO(this->get_logger(), "Goal accepted by server, waiting for result");
}
};

```

Assuming the goal was accepted by the server, it will start processing.
Any feedback to the client will be handled by the `feedback_callback`:

```
send_goal_options.feedback_callback = [this](
GoalHandleFibonacci::SharedPtr,
const std::shared_ptr<const Fibonacci::Feedback> feedback)
{
std::stringstream ss;
ss << "Next number in sequence received: ";
for (auto number : feedback->partial_sequence) {
ss << number << " ";
}
RCLCPP_INFO(this->get_logger(), ss.str().c_str());
};

```

When the server is finished processing, it will return a result to the client.
The result is handled by the `result_callback`:

```
send_goal_options.result_callback = [this](const GoalHandleFibonacci::WrappedResult & result)
{
switch (result.code) {
case rclcpp_action::ResultCode::SUCCEEDED:
break;
case rclcpp_action::ResultCode::ABORTED:
RCLCPP_ERROR(this->get_logger(), "Goal was aborted");
return;
case rclcpp_action::ResultCode::CANCELED:
RCLCPP_ERROR(this->get_logger(), "Goal was canceled");
return;
default:
RCLCPP_ERROR(this->get_logger(), "Unknown result code");
return;
}
std::stringstream ss;
ss << "Result received: ";
for (auto number : result.result->sequence) {
ss << number << " ";
}
RCLCPP_INFO(this->get_logger(), ss.str().c_str());
rclcpp::shutdown();
};

```

We now have a fully functioning action client.
Let’s get it built and running.

3.2 Compiling the action client

In the previous section we put the action client code into place.
To get it to compile and run, we need to do a couple of additional things.

First we need to setup the CMakeLists.txt so that the action client is compiled.
Open up `custom_action_cpp/CMakeLists.txt`, and add the following right after the `find_package` calls:

```
add_library(action_client SHARED
src/fibonacci_action_client.cpp)
target_include_directories(action_client PRIVATE
$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
$<INSTALL_INTERFACE:include>)
target_compile_definitions(action_client
PRIVATE "CUSTOM_ACTION_CPP_BUILDING_DLL")
ament_target_dependencies(action_client
"custom_action_interfaces"
"rclcpp"
"rclcpp_action"
"rclcpp_components")
rclcpp_components_register_node(action_client PLUGIN "custom_action_cpp::FibonacciActionClient" EXECUTABLE fibonacci_action_client)
install(TARGETS
action_client
ARCHIVE DESTINATION lib
LIBRARY DESTINATION lib
RUNTIME DESTINATION bin)

```

And now we can compile the package.
Go to the top-level of the `ros2_ws`, and run:

```
$ colcon build

```

This should compile the entire workspace, including the `fibonacci_action_client` in the `custom_action_cpp` package.

3.3 Running the action client

Now that we have the action client built, we can run it.
First make sure that an action server is running in a separate terminal.
Now source the workspace we just built (`ros2_ws`), and try to run the action client:

```
$ ros2 run custom_action_cpp fibonacci_action_client

```

You should see logged messages for the goal being accepted, feedback being printed, and the final result.

Summary

In this tutorial, you put together a C++ action server and action client line by line, and configured them to exchange goals, feedback, and results.

Related content

-
There are several ways you could write an action server and client in C++; check out the `minimal_action_server` and `minimal_action_client` packages in the ros2/examples repo.

-
For more detailed information about ROS actions, please refer to the design article.

PreviousNext

© Copyright 2026, Open Robotics.

Built with Sphinx using a
theme
provided by Read the Docs.


Other Versions
v: jazzy

ReleasesKilted (latest)JazzyIron (EOL)HumbleGalactic (EOL)Foxy (EOL)Eloquent (EOL)Dashing (EOL)Crystal (EOL)In DevelopmentRolling
