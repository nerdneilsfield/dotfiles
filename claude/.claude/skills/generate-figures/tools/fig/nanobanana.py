#!/usr/bin/env python3
"""Nano Banana Pro runner (OpenAI-compatible client)."""

from __future__ import annotations

import argparse
import base64
import os
import re
import sys
import urllib.request
from pathlib import Path

EXIT_OK = 0
EXIT_MISSING_DEP = 2
EXIT_RUNTIME = 10
DEFAULT_CONFIG = "~/.config/skiils.toml"


def _extract_first_url(text: str) -> str | None:
    # Prefer Markdown reference-style links: [id]: URL
    ref_links = re.findall(r"^\[[^\]]+\]:\s*(\S+)", text, flags=re.M)
    if ref_links:
        return ref_links[0]
    # Fallback: any URL
    urls = re.findall(r"https?://\S+", text)
    return urls[0] if urls else None


def _save_base64_image(data_url: str, output: Path) -> None:
    """Save a base64-encoded data URL to file."""
    output.parent.mkdir(parents=True, exist_ok=True)

    # Extract base64 data from data URL (e.g., "data:image/jpeg;base64,...")
    if "," in data_url:
        base64_data = data_url.split(",", 1)[1]
    else:
        base64_data = data_url

    image_data = base64.b64decode(base64_data)
    output.write_bytes(image_data)


def _download(url: str, output: Path) -> None:
    """Download an image from HTTP/HTTPS URL."""
    output.parent.mkdir(parents=True, exist_ok=True)
    req = urllib.request.Request(url, headers={"User-Agent": "nanobanana-runner"})
    with urllib.request.urlopen(req) as resp, output.open("wb") as f:
        f.write(resp.read())


def _save_image(url_or_data: str, output: Path) -> None:
    """Save image from URL or base64 data URL."""
    if url_or_data.startswith("data:"):
        # Base64 data URL
        _save_base64_image(url_or_data, output)
    elif url_or_data.startswith(("http://", "https://")):
        # Regular URL
        _download(url_or_data, output)
    else:
        # Try as base64 data directly
        try:
            image_data = base64.b64decode(url_or_data)
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_bytes(image_data)
        except Exception as exc:
            raise ValueError(f"Unknown image format: {url_or_data[:50]}...") from exc

def _load_config(path: Path) -> dict:
    if not path.exists():
        raise FileNotFoundError(f"config not found: {path}")
    try:
        import tomllib  # py3.11+
    except Exception as exc:  # pragma: no cover
        raise RuntimeError(f"tomllib not available: {exc}") from exc
    data = tomllib.loads(path.read_text(encoding="utf-8"))
    if isinstance(data.get("nanobanana"), dict):
        return data["nanobanana"]
    return data


def _truncate_base64(text: str, max_length: int = 100) -> str:
    """Truncate base64 data in text for cleaner logs."""
    import re
    text_str = str(text)

    # Pattern 1: Replace data URL base64 (data:image/...;base64,XXXXX)
    text_str = re.sub(
        r'(data:image/[^;]+;base64,)[A-Za-z0-9+/=]{100,}',
        r'\1<base64_truncated>',
        text_str
    )

    # Pattern 2: Replace inline base64 in 'data': 'XXXXX' format
    text_str = re.sub(
        r"('data':\s*')[A-Za-z0-9+/=]{100,}(')",
        r"\1<base64_truncated>\2",
        text_str
    )

    # Pattern 3: Replace inline base64 in "data": "XXXXX" format
    text_str = re.sub(
        r'("data":\s*")[A-Za-z0-9+/=]{100,}(")',
        r'\1<base64_truncated>\2',
        text_str
    )

    return text_str


def _resolve_auth(args: argparse.Namespace) -> tuple[str | None, str | None]:
    cfg_key = None
    cfg_base = None
    if args.config:
        cfg_path = Path(args.config).expanduser()
        if cfg_path.exists():
            cfg = _load_config(cfg_path)
            cfg_key = cfg.get("api_key")
            cfg_base = cfg.get("api_base_url")
        elif args.config != DEFAULT_CONFIG:
            raise FileNotFoundError(f"config not found: {cfg_path}")

    api_key = (
        args.api_key
        or cfg_key
        or os.getenv("POE_API_KEY")
        or os.getenv("OPENAI_API_KEY")
        or os.getenv("NANO_BANANA_API_KEY")
    )
    base_url = (
        args.base_url
        or cfg_base
        or os.getenv("POE_BASE_URL")
        or os.getenv("OPENAI_BASE_URL")
        or os.getenv("NANO_BANANA_BASE_URL")
    )
    return api_key, base_url


