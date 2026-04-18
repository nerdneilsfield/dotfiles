---
source_url: https://docs.ros.org/en/jazzy/How-To-Guides/Migrating-from-ROS1/Migrating-Package-XML.html
fetched_at: 2026-04-18T00:00:00Z
---

# Migrating your package.xml to format 2 — ROS 2 Documentation: Jazzy  documentation

Migrating your package.xml to format 2 — ROS 2 Documentation: Jazzy  documentation

-
- How-to Guides
- Migrating from ROS 1 to ROS 2
- Migrating your package.xml to format 2
-  Edit on GitHub


You're reading the documentation for an older, but still supported, version of ROS 2.
For information on the latest version, please have a look at Kilted.



Migrating your package.xml to format 2

ROS 2 requires `package.xml` files to use at least format 2.
This guide shows how to migrate a `package.xml` from format 1 to format 2.

If the `<package>` tag at the start of your `package.xml` looks like either of the following, then it is using format 1 and you must migrate it.

```
<package>

```

```
<package format="1">

```

Prerequisites

You should have a working ROS 1 installation.
This enables you to check that the converted `package.xml` is valid by building and testing the package, since ROS 1 supports all `package.xml` format versions.

Migrate from format 1 to 2

Format 1 and format 2 differ in how they specify dependencies.
Read the compatibility section in REP-0140 for a summary of the differences.

Add `format` attribute to `<package>`

Add or set the `format` attribute to `2` to indicate that the `package.xml` uses format 2.

```
<package format="2">

```

Replace `<run_depend>`

The `<run_depend>` tag is no longer allowed.
If you have a dependency specified like this:

```
<run_depend>foo</run_depend>

```

then replace it with one or both of these tags:

```
<build_export_depend>foo</build_export_depend>
<exec_depend>foo</exec_depend>

```

If the dependency is needed when something in your package is executed, then use the `<exec_depend>` tag.
If packages that depend on your package need the dependency when they are built, then use the `<build_export_depend>` tag.
Use both tags if you are unsure.

Convert some `<build_depend>` to `<test_depend>`

In format 1 `<test_depend>` declares dependencies that are needed when running your package’s tests.
It still does that in format 2, but it additionally declares dependencies that are needed when building your package’s tests.

Because of the limitations of this tag in format 1, your package may have a test-only dependency specified as a `<build_depend>` like this:

```
<build_depend>testfoo</build_depend>

```

If so, change it to a `<test_depend>`.

```
<test_depend>testfoo</test_depend>

```

Note

If you are using CMake, then make sure your test dependencies are only referenced within a `if(BUILD_TESTING)` block:

```
if (BUILD_TESTING)
find_package(testfoo REQUIRED)
endif()

```

Begin using `<doc_depend>`

Use the new `<doc_depend>` tag to declare dependencies needed for building your package’s documentation.
For example, C++ packages might have this dependency:

```
<doc_depend>doxygen</doc_depend>

```

while Python packages might have this one:

```
<doc_depend>python3-sphinx</doc_depend>

```

See the guide on documenting ROS 2 packages for more information.

Simplify dependencies with `<depend>`

`<depend>` is a new tag that makes `package.xml` files more concise.
If your `package.xml` has these three tags for the same dependency:

```
<build_depend>foo</build_depend>
<build_export_depend>foo</build_export_depend>
<exec_depend>foo</exec_depend>

```

then replace them with a single `<depend>` like this:

```
<depend>foo</depend>

```

Test your new `package.xml`

Build and test your package as you normally do using `catkin_make`, `cakin_make_isolated`, or the `catkin` build tool.
If everything succeeds, then your `package.xml` is valid.

PreviousNext

© Copyright 2026, Open Robotics.

Built with Sphinx using a
theme
provided by Read the Docs.


Other Versions
v: jazzy

ReleasesKilted (latest)JazzyIron (EOL)HumbleGalactic (EOL)Foxy (EOL)Eloquent (EOL)Dashing (EOL)Crystal (EOL)In DevelopmentRolling
