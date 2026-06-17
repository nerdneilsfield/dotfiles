# De-AI Rewriting Strategy Guide / 去AI化改写策略指南

This guide covers **how** to rewrite text to reduce AI detection rate. For pattern dictionaries of specific words and phrases to catch, see `PATTERNS_ZH.md` and `PATTERNS_EN.md`.

---

## Core Insight / 核心认知

AIGC detectors identify **sentence-structure fingerprints** (skeleton repetition), not individual words. The same skeleton used 3+ times is far more dangerous than any single AI-typical word.

> **Evidence note** (2026-03, observational): Based on Zhihu user reports and Tencent Zhuque Lab 2025 analysis. Tested on Chinese academic writing. May not generalize to other languages or genres. Experience-based conclusion, not peer-reviewed.

AIGC检测器识别的是**句式结构指纹**（骨架重复），而非单个词汇。同一骨架连续出现3次以上，比任何一个AI典型词汇都更危险。

**Priority order / 改写优先级:**

1. Skeleton repetition (structure) / 骨架重复（句式结构）
2. Template expressions / 模板化表达
3. AI vocabulary / AI高频词汇

Swapping synonyms while keeping the same skeleton is like changing the paint on a car the police are tracking by shape. Fix the shape first.

只换近义词而保留骨架，就像警察根据车型追踪时你只换了车漆。先改车型。

---

## Strategy 1: Skeleton Diversification / 骨架多样化

Adjacent paragraphs and sections must use **different** sentence structures. When a detector sees the same opening pattern repeated across paragraphs, it flags the entire passage.

相邻段落和章节必须使用**不同的**句式结构。当检测器发现相同的开头模式在多段重复出现时，会标记整个段落。

### Chinese Examples / 中文示例

**Bad / 差 -- 三章共用同一骨架:**

```
第三章 首先分析了温度对材料性能的影响，其次介绍了湿度的作用，此外说明了光照的效果，最后评估了综合因素。
第四章 首先分析了传感器布局方案，其次介绍了数据采集流程，此外说明了预处理方法，最后评估了整体精度。
第五章 首先分析了模型参数选择，其次介绍了训练策略，此外说明了验证方法，最后评估了泛化能力。
```

Three chapters all follow "首先分析...其次介绍...此外说明...最后评估..." -- this is a detection magnet.

**Good / 好 -- 每章不同骨架:**

```
第三章 围绕温度、湿度、光照三类环境因子展开，逐一量化其对材料劣化速率的贡献。
第四章 聚焦多源传感数据的融合问题。针对布局稀疏、采样不同步两个瓶颈，提出分级校准策略。
第五章 面向小样本场景下的泛化问题，对比了三种正则化路径，给出适用条件与局限。
```

Ch3 uses "围绕...展开", Ch4 uses "聚焦...针对...瓶颈", Ch5 uses "面向...问题". No two chapters share the same skeleton.

### English Examples

**Bad -- repeated parallel structure across sections:**

```
Section 3 first analyzes the temperature effects, then introduces the humidity model, additionally describes the light exposure protocol, and finally evaluates the combined impact.
Section 4 first analyzes the sensor layout, then introduces the data pipeline, additionally describes the preprocessing steps, and finally evaluates the overall accuracy.
```

**Good -- varied structure per section:**

```
Section 3 quantifies how three environmental factors -- temperature, humidity, and light -- each accelerate material degradation at different rates.
Section 4 tackles the fusion problem head-on. Two bottlenecks dominate: sparse sensor placement and asynchronous sampling. A tiered calibration strategy addresses both.
Section 5 asks whether regularization alone can solve the small-sample generalization problem. Three approaches are compared, with conditions and limitations noted for each.
```

### Practical rule / 实操规则

Before submitting, list the opening pattern of each paragraph in a section. If any pattern appears 3+ times, rewrite at least one instance.

提交前，列出每段的开头模式。如果任何模式出现3次以上，至少改写其中一个。

**Failure mode:** Over-varying structure can make text feel incoherent; readers expect some structural consistency within a genre.

