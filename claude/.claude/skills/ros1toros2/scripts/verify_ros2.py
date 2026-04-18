#!/usr/bin/env python3
"""verify_ros2.py — post-migration checks for a ROS2 workspace."""
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

from _common import load_banned_patterns, run_cmd

SCAN_EXTS = {".cpp", ".cc", ".cxx", ".h", ".hpp", ".hh", ".py", ".launch", ".xml", ".txt"}
CPP_EXTS = {".cpp", ".cc", ".cxx", ".h", ".hpp", ".hh"}

_ROS2_CPP_PUB_RE = re.compile(r'create_publisher\s*<\s*([A-Za-z0-9_:]+)\s*>\s*\(\s*"([^"]+)"')
_ROS2_CPP_SUB_RE = re.compile(r'create_subscription\s*<\s*([A-Za-z0-9_:]+)\s*>\s*\(\s*"([^"]+)"')
_ROS2_CPP_SRV_RE = re.compile(r'create_service\s*<\s*([A-Za-z0-9_:]+)\s*>\s*\(\s*"([^"]+)"')
_ROS2_CPP_CLI_RE = re.compile(r'create_client\s*<\s*([A-Za-z0-9_:]+)\s*>\s*\(\s*"([^"]+)"')
_ROS2_PY_PUB_RE = re.compile(r'create_publisher\s*\(\s*([A-Za-z0-9_.]+)\s*,\s*["\']([^"\']+)["\']')
_ROS2_PY_SUB_RE = re.compile(r'create_subscription\s*\(\s*([A-Za-z0-9_.]+)\s*,\s*["\']([^"\']+)["\']')
_ROS2_PY_SRV_RE = re.compile(r'create_service\s*\(\s*([A-Za-z0-9_.]+)\s*,\s*["\']([^"\']+)["\']')
_ROS2_PY_CLI_RE = re.compile(r'create_client\s*\(\s*([A-Za-z0-9_.]+)\s*,\s*["\']([^"\']+)["\']')
_PY_LAUNCH_REMAP_RE = re.compile(r"remappings\s*=\s*\[([^\]]*)\]", re.DOTALL)
_PY_LAUNCH_REMAP_PAIR_RE = re.compile(r'\(\s*["\']([^"\']+)["\']\s*,\s*["\']([^"\']+)["\']\s*\)')

_BUILD_ERR_CATEGORIES = [
    ("missing_dep", re.compile(r"fatal error: ([^\s:]+): No such file or directory")),
    ("api_mismatch", re.compile(r"error: 'class [^']+' has no member named '([^']+)'")),
    ("linker", re.compile(r"undefined reference to .([^.]+).")),
]
_AMENT_TEST_RE = re.compile(r"\bament_(?:cpplint|cppcheck|flake8|pep257|uncrustify|copyright|xmllint|lint_cmake|clang_format)\b")


def _load_plan_meta(path: Path | None) -> dict:
    if path is None or not path.exists():
        return {"tasks": [], "surface_changes": []}
    return json.loads(path.read_text(encoding="utf-8"))


def _residual_scan(workspace: Path) -> list[dict]:
    patterns = load_banned_patterns(SKILL_ROOT / "references" / "mappings")
    seen: set[tuple[str, str, int]] = set()
    hits: list[dict] = []
    for path in workspace.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in SCAN_EXTS:
            continue
        try:
            lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
        except Exception:
            continue
        for line_no, line in enumerate(lines, start=1):
            for pattern in patterns:
                key = (pattern, str(path), line_no)
                if pattern and pattern in line and key not in seen:
                    seen.add(key)
                    hits.append({"pattern": pattern, "file": str(path), "line": line_no, "snippet": line.strip()[:200]})
    return hits


def _find_ament_packages(workspace: Path) -> list[Path]:
    packages: list[Path] = []
    for package_xml in workspace.rglob("package.xml"):
        try:
            text = package_xml.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        if "ament_cmake" in text or "ament_python" in text:
            packages.append(package_xml.parent)
    return packages


def _pkg_name(pkg_dir: Path) -> str:
    try:
        import xml.etree.ElementTree as ET

        root = ET.parse(pkg_dir / "package.xml").getroot()
        return (root.findtext("name") or pkg_dir.name).strip()
    except Exception:
        return pkg_dir.name


