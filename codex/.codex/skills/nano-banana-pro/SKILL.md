---
name: nano-banana-pro
description: Generate and edit images using Nano Banana Pro (Gemini 3 Pro Image Preview) via NewAPI reverse proxy for Poe. Use when the user asks to generate, create, draw, make, edit, modify, change, alter, or update images. Also use when user references an existing image file and asks to modify it in any way (e.g., "modify this image", "change the background", "replace X with Y"). Supports text-to-image generation and image-to-image editing with configurable resolution (1K, 2K, 4K), aspect ratios, and optional web search for real-time information. The model can create detailed, context-rich visuals, precisely edit or restyle input images with exceptional fidelity, and generate legible text in images in multiple languages.
---

# Nano Banana Pro Image Generation & Editing

Generate new images or edit existing ones using Nano Banana Pro (Gemini 3 Pro Image Preview) through NewAPI reverse proxy for POE.

## Usage

Run the script using absolute path (do NOT cd to skill directory first):

**Generate new image:**
```bash
uv run ~/.codex/skills/nano-banana-pro/scripts/generate_image.py --prompt "your image description" --filename "output-name.png" [OPTIONS]
```

**Edit existing image:**
```bash
uv run ~/.codex/skills/nano-banana-pro/scripts/generate_image.py --prompt "editing instructions" --filename "output-name.png" --input-image "path/to/input.png" [OPTIONS]
```

**Important:** Always run from the user's current working directory so images are saved where the user is working, not in the skill directory.

## API Configuration

The script requires NewAPI configuration for POE access:

1. `--api-key` argument (use if user provided key in chat)
2. `NEWAPI_API_KEY` environment variable

**Optional:** Custom NewAPI server URL
1. `--base-url` argument
2. `NEWAPI_BASE_URL` environment variable
3. Default: `https://api.poe.com/v1`

If no API key is provided, the script exits with an error message.

## Parameters

### Required
- `--prompt` / `-p`: Image description or editing instructions
- `--filename` / `-f`: Output filename (e.g., `sunset.png`)

### Optional Input
- `--input-image` / `-i`: Input image path for editing/modification
  - Use when user wants to modify an existing image
  - The prompt should contain editing instructions
  - Common editing tasks: add/remove elements, change style, adjust colors, restyle, blur background, etc.

### Optional Image Settings
- `--image-size`: Resolution of image
  - Options: `1K` (default), `2K`, `4K`
  - Map user requests:
    - "low resolution", "1080", "1080p", "1K", no mention → `1K`
    - "2K", "2048", "normal", "medium resolution" → `2K`
    - "high resolution", "high-res", "hi-res", "4K", "ultra" → `4K`

- `--aspect-ratio`: Aspect ratio of output image
  - Options: `1:1`, `2:3`, `3:2`, `3:4`, `4:3`, `4:5`, `5:4`, `9:16`, `16:9`, `21:9`
  - Map user requests:
    - "square" → `1:1`
    - "portrait", "vertical", "phone" → `9:16` or `2:3`
    - "landscape", "horizontal", "widescreen" → `16:9` or `3:2`
    - "ultrawide", "cinema" → `21:9`

### Optional Behavior Settings
- `--web-search`: Enable web search and real-time information access
  - Use when user asks for current events, latest trends, or real-time data
  - Example: "latest fashion trends 2024", "current Tesla model"

- `--image-only`: Only generate image output (default: `True`, **RECOMMENDED**)
  - Guarantees single image output
  - Prevents text responses

- `--no-image-only`: Disable image-only mode
  - May include thinking process and text explanation
  - Use only if user explicitly wants explanation

## Filename Generation

Generate filenames with the pattern: `yyyy-mm-dd-hh-mm-ss-name.png`

**Format:** `{timestamp}-{descriptive-name}.png`
- Timestamp: Current date/time in format `yyyy-mm-dd-hh-mm-ss` (24-hour format)
- Name: Descriptive lowercase text with hyphens
- Keep the descriptive part concise (1-5 words typically)
- Use context from user's prompt or conversation
- If unclear, use random identifier (e.g., `x9k2`, `a7b3`)

Examples:
- Prompt "A serene Japanese garden" → `2025-01-15-14-23-05-japanese-garden.png`
- Prompt "sunset over mountains" → `2025-01-15-15-30-12-sunset-mountains.png`
- Prompt "create a robot" → `2025-01-15-16-45-33-robot.png`
- Unclear context → `2025-01-15-17-12-48-x9k2.png`

## Prompt Handling

**For generation:** Pass user's image description as-is to `--prompt`.
- Only rework if clearly insufficient or ambiguous
- Preserve user's creative intent and specific details

**For editing:** Pass editing instructions in `--prompt`.
- Examples: "make the sky more dramatic", "remove the person", "change to cartoon style", "add a rainbow"
- Be specific about what to change

