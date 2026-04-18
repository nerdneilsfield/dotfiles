#!/usr/bin/env python3
"""scan_ros1.py — walk a ROS1 workspace, produce inventory.json."""
from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
SKILL_ROOT = HERE.parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

from _common import ROS_SYMBOL_PATTERN, load_covered_index
from parsers import cmake_parser, cpp_parser, launch_parser, py_parser, xml_parser

CPP_EXTS = {".cpp", ".cc", ".cxx", ".h", ".hpp", ".hh"}
PY_EXTS = {".py"}

_CPP_PUB_RE = re.compile(r'\.advertise\s*<\s*([A-Za-z0-9_:]+)\s*>\s*\(\s*"([^"]+)"')
_CPP_SUB_RE = re.compile(r'\.subscribe\s*(?:<\s*([A-Za-z0-9_:]+)\s*>)?\s*\(\s*"([^"]+)"')
_CPP_SRV_PROV_RE = re.compile(r'\.advertiseService\s*(?:<\s*([A-Za-z0-9_:]+)\s*>)?\s*\(\s*"([^"]+)"')
_CPP_SRV_CALL_RE = re.compile(r'\.serviceClient\s*<\s*([A-Za-z0-9_:]+)\s*>\s*\(\s*"([^"]+)"')
_PY_PUB_RE = re.compile(r'rospy\.Publisher\s*\(\s*["\']([^"\']+)["\']\s*,\s*([A-Za-z0-9_.]+)')
_PY_SUB_RE = re.compile(r'rospy\.Subscriber\s*\(\s*["\']([^"\']+)["\']\s*,\s*([A-Za-z0-9_.]+)')
_PY_SRV_PROV_RE = re.compile(r'rospy\.Service\s*\(\s*["\']([^"\']+)["\']\s*,\s*([A-Za-z0-9_.]+)')
_PY_SRV_CALL_RE = re.compile(r'rospy\.ServiceProxy\s*\(\s*["\']([^"\']+)["\']\s*,\s*([A-Za-z0-9_.]+)')
_PY_PARAM_READ_RE = re.compile(r'rospy\.get_param\s*\(\s*["\']([^"\']+)["\']')
_PY_PARAM_SET_RE = re.compile(r'rospy\.set_param\s*\(\s*["\']([^"\']+)["\']')


def _find_packages(workspace: Path) -> list[Path]:
    return sorted(p.parent for p in workspace.rglob("package.xml"))


def _pkg_already_ros2(pkg_meta: dict) -> bool:
    build_type = (pkg_meta.get("build_type") or "").lower()
    return build_type.startswith("ament")


def _scan_package(pkg_dir: Path) -> dict:
    pkg_xml = pkg_dir / "package.xml"
    pkg_meta = xml_parser.parse(str(pkg_xml))
    if _pkg_already_ros2(pkg_meta):
        return {
            "name": pkg_meta.get("name") or pkg_dir.name,
            "path": str(pkg_dir),
            "build_type": pkg_meta.get("build_type"),
            "already_ros2": True,
            "package_xml": pkg_meta,
            "files": [],
            "launch_files": [],
        }

    cmake_path = pkg_dir / "CMakeLists.txt"
    cmake_meta = cmake_parser.parse(str(cmake_path)) if cmake_path.exists() else None

    files: list[dict] = []
    launch_files: list[dict] = []
    for path in pkg_dir.rglob("*"):
        if not path.is_file():
            continue
        suffix = path.suffix.lower()
        lower_name = path.name.lower()
        if suffix in CPP_EXTS:
            files.append(cpp_parser.parse(str(path)))
        elif suffix in PY_EXTS:
            try:
                files.append(py_parser.parse(str(path)))
            except SyntaxError as exc:
                files.append(
                    {
                        "path": str(path),
                        "language": "python",
                        "parser": "ast-error",
                        "error": str(exc),
                        "symbols": [],
                    }
                )
        elif lower_name.endswith(".launch") or lower_name.endswith(".launch.xml"):
            try:
                launch_files.append(launch_parser.parse(str(path)))
            except Exception as exc:
                launch_files.append({"path": str(path), "error": str(exc)})

    interfaces = {
        "msgs": sorted(str(p.relative_to(pkg_dir)) for p in pkg_dir.rglob("*.msg")),
        "srvs": sorted(str(p.relative_to(pkg_dir)) for p in pkg_dir.rglob("*.srv")),
        "actions": sorted(str(p.relative_to(pkg_dir)) for p in pkg_dir.rglob("*.action")),
    }

    return {
        "name": pkg_meta.get("name") or pkg_dir.name,
        "path": str(pkg_dir),
        "build_type": pkg_meta.get("build_type"),
        "already_ros2": False,
        "package_xml": pkg_meta,
        "cmake": cmake_meta,
        "interfaces": interfaces,
        "files": files,
        "launch_files": launch_files,
    }


