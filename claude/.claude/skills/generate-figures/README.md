# Generate Figures Skill

一个全局 Claude Code skill，用于从文档注释中自动生成 AI 图片。

## 功能特性

✅ **多格式支持**：LaTeX (.tex)、Markdown (.md)、Typst (.typ)
✅ **智能图片目录**：可指定或自动使用 `./images/` 目录
✅ **配置文件支持**：自动检测 `~/.config/skiils.toml`
✅ **模型可配置**：支持命令行或配置文件指定模型
✅ **Prompt 最佳实践**：内置 Nano Banana Pro 专业提示词指南
✅ **Prompt 优化工具**：分析和优化提示词质量

## 快速开始

### 1. 在文档中添加图片提示

**LaTeX:**
```latex
% FIGURE: Create a flowchart showing point cloud registration pipeline...
% OUTPUT: ch2_registration.png
% SIZE: 3840x2160
```

**Markdown:**
```markdown
<!-- FIGURE: Create a comparison diagram of Method A vs Method B... -->
<!-- OUTPUT: method_comparison.png -->
```

**Typst:**
```typst
// FIGURE: Generate neural network architecture diagram...
// OUTPUT: network_arch.png
// SIZE: 2048x1536
```

### 2. 生成图片

```bash
# 预览模式
python3 ~/.claude/skills/generate-figures/scripts/generate_figures.py \
  --file document.tex \
  --mode report

# 实际生成
python3 ~/.claude/skills/generate-figures/scripts/generate_figures.py \
  --file document.tex \
  --mode apply
```

### 3. 使用配置文件（可选）

创建 `~/.config/skiils.toml`：
```toml
api_key = "YOUR_API_KEY"
api_base_url = "https://api.example.com"
model = "nano-banana-pro"
```

## 工具集

### 主脚本
```bash
~/.claude/skills/generate-figures/scripts/generate_figures.py
```
扫描文档、生成图片、记录 provenance

### ASCII 图表注释生成工具
```bash
~/.claude/skills/generate-figures/scripts/add_figure_prompts.py
```
**自动为 ASCII 图表添加生成注释**

- 深度分析 ASCII 图的内容和结构
- 结合上下文理解图表含义
- 生成准确的英文 prompt（中文用引号包裹）
- 支持多种图表类型：几何图、流程图、数据结构、对比图等

**使用方法：**
```bash
python3 add_figure_prompts.py \
  --file input.md \
  --output output_with_prompts.md
```

### Prompt 优化工具
```bash
~/.claude/skills/generate-figures/scripts/optimize_prompt.py
```

**分析提示词：**
```bash
# 从命令行
python3 optimize_prompt.py "Create a diagram showing..."

# 从文件
python3 optimize_prompt.py --file my_prompt.txt

# 从 stdin
echo "Create a flowchart..." | python3 optimize_prompt.py
```

**获取模板：**
```bash
python3 optimize_prompt.py --template diagram
python3 optimize_prompt.py --template flowchart
python3 optimize_prompt.py --template comparison
python3 optimize_prompt.py --template photo
```

## 参考文档

### 核心文档
- **SKILL.md** - Skill 说明和使用方法
- **usage.md** - 详细使用指南和示例
- **prompt_best_practices.md** - ⭐ Nano Banana Pro 提示词完整指南

### Prompt 最佳实践速查

**6模块结构：**
```
主体 + 构图 + 行为 + 场景 + 风格 + 技术参数
```

**学术图表模板：**
```
Create a [diagram type] showing [topic].
Structure: [components and flow]
Style: Clean academic diagram, white background
Colors: Blue (#4A90E2) for primary
Labels: All in Chinese, 14pt, clear font
Title: "[中文标题]"
Aspect ratio: 16:9, 4K resolution
```

**关键技巧：**
- 使用专业术语：`85mm f/1.8` > "nice photo"
- 量化参数：`shallow DOF (f/1.4)` > "blurry"
- 中文标签：明确要求 "Chinese typography"
- 指定分辨率：`4K` / `2K` / `300 DPI`

## 命令行参数

```bash
--file      # 文档文件路径（必需）
--outdir    # 输出目录（默认：./images/）
--runner    # 图片生成器路径（默认：tools/fig/nanobanana.py）
--config    # 配置文件（默认：~/.config/skiils.toml）
--model     # 模型名称（覆盖配置文件）
--mode      # report（预览）或 apply（生成）
--encoding  # 文件编码（默认：utf-8）
--format    # 默认图片格式（默认：png）
```

## 示例工作流

### 论文配图生成

1. **编写提示词：**
```latex
% FIGURE: Create a technical diagram illustrating the registration pipeline. Show: Input point clouds → Feature extraction → Matching → Alignment → Output. Style: Clean academic, white background. Colors: Blue (#4A90E2) for source, Orange (#F59E0B) for target. Layout: Horizontal flow. Labels: Chinese 14pt. Title: "点云配准流程". Tech: 16:9, 4K.
% OUTPUT: fig_pipeline.png
```

2. **优化提示词（可选）：**
```bash
python3 optimize_prompt.py --file chapter2.tex
```

3. **预览：**
```bash
python3 generate_figures.py --file chapter2.tex --mode report
```

4. **生成：**
```bash
python3 generate_figures.py --file chapter2.tex --mode apply
```

5. **检查结果：**
```bash
ls images/
cat images/figures_provenance.json
```

## 高级用法

### 指定不同模型
```bash
python3 generate_figures.py \
  --file document.tex \
  --model "gpt-4-dalle" \
  --mode apply
```

### 自定义 runner
```bash
python3 generate_figures.py \
  --file document.tex \
  --runner ~/bin/my_generator.py \
  --mode apply
```

### 批量处理
```bash
for file in chapters/*.tex; do
  python3 generate_figures.py --file "$file" --mode apply
done
```

## Provenance 记录

生成的图片会自动记录 provenance 到 `{outdir}/figures_provenance.json`：

```json
[
  {
    "prompt": "Create a diagram...",
    "output_path": "/path/to/image.png",
    "line_number": 42,
    "generator_command": "runner.py --prompt '...' --output '...'",
    "timestamp": "2026-02-12T10:30:00",
    "sha256": "abc123...",
    "success": true
  }
]
```

## 故障排查

**没找到提示词？**
- 检查注释语法是否正确
- 确认 `FIGURE:` 关键字存在
- 验证文件编码（使用 `--encoding`）

**Runner 未找到？**
- 检查 runner 路径
- 确保 runner 可执行：`chmod +x runner.py`

**生成失败？**
- 查看 provenance JSON 的错误信息
- 检查 API 配置和凭证
- 验证 runner 可独立运行

## 更多资源

- [Google Nano Banana Pro 官方指南](https://blog.google/products-and-platforms/products/gemini/prompting-tips-nano-banana-pro/)
- [Prompt Engineering 最佳实践](https://www.datalearner.com/blog/1051763659266413)
- 完整提示词库：`references/prompt_best_practices.md`

## 贡献者

参考了 `.codex/skills/thesis-fig-generate-sample-figure-nanobanana/` 的设计模式。
