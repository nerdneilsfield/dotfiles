#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "openai>=1.0.0",
#     "pillow>=10.0.0",
# ]
# ///
"""
Generate images using Nano Banana Pro via NewAPI reverse proxy for POE.

Usage:
    uv run generate_image.py --prompt "your image description" --filename "output.png" [options]
"""

import argparse
import os
import re
import sys
import urllib.request
from io import BytesIO
from pathlib import Path


def get_config(
    provided_key: str | None, provided_base_url: str | None
) -> tuple[str, str]:
    """Get API key and base URL from arguments or environment."""
    api_key = provided_key or os.environ.get("NEWAPI_API_KEY")
    base_url = provided_base_url or os.environ.get(
        "NEWAPI_BASE_URL", "https://api.poe.com/v1"
    )

    if not api_key:
        print("Error: No API key provided.", file=sys.stderr)
        print("Please either:", file=sys.stderr)
        print("  1. Provide --api-key argument", file=sys.stderr)
        print("  2. Set NEWAPI_API_KEY environment variable", file=sys.stderr)
        sys.exit(1)

    return api_key, base_url


def extract_image_url(content: str) -> str | None:
    """Extract image URL from markdown format or plain text."""
    # Try markdown format: ![alt](url)
    markdown_pattern = r"!\[([^\]]*)\]\(([^)]+)\)"
    match = re.search(markdown_pattern, content)
    if match:
        return match.group(2)

    # Try plain URL format (https://...)
    url_pattern = r'https?://[^\s<>"]+?\.(?:png|jpg|jpeg|gif|webp)'
    match = re.search(url_pattern, content, re.IGNORECASE)
    if match:
        return match.group(0)

    return None


def generate_image(
    api_key: str,
    base_url: str,
    prompt: str,
    input_image_path: str | None = None,
    aspect_ratio: str | None = None,
    web_search: bool = False,
    image_only: bool = True,
    image_size: str = "1K",
) -> str:
    """Generate or edit image using NewAPI and return the image URL."""
    import base64

    from openai import OpenAI
    from PIL import Image as PILImage

    client = OpenAI(
        api_key=api_key,
        base_url=base_url,
    )

    # Build extra parameters
    extra_params = {}
    if aspect_ratio:
        extra_params["aspect_ratio"] = aspect_ratio
    if web_search:
        extra_params["web_search"] = True
    if image_only:
        extra_params["image_only"] = True
    if image_size:
        extra_params["image_size"] = image_size

    # Build messages with optional input image
    if input_image_path:
        # Load and encode input image
        pil_image = PILImage.open(input_image_path)
        buffered = BytesIO()
        pil_image.save(buffered, format="PNG")
        img_base64 = base64.b64encode(buffered.getvalue()).decode()

        messages = [
            {
                "role": "user",
                "content": [
                    {
                        "type": "image_url",
                        "image_url": {"url": f"data:image/png;base64,{img_base64}"},
                    },
                    {"type": "text", "text": prompt},
                ],
            }
        ]
        print(f"Loaded input image: {input_image_path}")
    else:
        messages = [{"role": "user", "content": prompt}]
</text>

<old_text line=89>
    print(f"Generating image with parameters:")
    print(f"  - image_size: {image_size}")
    print(f"  - aspect_ratio: {aspect_ratio or 'default'}")
    print(f"  - web_search: {web_search}")
    print(f"  - image_only: {image_only}")
    print()

    print(f"Generating image with parameters:")
    print(f"  - image_size: {image_size}")
    print(f"  - aspect_ratio: {aspect_ratio or 'default'}")
    print(f"  - web_search: {web_search}")
    print(f"  - image_only: {image_only}")
    print()

    try:
        response = client.chat.completions.create(
            model="nano-banana-pro",
            messages=messages,
            extra_body=extra_params if extra_params else None,
        )

        content = response.choices[0].message.content

        if not content:
            raise Exception("Empty response from API")

        print("Response received:")
        print("-" * 60)

        # Extract image URL
        image_url = extract_image_url(content)

        if not image_url:
            # Print full content if no image found
            print(content)
            print("-" * 60)
            raise Exception(
                "No image URL found in response. Try using --image-only flag."
            )

        # Print thinking process if present (everything before the image)
        markdown_pattern = r"!\[([^\]]*)\]\(([^)]+)\)"
        match = re.search(markdown_pattern, content)
        if match:
            thinking_text = content[: match.start()].strip()
            if thinking_text:
                print(thinking_text)
                print()

        print(f"Image URL: {image_url}")
        print("-" * 60)

        return image_url

    except Exception as e:
        print(f"Error calling API: {e}", file=sys.stderr)
        raise


