#!/usr/bin/env python3
"""
Unified De-AI Writing Trace Checker (Chinese & English)
Analyzes documents for AI writing patterns across multiple formats.

Usage:
    python deai_check.py main.tex --analyze
    python deai_check.py main.tex --analyze --lang zh
    python deai_check.py paper.md --section introduction --lang en
    python deai_check.py draft.txt --fix-suggestions --lang auto
"""

import argparse
import json
import re
import sys
from pathlib import Path

try:
    from parsers import get_parser, detect_language
except ImportError:
    sys.path.append(str(Path(__file__).parent))
    from parsers import get_parser, detect_language


# ── Chinese Patterns ──────────────────────────────────────────────

ZH_EMPTY_PHRASES = {
    r"显著提升": "quantify",
    r"全面(?:分析|研究|系统)": "list_scope",
    r"有效解决": "compare_baseline",
    r"重要(?:意义|价值|贡献)": "explain_why",
    r"具有重要的(?:理论|实践|现实)(?:意义|价值)": "explain_why",
    r"具有重要的(?:理论意义|实践价值|工程价值)(?:和|与)": "explain_why",
    r"鲁棒性(?:好|强)": "specify_condition",
    r"新颖(?:方法|思路)": "explain_novelty",
    r"达到最先进水平": "cite_sota",
    r"取得(?:显著|重大)进展": "quantify_progress",
    r"具有广阔的应用前景": "explain_why",
    r"奠定了坚实的基础": "add_specific",
    r"提供了(?:有力|重要)的(?:支撑|保障|支持|依据)": "add_specific",
}

ZH_OVER_CONFIDENT = {
    r"显而易见": "hedge",
    r"毫无疑问": "hedge",
    r"必然": "condition",
    r"完全(?:解决了|消除了)": "limit",
    r"毫无例外": "limit",
    r"总是": "frequency",
    r"从不": "frequency",
    r"肯定": "hedge",
    r"一定": "hedge",
    r"毋庸置疑": "hedge",
    r"不言而喻": "hedge",
    r"众所周知": "hedge",
    r"不难发现": "hedge",
    r"彻底消除了": "limit",
    r"深远(?:的)?(?:影响|意义)": "explain_why",
}

ZH_VAGUE_QUANTIFIERS = {
    r"大量研究(?:表明|显示|指出)?": "cite_specific",
    r"众多(?:实验|学者)": "quantify_exp",
    r"多种(?:方法|方案)": "list_methods",
    r"若干(?:方面|问题)": "list_items",
    r"许多(?:研究|学者)": "cite_specific",
    r"大部分": "quantify_percent",
    r"大幅(?:提升|改善)": "quantify",
    r"显著(?:增加|减少)": "quantify",
    r"广泛的": "specify_scope",
    r"越来越多的": "increasingly",
    r"有研究(?:表明|显示|指出)": "cite_specific",
    r"研究表明": "cite_specific",
}

ZH_TEMPLATE_EXPRESSIONS = {
    r"近年来[，,]?": "specific_time",
    r"随着.*?的(?:快速|飞速|迅速|蓬勃|不断)发展": "context_direct",
    r"随着(?:科技|技术|社会)(?:的)?发展": "context_direct",
    r"在当今.*?背景下": "context_direct",
    r"在.*?蓬勃发展的今天": "context_direct",
    r"发挥(?:着)?(?:举足轻重|至关重要|不可或缺)的作用": "specific_impact",
    r"发挥(?:着)?重要(?:的)?作用": "specific_impact",
    r"被广泛(?:应用|使用)": "cite_examples",
    r"引起(?:了)?(?:广泛|极大)关注": "cite_examples",
    r"备受(?:关注|重视|瞩目)": "cite_examples",
    r"日益(?:增长|增加|迫切)的需求": "quantify",
    r"提供了有力的(?:支撑|保障|支持)": "add_specific",
    r"蓬勃(?:发展|兴起)": "growth_data",
    r"(?:具有|拥有).{0,8}(?:重要|深远|广阔).{0,6}(?:意义|影响|前景|价值)": "explain_why",
}

ZH_AI_CLICHES = {
    r"值得注意的是": "delete_empty",
    r"需要指出的是": "delete_empty",
    r"值得一提的是": "delete_empty",
    r"需要强调的是": "delete_empty",
    r"基于以上分析": "delete_empty",
    r"综上所述": "delete_empty",
}

ZH_META_NARRATION = {
    r"本(?:章|节|文)(?:主要|旨在)": "delete_empty",
    r"本(?:章|节)将(?:从|对|详细)": "delete_empty",
}

ZH_AI_TRANSITIONS = {
    r"由此可见": "delete_empty",
    r"有鉴于此": "delete_empty",
    r"鉴于此": "delete_empty",
}

ZH_OVER_CERTAINTY_MED = {
    r"至关重要": "hedge",
    r"极其重要": "hedge",
    r"不可忽视": "hedge",
    r"十分严重": "hedge",
}

ZH_COMPARISON_STRUCTURE = {
    r"一方面.*另一方面": "skeleton_vary",
}

ZH_BUZZWORDS = {
    r"赋能": "replace_vocabulary",
    r"闭环": "replace_vocabulary",
    r"抓手": "replace_vocabulary",
    r"可落地": "replace_vocabulary",
    r"痛点": "replace_vocabulary",
    r"打通": "replace_vocabulary",
}

# ── Chinese Model-Specific Patterns (DeepSeek, etc.) ─────────────

ZH_MODEL_TICS = {
    # DS-01: Quantum/cyber buzzword combos in unrelated topics
    r"(?:量子|赛博|纠缠|潮汐).{1,30}(?:量子|赛博|纠缠|潮汐)": "replace_vocabulary",
    # DS-02: "三" fixation (三个/三种/三重 + enumeration)
    r"三(?:个|种|重|大|项|方面)": "replace_vocabulary",
    # DS-03: Parenthetical annotation overload (3+ parentheticals in one line)
    r"（[^）]{2,20}）.*（[^）]{2,20}）.*（[^）]{2,20}）": "replace_vocabulary",
    # DS-04: Tree-style numbering (1.1, 1.1.1 etc.)
    r"\d+\.\d+\.\d+": "skeleton_vary",
    # PSEUDO-01: Pseudo-academic jargon stacking
    r"(?:拓扑|范式|维度|框架|生态).{1,20}(?:拓扑|范式|维度|框架|生态)": "replace_vocabulary",
}

