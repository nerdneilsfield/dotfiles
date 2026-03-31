---
name: deai
description: Reduce AI detection rate in writing (Chinese & English). Use when de-AIing, humanizing, or auditing text for AI traces in any format (LaTeX, Typst, Markdown, plain text).
---

# De-AI Writing Assistant (Chinese & English)

Detect and remove AI writing traces to reduce AI detection rate. Supports Chinese and English, multiple document formats, and both automated checking and LLM-guided rewriting.

## Core Principle

**AIGC detectors recognize sentence-structure fingerprints (skeleton repetition), not individual words.** The same skeleton used 3+ times triggers detection far more than any single word choice. Fix skeletons first, vocabulary second.

## Steps

1. Parse `$ARGUMENTS` to determine: target file/text, language (`--lang zh|en|auto`), mode (`--mode check|rewrite|audit`), and format.
2. If `--lang auto` or unspecified, auto-detect language by checking CJK character ratio.
3. Choose the appropriate workflow:

### Mode: `check` (default) -- Automated Detection

1. Run the detection script:
   ```bash
   python3 $SKILL_DIR/scripts/deai_check.py <file> --analyze --lang <zh|en|auto>
   ```
2. Review the report: section-by-section density scores, prioritized trace listing.
3. Present findings to user with actionable suggestions.

### Mode: `rewrite` -- LLM-Guided Rewriting

1. First run `check` to identify AI traces.
2. Read `$SKILL_DIR/references/REWRITING_GUIDE.md` for rewriting strategies.
3. Read the language-specific pattern file:
   - Chinese: `$SKILL_DIR/references/PATTERNS_ZH.md`
   - English: `$SKILL_DIR/references/PATTERNS_EN.md`
4. For each flagged section (highest density first):
   a. Apply skeleton-level transformations (vary sentence structure, break parallelisms).
   b. Apply vocabulary-level fixes (replace AI-typical words/phrases).
   c. Preserve all technical content, data, citations, and math.
5. **Second-pass audit**: Re-run detection on the rewritten text. If traces remain, fix them.
6. Output in diff-comment format showing original vs. revised with change explanations.

### Mode: `audit` -- Two-Pass Full Audit

1. Run `check` to get baseline scores.
2. Perform `rewrite` on all flagged sections.
3. Re-run `check` on rewritten output.
4. Generate before/after comparison report with density score improvements.

### Mode: `style-profile` -- Style Extraction

Analyze reference articles and output a JSON style profile. The profile captures 8 dimensions of writing style and can be used during `rewrite` mode to match the target author's voice.

1. Run the style profiler:
   ```bash
   python3 $SKILL_DIR/scripts/style_profile.py ref1.txt ref2.txt --output profile.json
   ```
2. The output JSON includes: sentence patterns (mean/std/CV), word choice (formality, preferred words), rhetoric, structure, narrative perspective, emotion, rhythm, and punctuation profile.
3. When using `rewrite` mode, optionally pass `--style-profile profile.json` to guide the LLM toward the target style.

### Model Profile: `--profile`

Control which model-specific detection rules are loaded:
- `generic` (default): Universal patterns only, no model-specific tics
- `deepseek`: Adds DeepSeek-specific patterns (量子/赛博 buzzwords, 三-fixation, parenthetical overload, tree numbering)
- `claude`: Skips all model-specific patterns
- `mixed`: Loads all model-specific patterns

## Detection Philosophy

### What We Check (Priority Order)

1. **Structural skeleton repetition** (highest signal) -- same sentence pattern used 3+ times
2. **Template expressions** -- phrases that fit any paper/article in any field
3. **Over-confident claims** -- absolute assertions without evidence
4. **Empty phrases** -- vague adjectives replaceable by specific data
5. **Vague quantification** -- "many studies" without citations
6. **AI vocabulary** -- words that appear 5-20x more often in AI text

### What We Preserve

- All technical content, data, and reasoning
- LaTeX/Typst commands, math environments, citations, labels
- Necessary causal connections and logical flow
- Chapter-level introductory paragraphs (style-guide recommended)
- Statistically qualified claims (with p-values, percentages)

## Rewriting Rules

1. **Zero fabrication**: Never add data, metrics, claims, or citations
2. **Skeleton over lexicon**: Change sentence structure, not just swap synonyms
3. **Content preservation**: Technical content is sacred; only modify how it's expressed
4. **Vary everything**: No two adjacent paragraphs should share the same structure
5. **Implicit causality**: Delete connector words when context makes causality obvious
6. **Specific over vague**: Replace vague claims with concrete data when available; mark as [PENDING] if not

## Output Format

```
% ============================================================
% De-AI Edit (Line X - [Section])
% ============================================================
% Original: [AI-trace text]
% Revised:  [Humanized text]
%
% Changes:
% 1. [Type]: [Details]
% 2. [Type]: [Details]
%
% Warning: [PENDING VERIFICATION] if any claims need evidence
% ============================================================
```

## Change Types

1. **skeleton_vary** -- Changed sentence structure to break repetition
2. **delete_empty** -- Removed vague adjective/adverb
3. **add_specific** -- Replaced vague claim with concrete data
4. **split_sentence** -- Divided sentence >50 words (ZH) or >40 words (EN)
5. **downgrade_claim** -- Added academic hedging
6. **delete_connector** -- Removed redundant causal connector
7. **replace_template** -- Replaced template expression with specific content
8. **replace_vocabulary** -- Replaced AI-typical word with natural alternative
9. **vary_parallelism** -- Broke mechanical parallelism (firstly/secondly/finally)
10. **merge_fragments** -- Combined fragmented sentences for natural flow

## Density Score Interpretation

| Score | Chinese | English | Action |
|-------|---------|---------|--------|
| >15%  | >10%    | Critical | Rewrite section immediately |
| 10-15%| 5-10%   | High     | Rewrite soon |
| 5-10% | 3-5%    | Medium   | Review and revise |
| <5%   | <3%     | Low      | Minor polish only |

## Script Reference

| Script | Purpose |
|--------|---------|
| `deai_check.py <file> --analyze` | Full document analysis with density scores |
| `deai_check.py <file> --section <name>` | Check specific section |
| `deai_check.py <file> --score` | Section scores only |
| `deai_check.py <file> --fix-suggestions` | JSON suggestions for programmatic fixing |
| `deai_check.py <file> --lang zh\|en\|mixed\|auto` | Specify language |
| `deai_batch.py <file> --all-sections` | Batch analysis of all sections |
| `deai_batch.py <file> --chapter <file>` | Process specific chapter file |
| `style_profile.py ref1.txt ref2.txt` | Extract 8-dimension style profile as JSON |
| `style_profile.py *.md -o profile.json` | Save style profile to file |

## Troubleshooting

- If section detection fails, use `--section` to specify manually.
- For mixed-language documents, use `--lang mixed` to run both Chinese and English patterns simultaneously.
- If false positive rate is high, check if claims are statistically qualified (p-values, percentages).
- For non-academic text (blog posts, emails), focus on vocabulary and template patterns; structural skeleton analysis is less relevant.
