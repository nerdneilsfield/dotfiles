---
source_url: https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html
fetched_at: 2026-04-18T10:58:30Z
---

*   [](https://docs.ros.org/en/jazzy/index.html)

*   [How-to Guides](https://docs.ros.org/en/jazzy/How-To-Guides.html)

*   [Migrating from ROS 1 to ROS 2](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1.html)

*   Migrating Launch Files
*   [Edit on GitHub](https://github.com/ros2/ros2_documentation/blob/jazzy/source/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.rst)


* * *

**You're reading the documentation for an older, but still supported, version of ROS 2. For information on the latest version, please have a look at [Kilted](https://docs.ros.org/en/kilted/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html)
.**

Migrating Launch Files[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#migrating-launch-files "Link to this heading")

=====================================================================================================================================================================

While launch files in ROS 1 are always specified using [XML](https://wiki.ros.org/roslaunch/XML)
 files, ROS 2 supports both XML and YAML files. ROS 2 also supports Python launch scripts to enable more flexibility (see [launch package](https://github.com/ros2/launch/tree/jazzy/launch)
). However, for typical use cases, XML and YAML should be preferred over Python.

This guide describes how to write ROS 2 XML launch files for an easy migration from ROS 1.

[Background](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id9)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#background "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

A description of the ROS 2 launch system can be found in [Launch System tutorial](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Launch-system.html)
.

[Migrating tags](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id10)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#migrating-tags "Link to this heading")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### [launch](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id11)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#launch "Link to this heading")

*   [Available in ROS 1](https://wiki.ros.org/roslaunch/XML/launch)
    .

*   `launch` is the root element of any ROS 2 launch XML file.


### [node](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id12)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#node "Link to this heading")

*   [Available in ROS 1](https://wiki.ros.org/roslaunch/XML/node)
    .

*   Launches a new node.

*   Differences from ROS 1:

    > *   `type` attribute is now `exec`.
    >
    > *   `ns` attribute is now `namespace`.
    >
    > *   `required="true"` is now `on_exit="shutdown"`.
    >
    > *   The following attributes aren’t available: `machine`, `respawn_delay`, `clear_params`.
    >


#### Example[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#example "Link to this heading")

<launch>
   <node pkg="demo\_nodes\_cpp" exec="talker"/>
   <node pkg="demo\_nodes\_cpp" exec="listener"/>
</launch>

Copy to clipboard

### [param](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id13)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#param "Link to this heading")

*   [Available in ROS 1](https://wiki.ros.org/roslaunch/XML/param)
    .

*   Used for passing a parameter to a node.

*   There’s no global parameter concept in ROS 2. For that reason, it can only be used nested in a `node` tag. Some attributes aren’t supported in ROS 2: `type`, `textfile`, `binfile`, `executable`.

*   The `command` attribute is now `value="$(command '...' )"`.


#### Example[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id1 "Link to this heading")

<launch>
   <node pkg="demo\_nodes\_cpp" exec="parameter\_event"\>
      <param name="foo" value="5"/>
   </node>
</launch>

Copy to clipboard

#### Type inference rules[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#type-inference-rules "Link to this heading")

Here are some examples of how to write parameters:

<node pkg="my\_package" exec="my\_executable" name="my\_node"\>
   <!--A string parameter with value "1"-->
   <param name="a\_string" value="'1'"/>
   <!--A integer parameter with value 1-->
   <param name="an\_int" value="1"/>
   <!--A float parameter with value 1.0-->
   <param name="a\_float" value="1.0"/>
   <!--A string parameter with value "asd"-->
   <param name="another\_string" value="asd"/>
   <!--Another string parameter, with value "asd"-->
   <param name="string\_with\_same\_value\_as\_above" value="'asd'"/>
   <!--Another string parameter, with value "'asd'"-->
   <param name="quoted\_string" value="\\'asd\\'"/>
   <!--A list of strings, with value \["asd", "bsd", "csd"\]-->
   <param name="list\_of\_strings" value="asd, bsd, csd" value-sep=", "/>
   <!--A list of ints, with value \[1, 2, 3\]-->
   <param name="list\_of\_ints" value="1,2,3" value-sep=","/>
   <!--Another list of strings, with value \["1", "2", "3"\]-->
   <param name="another\_list\_of\_strings" value="'1';'2';'3'" value-sep=";"/>
   <!--A list of strings using an strange separator, with value \["1", "2", "3"\]-->
   <param name="strange\_separator" value="'1'//'2'//'3'" value-sep="//"/>
</node>

Copy to clipboard

#### Parameter grouping[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#parameter-grouping "Link to this heading")

In ROS 2, `param` tags are allowed to be nested. For example:

<node pkg="my\_package" exec="my\_executable" name="my\_node" namespace="/an\_absoulute\_ns"\>
   <param name="group1"\>
      <param name="group2"\>
         <param name="my\_param" value="1"/>
      </param>
      <param name="another\_param" value="2"/>
   </param>
</node>

Copy to clipboard

That will create two parameters:

*   A `group1.group2.my_param` of value `1`, hosted by node `/an_absolute_ns/my_node`.

*   A `group1.another_param` of value `2` hosted by node `/an_absolute_ns/my_node`.


It’s also possible to use full parameter names:

<node pkg="my\_package" exec="my\_executable" name="my\_node" namespace="/an\_absoulute\_ns"\>
   <param name="group1.group2.my\_param" value="1"/>
   <param name="group1.another\_param" value="2"/>
</node>

Copy to clipboard

### [rosparam](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id14)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#rosparam "Link to this heading")

*   [Available in ROS 1](https://wiki.ros.org/roslaunch/XML/rosparam)
    .

*   Loads parameters from a yaml file.

*   It has been replaced with a `from` attribute in `param` tags.


#### Example[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id2 "Link to this heading")

<node pkg="my\_package" exec="my\_executable" name="my\_node" namespace="/an\_absoulute\_ns"\>
   <param from="/path/to/file"/>
</node>

Copy to clipboard

### [remap](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id15)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#remap "Link to this heading")

*   [Available in ROS 1](https://wiki.ros.org/roslaunch/XML/remap)
    .

*   Used to pass remapping rules to a node.

*   It can only be used within `node` tags.


#### Example[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id3 "Link to this heading")

<launch>
   <node pkg="demo\_nodes\_cpp" exec="talker"\>
      <remap from="chatter" to="my\_topic"/>
   </node>
   <node pkg="demo\_nodes\_cpp" exec="listener"\>
      <remap from="chatter" to="my\_topic"/>
   </node>
</launch>

Copy to clipboard

### [include](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id16)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#include "Link to this heading")

*   [Available in ROS 1](https://wiki.ros.org/roslaunch/XML/include)
    .

*   Allows including another launch file.

*   Differences from ROS 1:

    > *   Available in ROS 1, included content was scoped. In ROS 2, it’s not. This means the values of `arg` tags are propagated into included launch files as if `pass_all_args="true"` were used in ROS 1. However, this propagation only works for args that have a default value (in the inner/included launch file). Required args have to be passed explicitly. Nest includes in `group` tags to scope them (see also `group` attributes `scoped` and `forwarding` ).
    >
    > *   `ns` attribute is not supported. See example of `push_ros_namespace` tag for a workaround.
    >
    > *   `arg` tag nested in an `include` tag is now `let`. However, `arg` is still supported for now.
    >
    > *   `let` tags nested in an `include` tag don’t support conditionals (`if`, `unless`) or the `description` attribute.
    >
    > *   There is no support for nested `env` tags. `set_env` and `unset_env` can be used instead.
    >
    > *   Both `clear_params` and `pass_all_args` attributes aren’t supported. ROS 2 launch behaves as if `pass_all_args` were set to true (see above).
    >


#### Examples[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#examples "Link to this heading")

See [Replacing an include tag](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#replacing-an-include-tag)
.

### [arg](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id17)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#arg "Link to this heading")

*   [Available in ROS 1](https://wiki.ros.org/roslaunch/XML/arg)
    .

*   `arg` is used for declaring a launch argument, or to pass an argument when using `include` tags.

*   Differences from ROS 1:

    > *   `value` attribute is not allowed. Use `let` tag for this.
    >
    > *   `doc` is now `description`.
    >
    > *   When nested within an `include` tag:
    >
    >     > *   Use `let` instead of `arg`.
    >     >
    >     > *   `if`, `unless`, and `description` attributes aren’t allowed.
    >     >
    >


#### Example[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id4 "Link to this heading")

<launch>
   <arg name="topic\_name" default="chatter"/>
   <node pkg="demo\_nodes\_cpp" exec="talker"\>
      <remap from="chatter" to="$(var topic\_name)"/>
   </node>
   <node pkg="demo\_nodes\_cpp" exec="listener"\>
      <remap from="chatter" to="$(var topic\_name)"/>
   </node>
</launch>

Copy to clipboard

#### Passing an argument to the launch file[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#passing-an-argument-to-the-launch-file "Link to this heading")

In the XML launch file above, the `topic_name` defaults to the name `chatter`, but can be configured on the command-line. Assuming the above launch configuration is in a file named `mylaunch.xml`, a different topic name can be used by launching it with the following:

$ ros2 launch mylaunch.xml topic\_name:\=custom\_topic\_name

Copy to clipboard

There is some additional information about passing command-line arguments in [Using Substitutions](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Launch/Using-Substitutions.html)
.

### [env](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id18)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#env "Link to this heading")

*   [Available in ROS 1](https://wiki.ros.org/roslaunch/XML/env)
    .

*   Sets an environment variable.

*   It has been replaced with `env`, `set_env` and `unset_env`:

    > *   `env` can only be used nested in a `node` or `executable` tag. `if` and `unless` tags aren’t supported.
    >
    > *   `set_env` can be nested within the root tag `launch` or in `group` tags. It accepts the same attributes as `env`, and also `if` and `unless` tags.
    >
    > *   `unset_env` unsets an environment variable. It accepts a `name` attribute and conditionals.
    >


#### Example[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id5 "Link to this heading")

<launch>
   <set\_env name="MY\_ENV\_VAR" value="MY\_VALUE" if="CONDITION\_A"/>
   <set\_env name="ANOTHER\_ENV\_VAR" value="ANOTHER\_VALUE" unless="CONDITION\_B"/>
   <set\_env name="SOME\_ENV\_VAR" value="SOME\_VALUE"/>
   <node pkg="MY\_PACKAGE" exec="MY\_EXECUTABLE" name="MY\_NODE"\>
      <env name="NODE\_ENV\_VAR" value="SOME\_VALUE"/>
   </node>
   <unset\_env name="MY\_ENV\_VAR" if="CONDITION\_A"/>
   <node pkg="ANOTHER\_PACKAGE" exec="ANOTHER\_EXECUTABLE" name="ANOTHER\_NODE"/>
   <unset\_env name="ANOTHER\_ENV\_VAR" unless="CONDITION\_B"/>
   <unset\_env name="SOME\_ENV\_VAR"/>
</launch>

Copy to clipboard

### [group](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id19)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#group "Link to this heading")

*   [Available in ROS 1](https://wiki.ros.org/roslaunch/XML/group)
    .

*   Allows limiting the scope of launch configurations. Usually used together with `let`, `include` and `push_ros_namespace` tags.

*   Differences from ROS 1:

    > *   There is no `ns` attribute. See the new `push_ros_namespace` tag as a workaround.
    >
    > *   `clear_params` attribute isn’t available.
    >
    > *   It doesn’t accept `remap` nor `param` tags as children.
    >
    > *   It has two new attributes: `scoped` and `forwarding` (both are true by default). If `scoped` is false, the group does not introduce a new variable scope, so actions done to variables inside the group also affect the outside variables. If `forwarding` is false, no outside launch configurations ( `arg` ) are available inside the group. This can be useful to isolate an included launch file and thus prevent collisions in argument names.
    >


#### Example[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#launch-prefix-example "Link to this heading")

`launch-prefix` configuration affects both `executable` and `node` tags’ actions. This example will use `time` as a prefix if `use_time_prefix_in_talker` argument is `1`, only for the talker.

<launch>
   <arg name="use\_time\_prefix\_in\_talker" default="0"/>
   <group>
      <let name="launch-prefix" value="time" if="$(var use\_time\_prefix\_in\_talker)"/>
      <node pkg="demo\_nodes\_cpp" exec="talker"/>
   </group>
   <node pkg="demo\_nodes\_cpp" exec="listener"/>
</launch>

Copy to clipboard

### [machine](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id20)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#machine "Link to this heading")

It is not supported at the moment.

### [test](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id21)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#test "Link to this heading")

It is not supported at the moment.

[New tags in ROS 2](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id22)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#new-tags-in-ros-2 "Link to this heading")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### [set\_env and unset\_env](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id23)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#set-env-and-unset-env "Link to this heading")

See [env](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#env)
 tag description.

### [push\_ros\_namespace](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id24)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#push-ros-namespace "Link to this heading")

`include` and `group` tags don’t accept an `ns` attribute. This action can be used as a workaround:

<!-Other tags-->
<group>
   <push\_ros\_namespace namespace="my\_ns"/>
   <!--Nodes here are namespaced with "my\_ns".-->
   <!--If there is an include action here, its nodes will also be namespaced.-->
   <push\_ros\_namespace namespace="another\_ns"/>
   <!--Nodes here are namespaced with "another\_ns/my\_ns".-->
   <push\_ros\_namespace namespace="/absolute\_ns"/>
   <!--Nodes here are namespaced with "/absolute\_ns".-->
   <!--The following node receives an absolute namespace, so it will ignore the others previously pushed.-->
   <!--The full path of the node will be /asd/my\_node.-->
   <node pkg="my\_pkg" exec="my\_executable" name="my\_node" namespace="/asd"/>
</group>
<!--Nodes outside the group action won't be namespaced.-->
<!-Other tags-->

Copy to clipboard

### [let](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id25)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#let "Link to this heading")

It’s a replacement of `arg` tag with a value attribute.

<let name="foo" value="asd"/>

Copy to clipboard

`let` and `arg` serve two different purposes in ROS 2:

*   `let` sets a launch configuration value.

*   `arg` declares a launch argument/configuration and optionally provides a default value. The value can separately be set from the CLI or when including the given launch file. If no value is set, the default value is used if one was provided, otherwise an error is reported.


### [executable](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id26)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#executable "Link to this heading")

It allows running any executable.

#### Example[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id7 "Link to this heading")

<executable cmd="ls -las" cwd="/var/log" name="my\_exec" launch-prefix="something" output="screen" shell="true"\>
   <env name="LD\_LIBRARY" value="/lib/some.so"/>
</executable>

Copy to clipboard

[Replacing an include tag](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id27)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#replacing-an-include-tag "Link to this heading")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

In order to include a launch file under a **namespace** as in ROS 1 then the `include` tags must be nested in a `group` tag.

<group>
   <include file="another\_launch\_file"/>
</group>

Copy to clipboard

Then, instead of using the `ns` attribute, add the `push_ros_namespace` action tag to specify the namespace:

<group>
   <push\_ros\_namespace namespace="my\_ns"/>
   <include file="another\_launch\_file"/>
</group>

Copy to clipboard

Nesting `include` tags under a `group` tag is only required when specifying a namespace

[Substitutions](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id28)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#substitutions "Link to this heading")

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Documentation about ROS 1’s substitutions can be found in [roslaunch XML wiki](https://wiki.ros.org/roslaunch/XML)
. Substitutions syntax hasn’t changed, i.e. it still follows the `$(substitution-name arg1 arg2 ...)` pattern. There are, however, some changes w.r.t. ROS 1:

*   `env` and `optenv` tags have been replaced by the `env` tag. `$(env <NAME>)` will fail if the environment variable doesn’t exist. `$(env <NAME> '')` does the same as ROS 1’s `$(optenv <NAME>)`. `$(env <NAME> <DEFAULT>)` does the same as ROS 1’s `$(env <NAME> <DEFAULT>)` or `$(optenv <NAME> <DEFAULT>)`.

*   `find` has been replaced with `find-pkg-share` (substituting the share directory of an installed package). Alternatively `find-pkg-prefix` will return the root of an installed package.

*   There is a new `exec-in-pkg` substitution. e.g.: `$(exec-in-pkg <exec_name> <package_name>)`.

*   There is a new `find-exec` substitution.

*   `arg` has been replaced with `var`. It looks at configurations defined either with `arg` or `let` tag.

*   `eval` and `dirname` substitutions require escape characters for string values, e.g. `if="$(eval '\'$(var variable)\' == \'val1\'')"`. You can also use HTML escapes like `&quot;` .

*   `eval` does not pass configurations ( `arg` ) as local Python variables. They have to be accessed via `$(var name)`.

*   The argument of `eval` has to be a quoted string in ROS 2. That is also the reason why quotes inside the expression have to be escaped.


[Type inference rules](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id29)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html#id8 "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

The rules that were shown in `Type inference rules` subsection of `param` tag applies to any attribute. For example:

<!--Setting a string value to an attribute expecting an int will raise an error.-->
<tag1 attr-expecting-an-int="'1'"/>
<!--Correct version.-->
<tag1 attr-expecting-an-int="1"/>
<!--Setting an integer in an attribute expecting a string will raise an error.-->
<tag2 attr-expecting-a-str="1"/>
<!--Correct version.-->
<tag2 attr-expecting-a-str="'1'"/>
<!--Setting a list of strings in an attribute expecting a string will raise an error.-->
<tag3 attr-expecting-a-str="asd, bsd" str-attr-sep=", "/>
<!--Correct version.-->
<tag3 attr-expecting-a-str="don't use a separator"/>

Copy to clipboard

Some attributes accept more than a single type, for example `value` attribute of `param` tag. It’s usual that parameters that are of type `int` (or `float`) also accept an `str`, that will be later substituted and tried to convert to an `int` (or `float`) by the action.

Other Versions v: jazzy

Releases

[Kilted (latest)](https://docs.ros.org/en/kilted/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html)

[Jazzy](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html)

[Iron (EOL)](https://docs.ros.org/en/iron/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html)

[Humble](https://docs.ros.org/en/humble/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html)

[Galactic (EOL)](https://docs.ros.org/en/galactic/index.html)

[Foxy (EOL)](https://docs.ros.org/en/foxy/index.html)

[Eloquent (EOL)](https://docs.ros.org/en/eloquent/index.html)

[Dashing (EOL)](https://docs.ros.org/en/dashing/index.html)

[Crystal (EOL)](https://docs.ros.org/en/crystal/index.html)

In Development

[Rolling](https://docs.ros.org/en/rolling/How-To-Guides/Migrating-from-ROS1/Migrating-Launch-Files.html)