# ── Chinese Punctuation Signatures ────────────────────────────────

ZH_PUNCTUATION_TRACES = {
    # PUNCT-01: 3+ single-word quoted terms (ASCII quotes)
    r'(?:"[^"]{1,4}")(?:[^"]*"[^"]{1,4}"){2,}': "replace_vocabulary",
    # PUNCT-01b: 3+ single-word quoted terms (Chinese quotes \u201c\u201d)
    r'(?:\u201c[^\u201d]{1,4}\u201d)(?:[^\u201c]*\u201c[^\u201d]{1,4}\u201d){2,}': "replace_vocabulary",
    # PUNCT-02: Em-dash (——) used as structural separator
    r"——": "replace_vocabulary",
    # PUNCT-03: Spaces padding around English/digits in Chinese context
    r"[\u4e00-\u9fff]\s+[A-Za-z0-9]+\s+[\u4e00-\u9fff]": "replace_vocabulary",
    # PUNCT-04: Nested single quotes inside double quotes
    r"\u201c[^\u201d]*\u2018[^\u2019]*\u2019[^\u201d]*\u201d": "replace_vocabulary",
    # PUNCT-05: 「」brackets (Japanese-style, sometimes used in Chinese AI output)
    r'\u300c[^\u300d]{1,4}\u300d': "replace_vocabulary",
    # PUNCT-06: 『』double brackets
    r'\u300e[^\u300f]{1,4}\u300f': "replace_vocabulary",
    # PUNCT-07: ASCII comma/period/colon after CJK char (should be fullwidth ，。：)
    r'[\u4e00-\u9fff][,.:;!?]': "replace_vocabulary",
    # PUNCT-08: Fullwidth digits/percent (０-９, ％)
    r'[\uff10-\uff19\uff05]': "replace_vocabulary",
}

# Severity classification for all pattern categories
# ── Pattern Metadata: severity + evidence level ──────────────────
# Evidence levels:
#   empirical     - backed by published research with quantified results
#   observational - community-validated pattern from multiple sources
#   model_specific- observed in specific model outputs, may not generalize
#   editorial     - stylistic preference, not necessarily detector-weighted

PATTERN_META: dict[str, dict[str, str]] = {
    # HIGH severity
    "empty_phrase":       {"severity": "HIGH",   "evidence": "empirical",      "signal": "detector"},
    "over_confident":     {"severity": "HIGH",   "evidence": "empirical",      "signal": "detector"},
    "ai_cliche":          {"severity": "HIGH",   "evidence": "observational",  "signal": "annoying"},
    "chatbot_artifact":   {"severity": "HIGH",   "evidence": "empirical",      "signal": "detector"},
    "tier1_vocabulary":   {"severity": "HIGH",   "evidence": "empirical",      "signal": "detector"},
    # MEDIUM severity
    "vague_quantifier":   {"severity": "MEDIUM", "evidence": "empirical",      "signal": "detector"},
    "template_expr":      {"severity": "MEDIUM", "evidence": "observational",  "signal": "detector"},
    "meta_narration":     {"severity": "MEDIUM", "evidence": "observational",  "signal": "annoying"},
    "ai_transition":      {"severity": "MEDIUM", "evidence": "observational",  "signal": "annoying"},
    "over_certainty_med": {"severity": "MEDIUM", "evidence": "observational",  "signal": "annoying"},
    "comparison_structure":{"severity": "MEDIUM","evidence": "editorial",      "signal": "style"},
    "tier2_cluster":      {"severity": "MEDIUM", "evidence": "empirical",      "signal": "detector"},
    "structural":         {"severity": "MEDIUM", "evidence": "empirical",      "signal": "detector"},
    "generic_reference":  {"severity": "MEDIUM", "evidence": "empirical",      "signal": "detector"},
    "punctuation_trace":  {"severity": "MEDIUM", "evidence": "observational",  "signal": "annoying"},
    "paragraph_metric":   {"severity": "MEDIUM", "evidence": "observational",  "signal": "detector"},
    # Model-specific
    "model_tic":          {"severity": "HIGH",   "evidence": "model_specific", "signal": "annoying"},
    # LOW severity
    "buzzword":           {"severity": "LOW",    "evidence": "editorial",      "signal": "style"},
    "tier3_density":      {"severity": "LOW",    "evidence": "empirical",      "signal": "detector"},
}

# Backwards-compatible helper
SEVERITY_MAP = {k: v["severity"] for k, v in PATTERN_META.items()}

# ── English Tier 2 Vocabulary (flag when 2+ in same paragraph) ────

EN_TIER2_WORDS = [
    "innovative", "dynamic", "scalable", "compelling", "unprecedented",
    "sophisticated", "instrumental", "world-class", "streamline",
    "empower", "foster", "spearhead", "resonate", "revolutionize",
    "facilitate", "underpin", "navigate", "reimagine", "catalyze",
    "galvanize", "augment", "cultivate", "illuminate", "elucidate",
    "juxtapose", "paradigm-shifting", "transformative", "cornerstone",
    "paramount", "poised", "burgeoning", "nascent", "quintessential",
    "overarching", "underpinning", "bolster", "encompass",
]

# ── English Tier 3 Vocabulary (flag at high density only) ─────────

EN_TIER3_WORDS = [
    "significant", "crucial", "nuanced", "multifaceted", "myriad",
    "plethora", "ecosystem", "moreover", "furthermore", "additionally",
    "subsequently",
]

# ── Chinese Connector Words (for structural overload detection) ───

ZH_CONNECTORS = [
    "因此", "这意味着", "也正因如此", "换言之", "由此可见",
    "有鉴于此", "综上所述", "总而言之",
]

EN_CONNECTORS = [
    "therefore", "thus", "hence", "consequently", "accordingly",
    "as a result", "thereby", "in conclusion",
]

# ── English Patterns ──────────────────────────────────────────────