The model is highly capable and understands natural language well.

## Image Editing

When the user wants to modify an existing image:
1. Check if they provide an image path or reference an image in the current directory
2. Use `--input-image` parameter with the path to the image
3. The prompt should contain editing instructions (what to change/add/remove)
4. Common editing tasks:
   - Add or remove elements
   - Change artistic style or filter
   - Adjust colors, lighting, mood
   - Blur or focus specific areas
   - Replace objects or backgrounds
   - Restyle with exceptional fidelity

## Output

- Script downloads and saves PNG to current directory (or specified path)
- Displays thinking process if present (when not using `--image-only`)
- Outputs the full path to the generated image
- **Do not read the image back** - just inform the user of the saved path

## Examples

**Basic generation (1K, default settings):**
```bash
uv run ~/.codex/skills/nano-banana-pro/scripts/generate_image.py \
  --prompt "A serene Japanese garden with cherry blossoms" \
  --filename "2025-01-15-14-23-05-japanese-garden.png"
```

**High resolution 4K:**
```bash
uv run ~/.codex/skills/nano-banana-pro/scripts/generate_image.py \
  --prompt "Sleeping cat in cinematic film still, shallow depth of field" \
  --filename "2025-01-15-15-30-12-cinematic-cat.png" \
  --image-size 4K
```

**Widescreen with aspect ratio:**
```bash
uv run ~/.codex/skills/nano-banana-pro/scripts/generate_image.py \
  --prompt "Epic sunset over mountains" \
  --filename "2025-01-15-16-45-33-epic-sunset.png" \
  --image-size 2K \
  --aspect-ratio 21:9
```

**With web search for current information:**
```bash
uv run ~/.codex/skills/nano-banana-pro/scripts/generate_image.py \
  --prompt "Latest iPhone design 2024" \
  --filename "2025-01-15-17-12-48-iphone-2024.png" \
  --web-search
```

**Portrait mode for phone wallpaper:**
```bash
uv run ~/.codex/skills/nano-banana-pro/scripts/generate_image.py \
  --prompt "Minimalist mountain landscape" \
  --filename "2025-01-15-18-20-15-mountain-wallpaper.png" \
  --image-size 4K \
  --aspect-ratio 9:16
```

**Custom NewAPI server:**
```bash
uv run ~/.codex/skills/nano-banana-pro/scripts/generate_image.py \
  --prompt "Futuristic city" \
  --filename "2025-01-15-19-30-25-futuristic-city.png" \
  --base-url "https://your-newapi-server.com/v1" \
  --api-key "your-api-key"
```

**Edit existing image - change style:**
```bash
uv run ~/.codex/skills/nano-banana-pro/scripts/generate_image.py \
  --prompt "make it look like a watercolor painting" \
  --filename "2025-01-15-20-15-30-watercolor-edit.png" \
  --input-image "original-photo.jpg" \
  --image-size 2K
```

**Edit existing image - add elements:**
```bash
uv run ~/.codex/skills/nano-banana-pro/scripts/generate_image.py \
  --prompt "add dramatic storm clouds to the sky" \
  --filename "2025-01-15-20-30-45-dramatic-sky.png" \
  --input-image "landscape.png"
```

**Edit existing image - remove and restyle:**

```bash
uv run ~/.codex/skills/nano-banana-pro/scripts/generate_image.py \
  --prompt "remove the people and make it look more peaceful" \
  --filename "2025-01-15-20-45-12-peaceful-scene.png" \
  --input-image "crowded-beach.jpg" \
  --image-size 4K
```

## Model Capabilities

Nano Banana Pro (Gemini 3 Pro Image Preview) can:
- Create detailed, context-rich visuals
- Generate legible text in images in multiple languages
- Understand complex prompts and nuanced descriptions
- Create images in various artistic styles
- Generate photorealistic or stylized images
- Include specific objects, people, scenes, or concepts

## Model Capabilities

Nano Banana Pro (Gemini 3 Pro Image Preview) can:
- Create detailed, context-rich visuals
- Generate legible text in images in multiple languages
- Understand complex prompts and nuanced descriptions
- Create images in various artistic styles
- Generate photorealistic or stylized images
- Include specific objects, people, scenes, or concepts

## Tips

1. **Always use `--image-only` (default)** unless user explicitly wants explanation
2. **Be specific in prompts** - the model understands detailed descriptions
3. **Use `--input-image` for edits** - DO NOT read the image file first, pass path directly
4. **Use web search** when asking for current/real-time information
5. **Match aspect ratio to use case**:
   - Social media post → `1:1`
   - Phone wallpaper → `9:16`
   - Desktop wallpaper → `16:9` or `21:9`
   - Print/poster → `3:4` or `4:5`
6. **High resolution for quality** - use `4K` for professional/detailed work
7. **For editing:** Be clear about what to change, add, or remove in the prompt
