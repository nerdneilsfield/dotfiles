#!/usr/bin/env python3
"""
使用 LLM 分析 ASCII 图并生成图片 prompt (支持并发 + 去重)
优化版本：更多上下文、去重检查、更强的system prompt、JSON输出
"""
import argparse
import json
import os
import re
import sys
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import NamedTuple
from difflib import SequenceMatcher
from datetime import datetime

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

def extract_context(lines, start_idx, end_idx, context_lines=100):
    """提取 ASCII 图周围的上下文（扩大上下文范围）"""
    # 向前查找 - 增加到100行
    context_before = []
    section_title = None
    subsection_title = None
    chapter_title = None

    for i in range(max(0, start_idx - context_lines), start_idx):
        line = lines[i].strip()
        if line.startswith('####'):
            pass  # 跳过4级标题
        elif line.startswith('###'):
            subsection_title = line.replace('#', '').strip()
        elif line.startswith('##'):
            section_title = line.replace('#', '').strip()
        elif line.startswith('#'):
            chapter_title = line.replace('#', '').strip()
        elif line and not line.startswith('```'):
            context_before.append(line)

    # 向后查找 - 增加到20行
    context_after = []
    for i in range(end_idx + 1, min(len(lines), end_idx + 20)):
        line = lines[i].strip()
        if line and not line.startswith('```') and not line.startswith('#'):
            context_after.append(line)

    return {
        'chapter': chapter_title,
        'section': section_title,
        'subsection': subsection_title,
        'before': '\n'.join(context_before[-30:]),  # 增加到最后30行
        'after': '\n'.join(context_after[:10])  # 增加到前10行
    }

def similarity_ratio(s1, s2):
    """计算两个字符串的相似度（0-1）"""
    return SequenceMatcher(None, s1, s2).ratio()

def check_duplicate(new_prompt, existing_prompts, threshold=0.7):
    """检查新prompt是否与已有prompts重复

    Args:
        new_prompt: 新生成的prompt
        existing_prompts: 已有的prompts列表
        threshold: 相似度阈值，超过此值认为重复

    Returns:
        (is_duplicate, most_similar_index, similarity_score)
    """
    if not existing_prompts:
        return False, -1, 0.0

    max_similarity = 0.0
    most_similar_idx = -1

    for idx, existing_prompt in enumerate(existing_prompts):
        if existing_prompt is None:
            continue
        similarity = similarity_ratio(new_prompt, existing_prompt)
        if similarity > max_similarity:
            max_similarity = similarity
            most_similar_idx = idx

    is_duplicate = max_similarity > threshold
    return is_duplicate, most_similar_idx, max_similarity

def generate_prompt_via_llm(ascii_content, context, client, model, existing_prompts=None, retry_count=0):
    """使用 LLM 生成图片 prompt（带去重重试机制）"""

    # 构建已有prompts的简要列表（用于去重参考）
    existing_prompts_summary = ""
    if existing_prompts and len(existing_prompts) > 0:
        recent_prompts = [p for p in existing_prompts[-5:] if p]  # 最近5个
        if recent_prompts:
            existing_prompts_summary = "\n\n**IMPORTANT - Avoid duplicates! Recently generated prompts:**\n"
            for i, p in enumerate(recent_prompts):
                preview = p[:150] + "..." if len(p) > 150 else p
                existing_prompts_summary += f"{len(existing_prompts) - len(recent_prompts) + i + 1}. {preview}\n"
            existing_prompts_summary += "\n**Your prompt must be SIGNIFICANTLY DIFFERENT from the above!**"

    meta_prompt = f"""You are an expert at creating image generation prompts for academic diagrams.

I have an ASCII diagram from a Chinese academic paper about point cloud registration algorithms (4PCS family). I need you to analyze the ASCII diagram and its context, then generate a detailed, accurate English prompt for an AI image generator (Nano Banana Pro) to create a professional academic figure.

**Chapter**: {context.get('chapter') or 'N/A'}
**Section**: {context.get('section') or 'N/A'}
**Subsection**: {context.get('subsection') or 'N/A'}

**Context before the diagram (last 30 lines):**
{context['before']}

**ASCII Diagram:**
```
{ascii_content}
```

**Context after the diagram (next 10 lines):**
{context['after']}{existing_prompts_summary}

⚠️ **CRITICAL REQUIREMENTS:**

1. **READ THE CONTEXT CAREFULLY** - Understand what THIS specific section is about
2. **BE SPECIFIC TO THIS SECTION** - Don't use generic templates
3. **AVOID REPETITION** - If recent prompts are shown above, make yours distinctly different
4. **IDENTIFY THE UNIQUE CONTENT**:
   - What makes THIS diagram different from others?
   - What specific concept/algorithm/structure does THIS section explain?
   - What are the unique elements in THIS ASCII diagram?

5. **Diagram Type Identification**:
   - For flowcharts: What specific algorithm? What are its unique steps?
   - For geometric diagrams: What specific geometric relationship? What points/lines?
   - For data structures: What specific structure? How is it organized?
   - For comparisons: What is being compared? What are the differences?

6. **Include Specific Details**:
   - All Chinese labels, titles, and annotations (in quotes "")
   - Specific formulas, complexity notations (e.g., O(n+k))
   - Specific algorithm names, method names
   - Specific structural elements from the ASCII

7. **Visual Style**:
   - Specify layout: "Vertical flowchart" for multi-step algorithms, "Horizontal" for comparisons
   - Colors: Blue (#4A90E2) primary, Orange (#F5A623) highlights, Gray (#8E8E93) secondary
   - Background: Pure white
   - Font: Chinese text, clear and readable, 14pt

8. **Completeness**:
   - Include ALL steps from the ASCII diagram
   - Include ALL Chinese text that should appear
   - Include ALL mathematical notations
   - 200-400 words, comprehensive and detailed

Output ONLY the image generation prompt in English, with Chinese text in quotes. Make it UNIQUE and SPECIFIC to this section's content.

Format:
Create a [specific diagram type] for "[exact Chinese title from subsection]".

[Detailed, section-specific description with all unique elements]

Style: [specific style]
Background: Pure white
Colors: [color scheme]
Labels: All Chinese text, [requirements]
Layout: [layout - specify Vertical/Horizontal clearly]
Aspect ratio: 16:9, high resolution"""

    try:
        response = client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": meta_prompt}],
            temperature=0.2,  # 降低temperature以提高准确性
            max_tokens=2000
        )
        prompt = response.choices[0].message.content.strip()

        # 检查是否重复
        if existing_prompts:
            is_dup, dup_idx, similarity = check_duplicate(prompt, existing_prompts, threshold=0.7)
            if is_dup and retry_count < 2:  # 最多重试2次
                print(f"    ⚠️  Detected similarity {similarity:.2%} with prompt #{dup_idx+1}, regenerating...")
                return generate_prompt_via_llm(ascii_content, context, client, model, existing_prompts, retry_count + 1)

        return prompt
    except Exception as e:
        print(f"Error calling LLM: {e}")
        return None

