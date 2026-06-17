"""
Document Parsers for De-AI Writing Checker
Supports LaTeX, Typst, Markdown, and plain text.
"""

import re
from abc import ABC, abstractmethod
from typing import Any


class DocumentParser(ABC):
    """Abstract base class for document parsers."""

    @abstractmethod
    def split_sections(self, content: str) -> dict[str, tuple[int, int]]:
        """Return {section_name: (start_line, end_line)} mapping."""

    @abstractmethod
    def extract_visible_text(self, line: str) -> str:
        """Extract human-readable text, stripping markup."""

    @abstractmethod
    def get_comment_prefix(self) -> str:
        """Return the comment prefix for this format."""

    @staticmethod
    def _unique_key(sections: dict, name: str) -> str:
        """Generate a unique section key to avoid collisions."""
        if name not in sections:
            return name
        i = 2
        while f"{name}_{i}" in sections:
            i += 1
        return f"{name}_{i}"

    @staticmethod
    def _merge_patterns(zh: dict[str, str], en: dict[str, str]) -> dict[str, str]:
        """Merge ZH and EN section patterns, combining regexes for same keys."""
        merged: dict[str, str] = {}
        for name, pat in zh.items():
            merged[name] = pat
        for name, pat in en.items():
            if name in merged:
                merged[name] = merged[name] + "|" + pat
            else:
                merged[name] = pat
        return merged


class LatexParser(DocumentParser):
    """Parser for LaTeX documents (Chinese and English)."""

    SECTION_PATTERNS_ZH = {
        "abstract": r"\\(?:chapter|section)\*?\{摘要\}|\\begin\{(?:c)?abstract\}",
        "introduction": r"\\(?:chapter|section)\*?\{(?:绪论|引言)\}",
        "related": r"\\(?:chapter|section)\*?\{(?:相关工作|文献综述)\}",
        "method": r"\\(?:chapter|section)\*?\{.*?(?:方法|原理|设计|框架|模型)\}",
        "experiment": r"\\(?:chapter|section)\*?\{.*?(?:实验|实现|测试)\}",
        "result": r"\\(?:chapter|section)\*?\{.*?(?:结果|性能)\}",
        "discussion": r"\\(?:chapter|section)\*?\{.*?(?:讨论|分析)\}",
        "conclusion": r"\\(?:chapter|section)\*?\{(?:结论|总结.*?展望)\}",
    }

    SECTION_PATTERNS_EN = {
        "abstract": r"\\begin\{abstract\}|\\section\*?\{Abstract\}",
        "introduction": r"\\section\*?\{Introduction\}",
        "related": r"\\section\*?\{(?:Related\s+Work|Background|Literature\s+Review)\}",
        "method": r"\\section\*?\{(?:Method(?:s|ology)?|Approach|Framework|Model)\}",
        "experiment": r"\\section\*?\{(?:Experiment(?:s|al\s+Setup)?|Implementation)\}",
        "result": r"\\section\*?\{(?:Results?|Evaluation|Performance)\}",
        "discussion": r"\\section\*?\{Discussion\}",
        "conclusion": r"\\section\*?\{Conclusion(?:s)?\}",
    }

    PRESERVE_PATTERNS = [
        r"\\cite\{[^}]+\}",
        r"\\ref\{[^}]+\}",
        r"\\label\{[^}]+\}",
        r"\\eqref\{[^}]+\}",
        r"\\autoref\{[^}]+\}",
        r"\$\$[^$]*\$\$",
        r"\$[^$]*\$",
        r"\\begin\{equation\}.*?\\end\{equation\}",
        r"\\begin\{align\}.*?\\end\{align\}",
        r"\\includegraphics(?:\[[^\]]*\])?\{[^}]+\}",
    ]

    def get_comment_prefix(self) -> str:
        return "%"

    def split_sections(self, content: str) -> dict[str, tuple[int, int]]:
        lines = content.split("\n")
        sections: dict[str, tuple[int, int]] = {}
        current_key = "preamble"
        start_line = 0
        all_patterns = self._merge_patterns(self.SECTION_PATTERNS_ZH, self.SECTION_PATTERNS_EN)

        for i, line in enumerate(lines, 1):
            for section_name, pattern in all_patterns.items():
                if re.search(pattern, line, re.IGNORECASE):
                    if current_key != "preamble":
                        sections[current_key] = (start_line, i - 1)
                    current_key = self._unique_key(sections, section_name)
                    start_line = i
                    break

        if current_key != "preamble":
            sections[current_key] = (start_line, len(lines))

        if not sections:
            sections["document"] = (1, len(lines))

        return sections

    def extract_visible_text(self, line: str) -> str:
        temp = line
        for pattern in self.PRESERVE_PATTERNS:
            temp = re.sub(pattern, " ", temp, flags=re.DOTALL)
        # Strip LaTeX commands but keep content
        temp = re.sub(r"\\[a-zA-Z]+\*?(?:\[[^\]]*\])*\{([^}]*)\}", r"\1", temp)
        temp = re.sub(r"\\[a-zA-Z]+\*?", "", temp)
        temp = re.sub(r"[{}]", "", temp)
        return re.sub(r"\s+", " ", temp).strip()