def _scan_ros2_source(path: Path) -> dict:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return {"pub": [], "sub": [], "srv_prov": [], "srv_call": []}
    pub: list[dict] = []
    sub: list[dict] = []
    srv_prov: list[dict] = []
    srv_call: list[dict] = []
    if path.suffix.lower() in CPP_EXTS:
        for match in _ROS2_CPP_PUB_RE.finditer(text):
            pub.append({"name": match.group(2), "type": match.group(1), "source": str(path)})
        for match in _ROS2_CPP_SUB_RE.finditer(text):
            sub.append({"name": match.group(2), "type": match.group(1), "source": str(path)})
        for match in _ROS2_CPP_SRV_RE.finditer(text):
            srv_prov.append({"name": match.group(2), "type": match.group(1), "source": str(path)})
        for match in _ROS2_CPP_CLI_RE.finditer(text):
            srv_call.append({"name": match.group(2), "type": match.group(1), "source": str(path)})
    elif path.suffix.lower() == ".py":
        for match in _ROS2_PY_PUB_RE.finditer(text):
            pub.append({"name": match.group(2), "type": match.group(1), "source": str(path)})
        for match in _ROS2_PY_SUB_RE.finditer(text):
            sub.append({"name": match.group(2), "type": match.group(1), "source": str(path)})
        for match in _ROS2_PY_SRV_RE.finditer(text):
            srv_prov.append({"name": match.group(2), "type": match.group(1), "source": str(path)})
        for match in _ROS2_PY_CLI_RE.finditer(text):
            srv_call.append({"name": match.group(2), "type": match.group(1), "source": str(path)})
    return {"pub": pub, "sub": sub, "srv_prov": srv_prov, "srv_call": srv_call}


def _scan_ros2_launch(path: Path) -> list[dict]:
    endpoints: list[dict] = []
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return endpoints
    for match in _PY_LAUNCH_REMAP_RE.finditer(text):
        for pair in _PY_LAUNCH_REMAP_PAIR_RE.finditer(match.group(1)):
            endpoints.append({"name": pair.group(2), "type": None, "launch": str(path), "remap_from": pair.group(1)})
    return endpoints


def _scan_ros2_surface(workspace: Path) -> dict[str, dict]:
    out: dict[str, dict] = {}
    for pkg_dir in _find_ament_packages(workspace):
        name = _pkg_name(pkg_dir)
        acc = {"pub": [], "sub": [], "srv_prov": [], "srv_call": []}
        for path in pkg_dir.rglob("*"):
            if not path.is_file():
                continue
            if path.suffix.lower() in CPP_EXTS or path.suffix.lower() == ".py":
                endpoints = _scan_ros2_source(path)
                for key in acc:
                    acc[key].extend(endpoints[key])
            if path.name.endswith(".launch.py"):
                acc["pub"].extend(_scan_ros2_launch(path))
        out[name] = acc
    return out


def _endpoint_keys(entries: list[dict]) -> set[str]:
    return {entry["name"] for entry in entries if entry.get("name")}


def _endpoint_types(entries: list[dict]) -> dict[str, str]:
    mapping: dict[str, str] = {}
    for entry in entries:
        if entry.get("name") and entry.get("type"):
            mapping.setdefault(entry["name"], entry["type"])
    return mapping


def _normalize_type(type_name: str | None) -> str | None:
    if not type_name:
        return None
    return type_name.replace("::msg::", "/").replace("::srv::", "/").replace("::", "/").replace(".", "/")