def generate_image(prompt: str, output: str, config: str | None = None, model: str | None = None,
                   api_key: str | None = None, base_url: str | None = None) -> int:
    """Generate image directly without argparse. Returns EXIT_OK on success."""
    # Create a mock args object
    class Args:
        pass

    args = Args()
    args.prompt = prompt
    args.output = output
    args.config = config or DEFAULT_CONFIG
    args.model = model
    args.api_key = api_key
    args.base_url = base_url
    args.size = None
    args.format = None

    # Rest of the logic from main()
    try:
        api_key, base_url = _resolve_auth(args)
    except Exception as exc:
        sys.stderr.write(f"Config error: {exc}\n")
        return EXIT_MISSING_DEP

    if not api_key or not base_url:
        sys.stderr.write(
            "Missing API key or base URL. Set env vars, pass api_key/base_url, "
            "or use config with api_key/api_base_url.\n"
        )
        return EXIT_MISSING_DEP

    # Determine model (priority: arg > config file > default)
    model = args.model
    if not model and args.config:
        cfg_path = Path(args.config).expanduser()
        if cfg_path.exists():
            try:
                cfg = _load_config(cfg_path)
                model = cfg.get("model") or cfg.get("image_model")
            except Exception:
                pass
    if not model:
        model = "nano-banana-pro"

    try:
        import openai  # type: ignore
    except Exception as exc:
        sys.stderr.write(f"Missing dependency: openai ({exc}).\n")
        return EXIT_MISSING_DEP

    # Continue with API call and image extraction (same as main())
    return _call_api_and_save(openai, api_key, base_url, model, args.prompt, Path(args.output))


