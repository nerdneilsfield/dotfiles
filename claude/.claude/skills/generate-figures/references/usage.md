# Generate Figures Skill - Usage Guide

## Quick Start

### 1. Add figure prompts to your document

#### LaTeX Example
```latex
\section{Introduction}

% FIGURE: A diagram showing the data processing pipeline with input, preprocessing, and output stages
% OUTPUT: ch1_pipeline.png
% SIZE: 1024x768

\begin{figure}[h]
  \centering
  % \includegraphics[width=0.8\textwidth]{images/ch1_pipeline.png}
  \caption{Data processing pipeline}
  \label{fig:pipeline}
\end{figure}
```

#### Markdown Example
```markdown
## Architecture

<!-- FIGURE: System architecture diagram showing frontend, backend, and database layers -->
<!-- OUTPUT: system_arch.png -->
<!-- SIZE: 1200x800 -->

![System Architecture](images/system_arch.png)
```

#### Typst Example
```typst
= Introduction

// FIGURE: Network topology with nodes and connections
// OUTPUT: network_topology.png
// SIZE: 1024x1024

#figure(
  image("images/network_topology.png", width: 80%),
  caption: [Network Topology]
)
```

### 2. Generate figures

**Dry run (report mode):**
```bash
python3 ~/.claude/skills/generate-figures/scripts/generate_figures.py \
  --file document.tex \
  --mode report
```

**Actually generate (apply mode):**
```bash
python3 ~/.claude/skills/generate-figures/scripts/generate_figures.py \
  --file document.tex \
  --outdir ./images \
  --runner tools/fig/nanobanana.py \
  --config ~/.config/skiils.toml \
  --mode apply
```

### 3. Check provenance
```bash
cat ./images/figures_provenance.json
```

## Comment Syntax Reference

### Required Field
- `FIGURE: <prompt>` - The image generation prompt (required)

### Optional Fields
- `OUTPUT: <filename>` - Specify output filename (default: auto-generated)
- `SIZE: <WxH>` - Image dimensions, e.g., `1024x768` (default: depends on runner)

### Notes
- Fields must appear in consecutive comment lines
- The prompt block ends when a non-comment line is encountered
- If OUTPUT is not specified, filename is auto-generated from prompt + timestamp
- **For best results**, follow the prompt structure in `prompt_best_practices.md`

## Writing Effective Prompts

### Quick Reference: 6-Module Prompt Structure

```
[Subject] + [Composition] + [Action] + [Location] + [Style] + [Technical]
```

### Academic Figure Example

```latex
% FIGURE: Create a flowchart diagram showing the point cloud registration pipeline. Structure: Input raw point clouds → Feature extraction (FPFH) → Correspondence matching → Transformation estimation → ICP refinement → Output aligned clouds. Style: Clean academic diagram with white background. Colors: Blue (#4A90E2) for source, Orange (#F59E0B) for target. Layout: Horizontal flow left to right with arrows. Labels: All in Chinese, 14pt clear font. Title: "点云配准算法流程图". Aspect ratio: 16:9, 4K resolution, professional quality.
% OUTPUT: ch2_registration_pipeline.png
% SIZE: 3840x2160
```

### Comparison Visualization Example

```markdown
<!-- FIGURE: Create a side-by-side comparison of Method A vs Method B results. Left panel shows traditional ICP with point clouds in gray, right panel shows our method with points in vibrant colors. Center has large "vs" divider. Each panel includes method name in Chinese at top and accuracy metrics below. Style: Clean scientific presentation, light gray background. Resolution: 4K, 16:9 for presentation slides. -->
<!-- OUTPUT: ch3_method_comparison.png -->
<!-- SIZE: 3840x2160 -->
```

### Diagram with Annotations Example

```typst
// FIGURE: Generate a technical diagram illustrating the neural network architecture. Show: Input layer (256 nodes) → Conv layer 1 (128) → ReLU → Conv layer 2 (64) → Fully connected (32) → Output (10 classes). Use boxes for layers connected by arrows. Add annotations in Chinese showing dimensions. Colors: Blue gradient for conv layers, orange for FC layers. Background: White. Labels: Clear Chinese typography. Style: Professional technical diagram. Resolution: 2K, aspect ratio 4:3 for paper.
// OUTPUT: ch4_network_architecture.png
// SIZE: 2048x1536
```

### Key Tips for Academic Figures

1. **Always specify Chinese labels**: "Labels: All in Chinese, [font size], clear and readable"
2. **Use color codes**: Specify exact hex colors for reproducibility
3. **Mention layout**: "Horizontal flow" / "Vertical hierarchy" / "Circular arrangement"
4. **Request clean style**: "Clean academic diagram" / "Professional scientific visualization"
5. **Specify resolution**: "4K for presentation" / "300 DPI for print" / "2K for paper"

See `prompt_best_practices.md` for comprehensive guide with templates and detailed examples.

## Configuration

### Runner Script
The runner script must accept these arguments:
- `--prompt <text>` - Image generation prompt
- `--output <path>` - Output file path
- `--config <path>` - (optional) Config file with API credentials
- `--model <name>` - (optional) Model name to use for generation
- `--size <WxH>` - (optional) Image dimensions
- `--format <ext>` - (optional) Image format (png, jpg, etc.)

See `~/.codex/skills/thesis-fig-generate-sample-figure-nanobanana/references/nanobanana_api.md` for API usage example.

### Config File Format (TOML)
```toml
api_key = "YOUR_API_KEY"
api_base_url = "https://api.example.com"
model = "nano-banana-pro"  # Optional: default model name
```

**Default location**: `~/.config/skiils.toml`

If `--config` is not specified and `~/.config/skiils.toml` exists, it will be automatically used. You can also explicitly specify a config file with `--config /path/to/config.toml`.

**Model priority**: Command-line `--model` > Config file `model` field > Runner's default

## Examples

### Process a thesis chapter (using default config)
```bash
python3 ~/.claude/skills/generate-figures/scripts/generate_figures.py \
  --file chapters/chapter1.tex \
  --outdir chapters/images \
  --mode apply
```

Note: This will automatically use `~/.config/skiils.toml` if it exists.

### Process a markdown document with custom runner
```bash
python3 ~/.claude/skills/generate-figures/scripts/generate_figures.py \
  --file README.md \
  --runner ~/bin/my_image_gen.py \
  --mode apply
```

### Different file encoding
```bash
python3 ~/.claude/skills/generate-figures/scripts/generate_figures.py \
  --file document.tex \
  --encoding gbk \
  --mode apply
```

### Specify custom model
```bash
python3 ~/.claude/skills/generate-figures/scripts/generate_figures.py \
  --file document.tex \
  --model "gpt-4-dalle" \
  --mode apply
```

Note: The `--model` parameter overrides the model specified in the config file.

## Provenance Output

The script generates `figures_provenance.json` in the output directory:

```json
[
  {
    "prompt": "System architecture diagram",
    "output_path": "/path/to/images/system_arch.png",
    "line_number": 42,
    "generator_command": "tools/fig/nanobanana.py --prompt '...' --output '...'",
    "timestamp": "2024-02-12T10:30:00",
    "sha256": "abc123...",
    "success": true
  }
]
```

## Troubleshooting

### No prompts found
- Check comment syntax matches your document type
- Ensure FIGURE: keyword is present
- Verify file encoding with `--encoding`

### Runner not found
- Specify correct path with `--runner`
- Ensure runner script is executable: `chmod +x runner.py`

### Generation fails
- Check API credentials in config file
- Verify runner script works standalone
- Check provenance JSON for error messages
