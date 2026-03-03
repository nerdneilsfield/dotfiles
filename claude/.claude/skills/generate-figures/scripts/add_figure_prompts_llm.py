#!/usr/bin/env python3
"""
使用 LLM 分析 ASCII 图并生成图片 prompt (支持并发)
"""
import argparse
import os
import re
import sys
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import NamedTuple

try:
    import openai
except ImportError:
    print("Error: openai library not found. Install with: pip install openai")
    sys.exit(2)

try:
    import tomllib
except ImportError:
    try:
        import tomli as tomllib
    except ImportError:
        tomllib = None

DEFAULT_CONFIG = "~/.config/skiils.toml"

class FigureTask(NamedTuple):
    """图表处理任务"""
    index: int
    ascii_content: str
    context: dict
    code_block_content: list
    line_number: int

def load_config(config_path):
    """加载配置文件"""
    if not config_path or not config_path.exists():
        return {}
    if tomllib is None:
        return {}
    try:
        with config_path.open("rb") as f:
            return tomllib.load(f)
    except Exception as e:
        print(f"Warning: Failed to parse config: {e}")
        return {}

def extract_context(lines, start_idx, end_idx, context_lines=30):
    """提取 ASCII 图周围的上下文"""
    # 向前查找
    context_before = []
    section_title = None
    subsection_title = None

    for i in range(max(0, start_idx - context_lines), start_idx):
        line = lines[i].strip()
        if line.startswith('###'):
            subsection_title = line.replace('#', '').strip()
        elif line.startswith('##'):
            section_title = line.replace('#', '').strip()
        elif line and not line.startswith('```'):
            context_before.append(line)

    # 向后查找
    context_after = []
    for i in range(end_idx + 1, min(len(lines), end_idx + 10)):
        line = lines[i].strip()
        if line and not line.startswith('```') and not line.startswith('#'):
            context_after.append(line)

    return {
        'section': section_title,
        'subsection': subsection_title,
        'before': '\n'.join(context_before[-15:]),
        'after': '\n'.join(context_after[:5])
    }

def generate_prompt_via_llm(ascii_content, context, client, model):
    """使用 LLM 生成图片 prompt"""

    meta_prompt = f"""You are an expert at creating image generation prompts for academic diagrams.

I have an ASCII diagram from a Chinese academic paper about point cloud registration algorithms (4PCS family). I need you to analyze the ASCII diagram and its context, then generate a detailed, accurate English prompt for an AI image generator (Nano Banana Pro) to create a professional academic figure.

**Section**: {context['section'] or 'N/A'}
**Subsection**: {context['subsection'] or 'N/A'}

**Context before the diagram:**
{context['before']}

**ASCII Diagram:**
```
{ascii_content}
```

**Context after the diagram:**
{context['after']}

Please analyze this diagram and generate a detailed English prompt for image generation. The prompt should:

1. **Identify the diagram type** (flowchart, geometric diagram, data structure, comparison, etc.)
2. **Extract key content**:
   - For flowcharts: algorithm name, inputs, outputs, main steps, complexity
   - For geometric diagrams: points, lines, relationships, invariants, formulas
   - For data structures: organization, access patterns, key operations
3. **Include all Chinese text** that should appear in the image (put Chinese in quotes "")
4. **Specify visual style**: Academic style, colors (blue #4A90E2 for primary, orange #F5A623 for highlights), layout
5. **Be detailed and specific**: Include all steps, formulas, labels from the ASCII diagram
6. **For flowcharts with many steps**: Specify "Vertical flowchart, top-to-bottom progression" in the Layout section

Output ONLY the image generation prompt in English, with Chinese text in quotes. Make it comprehensive and detailed (200-400 words).

Format:
Create a [diagram type] showing "[Chinese title]".

[Detailed description of content, structure, and elements]

Style: Academic [type], professional and clean
Background: Pure white
Colors: [specific color scheme]
Labels: All text in Chinese, [specific requirements]
Layout: [specific layout requirements - specify "Vertical" for multi-step flowcharts]
Aspect ratio: 16:9, high resolution"""

    try:
        response = client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": meta_prompt}],
            temperature=0.3,
            max_tokens=2000
        )
        prompt = response.choices[0].message.content.strip()
        return prompt
    except Exception as e:
        print(f"Error calling LLM: {e}")
        return None

