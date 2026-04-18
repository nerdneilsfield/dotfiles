"""Smoke test for scan_ros1.py against a hand-crafted fake ROS1 workspace."""
from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import scan_ros1

PACKAGE_XML = """<?xml version="1.0"?>
<package format="2">
  <name>hello_pkg</name>
  <version>0.0.1</version>
  <description>demo</description>
  <maintainer email="m@example.com">m</maintainer>
  <license>MIT</license>
  <buildtool_depend>catkin</buildtool_depend>
  <build_depend>roscpp</build_depend>
  <exec_depend>roscpp</exec_depend>
</package>
"""
CMAKE = """cmake_minimum_required(VERSION 3.0.2)
project(hello_pkg)
find_package(catkin REQUIRED COMPONENTS roscpp)
catkin_package()
add_executable(hello src/hello.cpp)
target_link_libraries(hello ${catkin_LIBRARIES})
"""
CPP = """#include <ros/ros.h>
int main(int argc, char** argv) {
    ros::init(argc, argv, "hello");
    ros::NodeHandle nh;
    ros::Publisher p = nh.advertise<std_msgs::String>("/hello", 10);
    ROS_INFO("hi");
    ros::spin();
    return 0;
}
"""
LAUNCH = """<launch>
  <node pkg="hello_pkg" type="hello" name="hello_node"/>
</launch>
"""


def main() -> int:
    with tempfile.TemporaryDirectory() as td:
        workspace = Path(td) / "ws" / "src"
        pkg = workspace / "hello_pkg"
        (pkg / "src").mkdir(parents=True)
        (pkg / "launch").mkdir()
        (pkg / "package.xml").write_text(PACKAGE_XML, encoding="utf-8")
        (pkg / "CMakeLists.txt").write_text(CMAKE, encoding="utf-8")
        (pkg / "src" / "hello.cpp").write_text(CPP, encoding="utf-8")
        (pkg / "launch" / "hello.launch").write_text(LAUNCH, encoding="utf-8")

        out_json = Path(td) / "inventory.json"
        rc = scan_ros1.main(["--workspace", str(workspace), "--output", str(out_json)])
        assert rc == 0, rc
        inventory = json.loads(out_json.read_text(encoding="utf-8"))
        assert len(inventory["packages"]) == 1, inventory
        pkg_meta = inventory["packages"][0]
        assert pkg_meta["name"] == "hello_pkg", pkg_meta
        assert pkg_meta["already_ros2"] is False, pkg_meta
        assert any("hello.cpp" in parsed["path"] for parsed in pkg_meta["files"]), pkg_meta["files"]
        pubs = pkg_meta["interface_surface"]["published_topics"]
        assert pubs, pkg_meta["interface_surface"]
        assert any(entry.get("name") == "/hello" for entry in pubs), pubs
        assert any(entry.get("type") and "String" in entry["type"] for entry in pubs), pubs
        assert "hello_pkg" in inventory["dependency_graph"], inventory["dependency_graph"]
    print("_smoke_scan.py OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
