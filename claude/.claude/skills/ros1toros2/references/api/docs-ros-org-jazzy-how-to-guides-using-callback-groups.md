---
source_url: https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html
fetched_at: 2026-04-18T10:58:34Z
---

*   [](https://docs.ros.org/en/jazzy/index.html)

*   [How-to Guides](https://docs.ros.org/en/jazzy/How-To-Guides.html)

*   Using Callback Groups
*   [Edit on GitHub](https://github.com/ros2/ros2_documentation/blob/jazzy/source/How-To-Guides/Using-callback-groups.rst)


* * *

**You're reading the documentation for an older, but still supported, version of ROS 2. For information on the latest version, please have a look at [Kilted](https://docs.ros.org/en/kilted/How-To-Guides/Using-callback-groups.html)
.**

Using Callback Groups[](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#using-callback-groups "Link to this heading")

==============================================================================================================================================

When running a node in a Multi-Threaded Executor, ROS 2 offers callback groups as a tool for controlling the execution of different callbacks. This page is meant as a guide on how to use callback groups efficiently. It is assumed that the reader has a basic understanding about the concept of [executors](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Executors.html)
.

[Basics of callback groups](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#id1)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#basics-of-callback-groups "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

When running a node in a Multi-Threaded Executor, ROS 2 offers two different types of callback groups for controlling execution of callbacks:

*   Mutually Exclusive Callback Group

*   Reentrant Callback Group


These callback groups restrict the execution of their callbacks in different ways. In short:

*   Mutually Exclusive Callback Group prevents its callbacks from being executed in parallel - essentially making it as if the callbacks in the group were executed by a SingleThreadedExecutor.

*   Reentrant Callback Group allows the executor to schedule and execute the group’s callbacks in any way it sees fit, without restrictions. This means that, in addition to different callbacks being run parallel to each other, different instances of the same callback may also be executed concurrently.

*   Callbacks belonging to different callback groups (of any type) can always be executed parallel to each other.


It is also important to keep in mind that different ROS 2 entities relay their callback group to all callbacks they spawn. For example, if one assigns a callback group to an action client, all callbacks created by the client will be assigned to that callback group.

Callback groups can be created by a node’s `create_callback_group` function in rclcpp and by calling the constructor of the group in rclpy. The callback group can then be passed as argument/option when creating a subscription, timer, etc. A reference to the callback group should be retained, otherwise the callback associated with the callback group will not be called by the executor.

C++Python

my\_callback\_group \= create\_callback\_group(rclcpp::CallbackGroupType::MutuallyExclusive);

rclcpp::SubscriptionOptions options;
options.callback\_group \= my\_callback\_group;

my\_subscription \= create\_subscription<Int32\>("/topic", rclcpp::SensorDataQoS(),
                                              callback, options);

Copy to clipboard

my\_callback\_group \= MutuallyExclusiveCallbackGroup()
my\_subscription \= self.create\_subscription(Int32, "/topic", self.callback, qos\_profile\=1,
                                            callback\_group\=my\_callback\_group)

Copy to clipboard

If the user does not specify any callback group when creating a subscription, timer, etc., this entity will be assigned to the node’s default callback group. The default callback group is a Mutually Exclusive Callback Group and it can be queried via `NodeBaseInterface::get_default_callback_group()` in rclcpp and via `Node.default_callback_group` in rclpy.

### [About callbacks](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#id2)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#about-callbacks "Link to this heading")

In the context of ROS 2 and executors, a callback means a function whose scheduling and execution is handled by an executor. Examples of callbacks in this context are

*   subscription callbacks (receiving and handling data from a topic),

*   timer callbacks,

*   service callbacks (for executing service requests in a server),

*   different callbacks in action servers and clients,

*   done-callbacks of Futures.


Below are a couple important points about callbacks that should be kept in mind when working with callback groups.

*   Almost everything in ROS 2 is a callback! Every function that is run by an executor is, by definition, a callback. The non-callback functions in a ROS 2 system are found mainly at the edge of the system (user and sensor inputs etc).

*   Sometimes the callbacks are hidden and their presence may not be obvious from the user/developer API. This is the case especially with any kind of “synchronous” call to a service or an action (in rclpy). For example, the synchronous call `Client.call(request)` to a service adds a Future’s done-callback that needs to be executed during the execution of the function call, but this callback is not directly visible to the user.


[Controlling execution](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#id3)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#controlling-execution "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

In order to control execution with callback groups, one can consider the following guidelines.

For the interaction of an individual callback with itself:

*   Register it to a Reentrant Callback Group if it should be executed in parallel to itself. An example case could be an action/service server that needs to be able to process several action calls in parallel to each other.

*   Register it to a Mutually Exclusive Callback Group if it should **never** be executed in parallel to itself. An example case could be a timer callback that runs a control loop that publishes control commands.


For the interaction of different callbacks with each other:

*   Register them to the same Mutually Exclusive Callback Group if they should **never** be executed in parallel. An example case could be that the callbacks are accessing shared critical and non-thread-safe resources.


If they should be executed in parallel, you have two options, depending on whether the individual callbacks should be able to overlap themselves or not:

*   Register them to different Mutually Exclusive Callback Groups (no overlap of the individual callbacks)

*   Register them to a Reentrant Callback Group (overlap of the individual callbacks)


An example case of running different callbacks in parallel is a Node that has a synchronous service client and a timer calling this service. See the detailed example below.

[Avoiding deadlocks](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#id4)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#avoiding-deadlocks "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Setting up callback groups of a node incorrectly can lead to deadlocks (or other unwanted behavior), especially if one desires to use synchronous calls to services or actions. Indeed, even the API documentation of ROS 2 mentions that synchronous calls to actions or services should not be done in callbacks, because it can lead to deadlocks. While using asynchronous calls is indeed safer in this regard, synchronous calls can also be made to work. On the other hand, synchronous calls also have their advantages, such as making the code simpler and easier to understand. Hence, this section provides some guidelines on how to set up a node’s callback groups correctly in order to avoid deadlocks.

First thing to note here is that every node’s default callback group is a Mutually Exclusive Callback Group. If the user does not specify any other callback group when creating a timer, subscription, client etc., any callbacks created then or later by these entities will use the node’s default callback group. Furthermore, if everything in a node uses the same Mutually Exclusive Callback Group, that node essentially acts as if it was handled by a Single-Threaded Executor, even if a multi-threaded one is specified! Thus, whenever one decides to use a Multi-Threaded Executor, some callback group(s) should always be specified in order for the executor choice to make sense.

With the above in mind, here are a couple guidelines to help avoid deadlocks:

*   If you make a synchronous call in any type of a callback, this callback and the client making the call need to belong to

    *   different callback groups (of any type), or

    *   a Reentrant Callback Group.

*   If the above configuration is not possible due to other requirements - such as thread-safety and/or blocking of other callbacks while waiting for the result (or if you want to make absolutely sure that there is never a possibility of a deadlock), use asynchronous calls.


Failing the first point will always cause a deadlock. An example of such a case would be making a synchronous service call in a timer callback (see the next section for an example).

[Examples](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#id5)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#examples "Link to this heading")

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Let us look at some simple examples of different callback group setups. The following demo code considers calling a service synchronously in a timer callback.

### [Demo code](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#id6)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#demo-code "Link to this heading")

We have two nodes - one providing a simple service:

C++Python

#include <memory>
#include "rclcpp/rclcpp.hpp"
#include "std\_srvs/srv/empty.hpp"

using namespace std::placeholders;

namespace cb\_group\_demo
{
class ServiceNode : public rclcpp::Node
{
public:
    ServiceNode() : Node("service\_node")
    {
        auto service\_callback \= \[this\](
            const std::shared\_ptr<rmw\_request\_id\_t\> request\_header,
            const std::shared\_ptr<std\_srvs::srv::Empty::Request\> request,
            const std::shared\_ptr<std\_srvs::srv::Empty::Response\> response)
        {
            (void)request\_header;
            (void)request;
            (void)response;
            RCLCPP\_INFO(this\->get\_logger(), "Received request, responding...");
        };
        service\_ptr\_ \= this\->create\_service<std\_srvs::srv::Empty\>(
                "test\_service",
                service\_callback
        );
    }

private:
    rclcpp::Service<std\_srvs::srv::Empty\>::SharedPtr service\_ptr\_;

};  // class ServiceNode
}   // namespace cb\_group\_demo

int main(int argc, char\* argv\[\])
{
    rclcpp::init(argc, argv);
    auto service\_node \= std::make\_shared<cb\_group\_demo::ServiceNode\>();

    RCLCPP\_INFO(service\_node\->get\_logger(), "Starting server node, shut down with CTRL-C");
    rclcpp::spin(service\_node);
    RCLCPP\_INFO(service\_node\->get\_logger(), "Keyboard interrupt, shutting down.\\n");

    rclcpp::shutdown();
    return 0;
}

Copy to clipboard

import rclpy
from rclpy.node import Node
from std\_srvs.srv import Empty

class ServiceNode(Node):
    def \_\_init\_\_(self):
        super().\_\_init\_\_('service\_node')
        self.srv \= self.create\_service(Empty, 'test\_service', callback\=self.service\_callback)

    def service\_callback(self, request, result):
        self.get\_logger().info('Received request, responding...')
        return result

if \_\_name\_\_ \== '\_\_main\_\_':
    rclpy.init()
    node \= ServiceNode()
    try:
        node.get\_logger().info("Starting server node, shut down with CTRL-C")
        rclpy.spin(node)
    except KeyboardInterrupt:
        node.get\_logger().info('Keyboard interrupt, shutting down.\\n')
    node.destroy\_node()
    rclpy.shutdown()

Copy to clipboard

and another containing a client to the service along with a timer for making service calls:

C++Python

_Note:_ The API of service client in rclcpp does not offer a synchronous call method similar to the one in rclpy, so we wait on the future object to simulate the effect of a synchronous call.

#include <chrono>
#include <memory>
#include "rclcpp/rclcpp.hpp"
#include "std\_srvs/srv/empty.hpp"

using namespace std::chrono\_literals;

namespace cb\_group\_demo
{
class DemoNode : public rclcpp::Node
{
public:
    DemoNode() : Node("client\_node")
    {
        client\_cb\_group\_ \= nullptr;
        timer\_cb\_group\_ \= nullptr;
        client\_ptr\_ \= this\->create\_client<std\_srvs::srv::Empty\>("test\_service", rmw\_qos\_profile\_services\_default,
                                                                client\_cb\_group\_);

        auto timer\_callback \= \[this\](){
            RCLCPP\_INFO(this\->get\_logger(), "Sending request");
            auto request \= std::make\_shared<std\_srvs::srv::Empty::Request\>();
            auto result\_future \= client\_ptr\_\->async\_send\_request(request);
            std::future\_status status \= result\_future.wait\_for(10s);  // timeout to guarantee a graceful finish
            if (status \== std::future\_status::ready) {
                RCLCPP\_INFO(this\->get\_logger(), "Received response");
            }
        };

        timer\_ptr\_ \= this\->create\_wall\_timer(1s, timer\_callback, timer\_cb\_group\_);
    }

private:
    rclcpp::CallbackGroup::SharedPtr client\_cb\_group\_;
    rclcpp::CallbackGroup::SharedPtr timer\_cb\_group\_;
    rclcpp::Client<std\_srvs::srv::Empty\>::SharedPtr client\_ptr\_;
    rclcpp::TimerBase::SharedPtr timer\_ptr\_;

};  // class DemoNode
}   // namespace cb\_group\_demo

int main(int argc, char\* argv\[\])
{
    rclcpp::init(argc, argv);
    auto client\_node \= std::make\_shared<cb\_group\_demo::DemoNode\>();
    rclcpp::executors::MultiThreadedExecutor executor;
    executor.add\_node(client\_node);

    RCLCPP\_INFO(client\_node\->get\_logger(), "Starting client node, shut down with CTRL-C");
    executor.spin();
    RCLCPP\_INFO(client\_node\->get\_logger(), "Keyboard interrupt, shutting down.\\n");

    rclcpp::shutdown();
    return 0;
}

Copy to clipboard

import rclpy
from rclpy.executors import MultiThreadedExecutor
from rclpy.callback\_groups import MutuallyExclusiveCallbackGroup, ReentrantCallbackGroup
from rclpy.node import Node
from std\_srvs.srv import Empty

class CallbackGroupDemo(Node):
    def \_\_init\_\_(self):
        super().\_\_init\_\_('client\_node')

        client\_cb\_group \= None
        timer\_cb\_group \= None
        self.client \= self.create\_client(Empty, 'test\_service', callback\_group\=client\_cb\_group)
        self.call\_timer \= self.create\_timer(1, self.\_timer\_cb, callback\_group\=timer\_cb\_group)

    def \_timer\_cb(self):
        self.get\_logger().info('Sending request')
        \_ \= self.client.call(Empty.Request())
        self.get\_logger().info('Received response')

if \_\_name\_\_ \== '\_\_main\_\_':
    rclpy.init()
    node \= CallbackGroupDemo()
    executor \= MultiThreadedExecutor()
    executor.add\_node(node)

    try:
        node.get\_logger().info('Beginning client, shut down with CTRL-C')
        executor.spin()
    except KeyboardInterrupt:
        node.get\_logger().info('Keyboard interrupt, shutting down.\\n')
    node.destroy\_node()
    rclpy.shutdown()

Copy to clipboard

The client node’s constructor contains options for setting the callback groups of the service client and the timer. With the default setting above (both being `nullptr` / `None`), both the timer and the client will use the node’s default Mutually Exclusive Callback Group.

### [The problem](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#id7)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#the-problem "Link to this heading")

Since we are making service calls with a 1 second timer, the expected outcome is that the service gets called once a second, the client always gets a response and prints `Received response`. If we try running the server and client nodes in terminals, we get the following outputs.

ClientServer

\[INFO\] \[1653034371.758739131\] \[client\_node\]: Starting client node, shut down with CTRL-C
\[INFO\] \[1653034372.755865649\] \[client\_node\]: Sending request
^C\[INFO\] \[1653034398.161674869\] \[client\_node\]: Keyboard interrupt, shutting down.

Copy to clipboard

\[INFO\] \[1653034355.308958238\] \[service\_node\]: Starting server node, shut down with CTRL-C
\[INFO\] \[1653034372.758197320\] \[service\_node\]: Received request, responding...
^C\[INFO\] \[1653034416.021962246\] \[service\_node\]: Keyboard interrupt, shutting down.

Copy to clipboard

So, it turns out that instead of the service being called repeatedly, the response of the first call is never received, after which the client node seemingly gets stuck and does not make further calls. That is, the execution stopped at a deadlock!

The reason for this is that the timer callback and the client are using the same Mutually Exclusive Callback Group (the node’s default). When the service call is made, the client then passes its callback group to the Future object (hidden inside the call-method in the Python version) whose done-callback needs to execute for the result of the service call to be available. But because this done-callback and the timer callback are in the same Mutually Exclusive group and the timer callback is still executing (waiting for the result of the service call), the done-callback never gets to execute. The stuck timer callback also blocks any other executions of itself, so the timer does not fire for a second time.

### [Solution](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#id8)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html#solution "Link to this heading")

We can fix this easily - for example - by assigning the timer and client to different callback groups. Thus, let us change the first two lines of the client node’s constructor to be as follows (everything else shall stay the same):

C++Python

client\_cb\_group\_ \= this\->create\_callback\_group(rclcpp::CallbackGroupType::MutuallyExclusive);
timer\_cb\_group\_ \= this\->create\_callback\_group(rclcpp::CallbackGroupType::MutuallyExclusive);

Copy to clipboard

client\_cb\_group \= MutuallyExclusiveCallbackGroup()
timer\_cb\_group \= MutuallyExclusiveCallbackGroup()

Copy to clipboard

Now we get the expected result, i.e. the timer fires repeatedly and each service call gets the result as it should:

ClientServer

\[INFO\] \[1653067523.431731177\] \[client\_node\]: Starting client node, shut down with CTRL-C
\[INFO\] \[1653067524.431912821\] \[client\_node\]: Sending request
\[INFO\] \[1653067524.433230445\] \[client\_node\]: Received response
\[INFO\] \[1653067525.431869330\] \[client\_node\]: Sending request
\[INFO\] \[1653067525.432912803\] \[client\_node\]: Received response
\[INFO\] \[1653067526.431844726\] \[client\_node\]: Sending request
\[INFO\] \[1653067526.432893954\] \[client\_node\]: Received response
\[INFO\] \[1653067527.431828287\] \[client\_node\]: Sending request
\[INFO\] \[1653067527.432848369\] \[client\_node\]: Received response
^C\[INFO\] \[1653067528.400052749\] \[client\_node\]: Keyboard interrupt, shutting down.

Copy to clipboard

\[INFO\] \[1653067522.052866001\] \[service\_node\]: Starting server node, shut down with CTRL-C
\[INFO\] \[1653067524.432577720\] \[service\_node\]: Received request, responding...
\[INFO\] \[1653067525.432365009\] \[service\_node\]: Received request, responding...
\[INFO\] \[1653067526.432300261\] \[service\_node\]: Received request, responding...
\[INFO\] \[1653067527.432272441\] \[service\_node\]: Received request, responding...
^C\[INFO\] \[1653034416.021962246\] \[service\_node\]: KeyboardInterrupt, shutting down.

Copy to clipboard

One might consider if just avoiding the node’s default callback group is enough. This is not the case: replacing the default group by a different Mutually Exclusive group changes nothing. Thus, the following configuration also leads to the previously discovered deadlock.

C++Python

client\_cb\_group\_ \= this\->create\_callback\_group(rclcpp::CallbackGroupType::MutuallyExclusive);
timer\_cb\_group\_ \= client\_cb\_group\_;

Copy to clipboard

client\_cb\_group \= MutuallyExclusiveCallbackGroup()
timer\_cb\_group \= client\_cb\_group

Copy to clipboard

In fact, the exact condition with which everything works in this case is that the timer and client must not belong to the same Mutually Exclusive group. Hence, all of the following configurations (and some others as well) produce the desired outcome where the timer fires repeatedly and service calls are completed.

C++Python

client\_cb\_group\_ \= this\->create\_callback\_group(rclcpp::CallbackGroupType::Reentrant);
timer\_cb\_group\_ \= client\_cb\_group\_;

Copy to clipboard

or

client\_cb\_group\_ \= this\->create\_callback\_group(rclcpp::CallbackGroupType::MutuallyExclusive);
timer\_cb\_group\_ \= nullptr;

Copy to clipboard

or

client\_cb\_group\_ \= nullptr;
timer\_cb\_group\_ \= this\->create\_callback\_group(rclcpp::CallbackGroupType::MutuallyExclusive);

Copy to clipboard

or

client\_cb\_group\_ \= this\->create\_callback\_group(rclcpp::CallbackGroupType::Reentrant);
timer\_cb\_group\_ \= nullptr;

Copy to clipboard

client\_cb\_group \= ReentrantCallbackGroup()
timer\_cb\_group \= client\_cb\_group

Copy to clipboard

or

client\_cb\_group \= MutuallyExclusiveCallbackGroup()
timer\_cb\_group \= None

Copy to clipboard

or

client\_cb\_group \= None
timer\_cb\_group \= MutuallyExclusiveCallbackGroup()

Copy to clipboard

or

client\_cb\_group \= ReentrantCallbackGroup()
timer\_cb\_group \= None

Copy to clipboard

Other Versions v: jazzy

Releases

[Kilted (latest)](https://docs.ros.org/en/kilted/How-To-Guides/Using-callback-groups.html)

[Jazzy](https://docs.ros.org/en/jazzy/How-To-Guides/Using-callback-groups.html)

[Iron (EOL)](https://docs.ros.org/en/iron/How-To-Guides/Using-callback-groups.html)

[Humble](https://docs.ros.org/en/humble/How-To-Guides/Using-callback-groups.html)

[Galactic (EOL)](https://docs.ros.org/en/galactic/How-To-Guides/Using-callback-groups.html)

[Foxy (EOL)](https://docs.ros.org/en/foxy/How-To-Guides/Using-callback-groups.html)

[Eloquent (EOL)](https://docs.ros.org/en/eloquent/index.html)

[Dashing (EOL)](https://docs.ros.org/en/dashing/index.html)

[Crystal (EOL)](https://docs.ros.org/en/crystal/index.html)

In Development

[Rolling](https://docs.ros.org/en/rolling/How-To-Guides/Using-callback-groups.html)