def determine_size(prompt, ascii_content):
    """根据 prompt 和 ASCII 内容智能判断图片尺寸

    Returns:
        str: 尺寸字符串，如 "1920x1080" 或 "1080x1920"
    """
    prompt_lower = prompt.lower()
    ascii_lower = ascii_content.lower()

    # 检查是否是纵向流程图
    vertical_keywords = [
        'vertical flowchart',
        'top-to-bottom progression',
        'flowchart diagram',
        'algorithm flowchart'
    ]

    # 检查 ASCII 内容的行数和结构
    ascii_lines = [line.strip() for line in ascii_content.split('\n') if line.strip()]
    is_tall = len(ascii_lines) > 15  # 超过15行的图可能适合竖向

    # 检查是否包含多步骤流程
    has_steps = any(keyword in ascii_lower for keyword in ['step', '步骤', 'for', 'while', 'loop'])

    # 判断逻辑
    is_vertical = (
        any(keyword in prompt_lower for keyword in vertical_keywords) or
        (is_tall and has_steps)
    )

    if is_vertical:
        return "1080x1920"  # 竖向
    else:
        return "1920x1080"  # 横向（默认）

def process_single_figure(task, client, model):
    """处理单个图表 (用于并发)"""
    try:
        prompt = generate_prompt_via_llm(task.ascii_content, task.context, client, model)
        if not prompt:
            prompt = f"Create a diagram for {task.context['subsection'] or 'figure'}."

        # 智能判断尺寸
        size = determine_size(prompt, task.ascii_content)

        # 根据尺寸调整 prompt 中的 aspect ratio
        if size == "1080x1920":  # 竖向
            # 替换 aspect ratio 为 9:16
            prompt = prompt.replace("Aspect ratio: 16:9", "Aspect ratio: 9:16 (vertical)")
            prompt = prompt.replace("aspect ratio: 16:9", "aspect ratio: 9:16 (vertical)")
            # 如果没有找到，添加到末尾
            if "aspect ratio" not in prompt.lower():
                prompt = prompt.rstrip() + " Aspect ratio: 9:16 (vertical), high resolution"
        else:  # 横向
            # 确保有 aspect ratio
            if "aspect ratio" not in prompt.lower():
                prompt = prompt.rstrip() + " Aspect ratio: 16:9, high resolution"

        return task.index, prompt, size, None
    except Exception as e:
        return task.index, None, "1920x1080", str(e)

def process_file(input_file, output_file, client, model, max_workers=4):
    """处理文件，使用 LLM 并发生成 prompts"""
    input_path = Path(input_file)
    output_path = Path(output_file)

    with open(input_path, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')

    # 第一遍：收集所有图表任务
    print("📊 Scanning document for ASCII diagrams...")
    tasks = []
    in_code_block = False
    code_block_start = -1
    code_block_content = []

    i = 0
    while i < len(lines):
        line = lines[i]

        if line.strip() == '```' and not in_code_block:
            in_code_block = True
            code_block_start = i
            code_block_content = []
            i += 1
            continue

        if line.strip() == '```' and in_code_block:
            in_code_block = False
            ascii_content = '\n'.join(code_block_content)
            context = extract_context(lines, code_block_start, i)

            tasks.append(FigureTask(
                index=len(tasks),
                ascii_content=ascii_content,
                context=context,
                code_block_content=code_block_content.copy(),
                line_number=code_block_start
            ))

            i += 1
            continue

        if in_code_block:
            code_block_content.append(line)

        i += 1

    if not tasks:
        print("No ASCII diagrams found")
        return 0

    print(f"Found {len(tasks)} diagrams\n")

    # 第二遍：并发生成 prompts
    print(f"🚀 Generating prompts with {max_workers} workers...\n")
    results = {}

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {
            executor.submit(process_single_figure, task, client, model): task
            for task in tasks
        }

        for future in as_completed(futures):
            task = futures[future]
            index, prompt, size, error = future.result()

            if error:
                print(f"[{index + 1}/{len(tasks)}] ✗ Failed: {error}")
                prompt = f"Create a diagram for {task.context['subsection'] or 'figure'}."
                size = "1920x1080"
            else:
                section = task.context['subsection'] or task.context['section'] or 'figure'
                size_indicator = "📐" if size == "1080x1920" else "📏"
                print(f"[{index + 1}/{len(tasks)}] ✓ {section[:50]}... ({len(prompt)} chars) {size_indicator} {size}")

            results[index] = (prompt, size)

    # 第三遍：重建文档，插入生成的 prompts
    print(f"\n📝 Writing output file...")
    output_lines = []
    in_code_block = False
    code_block_start = -1
    code_block_content = []
    task_index = 0

    i = 0
    while i < len(lines):
        line = lines[i]

        if line.strip() == '```' and not in_code_block:
            in_code_block = True
            code_block_start = i
            code_block_content = []
            i += 1
            continue

        if line.strip() == '```' and in_code_block:
            in_code_block = False

            # 获取对应的 prompt 和 size
            result = results.get(task_index, ("Create a diagram.", "1920x1080"))
            prompt, size = result if isinstance(result, tuple) else (result, "1920x1080")
            prompt_single_line = ' '.join(prompt.strip().split('\n'))

            # 生成文件名
            task = tasks[task_index]
            subsection = task.context['subsection'] or task.context['section'] or f'图表{task_index + 1}'
            clean_title = re.sub(r'[^\w\u4e00-\u9fff]', '_', subsection)
            clean_title = clean_title.strip('_')[:30]
            output_filename = f"fig_{task_index + 1:02d}_{clean_title}.png"

            # 添加注释
            output_lines.append('')
            output_lines.append(f'<!-- FIGURE: {prompt_single_line} -->')
            output_lines.append(f'<!-- OUTPUT: {output_filename} -->')
            output_lines.append(f'<!-- SIZE: {size} -->')
            output_lines.append('')
            output_lines.append('```')
            output_lines.extend(code_block_content)
            output_lines.append('```')

            task_index += 1
            i += 1
            continue

        if in_code_block:
            code_block_content.append(line)
            i += 1
            continue

        output_lines.append(line)
        i += 1

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(output_lines))

    print(f"\n✅ 处理完成! 共处理 {len(tasks)} 个图表")
    print(f"✅ 输出文件: {output_path}")
    return len(tasks)