EN_EMPTY_PHRASES = {
    r"\bsignificant\s+(?:improvement|performance|gain|enhancement|advancement)\b": "quantify",
    r"\bcomprehensive\s+(?:analysis|study|overview|survey|review)\b": "list_scope",
    r"\beffective\s+(?:solution|method|approach|technique)\b": "compare_baseline",
    r"\bimportant\s+(?:contribution|role|impact|implication)\b": "explain_why",
    r"\brobust\s+(?:performance|method|approach)\b": "specify_condition",
    r"\bnovel\s+(?:approach|method|technique|algorithm)\b": "explain_novelty",
    r"\bstate-of-the-art\s+(?:performance|results|accuracy)\b": "cite_sota",
    r"\bgroundbreaking\b": "explain_novelty",
    r"\bcutting-edge\b": "explain_novelty",
}

EN_OVER_CONFIDENT = {
    r"\bobviously\b": "hedge",
    r"\bclearly\b": "hedge",
    r"\bcertainly\b": "hedge",
    r"\bundoubtedly\b": "hedge",
    r"\bnecessarily\b": "condition",
    r"\bcompletely\b": "limit",
    r"\balways\b": "frequency",
    r"\bnever\b": "frequency",
}

EN_VAGUE_QUANTIFIERS = {
    r"\bmany\s+studies\b": "cite_specific",
    r"\bnumerous\s+experiments?\b": "quantify_exp",
    r"\bvarious\s+methods?\b": "list_methods",
    r"\bseveral\s+approaches?\b": "list_methods",
    r"\bmultiple\s+(?:datasets?|methods?|experiments?)\b": "quantify_items",
    r"\ba\s+(?:lot|large\s+number)\s+of\b": "quantify",
    r"\bthe\s+majority\s+of\b": "quantify_percent",
    r"\bsubstantial\s+(?:amount|number|gain|improvement)\b": "quantify",
}

EN_TEMPLATE_EXPRESSIONS = {
    r"\bin\s+recent\s+years\b": "specific_time",
    r"\bmore\s+and\s+more\b": "increasingly",
    r"\bplays?\s+an?\s+(?:important|crucial|vital|pivotal)\s+role\b": "specific_impact",
    r"\bwith\s+the\s+(?:rapid\s+)?development\s+of\b": "context_direct",
    r"\bhas\s+(?:been\s+)?widely\s+used\b": "cite_examples",
    r"\bhas\s+attracted\s+(?:much\s+|considerable\s+|significant\s+|widespread\s+)?attention\b": "cite_examples",
    r"\bit\s+is\s+worth\s+noting\s+that\b": "delete_empty",
    r"\bin\s+conclusion\b": "delete_empty",
    r"\bto\s+summarize\b": "delete_empty",
    r"\bit\s+should\s+be\s+noted\s+that\b": "delete_empty",
    r"\bneedless\s+to\s+say\b": "delete_empty",
    r"\bas\s+we\s+all\s+know\b": "delete_empty",
    r"\bthere\s+is\s+a\s+growing\s+need\s+for\b": "delete_empty",
    r"\bis\s+of\s+great\s+significance\b": "delete_empty",
}

EN_TIER1_VOCABULARY = {
    r"\bdelve(?:s|d)?\s+(?:into)?\b": "replace_vocabulary",
    r"\blandscape\b": "replace_vocabulary",
    r"\btapestry\b": "replace_vocabulary",
    r"\brealm\b": "replace_vocabulary",
    r"\bparadigm\b": "replace_vocabulary",
    r"\bembark(?:s|ed)?\b": "replace_vocabulary",
    r"\bbeacon\b": "replace_vocabulary",
    r"\btestament\s+to\b": "replace_vocabulary",
    r"\brobust\b": "replace_vocabulary",
    r"\bcomprehensive\b": "replace_vocabulary",
    r"\bleverage(?:s|d)?\b": "replace_vocabulary",
    r"\bpivotal\b": "replace_vocabulary",
    r"\bunderscores?\b": "replace_vocabulary",
    r"\bmeticulous(?:ly)?\b": "replace_vocabulary",
    r"\bseamless(?:ly)?\b": "replace_vocabulary",
    r"\bgame[- ]chang(?:er|ing)\b": "replace_vocabulary",
    r"\butilize(?:s|d)?\b": "replace_vocabulary",
    r"\bwatershed\s+moment\b": "replace_vocabulary",
    r"\bnestled\b": "replace_vocabulary",
    r"\bvibrant\b": "replace_vocabulary",
    r"\bthriving\b": "replace_vocabulary",
    r"\bshowcasing\b": "replace_vocabulary",
    r"\bholistic(?:ally)?\b": "replace_vocabulary",
    r"\bactionable\b": "replace_vocabulary",
    r"\bimpactful\b": "replace_vocabulary",
    r"\bsynergy\b": "replace_vocabulary",
    r"\binterplay\b": "replace_vocabulary",
    r"\bin\s+order\s+to\b": "replace_vocabulary",
    r"\bdue\s+to\s+the\s+fact\s+that\b": "replace_vocabulary",
    r"\bserves\s+as\b": "replace_vocabulary",
    r"\bboasts\b": "replace_vocabulary",
    r"\bcommence(?:s|d)?\b": "replace_vocabulary",
    r"\bascertain\b": "replace_vocabulary",
    r"\bendeavor(?:s)?\b": "replace_vocabulary",
    r"\bbest\s+practices?\b": "replace_vocabulary",
    r"\bdeep\s+dive\b": "replace_vocabulary",
    r"\bunpack(?:ing)?\b": "replace_vocabulary",
    r"\bembrace(?:s|d)?\b": "replace_vocabulary",
    r"\bintricate\b": "replace_vocabulary",
    r"\bcomplexities\b": "replace_vocabulary",
    r"\bever-evolving\b": "replace_vocabulary",
    r"\benduring\b": "replace_vocabulary",
    r"\bdaunting\b": "replace_vocabulary",
    r"\bthought\s+leader(?:ship)?\b": "replace_vocabulary",
    r"\blearnings\b": "replace_vocabulary",
}

# ── English Generic References (Desaire et al. 2023, Cell Reports) ─

