---
source_url: https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html
fetched_at: 2026-04-18T10:58:22Z
---

*   [](https://docs.ros.org/en/jazzy/index.html)

*   [How-to Guides](https://docs.ros.org/en/jazzy/How-To-Guides.html)

*   ament\_cmake user documentation
*   [Edit on GitHub](https://github.com/ros2/ros2_documentation/blob/jazzy/source/How-To-Guides/Ament-CMake-Documentation.rst)


* * *

**You're reading the documentation for an older, but still supported, version of ROS 2. For information on the latest version, please have a look at [Kilted](https://docs.ros.org/en/kilted/How-To-Guides/Ament-CMake-Documentation.html)
.**

ament\_cmake user documentation[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#ament-cmake-user-documentation "Link to this heading")

=====================================================================================================================================================================

`ament_cmake` is the build system for CMake based packages in ROS 2 (in particular, it will be used for most C/C++ projects). It is a set of scripts enhancing CMake and adding convenience functionality for package authors. Before using `ament_cmake`, it is very helpful to know the basics of [CMake](https://cmake.org/cmake/help/v3.8/)
. An official tutorial can be found [here](https://cmake.org/cmake/help/latest/guide/tutorial/index.html)
.

[Basics](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id1)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#basics "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

A basic CMake outline can be produced using `ros2 pkg create <package_name>` on the command line. The build information is then gathered in two files: the `package.xml` and the `CMakeLists.txt`, which must be in the same directory. The `package.xml` must contain all dependencies and a bit of metadata to allow colcon to find the correct build order for your packages, to install the required dependencies in CI, and to provide the information for a release with `bloom`. The `CMakeLists.txt` contains the commands to build and package executables and libraries and will be the main focus of this document.

### [Basic project outline](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id2)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#basic-project-outline "Link to this heading")

The basic outline of the `CMakeLists.txt` of an ament package contains:

cmake\_minimum\_required(VERSION 3.8)
project(my\_project)

ament\_package()

Copy to clipboard

The argument to `project` will be the package name and must be identical to the package name in the `package.xml`.

The project setup is done by `ament_package()` and this call must occur exactly once per package. `ament_package()` installs the `package.xml`, registers the package with the ament index, and installs configuration (and possibly target) files for CMake so that it can be found by other packages using `find_package`. Since `ament_package()` gathers a lot of information from the `CMakeLists.txt` it should be the last call in your `CMakeLists.txt`.

`ament_package` can be given additional arguments:

*   `CONFIG_EXTRAS`: a list of CMake files (`.cmake` or `.cmake.in` templates expanded by `configure_file()`) which should be available to clients of the package. For an example of when to use these arguments, see the discussion in [Adding resources](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#adding-resources)
    . For more information on how to use template files, see [the official documentation](https://cmake.org/cmake/help/v3.8/command/configure_file.html)
    .

*   `CONFIG_EXTRAS_POST`: same as `CONFIG_EXTRAS`, but the order in which the files are added differs. While `CONFIG_EXTRAS` files are included before the files generated for the `ament_export_*` calls the files from `CONFIG_EXTRAS_POST` are included afterwards.


Instead of adding to `ament_package`, you can also add to the variable `${PROJECT_NAME}_CONFIG_EXTRAS` and `${PROJECT_NAME}_CONFIG_EXTRAS_POST` with the same effect. The only difference is again the order in which the files are added with the following total order:

*   files added by `CONFIG_EXTRAS`

*   files added by appending to `${PROJECT_NAME}_CONFIG_EXTRAS`

*   files added by appending to `${PROJECT_NAME}_CONFIG_EXTRAS_POST`

*   files added by `CONFIG_EXTRAS_POST`


### [Compiler and linker options](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id3)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#compiler-and-linker-options "Link to this heading")

ROS 2 targets compilers which comply with the C++17 and C99 standard. Newer versions might be targeted in the future and are referenced [here](https://reps.openrobotics.org/rep-2000/)
. Therefore it is customary to set the corresponding CMake flags:

if(NOT CMAKE\_C\_STANDARD)
  set(CMAKE\_C\_STANDARD 99)
endif()
if(NOT CMAKE\_CXX\_STANDARD)
  set(CMAKE\_CXX\_STANDARD 17)
endif()

Copy to clipboard

To keep the code clean, compilers should throw warnings for questionable code and these warnings should be fixed.

It is recommended to at least cover the following warning levels:

*   For Visual Studio: the default `W1` warnings

*   For GCC and Clang: `-Wall -Wextra -Wpedantic` are highly recommended and `-Wshadow` is advisable


It is currently recommended to use `add_compile_options` to add these options for all targets. This avoids cluttering the code with target-based compile options for all executables, libraries, and tests:

if(CMAKE\_COMPILER\_IS\_GNUCXX OR CMAKE\_CXX\_COMPILER\_ID MATCHES "Clang")
  add\_compile\_options(\-Wall \-Wextra \-Wpedantic)
endif()

Copy to clipboard

### [Finding dependencies](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id4)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#finding-dependencies "Link to this heading")

Most `ament_cmake` projects will have dependencies on other packages. In CMake, this is accomplished by calling `find_package`. For instance, if your package depends on `rclcpp`, then the `CMakeLists.txt` file should contain:

find\_package(rclcpp REQUIRED)

Copy to clipboard

Note

It should never be necessary to `find_package` a library that is not explicitly needed but is a dependency of another dependency that is explicitly needed. If that is the case, file a bug against the corresponding package.

### [Adding targets](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id5)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#adding-targets "Link to this heading")

In CMake nomenclature, `targets` are the artifacts that this project will create. Either libraries or executables can be created, and a single project can contain zero or many of each of them.

LibrariesExecutables

These are created with a call to `add_library`, which should contain both the name of the target and the source files that should be compiled to create the library.

With the separation of header files and implementation in C/C++, it is not usually necessary to add header files as arguments to `add_library`.

The following best practice is proposed:

*   Put all headers which should be usable by clients of this library (and therefore must be installed) into a subdirectory of the `include` folder named like the package, while all other files (`.c/.cpp` and header files which should not be exported) are inside the `src` folder

*   Only `.c/.cpp` files are explicitly referenced in the call to `add_library`

*   Find headers to your library `my_library` via


target\_include\_directories(my\_library
  PUBLIC
    "$<BUILD\_INTERFACE:${CMAKE\_CURRENT\_SOURCE\_DIR}/include>"
    "$<INSTALL\_INTERFACE:include/${PROJECT\_NAME}>")

Copy to clipboard

This adds all files in the folder `${CMAKE_CURRENT_SOURCE_DIR}/include` to the public interface during build time and all files in the include folder (relative to `${CMAKE_INSTALL_DIR}`) when being installed.

`ros2 pkg create` creates a package layout that follows these rules.

Note

Since Windows is one of the officially supported platforms, to have maximum impact, any package should also build on Windows. The Windows library format enforces symbol visibility; that is, every symbol which should be used from a client has to be explicitly exported by the library (and symbols need to be implicitly imported).

Since GCC and Clang builds do not generally do this, it is advised to use the logic in [the GCC wiki](https://gcc.gnu.org/wiki/Visibility)
. To use it for a package called `my_library`:

*   Copy the logic in the link into a header file called `visibility_control.hpp`.

*   Replace `DLL` by `MY_LIBRARY` (for an example, see visibility control of [rviz\_rendering](https://github.com/ros2/rviz/blob/ros2/rviz_rendering/include/rviz_rendering/visibility_control.hpp)
    ).

*   Use the macros “MY\_LIBRARY\_PUBLIC” for all symbols you need to export (i.e. classes or functions).

*   In the project `CMakeLists.txt` use:

    target\_compile\_definitions(my\_library PRIVATE "MY\_LIBRARY\_BUILDING\_LIBRARY")

    Copy to clipboard


For more details, see [Windows Symbol Visibility in the Windows Tips and Tricks document](https://docs.ros.org/en/jazzy/The-ROS2-Project/Contributing/Windows-Tips-and-Tricks.html#windows-symbol-visibility)
.

These should be created with a call to `add_executable`, which should contain both the name of the target and the source files that should be compiled to create the executable. The executable may also have to be linked with any libraries created in this package by using `target_link_libraries`.

Since executables aren’t generally used by clients as a library, no header files need to be put in the `include` directory.

In the case that a package has both libraries and executables, make sure to combine the advice from both “Libraries” and “Executables” above.

### [Linking to dependencies](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id6)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#linking-to-dependencies "Link to this heading")

There are two ways to link your targets against a dependency.

The first and recommended way is to use the ament macro `ament_target_dependencies`. As an example, suppose we want to link `my_library` against the linear algebra library Eigen3.

find\_package(Eigen3 REQUIRED)
ament\_target\_dependencies(my\_library PUBLIC Eigen3)

Copy to clipboard

It includes the necessary headers and libraries and their dependencies to be correctly found by the project.

The second way is to use `target_link_libraries`.

Modern CMake prefers to use only targets, exporting and linking against them. CMake targets may be namespaced, similar to C++. Prefer to use the namespaced targets if they are available. For instance, `Eigen3` defines the target `Eigen3::Eigen`.

In the example of Eigen3, the call should then look like

target\_link\_libraries(my\_library PUBLIC Eigen3::Eigen)

Copy to clipboard

This will also include necessary headers, libraries and their dependencies. Note that this dependency must have been previously discovered via a call to `find_package`.

### [Installing](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id7)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#installing "Link to this heading")

LibrariesExecutables

When building a reusable library, some information needs to be exported for downstream packages to easily use it.

First, install the headers files which should be available to clients. The include directory is custom to support overlays in `colcon`; see [https://colcon.readthedocs.io/en/released/user/overriding-packages.html#install-headers-to-a-unique-include-directory](https://colcon.readthedocs.io/en/released/user/overriding-packages.html#install-headers-to-a-unique-include-directory)
 for more information.

install(
  DIRECTORY include/
  DESTINATION include/${PROJECT\_NAME}
)

Copy to clipboard

Next, install the targets and create the export target (`export_${PROJECT_NAME}`) that other code will use to find this package. Note that you can use a single `install` call to install all of the libraries in the project.

install(
  TARGETS my\_library
  EXPORT export\_${PROJECT\_NAME}
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  RUNTIME DESTINATION bin
)

ament\_export\_targets(export\_${PROJECT\_NAME} HAS\_LIBRARY\_TARGET)
ament\_export\_dependencies(some\_dependency)

Copy to clipboard

Here is what’s happening in the snippet above:

*   The `ament_export_targets` macro exports the targets for CMake. This is necessary to allow your library’s clients to use the `target_link_libraries(client PRIVATE my_library::my_library)` syntax. If the export set includes a library, add the option `HAS_LIBRARY_TARGET` to `ament_export_targets`, which adds potential libraries to environment variables.

*   The `ament_export_dependencies` exports dependencies to downstream packages. This is necessary so that the user of the library does not have to call `find_package` for those dependencies, too.


Warning

Calling `ament_export_targets`, `ament_export_dependencies`, or other ament commands from a CMake subdirectory will not work as expected. This is because the CMake subdirectory has no way of setting necessary variables in the parent scope where `ament_package` is called.

Note

Windows DLLs are treated as runtime artifacts and installed into the `RUNTIME DESTINATION` folder. It is therefore advised to keep the `RUNTIME` install even when developing libraries on Unix based systems.

*   The `EXPORT` notation of the install call requires additional attention: It installs the CMake files for the `my_library` target. It must be named exactly the same as the argument in `ament_export_targets`. To ensure that it can be used via `ament_target_dependencies`, it should not be named exactly the same as the library name, but instead should have a prefix like `export_` (as shown above).

*   All install paths are relative to `CMAKE_INSTALL_PREFIX`, which is already set correctly by colcon/ament.


There are two additional functions which are available, but are superfluous for target based installs:

ament\_export\_include\_directories("include/${PROJECT\_NAME}")
ament\_export\_libraries(my\_library)

Copy to clipboard

The first macro marks the directory of the exported include directories. The second macro marks the location of the installed library (this is done by the `HAS_LIBRARY_TARGET` argument in the call to `ament_export_targets`). These should only be used if the downstream projects can’t or don’t want to use CMake target based dependencies.

Some of the macros can take different types of arguments for non-target exports, but since the recommended way for modern Make is to use targets, we will not cover them here. Documentation of these options can be found in the source code itself.

When installing an executable, the following stanza _must be followed exactly_ for the rest of the ROS tooling to find it:

install(TARGETS my\_exe
    DESTINATION lib/${PROJECT\_NAME})

Copy to clipboard

In the case that a package has both libraries and executables, make sure to combine the advice from both “Libraries” and “Executables” above.

[Linting and Testing](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id8)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#linting-and-testing "Link to this heading")

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

In order to separate testing from building the library with colcon, wrap all calls to linters and tests in a conditional:

if(BUILD\_TESTING)
  find\_package(ament\_cmake\_gtest REQUIRED)
  ament\_add\_gtest(<tests>)
endif()

Copy to clipboard

### [Linting](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id9)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#linting "Link to this heading")

It’s advised to use the combined call from [ament\_lint\_auto](https://github.com/ament/ament_lint/blob/jazzy/ament_lint_auto/doc/index.rst#ament_lint_auto)
:

find\_package(ament\_lint\_auto REQUIRED)
ament\_lint\_auto\_find\_test\_dependencies()

Copy to clipboard

This will run linters as defined in the `package.xml`. It is recommended to use the set of linters defined by the package `ament_lint_common`. The individual linters included there, as well as their functions, can be seen in the [ament\_lint\_common docs](https://github.com/ament/ament_lint/blob/jazzy/ament_lint_common/doc/index.rst)
.

Linters provided by ament can also be added separately, instead of running `ament_lint_auto`. One example of how to do so can be found in the [ament\_cmake\_lint\_cmake documentation](https://github.com/ament/ament_lint/blob/jazzy/ament_cmake_lint_cmake/doc/index.rst)
.

### [Testing](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id10)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#testing "Link to this heading")

Ament contains CMake macros to simplify setting up GTests. Call:

find\_package(ament\_cmake\_gtest)
ament\_add\_gtest(some\_test <test\_sources>)

Copy to clipboard

to add a GTest. This is then a regular target which can be linked against other libraries (such as the project library). The macros have additional parameters:

*   `APPEND_ENV`: append environment variables. For instance you can add to the ament prefix path by calling:


find\_package(ament\_cmake\_gtest REQUIRED)
ament\_add\_gtest(some\_test <test\_sources>
  APPEND\_ENV PATH=some/additional/path/for/testing/resources)

Copy to clipboard

*   `APPEND_LIBRARY_DIRS`: append libraries so that they can be found by the linker at runtime. This can be achieved by setting environment variables like `PATH` on Windows and `LD_LIBRARY_PATH` on Linux, but this makes the call platform specific.

*   `ENV`: set environment variables (same syntax as `APPEND_ENV`).

*   `TIMEOUT`: set a test timeout in second. The default for GTests is 60 seconds. For example:


ament\_add\_gtest(some\_test <test\_sources> TIMEOUT 120)

Copy to clipboard

*   `SKIP_TEST`: skip this test (will be shown as “passed” in the console output).

*   `SKIP_LINKING_MAIN_LIBRARIES`: Don’t link against GTest.

*   `WORKING_DIRECTORY`: set the working directory for the test.


The default working directory otherwise is the `CMAKE_CURRENT_BINARY_DIR`, which is described in the [CMake documentation](https://cmake.org/cmake/help/latest/variable/CMAKE_CURRENT_BINARY_DIR.html)
.

Similarly, there is a CMake macro to set up GTest including GMock:

find\_package(ament\_cmake\_gmock REQUIRED)
ament\_add\_gmock(some\_test <test\_sources>)

Copy to clipboard

It has the same additional parameters as `ament_add_gtest`.

[Extending ament](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id11)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#extending-ament "Link to this heading")

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

It is possible to register additional macros/functions with `ament_cmake` and extend it in several ways.

### [Adding a function/macro to ament](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id12)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#adding-a-function-macro-to-ament "Link to this heading")

Extending ament will often times mean that you want to have some functions available to other packages. The best way to provide the macro to client packages is to register it with ament.

This can be done by appending the `${PROJECT_NAME}_CONFIG_EXTRAS` variable, which is used by `ament_package()` via

list(APPEND ${PROJECT\_NAME}\_CONFIG\_EXTRAS
  path/to/file.cmake"
  other/pathto/file.cmake"
)

Copy to clipboard

Alternatively, you can directly add the files to the `ament_package()` call:

ament\_package(CONFIG\_EXTRAS
  path/to/file.cmake
  other/pathto/file.cmake
)

Copy to clipboard

### [Adding to extension points](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id13)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#adding-to-extension-points "Link to this heading")

In addition to simple files with functions that can be used in other packages, you can also add extensions to ament. Those extensions are scripts which are executed with the function which defines the extension point. The most common use-case for ament extensions is probably registering rosidl message generators: When writing a generator, you normally want to generate all messages and services with your generator also without modifying the code for the message/service definition packages. This is possible by registering the generator as an extension to `rosidl_generate_interfaces`.

As an example, see

ament\_register\_extension(
  "rosidl\_generate\_interfaces"
  "rosidl\_generator\_cpp"
  "rosidl\_generator\_cpp\_generate\_interfaces.cmake")

Copy to clipboard

which registers the macro `rosidl_generator_cpp_generate_interfaces.cmake` for the package `rosidl_generator_cpp` to the extension point `rosidl_generate_interfaces`. When the extension point gets executed, this will trigger the execution of the script `rosidl_generator_cpp_generate_interfaces.cmake` here. In particular, this will call the generator whenever the function `rosidl_generate_interfaces` gets executed.

The most important extension point for generators, aside from `rosidl_generate_interfaces`, is `ament_package`, which will simply execute scripts with the `ament_package()` call. This extension point is useful when registering resources (see below).

`ament_register_extension` is a function which takes exactly three arguments:

*   `extension_point`: The name of the extension point (most of the time this will be one of `ament_package` or `rosidl_generate_interfaces`)

*   `package_name`: The name of the package containing the CMake file (i.e. the project name of the project where the file is written to)

*   `cmake_filename`: The CMake file executed when the extension point is run


Note

It is possible to define custom extension points in a similar manner to `ament_package` and `rosidl_generate_interfaces`, but this should hardly be necessary.

### [Adding extension points](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id14)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#adding-extension-points "Link to this heading")

Very rarely, it might be interesting to define a new extension point to ament.

Extension points can be registered within a macro so that all extensions will be executed when the corresponding macro is called. To do so:

*   Define and document a name for your extension (e.g. `my_extension_point`), which is the name passed to the `ament_register_extension` macro when using the extension point.

*   In the macro/function which should execute the extensions call:


ament\_execute\_extensions(my\_extension\_point)

Copy to clipboard

Ament extensions work by defining a variable containing the name of the extension point and filling it with the macros to be executed. Upon calling `ament_execute_extensions`, the scripts defined in the variable are then executed one after another.

[Adding resources](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id15)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#adding-resources "Link to this heading")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Especially when developing plugins or packages which allow plugins it is often essential to add resources to one ROS package from another (e.g. a plugin). Examples can be plugins for tools using the pluginlib.

This can be achieved using the ament index (also called “resource index”).

### [The ament index explained](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id16)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#the-ament-index-explained "Link to this heading")

For details on the design and intentions, see [here](https://github.com/ament/ament_cmake/blob/jazzy/ament_cmake_core/doc/resource_index.md)

In principle, the ament index is contained in a folder within the [install space](https://colcon.readthedocs.io/en/released/user/what-is-a-workspace.html#install-artifacts)
. It contains shallow subfolders named after different types of resources. Within the subfolder, each package providing said resource is referenced by name with a “marker file”. The file may contain whatever content necessary to obtain the resources, e.g. relative paths to the installation directories of the resource, it may also be simply empty.

To give an example, consider providing display plugins for RViz: When providing RViz plugins in a project named `my_rviz_displays` which will be read by the pluginlib, you will provide a `plugin_description.xml` file, which will be installed and used by the pluginlib to load the plugins. To achieve this, the plugin\_description.xml is registered as a resource in the resource\_index via

pluginlib\_export\_plugin\_description\_file(rviz\_common plugins\_description.xml)

Copy to clipboard

When running `colcon build`, this installs a file `my_rviz_displays` into a subfolder `rviz_common__pluginlib__plugin` into the resource\_index. Pluginlib factories within rviz\_common will know to gather information from all folders named `rviz_common__pluginlib__plugin` for packages that export plugins. The marker file for pluginlib factories contains an install-folder relative path to the `plugins_description.xml` file (and the name of the library as marker file name). With this information, the pluginlib can load the library and know which plugins to load from the `plugin_description.xml` file.

As a second example, consider the possibility to let your own RViz plugins use your own custom meshes. Meshes get loaded at startup time so that the plugin owner does not have to deal with it, but this implies RViz has to know about the meshes. To achieve this, RViz provides a function:

register\_rviz\_ogre\_media\_exports(DIRECTORIES <my\_dirs>)

Copy to clipboard

This registers the directories as an ogre\_media resource in the ament index. In short, it installs a file named after the project which calls the function into a subfolder called `rviz_ogre_media_exports`. The file contains the install folder relative paths to the directories listed in the macros. On startup time, RViz can now search for all folders called `rviz_ogre_media_exports` and load resources in all folders provided. These searches are done using `ament_index_cpp` (or `ament_index_py` for Python packages).

In the following sections we will explore how to add your own resources to the ament index and provide best practices for doing so.

### [Querying the ament index](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id17)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#querying-the-ament-index "Link to this heading")

If necessary, it is possible to query the ament index for resources via CMake. To do so, there are three functions:

`ament_index_has_resource`: Obtain a prefix path to the resource if it exists with the following parameters:

*   `var`: the output parameter: fill this variable with FALSE if the resource does not exist or the prefix path to the resource otherwise

*   `resource_type`: The type of the resource (e.g. `rviz_common__pluginlib__plugin`)

*   `resource_name`: The name of the resource which usually amounts to the name of the package having added the resource of type resource\_type (e.g. `rviz_default_plugins`)


`ament_index_get_resource`: Obtain the content of a specific resource, i.e. the contents of the marker file in the ament index.

*   `var`: the output parameter: filled with the content of the resource marker file if it exists.

*   `resource_type`: The type of the resource (e.g. `rviz_common__pluginlib__plugin`)

*   `resource_name`: The name of the resource which usually amounts to the name of the package having added the resource of type resource\_type (e.g. `rviz_default_plugins`)

*   `PREFIX_PATH`: The prefix path to search for (usually, the default `ament_index_get_prefix_path()` will be enough).


Note that `ament_index_get_resource` will throw an error if the resource does not exist, so it might be necessary to check using `ament_index_has_resource`.

`ament_index_get_resources`: Get all packages which registered resources of a specific type from the index

*   `var`: Output parameter: filled with a list of names of all packages which registered a resource of resource\_type

*   `resource_type`: The type of the resource (e.g. `rviz_common__pluginlib__plugin`)

*   `PREFIX_PATH`: The prefix path to search for (usually, the default `ament_index_get_prefix_path()` will be enough).


### [Adding to the ament index](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id18)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#adding-to-the-ament-index "Link to this heading")

Defining a resource requires two bits of information:

*   a name for the resource which must be unique,

*   a layout of the marker file, which can be anything and could also be empty (this is true for instance for the “package” resource marking a ROS 2 package)


For the RViz mesh resource, the corresponding choices were:

*   `rviz_ogre_media_exports` as name of the resource,

*   install path relative paths to all folders containing resources. This will already enable you to write the logic for using the corresponding resource in your package.


To allow users to easily register resources for your package, you should furthermore provide macros or functions such as the pluginlib function or `rviz_ogre_media_exports` function.

To register a resource, use the ament function `ament_index_register_resource`. This will create and install the marker files in the resource\_index. As an example, the corresponding call for `rviz_ogre_media_exports` is the following:

ament\_index\_register\_resource(rviz\_ogre\_media\_exports CONTENT ${OGRE\_MEDIA\_RESOURCE\_FILE})

Copy to clipboard

This installs a file named like `${PROJECT_NAME}` into a folder `rviz_ogre_media_exports` into the resource\_index with content given by variable `${OGRE_MEDIA_RESOURCE_FILE}`. The macro has a number of parameters that can be useful:

*   the first (unnamed) parameter is the name of the resource, which amounts to the name of the folder in the resource\_index

*   `CONTENT`: The content of the marker file as string. This could be a list of relative paths, etc. `CONTENT` cannot be used together with `CONTENT_FILE`.

*   `CONTENT_FILE`: The path to a file which will be use to create the marker file. The file can be a plain file or a template file expanded with `configure_file()`. `CONTENT_FILE` cannot be used together with `CONTENT`.

*   `PACKAGE_NAME`: The name of the package/library exporting the resource, which amounts to the name of the marker file. Defaults to `${PROJECT_NAME}`.

*   `AMENT_INDEX_BINARY_DIR`: The base path of the generated ament index. Unless really necessary, always use the default `${CMAKE_BINARY_DIR}/ament_cmake_index`.

*   `SKIP_INSTALL`: Skip installing the marker file.


Since only one marker file exists per package, it is usually a problem if the CMake function/macro gets called twice by the same project. However, for large projects it might be best to split up calls registering resources.

Therefore, it is best practice to let a macro registering a resource such as `register_rviz_ogre_media_exports.cmake` only fill some variables. The real call to `ament_index_register_resource` can then be added within an ament extension to `ament_package`. Since there must only ever be one call to `ament_package` per project, there will always only be one place where the resource gets registered. In the case of `rviz_ogre_media_exports` this amounts to the following strategy:

*   The macro `register_rviz_ogre_media_exports` takes a list of folders and appends them to a variable called `OGRE_MEDIA_RESOURCE_FILE`.

*   Another macro called `register_rviz_ogre_media_exports_hook` calls `ament_index_register_resource` if `${OGRE_MEDIA_RESOURCE_FILE}` is non-empty.

*   The `register_rviz_ogre_media_exports_hook.cmake` file is registered as an ament extension in a third file `register_rviz_ogre_media_exports_hook-extras.cmake` via calling


ament\_register\_extension("ament\_package" "rviz\_rendering"
  "register\_rviz\_ogre\_media\_exports\_hook.cmake")

Copy to clipboard

*   The files `register_rviz_ogre_media_exports.cmake` and `register_rviz_ogre_media_exports_hook-extra.cmake` are registered as `CONFIG_EXTRA` with `ament_package()`.


[Setting environment variables](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id19)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#setting-environment-variables "Link to this heading")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

`ament_cmake` provides a mechanism to automatically set environment variables for a ROS 2 workspace when it is sourced. This can be useful in configuring:

*   RMW implementations (setting up CycloneDDS, FastDDS, etc.)

*   Gazebo Simulations (setting up paths to plugins and resources)

*   Other custom robot-specific setting configurations


This can be implemented through `ament_environment_hooks`, which allows packages to define persistent environment variables that are set when the workspace is sourced.

### [About environment hooks](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id20)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#about-environment-hooks "Link to this heading")

Environment hooks are shell scripts provided by a ROS 2 package. When the setup file in the workspace is sourced, the hooks are also sourced. These scripts allow you to set or extend environment variables with requiring manual modifications to the `setup.bash` or `setup.zsh` files.

These environment hooks can be implemented by creating two types of script files:

*   `.dsv.in` files: These are machine-readable files that specify expected environment variable changes. Ament processes these files more efficiently than traditional shell scripts, improving performance when setting up the environment.

*   `.sh.in` files: These are shell scripts executed by Linux/macOS shells such as sh, bash, and zsh. They set environment variables at runtime when sourcing the workspace.


These files are processed by `colcon` to generate the final environment hook scripts.

The actual implementation of `ament_environment_hooks` can be found in the official [ament-cmake repository](https://github.com/ament/ament_cmake/tree/master/ament_cmake_core/cmake/environment_hooks)
.

### [Defining Persistent Environment Variables through Hooks](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id21)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#defining-persistent-environment-variables-through-hooks "Link to this heading")

This section provides a quick example on how to use environment hooks to configure FastDDS XML profiles for your ROS 2 package.

A recommended best practice when defining environment hooks is to place them within a dedicated `hooks` directory inside the package workspace.

Inside your created `hooks` folder, create a `my_package.sh.in` as follows:

export RMW\_IMPLEMENTATION\=rmw\_fastrtps\_cpp
export RMW\_FASTRTPS\_USE\_QOS\_FROM\_XML\=1
export FASTRTPS\_DEFAULT\_PROFILES\_FILE\="$COLCON\_CURRENT\_PREFIX/my\_dds\_profile.xml"

Copy to clipboard

In the same folder, create a `my_package.dsv.in` file as follows:

set;RMW\_IMPLEMENTATION;rmw\_fastrtps\_cpp
set;RMW\_FASTRTPS\_USE\_QOS\_FROM\_XML;1
set;FASTRTPS\_DEFAULT\_PROFILES\_FILE;my\_dds\_profile.xml

Copy to clipboard

Once added, you can register them using the ament\_environment\_hooks function in your `CMakeLists.txt` file:

ament\_environment\_hooks(
  "${CMAKE\_CURRENT\_SOURCE\_DIR}/hooks/my\_package.dsv.in"
  "${CMAKE\_CURRENT\_SOURCE\_DIR}/hooks/my\_package.sh.in"
)

Copy to clipboard

Another example of using environment hooks for Gazebo plugin paths can be found in the official [ros\_gz\_project\_template](https://github.com/gazebosim/ros_gz_project_template/tree/main/ros_gz_example_gazebo/hooks)
.

[API Version Management](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id22)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#api-version-management "Link to this heading")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ROS 2 provides automatic version header generation through `ament_generate_version_header`, which creates compile-time macros for API versioning and feature detection. This is particularly useful for maintaining backward compatibility and conditionally enabling features based on library versions.

Note

The `ament_generate_version_header` functionality is designed for C, C++, and other C-based languages only. It generates C/C++ header files with preprocessor macros and is not applicable to Python or other non-C-based packages.

### [Understanding auto-generated version macros](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id23)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#understanding-auto-generated-version-macros "Link to this heading")

Many ROS 2 C/C++ packages (such as `rclcpp`, `rcl`, and `rmw`) automatically generate version header files containing macros that expose the library’s version information. These version headers are generated from the `package.xml` file using the [ament\_generate\_version\_header.cmake](https://github.com/ament/ament_cmake/blob/$%7BROS_DISTRO%7D/ament_cmake_gen_version_h/cmake/ament_generate_version_header.cmake)
 script.

The generated version macros follow this naming convention:

*   `<PACKAGE_NAME>_VERSION_MAJOR`: Major version number

*   `<PACKAGE_NAME>_VERSION_MINOR`: Minor version number

*   `<PACKAGE_NAME>_VERSION_PATCH`: Patch version number

*   `<PACKAGE_NAME>_VERSION`: Combined version as a single integer (major \* 10000 + minor \* 100 + patch)

*   `<PACKAGE_NAME>_VERSION_STR`: String representation of the version (e.g., “1.2.3”)

*   `<PACKAGE_NAME>_VERSION_GTE(major, minor, patch)`: Macro to check if version is greater than or equal to specified version


For example, `rclcpp` provides macros like:

*   `RCLCPP_VERSION_MAJOR`

*   `RCLCPP_VERSION_MINOR`

*   `RCLCPP_VERSION_PATCH`

*   `RCLCPP_VERSION`

*   `RCLCPP_VERSION_STR`

*   `RCLCPP_VERSION_GTE(major, minor, patch)`


### [Generating version headers for your package](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id24)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#generating-version-headers-for-your-package "Link to this heading")

To generate version headers for your own package, add the following to your `CMakeLists.txt`:

find\_package(ament\_cmake\_gen\_version\_h REQUIRED)
ament\_generate\_version\_header(my\_library)

Copy to clipboard

This generates a header file at `<build_dir>/my_library/version.h` that can be included in your code:

#include "my\_library/version.h"

Copy to clipboard

The version information is automatically extracted from the `<version>` tag in your `package.xml`.

By default, the generated header file is placed in the build directory under `<package_name>/version.h`. You can customize the output location:

ament\_generate\_version\_header(my\_library HEADER\_PATH "my\_library/my\_version.h")

Copy to clipboard

### [Using version macros for API negotiation](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#id25)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#using-version-macros-for-api-negotiation "Link to this heading")

Version macros enable runtime and compile-time feature detection, which is essential for writing portable code across different ROS 2 distributions.

While ROS 2 guarantees ABI (Application Binary Interface) compatibility within the same distribution, new interfaces and features can be backported. This means that within a single distribution, different API versions may be available depending on which patch release is installed. Version macros allow developers to check if a specific feature is available before using it.

#### Example: Version checking[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#example-version-checking "Link to this heading")

#include "rclcpp/version.h"

// Check if new feature is available
#if RCLCPP\_VERSION\_GTE(28, 3, 0)
  use\_new\_api\_with\_feature();
#else
  use\_old\_api\_without\_feature();
#endif

Copy to clipboard

#### Best practices[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html#best-practices "Link to this heading")

*   **Check before using new features**: Always use version macros when utilizing features that may not be available in older versions of a library.

*   **Provide fallback implementations**: When possible, provide alternative implementations for older API versions to maintain backward compatibility.

*   **Document version requirements**: Clearly document the minimum required versions for specific features in your package documentation.

*   **Test across versions**: If your package needs to support multiple ROS 2 distributions, test it against the minimum supported version.

*   **Use the GTE macro**: Prefer using the `_VERSION_GTE(major, minor, patch)` macro for version comparisons, as it provides a cleaner and more readable syntax than manually comparing individual version components.


Other Versions v: jazzy

Releases

[Kilted (latest)](https://docs.ros.org/en/kilted/How-To-Guides/Ament-CMake-Documentation.html)

[Jazzy](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html)

[Iron (EOL)](https://docs.ros.org/en/iron/How-To-Guides/Ament-CMake-Documentation.html)

[Humble](https://docs.ros.org/en/humble/How-To-Guides/Ament-CMake-Documentation.html)

[Galactic (EOL)](https://docs.ros.org/en/galactic/How-To-Guides/Ament-CMake-Documentation.html)

[Foxy (EOL)](https://docs.ros.org/en/foxy/How-To-Guides/Ament-CMake-Documentation.html)

[Eloquent (EOL)](https://docs.ros.org/en/eloquent/index.html)

[Dashing (EOL)](https://docs.ros.org/en/dashing/index.html)

[Crystal (EOL)](https://docs.ros.org/en/crystal/index.html)

In Development

[Rolling](https://docs.ros.org/en/rolling/How-To-Guides/Ament-CMake-Documentation.html)