def _surface_diff(inventory: dict, post_surface: dict[str, dict], plan_meta: dict) -> dict:
    declared_changes = plan_meta.get("surface_changes", [])
    removed_set = {
        (change.get("package"), change.get("name") or change.get("from"))
        for change in declared_changes
        if change.get("kind") in ("topic_removed", "service_removed")
    }
    renamed_from = {
        (change.get("package"), change.get("from")): change.get("to")
        for change in declared_changes
        if change.get("kind") in ("topic_rename", "service_rename")
    }
    type_changes = {
        (change.get("package"), change.get("name")): (change.get("from"), change.get("to"))
        for change in declared_changes
        if change.get("kind") == "type_changed"
    }

    missing: list[dict] = []
    added: list[dict] = []
    type_changed: list[dict] = []
    undeclared: list[dict] = []

    categories = ("pub", "sub", "srv_prov", "srv_call")
    cat_to_inventory_key = {
        "pub": "published_topics",
        "sub": "subscribed_topics",
        "srv_prov": "services_provided",
        "srv_call": "services_called",
    }
    for pkg in inventory.get("packages", []):
        if pkg.get("already_ros2"):
            continue
        pkg_name = pkg["name"]
        post = post_surface.get(pkg_name, {category: [] for category in categories})
        surface_before = pkg.get("interface_surface") or {}
        for category in categories:
            before_list = surface_before.get(cat_to_inventory_key[category], [])
            after_list = post.get(category, [])
            before_keys = _endpoint_keys(before_list)
            after_keys = _endpoint_keys(after_list)
            before_types = _endpoint_types(before_list)
            after_types = _endpoint_types(after_list)

            for key in before_keys - after_keys:
                item = {"package": pkg_name, "category": category, "kind": "missing", "key": key}
                missing.append(item)
                declared_rename_dest = renamed_from.get((pkg_name, key))
                if (pkg_name, key) in removed_set:
                    continue
                if declared_rename_dest and declared_rename_dest in after_keys:
                    continue
                undeclared.append(item)
            for key in after_keys - before_keys:
                if any(dest == key for dest in renamed_from.values()):
                    continue
                added.append({"package": pkg_name, "category": category, "kind": "added", "key": key})
            for key in before_keys & after_keys:
                before_type = _normalize_type(before_types.get(key))
                after_type = _normalize_type(after_types.get(key))
                if before_type and after_type and before_type != after_type:
                    item = {
                        "package": pkg_name,
                        "category": category,
                        "kind": "type_changed",
                        "key": key,
                        "from": before_types.get(key),
                        "to": after_types.get(key),
                    }
                    type_changed.append(item)
                    declared_change = type_changes.get((pkg_name, key))
                    if not declared_change:
                        undeclared.append({**item, "reason": "undeclared_type_change"})
    return {"missing": missing, "added": added, "type_changed": type_changed, "undeclared": undeclared}


def _run_build(workspace: Path) -> dict:
    proc = run_cmd(
        ["colcon", "build", "--event-handlers", "console_direct+", "--base-paths", str(workspace)],
        cwd=workspace,
        timeout=1800,
    )
    categorized: dict[str, list[str]] = {"missing_dep": [], "api_mismatch": [], "linker": [], "other": []}
    for line in (proc.stderr or "").splitlines():
        tagged = False
        for label, regex in _BUILD_ERR_CATEGORIES:
            match = regex.search(line)
            if match:
                categorized[label].append(match.group(0))
                tagged = True
                break
        if not tagged and "error:" in line.lower():
            categorized["other"].append(line.strip())
    return {
        "skipped": False,
        "returncode": proc.returncode,
        "stderr_excerpt": (proc.stderr or "")[-4000:],
        "categorized": categorized,
    }


def _is_ament_lint_junit(path: Path, classname: str | None) -> bool:
    if _AMENT_TEST_RE.search(path.name):
        return True
    if classname and _AMENT_TEST_RE.search(classname):
        return True
    return False


def _parse_junit_lint(xml_path: Path) -> tuple[list[str], list[str]]:
    import xml.etree.ElementTree as ET

    errors: list[str] = []
    warnings: list[str] = []
    file_level_ament = _AMENT_TEST_RE.search(xml_path.name) is not None
    try:
        root = ET.parse(xml_path).getroot()
    except Exception:
        return errors, warnings
    for testcase in root.iter("testcase"):
        classname = testcase.get("classname")
        if not (file_level_ament or _is_ament_lint_junit(xml_path, classname)):
            continue
        for failure in testcase.findall("failure"):
            errors.append(f"{classname}::{testcase.get('name')}: {(failure.text or '')[:200]}")
        for error in testcase.findall("error"):
            errors.append(f"{classname}::{testcase.get('name')}: {(error.text or '')[:200]}")
        for skipped in testcase.findall("skipped"):
            warnings.append(f"{classname}::{testcase.get('name')}: skipped")
    return errors, warnings


def _run_lint(workspace: Path) -> dict:
    proc = run_cmd(["colcon", "test", "--base-paths", str(workspace)], cwd=workspace, timeout=1800)
    errors: list[str] = []
    warnings: list[str] = []
    for junit in (workspace / "build").rglob("*.xml"):
        if "test_results" not in junit.parts:
            continue
        parsed_errors, parsed_warnings = _parse_junit_lint(junit)
        errors.extend(parsed_errors)
        warnings.extend(parsed_warnings)
    return {"skipped": False, "returncode": proc.returncode, "errors": errors, "warnings": warnings}