EN_GENERIC_REFERENCES = {
    r"\bresearchers\s+have\s+(?:shown|found|demonstrated|suggested|noted)\b": "cite_specific",
    r"\bother\s+researchers\b": "cite_specific",
    r"\bexperts\s+(?:believe|suggest|argue|note)\b": "cite_specific",
    r"\bstudies\s+(?:have\s+)?(?:shown|demonstrated|suggested|indicated)\b": "cite_specific",
    r"\bprevious\s+(?:research|work|studies)\s+(?:has|have)\b": "cite_specific",
}

EN_CHATBOT_ARTIFACTS = {
    r"\bcertainly[!.]": "delete_empty",
    r"\bi\s+hope\s+this\s+helps\b": "delete_empty",
    r"\blet\s+me\s+know\s+if\b": "delete_empty",
    r"\bgreat\s+question\b": "delete_empty",
    r"\byou'?re\s+absolutely\s+right\b": "delete_empty",
    r"\blet'?s\s+(?:explore|break\s+this\s+down|dive\s+in)\b": "delete_empty",
}


# ── Instructions ──────────────────────────────────────────────────

ZH_INSTRUCTIONS = {
    "quantify": '替换为具体数值或指标 (如 "降低了 12%").',
    "list_scope": "列举具体分析了哪些方面.",
    "compare_baseline": "陈述相对于基线的具体改进幅度.",
    "explain_why": "解释具体的重要性或影响.",
    "specify_condition": "说明成立的具体条件.",
    "explain_novelty": "解释具体的技术差异点.",
    "cite_sota": "引用具体的 SOTA 论文并对比指标.",
    "quantify_progress": "用数据量化进展.",
    "hedge": '使用学术限定语 (如 "实验结果表明").',
    "condition": '增加前提条件 (如 "在本文设置下").',
    "limit": "承认局限性或边界条件.",
    "frequency": "使用频率副词或具体统计.",
    "cite_specific": "引用具体文献 [1-3].",
    "quantify_exp": "说明具体的实验或数据集数量.",
    "list_methods": "列举具体的对比方法.",
    "list_items": "列举具体的点.",
    "quantify_percent": "说明具体百分比.",
    "quantify_items": "说明确切数量.",
    "specify_scope": "界定具体范围.",
    "specific_time": '使用具体时间段或 "自 20XX 年以来".',
    "increasingly": "描述具体的增长趋势.",
    "specific_impact": "描述具体的功能或影响.",
    "context_direct": "直接切入具体问题背景.",
    "cite_examples": "提供具体的引用案例.",
    "growth_data": "提供增长数据支持.",
    "add_specific": "用具体内容替换空泛表述.",
    "delete_empty": "直接删除此表达.",
    "replace_vocabulary": "替换为更自然的中文表达.",
    "skeleton_vary": "改变句式结构，避免重复同一骨架.",
    "delete_connector": "删除冗余连接词，让因果关系隐含在上下文中.",
}

EN_INSTRUCTIONS = {
    "quantify": 'Replace with specific numbers or metrics (e.g., "reduces error by 12%").',
    "list_scope": "Explicitly list what was covered (X, Y, Z).",
    "compare_baseline": 'State improvement over baseline (e.g., "reduces error by X%").',
    "explain_why": "Explain specific importance or impact.",
    "specify_condition": "Specify under what conditions this holds.",
    "explain_novelty": "Explain specific technical difference.",
    "cite_sota": "Cite specific SOTA papers and compare metrics.",
    "quantify_progress": "Quantify progress with data.",
    "hedge": 'Use academic hedging (e.g., "results suggest").',
    "condition": 'Add condition (e.g., "under assumption X").',
    "limit": "Acknowledge limitations or boundaries.",
    "frequency": "Use frequency adverb or specific count.",
    "cite_specific": "Cite specific papers [1-3].",
    "quantify_exp": "State number of experiments/datasets.",
    "list_methods": "List specific methods compared.",
    "list_items": "List specific items.",
    "quantify_items": "State exact number.",
    "quantify_percent": "State percentage.",
    "specify_scope": "Define specific scope.",
    "specific_time": 'Use specific time period or "since 20XX".',
    "increasingly": 'Use "increasingly" or provide growth data.',
    "specific_impact": "Describe specific impact or function.",
    "context_direct": "Start directly with the problem/context.",
    "cite_examples": "Provide citation examples.",
    "growth_data": "Provide growth data.",
    "add_specific": "Replace with specific content.",
    "delete_empty": "Delete this expression entirely.",
    "replace_vocabulary": "Replace with a more natural alternative.",
}


