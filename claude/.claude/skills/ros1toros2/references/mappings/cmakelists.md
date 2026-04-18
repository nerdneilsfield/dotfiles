# CMakeLists.txt: ROS1 to ROS2

## Scope

This mapping covers `CMakeLists.txt` migration from catkin to `ament_cmake` in ROS2 Jazzy. It includes dependency discovery, target wiring, install rules, interface generation, export macros, testing hooks, and mixed C++/Python packages that still keep a CMake build. It does not cover pure `ament_python` packages that intentionally delete `CMakeLists.txt`.

## Symbol Mapping Table

| ROS1 | ROS2 (Jazzy) | Notes / Pitfalls | API ref |
|---|---|---|---|
| `cmake_minimum_required(VERSION 2.8.3)` | `cmake_minimum_required(VERSION 3.8)` or higher | Jazzy examples use 3.8; keep a higher minimum if the package already needs it. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `find_package(catkin REQUIRED COMPONENTS roscpp std_msgs ...)` | `find_package(ament_cmake REQUIRED)` plus one `find_package(<pkg> REQUIRED)` per dependency | Drop the `catkin` aggregate. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `catkin_package()` | `ament_package()` | `ament_package()` must appear exactly once and should be last. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `catkin_package(INCLUDE_DIRS include LIBRARIES mylib CATKIN_DEPENDS a b)` | `ament_export_include_directories(include)` + `ament_export_libraries(mylib)` + `ament_export_dependencies(a b)` | Split the one catkin macro into explicit exports. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `include_directories(include ${catkin_INCLUDE_DIRS})` | `target_include_directories(<target> PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>)` | Prefer target-local include dirs over directory-global state. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `target_link_libraries(node ${catkin_LIBRARIES})` | `ament_target_dependencies(node rclcpp std_msgs ...)` | Express direct ROS2 dependencies explicitly. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `add_executable(node src/node.cpp)` + `${catkin_EXPORTED_TARGETS}` dependency wiring | `add_executable(node src/node.cpp)` + `ament_target_dependencies(...)` | ROS2 target wiring is usually simpler; do not copy `${catkin_EXPORTED_TARGETS}` patterns blindly. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `add_library(mylib src/a.cpp)` + `${catkin_LIBRARIES}` | `add_library(mylib src/a.cpp)` + `ament_target_dependencies(mylib ...)` | Local libraries still use `target_link_libraries()` for non-ROS libs. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `install(TARGETS node RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION})` | `install(TARGETS node DESTINATION lib/${PROJECT_NAME})` | ROS2 nodes install into `lib/${PROJECT_NAME}`. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `install(DIRECTORY launch DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION})` | `install(DIRECTORY launch DESTINATION share/${PROJECT_NAME})` | Same pattern applies to `config`, `rviz`, and plugin description files. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `install(DIRECTORY include/${PROJECT_NAME}/ DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION})` | `install(DIRECTORY include/ DESTINATION include)` | Pair this with exported include directories. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `catkin_install_python(PROGRAMS scripts/foo.py DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION})` | `install(PROGRAMS scripts/foo.py DESTINATION lib/${PROJECT_NAME})` | This is for executable scripts, not importable modules. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `catkin_python_setup()` | `find_package(ament_cmake_python REQUIRED)` + `ament_python_install_package(${PROJECT_NAME})` | Use only when the package remains CMake-driven. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-python-documentation.md` |
| `add_message_files(FILES Foo.msg)` | `rosidl_generate_interfaces(${PROJECT_NAME} "msg/Foo.msg")` | ROS2 collapses message/service/action generation into one macro. | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| `add_service_files(FILES Bar.srv)` | `rosidl_generate_interfaces(${PROJECT_NAME} "srv/Bar.srv")` | Same macro, different path. | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| `add_action_files(FILES DoThing.action)` | `rosidl_generate_interfaces(${PROJECT_NAME} "action/DoThing.action")` | Same macro, different path. | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| `generate_messages(DEPENDENCIES std_msgs)` | `rosidl_generate_interfaces(... DEPENDENCIES std_msgs)` | Merge dependencies into the `rosidl_generate_interfaces()` call. | `api/docs-ros-org-jazzy-how-to-guides-interfaces-overview.md` |
| `catkin_add_gtest(test_name test/test.cpp)` | `ament_add_gtest(test_name test/test.cpp)` | ROS2 testing macros live under `ament_cmake_gtest`. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `catkin_add_nosetests(test)` | `ament_add_pytest_test(test test.py)` | Use ROS2 Python test macros instead of nosetests. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-python-documentation.md` |
| *(no explicit lint block)* | `if(BUILD_TESTING) find_package(ament_lint_auto REQUIRED) ament_lint_auto_find_test_dependencies() endif()` | This is the baseline ROS2 lint harness. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |
| `catkin_package()` handling exported local library targets implicitly | `ament_export_targets(<target>Targets HAS_LIBRARY_TARGET)` | Needed when downstream packages should link against your exported library target. | `api/docs-ros-org-jazzy-how-to-guides-ament-cmake-documentation.md` |