def _call_api_and_save(openai, api_key: str, base_url: str, model: str, prompt: str, output_path: Path) -> int:
    """Call API and save image. Extracted from main() for reuse."""
    try:
        client = openai.OpenAI(api_key=api_key, base_url=base_url)
        chat = client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": prompt}],
        )

        # Try to extract image from different response formats
        image_url = None

        choice = chat.choices[0]

        # Format 1: multi_mod_content in delta (NEW FORMAT - Gemini)
        if hasattr(choice, "delta") and choice.delta:
            delta = choice.delta
            if hasattr(delta, "multi_mod_content") and delta.multi_mod_content:
                try:
                    inline_data = None
                    if isinstance(delta.multi_mod_content[0], dict):
                        inline_data = delta.multi_mod_content[0].get("inline_data")
                    elif hasattr(delta.multi_mod_content[0], "inline_data"):
                        inline_data = delta.multi_mod_content[0].inline_data

                    if inline_data:
                        base64_data = None
                        mime_type = None

                        if isinstance(inline_data, dict):
                            base64_data = inline_data.get("data")
                            mime_type = inline_data.get("mime_type", "image/jpeg")
                        else:
                            base64_data = getattr(inline_data, "data", None)
                            mime_type = getattr(inline_data, "mime_type", "image/jpeg")

                        if base64_data:
                            if not base64_data.startswith("data:"):
                                image_url = f"data:{mime_type};base64,{base64_data}"
                            else:
                                image_url = base64_data
                except (IndexError, AttributeError, TypeError):
                    pass

        # Format 1b: multi_mod_content in message (NEW FORMAT - Gemini non-streaming)
        if not image_url and hasattr(choice, "message") and choice.message:
            message = choice.message
            if hasattr(message, "multi_mod_content") and message.multi_mod_content:
                try:
                    inline_data = None
                    if isinstance(message.multi_mod_content[0], dict):
                        inline_data = message.multi_mod_content[0].get("inline_data")
                    elif hasattr(message.multi_mod_content[0], "inline_data"):
                        inline_data = message.multi_mod_content[0].inline_data

                    if inline_data:
                        base64_data = None
                        mime_type = None

                        if isinstance(inline_data, dict):
                            base64_data = inline_data.get("data")
                            mime_type = inline_data.get("mime_type", "image/jpeg")
                        else:
                            base64_data = getattr(inline_data, "data", None)
                            mime_type = getattr(inline_data, "mime_type", "image/jpeg")

                        if base64_data:
                            if not base64_data.startswith("data:"):
                                image_url = f"data:{mime_type};base64,{base64_data}"
                            else:
                                image_url = base64_data
                except (IndexError, AttributeError, TypeError):
                    pass

        # Format 2: images in message
        if not image_url and hasattr(choice, "message") and choice.message:
            message = choice.message
            if hasattr(message, "images") and message.images:
                try:
                    if isinstance(message.images[0], dict):
                        image_url = message.images[0].get("image_url", {}).get("url")
                    elif hasattr(message.images[0], "image_url"):
                        if isinstance(message.images[0].image_url, dict):
                            image_url = message.images[0].image_url.get("url")
                        else:
                            image_url = message.images[0].image_url.url
                except (IndexError, AttributeError, TypeError):
                    pass

        # Format 3: images in delta (OLD FORMAT)
        if not image_url and hasattr(choice, "delta") and choice.delta:
            delta = choice.delta
            if hasattr(delta, "images") and delta.images:
                try:
                    if isinstance(delta.images[0], dict):
                        image_url = delta.images[0].get("image_url", {}).get("url")
                    elif hasattr(delta.images[0], "image_url"):
                        if isinstance(delta.images[0].image_url, dict):
                            image_url = delta.images[0].image_url.get("url")
                        else:
                            image_url = delta.images[0].image_url.url
                except (IndexError, AttributeError, TypeError):
                    pass

        # Format 4: URL in message content
        if not image_url:
            content = getattr(getattr(choice, "message", None), "content", None) or ""
            if content:
                image_url = _extract_first_url(content)

        # Format 5: Markdown image with data URL (NEW FORMAT - Gemini 3 Pro)
        # Example: ![image](data:image/jpeg;base64,<base64_data>)
        if not image_url:
            content = getattr(getattr(choice, "message", None), "content", None) or ""
            if content:
                # Extract data URL from markdown image syntax
                markdown_image_match = re.search(r'!\[.*?\]\((data:image/[^)]+)\)', content)
                if markdown_image_match:
                    image_url = markdown_image_match.group(1)

        if not image_url:
            sys.stderr.write("No image URL or data found in model output.\n")
            try:
                import json
                response_dict = chat.model_dump() if hasattr(chat, 'model_dump') else chat.dict()
                response_str = json.dumps(response_dict, indent=2, ensure_ascii=False)
                response_str = _truncate_base64(response_str)
                sys.stderr.write(f"Response structure:\n{response_str}\n")
            except Exception as e:
                sys.stderr.write(f"Response: {_truncate_base64(repr(chat))}\n")
            return EXIT_RUNTIME

    except Exception as exc:
        error_str = _truncate_base64(str(exc))
        sys.stderr.write(f"API call failed: {error_str}\n")
        return EXIT_RUNTIME

    try:
        _save_image(image_url, output_path)
    except Exception as exc:
        sys.stderr.write(f"Failed to save image: {exc}\n")
        return EXIT_RUNTIME

    return EXIT_OK


def main() -> int:
    parser = argparse.ArgumentParser(description="Run Nano Banana Pro and download image")
    parser.add_argument("--prompt", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--model", default=None)
    parser.add_argument("--api-key", default=None)
    parser.add_argument("--base-url", default=None)
    parser.add_argument("--size", default=None, help="Image size (ignored by this runner)")
    parser.add_argument("--format", default=None, help="Image format (ignored by this runner)")
    parser.add_argument(
        "--config",
        default=DEFAULT_CONFIG,
        help="TOML config with api_key/api_base_url/model",
    )
    args = parser.parse_args()

    # Use the generate_image function
    return generate_image(
        prompt=args.prompt,
        output=args.output,
        config=args.config,
        model=args.model,
        api_key=args.api_key,
        base_url=args.base_url
    )


if __name__ == "__main__":
    raise SystemExit(main())