class DeAIChecker:
    """Unified De-AI trace checker for Chinese and English."""

    def __init__(self, file_path: Path, lang: str = "auto", profile: str = "generic"):
        self.file_path = file_path
        self.content = file_path.read_text(encoding="utf-8", errors="ignore")
        self.lines = self.content.split("\n")
        self.parser = get_parser(file_path)
        self.section_ranges = self.parser.split_sections(self.content)
        self.comment_prefix = self.parser.get_comment_prefix()
        self.profile = profile  # generic, deepseek, claude, mixed

        if lang == "auto":
            self.lang = detect_language(self.content)
        else:
            self.lang = lang

        self._build_patterns()

    def _build_patterns(self) -> None:
        """Build pattern list based on detected language and profile."""
        self.all_patterns: list[tuple[str, dict[str, str]]] = []

        if self.lang in ("zh", "mixed"):
            self.all_patterns += [
                ("empty_phrase", ZH_EMPTY_PHRASES),
                ("over_confident", ZH_OVER_CONFIDENT),
                ("vague_quantifier", ZH_VAGUE_QUANTIFIERS),
                ("template_expr", ZH_TEMPLATE_EXPRESSIONS),
                ("ai_cliche", ZH_AI_CLICHES),
                ("meta_narration", ZH_META_NARRATION),
                ("ai_transition", ZH_AI_TRANSITIONS),
                ("over_certainty_med", ZH_OVER_CERTAINTY_MED),
                ("comparison_structure", ZH_COMPARISON_STRUCTURE),
                ("buzzword", ZH_BUZZWORDS),
                ("punctuation_trace", ZH_PUNCTUATION_TRACES),
            ]
            # Model-specific: full set for deepseek/mixed profile,
            # pseudo-academic only for generic, skip for claude
            if self.profile in ("deepseek", "mixed"):
                self.all_patterns.append(("model_tic", ZH_MODEL_TICS))
            elif self.profile == "generic":
                generic_tics = {k: v for k, v in ZH_MODEL_TICS.items() if "拓扑" in k}
                if generic_tics:
                    self.all_patterns.append(("model_tic", generic_tics))
            # claude profile: no model_tic patterns
            self.instructions = ZH_INSTRUCTIONS

        if self.lang in ("en", "mixed"):
            self.all_patterns += [
                ("empty_phrase", EN_EMPTY_PHRASES),
                ("over_confident", EN_OVER_CONFIDENT),
                ("vague_quantifier", EN_VAGUE_QUANTIFIERS),
                ("template_expr", EN_TEMPLATE_EXPRESSIONS),
                ("tier1_vocabulary", EN_TIER1_VOCABULARY),
                ("chatbot_artifact", EN_CHATBOT_ARTIFACTS),
                ("generic_reference", EN_GENERIC_REFERENCES),
            ]
            if self.lang == "mixed":
                self.instructions = {**EN_INSTRUCTIONS, **ZH_INSTRUCTIONS}
            else:
                self.instructions = EN_INSTRUCTIONS

    def _is_false_positive(self, match_obj: re.Match, text: str, pattern: str) -> bool:
        """Check context to rule out false positives."""
        start, end = match_obj.span()
        context_after = text[end: end + 60]
        context_before = text[max(0, start - 60): start]

        if self.lang == "zh":
            # Quantified claims with numbers
            if "显著" in pattern or "大幅" in pattern:
                if re.search(r"\d+(?:\.\d+)?%", context_after):
                    return True
                if re.search(r"p\s*[<>=]\s*0\.\d+", context_after):
                    return True
            # Chapter introductions (style-guide recommended)
            if "本章" in text and re.search(r"首先.*?随后.*?最后", text):
                return True
        else:
            # Statistical significance
            if "significant" in pattern:
                if re.search(r"statistically", context_before, re.IGNORECASE):
                    return True
                if re.search(r"p\s*[<>=]\s*0\.\d+", context_after):
                    return True
                if re.search(r"at\s+the\s+0\.\d+\s+level", context_after):
                    return True
            # Quantified improvements
            if "improvement" in pattern or "gain" in pattern:
                if re.search(r"(?:by|of)\s+\d+(?:\.\d+)?%", context_after):
                    return True
            # Specific ranges
            if "comprehensive" in pattern:
                if "from" in context_after and "to" in context_after:
                    return True

        return False

    def _find_traces_in_section(
        self, pattern: str, suggestion_type: str, section_name: str, category: str
    ) -> list[dict]:
        """Find pattern occurrences in a specific section."""
        if section_name not in self.section_ranges:
            return []

        start, end = self.section_ranges[section_name]
        matches = []
        re_flags = re.IGNORECASE if self.lang == "en" else 0

        for i in range(start - 1, min(end, len(self.lines))):
            line = self.lines[i]
            stripped = line.strip()

            if stripped.startswith(self.comment_prefix):
                continue

            visible_text = self.parser.extract_visible_text(stripped)
            if not visible_text:
                continue

            for match in re.finditer(pattern, visible_text, re_flags):
                if self._is_false_positive(match, visible_text, pattern):
                    continue

                matches.append({
                    "line": i + 1,
                    "text": visible_text,
                    "original": stripped,
                    "matched": match.group(),
                    "match_start": match.start(),
                    "match_end": match.end(),
                    "pattern": pattern,
                    "category": category,
                    "section": section_name,
                    "suggestion_type": suggestion_type,
                })

        return matches

    def _check_tier2_clusters(self, section_name: str) -> list[dict]:
        """Detect Tier 2 word clusters (2+ in same paragraph)."""
        if self.lang == "zh":
            return []
        if section_name not in self.section_ranges:
            return []

        start, end = self.section_ranges[section_name]
        traces = []
        paragraph: list[str] = []
        para_start = start

        for i in range(start - 1, min(end, len(self.lines)) + 1):
            line = self.lines[i].strip() if i < len(self.lines) else ""
            if not line and paragraph:
                para_text = " ".join(paragraph)
                found_words = []
                for word in EN_TIER2_WORDS:
                    if re.search(rf"\b{word}\b", para_text, re.IGNORECASE):
                        found_words.append(word)
                if len(found_words) >= 2:
                    traces.append({
                        "line": para_start,
                        "text": para_text[:80],
                        "original": para_text[:80],
                        "matched": ", ".join(found_words),
                        "pattern": "tier2_cluster",
                        "category": "tier2_cluster",
                        "section": section_name,
                        "suggestion_type": "replace_vocabulary",
                    })
                paragraph = []
                para_start = i + 2
            elif line:
                visible = self.parser.extract_visible_text(line)
                if visible:
                    paragraph.append(visible)

        return traces

    def _check_paragraph_metrics(self, section_name: str) -> list[dict]:
        """Compute paragraph-level structural metrics and flag anomalies.

        Metrics (per 500 chars/words):
        - parenthetical_rate: () or （）count
        - quote_term_rate: single-word quoted terms ("X" or \u201cX\u201d)
        - enumeration_ratio: 首先/其次/最后, 第一/第二, numbered lists
        - tree_ratio: headers + numbered items / total lines
        """
        if section_name not in self.section_ranges:
            return []

        start, end = self.section_ranges[section_name]
        traces = []

        section_text = ""
        numbered_lines = 0
        total_content_lines = 0

        for i in range(start - 1, min(end, len(self.lines))):
            visible = self.parser.extract_visible_text(self.lines[i].strip())
            if not visible:
                continue
            section_text += visible + "\n"
            total_content_lines += 1
            # Count numbered/enumerated lines
            if re.match(r"^\s*(?:\d+[.)）]|[①②③④⑤]|[-*•])\s", visible):
                numbered_lines += 1

        if not section_text or len(section_text) < 20:
            return []  # Too short for meaningful paragraph metrics

        text_len = len(section_text)
        unit = max(text_len / 500, 1)  # normalize to per-500-char

        # Parenthetical rate: （...） and (...)
        paren_count = len(re.findall(r"[（(][^）)]{2,}[）)]", section_text))
        paren_rate = paren_count / unit
        if paren_rate > 3:  # >3 parentheticals per 500 chars
            traces.append({
                "line": start, "text": f"Parenthetical rate: {paren_rate:.1f}/500c ({paren_count} total)",
                "original": f"parenthetical_rate={paren_rate:.1f}",
                "matched": f"parenthetical overload ({paren_count}x)",
                "pattern": "parenthetical_rate", "category": "paragraph_metric",
                "section": section_name, "suggestion_type": "skeleton_vary",
            })

        # Quote-term rate: single-word quoted terms
        zh_quotes = len(re.findall(r'[\u201c"][^\u201d"]{1,4}[\u201d"]', section_text))
        quote_rate = zh_quotes / unit
        if quote_rate > 3:  # >3 quoted terms per 500 chars
            traces.append({
                "line": start, "text": f"Quoted-term rate: {quote_rate:.1f}/500c ({zh_quotes} total)",
                "original": f"quote_term_rate={quote_rate:.1f}",
                "matched": f"quote-term overload ({zh_quotes}x)",
                "pattern": "quote_term_rate", "category": "paragraph_metric",
                "section": section_name, "suggestion_type": "replace_vocabulary",
            })

        # Enumeration ratio
        enum_markers = len(re.findall(
            r"首先|其次|最后|再次|第[一二三四五六七八九十]|"
            r"\bfirst(?:ly)?\b|\bsecond(?:ly)?\b|\bthird(?:ly)?\b|\bfinally\b",
            section_text, re.IGNORECASE
        ))
        enum_ratio = enum_markers / total_content_lines if total_content_lines else 0
        if enum_ratio > 0.3 and total_content_lines >= 3:  # >30% and at least 3 lines
            traces.append({
                "line": start, "text": f"Enumeration ratio: {enum_ratio:.0%} ({enum_markers}/{total_content_lines})",
                "original": f"enumeration_ratio={enum_ratio:.2f}",
                "matched": f"enumeration overload ({enum_ratio:.0%})",
                "pattern": "enumeration_ratio", "category": "paragraph_metric",
                "section": section_name, "suggestion_type": "skeleton_vary",
            })

        # Tree ratio: numbered/bulleted lines / total
        tree_ratio = numbered_lines / total_content_lines if total_content_lines else 0
        if tree_ratio > 0.5:  # >50% numbered/bulleted
            traces.append({
                "line": start, "text": f"Tree ratio: {tree_ratio:.0%} ({numbered_lines}/{total_content_lines})",
                "original": f"tree_ratio={tree_ratio:.2f}",
                "matched": f"tree structure ({tree_ratio:.0%})",
                "pattern": "tree_ratio", "category": "paragraph_metric",
                "section": section_name, "suggestion_type": "skeleton_vary",
            })

        return traces

    def _check_sentence_uniformity(self, section_name: str) -> list[dict]:
        """Detect AI-like sentence length uniformity (Desaire et al. 2023, AUC 0.98).

        Humans vary sentence lengths (std dev ~10-15 words). AI keeps them
        uniform (std dev ~3-6 words). Flag sections where std dev is too low.
        """
        if section_name not in self.section_ranges:
            return []
        start, end = self.section_ranges[section_name]

        sentence_lengths: list[int] = []
        for i in range(start - 1, min(end, len(self.lines))):
            visible = self.parser.extract_visible_text(self.lines[i].strip())
            if not visible:
                continue
            # Split into sentences (rough: period/question/exclamation + Chinese 。！？)
            sentences = re.split(r'[.!?。！？]\s*', visible)
            for s in sentences:
                s = s.strip()
                if not s:
                    continue
                if self.lang in ("zh", "mixed"):
                    wc = len(s)  # character count for Chinese
                else:
                    wc = len(s.split())  # word count for English
                if wc >= 3:  # skip trivial fragments
                    sentence_lengths.append(wc)

        if len(sentence_lengths) < 5:
            return []  # too few sentences for meaningful analysis

        import statistics
        mean_len = statistics.mean(sentence_lengths)
        std_len = statistics.stdev(sentence_lengths)

        # Coefficient of variation: std/mean. AI typically <0.25; humans >0.35
        if mean_len == 0:
            return []
        cv = std_len / mean_len

        traces = []
        # For English: flag if CV < 0.25 (very uniform)
        # For Chinese: flag if CV < 0.20 (chars vary less naturally)
        threshold = 0.20 if self.lang in ("zh", "mixed") else 0.25
        if cv < threshold:
            traces.append({
                "line": start,
                "text": f"Sentence length CV={cv:.2f} (mean={mean_len:.0f}, std={std_len:.1f}, n={len(sentence_lengths)})",
                "original": f"Low sentence diversity: CV={cv:.2f}",
                "matched": f"uniformity CV={cv:.2f}",
                "pattern": "sentence_uniformity",
                "category": "structural",
                "section": section_name,
                "suggestion_type": "skeleton_vary",
            })
        return traces

    def _check_connector_overload(self, section_name: str) -> list[dict]:
        """Detect connector word overload (3+ in same paragraph)."""
        if section_name not in self.section_ranges:
            return []

        start, end = self.section_ranges[section_name]
        connectors = ZH_CONNECTORS if self.lang in ("zh", "mixed") else EN_CONNECTORS
        traces = []
        paragraph_lines: list[tuple[int, str]] = []

        for i in range(start - 1, min(end, len(self.lines)) + 1):
            line = self.lines[i].strip() if i < len(self.lines) else ""
            if not line and paragraph_lines:
                para_text = " ".join(t for _, t in paragraph_lines)
                count = sum(1 for c in connectors if c in para_text.lower())
                if count >= 3:
                    first_line = paragraph_lines[0][0]
                    traces.append({
                        "line": first_line,
                        "text": para_text[:80],
                        "original": para_text[:80],
                        "matched": f"{count} connectors in paragraph",
                        "pattern": "connector_overload",
                        "category": "structural",
                        "section": section_name,
                        "suggestion_type": "delete_connector" if self.lang == "zh" else "delete_empty",
                    })
                paragraph_lines = []
            elif line:
                visible = self.parser.extract_visible_text(line)
                if visible:
                    paragraph_lines.append((i + 1, visible))

        return traces

    def _check_tier3_density(self, section_name: str) -> list[dict]:
        """Detect Tier 3 words that appear at high density (>3% = >30 per 1000 words)."""
        if self.lang == "zh":
            return []
        if section_name not in self.section_ranges:
            return []

        start, end = self.section_ranges[section_name]
        section_text = ""
        for i in range(start - 1, min(end, len(self.lines))):
            visible = self.parser.extract_visible_text(self.lines[i].strip())
            if visible:
                section_text += " " + visible

        word_count = len(section_text.split())
        if word_count < 50:
            return []  # Too short for meaningful density analysis

        traces = []
        for word in EN_TIER3_WORDS:
            occurrences = len(re.findall(rf"\b{word}\b", section_text, re.IGNORECASE))
            if occurrences == 0:
                continue
            density = (occurrences / word_count) * 1000
            if density > 30:
                # Find first occurrence line for the trace
                first_line = start
                for i in range(start - 1, min(end, len(self.lines))):
                    visible = self.parser.extract_visible_text(self.lines[i].strip())
                    if visible and re.search(rf"\b{word}\b", visible, re.IGNORECASE):
                        first_line = i + 1
                        break
                traces.append({
                    "line": first_line,
                    "text": f'"{word}" appears {occurrences}x in {word_count} words ({density:.1f}/1000)',
                    "original": f'"{word}" x{occurrences}',
                    "matched": f"{word} ({occurrences}x, {density:.1f}/1000w)",
                    "pattern": "tier3_density",
                    "category": "tier3_density",
                    "section": section_name,
                    "suggestion_type": "replace_vocabulary",
                })

        return traces

    def _count_words(self, section_name: str) -> int:
        """Count words/characters in a section for density calculation."""
        if section_name not in self.section_ranges:
            return 0
        start, end = self.section_ranges[section_name]
        total = 0
        for i in range(start - 1, min(end, len(self.lines))):
            visible = self.parser.extract_visible_text(self.lines[i].strip())
            if self.lang == "zh":
                total += sum(1 for c in visible if "\u4e00" <= c <= "\u9fff")
            else:
                total += len(visible.split())
        return total

    def check_section(self, section_name: str) -> dict:
        """Check a specific section for AI traces."""
        results = {
            "section": section_name,
            "total_lines": 0,
            "total_words": 0,
            "trace_count": 0,
            "traces": [],
        }

        if section_name not in self.section_ranges:
            start, end = 1, len(self.lines)
        else:
            start, end = self.section_ranges[section_name]

        results["total_lines"] = end - start + 1
        results["total_words"] = self._count_words(section_name)

        # Pattern-based detection
        for category, patterns_dict in self.all_patterns:
            for pattern, suggestion_type in patterns_dict.items():
                matches = self._find_traces_in_section(
                    pattern, suggestion_type, section_name, category
                )
                results["traces"].extend(matches)

        # Tier 2 cluster detection (English)
        results["traces"].extend(self._check_tier2_clusters(section_name))

        # Paragraph-level structural metrics
        results["traces"].extend(self._check_paragraph_metrics(section_name))

        # Structural: sentence-length uniformity (Desaire et al. 2023, AUC 0.98)
        results["traces"].extend(self._check_sentence_uniformity(section_name))

        # Structural: connector overload
        results["traces"].extend(self._check_connector_overload(section_name))

        # Tier 3 density detection (English)
        results["traces"].extend(self._check_tier3_density(section_name))

        # Dedup overlapping spans on the same line.
        # Only suppress a trace if its character span is fully contained
        # within another trace's span on the same line. Identical patterns
        # at *different* positions (e.g., five 值得注意的是 on one line)
        # are all kept because their spans don't overlap.
        deduped = []
        # Sort: longer spans first so they claim priority
        results["traces"].sort(
            key=lambda t: (
                t["line"],
                -(t.get("match_end", 0) - t.get("match_start", 0)),
            )
        )
        # kept_spans: list of (line, start, end) already accepted
        kept_spans: list[tuple[int, int, int]] = []
        for trace in results["traces"]:
            s = trace.get("match_start", -1)
            e = trace.get("match_end", -1)
            ln = trace["line"]
            if s == -1:
                # Traces without span info (tier2, structural) always kept
                deduped.append(trace)
                continue
            # Check if fully contained in an already-kept span
            dominated = any(
                kl == ln and ks <= s and e <= ke
                for kl, ks, ke in kept_spans
            )
            if not dominated:
                deduped.append(trace)
                kept_spans.append((ln, s, e))
        results["traces"] = deduped

        # Add severity and evidence level to each trace
        for trace in results["traces"]:
            meta = PATTERN_META.get(trace["category"], {"severity": "MEDIUM", "evidence": "observational"})
            trace["severity"] = meta["severity"]
            trace["evidence"] = meta["evidence"]
            trace["signal"] = meta.get("signal", "detector")

        results["trace_count"] = len(results["traces"])
        return results

    def analyze_document(self) -> dict:
        """Analyze entire document."""
        analysis = {
            "file": str(self.file_path),
            "language": self.lang,
            "total_lines": len(self.lines),
            "sections": {},
        }

        for section_name in self.section_ranges:
            analysis["sections"][section_name] = self.check_section(section_name)

        return analysis

    def calculate_density_score(self, result: dict) -> float:
        """Calculate AI trace density (traces per 100 words/chars)."""
        words = result.get("total_words", 0)
        if words > 0:
            return (result["trace_count"] / words) * 100
        # Fallback to line-based if word count unavailable
        if result["total_lines"] == 0:
            return 0.0
        return (result["trace_count"] / result["total_lines"]) * 100

    def _get_instruction(self, key: str) -> str:
        """Get human-readable instruction for suggestion key."""
        default = "请改写得更具体、客观。" if self.lang == "zh" else "Rewrite to be more specific and objective."
        return self.instructions.get(key, default)

    def generate_suggestions_json(self, analysis: dict) -> list[dict]:
        """Generate structured suggestions for programmatic fixing."""
        suggestions = []
        for section_name, result in analysis["sections"].items():
            for trace in result["traces"]:
                suggestions.append({
                    "file": str(self.file_path),
                    "line": trace["line"],
                    "section": section_name,
                    "category": trace["category"],
                    "matched": trace["matched"],
                    "issue": trace["text"],
                    "pattern": trace["pattern"],
                    "suggestion_key": trace["suggestion_type"],
                    "instruction": self._get_instruction(trace["suggestion_type"]),
                })
        return suggestions

    def generate_report(self, analysis: dict) -> str:
        """Generate human-readable report."""
        report = []
        sep = "=" * 70
        dash = "-" * 70

        if self.lang == "zh":
            report.append(sep)
            report.append("去AI化写作痕迹分析报告")
            report.append(sep)
            report.append(f"文件: {self.file_path}")
            report.append(f"语言: 中文")
            report.append(f"总行数: {analysis['total_lines']}")
        else:
            lang_label = "Mixed (ZH+EN)" if self.lang == "mixed" else "English"
            report.append(sep)
            report.append("DE-AI WRITING TRACE ANALYSIS REPORT")
            report.append(sep)
            report.append(f"File: {self.file_path}")
            report.append(f"Language: {lang_label}")
            report.append(f"Total lines: {analysis['total_lines']}")

        report.append("")

        # Priority ranking
        section_scores = []
        for section_name, result in analysis["sections"].items():
            score = self.calculate_density_score(result)
            section_scores.append((section_name, score, result))

        section_scores.sort(key=lambda x: x[1], reverse=True)

        report.append(dash)
        report.append("PRIORITY RANKING" if self.lang in ("en", "mixed") else "优先级排序")
        report.append(dash)

        for i, (section_name, score, result) in enumerate(section_scores, 1):
            if score > 0:
                if self.lang == "zh":
                    report.append(f"{i}. {section_name}: {score:.1f}% ({result['trace_count']} 处痕迹)")
                else:
                    report.append(f"{i}. {section_name}: {score:.1f}% ({result['trace_count']} traces)")

        report.append("")
        report.append(dash)
        report.append("DETAILED TRACE LISTING" if self.lang in ("en", "mixed") else "详细痕迹列表")
        report.append(dash)

        for section_name, result in analysis["sections"].items():
            if result["traces"]:
                report.append(f"\n{section_name.upper()}:")
                for trace in result["traces"][:15]:
                    if self.lang == "zh":
                        report.append(f"  第{trace['line']}行 [{trace['category']}] \"{trace['matched']}\"")
                        report.append(f"    {trace['text'][:80]}")
                        report.append(f"    -> 建议: {self._get_instruction(trace['suggestion_type'])}")
                    else:
                        report.append(f"  Line {trace['line']} [{trace['category']}] \"{trace['matched']}\"")
                        report.append(f"    {trace['text'][:80]}")
                        report.append(f"    -> Suggestion: {self._get_instruction(trace['suggestion_type'])}")

        # Summary
        report.append("")
        report.append(sep)
        total_traces = sum(r["trace_count"] for r in analysis["sections"].values())
        if self.lang == "zh":
            report.append(f"总计: {total_traces} 处 AI 痕迹")
        else:
            report.append(f"Total: {total_traces} AI traces")
        report.append(sep)

        return "\n".join(report)


