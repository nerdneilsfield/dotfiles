#!/usr/bin/env python3
"""Analyze and suggest improvements for Nano Banana Pro prompts."""

from __future__ import annotations

import argparse
import sys
from typing import NamedTuple


class PromptAnalysis(NamedTuple):
    """Analysis results for a prompt."""
    has_subject: bool
    has_composition: bool
    has_action: bool
    has_location: bool
    has_style: bool
    has_technical: bool
    has_chinese_text: bool
    has_resolution: bool
    has_aspect_ratio: bool
    suggestions: list[str]
    score: int  # 0-100


# Keywords for detecting each component
SUBJECT_KEYWORDS = ["show", "depict", "illustrate", "portray", "featuring"]
COMPOSITION_KEYWORDS = ["shot", "angle", "view", "framing", "portrait", "landscape", "close-up", "wide"]
ACTION_KEYWORDS = ["doing", "performing", "running", "walking", "jumping", "standing", "sitting", "working"]
LOCATION_KEYWORDS = ["in", "at", "on", "inside", "outside", "environment", "setting", "background", "scene"]
STYLE_KEYWORDS = ["style", "look", "aesthetic", "artistic", "photorealistic", "illustration", "painting", "render"]
TECHNICAL_KEYWORDS = ["mm", "f/", "lighting", "light", "color", "resolution", "quality", "detailed", "dof"]
CHINESE_INDICATORS = ["chinese", "中文", "汉字", "typography", "字体", "标签"]
RESOLUTION_KEYWORDS = ["4k", "2k", "1080p", "uhd", "hd", "high resolution", "dpi"]
ASPECT_KEYWORDS = ["16:9", "9:16", "4:3", "1:1", "aspect ratio", "vertical", "horizontal", "square"]


def analyze_prompt(prompt: str) -> PromptAnalysis:
    """Analyze a prompt and return suggestions."""
    prompt_lower = prompt.lower()
    suggestions = []

    # Check for 6 core components
    has_subject = any(kw in prompt_lower for kw in SUBJECT_KEYWORDS) or len(prompt.split()) > 5
    has_composition = any(kw in prompt_lower for kw in COMPOSITION_KEYWORDS)
    has_action = any(kw in prompt_lower for kw in ACTION_KEYWORDS)
    has_location = any(kw in prompt_lower for kw in LOCATION_KEYWORDS)
    has_style = any(kw in prompt_lower for kw in STYLE_KEYWORDS)
    has_technical = any(kw in prompt_lower for kw in TECHNICAL_KEYWORDS)

    # Check for Chinese text and typography
    has_chinese_text = any(kw in prompt_lower for kw in CHINESE_INDICATORS)

    # Check for resolution and aspect ratio
    has_resolution = any(kw in prompt_lower for kw in RESOLUTION_KEYWORDS)
    has_aspect_ratio = any(kw in prompt_lower for kw in ASPECT_KEYWORDS)

    # Generate suggestions
    if not has_subject:
        suggestions.append("Add specific subject description (e.g., 'a fluffy cat' instead of 'cat')")

    if not has_composition:
        suggestions.append("Specify composition (e.g., 'wide shot', 'close-up', 'low-angle')")

    if not has_action and "diagram" not in prompt_lower and "chart" not in prompt_lower:
        suggestions.append("Consider adding action/behavior if applicable (e.g., 'jumping', 'reading')")

    if not has_location:
        suggestions.append("Add location/environment context (e.g., 'in a modern office', 'outdoors at sunset')")

    if not has_style:
        suggestions.append("Specify visual style (e.g., 'photorealistic', 'watercolor', 'minimalist diagram')")

    if not has_technical:
        suggestions.append("Add technical parameters (e.g., 'soft lighting', 'shallow DOF', 'warm colors')")

    if not has_resolution:
        suggestions.append("Specify resolution for best quality (e.g., '4K resolution', '2K')")

    if not has_aspect_ratio:
        suggestions.append("Define aspect ratio (e.g., '16:9 for presentation', '4:3 for paper')")

    # Check for Chinese text handling
    if ("label" in prompt_lower or "text" in prompt_lower or "title" in prompt_lower) and not has_chinese_text:
        suggestions.append("If text contains Chinese, add: 'Labels in Chinese with proper typography'")

    # Check for vague adjectives
    vague_words = ["nice", "good", "beautiful", "professional", "cool", "awesome"]
    found_vague = [w for w in vague_words if w in prompt_lower]
    if found_vague:
        suggestions.append(f"Replace vague words ({', '.join(found_vague)}) with specific technical terms")

    # Check for quantified parameters
    if "blur" in prompt_lower and "f/" not in prompt_lower:
        suggestions.append("Quantify 'blur' as 'shallow depth of field (f/1.4)' or similar")

    if "bright" in prompt_lower or "dark" in prompt_lower:
        suggestions.append("Specify lighting setup instead of just 'bright/dark'")

    # Calculate score (0-100)
    component_score = sum([
        has_subject * 15,
        has_composition * 15,
        has_action * 10,
        has_location * 15,
        has_style * 15,
        has_technical * 15,
        has_resolution * 8,
        has_aspect_ratio * 7,
    ])

    return PromptAnalysis(
        has_subject=has_subject,
        has_composition=has_composition,
        has_action=has_action,
        has_location=has_location,
        has_style=has_style,
        has_technical=has_technical,
        has_chinese_text=has_chinese_text,
        has_resolution=has_resolution,
        has_aspect_ratio=has_aspect_ratio,
        suggestions=suggestions,
        score=component_score
    )


