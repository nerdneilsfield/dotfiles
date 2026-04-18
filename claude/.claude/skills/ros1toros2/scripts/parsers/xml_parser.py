"""package.xml parser via stdlib xml.etree."""
from __future__ import annotations

import xml.etree.ElementTree as ET
from pathlib import Path


def parse(path: str) -> dict:
    tree = ET.parse(path)
    root = tree.getroot()
    fmt = root.attrib.get("format", "1")
    name = (root.findtext("name") or "").strip()

    def _children(tag: str) -> list[str]:
        return [(elem.text or "").strip() for elem in root.findall(tag) if (elem.text or "").strip()]

    build_type = None
    export = root.find("export")
    if export is not None:
        bt = export.find("build_type")
        if bt is not None and bt.text:
            build_type = bt.text.strip()
    if build_type is None and "catkin" in _children("buildtool_depend"):
        build_type = "catkin"
    return {
        "path": path,
        "language": "package_xml",
        "parser": "xml.etree",
        "name": name,
        "format": fmt,
        "buildtool_depends": _children("buildtool_depend"),
        "build_depends": _children("build_depend") + _children("depend"),
        "exec_depends": _children("exec_depend") + _children("depend"),
        "build_type": build_type,
    }


if __name__ == "__main__":
    import sys
    import tempfile

    fixture = """<?xml version="1.0"?>
<package format="2">
  <name>my_pkg</name>
  <version>0.0.1</version>
  <description>demo</description>
  <maintainer email="m@example.com">m</maintainer>
  <license>MIT</license>
  <buildtool_depend>catkin</buildtool_depend>
  <build_depend>roscpp</build_depend>
  <build_depend>std_msgs</build_depend>
  <exec_depend>roscpp</exec_depend>
  <exec_depend>std_msgs</exec_depend>
  <depend>message_runtime</depend>
  <export>
    <metapackage/>
  </export>
</package>
"""
    with tempfile.TemporaryDirectory() as td:
        path = Path(td) / "package.xml"
        path.write_text(fixture, encoding="utf-8")
        out = parse(str(path))
        assert out["name"] == "my_pkg", out
        assert out["format"] == "2", out
        assert "catkin" in out["buildtool_depends"], out
        assert "roscpp" in out["build_depends"], out
        assert "roscpp" in out["exec_depends"], out
        assert out["build_type"] == "catkin" or out["build_type"] is None, out
    print("xml_parser.py OK")
    sys.exit(0)
