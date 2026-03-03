#!/usr/bin/env python3
"""
为文档中的ASCII图表添加学术风格的图片生成注释
深度分析ASCII内容和上下文，生成准确的图片描述
"""
import re
import argparse
from pathlib import Path

def analyze_ascii_content(ascii_content):
    """分析ASCII图的内容特征"""
    features = {
        'has_boxes': '┌' in ascii_content or '┬' in ascii_content or '├' in ascii_content,
        'has_arrows': '→' in ascii_content or '←' in ascii_content or '↓' in ascii_content or '↑' in ascii_content,
        'has_lines': '─' in ascii_content or '│' in ascii_content or '/' in ascii_content or '\\' in ascii_content,
        'has_points': re.search(r'\b[a-z]\b', ascii_content.lower()),
        'has_formulas': 'r1' in ascii_content or 'r2' in ascii_content or 'd1' in ascii_content,
        'has_grid': '┼' in ascii_content or '╋' in ascii_content,
        'has_bullets': '●' in ascii_content or '○' in ascii_content or '•' in ascii_content,
        'has_tree': '└' in ascii_content or '├' in ascii_content,
        'has_coordinates': re.search(r'\(.*,.*\)', ascii_content),
        'line_count': len(ascii_content.split('\n')),
        'text_content': extract_text_from_ascii(ascii_content)
    }
    return features

def extract_text_from_ascii(ascii_content):
    """从ASCII图中提取文本内容，去除框线字符"""
    # 移除框线字符
    box_chars = '┌┐└┘├┤┬┴┼─│╋╂╪╫╬═║╒╓╔╕╖╗╘╙╚╛╜╝╞╟╠╡╢╣╤╥╦╧╨╩╪╫╬'
    lines = []
    for line in ascii_content.split('\n'):
        # 移除框线字符
        cleaned = ''.join(c if c not in box_chars else ' ' for c in line)
        # 移除多余空格但保留内容
        cleaned = cleaned.strip()
        if cleaned and not all(c in ' │' for c in cleaned):
            lines.append(cleaned)
    return '\n'.join(lines)

def extract_detailed_context(lines, start_idx, end_idx):
    """提取详细的上下文信息"""
    # 向前查找标题和关键段落（最多50行）
    context_before = []
    section_title = None
    subsection_title = None
    key_concepts = []

    for i in range(max(0, start_idx - 50), start_idx):
        line = lines[i].strip()
        if line.startswith('###'):
            subsection_title = line.replace('#', '').strip()
        elif line.startswith('##'):
            section_title = line.replace('#', '').strip()
        elif line and not line.startswith('```'):
            # 提取关键概念（加粗文字）
            bold_matches = re.findall(r'\*\*(.*?)\*\*', line)
            key_concepts.extend(bold_matches)
            context_before.append(line)

    # 向后查找（最多10行）
    context_after = []
    for i in range(end_idx + 1, min(len(lines), end_idx + 10)):
        line = lines[i].strip()
        if line and not line.startswith('```') and not line.startswith('#'):
            context_after.append(line)

    return {
        'section': section_title,
        'subsection': subsection_title,
        'before': '\n'.join(context_before[-10:]),  # 最近10行
        'after': '\n'.join(context_after[:5]),  # 之后5行
        'concepts': list(set(key_concepts))
    }