def main():
    parser = argparse.ArgumentParser(
        description="Use LLM to analyze ASCII diagrams and generate image prompts",
        epilog="""
Config file example (~/.config/skiils.toml):
  api_key = "sk-..."
  api_base_url = "https://api.example.com/v1"
  chat_model = "claude-3-5-sonnet-20241022"  # for prompt generation
  model = "nano-banana-pro"                   # for image generation
        """
    )
    parser.add_argument("--file", required=True, help="Input markdown file")
    parser.add_argument("--output", required=True, help="Output markdown file")
    parser.add_argument("--config", default=DEFAULT_CONFIG, help="Config file (default: ~/.config/skiils.toml)")
    parser.add_argument("--model", default=None, help="LLM model for prompt generation (overrides config 'chat_model')")
    parser.add_argument("--api-key", default=None, help="API key (overrides config)")
    parser.add_argument("--base-url", default=None, help="API base URL (overrides config)")
    parser.add_argument("--workers", type=int, default=4, help="Number of concurrent workers (default: 4)")
    args = parser.parse_args()

    # 加载配置
    config_path = Path(args.config).expanduser() if args.config else None
    config = load_config(config_path) if config_path and config_path.exists() else {}

    # 获取 API 配置 (继承自配置文件)
    api_key = args.api_key or config.get("api_key") or os.getenv("OPENAI_API_KEY")
    base_url = args.base_url or config.get("api_base_url") or os.getenv("OPENAI_BASE_URL")

    # 获取 chat_model (用于生成 prompt)
    model = args.model or config.get("chat_model") or "claude-3-5-sonnet-20241022"

    # 获取并发数（优先级：命令行 > 配置文件 > 默认值）
    workers = args.workers if args.workers != 4 else config.get("chat_model_parallel", 4)

    if not api_key:
        print("Error: API key not found. Set via --api-key, config file, or OPENAI_API_KEY env var")
        return 1

    print(f"Using config: {config_path}")
    print(f"Using chat model for prompt generation: {model}")
    print(f"Using {workers} concurrent workers")
    if base_url:
        print(f"Using API base URL: {base_url}")

    # 创建 OpenAI 客户端
    client = openai.OpenAI(api_key=api_key, base_url=base_url)

    # 处理文件 (并发)
    count = process_file(args.file, args.output, client, model, max_workers=workers)
    return 0 if count > 0 else 1

if __name__ == '__main__':
    raise SystemExit(main())
