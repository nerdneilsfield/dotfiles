#!/usr/bin/env python3
"""Insert generated figures into document, replacing ASCII diagrams."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import NamedTuple


class FigureInfo(NamedTuple):
    """Information about a figure to insert."""
    index: int
    line_number: int  # Original line number from JSON
    output_filename: str
    caption: str | None = None


class LineOffset(NamedTuple):
    """Track line number offset after modifications."""
    original_line: int
    offset: int  # Number of lines added (positive) or removed (negative)


def _parse_json(json_path: Path) -> list[FigureInfo]:
    """Parse prompts JSON and extract figure information."""
    with json_path.open("r", encoding="utf-8") as f:
        data = json.load(f)

    figures = []
    for item in data.get("prompts", []):
        # Only process generated figures
        if not item.get("generated", False):
            continue

        figures.append(FigureInfo(
            index=item.get("index", 0),
            line_number=item.get("line_number", 0),
            output_filename=item.get("output_filename", ""),
            caption=item.get("subsection") or item.get("section") or None
        ))

    # Sort by line number to process in order
    figures.sort(key=lambda f: f.line_number)
    return figures


def _find_ascii_block(lines: list[str], start_line: int, debug: bool = False) -> tuple[int, int] | None:
    """
    Find ASCII diagram code block starting near the given line.

    Returns:
        tuple: (start_index, end_index) of code block, or None if not found
        Indices are 0-based for the lines list.
    """
    # Convert 1-based line number to 0-based index
    start_idx = start_line - 1

    # Search within a larger window (the ASCII block might be a few lines after the reference line)
    search_start = max(0, start_idx - 5)
    search_end = min(len(lines), start_idx + 100)

    if debug:
        print(f"    Searching range: {search_start}-{search_end} (target: {start_idx})")

    # Look for code block markers (``` or ~~~)
    in_code_block = False
    code_start = -1
    code_end = -1
    candidates = []

    for i in range(search_start, search_end):
        line = lines[i].strip()

        if line.startswith("```") or line.startswith("~~~"):
            if not in_code_block:
                # Found start of code block
                in_code_block = True
                code_start = i
            else:
                # Found end of code block
                code_end = i
                # Save this candidate
                candidates.append((code_start, code_end))
                # Reset and continue searching
                in_code_block = False
                code_start = -1

    if debug:
        print(f"    Found {len(candidates)} code blocks")
        for cs, ce in candidates:
            print(f"      Block: lines {cs+1}-{ce+1}")

    # Find the closest code block to our target line
    if candidates:
        # Prefer blocks that start after the target line (within 20 lines)
        nearby = [(cs, ce) for cs, ce in candidates if start_idx <= cs <= start_idx + 20]
        if nearby:
            return nearby[0]

        # Otherwise, find the closest block
        closest = min(candidates, key=lambda x: abs(x[0] - start_idx))
        # Only accept if it's reasonably close (within 50 lines)
        if abs(closest[0] - start_idx) <= 50:
            return closest

    # If we found an unclosed code block near the target
    if in_code_block and code_start >= 0:
        # Find the closing marker
        for i in range(code_start + 1, len(lines)):
            line = lines[i].strip()
            if line.startswith("```") or line.startswith("~~~"):
                if start_idx <= code_start <= start_idx + 20:
                    return (code_start, i)

    return None


def _apply_offset(line_number: int, offsets: list[LineOffset]) -> int:
    """Apply accumulated offsets to get current line number."""
    adjusted = line_number
    for offset_entry in offsets:
        if line_number > offset_entry.original_line:
            adjusted += offset_entry.offset
    return adjusted


def _insert_figures(
    input_path: Path,
    output_path: Path,
    figures: list[FigureInfo],
    image_dir: str = "./images",
    encoding: str = "utf-8"
) -> None:
    """
    Insert figures into document, replacing ASCII diagrams.

    Args:
        input_path: Input markdown file
        output_path: Output markdown file
        figures: List of figures to insert (sorted by line number)
        image_dir: Directory containing images (relative to document)
        encoding: File encoding
    """
    # Read document
    with input_path.open("r", encoding=encoding) as f:
        lines = f.readlines()

    # Track line offsets
    offsets: list[LineOffset] = []

    # Process figures in order
    for fig in figures:
        print(f"[{fig.index}] Inserting {fig.output_filename} at original line {fig.line_number}...")

        # Apply accumulated offsets to get current line number
        current_line = _apply_offset(fig.line_number, offsets)

        # Find ASCII block
        block_range = _find_ascii_block(lines, current_line)
        if not block_range:
            print(f"  ⚠️  Warning: Could not find ASCII block near line {current_line}")
            continue

        block_start, block_end = block_range
        block_size = block_end - block_start + 1

        # Create figure markdown
        image_path = f"{image_dir}/{fig.output_filename}"
        caption = f"图 {fig.index}: {fig.caption}" if fig.caption else f"图 {fig.index}"

        figure_lines = [
            "\n",
            f"![{caption}]({image_path})\n",
            "\n"
        ]

        # Replace block with figure
        lines[block_start:block_end + 1] = figure_lines

        # Calculate offset (negative if we removed lines)
        offset = len(figure_lines) - block_size
        offsets.append(LineOffset(
            original_line=fig.line_number,
            offset=offset
        ))

        print(f"  ✓ Replaced {block_size} lines with {len(figure_lines)} lines (offset: {offset:+d})")

    # Write output
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding=encoding) as f:
        f.writelines(lines)

    print(f"\n✅ Inserted {len(figures)} figures into {output_path}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Insert generated figures into document, replacing ASCII diagrams"
    )
    parser.add_argument("--file", required=True, help="Input markdown file")
    parser.add_argument("--output", required=True, help="Output markdown file")
    parser.add_argument("--json", required=True, help="Prompts JSON file")
    parser.add_argument("--image-dir", default="./images", help="Image directory (relative path)")
    parser.add_argument("--encoding", default="utf-8", help="File encoding")
    args = parser.parse_args()

    input_path = Path(args.file)
    output_path = Path(args.output)
    json_path = Path(args.json)

    if not input_path.exists():
        print(f"Error: Input file not found: {input_path}")
        return 1

    if not json_path.exists():
        print(f"Error: JSON file not found: {json_path}")
        return 1

    # Parse JSON
    print(f"📄 Reading prompts from {json_path}")
    figures = _parse_json(json_path)

    if not figures:
        print("⚠️  No generated figures found in JSON (check 'generated: true' field)")
        return 1

    print(f"Found {len(figures)} generated figures to insert\n")

    # Insert figures
    _insert_figures(input_path, output_path, figures, args.image_dir, args.encoding)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
