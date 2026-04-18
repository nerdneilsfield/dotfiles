---
source_url: https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Python-Documentation.html
fetched_at: 2026-04-18T10:58:25Z
---

*   [](https://docs.ros.org/en/jazzy/index.html)

*   [How-to Guides](https://docs.ros.org/en/jazzy/How-To-Guides.html)

*   ament\_cmake\_python user documentation
*   [Edit on GitHub](https://github.com/ros2/ros2_documentation/blob/jazzy/source/How-To-Guides/Ament-CMake-Python-Documentation.rst)


* * *

**You're reading the documentation for an older, but still supported, version of ROS 2. For information on the latest version, please have a look at [Kilted](https://docs.ros.org/en/kilted/How-To-Guides/Ament-CMake-Python-Documentation.html)
.**

ament\_cmake\_python user documentation[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Python-Documentation.html#ament-cmake-python-user-documentation "Link to this heading")

===========================================================================================================================================================================================

`ament_cmake_python` is a package that provides CMake functions for packages of the `ament_cmake` build type that contain Python code. See the [ament\_cmake user documentation](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Documentation.html)
 for more information.

Note

Pure Python packages should use the `ament_python` build type in most cases. To create an `ament_python` package, see [Creating your first ROS 2 package](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Creating-Your-First-ROS2-Package.html)
. `ament_cmake_python` should only be used in cases where that is not possible, like when mixing C/C++ and Python code.

[Basics](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Python-Documentation.html#id1)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Python-Documentation.html#basics "Link to this heading")

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### [Basic project outline](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Python-Documentation.html#id2)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Python-Documentation.html#basic-project-outline "Link to this heading")

The outline of a package called “my\_project” with the `ament_cmake` build type that uses `ament_cmake_python` looks like:

.
└── my\_project
    ├── CMakeLists.txt
    ├── package.xml
    └── my\_project
        ├── \_\_init\_\_.py
        └── my\_script.py

Copy to clipboard

The `__init__.py` file can be empty, but it is needed to [make Python treat the directory containing it as a package](https://docs.python.org/3/tutorial/modules.html#packages)
. There can also be a `src` or `include` directory alongside the `CMakeLists.txt` which holds C/C++ code.

### [Using ament\_cmake\_python](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Python-Documentation.html#id3)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Python-Documentation.html#using-ament-cmake-python "Link to this heading")

The package must declare a dependency on `ament_cmake_python` in its `package.xml`.

<buildtool\_depend>ament\_cmake\_python</buildtool\_depend>

Copy to clipboard

The `CMakeLists.txt` should contain:

find\_package(ament\_cmake\_python REQUIRED)
\# ...
ament\_python\_install\_package(${PROJECT\_NAME})

Copy to clipboard

The argument to `ament_python_install_package()` is the name of the directory alongside the `CMakeLists.txt` that contains the Python file. In this case, it is `my_project`, or `${PROJECT_NAME}`.

Warning

Calling `rosidl_generate_interfaces` and `ament_python_install_package` in the same CMake project does not work. See this [Github issue](https://github.com/ros2/rosidl_python/issues/141)
 for more info. It is best practice to instead separate out the message generation into a separate package.

Then, another Python package that correctly depends on `my_project` can use it as a normal Python module:

from my\_project.my\_script import my\_function

Copy to clipboard

Assuming `my_script.py` contains a function called `my_function()`.

### [Using ament\_cmake\_pytest](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Python-Documentation.html#id4)
[](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Python-Documentation.html#using-ament-cmake-pytest "Link to this heading")

The package `ament_cmake_pytest` is used to make tests discoverable to `cmake`. The package must declare a test dependency on `ament_cmake_pytest` in its `package.xml`.

<test\_depend>ament\_cmake\_pytest</test\_depend>

Copy to clipboard

Say the package has a file structure like below, with tests in the `tests` folder.

.
├── CMakeLists.txt
├── my\_project
│   └── my\_script.py
├── package.xml
└── tests
    ├── test\_a.py
    └── test\_b.py

Copy to clipboard

The `CMakeLists.txt` should contain:

if(BUILD\_TESTING)
  find\_package(ament\_cmake\_pytest REQUIRED)
  set(\_pytest\_tests
    tests/test\_a.py
    tests/test\_b.py
    \# Add other test files here
  )
  foreach(\_test\_path ${\_pytest\_tests})
    get\_filename\_component(\_test\_name ${\_test\_path} NAME\_WE)
    ament\_add\_pytest\_test(${\_test\_name} ${\_test\_path}
      APPEND\_ENV PYTHONPATH=${CMAKE\_CURRENT\_BINARY\_DIR}
      TIMEOUT 60
      WORKING\_DIRECTORY ${CMAKE\_SOURCE\_DIR}
    )
  endforeach()
endif()

Copy to clipboard

Compared to the usage of ament\_python, which supports automatic test discovery, ament\_cmake\_pytest must be called with the path to each test file. The timeout can be reduced as needed.

Now, you can invoke your tests with the [standard colcon testing commands](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Testing/CLI.html)
.

Other Versions v: jazzy

Releases

[Kilted (latest)](https://docs.ros.org/en/kilted/How-To-Guides/Ament-CMake-Python-Documentation.html)

[Jazzy](https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Python-Documentation.html)

[Iron (EOL)](https://docs.ros.org/en/iron/How-To-Guides/Ament-CMake-Python-Documentation.html)

[Humble](https://docs.ros.org/en/humble/How-To-Guides/Ament-CMake-Python-Documentation.html)

[Galactic (EOL)](https://docs.ros.org/en/galactic/How-To-Guides/Ament-CMake-Python-Documentation.html)

[Foxy (EOL)](https://docs.ros.org/en/foxy/How-To-Guides/Ament-CMake-Python-Documentation.html)

[Eloquent (EOL)](https://docs.ros.org/en/eloquent/index.html)

[Dashing (EOL)](https://docs.ros.org/en/dashing/index.html)

[Crystal (EOL)](https://docs.ros.org/en/crystal/index.html)

In Development

[Rolling](https://docs.ros.org/en/rolling/How-To-Guides/Ament-CMake-Python-Documentation.html)
