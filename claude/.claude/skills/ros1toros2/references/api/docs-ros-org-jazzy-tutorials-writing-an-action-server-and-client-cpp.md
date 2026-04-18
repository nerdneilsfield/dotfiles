---
source_url: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html
fetched_at: 2026-04-18T10:58:57Z
---

*   [](https://docs.ros.org/en/jazzy/index.html)

*   [Tutorials](https://docs.ros.org/en/jazzy/Tutorials.html)

*   [Intermediate](https://docs.ros.org/en/jazzy/Tutorials/Intermediate.html)

*   Writing an action server and client (C++)
*   [Edit on GitHub](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.rst)


* * *

**You're reading the documentation for an older, but still supported, version of ROS 2. For information on the latest version, please have a look at [Kilted](https://docs.ros.org/en/kilted/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html)
.**

Writing an action server and client (C++)[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#writing-an-action-server-and-client-c "Link to this heading")

=========================================================================================================================================================================================================

**Goal:** Implement an action server and client in C++.

**Tutorial level:** Intermediate

**Time:** 15 minutes

[Background](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#id2)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#background "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Actions are a form of asynchronous communication in ROS. _Action clients_ send goal requests to _action servers_. _Action servers_ send goal feedback and results to _action clients_.

[Prerequisites](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#id3)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#prerequisites "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

You will need the `custom_action_interfaces` package and the `Fibonacci.action` interface defined in the previous tutorial, [Creating an action](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Creating-an-Action.html)
.

[Tasks](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#id4)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#tasks "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### [1 Creating the custom\_action\_cpp package](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#id5)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#creating-the-custom-action-cpp-package "Link to this heading")

As we saw in the [Creating a package](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Creating-Your-First-ROS2-Package.html)
 tutorial, we need to create a new package to hold our C++ and supporting code.

#### 1.1 Creating the custom\_action\_cpp package[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#id1 "Link to this heading")

Go into the action workspace you created in the [previous tutorial](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Creating-an-Action.html)
 (remember to source the workspace), and create a new package for the C++ action server:

LinuxmacOSWindows

$ cd ~/ros2\_ws/src
$ ros2 pkg create \--dependencies custom\_action\_interfaces rclcpp rclcpp\_action rclcpp\_components \--license Apache-2.0 \-- custom\_action\_cpp

Copy to clipboard

$ cd ~/ros2\_ws/src
$ ros2 pkg create \--dependencies custom\_action\_interfaces rclcpp rclcpp\_action rclcpp\_components \--license Apache-2.0 \-- custom\_action\_cpp

Copy to clipboard

$ cd \\ros2\_ws\\src
$ ros2 pkg create \--dependencies custom\_action\_interfaces rclcpp rclcpp\_action rclcpp\_components \--license Apache-2.0 \-- custom\_action\_cpp

Copy to clipboard

#### 1.2 Adding in visibility control[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#adding-in-visibility-control "Link to this heading")

In order to make the package compile and work on Windows, we need to add in some “visibility control”. For more details, see [Windows Symbol Visibility in the Windows Tips and Tricks document](https://docs.ros.org/en/jazzy/The-ROS2-Project/Contributing/Windows-Tips-and-Tricks.html#windows-symbol-visibility)
.

Open up `custom_action_cpp/include/custom_action_cpp/visibility_control.h`, and put the following code in:

#ifndef CUSTOM\_ACTION\_CPP\_\_VISIBILITY\_CONTROL\_H\_
#define CUSTOM\_ACTION\_CPP\_\_VISIBILITY\_CONTROL\_H\_

#ifdef \_\_cplusplus
extern "C"
{
#endif

// This logic was borrowed (then namespaced) from the examples on the gcc wiki:
//     https://gcc.gnu.org/wiki/Visibility

#if defined \_WIN32 || defined \_\_CYGWIN\_\_
  #ifdef \_\_GNUC\_\_
    #define CUSTOM\_ACTION\_CPP\_EXPORT \_\_attribute\_\_ ((dllexport))
    #define CUSTOM\_ACTION\_CPP\_IMPORT \_\_attribute\_\_ ((dllimport))
  #else
    #define CUSTOM\_ACTION\_CPP\_EXPORT \_\_declspec(dllexport)
    #define CUSTOM\_ACTION\_CPP\_IMPORT \_\_declspec(dllimport)
  #endif
  #ifdef CUSTOM\_ACTION\_CPP\_BUILDING\_DLL
    #define CUSTOM\_ACTION\_CPP\_PUBLIC CUSTOM\_ACTION\_CPP\_EXPORT
  #else
    #define CUSTOM\_ACTION\_CPP\_PUBLIC CUSTOM\_ACTION\_CPP\_IMPORT
  #endif
  #define CUSTOM\_ACTION\_CPP\_PUBLIC\_TYPE CUSTOM\_ACTION\_CPP\_PUBLIC
  #define CUSTOM\_ACTION\_CPP\_LOCAL
#else
  #define CUSTOM\_ACTION\_CPP\_EXPORT \_\_attribute\_\_ ((visibility("default")))
  #define CUSTOM\_ACTION\_CPP\_IMPORT
  #if \_\_GNUC\_\_ >= 4
    #define CUSTOM\_ACTION\_CPP\_PUBLIC \_\_attribute\_\_ ((visibility("default")))
    #define CUSTOM\_ACTION\_CPP\_LOCAL  \_\_attribute\_\_ ((visibility("hidden")))
  #else
    #define CUSTOM\_ACTION\_CPP\_PUBLIC
    #define CUSTOM\_ACTION\_CPP\_LOCAL
  #endif
  #define CUSTOM\_ACTION\_CPP\_PUBLIC\_TYPE
#endif

#ifdef \_\_cplusplus
}
#endif

#endif  // CUSTOM\_ACTION\_CPP\_\_VISIBILITY\_CONTROL\_H\_

Copy to clipboard

### [2 Writing an action server](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#id6)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#writing-an-action-server "Link to this heading")

Let’s focus on writing an action server that computes the Fibonacci sequence using the action we created in the [Creating an action](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Creating-an-Action.html)
 tutorial.

#### 2.1 Writing the action server code[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#writing-the-action-server-code "Link to this heading")

Open up `custom_action_cpp/src/fibonacci_action_server.cpp`, and put the following code in:

#include <functional>
#include <memory>
#include <thread>

#include "custom\_action\_interfaces/action/fibonacci.hpp"
#include "rclcpp/rclcpp.hpp"
#include "rclcpp\_action/rclcpp\_action.hpp"
#include "rclcpp\_components/register\_node\_macro.hpp"

#include "custom\_action\_cpp/visibility\_control.hpp"

namespace custom\_action\_cpp
{
class FibonacciActionServer : public rclcpp::Node
{
public:
  using Fibonacci \= custom\_action\_interfaces::action::Fibonacci;
  using GoalHandleFibonacci \= rclcpp\_action::ServerGoalHandle<Fibonacci\>;

  CUSTOM\_ACTION\_CPP\_PUBLIC
  explicit FibonacciActionServer(const rclcpp::NodeOptions & options \= rclcpp::NodeOptions())
  : Node("fibonacci\_action\_server", options)
  {
    using namespace std::placeholders;

    auto handle\_goal \= \[this\](
      const rclcpp\_action::GoalUUID & uuid,
      std::shared\_ptr<const Fibonacci::Goal\> goal)
    {
      RCLCPP\_INFO(this\->get\_logger(), "Received goal request with order %d", goal\->order);
      (void)uuid;
      return rclcpp\_action::GoalResponse::ACCEPT\_AND\_EXECUTE;
    };

    auto handle\_cancel \= \[this\](
      const std::shared\_ptr<GoalHandleFibonacci\> goal\_handle)
    {
      RCLCPP\_INFO(this\->get\_logger(), "Received request to cancel goal");
      (void)goal\_handle;
      return rclcpp\_action::CancelResponse::ACCEPT;
    };

    auto handle\_accepted \= \[this\](
      const std::shared\_ptr<GoalHandleFibonacci\> goal\_handle)
    {
      // this needs to return quickly to avoid blocking the executor,
      // so we declare a lambda function to be called inside a new thread
      auto execute\_in\_thread \= \[this, goal\_handle\](){return this\->execute(goal\_handle);};
      std::thread{execute\_in\_thread}.detach();
    };

    this\->action\_server\_ \= rclcpp\_action::create\_server<Fibonacci\>(
      this,
      "fibonacci",
      handle\_goal,
      handle\_cancel,
      handle\_accepted);
  }

private:
  rclcpp\_action::Server<Fibonacci\>::SharedPtr action\_server\_;

  void execute(const std::shared\_ptr<GoalHandleFibonacci\> goal\_handle) {
    RCLCPP\_INFO(this\->get\_logger(), "Executing goal");
    rclcpp::Rate loop\_rate(1);
    const auto goal \= goal\_handle\->get\_goal();
    auto feedback \= std::make\_shared<Fibonacci::Feedback\>();
    auto & sequence \= feedback\->partial\_sequence;
    sequence.push\_back(0);
    sequence.push\_back(1);
    auto result \= std::make\_shared<Fibonacci::Result\>();

    for (int i \= 1; (i < goal\->order) && rclcpp::ok(); ++i) {
      // Check if there is a cancel request
      if (goal\_handle\->is\_canceling()) {
        result\->sequence \= sequence;
        goal\_handle\->canceled(result);
        RCLCPP\_INFO(this\->get\_logger(), "Goal canceled");
        return;
      }
      // Update sequence
      sequence.push\_back(sequence\[i\] + sequence\[i \- 1\]);
      // Publish feedback
      goal\_handle\->publish\_feedback(feedback);
      RCLCPP\_INFO(this\->get\_logger(), "Publish feedback");

      loop\_rate.sleep();
    }

    // Check if goal is done
    if (rclcpp::ok()) {
      result\->sequence \= sequence;
      goal\_handle\->succeed(result);
      RCLCPP\_INFO(this\->get\_logger(), "Goal succeeded");
    }
  };

};  // class FibonacciActionServer

}  // namespace custom\_action\_cpp

RCLCPP\_COMPONENTS\_REGISTER\_NODE(custom\_action\_cpp::FibonacciActionServer)

Copy to clipboard

The first few lines include all of the headers we need to compile.

Next we create a class that is a derived class of `rclcpp::Node`:

class FibonacciActionServer : public rclcpp::Node

Copy to clipboard

The constructor for the `FibonacciActionServer` class initializes the node name as `fibonacci_action_server`:

  explicit FibonacciActionServer(const rclcpp::NodeOptions & options \= rclcpp::NodeOptions())
  : Node("fibonacci\_action\_server", options)

Copy to clipboard

The constructor also instantiates a new action server:

    this\->action\_server\_ \= rclcpp\_action::create\_server<Fibonacci\>(
      this,
      "fibonacci",
      handle\_goal,
      handle\_cancel,
      handle\_accepted);

Copy to clipboard

An action server requires 6 things:

1.  The templated action type name: `Fibonacci`.

2.  A ROS 2 node to add the action to: `this`.

3.  The action name: `'fibonacci'`.

4.  A callback function for handling goals: `handle_goal`

5.  A callback function for handling cancellation: `handle_cancel`.

6.  A callback function for handling goal accept: `handle_accept`.


The implementation of the various callbacks is done with [lambda expressions](https://en.cppreference.com/w/cpp/language/lambda)
 within the constructor. Note that all of the callbacks need to return quickly, otherwise we risk starving the executor.

We start with the callback for handling new goals:

    auto handle\_goal \= \[this\](
      const rclcpp\_action::GoalUUID & uuid,
      std::shared\_ptr<const Fibonacci::Goal\> goal)
    {
      RCLCPP\_INFO(this\->get\_logger(), "Received goal request with order %d", goal\->order);
      (void)uuid;
      return rclcpp\_action::GoalResponse::ACCEPT\_AND\_EXECUTE;
    };

Copy to clipboard

This implementation just accepts all goals.

Next up is the callback for dealing with cancellation:

    auto handle\_cancel \= \[this\](
      const std::shared\_ptr<GoalHandleFibonacci\> goal\_handle)
    {
      RCLCPP\_INFO(this\->get\_logger(), "Received request to cancel goal");
      (void)goal\_handle;
      return rclcpp\_action::CancelResponse::ACCEPT;
    };

Copy to clipboard

This implementation just tells the client that it accepted the cancellation.

The last of the callbacks accepts a new goal and starts processing it:

    auto handle\_accepted \= \[this\](
      const std::shared\_ptr<GoalHandleFibonacci\> goal\_handle)
    {
      // this needs to return quickly to avoid blocking the executor,
      // so we declare a lambda function to be called inside a new thread
      auto execute\_in\_thread \= \[this, goal\_handle\](){return this\->execute(goal\_handle);};
      std::thread{execute\_in\_thread}.detach();
    };

Copy to clipboard

Since the execution is a long-running operation, we spawn off a thread to do the actual work and return from `handle_accepted` quickly.

All further processing and updates are done in the `execute` method in the new thread:

  void execute(const std::shared\_ptr<GoalHandleFibonacci\> goal\_handle) {
    RCLCPP\_INFO(this\->get\_logger(), "Executing goal");
    rclcpp::Rate loop\_rate(1);
    const auto goal \= goal\_handle\->get\_goal();
    auto feedback \= std::make\_shared<Fibonacci::Feedback\>();
    auto & sequence \= feedback\->partial\_sequence;
    sequence.push\_back(0);
    sequence.push\_back(1);
    auto result \= std::make\_shared<Fibonacci::Result\>();

    for (int i \= 1; (i < goal\->order) && rclcpp::ok(); ++i) {
      // Check if there is a cancel request
      if (goal\_handle\->is\_canceling()) {
        result\->sequence \= sequence;
        goal\_handle\->canceled(result);
        RCLCPP\_INFO(this\->get\_logger(), "Goal canceled");
        return;
      }
      // Update sequence
      sequence.push\_back(sequence\[i\] + sequence\[i \- 1\]);
      // Publish feedback
      goal\_handle\->publish\_feedback(feedback);
      RCLCPP\_INFO(this\->get\_logger(), "Publish feedback");

      loop\_rate.sleep();
    }

    // Check if goal is done
    if (rclcpp::ok()) {
      result\->sequence \= sequence;
      goal\_handle\->succeed(result);
      RCLCPP\_INFO(this\->get\_logger(), "Goal succeeded");
    }
  };

Copy to clipboard

This work thread processes one sequence number of the Fibonacci sequence every second, publishing a feedback update for each step. When it has finished processing, it marks the `goal_handle` as succeeded, and quits.

We now have a fully functioning action server. Let’s get it built and running.

#### 2.2 Compiling the action server[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#compiling-the-action-server "Link to this heading")

In the previous section we put the action server code into place. To get it to compile and run, we need to do a couple of additional things.

First we need to setup the CMakeLists.txt so that the action server is compiled. Open up `custom_action_cpp/CMakeLists.txt`, and add the following right after the `find_package` calls:

add\_library(action\_server SHARED
  src/fibonacci\_action\_server.cpp)
target\_include\_directories(action\_server PRIVATE
  $<BUILD\_INTERFACE:${CMAKE\_CURRENT\_SOURCE\_DIR}/include\>
  $<INSTALL\_INTERFACE:include\>)
target\_compile\_definitions(action\_server
  PRIVATE "CUSTOM\_ACTION\_CPP\_BUILDING\_DLL")
ament\_target\_dependencies(action\_server
  "custom\_action\_interfaces"
  "rclcpp"
  "rclcpp\_action"
  "rclcpp\_components")
rclcpp\_components\_register\_node(action\_server PLUGIN "custom\_action\_cpp::FibonacciActionServer" EXECUTABLE fibonacci\_action\_server)
install(TARGETS
  action\_server
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin)

Copy to clipboard

And now we can compile the package. Go to the top-level of the `ros2_ws`, and run:

$ colcon build

Copy to clipboard

This should compile the entire workspace, including the `fibonacci_action_server` in the `custom_action_cpp` package.

#### 2.3 Running the action server[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#running-the-action-server "Link to this heading")

Now that we have the action server built, we can run it. Source the workspace we just built (`ros2_ws`), and try to run the action server:

$ ros2 run custom\_action\_cpp fibonacci\_action\_server

Copy to clipboard

### [3 Writing an action client](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#id7)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#writing-an-action-client "Link to this heading")

#### 3.1 Writing the action client code[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#writing-the-action-client-code "Link to this heading")

Open up `custom_action_cpp/src/fibonacci_action_client.cpp`, and put the following code in:

#include <functional>
#include <future>
#include <memory>
#include <string>
#include <sstream>

#include "custom\_action\_interfaces/action/fibonacci.hpp"

#include "rclcpp/rclcpp.hpp"
#include "rclcpp\_action/rclcpp\_action.hpp"
#include "rclcpp\_components/register\_node\_macro.hpp"

namespace custom\_action\_cpp
{
class FibonacciActionClient : public rclcpp::Node
{
public:
  using Fibonacci \= custom\_action\_interfaces::action::Fibonacci;
  using GoalHandleFibonacci \= rclcpp\_action::ClientGoalHandle<Fibonacci\>;

  explicit FibonacciActionClient(const rclcpp::NodeOptions & options)
  : Node("fibonacci\_action\_client", options)
  {
    this\->client\_ptr\_ \= rclcpp\_action::create\_client<Fibonacci\>(
      this,
      "fibonacci");

    auto timer\_callback\_lambda \= \[this\](){ return this\->send\_goal(); };
    this\->timer\_ \= this\->create\_wall\_timer(
      std::chrono::milliseconds(500),
      timer\_callback\_lambda);
  }

  void send\_goal()
  {
    using namespace std::placeholders;

    this\->timer\_\->cancel();

    if (!this\->client\_ptr\_\->wait\_for\_action\_server()) {
      RCLCPP\_ERROR(this\->get\_logger(), "Action server not available after waiting");
      rclcpp::shutdown();
    }

    auto goal\_msg \= Fibonacci::Goal();
    goal\_msg.order \= 10;

    RCLCPP\_INFO(this\->get\_logger(), "Sending goal");

    auto send\_goal\_options \= rclcpp\_action::Client<Fibonacci\>::SendGoalOptions();
    send\_goal\_options.goal\_response\_callback \= \[this\](const GoalHandleFibonacci::SharedPtr & goal\_handle)
    {
      if (!goal\_handle) {
        RCLCPP\_ERROR(this\->get\_logger(), "Goal was rejected by server");
      } else {
        RCLCPP\_INFO(this\->get\_logger(), "Goal accepted by server, waiting for result");
      }
    };

    send\_goal\_options.feedback\_callback \= \[this\](
      GoalHandleFibonacci::SharedPtr,
      const std::shared\_ptr<const Fibonacci::Feedback\> feedback)
    {
      std::stringstream ss;
      ss << "Next number in sequence received: ";
      for (auto number : feedback\->partial\_sequence) {
        ss << number << " ";
      }
      RCLCPP\_INFO(this\->get\_logger(), ss.str().c\_str());
    };

    send\_goal\_options.result\_callback \= \[this\](const GoalHandleFibonacci::WrappedResult & result)
    {
      switch (result.code) {
        case rclcpp\_action::ResultCode::SUCCEEDED:
          break;
        case rclcpp\_action::ResultCode::ABORTED:
          RCLCPP\_ERROR(this\->get\_logger(), "Goal was aborted");
          return;
        case rclcpp\_action::ResultCode::CANCELED:
          RCLCPP\_ERROR(this\->get\_logger(), "Goal was canceled");
          return;
        default:
          RCLCPP\_ERROR(this\->get\_logger(), "Unknown result code");
          return;
      }
      std::stringstream ss;
      ss << "Result received: ";
      for (auto number : result.result\->sequence) {
        ss << number << " ";
      }
      RCLCPP\_INFO(this\->get\_logger(), ss.str().c\_str());
      rclcpp::shutdown();
    };
    this\->client\_ptr\_\->async\_send\_goal(goal\_msg, send\_goal\_options);
  }

private:
  rclcpp\_action::Client<Fibonacci\>::SharedPtr client\_ptr\_;
  rclcpp::TimerBase::SharedPtr timer\_;
};  // class FibonacciActionClient

}  // namespace custom\_action\_cpp

RCLCPP\_COMPONENTS\_REGISTER\_NODE(custom\_action\_cpp::FibonacciActionClient)

Copy to clipboard

The first few lines include all of the headers we need to compile.

Next we create a class that is a derived class of `rclcpp::Node`:

class FibonacciActionClient : public rclcpp::Node

Copy to clipboard

The constructor for the `FibonacciActionClient` class initializes the node name as `fibonacci_action_client`:

  explicit FibonacciActionClient(const rclcpp::NodeOptions & options)
  : Node("fibonacci\_action\_client", options)

Copy to clipboard

The constructor also instantiates a new action client:

    this\->client\_ptr\_ \= rclcpp\_action::create\_client<Fibonacci\>(
      this,
      "fibonacci");

Copy to clipboard

An action client requires 3 things:

1.  The templated action type name: `Fibonacci`.

2.  A ROS 2 node to add the action client to: `this`.

3.  The action name: `'fibonacci'`.


We also instantiate a ROS timer that will kick off the one and only call to `send_goal`:

    auto timer\_callback\_lambda \= \[this\](){ return this\->send\_goal(); };
    this\->timer\_ \= this\->create\_wall\_timer(
      std::chrono::milliseconds(500),
      timer\_callback\_lambda);

Copy to clipboard

When the timer expires, it will call `send_goal`:

  void send\_goal()
  {
    using namespace std::placeholders;

    this\->timer\_\->cancel();

    if (!this\->client\_ptr\_\->wait\_for\_action\_server()) {
      RCLCPP\_ERROR(this\->get\_logger(), "Action server not available after waiting");
      rclcpp::shutdown();
    }

    auto goal\_msg \= Fibonacci::Goal();
    goal\_msg.order \= 10;

    RCLCPP\_INFO(this\->get\_logger(), "Sending goal");

    auto send\_goal\_options \= rclcpp\_action::Client<Fibonacci\>::SendGoalOptions();
    send\_goal\_options.goal\_response\_callback \= \[this\](const GoalHandleFibonacci::SharedPtr & goal\_handle)
    {
      if (!goal\_handle) {
        RCLCPP\_ERROR(this\->get\_logger(), "Goal was rejected by server");
      } else {
        RCLCPP\_INFO(this\->get\_logger(), "Goal accepted by server, waiting for result");
      }
    };

    send\_goal\_options.feedback\_callback \= \[this\](
      GoalHandleFibonacci::SharedPtr,
      const std::shared\_ptr<const Fibonacci::Feedback\> feedback)
    {
      std::stringstream ss;
      ss << "Next number in sequence received: ";
      for (auto number : feedback\->partial\_sequence) {
        ss << number << " ";
      }
      RCLCPP\_INFO(this\->get\_logger(), ss.str().c\_str());
    };

    send\_goal\_options.result\_callback \= \[this\](const GoalHandleFibonacci::WrappedResult & result)
    {
      switch (result.code) {
        case rclcpp\_action::ResultCode::SUCCEEDED:
          break;
        case rclcpp\_action::ResultCode::ABORTED:
          RCLCPP\_ERROR(this\->get\_logger(), "Goal was aborted");
          return;
        case rclcpp\_action::ResultCode::CANCELED:
          RCLCPP\_ERROR(this\->get\_logger(), "Goal was canceled");
          return;
        default:
          RCLCPP\_ERROR(this\->get\_logger(), "Unknown result code");
          return;
      }
      std::stringstream ss;
      ss << "Result received: ";
      for (auto number : result.result\->sequence) {
        ss << number << " ";
      }
      RCLCPP\_INFO(this\->get\_logger(), ss.str().c\_str());
      rclcpp::shutdown();
    };
    this\->client\_ptr\_\->async\_send\_goal(goal\_msg, send\_goal\_options);
  }

Copy to clipboard

This function does the following:

1.  Cancels the timer (so it is only called once).

2.  Waits for the action server to come up.

3.  Instantiates a new `Fibonacci::Goal`.

4.  Sets the response, feedback, and result callbacks.

5.  Sends the goal to the server.


When the server receives and accepts the goal, it will send a response to the client. That response is handled by `goal_response_callback`:

    send\_goal\_options.goal\_response\_callback \= \[this\](const GoalHandleFibonacci::SharedPtr & goal\_handle)
    {
      if (!goal\_handle) {
        RCLCPP\_ERROR(this\->get\_logger(), "Goal was rejected by server");
      } else {
        RCLCPP\_INFO(this\->get\_logger(), "Goal accepted by server, waiting for result");
      }
    };

Copy to clipboard

Assuming the goal was accepted by the server, it will start processing. Any feedback to the client will be handled by the `feedback_callback`:

    send\_goal\_options.feedback\_callback \= \[this\](
      GoalHandleFibonacci::SharedPtr,
      const std::shared\_ptr<const Fibonacci::Feedback\> feedback)
    {
      std::stringstream ss;
      ss << "Next number in sequence received: ";
      for (auto number : feedback\->partial\_sequence) {
        ss << number << " ";
      }
      RCLCPP\_INFO(this\->get\_logger(), ss.str().c\_str());
    };

Copy to clipboard

When the server is finished processing, it will return a result to the client. The result is handled by the `result_callback`:

    send\_goal\_options.result\_callback \= \[this\](const GoalHandleFibonacci::WrappedResult & result)
    {
      switch (result.code) {
        case rclcpp\_action::ResultCode::SUCCEEDED:
          break;
        case rclcpp\_action::ResultCode::ABORTED:
          RCLCPP\_ERROR(this\->get\_logger(), "Goal was aborted");
          return;
        case rclcpp\_action::ResultCode::CANCELED:
          RCLCPP\_ERROR(this\->get\_logger(), "Goal was canceled");
          return;
        default:
          RCLCPP\_ERROR(this\->get\_logger(), "Unknown result code");
          return;
      }
      std::stringstream ss;
      ss << "Result received: ";
      for (auto number : result.result\->sequence) {
        ss << number << " ";
      }
      RCLCPP\_INFO(this\->get\_logger(), ss.str().c\_str());
      rclcpp::shutdown();
    };

Copy to clipboard

We now have a fully functioning action client. Let’s get it built and running.

#### 3.2 Compiling the action client[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#compiling-the-action-client "Link to this heading")

In the previous section we put the action client code into place. To get it to compile and run, we need to do a couple of additional things.

First we need to setup the CMakeLists.txt so that the action client is compiled. Open up `custom_action_cpp/CMakeLists.txt`, and add the following right after the `find_package` calls:

add\_library(action\_client SHARED
  src/fibonacci\_action\_client.cpp)
target\_include\_directories(action\_client PRIVATE
  $<BUILD\_INTERFACE:${CMAKE\_CURRENT\_SOURCE\_DIR}/include\>
  $<INSTALL\_INTERFACE:include\>)
target\_compile\_definitions(action\_client
  PRIVATE "CUSTOM\_ACTION\_CPP\_BUILDING\_DLL")
ament\_target\_dependencies(action\_client
  "custom\_action\_interfaces"
  "rclcpp"
  "rclcpp\_action"
  "rclcpp\_components")
rclcpp\_components\_register\_node(action\_client PLUGIN "custom\_action\_cpp::FibonacciActionClient" EXECUTABLE fibonacci\_action\_client)
install(TARGETS
  action\_client
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin)

Copy to clipboard

And now we can compile the package. Go to the top-level of the `ros2_ws`, and run:

$ colcon build

Copy to clipboard

This should compile the entire workspace, including the `fibonacci_action_client` in the `custom_action_cpp` package.

#### 3.3 Running the action client[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#running-the-action-client "Link to this heading")

Now that we have the action client built, we can run it. First make sure that an action server is running in a separate terminal. Now source the workspace we just built (`ros2_ws`), and try to run the action client:

$ ros2 run custom\_action\_cpp fibonacci\_action\_client

Copy to clipboard

You should see logged messages for the goal being accepted, feedback being printed, and the final result.

[Summary](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#id8)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#summary "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

In this tutorial, you put together a C++ action server and action client line by line, and configured them to exchange goals, feedback, and results.

[Related content](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#id9)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html#related-content "Link to this heading")

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*   There are several ways you could write an action server and client in C++; check out the `minimal_action_server` and `minimal_action_client` packages in the [ros2/examples](https://github.com/ros2/examples/tree/jazzy/rclcpp)
     repo.

*   For more detailed information about ROS actions, please refer to the [design article](http://design.ros2.org/articles/actions.html)
    .


Other Versions v: jazzy

Releases

[Kilted (latest)](https://docs.ros.org/en/kilted/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html)

[Jazzy](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html)

[Iron (EOL)](https://docs.ros.org/en/iron/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html)

[Humble](https://docs.ros.org/en/humble/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html)

[Galactic (EOL)](https://docs.ros.org/en/galactic/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html)

[Foxy (EOL)](https://docs.ros.org/en/foxy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html)

[Eloquent (EOL)](https://docs.ros.org/en/eloquent/index.html)

[Dashing (EOL)](https://docs.ros.org/en/dashing/index.html)

[Crystal (EOL)](https://docs.ros.org/en/crystal/index.html)

In Development

[Rolling](https://docs.ros.org/en/rolling/Tutorials/Intermediate/Writing-an-Action-Server-Client/Cpp.html)
