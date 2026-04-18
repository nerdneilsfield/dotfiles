---
source_url: https://docs.ros.org/en/jazzy/How-To-Guides/Ament-CMake-Python-Documentation.html
fetched_at: 2026-04-18T00:00:00Z
---

# ament_cmake_python user documentation — ROS 2 Documentation: Jazzy  documentation

ament_cmake_python user documentation — ROS 2 Documentation: Jazzy  documentation

-
- How-to Guides
- ament_cmake_python user documentation
-  Edit on GitHub


You're reading the documentation for an older, but still supported, version of ROS 2.
For information on the latest version, please have a look at Kilted.



ament_cmake_python user documentation

`ament_cmake_python` is a package that provides CMake functions for packages of the `ament_cmake` build type that contain Python code.
See the ament_cmake user documentation for more information.

Note

Pure Python packages should use the `ament_python` build type in most cases.
To create an `ament_python` package, see Creating your first ROS 2 package.
`ament_cmake_python` should only be used in cases where that is not possible, like when mixing C/C++ and Python code.

Basics

Basic project outline

The outline of a package called “my_project” with the `ament_cmake` build type that uses `ament_cmake_python` looks like:

```
.
└── my_project
├── CMakeLists.txt
├── package.xml
└── my_project
├── __init__.py
└── my_script.py

```

The `__init__.py` file can be empty, but it is needed to make Python treat the directory containing it as a package.
There can also be a `src` or `include` directory alongside the `CMakeLists.txt` which holds C/C++ code.

Using ament_cmake_python

The package must declare a dependency on `ament_cmake_python` in its `package.xml`.

```
<buildtool_depend>ament_cmake_python</buildtool_depend>

```

The `CMakeLists.txt` should contain:

```
find_package(ament_cmake_python REQUIRED)
# ...
ament_python_install_package(${PROJECT_NAME})

```

The argument to `ament_python_install_package()` is the name of the directory alongside the `CMakeLists.txt` that contains the Python file.
In this case, it is `my_project`, or `${PROJECT_NAME}`.

Warning

Calling `rosidl_generate_interfaces` and `ament_python_install_package` in the same CMake project does not work.
See this Github issue for more info.
It is best practice to instead separate out the message generation into a separate package.

Then, another Python package that correctly depends on `my_project` can use it as a normal Python module:

```
from my_project.my_script import my_function

```

Assuming `my_script.py` contains a function called `my_function()`.

Using ament_cmake_pytest

The package `ament_cmake_pytest` is used to make tests discoverable to `cmake`.
The package must declare a test dependency on `ament_cmake_pytest` in its `package.xml`.

```
<test_depend>ament_cmake_pytest</test_depend>

```

Say the package has a file structure like below, with tests in the `tests` folder.

```
.
├── CMakeLists.txt
├── my_project
│   └── my_script.py
├── package.xml
└── tests
├── test_a.py
└── test_b.py

```

The `CMakeLists.txt` should contain:

```
if(BUILD_TESTING)
find_package(ament_cmake_pytest REQUIRED)
set(_pytest_tests
tests/test_a.py
tests/test_b.py
# Add other test files here
)
foreach(_test_path ${_pytest_tests})
get_filename_component(_test_name ${_test_path} NAME_WE)
ament_add_pytest_test(${_test_name} ${_test_path}
APPEND_ENV PYTHONPATH=${CMAKE_CURRENT_BINARY_DIR}
TIMEOUT 60
WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)
endforeach()
endif()

```

Compared to the usage of ament_python, which supports automatic test discovery, ament_cmake_pytest must be called with the path to each test file.
The timeout can be reduced as needed.

Now, you can invoke your tests with the standard colcon testing commands.

PreviousNext

© Copyright 2026, Open Robotics.

Built with Sphinx using a
theme
provided by Read the Docs.


Other Versions
v: jazzy

ReleasesKilted (latest)JazzyIron (EOL)HumbleGalactic (EOL)Foxy (EOL)Eloquent (EOL)Dashing (EOL)Crystal (EOL)In DevelopmentRolling
