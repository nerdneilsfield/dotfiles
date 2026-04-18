"""ROS1 XML launch file parser via xml.etree; preserves $(arg), $(find), $(eval)."""
from __future__ import annotations

import xml.etree.ElementTree as ET


def _attrs(elem: ET.Element) -> dict:
    return {key: value for key, value in elem.attrib.items()}


def parse(path: str) -> dict:
    tree = ET.parse(path)
    root = tree.getroot()
    nodes: list[dict] = []
    includes: list[dict] = []
    args: list[dict] = []
    rosparams: list[dict] = []
    groups: list[dict] = []

    def walk(elem: ET.Element) -> None:
        for child in elem:
            tag = child.tag
            if tag == "node":
                params = [_attrs(p) for p in child.findall("param")]
                remaps = [_attrs(r) for r in child.findall("remap")]
                nodes.append({**_attrs(child), "params": params, "remaps": remaps})
            elif tag == "include":
                include_args = [_attrs(a) for a in child.findall("arg")]
                includes.append({**_attrs(child), "args": include_args})
            elif tag == "arg":
                args.append(_attrs(child))
            elif tag == "rosparam":
                rosparams.append(_attrs(child))
            elif tag == "group":
                groups.append(_attrs(child))
                walk(child)
            else:
                walk(child)

    walk(root)
    return {
        "path": path,
        "language": "roslaunch",
        "parser": "xml.etree",
        "nodes": nodes,
        "includes": includes,
        "args": args,
        "rosparams": rosparams,
        "groups": groups,
    }


if __name__ == "__main__":
    import sys
    import tempfile
    from pathlib import Path

    fixture = """<launch>
  <arg name="robot" default="r1"/>
  <node pkg="my_pkg" type="my_node" name="runner" output="screen">
    <param name="rate" value="10"/>
    <remap from="/scan" to="/$(arg robot)/scan"/>
  </node>
  <include file="$(find other_pkg)/launch/helper.launch">
    <arg name="x" value="1"/>
  </include>
  <group ns="ns1">
    <rosparam file="$(find my_pkg)/config/params.yaml" command="load"/>
  </group>
</launch>
"""
    with tempfile.TemporaryDirectory() as td:
        path = Path(td) / "demo.launch"
        path.write_text(fixture, encoding="utf-8")
        out = parse(str(path))
        assert len(out["nodes"]) == 1, out
        assert out["nodes"][0]["pkg"] == "my_pkg", out
        assert out["nodes"][0]["type"] == "my_node", out
        assert any("$(arg robot)" in remap["to"] for remap in out["nodes"][0]["remaps"]), out
        assert len(out["includes"]) == 1, out
        assert "$(find other_pkg)" in out["includes"][0]["file"], out
        assert any(param.get("command") == "load" for param in out["rosparams"]), out
    print("launch_parser.py OK")
    sys.exit(0)
