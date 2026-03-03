# Nano Banana Pro Prompt 最佳实践指南

基于 Google 官方文档和社区最佳实践整理。

## 一、提示词的核心结构（6个模块）

优秀的 Nano Banana Pro 提示词应包含以下结构：

```
主体 + 构图 + 行为 + 场景 + 风格 + 技术控制
(Subject + Composition + Action + Location + Style + Technical Controls)
```

### 1. 主体（Subject）
**越具体越好，越模糊越随机**

❌ 错误示例：`a cat`
✅ 优秀示例：`a fluffy calico cat wearing a tiny wizard hat with star patterns`

**关键要点**：
- 描述具体特征（颜色、材质、装饰）
- 包含关键细节（姿态、表情、服饰）
- 对于人物，描述身份和特征

### 2. 构图（Composition）
**使用专业摄影术语**

常用构图类型：
- `wide shot` / `extreme close-up` / `medium shot`
- `low-angle shot` / `high-angle` / `eye-level`
- `portrait` / `landscape` / `symmetrical composition`
- `rule of thirds` / `centered composition`

示例：
```
A low-angle portrait shot of a confident entrepreneur
```

### 3. 行为（Action）
**为画面增加叙事和动态感**

示例动作：
- `brewing coffee` / `reading a book` / `casting a spell`
- `running mid-stride` / `jumping` / `dancing`
- `looking at camera` / `turning away` / `reaching for`

### 4. 场景（Location）
**明确物理环境和氛围**

优秀示例：
- `in a futuristic Mars café with red dust outside the window`
- `in a cluttered alchemist's library with floating books`
- `in a sun-drenched meadow at golden hour`
- `on a rain-soaked Tokyo street with neon reflections`

### 5. 风格（Style）
**明确艺术风格或视觉参考**

常用风格：
- `photorealistic` / `hyperrealistic`
- `watercolor illustration` / `oil painting`
- `3D animation` / `flat design` / `isometric`
- `film noir` / `cyberpunk` / `art deco`
- `1990s product photography` / `vintage poster`
- `minimalist` / `maximalist`

### 6. 技术控制（Technical Controls）
**这是 Nano Banana Pro 的必杀技**

#### 画幅比例（Aspect Ratio）
- `16:9 cinematic` - 电影宽屏
- `9:16 vertical poster` - 手机竖屏海报
- `1:1 square` - Instagram方形
- `21:9 ultra-wide` - 超宽屏

#### 相机参数
- 镜头：`50mm` / `85mm portrait lens` / `wide-angle 24mm` / `macro lens`
- 光圈：`shallow depth of field (f/1.4)` / `f/8` / `bokeh background`
- 焦点：`sharp focus on eyes` / `soft focus`

#### 光线（Lighting）
- `golden hour backlight creating long shadows`
- `soft diffused lighting` / `hard directional light`
- `rim lighting on hair` / `three-point lighting`
- `neon lighting` / `natural window light`
- `dramatic chiaroscuro` / `flat even lighting`

#### 色彩分级（Color Grading）
- `cinematic teal and orange tones`
- `muted pastel palette`
- `high contrast black and white`
- `warm vintage tones` / `cool blue tones`
- `desaturated` / `vibrant colors`

#### 分辨率
- `4K resolution` / `2K` / `1080p`
- `ultra detailed` / `high quality`

## 二、专业级提示词写作技巧

### 用摄影语言控制画面

Nano Banana Pro 能完全理解专业摄影术语：

```
A portrait of a young woman, 85mm lens, shallow depth of field (f/1.4),
rim lighting on hair, soft shadows, cinematic teal-orange color grading,
shot at eye level
```

**效果**：接近真实摄影棚拍的专业质感

### 中文文本渲染的关键

**如果画面包含中文文字，必须：**
1. 明确告诉模型要放什么字
2. 明确字的位置和样式
3. 强调使用中文排版

示例：
```
Render the headline "城市探险者" in bold white sans-serif font,
centered at the top. Use proper Chinese typography with balanced character spacing.
Add a subtitle "URBAN EXPLORER" in smaller English text below.
```

### 编辑已有图片的提示词

处理已有图片时，使用**直接的命令句**：

