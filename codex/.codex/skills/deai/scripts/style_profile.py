#!/usr/bin/env python3
"""
Style Profile Analyzer for De-AI Skill.

Analyzes one or more reference documents and outputs a JSON style profile
that captures the author's writing characteristics across 8 dimensions.
The profile can then be fed to an LLM during rewrite mode to match the
target style, producing text that sounds like the author -- not like AI.

Usage:
    python3 style_profile.py article1.txt article2.txt --output profile.json
    python3 style_profile.py reference.tex --lang zh
    python3 style_profile.py *.md --format compact

The output JSON follows the 8-dimension framework from REWRITING_GUIDE.md
Strategy 11. It is designed to be passed directly to an LLM as a system
prompt or style context.
"""

import argparse
import json
import re
import statistics
import sys
from pathlib import Path

try:
    from parsers import get_parser, detect_language
except ImportError:
    sys.path.append(str(Path(__file__).parent))
    from parsers import get_parser, detect_language


def _extract_text(file_path: Path) -> str:
    """Read file and extract visible text, preserving paragraph breaks."""
    content = file_path.read_text(encoding="utf-8", errors="ignore")
    parser = get_parser(file_path)
    lines = content.split("\n")
    result_lines = []
    for line in lines:
        stripped = line.strip()
        if not stripped:
            result_lines.append("")  # preserve blank lines as paragraph breaks
        else:
            v = parser.extract_visible_text(stripped)
            if v:
                result_lines.append(v)
    return "\n".join(result_lines)


def _split_sentences(text: str, lang: str) -> list[str]:
    """Split text into sentences."""
    if lang in ("zh", "mixed"):
        parts = re.split(r'[。！？；.!?]\s*|\n+', text)
    else:
        parts = re.split(r'[.!?]\s+|\n+', text)
    return [s.strip() for s in parts if s.strip() and len(s.strip()) > 3]


def _sentence_lengths(sentences: list[str], lang: str) -> list[int]:
    """Get word/char counts per sentence."""
    if lang == "zh":
        return [sum(1 for c in s if "\u4e00" <= c <= "\u9fff") for s in sentences]
    return [len(s.split()) for s in sentences]


def _count_punctuation(text: str) -> dict[str, int]:
    """Count punctuation usage."""
    counts = {}
    for name, pattern in [
        ("parentheses", r"[()（）]"),
        ("dashes", r"[—–\-]{2,}|——"),
        ("semicolons", r"[;；]"),
        ("colons", r"[:：]"),
        ("questions", r"[?？]"),
        ("exclamations", r"[!！]"),
        ("quotes_double", r'["""\u201c\u201d]'),
        ("quotes_single", r"['''\u2018\u2019]"),
    ]:
        counts[name] = len(re.findall(pattern, text))
    return counts


def _extract_frequent_words(text: str, lang: str, top_n: int = 20) -> list[str]:
    """Extract most frequent content words (skip stopwords)."""
    zh_stops = set("的了是在不有我他她它们这那和与或但如果因为所以虽然然而而且并且因此由于为了以及以便于是其中之一")
    en_stops = set("the a an is are was were be been being have has had do does did will would shall should can could may might must to of in for on with at by from as into through during before after above below between")

    if lang == "zh":
        # Simple character bigram frequency
        chars = [c for c in text if "\u4e00" <= c <= "\u9fff" and c not in zh_stops]
        bigrams = [chars[i] + chars[i+1] for i in range(len(chars)-1)]
        freq: dict[str, int] = {}
        for bg in bigrams:
            freq[bg] = freq.get(bg, 0) + 1
    else:
        words = re.findall(r'\b[a-z]+\b', text.lower())
        words = [w for w in words if w not in en_stops and len(w) > 2]
        freq = {}
        for w in words:
            freq[w] = freq.get(w, 0) + 1

    sorted_words = sorted(freq.items(), key=lambda x: -x[1])
    return [w for w, _ in sorted_words[:top_n]]


def _detect_rhetoric(text: str, lang: str) -> list[str]:
    """Detect common rhetorical devices."""
    devices = []
    if lang == "zh":
        if re.search(r"如同|好像|仿佛|犹如|像是", text):
            devices.append("simile")
        if re.search(r"难道|怎能|岂不|何尝", text):
            devices.append("rhetorical_question")
        if re.search(r"(.{2,8})，\1", text):
            devices.append("repetition")
    else:
        if re.search(r"\blike\b|\bas\s+\w+\s+as\b|\bresembl", text, re.I):
            devices.append("simile")
        if re.search(r"\b(not|never|no)\b.{5,30}\b(but|yet|rather)\b", text, re.I):
            devices.append("antithesis")
        if re.search(r'\b(\w{4,})\b.{10,50}\b\1\b', text, re.I):
            devices.append("repetition")
    return devices or ["none_detected"]


def _detect_perspective(text: str, lang: str) -> str:
    """Detect narrative perspective."""
    if lang == "zh":
        first = len(re.findall(r"我|本文|笔者", text))
        third = len(re.findall(r"该|其|本研究", text))
    else:
        first = len(re.findall(r"\bI\b|\bwe\b|\bour\b|\bmy\b", text, re.I))
        third = len(re.findall(r"\bthe\s+(?:author|study|paper|method)\b", text, re.I))

    if first > third * 2:
        return "first_person"
    if third > first * 2:
        return "third_person"
    return "mixed"


