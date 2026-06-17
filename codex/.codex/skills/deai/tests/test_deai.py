#!/usr/bin/env python3
"""
Regression test suite for DeAI Writing Trace Checker.

Loads fixture files and verifies detection behavior:
- should_match/   : every non-comment line MUST trigger at least one trace
- should_not_match/: every non-comment line MUST trigger zero traces
- structural/     : file MUST trigger a specific structural category

Run:
    python3 tests/test_deai.py
    python3 tests/test_deai.py -v          # verbose
    python3 -m unittest tests.test_deai    # from parent dir
"""

import os
import sys
import tempfile
import unittest
from pathlib import Path

# ---------------------------------------------------------------------------
# Import DeAIChecker from ../scripts/deai_check.py
# ---------------------------------------------------------------------------
_TESTS_DIR = Path(__file__).resolve().parent
_SCRIPTS_DIR = _TESTS_DIR.parent / "scripts"
sys.path.insert(0, str(_SCRIPTS_DIR))

from deai_check import DeAIChecker  # noqa: E402

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
_FIXTURES_DIR = _TESTS_DIR / "fixtures"

# Map structural fixture filenames to expected category in traces
STRUCTURAL_EXPECTED_CATEGORY = {
    "uniform_sentences.txt": "sentence_uniformity",
    "connector_overload.txt": "connector_overload",
}


def _load_fixture_lines(fixture_path: Path) -> list[tuple[int, str]]:
    """Load non-empty, non-comment lines from a fixture file.

    Returns list of (line_number, text) tuples.
    """
    lines = []
    for i, raw in enumerate(fixture_path.read_text(encoding="utf-8").splitlines(), 1):
        stripped = raw.strip()
        if not stripped or stripped.startswith("#"):
            continue
        lines.append((i, stripped))
    return lines


def _check_single_line(text: str, lang: str = "auto", profile: str = "generic") -> dict:
    """Write text to a temp .txt file and run DeAIChecker on it.

    Returns the check_section result dict for the 'document' section.
    """
    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".txt", encoding="utf-8", delete=False
    ) as f:
        f.write(text)
        f.flush()
        tmp_path = Path(f.name)
    try:
        checker = DeAIChecker(tmp_path, lang=lang, profile=profile)
        return checker.check_section("document")
    finally:
        tmp_path.unlink(missing_ok=True)

# Fixtures that require a specific profile (not generic)
FIXTURE_PROFILE_MAP = {
    "zh_model_tics.txt": "deepseek",
}


def _check_full_file(fixture_path: Path, lang: str = "auto") -> dict:
    """Run DeAIChecker on an entire fixture file (for structural tests).

    Returns the check_section result dict for the 'document' section.
    """
    checker = DeAIChecker(fixture_path, lang=lang)
    return checker.check_section("document")


def _detect_lang_hint(filename: str) -> str:
    """Infer language hint from fixture filename prefix."""
    name = filename.lower()
    if name.startswith("zh_"):
        return "zh"
    if name.startswith("en_"):
        return "en"
    return "auto"


# ---------------------------------------------------------------------------
# Test classes
# ---------------------------------------------------------------------------
class TestShouldMatch(unittest.TestCase):
    """Every non-comment line in should_match/ fixtures must trigger >= 1 trace."""

    pass  # test methods are generated dynamically below


class TestShouldNotMatch(unittest.TestCase):
    """Every non-comment line in should_not_match/ fixtures must trigger 0 traces."""

    pass  # test methods are generated dynamically below


class TestStructural(unittest.TestCase):
    """Structural fixtures must trigger their expected category."""

    pass  # test methods are generated dynamically below


# ---------------------------------------------------------------------------
# Dynamic test generation
# ---------------------------------------------------------------------------

def _make_should_match_test(fixture_path: Path, line_no: int, text: str, lang: str):
    profile = FIXTURE_PROFILE_MAP.get(fixture_path.name, "generic")
    def test_method(self):
        result = _check_single_line(text, lang=lang, profile=profile)
        trace_count = result["trace_count"]
        self.assertGreater(
            trace_count,
            0,
            f"SHOULD MATCH but got 0 traces.\n"
            f"  File: {fixture_path.name}:{line_no}\n"
            f"  Text: {text!r}",
        )
    return test_method


def _make_should_not_match_test(fixture_path: Path, line_no: int, text: str, lang: str):
    def test_method(self):
        result = _check_single_line(text, lang=lang)
        trace_count = result["trace_count"]
        traces_detail = ""
        if trace_count > 0:
            traces_detail = "\n  Traces:\n" + "\n".join(
                f"    - [{t['category']}] {t['matched']}" for t in result["traces"]
            )
        self.assertEqual(
            trace_count,
            0,
            f"SHOULD NOT MATCH but got {trace_count} trace(s).{traces_detail}\n"
            f"  File: {fixture_path.name}:{line_no}\n"
            f"  Text: {text!r}",
        )
    return test_method


def _make_structural_test(fixture_path: Path, expected_category: str):
    def test_method(self):
        lang = _detect_lang_hint(fixture_path.name)
        result = _check_full_file(fixture_path, lang=lang)
        # Structural traces use category="structural" with the specific
        # detector name in the "pattern" field.
        patterns_found = {t.get("pattern", t["category"]) for t in result["traces"]}
        categories_found = {t["category"] for t in result["traces"]}
        found = patterns_found | categories_found
        self.assertIn(
            expected_category,
            found,
            f"Expected '{expected_category}' not found in traces.\n"
            f"  File: {fixture_path.name}\n"
            f"  Categories: {categories_found}\n"
            f"  Patterns: {patterns_found}",
        )
    return test_method


def _generate_tests():
    """Scan fixture directories and attach test methods to test classes."""
    # should_match
    should_match_dir = _FIXTURES_DIR / "should_match"
    if should_match_dir.is_dir():
        for fixture_file in sorted(should_match_dir.glob("*.txt")):
            lang = _detect_lang_hint(fixture_file.name)
            base = fixture_file.stem
            for line_no, text in _load_fixture_lines(fixture_file):
                method_name = f"test_{base}_line{line_no}"
                method = _make_should_match_test(fixture_file, line_no, text, lang)
                method.__doc__ = f"{fixture_file.name}:{line_no} should match"
                setattr(TestShouldMatch, method_name, method)

    # should_not_match
    should_not_match_dir = _FIXTURES_DIR / "should_not_match"
    if should_not_match_dir.is_dir():
        for fixture_file in sorted(should_not_match_dir.glob("*.txt")):
            lang = _detect_lang_hint(fixture_file.name)
            base = fixture_file.stem
            for line_no, text in _load_fixture_lines(fixture_file):
                method_name = f"test_{base}_line{line_no}"
                method = _make_should_not_match_test(fixture_file, line_no, text, lang)
                method.__doc__ = f"{fixture_file.name}:{line_no} should not match"
                setattr(TestShouldNotMatch, method_name, method)

    # structural
    structural_dir = _FIXTURES_DIR / "structural"
    if structural_dir.is_dir():
        for fixture_file in sorted(structural_dir.glob("*.txt")):
            expected_cat = STRUCTURAL_EXPECTED_CATEGORY.get(fixture_file.name)
            if expected_cat is None:
                continue
            method_name = f"test_{fixture_file.stem}"
            method = _make_structural_test(fixture_file, expected_cat)
            method.__doc__ = f"{fixture_file.name} should trigger {expected_cat}"
            setattr(TestStructural, method_name, method)


_generate_tests()


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    unittest.main(verbosity=2)