---

## Strategy 2: Implicit Causality / 隐式因果

Delete connector words when context already makes the causal relationship obvious. AI text over-signposts; human text trusts the reader.

当上下文已经让因果关系显而易见时，删除连接词。AI文本过度标注路标；人类文本信任读者的理解力。

### Chinese / 中文

**Delete these when causality is clear / 因果明显时直接删除:**

- 因此 / 从而 / 这意味着 / 也正因如此 / 换言之 / 由此可见

**Before / 改前:**
> 温度每升高10°C，反应速率提高约一倍。**因此**，高温环境下的材料劣化速度显著加快。

**After / 改后:**
> 温度每升高10°C，反应速率提高约一倍。高温环境下材料劣化速度显著加快——这在户外暴露试验中已被反复验证。

The causal link is self-evident. Removing "因此" and adding a concrete grounding detail makes it sound more human.

### English

**Delete these when causality is clear:**

- thereby / thus / hence / consequently / as a result / it follows that / this means that

**Before:**
> The learning rate was reduced by a factor of 10 at epoch 50. **Consequently**, the loss curve stabilized.

**After:**
> The learning rate dropped by 10x at epoch 50. The loss curve stabilized within three epochs.

**Key rule / 关键规则:** Don't replace one AI connector with another. If you swap "因此" for "由此可见", the detection score doesn't change. Just delete.

不要用一个AI连接词替换另一个。把"因此"换成"由此可见"不会降低检测分数。直接删。

**Failure mode:** Deleting too many connectors makes reasoning feel jumpy; keep connectors where the causal link is non-obvious or crosses paragraph boundaries.

---

## Strategy 3: Concrete Over Vague / 具体化替代

Vague praise and empty intensifiers are strong AI signals. Replace them with specific metrics, numbers, or observable facts. If you don't have the data, mark it.

模糊赞美和空洞的程度副词是强AI信号。用具体指标、数字或可观察的事实替代。没有数据就标注。

### Chinese / 中文

| Vague / 模糊 | Concrete / 具体 |
|---|---|
| 显著提升了性能 | 将MAE从0.23降低至0.12（降幅48%） |
| 取得了良好的效果 | 在三组对比实验中均排名第一 |
| 具有广泛的应用前景 | 已在XX电网的12个变电站部署试运行 |
| 有效解决了该问题 | 将误报率从17%压缩至3.2% |

If you cannot verify a claim, write:

> 将检测精度提升至 [待补证]%

### English

| Vague | Concrete |
|---|---|
| significantly improved | reduced MAE from 0.23 to 0.12 (48% decrease) |
| achieved promising results | ranked first across all three benchmark datasets |
| has broad applications | deployed at 12 substations in XX power grid |
| effectively addresses the problem | cut false positive rate from 17% to 3.2% |

If you cannot verify a claim, write:

> Improved detection accuracy to [PENDING VERIFICATION]%

### Rule / 规则

Every claim should pass the "what number?" test. If you can't answer with a number, either find one or flag it.

每个主张都应通过"具体是多少?"测试。如果回答不出数字，要么找到数据，要么标注待补。

**Failure mode:** Fabricating specific numbers to replace vague claims is worse than leaving vague claims; only concretize when you have real data.

---

## Strategy 4: Vary Enumeration Structures / 列举结构差异化

When listing 3+ items (methods, contributions, sensors, etc.), **never use the same list format twice** in a document section.

当列举3项以上内容（方法、贡献、传感器等）时，在同一文档章节中**绝不重复使用同一种列举格式**。

### Three formats to rotate / 三种格式轮换

**Format A: Numbered list with periods / 编号句点式**

```
本文的主要贡献包括三个方面。(1) 提出了一种基于图注意力的多源融合框架。
(2) 设计了自适应权重分配机制。(3) 在三个公开数据集上验证了方法有效性。
```

**Format B: Semicolon-separated flow / 分号流式**

```
该方法具备三项特性：支持异步数据流输入；可在线调整融合权重；
对传感器故障具有鲁棒性。
```

