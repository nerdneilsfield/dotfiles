"""CMakeLists.txt parser (parse_cmake preferred, regex fallback)."""
from __future__ import annotations

import re
import sys
from pathlib import Path

_HAS_PARSE_CMAKE = False
try:
    from parse_cmake import parsing as _pc_parsing  # type: ignore

    _HAS_PARSE_CMAKE = True
except ImportError:
    _pc_parsing = None  # type: ignore[assignment]


def _gather_find_package(body: str) -> list[str]:
    components: list[str] = []
    for match in re.finditer(r"find_package\s*\(([^)]*)\)", body, re.IGNORECASE | re.DOTALL):
        args = match.group(1).split()
        if not args:
            continue
        components.append(args[0])
        if "COMPONENTS" in args:
            index = args.index("COMPONENTS")
            components.extend(args[index + 1 :])
    return components


def _gather_executables(body: str) -> list[dict]:
    executables: list[dict] = []
    for match in re.finditer(r"add_executable\s*\(([^)]*)\)", body, re.IGNORECASE | re.DOTALL):
        args = match.group(1).split()
        if args:
            executables.append({"name": args[0], "sources": args[1:]})
    return executables


def _gather_libraries(body: str) -> list[dict]:
    libraries: list[dict] = []
    for match in re.finditer(r"add_library\s*\(([^)]*)\)", body, re.IGNORECASE | re.DOTALL):
        args = match.group(1).split()
        if args:
            libraries.append({"name": args[0], "sources": args[1:]})
    return libraries


def parse(path: str) -> dict:
    source = Path(path).read_text(encoding="utf-8", errors="replace")
    parser_name = "regex"
    if _HAS_PARSE_CMAKE:
        try:
            assert _pc_parsing is not None
            _pc_parsing.parse(source)
            parser_name = "parse_cmake"
        except Exception as exc:
            print(f"[cmake_parser] parse_cmake failed for {path}: {exc}; falling back", file=sys.stderr)
    components = _gather_find_package(source)
    return {
        "path": path,
        "language": "cmake",
        "parser": parser_name,
        "lines_total": len(source.splitlines()),
        "find_package_components": components,
        "catkin_package_calls": len(re.findall(r"\bcatkin_package\s*\(", source)),
        "message_gen": bool(
            re.search(r"\badd_message_files\s*\(", source) or re.search(r"\bgenerate_messages\s*\(", source)
        ),
        "executables": _gather_executables(source),
        "libraries": _gather_libraries(source),
        "installs": len(re.findall(r"\binstall\s*\(", source)),
    }


if __name__ == "__main__":
    import tempfile

    fixture = """\
cmake_minimum_required(VERSION 3.0.2)
project(my_pkg)
find_package(catkin REQUIRED COMPONENTS
  roscpp
  std_msgs
  message_generation
)
add_message_files(
  FILES Foo.msg Bar.msg
)
generate_messages(
  DEPENDENCIES std_msgs
)
catkin_package(
  CATKIN_DEPENDS roscpp std_msgs message_runtime
)
add_executable(my_node src/my_node.cpp)
target_link_libraries(my_node ${catkin_LIBRARIES})
install(TARGETS my_node RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION})
"""
    with tempfile.TemporaryDirectory() as td:
        path = Path(td) / "CMakeLists.txt"
        path.write_text(fixture, encoding="utf-8")
        out = parse(str(path))
        assert out["parser"] in ("parse_cmake", "regex"), out
        assert "catkin" in out["find_package_components"] or "roscpp" in out["find_package_components"], out
        assert out["catkin_package_calls"] == 1, out
        assert out["message_gen"] is True, out
        assert any(exe["name"] == "my_node" for exe in out["executables"]), out
    print("cmake_parser.py OK")
    sys.exit(0)