def build_report(workspace: Path, inventory: dict, plan_meta: dict, skip_build: bool, skip_lint: bool) -> dict:
    residuals = _residual_scan(workspace)
    post_surface = _scan_ros2_surface(workspace)
    report = {
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "workspace": str(workspace),
        "residuals": residuals,
        "surface_diff": _surface_diff(inventory, post_surface, plan_meta),
        "build": {"skipped": skip_build, "returncode": None, "stderr_excerpt": "", "categorized": {}},
        "lint": {"skipped": skip_lint, "returncode": None, "errors": [], "warnings": []},
        "plan_status": {"total": len(plan_meta.get("tasks", [])), "incomplete": []},
    }
    if skip_build:
        report["build"] = {"skipped": True, "returncode": None, "stderr_excerpt": "", "categorized": {}}
    else:
        report["build"] = _run_build(workspace)
    if skip_lint:
        report["lint"] = {"skipped": True, "returncode": None, "errors": [], "warnings": []}
    else:
        report["lint"] = _run_lint(workspace)
    for task in plan_meta.get("tasks", []):
        if (task.get("status") or "pending") != "completed":
            report["plan_status"]["incomplete"].append(task.get("id"))
    return report


def pass_criteria(report: dict) -> tuple[bool, list[str]]:
    reasons: list[str] = []
    if report["residuals"]:
        reasons.append(f"residual ROS1 symbols: {len(report['residuals'])}")
    if report["surface_diff"]["undeclared"]:
        reasons.append(f"undeclared surface changes: {len(report['surface_diff']['undeclared'])}")
    if not report["build"]["skipped"] and report["build"]["returncode"] not in (None, 0):
        reasons.append(f"colcon build rc={report['build']['returncode']}")
    if not report["lint"]["skipped"] and report["lint"]["errors"]:
        reasons.append(f"lint errors: {len(report['lint']['errors'])}")
    if report["plan_status"]["incomplete"]:
        reasons.append(f"plan tasks incomplete: {report['plan_status']['incomplete']}")
    return (not reasons, reasons)


def render_markdown_digest(report: dict) -> str:
    lines = ["# Verification Report", ""]
    lines.append(f"- Generated: {report['generated_at']}")
    lines.append(f"- Workspace: `{report['workspace']}`")
    lines.append(f"- Passed: **{report['passed']}**")
    if report["failure_reasons"]:
        lines.append(f"- Failure reasons: {', '.join(report['failure_reasons'])}")
    lines.append("")
    lines.append(f"## Residuals ({len(report['residuals'])})")
    for hit in report["residuals"][:50]:
        lines.append(f"- `{hit['pattern']}` at `{hit['file']}:{hit['line']}` — `{hit['snippet']}`")
    if len(report["residuals"]) > 50:
        lines.append(f"- … and {len(report['residuals']) - 50} more")
    lines.append("")
    diff = report["surface_diff"]
    lines.append("## Surface diff")
    lines.append(
        f"- Missing: {len(diff['missing'])}, Added: {len(diff['added'])}, "
        f"Type-changed: {len(diff['type_changed'])}, **Undeclared: {len(diff['undeclared'])}**"
    )
    for item in diff["undeclared"][:20]:
        lines.append(f"- {item['package']} / {item['kind']} / `{item['key']}`")
    lines.append("")
    lines.append("## Build")
    if report["build"]["skipped"]:
        lines.append("- skipped")
    else:
        lines.append(f"- returncode: {report['build']['returncode']}")
        for category, items in (report["build"].get("categorized") or {}).items():
            if items:
                lines.append(f"- {category}: {len(items)}")
    lines.append("")
    lines.append("## Lint")
    if report["lint"]["skipped"]:
        lines.append("- skipped")
    else:
        lines.append(f"- errors: {len(report['lint']['errors'])}, warnings: {len(report['lint']['warnings'])}")
    lines.append("")
    lines.append("## Plan status")
    lines.append(f"- Incomplete: {report['plan_status']['incomplete']}")
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--workspace", required=True)
    parser.add_argument("--inventory", required=True)
    parser.add_argument("--plan-meta", default=None)
    parser.add_argument("--output", default=None)
    parser.add_argument("--md", default=None)
    parser.add_argument("--skip-build", action="store_true")
    parser.add_argument("--skip-lint", action="store_true")
    args = parser.parse_args(argv)

    workspace = Path(args.workspace).resolve()
    inventory = json.loads(Path(args.inventory).read_text(encoding="utf-8"))
    plan_meta = _load_plan_meta(Path(args.plan_meta) if args.plan_meta else None)

    report = build_report(workspace, inventory, plan_meta, args.skip_build, args.skip_lint)
    ok, reasons = pass_criteria(report)
    report["passed"] = ok
    report["failure_reasons"] = reasons

    out_path = Path(args.output) if args.output else workspace / "docs" / "ros1-migration" / "artifacts" / "verify-report.json"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
    if args.md:
        Path(args.md).write_text(render_markdown_digest(report), encoding="utf-8")
    print(f"wrote {out_path}; passed={ok}; reasons={reasons}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