✅ 正确示例：
- `Turn this scene into nighttime`
- `Remove the background car`
- `Change his shirt to red plaid`
- `Shift focus from the person to the flowers`
- `Translate all English text to Chinese while keeping layout unchanged`

❌ 避免：
- `Could you please maybe...`（太客气，不够直接）
- `I want it to look like...`（描述不清晰）

### 多图一致性提示

当使用多张参考图时，**明确每张图的角色**：

```
Use Image A for character identity and facial features,
Image B for the pose and body position,
Image C for the background environment and lighting.
Maintain consistent face proportions across all elements.
```

### 品牌设计提示

品牌类提示词模板：

```
Maintain brand colors (#0A5BFF and #FFB000),
apply soft shadows with 15% opacity,
drape the logo naturally onto 3D surfaces preserving perspective,
use consistent typography (font: Helvetica Neue Bold),
4K resolution, professional mockup quality
```

## 三、完整提示词模板（可复制）

### 通用高质量模板

```
[主体描述]
Describe the main subject with specific traits and characteristics.

[构图]
Shot type: [wide/close-up/portrait/etc.]
Angle: [low-angle/high-angle/eye-level]
Framing: [centered/rule-of-thirds/etc.]

[动作]
Action or moment being captured: [具体动作]

[场景]
Environment: [详细环境描述]
Time of day: [golden hour/noon/night/etc.]
Weather: [sunny/rainy/foggy/etc.]

[风格]
Art style: [photorealistic/illustration/3D/etc.]
Visual reference: [film noir/cyberpunk/vintage/etc.]

[技术参数]
Camera: [50mm f/1.8 / 85mm portrait lens / etc.]
Lighting: [soft glow/rim light/natural light/etc.]
Color grading: [cinematic teal & orange/vintage warm/etc.]
Aspect ratio: [16:9 / 9:16 / 1:1]
Resolution: [4K / 2K]

[文本内容 - 如需要]
Text: "[具体文字内容]"
Typography: [font style, size, position]
Language: [Chinese with proper typography / English / etc.]

[特殊要求 - 可选]
Additional requirements: [任何特殊需求]
```

### 学术论文配图模板

```
[图表类型]: A [diagram/flowchart/infographic] showing [主题]

[内容结构]:
- Main components: [列出主要组成部分]
- Flow/relationship: [说明流程或关系]
- Labels: [需要的标签文字，建议用中文]

[视觉风格]:
Style: Clean, professional academic diagram
Colors: [Soft blue (#4A90E2) for primary, gray (#6B7280) for secondary]
Layout: [Horizontal flow / Vertical hierarchy / Circular / etc.]
Background: White or light gray (#F9FAFB)

[文字要求]:
All labels in Chinese with clear, readable font (minimum 12pt)
Use arrows and connecting lines to show relationships
Include title: "[图表标题]"

[技术规格]:
Aspect ratio: 16:9 for presentation / 4:3 for paper
Resolution: 300 DPI for print / 4K for digital
Format: Clean vector-style appearance
```

### 海报设计模板

```
Create a [poster type] poster

[主视觉]:
Main image: [核心视觉描述]
Composition: [构图方式]

[文字内容]:
Headline: "[主标题]" - Bold, large, [font style]
Subheading: "[副标题]" - [font style and size]
Body text: "[正文内容]"
Language: Chinese typography with proper character spacing

[设计风格]:
Style: [modern/vintage/minimalist/etc.]
Color palette: [主色调描述和色号]
Visual hierarchy: [Clear headline > supporting text]

[技术规格]:
Aspect ratio: 9:16 for vertical poster
Resolution: 4K
Quality: Print-ready, high resolution
```

## 四、黄金法则

### ① 专业术语 > 模糊描述

❌ "Professional looking photo"
✅ "Shot with 85mm lens, f/1.8, studio lighting setup with softbox"

❌ "Cinematic vibe"
✅ "Kodak Vision3 500T film stock, anamorphic lens flares, teal and orange color grading"

### ② 结构化 > 流水账

一条提示词至少包含：主体 + 场景 + 风格 + 构图

### ③ 命令句 > 请求句（编辑时）

❌ "Could you please make the background darker?"
✅ "Darken the background by 30%"

### ④ 具体 > 抽象

❌ "Beautiful lighting"
✅ "Golden hour backlight with rim glow, soft shadows, warm color temperature 5500K"