**Format C: Natural narrative / 自然叙述式**

```
框架的核心在于图注意力机制（GAT），配合自适应权重模块完成多源信号的
实时融合。验证工作覆盖了 Dataset-A、B、C 三个基准集。
```

### English example

**Format A -- numbered:**

> This work makes three contributions. (1) A graph-attention fusion framework for multi-source data. (2) An adaptive weight allocation mechanism. (3) Validation on three public benchmarks.

**Format B -- semicolons in flow:**

> The method handles asynchronous inputs; adjusts fusion weights online; and degrades gracefully under sensor failure.

**Format C -- narrative:**

> At its core, the framework relies on graph attention (GAT) paired with an adaptive weighting module. We validated it on Dataset-A, B, and C.

### Rule / 规则

If Block 1 uses Format A, Block 2 should use B or C. Never let the detector see three numbered lists in a row.

如果第一块用了格式A，第二块就用B或C。绝不能让检测器看到连续三个编号列表。

**Failure mode:** Forcing different structures on naturally parallel items hurts readability; technical specs and method comparisons benefit from consistent format.

---

## Strategy 5: Break Mechanical Parallelism / 打破机械排比

Parallel structures like "不仅X，还Y" or "It is not only X but also Y" are AI fingerprints when overused. Break them.

"不仅X，还Y" 或 "It is not only X but also Y" 这样的排比结构在过度使用时就是AI指纹。打破它们。

### Chinese / 中文

| Mechanical / 机械排比 | Natural / 自然改写 |
|---|---|
| 不仅需要考虑精度，还需要兼顾效率 | 精度是首要指标，但部署时的推理速度同样不可忽视 |
| 不仅提升了检测率，还降低了误报率 | 检测率从82%提升至95%，误报率同步从12%降至3% |
| 不仅适用于A场景，还可推广至B场景 | 除A场景外，该方法在B场景中也通过了验证（见表4） |

### English

| Mechanical | Natural |
|---|---|
| It not only improves accuracy but also reduces latency | Accuracy goes up; latency goes down -- the two are not in tension here |
| The system is not just fast, it is also reliable | Speed and reliability usually trade off. Here they don't: median response time is 12ms at 99.97% uptime |
| This approach addresses not only X but also Y | The approach handles X. It also turns out to work for Y, though that was not the original design goal |

### Mixed cutting approaches / 混合切割方式

When describing multiple aspects, vary the angle:

- **Scene-based / 场景切入:** "在户外环境中..."
- **Classification-based / 分类切入:** "按数据类型划分..."
- **Method-based / 方法切入:** "采用分层策略..."

Don't let every paragraph start with the same type of framing.

不要让每段都以同一种框架开头。

**Failure mode:** Breaking parallelism in formal/legal/regulatory documents destroys precision; only apply in narrative prose.

---

## Strategy 6: Delete Generic Endings / 删除万金油结尾

AI loves to end sections and papers with grand, unfalsifiable statements. These are detection magnets.

AI喜欢用宏大的、不可证伪的陈述来结束章节和论文。这些是检测磁铁。

### Chinese / 中文

**Delete or replace / 删除或替换:**

| Generic ending / 万金油结尾 | Action / 处理 |
|---|---|
| 具有重要的理论意义和工程价值 | 删除，或替换为具体成果："该方法已集成至XX系统v2.1" |
| 为该领域的发展提供了新的思路 | 删除，或改为具体后续计划："下一步将在YY数据集上测试迁移性" |
| 对推动XX事业发展具有深远影响 | 直接删除 |
| 未来可期 | 直接删除 |

### English

| Generic ending | Action |
|---|---|
| The future looks bright for this field | Delete, or replace with a specific next step |
| This work opens new avenues for research | Delete, or name the specific avenue: "The logical next step is testing on out-of-distribution data" |
| has significant theoretical and practical implications | Delete, or state what the implication actually is |
| paves the way for future breakthroughs | Delete |

### Rule / 规则

