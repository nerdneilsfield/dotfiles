---
name: generate-figures
description: Scan document files (tex/md/typst) for figure prompts in comments, generate figures via AI, and insert them. Supports custom output directories or defaults to ./images/.
---

# Generate Figures from Comments

## Overview
Parse document files (.tex, .md, .typst) to find figure generation prompts in comments, generate figures using an AI image generation API, and optionally insert the figure references back into the document.

## Workflow
1. Scan the specified file for comment patterns containing figure prompts
2. Extract prompts and metadata (output filename, size, etc.)
3. Determine output directory (specified or default to `./images/`)
4. Generate figures via the configured runner (e.g., Nano Banana Pro)
5. Write provenance records (prompt, path, hash, timestamp)
6. Optionally update the document with figure references

## Comment Syntax

### LaTeX (.tex)
```latex
% FIGURE: prompt goes here
% OUTPUT: figure_name.png
% SIZE: 1024x1024
```

### Markdown (.md)
```markdown
<!-- FIGURE: prompt goes here -->
<!-- OUTPUT: figure_name.png -->
<!-- SIZE: 1024x1024 -->
```

### Typst (.typst)
```typst
// FIGURE: prompt goes here
// OUTPUT: figure_name.png
// SIZE: 1024x1024
```

## Scripts

### 1. Generate Prompts from ASCII Diagrams (RECOMMENDED)
Use `scripts/add_figure_prompts_llm_v2.py` to automatically generate prompts from ASCII diagrams in your document:

```bash
python3 ~/.claude/skills/generate-figures/scripts/add_figure_prompts_llm_v2.py \
  --file document.md \
  --output document_with_figures.md \
  --config ~/.config/skiils.toml
```

**Features:**
- Analyzes ASCII diagrams and surrounding context (100 lines)
- Uses LLM to generate detailed, context-specific prompts
- Automatic deduplication (similarity check)
- Outputs JSON with all prompts and metadata
- Records line numbers, chapter/section info, similarity scores

**Arguments:**
- `--file`: Input markdown file (required)
- `--output`: Output markdown file with FIGURE comments (required)
- `--config`: Config file (default: `~/.config/skiils.toml`)
- `--model`: LLM model for prompt generation (default: from config `chat_model`)
- `--api-key`: API key (overrides config)
- `--base-url`: API base URL (overrides config)

**Outputs:**
- `{output}.md` - Document with FIGURE/OUTPUT/SIZE comments
- `{output}_prompts.json` - Detailed JSON with all prompts, line numbers, similarity analysis

**JSON Structure:**
```json
{
  "metadata": {
    "generated_at": "2026-02-12T...",
    "total_figures": 38,
    "duplicates_detected": 2
  },
  "prompts": [
    {
      "index": 1,
      "line_number": 102,
      "chapter": "...",
      "section": "...",
      "subsection": "...",
      "output_filename": "fig_01_xxx.png",
      "prompt": "...",
      "size": "1920x1080",
      "similar_to": [...],
      "generated": false
    }
  ]
}
```

**Note:** The `generated` field tracks whether the image has been generated. It starts as `false` and is automatically updated to `true` after successful generation.

### 2. Generate Figures (Two Modes)

#### Mode A: From Document Comments (Original)
Use `scripts/generate_figures.py` to generate images from comment prompts in documents:

```bash
python3 ~/.claude/skills/generate-figures/scripts/generate_figures.py \
  --file document_with_figures.md \
  --outdir ./images \
  --config ~/.config/skiils.toml \
  --mode apply
```

#### Mode B: From JSON File (RECOMMENDED)
Use `scripts/generate_figures.py` with `--from-json` to generate images directly from the JSON prompts file:

```bash
python3 ~/.claude/skills/generate-figures/scripts/generate_figures.py \
  --from-json document_prompts.json \
  --outdir ./images \
  --config ~/.config/skiils.toml \
  --mode apply
```

**Key Features:**
- ✅ **Incremental generation**: Automatically skips images where `generated: true`
- ✅ **Auto-updates JSON**: Sets `generated: true` after successful generation
- ✅ **Resume support**: Can re-run to generate only failed/missing images
- ✅ **Parallel generation**: Uses config `image_model_parallel` for concurrent workers

**Arguments:**
- `--file`: Document file to scan (use this OR `--from-json`)
- `--from-json`: JSON file with prompts (use this OR `--file`)
- `--outdir`: Output directory for figures (default: `./images/` relative to input file)
- `--start-id`: Start index (inclusive, 1-based). Only used with `--from-json`
- `--end-id`: End index (exclusive, 1-based). Only used with `--from-json`
- `--runner`: Path to image generation runner (default: `tools/fig/nanobanana.py`)
- `--config`: Config file for API credentials (default: auto-detect `~/.config/skiils.toml`)
- `--model`: Image generation model name (overrides config `image_model`)
- `--mode`: `report` (dry-run) or `apply` (generate images)
- `--encoding`: File encoding (default: utf-8)

**Outputs:**
- Images in `--outdir`
- `figures_provenance.json` with generation metadata (prompt, hash, timestamp)
- Updated JSON file with `generated: true` for successful generations (only in `--from-json` mode)

### 3. Insert Figures into Document

Use `scripts/insert_figures.py` to replace ASCII diagrams with generated images:

```bash
python3 ~/.claude/skills/generate-figures/scripts/insert_figures.py \
  --file document.md \
  --output document_final.md \
  --json document_prompts.json \
  --image-dir ./images
```