def _scan_source_for_endpoints(path: str, language: str) -> dict:
    """Extract {name, type} endpoint tuples from one source file."""
    try:
        text = Path(path).read_text(encoding="utf-8", errors="replace")
    except Exception:
        return {"pub": [], "sub": [], "srv_prov": [], "srv_call": [], "params_read": [], "params_declared": []}
    pub: list[dict] = []
    sub: list[dict] = []
    srv_prov: list[dict] = []
    srv_call: list[dict] = []
    params_read: list[dict] = []
    params_declared: list[dict] = []
    if language == "cpp":
        for regex, bucket in (
            (_CPP_PUB_RE, pub),
            (_CPP_SUB_RE, sub),
            (_CPP_SRV_PROV_RE, srv_prov),
            (_CPP_SRV_CALL_RE, srv_call),
        ):
            for match in regex.finditer(text):
                type_token, name_token = match.group(1), match.group(2)
                bucket.append({"name": name_token, "type": type_token or None, "source": path})
    elif language == "python":
        for regex, bucket in (
            (_PY_PUB_RE, pub),
            (_PY_SUB_RE, sub),
            (_PY_SRV_PROV_RE, srv_prov),
            (_PY_SRV_CALL_RE, srv_call),
        ):
            for match in regex.finditer(text):
                bucket.append({"name": match.group(1), "type": match.group(2), "source": path})
        for match in _PY_PARAM_READ_RE.finditer(text):
            params_read.append({"name": match.group(1), "source": path})
        for match in _PY_PARAM_SET_RE.finditer(text):
            params_declared.append({"name": match.group(1), "source": path})
    return {
        "pub": pub,
        "sub": sub,
        "srv_prov": srv_prov,
        "srv_call": srv_call,
        "params_read": params_read,
        "params_declared": params_declared,
    }


def _derive_surface(pkg: dict) -> dict:
    pub: list[dict] = []
    sub: list[dict] = []
    srv_prov: list[dict] = []
    srv_call: list[dict] = []
    actions_prov: list[dict] = []
    actions_call: list[dict] = []
    params_declared: list[dict] = []
    params_read: list[dict] = []
    for parsed_file in pkg.get("files", []):
        endpoints = _scan_source_for_endpoints(parsed_file["path"], parsed_file.get("language", ""))
        pub.extend(endpoints["pub"])
        sub.extend(endpoints["sub"])
        srv_prov.extend(endpoints["srv_prov"])
        srv_call.extend(endpoints["srv_call"])
        params_read.extend(endpoints["params_read"])
        params_declared.extend(endpoints["params_declared"])
    for launch_file in pkg.get("launch_files", []):
        for node in launch_file.get("nodes", []):
            for remap in node.get("remaps", []):
                pub.append(
                    {
                        "name": remap.get("to"),
                        "type": None,
                        "launch": launch_file["path"],
                        "remap_from": remap.get("from"),
                    }
                )
    return {
        "published_topics": pub,
        "subscribed_topics": sub,
        "services_provided": srv_prov,
        "services_called": srv_call,
        "actions_provided": actions_prov,
        "actions_called": actions_call,
        "params_declared": params_declared,
        "params_read": params_read,
    }