class TypstParser(DocumentParser):
    """Parser for Typst documents."""

    SECTION_PATTERNS_ZH = {
        "abstract": r"^=\s+摘要",
        "introduction": r"^=\s+(?:绪论|引言)",
        "related": r"^=\s+(?:相关工作|文献综述)",
        "method": r"^=\s+.*(?:方法|原理|设计)",
        "experiment": r"^=\s+.*(?:实验|实现|测试)",
        "result": r"^=\s+.*(?:结果|性能)",
        "discussion": r"^=\s+.*(?:讨论|分析)",
        "conclusion": r"^=\s+(?:结论|总结.*?展望)",
    }

    SECTION_PATTERNS_EN = {
        "abstract": r"^=\s+Abstract",
        "introduction": r"^=\s+Introduction",
        "related": r"^=\s+(?:Related\s+Work|Background)",
        "method": r"^=\s+(?:Method(?:s|ology)?|Approach)",
        "experiment": r"^=\s+(?:Experiment(?:s)?|Implementation)",
        "result": r"^=\s+(?:Results?|Evaluation)",
        "discussion": r"^=\s+Discussion",
        "conclusion": r"^=\s+Conclusion(?:s)?",
    }

    PRESERVE_PATTERNS = [
        r"@[a-zA-Z0-9_-]+",
        r"#cite\([^)]+\)",
        r"#figure\([^)]+\)",
        r"#table\([^)]+\)",
        r"\$[^$]+\$",
        r"<[a-zA-Z0-9_-]+>",
        r"#link\([^)]+\)",
    ]

    def get_comment_prefix(self) -> str:
        return "//"

    def split_sections(self, content: str) -> dict[str, tuple[int, int]]:
        lines = content.split("\n")
        sections: dict[str, tuple[int, int]] = {}
        current_key = "preamble"
        start_line = 0
        all_patterns = self._merge_patterns(self.SECTION_PATTERNS_ZH, self.SECTION_PATTERNS_EN)

        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            for section_name, pattern in all_patterns.items():
                if re.search(pattern, stripped, re.IGNORECASE):
                    if current_key != "preamble":
                        sections[current_key] = (start_line, i - 1)
                    current_key = self._unique_key(sections, section_name)
                    start_line = i
                    break

        if current_key != "preamble":
            sections[current_key] = (start_line, len(lines))

        if not sections:
            sections["document"] = (1, len(lines))

        return sections

    def extract_visible_text(self, line: str) -> str:
        temp = line
        if "//" in temp:
            temp = temp.split("//")[0]
        for pattern in self.PRESERVE_PATTERNS:
            temp = re.sub(pattern, " ", temp, flags=re.DOTALL)
        return re.sub(r"\s+", " ", temp).strip()


