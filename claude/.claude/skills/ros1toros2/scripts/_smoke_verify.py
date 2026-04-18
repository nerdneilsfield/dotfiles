"""Smoke test for verify_ros2.py: residual scan + surface diff + plan-meta checks."""
from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import verify_ros2

POST_PKG_XML = """<?xml version="1.0"?>
<package format="3">
  <name>hello_pkg</name>
  <version>0.0.1</version>
  <description>demo</description>
  <maintainer email="m@example.com">m</maintainer>
  <license>MIT</license>
  <buildtool_depend>ament_cmake</buildtool_depend>
  <depend>rclcpp</depend>
  <export><build_type>ament_cmake</build_type></export>
</package>
"""
POST_CPP_CLEAN = """#include <rclcpp/rclcpp.hpp>
class Hello : public rclcpp::Node {
public:
  Hello() : Node("hello") {
    pub_ = create_publisher<std_msgs::msg::String>("/hello", 10);
    renamed_ = create_publisher<std_msgs::msg::String>("/hello_new", 10);
  }
private:
  rclcpp::Publisher<std_msgs::msg::String>::SharedPtr pub_;
  rclcpp::Publisher<std_msgs::msg::String>::SharedPtr renamed_;
};
int main(int argc, char** argv) {
    rclcpp::init(argc, argv);
    RCLCPP_INFO(rclcpp::get_logger("hello"), "hi");
    rclcpp::spin(std::make_shared<Hello>());
    return 0;
}
"""
POST_CPP_DIRTY = POST_CPP_CLEAN + "// stray: ros::init was here\n"

PRE_INVENTORY = {
    "source_ros_distro": "noetic",
    "target_ros_distro": "jazzy",
    "packages": [
        {
            "name": "hello_pkg",
            "already_ros2": False,
            "interface_surface": {
                "published_topics": [
                    {"name": "/hello", "type": "std_msgs/String", "source": "pre"},
                    {"name": "/hello_old", "type": "std_msgs/String", "source": "pre"},
                    {"name": "/dropped", "type": "std_msgs/String", "source": "pre"},
                ],
                "subscribed_topics": [],
                "services_provided": [],
                "services_called": [],
                "actions_provided": [],
                "actions_called": [],
                "params_declared": [],
                "params_read": [],
            },
        }
    ],
}


def _write_pkg(root: Path, body: str) -> None:
    (root / "hello_pkg" / "src").mkdir(parents=True)
    (root / "hello_pkg" / "package.xml").write_text(POST_PKG_XML, encoding="utf-8")
    (root / "hello_pkg" / "src" / "hello.cpp").write_text(body, encoding="utf-8")


def main() -> int:
    with tempfile.TemporaryDirectory() as td:
        workspace = Path(td) / "ws"
        workspace.mkdir()
        _write_pkg(workspace, POST_CPP_CLEAN)
        inventory_path = Path(td) / "inv.json"
        inventory_path.write_text(json.dumps(PRE_INVENTORY), encoding="utf-8")

        plan_path = Path(td) / "plan-meta.json"
        out = Path(td) / "report.json"

        plan_path.write_text(
            json.dumps(
                {
                    "tasks": [],
                    "surface_changes": [
                        {
                            "package": "hello_pkg",
                            "kind": "topic_rename",
                            "from": "/hello_old",
                            "to": "/hello_new",
                            "reason": "consolidation",
                        }
                    ],
                }
            ),
            encoding="utf-8",
        )
        rc = verify_ros2.main(
            [
                "--workspace",
                str(workspace),
                "--inventory",
                str(inventory_path),
                "--plan-meta",
                str(plan_path),
                "--output",
                str(out),
                "--skip-build",
                "--skip-lint",
            ]
        )
        report = json.loads(out.read_text(encoding="utf-8"))
        assert rc == 1 and not report["passed"], report
        undeclared_keys = {item["key"] for item in report["surface_diff"]["undeclared"]}
        missing_keys = {item["key"] for item in report["surface_diff"]["missing"]}
        assert "/dropped" in undeclared_keys, report["surface_diff"]
        assert "/hello_old" in missing_keys, report["surface_diff"]
        assert "/hello_old" not in undeclared_keys, report["surface_diff"]
        assert "/hello" not in missing_keys, report["surface_diff"]

        plan_path.write_text(
            json.dumps(
                {
                    "tasks": [],
                    "surface_changes": [
                        {
                            "package": "hello_pkg",
                            "kind": "topic_rename",
                            "from": "/hello_old",
                            "to": "/hello_new",
                            "reason": "consolidation",
                        },
                        {
                            "package": "hello_pkg",
                            "kind": "topic_removed",
                            "name": "/dropped",
                            "reason": "obsolete",
                        },
                    ],
                }
            ),
            encoding="utf-8",
        )
        rc2 = verify_ros2.main(
            [
                "--workspace",
                str(workspace),
                "--inventory",
                str(inventory_path),
                "--plan-meta",
                str(plan_path),
                "--output",
                str(out),
                "--skip-build",
                "--skip-lint",
            ]
        )
        report2 = json.loads(out.read_text(encoding="utf-8"))
        assert rc2 == 0 and report2["passed"], report2
        assert report2["residuals"] == [], report2["residuals"]

        (workspace / "hello_pkg" / "src" / "hello.cpp").write_text(POST_CPP_DIRTY, encoding="utf-8")
        rc3 = verify_ros2.main(
            [
                "--workspace",
                str(workspace),
                "--inventory",
                str(inventory_path),
                "--plan-meta",
                str(plan_path),
                "--output",
                str(out),
                "--skip-build",
                "--skip-lint",
            ]
        )
        report3 = json.loads(out.read_text(encoding="utf-8"))
        assert rc3 == 1 and not report3["passed"], report3
        assert any("ros::init" in hit["pattern"] for hit in report3["residuals"]), report3["residuals"]
    print("_smoke_verify.py OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
