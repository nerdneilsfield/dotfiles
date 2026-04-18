"""C++ ROS1 symbol extractor (libclang preferred, regex fallback)."""
from __future__ import annotations

import re
import sys
from pathlib import Path

_HAS_LIBCLANG = False
try:
    from clang import cindex  # type: ignore

    _HAS_LIBCLANG = True
except ImportError:
    cindex = None  # type: ignore[assignment]

_INCLUDE_RE = re.compile(r'^\s*#\s*include\s*[<"]([^">]+)[>"]')
_ROS_CALL_RE = re.compile(r"\b(ros::[A-Za-z_][A-Za-z_0-9:]*|ROS_(?:INFO|WARN|ERROR|DEBUG|FATAL)(?:_STREAM)?)\b")
_METHOD_CALL_RE = re.compile(r"\.(advertise|subscribe|advertiseService|serviceClient|getParam|setParam|param)\s*[(<]")


def _parse_libclang(path: str, source: str) -> list[dict]:
    assert cindex is not None
    symbols: list[dict] = []
    index = cindex.Index.create()
    tu = index.parse(
        path,
        args=["-x", "c++", "-std=c++17", "-fsyntax-only"],
        options=cindex.TranslationUnit.PARSE_DETAILED_PROCESSING_RECORD,
    )
    for node in tu.cursor.walk_preorder():
        try:
            loc = node.location
            if loc.file is None or Path(loc.file.name).resolve() != Path(path).resolve():
                continue
        except Exception:
            continue
        kind = node.kind
        if kind == cindex.CursorKind.INCLUSION_DIRECTIVE:
            symbols.append({"kind": "include", "name": node.displayname, "line": loc.line})
        elif kind in (
            cindex.CursorKind.FUNCTION_DECL,
            cindex.CursorKind.CXX_METHOD,
            cindex.CursorKind.CLASS_DECL,
            cindex.CursorKind.STRUCT_DECL,
        ):
            if node.is_definition():
                extent = node.extent
                symbols.append(
                    {
                        "kind": "def",
                        "name": node.spelling or node.displayname,
                        "line_range": [extent.start.line, extent.end.line],
                    }
                )
        elif kind == cindex.CursorKind.CALL_EXPR:
            spelling = node.spelling or node.displayname
            if spelling:
                symbols.append({"kind": "call", "name": spelling, "line": loc.line})
        elif kind == cindex.CursorKind.TYPE_REF:
            symbols.append({"kind": "type", "name": node.spelling, "line": loc.line})
        elif kind == cindex.CursorKind.MACRO_INSTANTIATION:
            symbols.append({"kind": "macro_use", "name": node.spelling, "line": loc.line})
    for line_no, line in enumerate(source.splitlines(), start=1):
        for match in _ROS_CALL_RE.finditer(line):
            if not any(s["name"] == match.group(1) and s.get("line") == line_no for s in symbols):
                kind = "macro_use" if match.group(1).startswith("ROS_") else "call"
                symbols.append({"kind": kind, "name": match.group(1), "line": line_no})
        for match in _METHOD_CALL_RE.finditer(line):
            symbols.append({"kind": "call", "name": f".{match.group(1)}", "line": line_no})
    return symbols


def _parse_regex(source: str) -> list[dict]:
    symbols: list[dict] = []
    brace_depth = 0
    def_starts: list[tuple[str, int]] = []
    for line_no, line in enumerate(source.splitlines(), start=1):
        include_match = _INCLUDE_RE.match(line)
        if include_match:
            symbols.append({"kind": "include", "name": include_match.group(1), "line": line_no})
        for match in _ROS_CALL_RE.finditer(line):
            kind = "macro_use" if match.group(1).startswith("ROS_") else "call"
            symbols.append({"kind": kind, "name": match.group(1), "line": line_no})
        for match in _METHOD_CALL_RE.finditer(line):
            symbols.append({"kind": "call", "name": f".{match.group(1)}", "line": line_no})
        stripped = line.strip()
        def_match = re.match(r"(?:class|struct|void|int|auto)\s+(\w+)\s*(?:\([^)]*\))?\s*\{?", stripped)
        if def_match and "{" in line:
            def_starts.append((def_match.group(1), line_no))
        brace_depth += line.count("{") - line.count("}")
        if brace_depth == 0 and def_starts and line.rstrip().endswith("}"):
            name, start = def_starts.pop(0)
            symbols.append({"kind": "def", "name": name, "line_range": [start, line_no], "approximate": True})
            def_starts.clear()
    return symbols


def parse(path: str) -> dict:
    source = Path(path).read_text(encoding="utf-8", errors="replace")
    if _HAS_LIBCLANG:
        try:
            symbols = _parse_libclang(path, source)
            return {
                "path": path,
                "language": "cpp",
                "parser": "libclang",
                "lines_total": len(source.splitlines()),
                "symbols": symbols,
            }
        except Exception as exc:
            print(f"[cpp_parser] libclang failed for {path}: {exc}; falling back to regex", file=sys.stderr)
    return {
        "path": path,
        "language": "cpp",
        "parser": "regex",
        "lines_total": len(source.splitlines()),
        "symbols": _parse_regex(source),
    }


if __name__ == "__main__":
    import tempfile

    fixture = """\
#include <ros/ros.h>
#include <sensor_msgs/LaserScan.h>

class MyNode {
public:
    MyNode() {
        ros::NodeHandle nh;
        pub_ = nh.advertise<sensor_msgs::LaserScan>("/scan", 10);
        sub_ = nh.subscribe("/cmd", 10, &MyNode::cb, this);
    }
    void cb(const sensor_msgs::LaserScan::ConstPtr& msg) {
        ROS_INFO("hi");
    }
private:
    ros::Publisher pub_;
    ros::Subscriber sub_;
};

int main(int argc, char** argv) {
    ros::init(argc, argv, "my_node");
    MyNode n;
    ros::spin();
    return 0;
}
"""

    with tempfile.TemporaryDirectory() as td:
        path = Path(td) / "main.cpp"
        path.write_text(fixture, encoding="utf-8")
        out = parse(str(path))
        kinds = {s["kind"] for s in out["symbols"]}
        names = {s["name"] for s in out["symbols"]}
        assert out["language"] == "cpp", out
        assert out["parser"] in ("libclang", "regex"), out
        assert "include" in kinds, kinds
        assert any(name.startswith("ros::") or name == "ROS_INFO" for name in names), names
        assert "ros::init" in names, names
        assert "ROS_INFO" in names, names
        assert any("advertise" in name for name in names), names
    print("cpp_parser.py OK")
    sys.exit(0)