def determine_size(prompt, ascii_content):
    """根据 prompt 和 ASCII 内容智能判断图片尺寸"""
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
    is_tall = len(ascii_lines) > 15

    # 检查是否包含多步骤流程
    has_steps = any(keyword in ascii_lower for keyword in ['step', '步骤', 'for', 'while', 'loop', '算法流程'])

    # 判断逻辑
    is_vertical = (
        any(keyword in prompt_lower for keyword in vertical_keywords) or
        (is_tall and has_steps)
    )

    if is_vertical:
        return "1080x1920"
    else:
        return "1920x1080"

def process_single_figure(task, client, model, existing_prompts):
    """处理单个图表 (用于并发)"""
    try:
        prompt = generate_prompt_via_llm(task.ascii_content, task.context, client, model, existing_prompts)
        if not prompt:
            prompt = f"Create a specific diagram for {task.context['subsection'] or 'figure'}."

        # 智能判断尺寸
        size = determine_size(prompt, task.ascii_content)

        # 根据尺寸调整 prompt 中的 aspect ratio
        if size == "1080x1920":
            prompt = prompt.replace("Aspect ratio: 16:9", "Aspect ratio: 9:16 (vertical)")
            prompt = prompt.replace("aspect ratio: 16:9", "aspect ratio: 9:16 (vertical)")
            if "aspect ratio" not in prompt.lower():
                prompt = prompt.rstrip() + " Aspect ratio: 9:16 (vertical), high resolution"
        else:
            if "aspect ratio" not in prompt.lower():
                prompt = prompt.rstrip() + " Aspect ratio: 16:9, high resolution"

        return task.index, prompt, size, None
    except Exception as e:
        return task.index, None, "1920x1080", str(e)

