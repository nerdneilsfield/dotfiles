#!/usr/bin/env python3
"""
De-AI Batch Processor (Chinese & English)
Batch processes entire documents or directories.

Usage:
    python deai_batch.py main.tex --all-sections
    python deai_batch.py main.tex --all-sections --lang zh
    python deai_batch.py paper.md --chapter intro.md --output polished/
    python deai_batch.py . --glob "*.tex" --lang auto
"""

import argparse
import sys
from pathlib import Path

try:
    from deai_check import DeAIChecker
    from parsers import detect_language, get_parser
except ImportError:
    sys.path.append(str(Path(__file__).parent))
    from deai_check import DeAIChecker
    from parsers import detect_language, get_parser


class DeAIBatchProcessor:
    """Batch process documents for de-AI analysis."""

    def __init__(self, file_path: Path, lang: str = "auto", profile: str = "generic"):
        self.file_path = file_path
        self.lang = lang
        self.profile = profile

    def analyze_all_sections(self) -> str:
        """Analyze all sections of a single file."""
        checker = DeAIChecker(self.file_path, lang=self.lang, profile=self.profile)
        analysis = checker.analyze_document()
        return checker.generate_report(analysis)

    def process_chapter_file(self, chapter_file: Path, output_dir: Path) -> bool:
        """Process a single chapter file and annotate AI traces."""
        if not chapter_file.exists():
            print(f"[ERROR] Chapter file not found: {chapter_file}")
            return False

        checker = DeAIChecker(chapter_file, lang=self.lang, profile=self.profile)
        analysis = checker.analyze_document()

        content = chapter_file.read_text(encoding="utf-8", errors="ignore")
        lines = content.split("\n")
        comment_prefix = checker.comment_prefix

        # Collect all trace line numbers
        trace_lines: dict[int, list[dict]] = {}
        for _section_name, result in analysis["sections"].items():
            for trace in result["traces"]:
                line_num = trace["line"]
                if line_num not in trace_lines:
                    trace_lines[line_num] = []
                trace_lines[line_num].append(trace)

        # Annotate file
        processed_lines = []
        for i, line in enumerate(lines):
            line_num = i + 1
            if line_num in trace_lines:
                traces = trace_lines[line_num]
                categories = ", ".join(t["category"] for t in traces)
                matched = ", ".join(f'"{t["matched"]}"' for t in traces)
                if comment_prefix == "<!--":
                    comment = f"<!-- De-AI: Line {line_num} - [{categories}] {matched} -->"
                else:
                    comment = f"{comment_prefix} De-AI: Line {line_num} - [{categories}] {matched}"
                processed_lines.append(comment)
            processed_lines.append(line)

        output_file = output_dir / chapter_file.name
        output_file.write_text("\n".join(processed_lines), encoding="utf-8")

        total_traces = sum(len(t) for t in trace_lines.values())
        print(f"[OK] Processed: {chapter_file.name}")
        print(f"     Output: {output_file}")
        print(f"     Traces: {total_traces}")

        return True

    def process_directory(self, glob_pattern: str) -> str:
        """Process all matching files in a directory."""
        directory = self.file_path
        if not directory.is_dir():
            directory = directory.parent

        files = sorted(directory.glob(glob_pattern))
        if not files:
            return f"[WARNING] No files matching '{glob_pattern}' found in {directory}"

        reports = []
        total_files = 0
        total_traces = 0

        for f in files:
            checker = DeAIChecker(f, lang=self.lang, profile=self.profile)
            analysis = checker.analyze_document()

            file_traces = sum(
                r["trace_count"] for r in analysis["sections"].values()
            )
            total_traces += file_traces
            total_files += 1

            worst_score = 0
            if analysis["sections"]:
                worst_score = max(
                    checker.calculate_density_score(r)
                    for r in analysis["sections"].values()
                )

            status = "OK" if worst_score < 5 else "WARN" if worst_score < 10 else "CRIT"
            reports.append(
                f"  [{status}] {f.name}: {file_traces} traces, "
                f"worst section {worst_score:.1f}%"
            )

        header = "=" * 70
        summary = [
            header,
            "DE-AI BATCH ANALYSIS REPORT",
            header,
            f"Directory: {directory}",
            f"Pattern: {glob_pattern}",
            f"Files analyzed: {total_files}",
            f"Total traces: {total_traces}",
            "",
            "-" * 70,
            "FILE RESULTS",
            "-" * 70,
        ]
        summary.extend(reports)
        summary.append(header)

        return "\n".join(summary)


def main():
    parser = argparse.ArgumentParser(
        description="Batch process documents for AI writing trace detection"
    )
    parser.add_argument("file", type=Path, help="Main file or directory")
    parser.add_argument("--lang", choices=["zh", "en", "mixed", "auto"], default="auto",
                        help="Language (default: auto)")
    parser.add_argument("--profile", choices=["generic", "deepseek", "claude", "mixed"],
                        default="generic", help="Model profile (default: generic)")
    parser.add_argument("--all-sections", action="store_true",
                        help="Analyze all sections of the file")
    parser.add_argument("--chapter", type=Path,
                        help="Process a specific chapter file")
    parser.add_argument("--output", type=Path,
                        help="Output directory for annotated files")
    parser.add_argument("--glob", type=str,
                        help='Process all matching files (e.g., "*.tex")')
    parser.add_argument("--report", type=Path, help="Save report to file")

    args = parser.parse_args()

    if not args.file.exists():
        print(f"[ERROR] Not found: {args.file}", file=sys.stderr)
        sys.exit(1)

    processor = DeAIBatchProcessor(args.file, lang=args.lang, profile=args.profile)

    if args.glob:
        report = processor.process_directory(args.glob)
        if args.report:
            args.report.write_text(report, encoding="utf-8")
            print(f"[OK] Report saved to: {args.report}")
        else:
            print(report)

    elif args.all_sections:
        report = processor.analyze_all_sections()
        if args.report:
            args.report.write_text(report, encoding="utf-8")
            print(f"[OK] Report saved to: {args.report}")
        else:
            print(report)

    elif args.chapter:
        if not args.output:
            print("[ERROR] --output required when using --chapter")
            sys.exit(1)
        args.output.mkdir(parents=True, exist_ok=True)
        success = processor.process_chapter_file(args.chapter, args.output)
        sys.exit(0 if success else 1)

    else:
        # Default: show detected sections
        content = args.file.read_text(encoding="utf-8", errors="ignore")
        doc_parser = get_parser(args.file)
        sections = doc_parser.split_sections(content)
        lang = detect_language(content) if args.lang == "auto" else args.lang

        print(f"\nFile: {args.file}")
        print(f"Language: {lang}")
        print(f"Detected sections:")
        for name, (start, end) in sections.items():
            print(f"  - {name}: lines {start}-{end}")
        print(f"\nUse --all-sections for full analysis")


if __name__ == "__main__":
    main()