### ⑤ 量化参数 > 形容词

❌ "Nice bokeh effect"
✅ "Shallow depth of field at f/1.4, creamy bokeh background"

## 五、常见场景提示词示例

### 学术图表

```
Create a scientific diagram showing the point cloud registration pipeline.

Structure:
- Input: Raw 3D point clouds (two clouds shown in different colors)
- Step 1: Feature extraction (FPFH descriptors visualization)
- Step 2: Correspondence matching (lines connecting matching points)
- Step 3: Transformation estimation (coordinate frame transformation)
- Step 4: ICP refinement (iterative alignment visualization)
- Output: Aligned point clouds (merged result)

Style: Clean academic diagram with white background
Colors: Blue (#4A90E2) for source cloud, Orange (#F59E0B) for target cloud
Layout: Horizontal flow from left to right with clear arrows
Labels: All in Chinese with clear 14pt font
Include title: "点云配准算法流程图"

Technical: 16:9 aspect ratio, 4K resolution, vector-style clarity
```

### 算法流程图

```
Generate a flowchart diagram for [算法名称]

Components:
- Start/End: Rounded rectangles
- Process steps: Rectangles with step descriptions in Chinese
- Decisions: Diamonds with yes/no branches
- Data: Parallelograms

Visual style:
- Modern flat design
- Primary color: Teal (#14B8A6)
- Accent color: Orange (#F97316)
- Connector lines: Gray with arrows
- Background: White
- Font: Clean sans-serif, minimum 12pt

Layout: Vertical flow, top to bottom
Labels: Clear Chinese text for all steps
Include: Input/output specifications

Resolution: 4K, suitable for academic paper
```

### 实验结果对比图

```
Create a side-by-side comparison visualization

Left panel: [Method A results]
Right panel: [Method B results]
Center: Large "vs" divider

Each panel shows:
- Method name in Chinese at top
- Visual result (image/graph)
- Key metrics below in table format
- Color code: Green for better, Red for worse

Style: Clean scientific presentation
Background: Light gray (#F3F4F6)
Border: Thin lines separating panels
Metrics table: Professional typography

Aspect ratio: 16:9
Resolution: 4K for presentation
Include: Clear Chinese labels and metric names
```

## 六、针对论文配图的特殊建议

### 文字清晰度
- 所有标签使用中文
- 字号不小于12pt
- 使用清晰的无衬线字体
- 确保黑白打印时也清晰可读

### 配色方案
- 使用色盲友好的配色
- 主要信息用深色（#1F2937）
- 辅助信息用中灰色（#6B7280）
- 强调部分用蓝色（#3B82F6）或橙色（#F59E0B）

### 分辨率
- 论文打印：300 DPI 或 4K
- PPT演示：2K 或 4K
- 在线浏览：2K 即可

### 布局建议
- 16:9 适合演示文稿
- 4:3 适合论文版面
- 保持充足的留白
- 重要元素居中或遵循三分法则

## 七、快速检查清单

在提交 prompt 前检查：

- [ ] 是否包含了6个核心模块？
- [ ] 主体描述是否足够具体？
- [ ] 是否使用了专业术语而非模糊形容词？
- [ ] 如有中文文字，是否明确要求中文排版？
- [ ] 是否指定了分辨率和宽高比？
- [ ] 技术参数是否量化明确（如 f/1.8 而非 "blurry background"）？
- [ ] 编辑指令是否使用命令句？
- [ ] 多图任务是否明确了每张图的角色？

## Sources

- [7 tips to get the most out of Nano Banana Pro - Google Blog](https://blog.google/products-and-platforms/products/gemini/prompting-tips-nano-banana-pro/)
- [如何让Nano Banana Pro生成更好的图片？官方教程 - DataLearner](https://www.datalearner.com/blog/1051763659266413)
- [30+ 最佳 Nano Banana Pro 提示 - PromptsRef](https://promptsref.com/zh/guide/30-best-nano-banana-pro-prompts-to-master-image-generation-and-editing-1763709158111)
- [Nano Banana Pro Ultimate Prompting Guide - Reddit](https://www.reddit.com/r/PromptEngineering/comments/1pid4cs/nano_banana_pro_ultimate_prompting_guide/)
