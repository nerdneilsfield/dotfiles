# package.xml: ROS1 to ROS2

## Scope

This mapping covers `package.xml` migration from catkin-era ROS1 packages to ROS2 Jazzy package metadata. It focuses on package format, build tool selection, dependency renames, interface-generation dependencies, component-related exports, and testing metadata. It does not try to document every third-party package rename; use the package's ROS2 docs when a dependency is ecosystem-specific.

## Symbol Mapping Table

| ROS1 | ROS2 (Jazzy) | Notes / Pitfalls | API ref |
|---|---|---|---|
| `<package format="1">` | `<package format="3">` | Normalize old manifests straight to format 3 instead of stopping at format 2. | `api/docs-ros-org-jazzy-how-to-guides-migrating-from-ros1-package-xml.md` |
| `<package format="2">` | `<package format="3">` | ROS2 package manifests use format 3. | `api/docs-ros-org-jazzy-how-to-guides-migrating-from-ros1-package-xml.md` |
| `<buildtool_depend>catkin</buildtool_depend>` | `<buildtool_depend>ament_cmake</buildtool_depend>` | Use this for C++ packages and mixed C++/Python packages that still keep a `CMakeLists.txt`. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `<buildtool_depend>catkin</buildtool_depend>` | `<buildtool_depend>ament_python</buildtool_depend>` | Use this for pure-Python packages that drop `CMakeLists.txt` entirely. | `api/docs-ros-org-jazzy-how-to-guides-migrating-from-ros1-package-xml.md` |
| `<depend>roscpp</depend>` | `<depend>rclcpp</depend>` | Straight client-library rename. | `api/docs-ros-org-jazzy-api-rclcpp-index.md` |
| `<depend>rospy</depend>` | `<depend>rclpy</depend>` | Straight client-library rename. | `api/docs-ros2-org-api-rclpy-index.md` |
| `<build_depend>message_generation</build_depend>` | `<build_depend>rosidl_default_generators</build_depend>` | Needed only in packages that define `.msg`, `.srv`, or `.action` files. | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| `<exec_depend>message_runtime</exec_depend>` | `<exec_depend>rosidl_default_runtime</exec_depend>` | Runtime half of the ROS2 interface toolchain. | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| *(no ROS1 equivalent)* | `<member_of_group>rosidl_interface_packages</member_of_group>` | Required for interface packages in ROS2. | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| `<depend>tf</depend>` | `<depend>tf2_ros</depend>` | ROS1 `tf` does not come forward unchanged; migrate to tf2 APIs. | `api/docs-ros-org-jazzy-tutorials-tf2.md` |
| `<depend>tf2_ros</depend>` | `<depend>tf2_ros</depend>` | Keep the dependency, but update source code to ROS2 headers and node APIs. | `api/docs-ros-org-jazzy-tutorials-tf2.md` |
| `<depend>actionlib</depend>` | `<depend>rclcpp_action</depend>` | C++ action clients and servers depend on `rclcpp_action`. | `api/docs-ros-org-jazzy-tutorials-writing-an-action-server-and-client-cpp.md` |
| `<depend>actionlib</depend>` | `<depend>rclpy</depend>` plus the action interface package | Python action support lives under `rclpy.action`; there is no separate `rclpy_action` package. | `api/docs-ros-org-jazzy-tutorials-writing-an-action-server-and-client-python.md` |
| `<depend>nodelet</depend>` | `<depend>rclcpp_components</depend>` | Nodelets become components. Keep `pluginlib` if the package already exports plugins. | `api/docs-ros-org-jazzy-tutorials-composition.md` |
| `<export><build_type>catkin</build_type></export>` | `<export><build_type>ament_cmake</build_type></export>` | Required for ROS2 CMake packages. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `<export><build_type>catkin</build_type></export>` | `<export><build_type>ament_python</build_type></export>` | Required for ROS2 pure-Python packages. | `api/docs-ros-org-jazzy-how-to-guides-migrating-from-ros1-package-xml.md` |
| `<run_depend>foo</run_depend>` | `<exec_depend>foo</exec_depend>` or `<build_export_depend>foo</build_export_depend>` | Split old `run_depend` usage by actual meaning; do not carry the tag forward. | `api/docs-ros-org-jazzy-how-to-guides-migrating-from-ros1-package-xml.md` |
| `<test_depend>rostest</test_depend>` | `<test_depend>ament_lint_auto</test_depend>` and, if needed, `launch_testing` deps | `rostest` does not port 1:1. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `<export><nodelet plugin="${prefix}/nodelet_plugins.xml"/></export>` | *(remove from `package.xml`; register components in code/CMake instead)* | ROS2 component discovery is driven by `rclcpp_components` registration and plugin descriptions, not a package.xml `nodelet` export. | `api/docs-ros-org-jazzy-tutorials-composition.md` |
| `catkin` package that mixes C++ and Python helpers | `ament_cmake` + `ament_cmake_python` support | The package stays CMake-driven; add the Python helper package only when Python must be installed from the CMake project. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-python-documentation.md` |

## Covered Symbols

- `<package format="1">`
- `<package format="2">`
- `catkin`
- `roscpp`
- `rospy`
- `message_generation`
- `message_runtime`
- `tf`
- `tf2_ros`
- `actionlib`
- `actionlib_msgs`
- `nodelet`
- `pluginlib`
- `<run_depend>`
- `<buildtool_depend>`
- `<depend>`
- `<build_depend>`
- `<exec_depend>`
- `<build_export_depend>`
- `<test_depend>`
- `<member_of_group>`
- `<export><build_type>catkin</build_type></export>`
- `<export><nodelet plugin="${prefix}/nodelet_plugins.xml"/></export>`
- `rostest`

## Structural Translation Patterns

- **Catkin C++ package -> ament_cmake package**
  Recognition cues: package has `CMakeLists.txt`, `src/*.cpp`, or public headers under `include/`.
  Before: `<buildtool_depend>catkin</buildtool_depend>`
  After: `<buildtool_depend>ament_cmake</buildtool_depend>` and `<export><build_type>ament_cmake</build_type></export>`.

- **Catkin Python package -> ament_python package**
  Recognition cues: ROS1 package uses `rospy`, `setup.py`, and CMake only to install scripts.
  Before: catkin manifest plus `rospy`.
  After: `<buildtool_depend>ament_python</buildtool_depend>`, `<depend>rclpy</depend>`, and `<export><build_type>ament_python</build_type></export>`.

- **Mixed C++/Python package -> ament_cmake package with Python install helpers**
  Recognition cues: package builds C++ targets but also ships importable Python modules or helper scripts.
  Before: one catkin manifest for both worlds.
  After: keep `ament_cmake` as the build type and add `ament_cmake_python` support in CMake/package metadata when Python modules must still install from the same package.

- **Interface-generating package -> dedicated ROS2 interface package**
  Recognition cues: manifest carries `message_generation` / `message_runtime` and the package owns `.msg`, `.srv`, or `.action` files.
  Before: ROS1 message-generation deps in the same package as the code.
  After: add `rosidl_default_generators`, `rosidl_default_runtime`, and `rosidl_interface_packages`; if the package also needs `ament_cmake_python`, consider splitting interfaces into their own package because `rosidl_generate_interfaces()` and `ament_python_install_package()` do not coexist well in one CMake project.

## Surface-Preserving Rules

The manifest does not itself define the runtime surface, but it gates whether the migrated package can build the same nodes, interfaces, and plugins. Preserve the package name, keep every dependency required to reproduce the ROS1 runtime surface, and do not silently drop interface-generation or plugin-related dependencies. Switching from ROS1 notation to ROS2 notation inside the manifest is structural, not a surface change. A real surface change only occurs if the migrated package loses an executable, interface package, component, or other externally consumed capability; those changes must be declared in `plan-meta.json`.

## Edge Cases

- **Metapackages:** keep the package lightweight, declare only the needed `exec_depend` children, and still export the correct ROS2 build type.
- **Pure Python packages:** the clean ROS2 target is usually `ament_python`, which removes the need for `CMakeLists.txt`.
- **Mixed packages with generated interfaces and Python modules:** ROS2 docs warn that `rosidl_generate_interfaces()` and `ament_python_install_package()` should not live in the same CMake project; split interfaces into a dedicated package if needed.
- **Plugin migration:** `nodelet` package.xml exports disappear; the runtime equivalent comes from `rclcpp_components` registration plus plugin description installation handled in source/CMake.
- **Legacy `<run_depend>` tags:** do not cargo-cult them into format 3; decide whether the dependency is runtime-only (`exec_depend`) or also needed by downstream builds (`build_export_depend`).

## Banned Symbols (Verification Hooks)

- `<package format="1">`
- `<package format="2">`
- `<buildtool_depend>catkin</buildtool_depend>`
- `<depend>roscpp</depend>`
- `<depend>rospy</depend>`
- `<build_depend>message_generation</build_depend>`
- `<exec_depend>message_runtime</exec_depend>`
- `<depend>tf</depend>`
- `<depend>actionlib</depend>`
- `<depend>nodelet</depend>`
- `<run_depend>`
- `<export><build_type>catkin</build_type></export>`
- `<export><nodelet plugin="${prefix}/nodelet_plugins.xml"/></export>`
