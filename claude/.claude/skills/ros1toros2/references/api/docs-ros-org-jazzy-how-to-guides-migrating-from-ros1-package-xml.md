---
source_url: https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html
fetched_at: 2026-04-18T10:58:32Z
---

*   [](https://docs.ros.org/en/jazzy/index.html)

*   [How-to Guides](https://docs.ros.org/en/jazzy/How-To-Guides.html)

*   [Migrating from ROS 1 to ROS 2](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1.html)

*   Migrating your package.xml to format 2
*   [Edit on GitHub](https://github.com/ros2/ros2_documentation/blob/jazzy/source/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.rst)


* * *

**You're reading the documentation for an older, but still supported, version of ROS 2. For information on the latest version, please have a look at [Kilted](https://docs.ros.org/en/kilted/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html)
.**

Migrating your package.xml to format 2[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#migrating-your-package-xml-to-format-2 "Link to this heading")

====================================================================================================================================================================================================

ROS 2 requires `package.xml` files to use at least [format 2](https://reps.openrobotics.org/rep-0140/)
. This guide shows how to migrate a `package.xml` from format 1 to format 2.

If the `<package>` tag at the start of your `package.xml` looks like either of the following, then it is using format 1 and you must migrate it.

<package>

Copy to clipboard

<package format="1"\>

Copy to clipboard

[Prerequisites](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#id1)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#prerequisites "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

You should have a working ROS 1 installation. This enables you to check that the converted `package.xml` is valid by building and testing the package, since ROS 1 supports all `package.xml` format versions.

[Migrate from format 1 to 2](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#id2)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#migrate-from-format-1-to-2 "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Format 1 and format 2 differ in how they specify dependencies. Read the [compatibility section in REP-0140](https://reps.openrobotics.org/rep-0140/#compatibility)
 for a summary of the differences.

### [Add `format` attribute to `<package>`](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#id3)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#add-format-attribute-to-package "Link to this heading")

Add or set the `format` attribute to `2` to indicate that the `package.xml` uses format 2.

<package format="2"\>

Copy to clipboard

### [Replace `<run_depend>`](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#id4)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#replace-run-depend "Link to this heading")

The `<run_depend>` tag is no longer allowed. If you have a dependency specified like this:

<run\_depend>foo</run\_depend>

Copy to clipboard

then replace it with one or both of these tags:

<build\_export\_depend>foo</build\_export\_depend>
<exec\_depend>foo</exec\_depend>

Copy to clipboard

If the dependency is needed when something in your package is executed, then use the `<exec_depend>` tag. If packages that depend on your package need the dependency when they are built, then use the `<build_export_depend>` tag. Use both tags if you are unsure.

### [Convert some `<build_depend>` to `<test_depend>`](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#id5)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#convert-some-build-depend-to-test-depend "Link to this heading")

In format 1 `<test_depend>` declares dependencies that are needed when running your package’s tests. It still does that in format 2, but it additionally declares dependencies that are needed when building your package’s tests.

Because of the limitations of this tag in format 1, your package may have a test-only dependency specified as a `<build_depend>` like this:

<build\_depend>testfoo</build\_depend>

Copy to clipboard

If so, change it to a `<test_depend>`.

<test\_depend>testfoo</test\_depend>

Copy to clipboard

Note

If you are using CMake, then make sure your test dependencies are only referenced within a `if(BUILD_TESTING)` block:

if (BUILD\_TESTING)
    find\_package(testfoo REQUIRED)
endif()

Copy to clipboard

### [Begin using `<doc_depend>`](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#id6)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#begin-using-doc-depend "Link to this heading")

Use the new `<doc_depend>` tag to declare dependencies needed for building your package’s documentation. For example, C++ packages might have this dependency:

<doc\_depend>doxygen</doc\_depend>

Copy to clipboard

while Python packages might have this one:

<doc\_depend>python3-sphinx</doc\_depend>

Copy to clipboard

See [the guide on documenting ROS 2 packages](https://docs.ros.org/en/jazzy/How-To-Guides/Documenting-a-ROS-2-Package.html)
 for more information.

### [Simplify dependencies with `<depend>`](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#id7)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#simplify-dependencies-with-depend "Link to this heading")

`<depend>` is a new tag that makes `package.xml` files more concise. If your `package.xml` has these three tags for the same dependency:

<build\_depend\>foo</build\_depend\>
<build\_export\_depend\>foo</build\_export\_depend\>
<exec\_depend\>foo</exec\_depend\>

Copy to clipboard

then replace them with a single `<depend>` like this:

<depend>foo</depend>

Copy to clipboard

[Test your new `package.xml`](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#id8)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html#test-your-new-package-xml "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Build and test your package as you normally do using `catkin_make`, `cakin_make_isolated`, or the `catkin` build tool. If everything succeeds, then your `package.xml` is valid.

Other Versions v: jazzy

Releases

[Kilted (latest)](https://docs.ros.org/en/kilted/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html)

[Jazzy](https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html)

[Iron (EOL)](https://docs.ros.org/en/iron/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html)

[Humble](https://docs.ros.org/en/humble/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html)

[Galactic (EOL)](https://docs.ros.org/en/galactic/index.html)

[Foxy (EOL)](https://docs.ros.org/en/foxy/index.html)

[Eloquent (EOL)](https://docs.ros.org/en/eloquent/index.html)

[Dashing (EOL)](https://docs.ros.org/en/dashing/index.html)

[Crystal (EOL)](https://docs.ros.org/en/crystal/index.html)

In Development

[Rolling](https://docs.ros.org/en/rolling/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html)