If an ending sentence could appear unchanged in any paper from any field, it should be deleted or replaced with something field-specific.

如果一个结尾句可以原封不动地出现在任何领域的任何论文中，它应该被删除或替换为领域相关的具体内容。

**Failure mode:** Some genres require formulaic conclusions (grant proposals, compliance reports); know your audience before cutting.

---

## Strategy 7: Add Voice and Personality / 注入个性

This strategy applies mainly to English writing, and to Chinese writing in non-formal contexts (blogs, reports, commentary).

本策略主要适用于英文写作，以及中文非正式语境（博客、报告、评论）。

### English

Human writing has opinions, rhythm variation, and acknowledgment of complexity. AI writing is relentlessly balanced, evenly paced, and diplomatically neutral.

**Practical tips:**

- **Have opinions.** "Method X outperforms Y" is more human than "Method X and Method Y each have their own advantages."
- **Vary rhythm.** Follow a long analytical sentence with a short punchy one. "This works. Here's why it shouldn't."
- **Acknowledge mess.** "The results are not clean -- two of the five trials showed anomalous behavior that we cannot fully explain." This kind of honesty is rare in AI text.
- **Use first person when appropriate.** "We chose X because..." is more natural than "X was chosen due to..."
- **Be specific about uncertainty.** Not "further research is needed" but "we don't know whether this holds above 200°C."

### Chinese / 中文

在允许主观表达的语境中：

- **表达立场：** "X方法在本场景中明显优于Y" 比 "X方法和Y方法各有优势" 更自然。
- **承认局限：** "第三组实验的结果不太理想，原因尚不完全清楚" 比 "实验结果有待进一步分析" 更像人写的。
- **混合长短句：** 不要每句都是30字。偶尔来一句7字的短句。

### Rule / 规则

Perfect structure feels algorithmic. Let some controlled imperfection in.

完美的结构感觉像算法。放入一些有控制的不完美。

**Failure mode:** Injecting personal voice into third-person academic writing violates style norms; only for blogs, essays, and informal contexts.

---

## Strategy 8: Perplexity and Burstiness / 困惑度与突发性

These are the two main statistical signals that AI detectors measure.

这是AI检测器衡量的两个主要统计信号。

### Perplexity / 困惑度

**What it measures:** How unpredictable the next word is, given the previous words.

**衡量什么：** 给定前面的词，下一个词有多不可预测。

- AI text has **low** perplexity -- it always picks the most probable next word.
- Human text has **higher** perplexity -- humans make surprising word choices, use idioms, switch registers.

**How to increase perplexity / 如何提高困惑度:**