def download_and_save_image(image_url: str, output_path: Path) -> None:
    """Download image from URL and save as PNG."""
    from PIL import Image as PILImage

    print(f"Downloading image from: {image_url}")

    try:
        # Download image
        with urllib.request.urlopen(image_url) as response:
            image_data = response.read()

        # Open with PIL
        image = PILImage.open(BytesIO(image_data))

        # Convert to RGB if necessary
        if image.mode == "RGBA":
            rgb_image = PILImage.new("RGB", image.size, (255, 255, 255))
            rgb_image.paste(image, mask=image.split()[3])
            rgb_image.save(str(output_path), "PNG")
        elif image.mode == "RGB":
            image.save(str(output_path), "PNG")
        else:
            image.convert("RGB").save(str(output_path), "PNG")

        print(f"✓ Image saved: {output_path.resolve()}")

    except Exception as e:
        print(f"Error downloading or saving image: {e}", file=sys.stderr)
        raise


def main():
    parser = argparse.ArgumentParser(
        description="Generate images using Nano Banana Pro via NewAPI (POE reverse proxy)"
    )

    # Required arguments
    parser.add_argument(
        "--prompt", "-p", required=True, help="Image description/prompt"
    )
    parser.add_argument(
        "--filename", "-f", required=True, help="Output filename (e.g., sunset.png)"
    )
    parser.add_argument(
        "--input-image", "-i", help="Optional input image path for editing/modification"
    )

    # API configuration
    parser.add_argument(
        "--api-key", "-k", help="NewAPI API key (overrides NEWAPI_API_KEY env var)"
    )
    parser.add_argument(
        "--base-url",
        help="NewAPI base URL (overrides NEWAPI_BASE_URL env var, default: https://api.poe.com/v1)",
    )

    # Image parameters
    parser.add_argument(
        "--image-size",
        choices=["1K", "2K", "4K"],
        default="1K",
        help="Resolution of image (default: 1K)",
    )
    parser.add_argument(
        "--aspect-ratio",
        choices=[
            "1:1",
            "2:3",
            "3:2",
            "3:4",
            "4:3",
            "4:5",
            "5:4",
            "9:16",
            "16:9",
            "21:9",
        ],
        help="Aspect ratio of the output image",
    )
    parser.add_argument(
        "--web-search",
        action="store_true",
        help="Enable web search and real-time information access",
    )
    parser.add_argument(
        "--image-only",
        action="store_true",
        default=True,
        help="Only generate image output (default: True, recommended)",
    )
    parser.add_argument(
        "--no-image-only",
        action="store_false",
        dest="image_only",
        help="Disable image-only mode (may include text response)",
    )

    args = parser.parse_args()

    # Get configuration
    api_key, base_url = get_config(args.api_key, args.base_url)

    # Set up output path
    output_path = Path(args.filename)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Validate input image if provided
    if args.input_image and not Path(args.input_image).exists():
        print(f"Error: Input image not found: {args.input_image}", file=sys.stderr)
        sys.exit(1)

    try:
        # Generate or edit image
        image_url = generate_image(
            api_key=api_key,
            base_url=base_url,
            prompt=args.prompt,
            input_image_path=args.input_image,
            aspect_ratio=args.aspect_ratio,
            web_search=args.web_search,
            image_only=args.image_only,
            image_size=args.image_size,
        )

        # Download and save
        download_and_save_image(image_url, output_path)

    except Exception as e:
        print(f"\nFailed to generate image: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
