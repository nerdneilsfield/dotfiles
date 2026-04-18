In this quick guide I’ll give you some tips on how you can migrate a current ROS1 project into a ROS2 project.

So, you are currently using + maintaining (+ developing) your ROS1 code base. How can you make a transition to ROS2 without breaking everything for your users, and while being able to continue adding new functionalities?

That’s what I’ll focus on in this post. Note that the solution I propose is only one solution and this post is not an exhaustive list of all available options. I’ll give you an overall overview of what you need to do, without going into technical details.

Here is a shorter video version of this guide:

After watching the video, [subscribe to the Robotics Back-End Youtube channel](https://www.youtube.com/c/RoboticsBackEnd?sub_confirmation=1) so you don’t miss the next tutorials!

* * *

_You want to learn ROS2 efficiently?_

_Check out **[ROS2 For Beginners](https://rbcknd.com/ros2-for-beginners)** and learn ROS2 step by step, in 1 week._

* * *

Challenge to migrate a code base from ROS1 to ROS2
--------------------------------------------------

### Which versions to use?

The minimum ROS2 distribution you should choose now is ROS2 Foxy. And you can run ROS2 Foxy on Windows 10, MacOS, or Ubuntu. If you choose Ubuntu you’ll use version 20.04. And the only Python version you can use is Python3+.

Then, with which ROS1 distribution your app is currently written?

If you’re using ROS Kinetic (Ubuntu 16.04) or ROS Melodic (Ubuntu 18.04), then you’re using Python2 because Python3 was not (completely) supported for those distributions.

So, as you can see, you have multiple challenges, since for the transition, you’ll probably have to switch the OS version, as well as the Python version.

### Switch to ROS Noetic first? (optional)

The latest (and last) ROS1 distribution is ROS Noetic, targeting Ubuntu 20.04 and Python3.

This may be a good (optional) first step if you want to make the transition to ROS2 Foxy from ROS1 Kinetic or ROS1 Melodic. You can first port your ROS1 code to ROS1 Noetic and make sure everything works with Python3. Then, you can switch to ROS2.

So, for example:

1.  ROS1 Melodic + Ubuntu 18.04 + Python2
2.  ROS1 Noetic + Ubuntu 20.04 + Python3
3.  ROS2 Foxy + Ubuntu 20.04 + Python3

This will take more time, but it also allows you to be able to run your ROS1 app until 2025, instead of 2023 for Melodic and 2021 (!) for Kinetic.

But, doing this is completely optional. Instead, from any ROS1 distribution you use, you can directly switch to ROS2 thanks to a useful package named ros1\_bridge.

### ros1\_bridge: the tool you’ll use to migrate from ROS1 to ROS2

The ros1\_bridge package allows you to communicate between ROS1 and ROS2. In this quick guide I won’t technically explain how to use ros1\_bridge, I’ll just give you a global overview of the steps you’ll need to take.

ros1\_bridge will receive messages/services you send from your ROS1/ROS2 nodes, and de-serialize/re-serialize them so they can be delivered to both ROS1 and ROS2 nodes in the network.

So, what does it mean?

*   You can start a ROS1 publisher on one side, get the messages from a ROS2 subscriber on the other side (and vice versa).
*   You can send a request from a ROS1 client to a ROS2 service server (and vice versa).

Great, so it means that you won’t be stuck: you will be able to develop your ROS1 and ROS2 applications independently, while making them communicate between each other.

So, you can:

*   Have a smooth transition for the users of your application.
*   Continue to release new features while you make the transition.

The Autoware foundation is currently using a similar method to make Autoware switch from ROS1 to ROS2. They have [talked about it on ROSCon](https://vimeo.com/378682692). The video is a good complement to this written guide.

So, now, what are the steps you’ll take to migrate?

Migrate your code base from ROS1 to ROS2 step by step with ros1\_bridge
-----------------------------------------------------------------------

### Step 0: learn ROS2

This might sound obvious, but before you make the transition, it’s better to understand what is ROS2, how to write programs in ROS2, what are the differences, new features, etc.

And since you can still rely on ROS1 for a while + have a smooth transition later on (with ros1\_bridge), don’t rush too quickly on migrating right now! You don’t want to write crappy or non scalable code for your whole new ROS2 application.

Check out:

*   [How to learn ROS2.](https://roboticsbackend.com/how-to-learn-ros2/)
*   [What are the differences between ROS1 and ROS2.](https://roboticsbackend.com/ros1-vs-ros2-practical-overview/)
*   [You can also get this complete ROS2 step-by-step course to get started quickly and on the right track](https://skl.sh/305NKUX) (Free for 14 days).

And after you’re confident with ROS2, start the migration.

### Step 1: enable ROS2 communication with your ROS1 code base

Here you’ll start with your ROS1 code base. Enable [ros1\_bridge](https://github.com/ros2/ros1_bridge/blob/master/README.md) so you can work with your ROS1 app from a ROS2 environment.

![](https://roboticsbackend.com/wp-content/uploads/2020/07/migrate_ros1_ros2_with_ros1_bridge.png)

No code written yet, just set up the binding so you can subscribe/publish/call services/etc from the ROS2 side.

At this point:

*   Nothing changes for your ROS1 users.
*   ROS2 users can start using your app and integrate it with their own ROS2 code.

### Step 2 – n: migrate nodes/packages one by one

This is where you’ll re-write your ROS1 functionalities into ROS2 functionalities.

Let’s say you have a camera package containing a driver node and image processing node. You can:

1.  Rewrite the driver node in ROS2.
2.  Once it’s working, use this ROS2 driver instead of the ROS1 one. Thanks to the ros1\_bridge, the new ROS2 driver will be able to communicate with the ROS1 image processing node, and all other ROS1 nodes in the app.
3.  Rewrite the image processing node in ROS2.
4.  Use this new ROS2 node instead of the ROS1 version.
5.  You can now remove (or deprecate first) the camera package from your ROS1 app. All new additions will be made to the ROS2 camera package. And the camera will still be able to communicate with all the other ROS1 functionalities of your application.

![](https://roboticsbackend.com/wp-content/uploads/2020/07/migrate_package_ros1_ros2.png)

Repeat those steps for every other package you have in your ROS1 app.

Rewriting your packages is also a good opportunity to check how you can improve your existing code.

In most cases, ROS must be used as a wrapper around your libraries and functionalities. If you did it well in ROS1 it will be much easier to move the code to ROS2. If you didn’t, well now is a good time to start again on the right foot.

### Step 2 – n (bonus): develop new functionalities while migrating

You may want to continue developing new functionalities for your robot/application. Doing the ROS1 → ROS2 transition does not mean that you have to put everything on pause.

So, let’s say you are developing a new laser scan package, directly in ROS2.

You add your package to your ROS2 stack, so your ROS2 users can directly start to use it.

![](https://roboticsbackend.com/wp-content/uploads/2020/07/migrate_ros1_ros2_add_new_package-1024x448.png)

When releasing your package here, you might choose to:

*   Make it available from the ROS1 side: this might represent some extra work especially if you need to modify other packages’ interfaces to communicate with this new package.
*   Make it available only for ROS2 users. It doesn’t break anything for your ROS1 users, they just won’t get access to this new feature – and this may incentive them to start using your app with ROS2. This option is probably the best one in most cases.

### Last step: remove the ROS1 binding

Now, all your ROS1 packages are ported to ROS2. Your ROS2 app can be launched completely and independently from ROS1. Congrats!

At this point, you may still keep the ROS1 <-> ROS2 binding until ROS1 end of life, so that your ROS1 users still have time to use your app with ROS1, and switch to ROS2. Of course, they may not have access to new functionalities.

![](https://roboticsbackend.com/wp-content/uploads/2020/07/migration_ros1_ros2_finished-1024x454.png)

You can also directly cut the bridge so that from now on, your app will only be supported with ROS2. And you can start making breaking changes without having to also maintain the compatibility with ROS1.

Conclusion on migrating a project from ROS1 to ROS2
---------------------------------------------------

Migrating a code base is never an easy task. But, anyway, with ROS1 and ROS2 you’ll have to do it, so it’s not like you have the choice here. It’s not a bad thing though: the time you spend migrating will mostly be gained back because ROS2 will bring you much more functionalities in the future.

Rewriting your code is also a good opportunity to improve its foundation, something that you probably wouldn’t have done without having to migrate.

By using the proposed solution with ros1\_bridge, you can have a less stressful and more smooth transition, both for you and for the users of your applications.

Using this technique means that:

*   Your users who want to continue using your app with ROS1 can do that until you stop supporting ROS1 (or until 2025 with ROS Noetic end of life). Of course they will also need to switch to the ROS2 version, but you give them more time to update, you don’t just ask them to switch overnight.
*   Your (new) users who directly want to use ROS2 from the start can also do that. They will get access to your existing ROS1 app through ROS2 communication features, and they will also get access to any new feature you release.