def generate_detailed_prompt(ascii_content, context, features, line_num):
    """根据ASCII内容和上下文生成详细的prompt (英文prompt，中文用引号包裹)"""

    # 分析图表类型和内容
    ascii_lower = ascii_content.lower()

    # 1. 判断是否是几何图（包含点标签）
    if features['has_points'] and not features['has_boxes']:
        # 提取点的标签
        points = re.findall(r'\b([a-z])\b', ascii_content.lower())
        points = list(set(points))

        # 查找关键几何概念
        geometric_concepts = []
        if '交点' in context['before'] or 'intersection' in context['before'].lower():
            geometric_concepts.append('intersection point')
        if '比率' in context['before'] or 'ratio' in context['before']:
            geometric_concepts.append('ratio relationships')
        if '线段' in context['before']:
            geometric_concepts.append('line segments')
        if '不变' in context['before']:
            geometric_concepts.append('invariant properties')

        prompt = f"""Create a clean geometric diagram illustrating affine invariant ratios for coplanar four points.
Main elements:
- Four coplanar points labeled "{', '.join(sorted(points)[:4])}"
- Two line segments intersecting at point "e"
- Show ratio relationships: r1 = |ae|/|ab| and r2 = |ce|/|cd|
- Annotate with clear labels showing "线段 ab 与线段 cd 交于点 e"
- Add text annotations: "r1 = |ae| / |ab|", "r2 = |ce| / |cd|"
- Include note: "这两个比率在刚体变换(以及仿射变换)下不变"
Style: Academic geometry diagram, simple and clear
Background: Pure white
Colors: Points in blue (#4A90E2), lines in dark gray (#333333), labels in Chinese
Layout: Centered, geometrically accurate proportions
Aspect ratio: 16:9, high resolution"""
        return prompt

    # 2. 算法流程图
    elif features['has_boxes'] and features['has_arrows']:
        # 提取算法标题
        title_match = re.search(r'([A-Z0-9\-]+)\s*算法流程', ascii_content)
        algorithm = title_match.group(1) if title_match else 'Algorithm'

        # 提取输入输出
        inputs = []
        outputs = []
        input_match = re.search(r'输入[：:](.*?)(?=输出|$)', ascii_content, re.DOTALL)
        output_match = re.search(r'输出[：:](.*?)(?=\n|$)', ascii_content)
        if input_match:
            inputs = [x.strip() for x in re.split(r'[,，]', input_match.group(1)) if x.strip()]
        if output_match:
            outputs = [x.strip() for x in re.split(r'[,，]', output_match.group(1)) if x.strip()]

        # 提取主要步骤
        steps = []
        step_pattern = r'(?:^|\n)\s*(?:[0-9]+\.|[a-z]\)|\([a-z]\))\s*([^│\n]+)'
        for match in re.finditer(step_pattern, ascii_content):
            step_text = match.group(1).strip()
            if step_text and len(step_text) > 3:
                steps.append(step_text)

        # 提取复杂度标注
        complexity = []
        complexity_pattern = r'O\([^)]+\)'
        for match in re.finditer(complexity_pattern, ascii_content):
            complexity.append(match.group(0))

        # 提取数学公式
        formulas = []
        formula_pattern = r'[a-z][0-9]?\s*[=≈]\s*[^│\n]{3,30}'
        for match in re.finditer(formula_pattern, ascii_content):
            formulas.append(match.group(0).strip())

        # 提取关键概念
        key_concepts = re.findall(r'[A-Z][a-zA-Z0-9]+(?:4PCS|Base|Pairs|LCP|RANSAC)', ascii_content)

        # 生成详细的文本内容描述
        text_content = features['text_content']

        # 构建详细的 prompt
        title_cn = context['subsection'] or f'{algorithm} Algorithm'

        prompt = f"""Create a detailed algorithm flowchart diagram for "{title_cn}" ({algorithm}).

**Diagram Title:** "{algorithm} 算法流程" (centered, bold, 18pt)

**Input Section (top, green box #7ED321):**
{chr(10).join(f"- {inp}" for inp in inputs) if inputs else "- Source point cloud P, target point cloud Q, tolerance ε"}

**Main Algorithm Flow:**
{chr(10).join(f"{i+1}. {step}" for i, step in enumerate(steps[:8])) if steps else "Standard RANSAC iteration framework"}

**Key Components to Include:**
- Algorithm name and complexity annotations: {', '.join(complexity) if complexity else 'O(n+k)'}
- Mathematical formulas in boxes: {', '.join(formulas[:3]) if formulas else 'r1, r2, d3 relationships'}
- Sub-steps with clear hierarchy and indentation
- Decision diamonds for conditional logic
- Loop indicators for RANSAC iterations

**Output Section (bottom, green box #7ED321):**
{chr(10).join(f"- {out}" for out in outputs) if outputs else "- Optimal transformation T*"}

**Detailed Content from ASCII:**
{text_content[:500]}

**Visual Style:**
- Layout: Vertical flowchart, top-to-bottom progression
- Boxes: Rounded rectangles for processes (blue #4A90E2), diamonds for decisions (orange #F5A623)
- Connections: Solid arrows with clear directional flow
- Background: Pure white
- Font: All labels in Chinese, 14pt, clear sans-serif
- Hierarchy: Nested boxes for sub-procedures, clear indentation
- Annotations: Include complexity O(n+k) and mathematical formulas
- Spacing: Generous padding, professional academic style
- Resolution: 16:9 aspect ratio, high resolution (4K)"""
        return prompt

    # 3. 数据结构图（网格、索引等）
    elif features['has_grid'] or ('网格' in context['before'] and features['has_bullets']):
        title_cn = context['subsection'] or 'Spatial Grid Indexing'
        prompt = f"""Create a data structure visualization showing "{title_cn}".
Structure: 2D/3D grid cells with points distributed
Main elements:
- Uniform grid subdivision
- Points marked in different cells
- Query sphere/shell highlighted
- Show efficient cell-based lookup pattern
Labels: "网格单元", "查询球壳", "点云数据"
Style: Technical diagram, clear and informative
Background: Pure white
Colors: Grid in light gray (#E0E0E0), points in blue (#4A90E2), query region highlighted in orange (#F5A623)
Layout: Clean grid structure
Aspect ratio: 16:9, high resolution"""
        return prompt

    # 4. 对比图
    elif 'vs' in ascii_lower or '对比' in context['before']:
        title_cn = context['subsection'] or 'Comparison Diagram'
        prompt = f"""Create a comparison diagram showing "{title_cn}".
Structure: Two or more columns comparing different approaches
Main elements:
- Clear visual separation between compared items
- Key differences highlighted
- Labeled invariants or parameters for each
Style: Academic comparison chart
Background: Pure white
Colors: Different methods in distinct colors (blue #4A90E2, orange #F5A623)
Labels: All text in Chinese, clear annotations
Layout: Side-by-side or before-after comparison
Aspect ratio: 16:9, high resolution"""
        return prompt

    # 5. 级联过滤图
    elif '级联' in context['before'] or '层' in ascii_content:
        title_cn = context['subsection'] or 'Cascade Filtering'
        prompt = f"""Create a cascade filtering diagram showing "{title_cn}".
Structure: Top-to-bottom funnel showing progressive filtering
Main elements:
- Multiple filtering stages (3-4 levels)
- Each level reduces candidate set
- Arrows showing data flow downward
- Annotate filtering conditions at each stage
Labels: Show data volume reduction (e.g., "全体点 Q (n个)" → "候选集缩减")
Style: Academic process diagram
Background: Pure white
Colors: Gradient blue from dark (#2C5AA0) to light (#A8D5FF) showing reduction
Layout: Vertical cascade, decreasing width per level
Aspect ratio: 16:9, high resolution"""
        return prompt

    # 6. 默认示意图
    else:
        # 从上下文提取关键信息
        title_cn = context['subsection'] or context['section'] or '示意图'

        prompt = f"""Create a schematic diagram illustrating "{title_cn}".
Context: {', '.join(context['concepts'][:3]) if context['concepts'] else 'Technical illustration'}
Style: Clean academic diagram
Background: Pure white
Colors: Primary elements in blue (#4A90E2), secondary in gray (#8E8E93)
Labels: All text in Chinese, clear and readable
Layout: Organized and clear visual hierarchy
Aspect ratio: 16:9, high resolution"""
        return prompt

