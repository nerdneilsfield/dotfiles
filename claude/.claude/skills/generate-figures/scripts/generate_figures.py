#!/usr/bin/env python3
"""Scan document files for figure prompts and generate images."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shlex
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime
from pathlib import Path
from typing import NamedTuple

try:
    import tomllib
except ImportError:
    try:
        import tomli as tomllib  # fallback for Python < 3.11
    except ImportError:
        tomllib = None  # type: ignore

EXIT_OK = 0
EXIT_NO_PROMPTS = 1
EXIT_MISSING_DEP = 2
EXIT_RUNTIME = 10


class FigurePrompt(NamedTuple):
    """Represents a figure generation prompt extracted from a document."""
    prompt: str
    output: str | None
    size: str | None
    line_number: int
    original_text: str


def _detect_file_type(path: Path) -> str:
    """Detect document type from extension."""
    suffix = path.suffix.lower()
    if suffix == ".tex":
        return "latex"
    elif suffix == ".md":
        return "markdown"
    elif suffix == ".typ":
        return "typst"
    else:
        return "unknown"


def _parse_prompts(file_path: Path, encoding: str = "utf-8") -> list[FigurePrompt]:
    """Extract figure prompts from document comments."""
    content = file_path.read_text(encoding=encoding)
    lines = content.split("\n")
    file_type = _detect_file_type(file_path)

    prompts = []

    # Patterns for different file types
    if file_type == "latex":
        # LaTeX: % FIGURE: ...
        comment_pattern = r"^\s*%\s*(FIGURE|OUTPUT|SIZE):\s*(.+)$"
    elif file_type == "markdown":
        # Markdown: <!-- FIGURE: ... -->
        comment_pattern = r"^\s*<!--\s*(FIGURE|OUTPUT|SIZE):\s*(.+?)\s*-->$"
    elif file_type == "typst":
        # Typst: // FIGURE: ...
        comment_pattern = r"^\s*//\s*(FIGURE|OUTPUT|SIZE):\s*(.+)$"
    else:
        return prompts

    current_prompt = None
    current_output = None
    current_size = None
    start_line = -1
    original_lines = []

    for line_num, line in enumerate(lines, start=1):
        match = re.match(comment_pattern, line)
        if match:
            key, value = match.groups()
            original_lines.append(line)

            if key == "FIGURE":
                # Start of new prompt block
                if current_prompt:
                    # Save previous prompt
                    prompts.append(FigurePrompt(
                        prompt=current_prompt,
                        output=current_output,
                        size=current_size,
                        line_number=start_line,
                        original_text="\n".join(original_lines[:-1])
                    ))
                    original_lines = [line]

                current_prompt = value.strip()
                current_output = None
                current_size = None
                start_line = line_num
            elif key == "OUTPUT":
                current_output = value.strip()
            elif key == "SIZE":
                current_size = value.strip()
        elif current_prompt and not re.match(comment_pattern, line):
            # End of comment block
            prompts.append(FigurePrompt(
                prompt=current_prompt,
                output=current_output,
                size=current_size,
                line_number=start_line,
                original_text="\n".join(original_lines)
            ))
            current_prompt = None
            original_lines = []

    # Don't forget the last prompt
    if current_prompt:
        prompts.append(FigurePrompt(
            prompt=current_prompt,
            output=current_output,
            size=current_size,
            line_number=start_line,
            original_text="\n".join(original_lines)
        ))

    return prompts


def _parse_prompts_from_json(json_path: Path, start_id: int | None = None, end_id: int | None = None) -> tuple[list[FigurePrompt], list[int], dict]:
    """
    Extract figure prompts from JSON file.

    Args:
        json_path: Path to JSON file
        start_id: Start index (inclusive, 1-based), None means from beginning
        end_id: End index (exclusive, 1-based), None means to end

    Returns:
        tuple: (prompts, indices_to_generate, full_json_data)
            - prompts: list of FigurePrompt objects for images not yet generated
            - indices_to_generate: list of indices (in original JSON) that need generation
            - full_json_data: complete JSON data for later updating
    """
    with json_path.open("r", encoding="utf-8") as f:
        data = json.load(f)

    prompts = []
    indices_to_generate = []

    for idx, item in enumerate(data.get("prompts", [])):
        item_index = item.get("index", idx + 1)  # Use 'index' field from JSON, fallback to position

        # Filter by ID range [start_id, end_id)
        if start_id is not None and item_index < start_id:
            continue
        if end_id is not None and item_index >= end_id:
            continue

        # Skip already generated images
        if item.get("generated", False):
            continue

        prompts.append(FigurePrompt(
            prompt=item["prompt"],
            output=item.get("output_filename"),
            size=item.get("size"),
            line_number=item.get("line_number", idx + 1),
            original_text=f"JSON index {idx} (ID {item_index})"
        ))
        indices_to_generate.append(idx)

    return prompts, indices_to_generate, data


def _slugify(text: str, limit: int = 32) -> str:
    """Convert text to safe filename."""
    safe = "".join(ch.lower() if ch.isalnum() else "-" for ch in text)
    safe = "-".join(filter(None, safe.split("-")))
    return safe[:limit] or "figure"


def _sha256(path: Path) -> str:
    """Compute SHA256 hash of file."""
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(8192), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _read_config(config_path: Path | None) -> dict:
    """Read TOML config file and return as dict."""
    if not config_path or not config_path.exists():
        return {}

    if tomllib is None:
        # TOML library not available, skip parsing
        return {}

    try:
        with config_path.open("rb") as f:
            return tomllib.load(f)
    except Exception as e:
        print(f"Warning: Failed to parse config file {config_path}: {e}")
        return {}


def _generate_figure(
    prompt_info: FigurePrompt,
    outdir: Path,
    runner: Path,
    config: Path | None,
    model: str | None = None,
    default_format: str = "png"
) -> dict:
    """Generate a single figure and return provenance."""

    # Determine output filename
    if prompt_info.output:
        output_filename = prompt_info.output
    else:
        timestamp = datetime.utcnow().strftime("%Y%m%d%H%M%S")
        slug = _slugify(prompt_info.prompt)
        output_filename = f"figure_{slug}_{timestamp}.{default_format}"

    output_path = outdir / output_filename

    # Direct import and call instead of subprocess
    try:
        import importlib.util
        spec = importlib.util.spec_from_file_location("nanobanana", str(runner))
        nanobanana = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(nanobanana)

        # Call generate_image directly
        returncode = nanobanana.generate_image(
            prompt=prompt_info.prompt,
            output=str(output_path),
            config=str(config) if config else None,
            model=model
        )

        provenance = {
            "prompt": prompt_info.prompt,
            "output_path": str(output_path),
            "line_number": prompt_info.line_number,
            "generator": f"direct call to {runner.name}",
            "timestamp": datetime.utcnow().isoformat(),
        }

        if returncode != 0:
            provenance["error"] = "generation failed (check stderr)"
            provenance["success"] = False
            return provenance

        if not output_path.exists():
            provenance["error"] = "output file not generated"
            provenance["success"] = False
            return provenance

        provenance["sha256"] = _sha256(output_path)
        provenance["success"] = True
        return provenance

    except Exception as e:
        provenance = {
            "prompt": prompt_info.prompt,
            "output_path": str(output_path),
            "line_number": prompt_info.line_number,
            "error": f"Failed to load or call generator: {e}",
            "success": False,
            "timestamp": datetime.utcnow().isoformat(),
        }
        return provenance


def _format_cmd(cmd: list[str]) -> str:
    """Format command for display."""
    return " ".join(shlex.quote(part) for part in cmd)


def _write_provenance(outdir: Path, entries: list[dict]) -> None:
    """Write provenance records to JSON file."""
    path = outdir / "figures_provenance.json"
    path.write_text(json.dumps(entries, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate figures from document comment prompts or JSON file"
    )
    parser.add_argument("--file", help="Document file to scan")
    parser.add_argument("--from-json", help="JSON file containing prompts (alternative to --file)")
    parser.add_argument("--outdir", default=None, help="Output directory (default: ./images/)")
    parser.add_argument("--runner", default="tools/fig/nanobanana.py", help="Image generator runner")
    parser.add_argument("--config", default=None, help="Config file for API credentials")
    parser.add_argument("--model", default=None, help="Model name (overrides config file)")
    parser.add_argument("--mode", choices=["report", "apply"], default="report")
    parser.add_argument("--encoding", default="utf-8", help="File encoding")
    parser.add_argument("--format", default="png", help="Default image format")
    parser.add_argument("--start-id", type=int, default=None, help="Start index (inclusive, 1-based)")
    parser.add_argument("--end-id", type=int, default=None, help="End index (exclusive, 1-based)")
    args = parser.parse_args()

    # Validate input arguments
    if not args.file and not args.from_json:
        parser.error("Either --file or --from-json must be specified")
    if args.file and args.from_json:
        parser.error("Cannot specify both --file and --from-json")

    # Validate ID range
    if args.start_id is not None and args.start_id < 1:
        parser.error("--start-id must be >= 1")
    if args.end_id is not None and args.end_id < 1:
        parser.error("--end-id must be >= 1")
    if args.start_id is not None and args.end_id is not None and args.start_id >= args.end_id:
        parser.error("--start-id must be less than --end-id")

    # Handle JSON input vs document file input
    json_data = None
    indices_to_generate = None
    json_path = None

    if args.from_json:
        # JSON mode
        json_path = Path(args.from_json).resolve()
        if not json_path.exists():
            print(f"Error: JSON file not found: {json_path}")
            return EXIT_MISSING_DEP

        # Determine output directory
        if args.outdir:
            outdir = Path(args.outdir).resolve()
        else:
            outdir = json_path.parent / "images"

        print(f"📄 Reading prompts from JSON: {json_path}")
    else:
        # Document file mode
        file_path = Path(args.file).resolve()
        if not file_path.exists():
            print(f"Error: File not found: {file_path}")
            return EXIT_MISSING_DEP

        # Determine output directory
        if args.outdir:
            outdir = Path(args.outdir).resolve()
        else:
            outdir = file_path.parent / "images"

    # Create output directory
    outdir.mkdir(parents=True, exist_ok=True)

    # Determine config file
    config_path = None
    if args.config:
        config_path = Path(args.config)
    else:
        # Try default locations
        default_config = Path.home() / ".config" / "skiils.toml"
        if default_config.exists():
            config_path = default_config
            print(f"Using default config: {default_config}")

    # Read config and determine model
    config_data = _read_config(config_path)
    model = args.model or config_data.get("image_model") or config_data.get("model")  # fallback to "model" for compatibility
    workers = config_data.get("image_model_parallel", 1)

    if model:
        print(f"Using image model: {model}")
    print(f"Using {workers} concurrent workers for image generation")

    # Check runner
    runner = Path(args.runner)
    if not runner.exists():
        print(f"Error: Runner not found: {runner}")
        print(f"Please create the runner script or specify --runner")
        return EXIT_MISSING_DEP

    # Parse prompts
    if args.from_json:
        prompts, indices_to_generate, json_data = _parse_prompts_from_json(
            json_path,
            start_id=args.start_id,
            end_id=args.end_id
        )
        total_prompts = len(json_data.get("prompts", []))

        # Count prompts in range
        prompts_in_range = 0
        for item in json_data.get("prompts", []):
            item_index = item.get("index", json_data.get("prompts", []).index(item) + 1)
            if args.start_id is not None and item_index < args.start_id:
                continue
            if args.end_id is not None and item_index >= args.end_id:
                continue
            prompts_in_range += 1

        skipped_already_generated = prompts_in_range - len(prompts)

        # Print range info
        if args.start_id or args.end_id:
            start = args.start_id or 1
            end = args.end_id or total_prompts
            print(f"📊 ID range filter: [{start}, {end}) - processing {prompts_in_range} prompts")

        if not prompts:
            if prompts_in_range == 0:
                print(f"⚠️  No prompts found in specified range")
            else:
                print(f"✅ All {prompts_in_range} figures in range already generated!")
            return EXIT_OK

        print(f"Found {total_prompts} total prompts")
        print(f"  → {prompts_in_range} in specified range")
        print(f"  → {len(prompts)} need generation")
        print(f"  → {skipped_already_generated} already generated")
    else:
        prompts = _parse_prompts(file_path, encoding=args.encoding)

        if not prompts:
            print(f"No figure prompts found in {file_path}")
            return EXIT_NO_PROMPTS

        print(f"Found {len(prompts)} figure prompt(s) in {file_path}")

    print(f"Output directory: {outdir}")
    print()

    # Process prompts
    provenance_records = []

    if args.mode == "report":
        # Report mode: sequential, no generation
        for idx, prompt_info in enumerate(prompts, start=1):
            print(f"[{idx}/{len(prompts)}] Line {prompt_info.line_number}: {prompt_info.prompt[:60]}...")
            print(f"  Would generate: {prompt_info.output or '(auto-named)'}")
            if prompt_info.size:
                print(f"  Size: {prompt_info.size}")
            print()
    else:
        # Apply mode: concurrent generation
        print(f"🚀 Generating {len(prompts)} images with {workers} workers...\n")

        success_count = 0
        fail_count = 0

        def generate_with_index(idx_and_prompt):
            idx, prompt_info = idx_and_prompt
            provenance = _generate_figure(
                prompt_info, outdir, runner, config_path, model, args.format
            )
            return idx, prompt_info, provenance

        with ThreadPoolExecutor(max_workers=workers) as executor:
            futures = {
                executor.submit(generate_with_index, (idx, prompt_info)): idx
                for idx, prompt_info in enumerate(prompts, start=1)
            }

            for future in as_completed(futures):
                idx, prompt_info, provenance = future.result()
                provenance_records.append(provenance)

                if provenance["success"]:
                    success_count += 1
                    output_path = Path(provenance['output_path'])
                    size_kb = output_path.stat().st_size / 1024
                    # Check if high-res based on size hint in prompt
                    size_indicator = "📐" if prompt_info.size and "1920" in prompt_info.size else "📏"
                    print(f"[{idx}/{len(prompts)}] ✓ {output_path.name} ({size_kb:.1f} KB) {size_indicator}")
                else:
                    fail_count += 1
                    error_msg = provenance.get('error', 'unknown error')
                    # Truncate long error messages
                    if len(error_msg) > 150:
                        error_msg = error_msg[:150] + "..."
                    print(f"[{idx}/{len(prompts)}] ✗ Failed: {error_msg}")

    # Write provenance
    if args.mode == "apply" and provenance_records:
        _write_provenance(outdir, provenance_records)

        # Update JSON file if using --from-json
        if args.from_json and json_data:
            # Mark successfully generated images as generated=true
            for idx, (json_idx, provenance) in enumerate(zip(indices_to_generate, provenance_records)):
                if provenance.get("success", False):
                    json_data["prompts"][json_idx]["generated"] = True

            # Write updated JSON
            with json_path.open("w", encoding="utf-8") as f:
                json.dump(json_data, f, indent=2, ensure_ascii=False)
                f.write("\n")
            print(f"📝 Updated JSON: {json_path}")

        # Print summary
        print(f"\n{'='*60}")
        print(f"✨ Generation Complete!")
        print(f"{'='*60}")
        print(f"✅ Success: {success_count}/{len(prompts)}")
        print(f"❌ Failed: {fail_count}/{len(prompts)}")
        print(f"📁 Output directory: {outdir}")
        print(f"📝 Provenance: {outdir / 'figures_provenance.json'}")

    return EXIT_OK


if __name__ == "__main__":
    raise SystemExit(main())