def print_analysis(prompt: str, analysis: PromptAnalysis) -> None:
    """Print the analysis results."""
    print("\n" + "="*70)
    print("PROMPT ANALYSIS")
    print("="*70)
    print(f"\nOriginal Prompt:\n{prompt}\n")

    print(f"Quality Score: {analysis.score}/100")

    # Score interpretation
    if analysis.score >= 90:
        rating = "Excellent ✨"
    elif analysis.score >= 70:
        rating = "Good ✓"
    elif analysis.score >= 50:
        rating = "Needs Improvement ⚠️"
    else:
        rating = "Poor ✗"
    print(f"Rating: {rating}\n")

    # Component checklist
    print("Component Checklist:")
    print(f"  {'✓' if analysis.has_subject else '✗'} Subject description")
    print(f"  {'✓' if analysis.has_composition else '✗'} Composition/framing")
    print(f"  {'✓' if analysis.has_action else '✗'} Action/behavior")
    print(f"  {'✓' if analysis.has_location else '✗'} Location/environment")
    print(f"  {'✓' if analysis.has_style else '✗'} Visual style")
    print(f"  {'✓' if analysis.has_technical else '✗'} Technical parameters")
    print(f"  {'✓' if analysis.has_resolution else '✗'} Resolution specified")
    print(f"  {'✓' if analysis.has_aspect_ratio else '✗'} Aspect ratio specified")

    # Suggestions
    if analysis.suggestions:
        print(f"\nSuggestions for Improvement ({len(analysis.suggestions)}):")
        for i, suggestion in enumerate(analysis.suggestions, 1):
            print(f"  {i}. {suggestion}")
    else:
        print("\nNo suggestions - prompt looks great!")

    print("\n" + "="*70)


def suggest_template(prompt_type: str) -> str:
    """Return a template for common prompt types."""
    templates = {
        "diagram": """Create a [type] diagram showing [topic].

Structure:
- Component 1: [description]
- Component 2: [description]
- Flow/relationship: [description]

Style: Clean academic diagram, white background
Colors: Blue (#4A90E2) for primary, Gray (#6B7280) for secondary
Layout: [Horizontal/Vertical] flow with clear arrows
Labels: All in Chinese, 14pt font, clear and readable
Title: "[图表标题]"

Technical: 16:9 aspect ratio, 4K resolution, professional quality""",

        "comparison": """Create a side-by-side comparison visualization.

Left panel: [Method A description]
Right panel: [Method B description]
Center: Large "vs" divider

Visual style: Clean scientific presentation
Colors: [specify color scheme]
Background: Light gray (#F3F4F6)
Labels: Chinese text, clear typography
Metrics: Show key numbers in table format

Technical: 16:9, 4K resolution for presentation""",

        "flowchart": """Generate a flowchart diagram for [process/algorithm name].

Components:
- Start/End: Rounded rectangles
- Process steps: Rectangles with descriptions in Chinese
- Decisions: Diamonds with yes/no branches
- Data: Parallelograms

Style: Modern flat design
Colors: Teal (#14B8A6) for primary, Orange (#F97316) for accent
Layout: Vertical flow, top to bottom
Labels: Clear Chinese text for all steps

Technical: 4K resolution, suitable for academic paper""",

        "photo": """[Subject description] doing [action].

Composition: [shot type] shot at [angle]
Location: [environment details]
Lighting: [lighting setup]
Style: [photorealistic/artistic style]

Camera: [lens and settings]
Color grading: [color palette]
Aspect ratio: [16:9/9:16/etc.]
Resolution: 4K""",
    }

    return templates.get(prompt_type, "Template not found")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Analyze and optimize Nano Banana Pro prompts"
    )
    parser.add_argument("prompt", nargs="?", help="Prompt to analyze")
    parser.add_argument("--file", help="Read prompt from file")
    parser.add_argument("--template", choices=["diagram", "comparison", "flowchart", "photo"],
                       help="Show template for prompt type")
    args = parser.parse_args()

    if args.template:
        print(f"\nTemplate for {args.template}:")
        print("="*70)
        print(suggest_template(args.template))
        print("="*70)
        return 0

    # Get prompt
    if args.file:
        try:
            with open(args.file, encoding="utf-8") as f:
                prompt = f.read().strip()
        except FileNotFoundError:
            print(f"Error: File not found: {args.file}")
            return 1
    elif args.prompt:
        prompt = args.prompt
    else:
        print("Reading prompt from stdin (Ctrl+D to finish)...")
        prompt = sys.stdin.read().strip()

    if not prompt:
        print("Error: No prompt provided")
        return 1

    # Analyze and print
    analysis = analyze_prompt(prompt)
    print_analysis(prompt, analysis)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