def analyze_style(files: list[Path], lang: str = "auto") -> dict:
    """Analyze writing style across one or more reference files.

    Returns an 8-dimension JSON style profile.
    """
    all_text = ""
    for f in files:
        all_text += _extract_text(f) + "\n\n"

    if lang == "auto":
        lang = detect_language(all_text)

    sentences = _split_sentences(all_text, lang)
    lengths = _sentence_lengths(sentences, lang)

    if not lengths:
        return {"error": "No sentences found in input files"}

    mean_len = statistics.mean(lengths)
    std_len = statistics.stdev(lengths) if len(lengths) > 1 else 0

    # Paragraph analysis
    paragraphs = [p.strip() for p in all_text.split("\n\n") if p.strip()]
    para_lengths = [len(p) for p in paragraphs]
    mean_para = statistics.mean(para_lengths) if para_lengths else 0

    punct = _count_punctuation(all_text)
    frequent = _extract_frequent_words(all_text, lang)
    rhetoric = _detect_rhetoric(all_text, lang)
    perspective = _detect_perspective(all_text, lang)

    # Formality: ratio of formal markers
    if lang == "zh":
        formal_count = len(re.findall(r"因此|综上|鉴于|据此|基于", all_text))
        informal_count = len(re.findall(r"其实|说白了|讲真|反正|就是", all_text))
    else:
        formal_count = len(re.findall(r"\btherefore\b|\bhence\b|\bmoreover\b|\bfurthermore\b", all_text, re.I))
        informal_count = len(re.findall(r"\bbasically\b|\bactually\b|\bpretty\b|\bstuff\b", all_text, re.I))
    total_markers = formal_count + informal_count
    formality = round(min(5, max(1, 3 + (formal_count - informal_count) / max(total_markers, 1) * 2)))

    profile = {
        "style_summary": f"{'Chinese' if lang == 'zh' else 'Mixed (ZH+EN)' if lang == 'mixed' else 'English'} writing, "
                         f"formality {formality}/5, "
                         f"avg sentence {mean_len:.0f} {'chars' if lang == 'zh' else 'words'}, "
                         f"{'varied' if std_len / max(mean_len, 1) > 0.3 else 'uniform'} rhythm",
        "language": {
            "sentence_pattern": {
                "mean_length": round(mean_len, 1),
                "std_length": round(std_len, 1),
                "cv": round(std_len / max(mean_len, 1), 2),
                "short_sentences_pct": round(sum(1 for l in lengths if l < mean_len * 0.5) / max(len(lengths), 1) * 100),
                "long_sentences_pct": round(sum(1 for l in lengths if l > mean_len * 1.5) / max(len(lengths), 1) * 100),
            },
            "word_choice": {
                "formality_level": formality,
                "preferred_words": frequent[:10],
                "total_unique_words": len(set(re.findall(r'\b\w+\b', all_text.lower()))),
            },
            "rhetoric": rhetoric,
        },
        "structure": {
            "paragraph_count": len(paragraphs),
            "mean_paragraph_length": round(mean_para),
            "transition_style": "formal" if formality >= 4 else "casual" if formality <= 2 else "balanced",
        },
        "narrative": {
            "perspective": perspective,
            "narrator_attitude": "objective" if formality >= 4 else "personal" if perspective == "first_person" else "balanced",
        },
        "emotion": {
            "intensity": min(5, max(1, punct.get("exclamations", 0) // max(len(paragraphs), 1) + 1)),
            "expression_style": "restrained" if punct.get("exclamations", 0) < 3 else "expressive",
        },
        "thinking": {
            "logic_pattern": "deductive" if formal_count > informal_count else "inductive",
        },
        "uniqueness": {
            "signature_phrases": frequent[:5],
        },
        "rhythm": {
            "sentence_cv": round(std_len / max(mean_len, 1), 2),
            "tempo": "varied" if std_len / max(mean_len, 1) > 0.3 else "steady",
        },
        "punctuation_profile": punct,
        "_meta": {
            "files_analyzed": [str(f) for f in files],
            "language": lang,
            "total_sentences": len(sentences),
            "total_chars": len(all_text),
        },
    }

    return profile


def main():
    parser = argparse.ArgumentParser(
        description="Analyze writing style and output a JSON profile"
    )
    parser.add_argument("files", nargs="+", type=Path, help="Reference files to analyze")
    parser.add_argument("--lang", choices=["zh", "en", "mixed", "auto"], default="auto")
    parser.add_argument("--output", "-o", type=Path, help="Save profile to file")
    parser.add_argument("--format", choices=["pretty", "compact"], default="pretty",
                        help="JSON output format")

    args = parser.parse_args()

    for f in args.files:
        if not f.exists():
            print(f"[ERROR] File not found: {f}", file=sys.stderr)
            sys.exit(1)

    profile = analyze_style(args.files, lang=args.lang)

    indent = 2 if args.format == "pretty" else None
    output = json.dumps(profile, indent=indent, ensure_ascii=False)

    if args.output:
        args.output.write_text(output, encoding="utf-8")
        print(f"[OK] Style profile saved to: {args.output}")
    else:
        print(output)


if __name__ == "__main__":
    main()