class MarkdownParser(DocumentParser):
    """Parser for Markdown documents."""

    SECTION_PATTERNS_ZH = {
        "abstract": r"^#{1,2}\s+摘要",
        "introduction": r"^#{1,2}\s+(?:绪论|引言|简介)",
        "related": r"^#{1,2}\s+(?:相关工作|文献综述|背景)",
        "method": r"^#{1,2}\s+.*(?:方法|原理|设计|框架)",
        "experiment": r"^#{1,2}\s+.*(?:实验|实现|测试)",
        "result": r"^#{1,2}\s+.*(?:结果|性能|评估)",
        "discussion": r"^#{1,2}\s+(?:讨论|分析)",
        "conclusion": r"^#{1,2}\s+(?:结论|总结)",
    }

    SECTION_PATTERNS_EN = {
        "abstract": r"^#{1,2}\s+Abstract",
        "introduction": r"^#{1,2}\s+Introduction",
        "related": r"^#{1,2}\s+(?:Related\s+Work|Background|Literature)",
        "method": r"^#{1,2}\s+(?:Method(?:s|ology)?|Approach)",
        "experiment": r"^#{1,2}\s+(?:Experiment(?:s)?|Implementation)",
        "result": r"^#{1,2}\s+(?:Results?|Evaluation|Performance)",
        "discussion": r"^#{1,2}\s+Discussion",
        "conclusion": r"^#{1,2}\s+Conclusion(?:s)?",
    }

    def get_comment_prefix(self) -> str:
        return "<!--"

    def split_sections(self, content: str) -> dict[str, tuple[int, int]]:
        lines = content.split("\n")
        sections: dict[str, tuple[int, int]] = {}
        current_key = "preamble"
        start_line = 0
        all_patterns = self._merge_patterns(self.SECTION_PATTERNS_ZH, self.SECTION_PATTERNS_EN)

        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            for section_name, pattern in all_patterns.items():
                if re.search(pattern, stripped, re.IGNORECASE):
                    if current_key != "preamble":
                        sections[current_key] = (start_line, i - 1)
                    current_key = self._unique_key(sections, section_name)
                    start_line = i
                    break

        if current_key != "preamble":
            sections[current_key] = (start_line, len(lines))

        if not sections:
            sections["document"] = (1, len(lines))

        return sections

    def extract_visible_text(self, line: str) -> str:
        temp = line
        # Remove markdown links [text](url)
        temp = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", temp)
        # Remove images ![alt](url)
        temp = re.sub(r"!\[[^\]]*\]\([^)]*\)", "", temp)
        # Remove inline code
        temp = re.sub(r"`[^`]*`", " ", temp)
        # Remove bold/italic markers
        temp = re.sub(r"\*{1,3}([^*]*)\*{1,3}", r"\1", temp)
        temp = re.sub(r"_{1,3}([^_]*)_{1,3}", r"\1", temp)
        # Remove heading markers
        temp = re.sub(r"^#{1,6}\s+", "", temp)
        # Remove HTML comments
        temp = re.sub(r"<!--.*?-->", "", temp, flags=re.DOTALL)
        return re.sub(r"\s+", " ", temp).strip()


class PlainTextParser(DocumentParser):
    """Parser for plain text documents."""

    def get_comment_prefix(self) -> str:
        return "#"

    def split_sections(self, content: str) -> dict[str, tuple[int, int]]:
        # Treat entire document as one section
        lines = content.split("\n")
        return {"document": (1, len(lines))}

    def extract_visible_text(self, line: str) -> str:
        return line.strip()


def get_parser(file_path: Any) -> DocumentParser:
    """Factory method to get appropriate parser."""
    path_str = str(file_path).lower()
    if path_str.endswith(".typ"):
        return TypstParser()
    if path_str.endswith(".md"):
        return MarkdownParser()
    if path_str.endswith((".tex", ".ltx", ".bbl")):
        return LatexParser()
    return PlainTextParser()


def detect_language(text: str) -> str:
    """Detect language based on CJK character ratio.

    Returns 'zh' if mostly Chinese, 'en' if mostly English,
    'mixed' if both languages are substantially present.
    """
    if not text:
        return "en"
    cjk_count = sum(1 for c in text if "\u4e00" <= c <= "\u9fff")
    total = len(text.replace(" ", "").replace("\n", ""))
    if total == 0:
        return "en"
    ratio = cjk_count / total
    if ratio > 0.6:
        return "zh"
    if ratio < 0.05:
        return "en"
    return "mixed"
