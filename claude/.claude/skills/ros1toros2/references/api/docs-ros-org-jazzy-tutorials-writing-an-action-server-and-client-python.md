---
source_url: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html
fetched_at: 2026-04-18T10:59:00Z
---

*   [](https://docs.ros.org/en/jazzy/index.html)

*   [Tutorials](https://docs.ros.org/en/jazzy/Tutorials.html)

*   [Intermediate](https://docs.ros.org/en/jazzy/Tutorials/Intermediate.html)

*   Writing an action server and client (Python)
*   [Edit on GitHub](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.rst)


* * *

**You're reading the documentation for an older, but still supported, version of ROS 2. For information on the latest version, please have a look at [Kilted](https://docs.ros.org/en/kilted/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html)
.**

Writing an action server and client (Python)[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#writing-an-action-server-and-client-python "Link to this heading")

================================================================================================================================================================================================================

**Goal:** Implement an action server and client in Python.

**Tutorial level:** Intermediate

**Time:** 15 minutes

[Background](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#id1)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#background "Link to this heading")

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Actions are a form of asynchronous communication in ROS 2. _Action clients_ send goal requests to _action servers_. _Action servers_ send goal feedback and results to _action clients_.

[Prerequisites](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#id2)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#prerequisites "Link to this heading")

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

You will need the `custom_action_interfaces` package and the `Fibonacci.action` interface defined in the previous tutorial, [Creating an action](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Creating-an-Action.html)
.

[Tasks](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#id3)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#tasks "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### [1 Writing an action server](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#id4)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#writing-an-action-server "Link to this heading")

Let’s focus on writing an action server that computes the Fibonacci sequence using the action we created in the [Creating an action](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Creating-an-Action.html)
 tutorial.

Until now, you’ve created packages and used `ros2 run` to run your nodes. To keep things simple in this tutorial, however, we’ll scope the action server to a single file. If you’d like to see what a complete package for the actions tutorials looks like, check out [action\_tutorials](https://github.com/ros2/demos/tree/jazzy/action_tutorials)
.

Open a new file in your home directory, let’s call it `fibonacci_action_server.py`, and add the following code:

import rclpy
from rclpy.action import ActionServer
from rclpy.node import Node

from custom\_action\_interfaces.action import Fibonacci

class FibonacciActionServer(Node):

    def \_\_init\_\_(self):
        super().\_\_init\_\_('fibonacci\_action\_server')
        self.\_action\_server \= ActionServer(
            self,
            Fibonacci,
            'fibonacci',
            self.execute\_callback)

    def execute\_callback(self, goal\_handle):
        self.get\_logger().info('Executing goal...')
        result \= Fibonacci.Result()
        return result

def main(args\=None):
    rclpy.init(args\=args)

    fibonacci\_action\_server \= FibonacciActionServer()

    rclpy.spin(fibonacci\_action\_server)

if \_\_name\_\_ \== '\_\_main\_\_':
    main()

Copy to clipboard

Line 8 defines a class `FibonacciActionServer` that is a subclass of `Node`. The class is initialized by calling the `Node` constructor, naming our node `fibonacci_action_server`:

        super().\_\_init\_\_('fibonacci\_action\_server')

Copy to clipboard

In the constructor we also instantiate a new action server:

        self.\_action\_server \= ActionServer(
            self,
            Fibonacci,
            'fibonacci',
            self.execute\_callback)

Copy to clipboard

An action server requires four arguments:

1.  A ROS 2 node to add the action server to: `self`.

2.  The type of the action: `Fibonacci` (imported in line 5).

3.  The action name: `'fibonacci'`.

4.  A callback function for executing accepted goals: `self.execute_callback`. This callback **must** return a result message for the action type.


We also define an `execute_callback` method in our class:

    def execute\_callback(self, goal\_handle):
        self.get\_logger().info('Executing goal...')
        result \= Fibonacci.Result()
        return result

Copy to clipboard

This is the method that will be called to execute a goal once it is accepted.

Let’s try running our action server:

LinuxmacOSWindows

$ python3 fibonacci\_action\_server.py

Copy to clipboard

$ python3 fibonacci\_action\_server.py

Copy to clipboard

$ python fibonacci\_action\_server.py

Copy to clipboard

In another terminal, we can use the command line interface to send a goal:

$ ros2 action send\_goal fibonacci custom\_action\_interfaces/action/Fibonacci "{order: 5}"

Copy to clipboard

In the terminal that is running the action server, you should see a logged message “Executing goal…” followed by a warning that the goal state was not set. By default, if the goal handle state is not set in the execute callback it assumes the _aborted_ state.

We can call `succeed()` on the goal handle to indicate that the goal was successful:

    def execute\_callback(self, goal\_handle):
        self.get\_logger().info('Executing goal...')
        goal\_handle.succeed()        result \= Fibonacci.Result()
        return result

Copy to clipboard

Now if you restart the action server and send another goal, you should see the goal finished with the status `SUCCEEDED`.

Now let’s make our goal execution actually compute and return the requested Fibonacci sequence:

    def execute\_callback(self, goal\_handle):
        self.get\_logger().info('Executing goal...')

        sequence \= \[0, 1\]
        for i in range(1, goal\_handle.request.order):            sequence.append(sequence\[i\] + sequence\[i\-1\])
        goal\_handle.succeed()

        result \= Fibonacci.Result()
        result.sequence \= sequence        return result

Copy to clipboard

After computing the sequence, we assign it to the result message field before returning.

Again, restart the action server and send another goal. You should see the goal finish with the proper result sequence.

#### 1.2 Publishing feedback[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#publishing-feedback "Link to this heading")

One of the nice things about actions is the ability to provide feedback to an action client during goal execution. We can make our action server publish feedback for action clients by calling the goal handle’s `publish_feedback()` method.

We’ll replace the `sequence` variable, and use a feedback message to store the sequence instead. After every update of the feedback message in the for-loop, we publish the feedback message and sleep for dramatic effect:

import time
import rclpy
from rclpy.action import ActionServer
from rclpy.node import Node

from custom\_action\_interfaces.action import Fibonacci

class FibonacciActionServer(Node):

    def \_\_init\_\_(self):
        super().\_\_init\_\_('fibonacci\_action\_server')
        self.\_action\_server \= ActionServer(
            self,
            Fibonacci,
            'fibonacci',
            self.execute\_callback)

    def execute\_callback(self, goal\_handle):
        self.get\_logger().info('Executing goal...')

        feedback\_msg \= Fibonacci.Feedback()        feedback\_msg.partial\_sequence \= \[0, 1\]
        for i in range(1, goal\_handle.request.order):
            feedback\_msg.partial\_sequence.append(                feedback\_msg.partial\_sequence\[i\] + feedback\_msg.partial\_sequence\[i\-1\])            self.get\_logger().info('Feedback: {0}'.format(feedback\_msg.partial\_sequence))            goal\_handle.publish\_feedback(feedback\_msg)            time.sleep(1)
        goal\_handle.succeed()

        result \= Fibonacci.Result()
        result.sequence \= feedback\_msg.partial\_sequence        return result

def main(args\=None):
    rclpy.init(args\=args)

    fibonacci\_action\_server \= FibonacciActionServer()

    rclpy.spin(fibonacci\_action\_server)

if \_\_name\_\_ \== '\_\_main\_\_':
    main()

Copy to clipboard

After restarting the action server, we can confirm that feedback is now published by using the command line tool with the `--feedback` option:

$ ros2 action send\_goal \--feedback fibonacci custom\_action\_interfaces/action/Fibonacci "{order: 5}"

Copy to clipboard

### [2 Writing an action client](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#id5)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#writing-an-action-client "Link to this heading")

We’ll also scope the action client to a single file. Open a new file, let’s call it `fibonacci_action_client.py`, and add the following boilerplate code:

import rclpy
from rclpy.action import ActionClient
from rclpy.node import Node

from custom\_action\_interfaces.action import Fibonacci

class FibonacciActionClient(Node):

    def \_\_init\_\_(self):
        super().\_\_init\_\_('fibonacci\_action\_client')
        self.\_action\_client \= ActionClient(self, Fibonacci, 'fibonacci')

    def send\_goal(self, order):
        goal\_msg \= Fibonacci.Goal()
        goal\_msg.order \= order

        self.\_action\_client.wait\_for\_server()

        return self.\_action\_client.send\_goal\_async(goal\_msg)

def main(args\=None):
    rclpy.init(args\=args)

    action\_client \= FibonacciActionClient()

    future \= action\_client.send\_goal(10)

    rclpy.spin\_until\_future\_complete(action\_client, future)

if \_\_name\_\_ \== '\_\_main\_\_':
    main()

Copy to clipboard

We’ve defined a class `FibonacciActionClient` that is a subclass of `Node`. The class is initialized by calling the `Node` constructor, naming our node `fibonacci_action_client`:

        super().\_\_init\_\_('fibonacci\_action\_client')

Copy to clipboard

Also in the class constructor, we create an action client using the custom action definition from the previous tutorial on [Creating an action](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Creating-an-Action.html)
:

        self.\_action\_client \= ActionClient(self, Fibonacci, 'fibonacci')

Copy to clipboard

We create an `ActionClient` by passing it three arguments:

1.  A ROS 2 node to add the action client to: `self`

2.  The type of the action: `Fibonacci`

3.  The action name: `'fibonacci'`


Our action client will be able to communicate with action servers of the same action name and type.

We also define a method `send_goal` in the `FibonacciActionClient` class:

    def send\_goal(self, order):
        goal\_msg \= Fibonacci.Goal()
        goal\_msg.order \= order

        self.\_action\_client.wait\_for\_server()

        return self.\_action\_client.send\_goal\_async(goal\_msg)

Copy to clipboard

This method waits for the action server to be available, then sends a goal to the server. It returns a future that we can later wait on.

After the class definition, we define a function `main()` that initializes ROS 2 and creates an instance of our `FibonacciActionClient` node. It then sends a goal and waits until that goal has been completed.

Finally, we call `main()` in the entry point of our Python program.

Let’s test our action client by first running the action server built earlier:

LinuxmacOSWindows

$ python3 fibonacci\_action\_server.py

Copy to clipboard

$ python3 fibonacci\_action\_server.py

Copy to clipboard

$ python fibonacci\_action\_server.py

Copy to clipboard

In another terminal, run the action client. You should see messages printed by the action server as it successfully executes the goal:

LinuxmacOSWindows

$ python3 fibonacci\_action\_client.py
\[INFO\] \[fibonacci\_action\_server\]: Executing goal...
\[INFO\] \[fibonacci\_action\_server\]: Feedback: array('i', \[0, 1, 1\])
\[INFO\] \[fibonacci\_action\_server\]: Feedback: array('i', \[0, 1, 1, 2\])
\[INFO\] \[fibonacci\_action\_server\]: Feedback: array('i', \[0, 1, 1, 2, 3\])
\[INFO\] \[fibonacci\_action\_server\]: Feedback: array('i', \[0, 1, 1, 2, 3, 5\])
~ etc.

Copy to clipboard

$ python3 fibonacci\_action\_client.py
\[INFO\] \[fibonacci\_action\_server\]: Executing goal...
\[INFO\] \[fibonacci\_action\_server\]: Feedback: array('i', \[0, 1, 1\])
\[INFO\] \[fibonacci\_action\_server\]: Feedback: array('i', \[0, 1, 1, 2\])
\[INFO\] \[fibonacci\_action\_server\]: Feedback: array('i', \[0, 1, 1, 2, 3\])
\[INFO\] \[fibonacci\_action\_server\]: Feedback: array('i', \[0, 1, 1, 2, 3, 5\])
~ etc.

Copy to clipboard

$ python fibonacci\_action\_client.py
\[INFO\] \[fibonacci\_action\_server\]: Executing goal...
\[INFO\] \[fibonacci\_action\_server\]: Feedback: array('i', \[0, 1, 1\])
\[INFO\] \[fibonacci\_action\_server\]: Feedback: array('i', \[0, 1, 1, 2\])
\[INFO\] \[fibonacci\_action\_server\]: Feedback: array('i', \[0, 1, 1, 2, 3\])
\[INFO\] \[fibonacci\_action\_server\]: Feedback: array('i', \[0, 1, 1, 2, 3, 5\])
\# etc.

Copy to clipboard

The action client should start up, and then quickly finish. At this point, we have a functioning action client, but we don’t see any results or get any feedback.

#### 2.1 Getting a result[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#getting-a-result "Link to this heading")

So we can send a goal, but how do we know when it is completed? We can get the result information with a couple steps. First, we need to get a goal handle for the goal we sent. Then, we can use the goal handle to request the result.

Here’s the complete code for this example:

import rclpy
from rclpy.action import ActionClient
from rclpy.node import Node

from custom\_action\_interfaces.action import Fibonacci

class FibonacciActionClient(Node):

    def \_\_init\_\_(self):
        super().\_\_init\_\_('fibonacci\_action\_client')
        self.\_action\_client \= ActionClient(self, Fibonacci, 'fibonacci')

    def send\_goal(self, order):
        goal\_msg \= Fibonacci.Goal()
        goal\_msg.order \= order

        self.\_action\_client.wait\_for\_server()

        self.\_send\_goal\_future \= self.\_action\_client.send\_goal\_async(goal\_msg)

        self.\_send\_goal\_future.add\_done\_callback(self.goal\_response\_callback)

    def goal\_response\_callback(self, future):
        goal\_handle \= future.result()
        if not goal\_handle.accepted:
            self.get\_logger().info('Goal rejected :(')
            return

        self.get\_logger().info('Goal accepted :)')

        self.\_get\_result\_future \= goal\_handle.get\_result\_async()
        self.\_get\_result\_future.add\_done\_callback(self.get\_result\_callback)

    def get\_result\_callback(self, future):
        result \= future.result().result
        self.get\_logger().info('Result: {0}'.format(result.sequence))
        rclpy.shutdown()

def main(args\=None):
    rclpy.init(args\=args)

    action\_client \= FibonacciActionClient()

    action\_client.send\_goal(10)

    rclpy.spin(action\_client)

if \_\_name\_\_ \== '\_\_main\_\_':
    main()

Copy to clipboard

The `ActionClient.send_goal_async()` method returns a future to a goal handle. First we register a callback for when the future is complete:

        self.\_send\_goal\_future.add\_done\_callback(self.goal\_response\_callback)

Copy to clipboard

Note that the future is completed when an action server accepts or rejects the goal request. Let’s look at the `goal_response_callback` in more detail. We can check to see if the goal was rejected and return early since we know there will be no result:

    def goal\_response\_callback(self, future):
        goal\_handle \= future.result()
        if not goal\_handle.accepted:
            self.get\_logger().info('Goal rejected :(')
            return

        self.get\_logger().info('Goal accepted :)')

Copy to clipboard

Now that we’ve got a goal handle, we can use it to request the result with the method `get_result_async()`. Similar to sending the goal, we will get a future that will complete when the result is ready. Let’s register a callback just like we did for the goal response:

        self.\_get\_result\_future \= goal\_handle.get\_result\_async()
        self.\_get\_result\_future.add\_done\_callback(self.get\_result\_callback)

Copy to clipboard

In the callback, we log the result sequence and shutdown ROS 2 for a clean exit:

    def get\_result\_callback(self, future):
        result \= future.result().result
        self.get\_logger().info('Result: {0}'.format(result.sequence))
        rclpy.shutdown()

Copy to clipboard

With an action server running in a separate terminal, go ahead and try running our Fibonacci action client!

LinuxmacOSWindows

$ python3 fibonacci\_action\_client.py

Copy to clipboard

$ python3 fibonacci\_action\_client.py

Copy to clipboard

$ python fibonacci\_action\_client.py

Copy to clipboard

You should see logged messages for the goal being accepted and the final result.

#### 2.2 Getting feedback[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#getting-feedback "Link to this heading")

Our action client can send goals. Nice! But it would be great if we could get some feedback about the goals we send from the action server.

Here’s the complete code for this example:

import rclpy
from rclpy.action import ActionClient
from rclpy.node import Node

from custom\_action\_interfaces.action import Fibonacci

class FibonacciActionClient(Node):

    def \_\_init\_\_(self):
        super().\_\_init\_\_('fibonacci\_action\_client')
        self.\_action\_client \= ActionClient(self, Fibonacci, 'fibonacci')

    def send\_goal(self, order):
        goal\_msg \= Fibonacci.Goal()
        goal\_msg.order \= order

        self.\_action\_client.wait\_for\_server()

        self.\_send\_goal\_future \= self.\_action\_client.send\_goal\_async(goal\_msg, feedback\_callback\=self.feedback\_callback)

        self.\_send\_goal\_future.add\_done\_callback(self.goal\_response\_callback)

    def goal\_response\_callback(self, future):
        goal\_handle \= future.result()
        if not goal\_handle.accepted:
            self.get\_logger().info('Goal rejected :(')
            return

        self.get\_logger().info('Goal accepted :)')

        self.\_get\_result\_future \= goal\_handle.get\_result\_async()
        self.\_get\_result\_future.add\_done\_callback(self.get\_result\_callback)

    def get\_result\_callback(self, future):
        result \= future.result().result
        self.get\_logger().info('Result: {0}'.format(result.sequence))
        rclpy.shutdown()

    def feedback\_callback(self, feedback\_msg):
        feedback \= feedback\_msg.feedback
        self.get\_logger().info('Received feedback: {0}'.format(feedback.partial\_sequence))

def main(args\=None):
    rclpy.init(args\=args)

    action\_client \= FibonacciActionClient()

    action\_client.send\_goal(10)

    rclpy.spin(action\_client)

if \_\_name\_\_ \== '\_\_main\_\_':
    main()

Copy to clipboard

Here’s the callback function for feedback messages:

    def feedback\_callback(self, feedback\_msg):
        feedback \= feedback\_msg.feedback
        self.get\_logger().info('Received feedback: {0}'.format(feedback.partial\_sequence))

Copy to clipboard

In the callback we get the feedback portion of the message and print the `partial_sequence` field to the screen.

We need to register the callback with the action client. This is achieved by additionally passing the callback to the action client when we send a goal:

        self.\_send\_goal\_future \= self.\_action\_client.send\_goal\_async(goal\_msg, feedback\_callback\=self.feedback\_callback)

Copy to clipboard

We’re all set. If we run our action client, you should see feedback being printed to the screen.

[Summary](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#id6)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#summary "Link to this heading")

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

In this tutorial, you put together a Python action server and action client line by line, and configured them to exchange goals, feedback, and results.

[Related content](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#id7)
[](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html#related-content "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*   There are several ways you could write an action server and client in Python; check out the `minimal_action_server` and `minimal_action_client` packages in the [ros2/examples](https://github.com/ros2/examples/tree/jazzy/rclpy/actions)
     repo.

*   For more detailed information about ROS actions, please refer to the [design article](http://design.ros2.org/articles/actions.html)
    .


Other Versions v: jazzy

Releases

[Kilted (latest)](https://docs.ros.org/en/kilted/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html)

[Jazzy](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html)

[Iron (EOL)](https://docs.ros.org/en/iron/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html)

[Humble](https://docs.ros.org/en/humble/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html)

[Galactic (EOL)](https://docs.ros.org/en/galactic/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html)

[Foxy (EOL)](https://docs.ros.org/en/foxy/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html)

[Eloquent (EOL)](https://docs.ros.org/en/eloquent/index.html)

[Dashing (EOL)](https://docs.ros.org/en/dashing/index.html)

[Crystal (EOL)](https://docs.ros.org/en/crystal/index.html)

In Development

[Rolling](https://docs.ros.org/en/rolling/Tutorials/Intermediate/Writing-an-Action-Server-Client/Py.html)