**Key Features:**
- ✅ **Smart line offset tracking**: Handles line number changes as content is replaced
- ✅ **Only inserts generated images**: Checks `generated: true` in JSON
- ✅ **Preserves document structure**: Replaces ASCII blocks with markdown images
- ✅ **Automatic caption generation**: Uses section/subsection titles from JSON

**Arguments:**
- `--file`: Input markdown file (required)
- `--output`: Output markdown file with images inserted (required)
- `--json`: Prompts JSON file (required)
- `--image-dir`: Directory containing images, relative path (default: `./images`)
- `--encoding`: File encoding (default: utf-8)

**What it does:**
1. Reads prompts JSON and finds all figures with `generated: true`
2. For each figure, locates the ASCII diagram code block near `line_number`
3. Replaces the code block with markdown image syntax: `![caption](path)`
4. Tracks line number offsets to handle subsequent figures correctly

**Output format:**
```markdown
![图 1: 章节标题](./images/fig_01_xxx.png)
```

## Recommended Workflow

### Workflow 1: JSON-based (RECOMMENDED for large projects)

1. **Prepare document** with ASCII diagrams in code blocks
2. **Generate prompts**:
   ```bash
   python3 add_figure_prompts_llm_v2.py --file doc.md --output doc_out.md --config ~/.config/skiils.toml
   ```
   This creates `doc_out_prompts.json` with all prompts and `generated: false`
3. **Review JSON**: Check `doc_out_prompts.json` for duplicates/quality
4. **Generate images from JSON**:
   ```bash
   # Generate all images
   python3 generate_figures.py --from-json doc_out_prompts.json --outdir ./images --config ~/.config/skiils.toml --mode apply

   # Or generate in batches (useful for large sets)
   python3 generate_figures.py --from-json doc_out_prompts.json --outdir ./images --config ~/.config/skiils.toml --mode apply --start-id 1 --end-id 10
   python3 generate_figures.py --from-json doc_out_prompts.json --outdir ./images --config ~/.config/skiils.toml --mode apply --start-id 10 --end-id 20
   ```
   This updates JSON with `generated: true` for successful generations
5. **Resume if needed**: Re-run step 4 to retry failed images (skips already generated)
6. **Review images**: Check generated figures in `./images/`
7. **Insert images into document**:
   ```bash
   python3 insert_figures.py --file doc.md --output doc_final.md --json doc_out_prompts.json --image-dir ./images
   ```
   This replaces ASCII diagrams with markdown image references

**Batch Generation Examples:**
```bash
# Generate first 5 images: IDs [1, 5) = 1, 2, 3, 4
--start-id 1 --end-id 5

# Generate next 5 images: IDs [5, 10) = 5, 6, 7, 8, 9
--start-id 5 --end-id 10

# Generate from ID 20 to end
--start-id 20

# Generate first 10 images
--end-id 11
```

### Workflow 2: Direct from comments (simpler for small projects)

1. **Prepare document** with ASCII diagrams
2. **Generate prompts**: Run `add_figure_prompts_llm_v2.py` to add FIGURE comments
3. **Generate images**: Run `generate_figures.py --file doc.md --mode apply`
4. **Review images**: Check generated figures

**JSON workflow advantages:**
- Incremental generation (resume after failures)
- Easier to track progress (`generated` field)
- Can manually edit prompts in JSON before generating
- Better for large batches (38+ figures)

## Prompt Writing Best Practices

For **Nano Banana Pro** (and similar AI image generators), effective prompts should follow a structured approach:

### Core Prompt Structure (6 Modules)
```
Subject + Composition + Action + Location + Style + Technical Controls
```

**Key Tips:**
- **Be specific**: "a fluffy calico cat wearing a wizard hat" > "a cat"
- **Use professional terminology**: "85mm lens, f/1.8, rim lighting" > "nice photo"
- **Specify technical parameters**: "16:9 cinematic, 4K resolution"
- **For Chinese text**: Explicitly request "Chinese typography with proper character spacing"
- **For editing**: Use direct commands like "Remove the car" not "Could you remove..."

**Academic Figure Template:**
```
Create a [diagram/flowchart] showing [topic].
Structure: [list components and flow]
Style: Clean academic diagram, white background
Colors: Blue (#4A90E2) for primary, gray for secondary
Labels: All in Chinese, 14pt font, clear and readable
Title: "[图表标题]"
Aspect ratio: 16:9, 4K resolution
```

See `references/prompt_best_practices.md` for comprehensive guide with templates and examples.

## Configuration File

Create `~/.config/skiils.toml` with:

```toml
# API Configuration
api_key = "your-api-key"
base_url = "https://api.example.com/v1"

# Model Configuration
chat_model = "gpt-4"              # For prompt generation (add_figure_prompts_llm_v2.py)
image_model = "dall-e-3"          # For image generation (generate_figures.py)
image_model_parallel = 3          # Number of concurrent image generation workers

# Optional: Model-specific settings
temperature = 0.7
max_tokens = 4096
```

**Key Settings:**
- `chat_model`: LLM used to generate prompts from ASCII diagrams
- `image_model`: Model used to generate actual images (e.g., DALL-E 3, Nano Banana Pro)
- `image_model_parallel`: Number of concurrent workers (default: 1). Higher = faster but more API load

## Notes
- Output filenames should be descriptive (e.g., `ch1_registration_pipeline.png`)
- The images directory is created automatically if it doesn't exist
- Provenance is written to `{outdir}/figures_provenance.json`
- Default runner must accept `--prompt`, `--output`, `--config`, `--model`, `--size`, `--format` arguments
- Model can be specified via `--model` flag (highest priority) or `model` field in config file
