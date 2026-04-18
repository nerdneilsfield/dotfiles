# ROS1 Residual Grep Patterns

Canonical `rg` patterns for spotting ROS1 leftovers during Step 5 verification and before M2's `verify_ros2.py` exists.

## Usage

Filter out comment lines and blank lines before handing the patterns to `rg -f`, otherwise comment text is treated as a real regex.

```bash
grep -v '^#' references/grep-patterns.md | grep -v '^$' | rg -n -f - <workspace>
```

## C++ client library

ros::NodeHandle
ros::init
ros::spin\(
ros::spinOnce\(
ros::AsyncSpinner
ros::Rate
ROS_INFO
ROS_WARN
ROS_ERROR
#include <ros/ros\.h>

## Python client library

import rospy
rospy\.init_node
rospy\.Publisher
rospy\.Subscriber
rospy\.Service
rospy\.ServiceProxy
rospy\.spin
rospy\.get_param
rospy\.set_param
rospy\.sleep

## Build system and packaging

find_package\(catkin
catkin_package\(
message_generation
message_runtime
add_message_files\(
generate_messages\(
catkin_install_python\(
<buildtool_depend>catkin</buildtool_depend>

## Launch and parameters

<launch>
<rosparam
\$\(arg 
\$\(find 
\$\(eval 
dynamic_reconfigure

## TF, actions, nodelets

tf::TransformBroadcaster
tf::TransformListener
actionlib::SimpleActionServer
actionlib::SimpleActionClient
import actionlib
nodelet::Nodelet
PLUGINLIB_EXPORT_CLASS
