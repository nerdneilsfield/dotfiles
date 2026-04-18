"""Shared helpers for ros1toros2 scripts."""
from __future__ import annotations

import re
import subprocess
from pathlib import Path

ROS_SYMBOL_PATTERN = re.compile(
    r"\b(?:ros::[A-Za-z_][A-Za-z_0-9:]*|"
    r"ROS_(?:INFO|WARN|ERROR|DEBUG|FATAL)(?:_STREAM)?|"
    r"rospy\.[A-Za-z_][A-Za-z_0-9]*|"
    r"tf\.[A-Za-z_][A-Za-z_0-9]*|"
    r"actionlib\.[A-Za-z_][A-Za-z_0-9]*)"
)


def load_covered_index(mappings_dir: Path) -> set[str]:
    """Aggregate every 'Covered Symbols' entry from references/mappings/*.md."""
    covered: set[str] = set()
    for md in sorted(mappings_dir.glob("*.md")):
        in_section = False
        buf: list[str] = []
        for line in md.read_text(encoding="utf-8").splitlines():
            if line.startswith("## "):
                if in_section:
                    break
                if line.strip().lower().startswith("## covered symbols"):
                    in_section = True
                continue
            if in_section:
                buf.append(line)
        blob = " ".join(buf)
        for tok in re.findall(r"`([^`]+)`", blob):
            covered.add(tok.strip())
    return covered


def load_banned_patterns(mappings_dir: Path) -> list[str]:
    """Aggregate every 'Banned Symbols' entry from references/mappings/*.md."""
    patterns: list[str] = []
    for md in sorted(mappings_dir.glob("*.md")):
        in_section = False
        buf: list[str] = []
        for line in md.read_text(encoding="utf-8").splitlines():
            if line.startswith("## "):
                if in_section:
                    break
                if "banned symbols" in line.lower():
                    in_section = True
                continue
            if in_section:
                buf.append(line)
        blob = " ".join(buf)
        for tok in re.findall(r"`([^`]+)`", blob):
            patterns.append(tok.strip())
    return patterns


def run_cmd(cmd: list[str], cwd: Path | None = None, timeout: int = 600) -> subprocess.CompletedProcess[str]:
    """Run a shell command and capture stdout/stderr."""
    return subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        capture_output=True,
        text=True,
        timeout=timeout,
        check=False,
    )


if __name__ == "__main__":
    import sys
    import tempfile

    with tempfile.TemporaryDirectory() as td:
        mappings = Path(td) / "mappings"
        mappings.mkdir()
        (mappings / "demo.md").write_text(
            "# demo\n## Covered Symbols\n`ros::init`, `ros::NodeHandle`\n"
            "## Banned Symbols (Verification Hooks)\n`ros::init`, `.advertise(`\n",
            encoding="utf-8",
        )
        covered = load_covered_index(mappings)
        banned = load_banned_patterns(mappings)
        assert covered == {"ros::init", "ros::NodeHandle"}, covered
        assert set(banned) == {"ros::init", ".advertise("}, banned
        assert ROS_SYMBOL_PATTERN.search("foo ros::init bar")
        assert ROS_SYMBOL_PATTERN.search("x = rospy.Publisher(...)")
        assert not ROS_SYMBOL_PATTERN.search("just_regular_code()")
    print("_common.py OK")
    sys.exit(0)