## Covered Symbols

- `catkin`
- `catkin_package`
- `${catkin_INCLUDE_DIRS}`
- `${catkin_LIBRARIES}`
- `${catkin_EXPORTED_TARGETS}`
- `CATKIN_PACKAGE_BIN_DESTINATION`
- `CATKIN_PACKAGE_SHARE_DESTINATION`
- `CATKIN_PACKAGE_INCLUDE_DESTINATION`
- `CATKIN_DEVEL_PREFIX`
- `catkin_install_python`
- `catkin_python_setup`
- `add_message_files`
- `add_service_files`
- `add_action_files`
- `generate_messages`
- `add_dependencies`
- `catkin_add_gtest`
- `catkin_add_nosetests`
- `install(TARGETS ... ${CATKIN_PACKAGE_BIN_DESTINATION})`
- `install(DIRECTORY launch DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION})`

## Structural Translation Patterns

- **Typical catkin package -> target-oriented ament_cmake package**
  Recognition cues: `find_package(catkin ...)`, `catkin_package()`, directory-global `include_directories()`, and `${catkin_LIBRARIES}` in `target_link_libraries()`.
  Before: catkin collects metadata in one macro.
  After: `find_package(ament_cmake REQUIRED)`, explicit `find_package()` calls per dependency, target-local include directories, `ament_target_dependencies()`, explicit exports, and a final `ament_package()`.

- **Message-generating package -> `rosidl_generate_interfaces()` package**
  Recognition cues: any of `add_message_files`, `add_service_files`, `add_action_files`, or `generate_messages`.
  Before: multiple catkin macros plus exported targets.
  After: one `rosidl_generate_interfaces()` block plus interface dependencies in `package.xml`.

- **Mixed C++/Python package -> `ament_cmake` + `ament_cmake_python`**
  Recognition cues: C++ targets plus importable Python modules or helper packages installed from the same tree.
  Before: `catkin_python_setup()` and script install helpers in catkin.
  After: keep `ament_cmake`, add `find_package(ament_cmake_python REQUIRED)`, use `ament_python_install_package()`, and keep executable scripts on `install(PROGRAMS ...)`.

## Surface-Preserving Rules

Build files are structural, but they determine whether the migrated workspace still produces the same runtime artifacts. Preserve executable target names, installed launch/config paths, generated interface package names, and exported library targets unless `plan-meta.json` explicitly declares a surface change. Switching from catkin macros to ament macros is not itself a surface change. Renaming an executable, removing an install rule, or changing which interfaces a package generates is a surface change because downstream launch files and packages observe it.

## Edge Cases

- **Minimum CMake version:** ROS2 Jazzy docs show `3.8`; if the existing workspace already uses a newer requirement, keep the newer value instead of downgrading it.
- **Header-only libraries:** export them with `ament_export_targets()` or `ament_export_include_directories()` even when there is no compiled artifact.
- **Packages that both generate interfaces and install Python modules:** ROS2 docs warn that `rosidl_generate_interfaces()` and `ament_python_install_package()` do not work in the same CMake project; split interfaces into a dedicated package if needed.
- **Tests migrated from rosunit/rostest:** swap to `ament_add_gtest`, `ament_add_pytest_test`, or `launch_testing` instead of carrying catkin test macros over.
- **Local non-ROS libraries:** keep `target_link_libraries()` for those; `ament_target_dependencies()` is for ROS package dependencies, not a blanket replacement for all linking.

## Banned Symbols (Verification Hooks)

- `find_package(catkin`
- `catkin_package`
- `${catkin_INCLUDE_DIRS}`
- `${catkin_LIBRARIES}`
- `${catkin_EXPORTED_TARGETS}`
- `CATKIN_PACKAGE_BIN_DESTINATION`
- `CATKIN_PACKAGE_SHARE_DESTINATION`
- `CATKIN_PACKAGE_INCLUDE_DESTINATION`
- `CATKIN_DEVEL_PREFIX`
- `catkin_install_python`
- `catkin_python_setup`
- `add_message_files`
- `add_service_files`
- `add_action_files`
- `generate_messages`
- `catkin_add_gtest`
- `catkin_add_nosetests`