def process_file(input_file, output_file):
    """处理文件，为所有ASCII图添加生成注释"""
    input_path = Path(input_file)
    output_path = Path(output_file)

    with open(input_path, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')
    output_lines = []
    in_code_block = False
    code_block_start = -1
    code_block_content = []
    figure_count = 0

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
            figure_count += 1

            # 分析ASCII内容
            ascii_content = '\n'.join(code_block_content)
            features = analyze_ascii_content(ascii_content)

            # 提取详细上下文
            context = extract_detailed_context(lines, code_block_start, i)

            # 生成详细prompt
            prompt = generate_detailed_prompt(ascii_content, context, features, figure_count)

            # 压缩成单行
            prompt_single_line = ' '.join(prompt.strip().split('\n'))

            # 生成输出文件名
            subsection = context['subsection'] or context['section'] or f'图表{figure_count}'
            clean_title = re.sub(r'[^\w\u4e00-\u9fff]', '_', subsection)
            clean_title = clean_title.strip('_')[:30]
            output_filename = f"fig_{figure_count:02d}_{clean_title}.png"

            # 添加注释
            output_lines.append('')
            output_lines.append(f'<!-- FIGURE: {prompt_single_line} -->')
            output_lines.append(f'<!-- OUTPUT: {output_filename} -->')
            output_lines.append('<!-- SIZE: 1920x1080 -->')
            output_lines.append('')
            output_lines.append('```')
            output_lines.extend(code_block_content)
            output_lines.append('```')

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

    print(f"处理完成! 共处理 {figure_count} 个图表")
    print(f"输出文件: {output_path}")
    return figure_count

def main():
    parser = argparse.ArgumentParser(
        description="Add figure generation prompts to ASCII diagrams in markdown files"
    )
    parser.add_argument("--file", required=True, help="Input markdown file")
    parser.add_argument("--output", required=True, help="Output markdown file with prompts")
    args = parser.parse_args()

    count = process_file(args.file, args.output)
    return 0 if count > 0 else 1

if __name__ == '__main__':
    raise SystemExit(main())