def main():
    parser = argparse.ArgumentParser(
        description="Analyze documents for AI writing traces (Chinese & English)"
    )
    parser.add_argument("file", type=Path, help="File to analyze")
    parser.add_argument("--lang", choices=["zh", "en", "mixed", "auto"], default="auto",
                        help="Language: zh, en, mixed (both), auto (default: auto)")
    parser.add_argument("--profile", choices=["generic", "deepseek", "claude", "mixed"],
                        default="generic",
                        help="Model profile: generic (default), deepseek, claude, mixed")
    parser.add_argument("--section", type=str, help="Check specific section")
    parser.add_argument("--analyze", action="store_true", help="Full document analysis")
    parser.add_argument("--score", action="store_true", help="Section scores only")
    parser.add_argument("--fix-suggestions", action="store_true",
                        help="Generate JSON suggestions")
    parser.add_argument("--output", type=Path, help="Save output to file")

    args = parser.parse_args()

    if not args.file.exists():
        label = "错误" if args.lang == "zh" else "ERROR"
        print(f"[{label}] File not found: {args.file}", file=sys.stderr)
        sys.exit(1)

    checker = DeAIChecker(args.file, lang=args.lang, profile=args.profile)

    if args.fix_suggestions:
        analysis = checker.analyze_document()
        suggestions = checker.generate_suggestions_json(analysis)
        output = json.dumps(suggestions, indent=2, ensure_ascii=False)
        if args.output:
            args.output.write_text(output, encoding="utf-8")
            print(f"[OK] Suggestions saved to: {args.output}")
        else:
            print(output)
        sys.exit(0)

    if args.analyze:
        analysis = checker.analyze_document()
        report = checker.generate_report(analysis)

        if args.output:
            args.output.write_text(report, encoding="utf-8")
            print(f"[OK] Report saved to: {args.output}")
        else:
            print(report)

        worst_score = 0
        if analysis["sections"]:
            worst_score = max(
                checker.calculate_density_score(r)
                for r in analysis["sections"].values()
            )

        if worst_score > 10:
            sys.exit(2)
        elif worst_score > 5:
            sys.exit(1)
        else:
            sys.exit(0)

    elif args.section:
        result = checker.check_section(args.section.lower())
        score = checker.calculate_density_score(result)
        print(f"\nSection: {args.section}")
        print(f"Density: {score:.1f}%")
        for trace in result["traces"]:
            print(f"Line {trace['line']}: \"{trace['matched']}\"")
            print(f"  {trace['text'][:80]}")
            print(f"  -> {checker._get_instruction(trace['suggestion_type'])}\n")

    elif args.score:
        analysis = checker.analyze_document()
        header = "章节" if checker.lang == "zh" else "Section"
        density = "密度" if checker.lang == "zh" else "Density"
        print(f"\n{header:<20} {density:<10}")
        print("-" * 30)
        for section_name, result in analysis["sections"].items():
            score = checker.calculate_density_score(result)
            print(f"{section_name:<20} {score:>6.1f}%")

    else:
        print("[INFO] Use --analyze for full analysis, --score for density scores, "
              "--fix-suggestions for JSON output")


if __name__ == "__main__":
    main()