- Use domain-specific jargon mixed with casual phrasing
- 混合使用专业术语和口语化表达
- Choose less common synonyms occasionally (not always -- that's also detectable)
- 偶尔选择不太常见的近义词（不是每次——那也会被检测到）
- Insert parenthetical asides and qualifications
- 插入括号内的补充说明和限定

### Burstiness / 突发性

**What it measures:** How much sentence complexity varies within a passage.

**衡量什么：** 一段文字中句子复杂度的变化程度。

- AI text has **low** burstiness -- sentences are uniformly medium-length and medium-complexity.
- Human text has **high** burstiness -- a 40-word compound sentence followed by a 6-word fragment.

**How to increase burstiness / 如何提高突发性:**

- Mix sentence lengths deliberately. After a complex sentence, write a short one.
- 刻意混合句子长度。复杂句之后写一个短句。
- Vary paragraph lengths. Not every paragraph needs to be 4-5 sentences.
- 变化段落长度。不是每段都需要4-5句话。
- Occasionally use incomplete sentences or single-word emphasis. (Sparingly in academic text.)
- 偶尔使用不完整的句子或单词强调。（学术文本中慎用。）

### Practical test / 实操检验

Read your text aloud. If every sentence takes roughly the same number of breaths, burstiness is too low. If no word surprises you, perplexity is too low.

大声朗读你的文本。如果每句话大约需要相同的呼吸次数，突发性太低。如果没有任何词让你意外，困惑度太低。

**Failure mode:** Artificially increasing word unpredictability can produce gibberish; the goal is natural variation, not maximum entropy.

---

## Strategy 9: Two-Pass Rewriting / 两轮改写

A single rewriting pass catches the obvious patterns but often creates new ones. Always do two passes.

单次改写能捕捉明显的模式，但往往会制造新的模式。务必进行两轮改写。

### Process / 流程

**Pass 1 -- Fix detected issues / 第一轮——修复检测到的问题**

1. Run detection (automated or manual).
2. Fix all flagged patterns: skeletons, connectors, vocabulary.
3. Save the intermediate version.

运行检测（自动或手动）→ 修复所有标记的模式 → 保存中间版本。

**Pass 2 -- Hunt surviving patterns / 第二轮——追杀残存模式**

1. Re-read the rewrite from scratch. Ask: "What still sounds obviously AI?"
2. Look specifically for patterns that only become visible after the initial cleanup:
   - New skeleton repetitions introduced by the rewrite itself
   - Remaining connector chains that weren't flagged individually but form a pattern together
   - Uniform sentence length after editing (a common side effect of careful rewriting)
3. Fix surviving patterns.

从头重读改写版本，问自己："什么地方仍然一眼看出是AI？"
特别注意改写本身引入的新模式：新的骨架重复、残存的连接词链、编辑后变得整齐划一的句长。

**Pass 2 catches 15-30% additional patterns** that are invisible before Pass 1 cleanup.

第二轮通常能捕获额外15-30%的模式，这些在第一轮清理前是不可见的。

**Failure mode:** Over-editing in pursuit of zero AI traces can strip natural flow; stop after 2 passes to avoid over-polishing.

---

## Strategy 10: Section-Specific Strategies / 分章节策略

Different sections have different AI-trace profiles. Apply targeted strategies.

不同章节有不同的AI痕迹特征。采用针对性策略。

### Abstract / 摘要

- **Main risk / 主要风险:** Template structure ("In this paper, we propose... We evaluate... Results show... Our method achieves...")
- **Fix:** Vary the information order. Lead with the problem or the result, not "In this paper."
- **中文修复：** 不要以"本文提出了..."开头。可以从问题、结果或方法切入。

### Introduction / 引言

- **Main risk / 主要风险:** Paragraph-level skeleton repetition (each paragraph: topic sentence → context → gap → contribution)
- **Fix:** Mix paragraph structures. One paragraph can start with a question. Another can start with a concrete example.
- **中文修复：** 不是每段都需要"总分"结构。可以用问题开头、用案例开头、用数据开头。

### Related Work / 相关工作

- **Main risk / 主要风险:** "X et al. [1] proposed... Y et al. [2] proposed... Z et al. [3] proposed..."
- **Fix:** Group by theme, not by citation. Discuss what the approaches share and where they differ, rather than summarizing each paper sequentially.
- **中文修复：** 按主题而非按引用顺序组织。讨论方法的共性和差异，而非逐篇摘要。

### Methodology / 方法

- **Main risk / 主要风险:** Excessive signposting ("First, we define... Then, we construct... Next, we apply... Finally, we optimize...")
- **Fix:** Let the method flow naturally. Use subsection headings instead of connectors to organize steps.
- **中文修复：** 让方法自然流动。用小节标题代替"首先...然后...最后..."来组织步骤。

### Results / 结果

- **Main risk / 主要风险:** Repetitive comparison sentences ("Our method outperforms X by Y%. Compared to Z, our method achieves...")
- **Fix:** Vary comparison framing. Use tables for numbers, prose for insights. Lead with what is surprising or noteworthy.
- **中文修复：** 变化比较的表达方式。数字放表格，见解用文字。先说值得注意的发现。

### Discussion / 讨论

- **Main risk / 主要风险:** Generic hedging and future work boilerplate.
- **Fix:** Be specific about limitations ("fails when N < 50") and future work ("next step: test on dataset X").
- **中文修复：** 具体说明局限（"当N<50时失效"）和下一步计划（"计划在X数据集上测试"）。

### Conclusion / 结论

- **Main risk / 主要风险:** Restating the abstract with slight paraphrase + generic ending.
- **Fix:** Add something new -- a reflection, a caveat, or a specific recommendation. Cut all generic endings.
- **中文修复：** 加入新内容——反思、注意事项或具体建议。删除所有万金油结尾。

**Failure mode:** Applying narrative strategies to methods/results sections hurts reproducibility; keep technical sections precise.

---

## Anti-Patterns: What NOT to Do / 不该做的事

These are common mistakes that make rewriting ineffective or counterproductive.

以下是使改写无效或适得其反的常见错误。

### 1. Don't just swap synonyms / 不要只做近义词替换

Detectors analyze sentence structure, not individual words. Changing "utilize" to "use" while keeping the same skeleton achieves nothing.

检测器分析的是句式结构，不是单个词。在保持相同骨架的情况下把"utilize"改成"use"毫无意义。

### 2. Don't delete technical content / 不要删除技术内容

Only change **how** something is expressed, not **what** is expressed. Data, methods, formulas, citations, and reasoning steps are untouchable.

只改变表达**方式**，不改变表达**内容**。数据、方法、公式、引用和推理步骤不可触碰。

### 3. Don't over-compress / 不要过度压缩

Removing too many reasoning steps makes text feel jumpy and disconnected. The reader needs enough logical scaffolding to follow the argument.

删除太多推理步骤会让文本感觉跳跃和断裂。读者需要足够的逻辑支撑来跟上论证。

### 4. Don't replace one AI connector with another / 不要用AI连接词替换另一个AI连接词

Swapping "因此" for "由此可见" or "therefore" for "consequently" does not reduce detection. Delete the connector entirely when causality is obvious.

把"因此"换成"由此可见"，或"therefore"换成"consequently"，不会降低检测分数。因果关系明显时直接删除连接词。

### 5. Don't make all sentences the same length / 不要让所有句子一样长

A common side effect of careful editing is regularizing sentence length. After rewriting, check that sentence lengths still vary naturally.

仔细编辑的一个常见副作用是句子长度趋于一致。改写后，检查句子长度是否仍然自然变化。

### 6. Don't remove all section introductions / 不要删除所有章节引言

Section-level introductory sentences that orient the reader are useful and expected in academic writing. Don't confuse them with AI template sentences. The difference: a good intro is specific to the content that follows; an AI template intro could precede any content.

章节级的引导句对读者有帮助，在学术写作中是预期存在的。不要把它们和AI模板句混淆。区别在于：好的引言针对后续具体内容；AI模板引言可以放在任何内容前面。

---

## Quick Reference Checklist / 快速检查清单

Before finalizing any rewrite, verify:

改写定稿前，确认以下各项：

- [ ] No sentence skeleton appears 3+ times in adjacent paragraphs / 相邻段落中没有同一骨架出现3次以上
- [ ] No two consecutive enumeration blocks use the same format / 没有连续两个列举块使用相同格式
- [ ] Connector words deleted (not replaced) where causality is obvious / 因果明显处的连接词已删除（而非替换）
- [ ] Vague claims replaced with numbers or marked [PENDING] / 模糊主张已替换为数字或标注[待补证]
- [ ] Generic endings deleted or replaced with specifics / 万金油结尾已删除或替换为具体内容
- [ ] Sentence lengths vary naturally (mix of short and long) / 句子长度自然变化（长短句混合）
- [ ] Paragraph lengths vary (not all 4-5 sentences) / 段落长度有变化（不是都4-5句）
- [ ] Technical content fully preserved / 技术内容完整保留
- [ ] Two-pass rewriting completed / 已完成两轮改写
- [ ] Read aloud test passed / 通过了朗读测试

---

## Strategy 11: Style Extraction & Application / 文风提取与应用

For creative or non-academic writing, extract the target style first:

### Step 1: Feed 3-5 reference articles to an LLM with this 8-dimension analysis prompt:

```json
{
  "style_summary": "one-liner description",
  "language": { "sentence_pattern": [], "word_choice": { "formality_level": "1-5", "preferred_words": [], "avoided_words": [] }, "rhetoric": [] },
  "structure": { "paragraph_length": "", "transition_style": "", "hierarchy_pattern": "" },
  "narrative": { "perspective": "", "time_sequence": "", "narrator_attitude": "" },
  "emotion": { "intensity": "1-5", "expression_style": "", "tone": "" },
  "thinking": { "logic_pattern": "", "depth": "1-5", "rhythm": "" },
  "uniqueness": { "signature_phrases": [], "imagery_system": [] },
  "rhythm": { "syllable_pattern": "", "pause_pattern": "", "tempo": "" }
}
```

### Step 2: Feed the extracted JSON + new topic to the LLM in a separate conversation

### Step 3: Iterate 3-5 passes, reviewing and updating the style JSON each time

**Key insight:** "Learn style first, then write" produces better results than "emulate while writing."

> **Evidence note** (2026-03, observational): Style extraction effectiveness is based on community practice reports from 2025-2026 Chinese creative and academic writing contexts. Model capabilities change rapidly with each release. Not peer-reviewed.

**Failure mode:** Cloning another author's style too closely is plagiarism of voice; use as inspiration, not replication.

---

## Strategy 12: Multi-Model Collaborative Workflow / 多模型协作

1. **Claude/DeepSeek:** Generate logical initial draft (handles complex requirements)
2. **Gemini:** Polish/humanize final pass (lowest AI taste empirically)
3. **Manual review:** Fix remaining model-specific tics

> **Evidence note** (2026-03, observational): "Claude for logical initial drafts" and "Gemini for polish/lowest AI taste" reflects community preference as of 2025-2026, based on multiple Zhihu user reports and practitioner experience with Chinese creative and academic writing. Model capabilities change rapidly; re-evaluate when model versions update. Not peer-reviewed.

**Failure mode:** Model switching adds latency and cost; for short documents, a single well-prompted model is often sufficient.

---

## Strategy 13: Model-Specific Tic Override / 模型特有口癖覆盖

Some model traits survive any prompt modification. Explicitly prohibit them:

**DeepSeek tics to ban:**
- 量子纠缠, 潮汐, 赛博朋克 (used in unrelated topics)
- Obsessive preference for number 三 in structuring
- Parenthetical annotation abuse: text (with constant parentheticals)
- Tree-structured logic (1. → 1.1 → 1.1.1) instead of narrative prose

**Detection metric -- Tree Ratio:**
Tree Ratio = (numbered-list sentences + headers + enumerated points) / total sentences
If Tree Ratio >50% → rewrite into prose narrative.

> **Evidence note** (2026-03, observational): The 50% Tree Ratio threshold is an observational rule of thumb from community practice, not empirically validated with a controlled study. Adjust based on your specific genre and detector.

**Failure mode:** Overly aggressive prohibition lists can over-constrain the model, producing bland output; ban only confirmed tics.

---

## Strategy 14: Punctuation Normalization / 标点符号规范化

AI punctuation signatures (from Tencent Zhuque 2025 research):

> **Evidence note** (2026-03, industry report): Based on Tencent Zhuque Lab 2025 analysis. Specific to Chinese text detection and Chinese punctuation patterns. May not generalize to other languages or writing systems.

| Signal | AI Frequency | Human Frequency | Fix |
|--------|---|---|---|
| 双引号 for single terms ("区块链") | 30% higher | Low | Remove or use parentheses |
| 破折号 (dash) | Frequent, structural | Rare | Replace with comma/period |
| Space around English/digits | 100% (Doubao) | ~5% | Remove padding spaces |
| Nested 单引号 inside 双引号 | Abnormal | Absent | Flatten to single layer |

**Rule:** Max 1 quoted term per paragraph. If >3 single-word quoted terms per 500 chars → rewrite.

**Failure mode:** Removing all dashes and quoted terms can lose semantic precision; quotes around technical terms serve a definitional purpose.
