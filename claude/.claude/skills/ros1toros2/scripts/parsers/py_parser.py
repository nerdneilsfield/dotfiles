"""Python ROS1 symbol extractor via stdlib ast (no fallback needed)."""
from __future__ import annotations

import ast
from pathlib import Path

_ROS_ROOTS = {"rospy", "roslib", "tf", "tf2_ros", "actionlib", "dynamic_reconfigure"}


def _attr_chain(node: ast.AST) -> str:
    parts: list[str] = []
    while isinstance(node, ast.Attribute):
        parts.append(node.attr)
        node = node.value
    if isinstance(node, ast.Name):
        parts.append(node.id)
    return ".".join(reversed(parts))


def parse(path: str) -> dict:
    source = Path(path).read_text(encoding="utf-8", errors="replace")
    tree = ast.parse(source, filename=path)
    symbols: list[dict] = []
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                root = alias.name.split(".")[0]
                if root in _ROS_ROOTS:
                    symbols.append({"kind": "import", "name": alias.name, "line": node.lineno})
        elif isinstance(node, ast.ImportFrom):
            module = node.module or ""
            root = module.split(".")[0]
            if root in _ROS_ROOTS or module.endswith(".msg") or module.endswith(".srv"):
                symbols.append({"kind": "import", "name": module, "line": node.lineno})
        elif isinstance(node, ast.Call):
            chain = _attr_chain(node.func)
            if chain and chain.split(".")[0] in _ROS_ROOTS:
                symbols.append({"kind": "call", "name": chain, "line": node.lineno})
        elif isinstance(node, ast.Attribute):
            chain = _attr_chain(node)
            if chain and chain.split(".")[0] in _ROS_ROOTS and "." in chain:
                symbols.append({"kind": "attribute", "name": chain, "line": node.lineno})
        elif isinstance(node, ast.FunctionDef):
            symbols.append(
                {
                    "kind": "def",
                    "name": node.name,
                    "line_range": [node.lineno, node.end_lineno or node.lineno],
                }
            )
        elif isinstance(node, ast.ClassDef):
            symbols.append(
                {
                    "kind": "def",
                    "name": node.name,
                    "line_range": [node.lineno, node.end_lineno or node.lineno],
                    "class": True,
                }
            )
    return {
        "path": path,
        "language": "python",
        "parser": "ast",
        "lines_total": len(source.splitlines()),
        "symbols": symbols,
    }


if __name__ == "__main__":
    import sys
    import tempfile

    fixture = """\
import rospy
from std_msgs.msg import String
import tf
import actionlib

class Talker:
    def __init__(self):
        rospy.init_node("talker")
        self.pub = rospy.Publisher("/chatter", String, queue_size=10)
        self.srv = rospy.Service("/ping", SomeSrv, self.cb)

    def cb(self, req):
        rospy.loginfo("got it")
        return None

def main():
    rospy.init_node("talker")
    rospy.spin()

if __name__ == "__main__":
    main()
"""
    with tempfile.TemporaryDirectory() as td:
        path = Path(td) / "talker.py"
        path.write_text(fixture, encoding="utf-8")
        out = parse(str(path))
        names = {s["name"] for s in out["symbols"]}
        kinds = {s["kind"] for s in out["symbols"]}
        assert out["language"] == "python", out
        assert out["parser"] == "ast", out
        assert "rospy" in names or "rospy (import)" in names, names
        assert any("init_node" in name for name in names), names
        assert any("Publisher" in name for name in names), names
        assert any("Service" in name for name in names), names
        assert "def" in kinds, kinds
    print("py_parser.py OK")
    sys.exit(0)