def process_file(input_file, output_file, client, model_name, max_workers=4):
    """处理文件，使用 LLM 生成 prompts（带去重）"""
    input_path = Path(input_file)
    output_path = Path(output_file)
    model = model_name  # 保存模型名称用于metadata

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

    # 第二遍：顺序生成 prompts（保证去重检查）
    print(f"🚀 Generating prompts with deduplication checks...\n")
    results = {}
    existing_prompts = []

    for task in tasks:
        index, prompt, size, error = process_single_figure(task, client, model_name, existing_prompts)

        if error:
            print(f"[{index + 1}/{len(tasks)}] ✗ Failed: {error}")
            prompt = f"Create a specific diagram for {task.context['subsection'] or 'figure'}."
            size = "1920x1080"
        else:
            section = task.context['subsection'] or task.context['section'] or 'figure'
            size_indicator = "📐" if size == "1080x1920" else "📏"

            # 检查与已有prompts的相似度
            if existing_prompts:
                _, _, max_sim = check_duplicate(prompt, existing_prompts, threshold=0.0)
                similarity_indicator = f"(sim: {max_sim:.0%})" if max_sim > 0.5 else ""
            else:
                similarity_indicator = ""

            print(f"[{index + 1}/{len(tasks)}] ✓ {section[:40]}... ({len(prompt)} chars) {size_indicator} {size} {similarity_indicator}")

        results[index] = (prompt, size)
        existing_prompts.append(prompt)

    # 第三遍：检查并报告重复
    print(f"\n🔍 Checking for duplicates...")
    duplicates_found = []
    for i in range(len(existing_prompts)):
        for j in range(i + 1, len(existing_prompts)):
            similarity = similarity_ratio(existing_prompts[i], existing_prompts[j])
            if similarity > 0.7:
                duplicates_found.append((i+1, j+1, similarity))

    if duplicates_found:
        print(f"⚠️  Found {len(duplicates_found)} potential duplicates:")
        for idx1, idx2, sim in duplicates_found[:5]:  # 只显示前5个
            print(f"   - Prompt #{idx1} ↔ #{idx2}: {sim:.0%} similar")
        if len(duplicates_found) > 5:
            print(f"   ... and {len(duplicates_found) - 5} more")
    else:
        print("✅ No duplicates detected!")

    # 第四遍：重建文档，插入生成的 prompts
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
            clean_title = clean_title.strip('_')[:60]  # 增加文件名长度
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

    # 保存 prompts 到 JSON 文件
    json_path = output_path.parent / (output_path.stem + '_prompts.json')
    prompts_data = {
        'metadata': {
            'generated_at': datetime.now().isoformat(),
            'total_figures': len(tasks),
            'input_file': str(input_path),
            'output_file': str(output_path),
            'model_used': model,
            'duplicates_detected': len(duplicates_found)
        },
        'prompts': []
    }

    for idx, task in enumerate(tasks):
        prompt, size = results.get(idx, ("", "1920x1080"))
        subsection = task.context['subsection'] or task.context['section'] or f'图表{idx + 1}'
        clean_title = re.sub(r'[^\w\u4e00-\u9fff]', '_', subsection)
        clean_title = clean_title.strip('_')[:60]
        output_filename = f"fig_{idx + 1:02d}_{clean_title}.png"

        # 计算与其他prompts的相似度
        similarities = []
        if idx > 0:
            for other_idx in range(idx):
                other_prompt = results.get(other_idx, ("", ""))[0]
                if other_prompt:
                    sim = similarity_ratio(prompt, other_prompt)
                    if sim > 0.5:  # 只记录相似度>50%的
                        similarities.append({
                            'with_index': other_idx + 1,
                            'similarity': round(sim, 3)
                        })

        prompts_data['prompts'].append({
            'index': idx + 1,
            'line_number': task.line_number,
            'chapter': task.context.get('chapter'),
            'section': task.context.get('section'),
            'subsection': task.context.get('subsection'),
            'output_filename': output_filename,
            'prompt': prompt,
            'size': size,
            'prompt_length': len(prompt),
            'ascii_lines': len(task.ascii_content.split('\n')),
            'similar_to': similarities if similarities else None,
            'generated': False  # 新增：标记是否已生成图片
        })

    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(prompts_data, f, ensure_ascii=False, indent=2)

    print(f"\n✅ 处理完成! 共处理 {len(tasks)} 个图表")
    print(f"✅ 输出文件: {output_path}")
    print(f"📋 Prompts JSON: {json_path}")

    if duplicates_found:
        print(f"\n⚠️  警告: 检测到 {len(duplicates_found)} 处可能的重复，建议人工检查")
        print(f"   详细信息已保存在 {json_path}")

    return len(tasks)

def main():
    parser = argparse.ArgumentParser(
        description="Use LLM to analyze ASCII diagrams and generate unique image prompts (v2 with deduplication)",
        epilog="""
Config file example (~/.config/skiils.toml):
  api_key = "sk-..."
  api_base_url = "https://api.example.com/v1"
  chat_model = "claude-3-5-sonnet-20241022"
        """
    )
    parser.add_argument("--file", required=True, help="Input markdown file")
    parser.add_argument("--output", required=True, help="Output markdown file")
    parser.add_argument("--config", default=DEFAULT_CONFIG, help="Config file")
    parser.add_argument("--model", default=None, help="LLM model for prompt generation")
    parser.add_argument("--api-key", default=None, help="API key")
    parser.add_argument("--base-url", default=None, help="API base URL")
    args = parser.parse_args()

    # 加载配置
    config_path = Path(args.config).expanduser() if args.config else None
    config = load_config(config_path) if config_path and config_path.exists() else {}

    api_key = args.api_key or config.get("api_key") or os.getenv("OPENAI_API_KEY")
    base_url = args.base_url or config.get("api_base_url") or os.getenv("OPENAI_BASE_URL")
    model = args.model or config.get("chat_model") or "claude-3-5-sonnet-20241022"

    if not api_key:
        print("Error: API key not found")
        return 1

    print(f"Using config: {config_path}")
    print(f"Using chat model: {model}")
    if base_url:
        print(f"Using API base URL: {base_url}")

    client = openai.OpenAI(api_key=api_key, base_url=base_url)

    # 处理文件（顺序执行以支持去重）
    count = process_file(args.file, args.output, client, model, max_workers=1)
    return 0 if count > 0 else 1

if __name__ == '__main__':
    raise SystemExit(main())