def _detect_unresolved(pkg: dict, covered: set[str]) -> list[str]:
    seen: set[str] = set()
    for parsed_file in pkg.get("files", []):
        source_path = Path(parsed_file["path"])
        if not source_path.exists():
            continue
        text = source_path.read_text(encoding="utf-8", errors="replace")
        for match in ROS_SYMBOL_PATTERN.finditer(text):
            symbol = match.group(0)
            if symbol not in covered:
                seen.add(symbol)
    return sorted(seen)


def _build_inventory(workspace: Path, pkg_filter: str | None, source_distro: str, target_distro: str) -> dict:
    covered = load_covered_index(SKILL_ROOT / "references" / "mappings")
    packages: list[dict] = []
    for pkg_dir in _find_packages(workspace):
        if pkg_filter and pkg_dir.name != pkg_filter:
            continue
        pkg = _scan_package(pkg_dir)
        pkg["interface_surface"] = _derive_surface(pkg)
        pkg["unresolved_symbols"] = _detect_unresolved(pkg, covered)
        packages.append(pkg)
    dependency_graph = {
        pkg["name"]: sorted(
            set((pkg.get("package_xml") or {}).get("build_depends", []) + (pkg.get("package_xml") or {}).get("exec_depends", []))
        )
        for pkg in packages
    }
    degraded = [
        parsed_file["path"]
        for pkg in packages
        for parsed_file in pkg.get("files", [])
        if parsed_file.get("parser") == "regex"
    ]
    return {
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "source_ros_distro": source_distro,
        "target_ros_distro": target_distro,
        "workspace": str(workspace),
        "packages": packages,
        "dependency_graph": dependency_graph,
        "unresolved_symbols": sorted({symbol for pkg in packages for symbol in pkg.get("unresolved_symbols", [])}),
        "parser_degraded_files": degraded,
    }


def _render_digest(inventory: dict) -> str:
    lines = ["# ROS1 Inventory Digest", ""]
    lines.append(f"- Workspace: `{inventory['workspace']}`")
    lines.append(f"- Source distro: {inventory['source_ros_distro']}  → target: {inventory['target_ros_distro']}")
    lines.append(f"- Packages scanned: {len(inventory['packages'])}")
    lines.append(f"- Degraded parser files: {len(inventory['parser_degraded_files'])}")
    lines.append(f"- Unresolved symbols (global): {len(inventory['unresolved_symbols'])}")
    lines.append("")
    for pkg in inventory["packages"]:
        lines.append(f"## {pkg['name']}")
        lines.append(f"- already_ros2: `{pkg.get('already_ros2')}`")
        lines.append(f"- build_type: `{pkg.get('build_type')}`")
        lines.append(f"- files: {len(pkg.get('files', []))}")
        lines.append(f"- launch: {len(pkg.get('launch_files', []))}")
        lines.append(
            f"- msgs: {len(pkg.get('interfaces', {}).get('msgs', []))}, "
            f"srvs: {len(pkg.get('interfaces', {}).get('srvs', []))}, "
            f"actions: {len(pkg.get('interfaces', {}).get('actions', []))}"
        )
        if pkg.get("unresolved_symbols"):
            preview = ", ".join(pkg["unresolved_symbols"][:10])
            suffix = " …" if len(pkg["unresolved_symbols"]) > 10 else ""
            lines.append(f"- unresolved: {preview}{suffix}")
        lines.append("")
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Scan a ROS1 workspace and emit inventory.json")
    parser.add_argument("--workspace", required=True)
    parser.add_argument("--package", default=None)
    parser.add_argument("--output", default=None)
    parser.add_argument("--md", default=None)
    parser.add_argument("--source-distro", default="noetic")
    parser.add_argument("--target-distro", default="jazzy")
    args = parser.parse_args(argv)

    workspace = Path(args.workspace).resolve()
    if not workspace.exists():
        print(f"workspace not found: {workspace}", file=sys.stderr)
        return 2

    inventory = _build_inventory(workspace, args.package, args.source_distro, args.target_distro)
    out_path = Path(args.output) if args.output else workspace / "docs" / "ros1-migration" / "artifacts" / "inventory.json"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(inventory, indent=2), encoding="utf-8")
    if args.md:
        Path(args.md).write_text(_render_digest(inventory), encoding="utf-8")
    print(f"wrote {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
