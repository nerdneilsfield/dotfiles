# English AI Trace Patterns

Reference document for detecting and replacing AI-typical writing patterns in English text. Organized by detection priority: structural patterns first, then vocabulary, then style.

---

## 1. Tiered Vocabulary System

### Tier 1 -- Always Flag

These words and phrases appear 5-20x more frequently in AI-generated text than in human writing. Flag every occurrence regardless of context.

| AI-typical word/phrase | Replacement(s) |
|---|---|
| delve / delve into | examine, explore, investigate, look at, study |
| landscape (metaphor) | field, area, situation, state of affairs |
| tapestry | mix, combination, collection |
| realm | area, field, domain, space |
| paradigm | model, framework, approach, way of thinking |
| embark | start, begin, set out |
| beacon | example, signal, guide |
| testament to | evidence of, proof of, shows |
| robust | strong, solid, reliable, durable |
| comprehensive | thorough, complete, full, wide-ranging |
| cutting-edge | recent, advanced, new, modern |
| leverage (verb) | use, apply, take advantage of, build on |
| pivotal | key, central, critical, decisive |
| underscores | highlights, shows, stresses, points to |
| meticulous / meticulously | careful / carefully, precise / precisely, thorough / thoroughly |
| seamless / seamlessly | smooth / smoothly, without interruption, integrated |
| game-changer | breakthrough, major shift, turning point |
| utilize | use |
| watershed moment | turning point, milestone, defining moment |
| nestled | located, situated, set, placed |
| vibrant | lively, active, energetic, colorful |
| thriving | growing, successful, flourishing |
| showcasing | showing, demonstrating, presenting, displaying |
| deep dive | close look, detailed examination, thorough analysis |
| unpack | explain, break down, analyze, examine |
| bustling | busy, active, crowded, lively |
| intricate | detailed, complex, elaborate, involved |
| complexities | difficulties, complications, challenges, details |
| ever-evolving | changing, developing, shifting |
| enduring | lasting, persistent, long-standing, durable |
| daunting | difficult, challenging, intimidating, hard |
| holistic | overall, complete, integrated, whole-system |
| actionable | practical, usable, concrete, specific |
| impactful | effective, influential, significant (use sparingly) |
| learnings | lessons, findings, takeaways, insights |
| thought leadership | expertise, authority, influence |
| best practices | recommended methods, proven techniques, guidelines |
| synergy | cooperation, combined effect, collaboration |
| interplay | interaction, relationship, connection |
| in order to | to |
| due to the fact that | because, since |
| serves as | is |
| features (verb) | has, includes, contains |
| boasts | has, offers, provides |
| commence | begin, start |
| ascertain | find out, determine, learn, confirm |
| endeavor | effort, attempt, project, work |
| keen (intensifier) | strong, eager, interested |
| symphony (metaphor) | blend, combination, coordination |
| embrace (metaphor) | adopt, accept, use, welcome |

### Tier 2 -- Flag in Clusters

These words are acceptable on their own. Flag when **2 or more** appear in the same paragraph -- that clustering pattern is a strong AI signal.

| Word | Notes |
|---|---|
| innovative | Often paired with "dynamic" or "cutting-edge" |
| dynamic | Vague when describing static systems |
| scalable | Acceptable in technical architecture discussion |
| compelling | Overused as a generic positive |
| unprecedented | Rarely accurate; verify claim |
| sophisticated | Often replaceable with "complex" or specific details |
| instrumental | Replace with "important" or explain the actual role |
| world-class | Unsubstantiated superlative |
| streamline | Replace with "simplify" or describe the actual simplification |
| empower | Replace with "enable" or "allow" or state the concrete capability |
| foster | Replace with "encourage" or "support" |
| spearhead | Replace with "lead" or "start" |
| resonate | Replace with "appeal to" or "connect with" |
| revolutionize | Almost always an exaggeration; use "change" or "improve" |
| facilitate | Replace with "help" or "make possible" |
| underpin | Replace with "support" or "form the basis of" |
| navigate | Replace with "handle" or "manage" or "deal with" |
| reimagine | Replace with "redesign" or "rethink" |
| catalyze | Replace with "trigger" or "cause" or "accelerate" |
| galvanize | Replace with "motivate" or "push" or "drive" |
| augment | Replace with "add to" or "extend" or "supplement" |
| cultivate | Replace with "build" or "develop" or "grow" |
| illuminate | Replace with "clarify" or "reveal" or "explain" |
| elucidate | Replace with "explain" or "clarify" |
| juxtapose | Replace with "compare" or "contrast" or "place side by side" |
| paradigm-shifting | Replace with "major" or describe the actual change |
| transformative | Replace with "significant" or describe the actual effect |
| cornerstone | Replace with "foundation" or "basis" or "key part" |
| paramount | Replace with "critical" or "most important" |
| poised | Replace with "ready" or "positioned" or "likely" |
| burgeoning | Replace with "growing" or "expanding" |
| nascent | Replace with "early" or "new" or "emerging" |
| quintessential | Replace with "typical" or "defining" or "classic" |
| overarching | Replace with "main" or "broad" or "general" |
| underpinning | Replace with "basis" or "foundation" or "support" |
| bolster | Replace with "strengthen" or "support" or "reinforce" |
| encompass | Replace with "include" or "cover" or "span" |

### Tier 3 -- Flag by Density

Common words that AI overuses. Flag only when they exceed **3% density** (occurrences per 1000 words > 30) within a section.

| Word | AI-typical density | Human-typical density | Notes |
|---|---|---|---|
| significant | 8-12 per 1k | 2-4 per 1k | See false positive rules below |
| crucial | 6-10 per 1k | 1-3 per 1k | Replace with "important" or "key" |
| nuanced | 5-8 per 1k | 1-2 per 1k | Replace with "subtle" or describe the nuance |
| multifaceted | 4-7 per 1k | <1 per 1k | Replace with "complex" or list the facets |
| myriad | 5-8 per 1k | 1-2 per 1k | Replace with "many" or give a number |
| plethora | 4-6 per 1k | <1 per 1k | Replace with "many" or "a wide range of" |
| ecosystem | 5-9 per 1k | 1-3 per 1k | Acceptable in biology/software; flag metaphorical use |
| moreover | 6-10 per 1k | 2-3 per 1k | Delete or restructure sentence |
| furthermore | 5-8 per 1k | 1-3 per 1k | Delete or restructure sentence |
| additionally | 6-9 per 1k | 1-2 per 1k | Delete or restructure sentence |
| subsequently | 4-7 per 1k | 1-2 per 1k | Replace with "then" or "after that" |

---

## 2. Empty Phrases

Vague adjective-noun pairs that add no information. Replace with specific data or delete entirely.

### Regex Patterns

```regex
\b(significant|notable|remarkable)\s+(improvement|performance|gain|enhancement|increase|reduction)\b
\b(comprehensive|thorough|extensive)\s+(analysis|study|overview|review|examination|survey)\b
\b(effective|efficient|powerful)\s+(solution|method|approach|strategy|technique|framework)\b
\b(important|critical|vital)\s+(contribution|role|impact|factor|aspect|element)\b
\b(robust|reliable|stable)\s+(performance|method|approach|system|framework|architecture)\b
\b(novel|new|unique)\s+(approach|method|technique|framework|algorithm|strategy)\b
\b(state-of-the-art|SOTA)\s+(performance|results|accuracy|method|approach)\b
\b(superior|excellent|outstanding)\s+(performance|results|accuracy|quality)\b
```

### Replacement Strategy

| Empty phrase | Better alternative |
|---|---|
| significant improvement | improved by X% / reduced error by X |
| comprehensive analysis | analyzed N samples across M conditions |
| effective solution | solves [specific problem] by [specific mechanism] |
| important contribution | contributes [specific thing] to [specific area] |
| robust performance | maintains accuracy above X% under Y conditions |
| novel approach | [describe what is actually new about it] |
| state-of-the-art results | outperforms [baseline] by X% on [benchmark] |

---

## 3. Over-Confident Language

Absolute claims without evidence. Flag and downgrade.

| Over-confident | Hedged replacement |
|---|---|
| obviously | -- (delete, or rephrase as evidence-based claim) |
| clearly | the data suggest, as shown in [Figure/Table] |
| certainly | likely, with high probability |
| undoubtedly | the evidence strongly suggests |
| necessarily | often, in most cases, typically |
| completely | largely, to a great extent, nearly |
| always | in all tested cases, consistently |
| never | in no observed case, not in any of the N trials |
| proves | supports, provides evidence for |
| the best | among the best, one of the strongest |
| the only | one of few, among the first |
| perfectly | closely, accurately, with high fidelity |
| impossible | infeasible under current constraints, unlikely |
| without question | by most accounts, based on available evidence |
| unquestionably | strongly, based on consistent findings |

---

## 4. Vague Quantifiers

Replace with concrete numbers or citations.

| Vague quantifier | Better alternative |
|---|---|
| many studies | [Author1 et al., Author2 et al., ...] (cite 2-5 specifically) |
| numerous experiments | N experiments across M configurations |
| various methods | [list the methods], or N methods including ... |
| several approaches | three/four/five approaches, specifically ... |
| multiple datasets | N datasets (Dataset1, Dataset2, ...) |
| a lot of / a large number of | N instances, over N, approximately N |
| the majority of | X% of, N out of M |
| a substantial amount/number | N items, X% of the total |
| some researchers | [Author et al.] and [Author et al.] |
| recent work | [Author et al., Year] and [Author et al., Year] |
| growing body of evidence | [cite 3+ sources from the last 5 years] |
| widely adopted | used in N systems/studies, adopted by X, Y, Z |

### Regex Pattern

```regex
\b(many|numerous|various|several|multiple|some|few|a number of|a lot of|a large number of|the majority of|a substantial (amount|number) of|a growing (body|number) of|an increasing number of)\s+(studies|experiments|methods|approaches|datasets|researchers|works|papers|techniques|models|systems|frameworks)\b
```

---

## 5. Template Expressions

Filler phrases that fit any paper in any field. Delete or replace with field-specific content.

| Template expression | Replacement strategy |
|---|---|
| In recent years, ... | [Cite specific starting point]: Since [Author, Year] demonstrated ..., or delete entirely and start with the actual content |
| More and more ... | [Concrete trend]: Adoption of X grew from Y to Z between [Year] and [Year] |
| plays an important/crucial role in | is central to / is required for / directly affects |
| With the (rapid) development of ... | Since [specific advance], ... / As X matured from A to B, ... |
| has (been) widely used in | is used in [specific domains], for example ... |
| has attracted (much/considerable) attention | [N papers since Year] have studied ..., or [Author] and [Author] investigated ... |
| remains a challenging problem | [describe the specific unsolved aspect] |
| is of great significance | matters because [specific reason] |
| there is a growing need for | [stakeholder] needs X because [specific reason] |
| to the best of our knowledge | [acceptable in limited use; verify the novelty claim is accurate] |
| it is worth noting that | [delete -- if it's worth noting, just state it] |
| it should be noted that | [delete -- same as above] |
| needless to say | [delete -- if needless, don't say it] |
| it goes without saying | [delete] |
| as we all know | [delete or cite a source] |

### Regex Pattern

```regex
\b[Ii]n recent years\b
\b[Mm]ore and more\b
\bplays a(n)? (important|crucial|critical|key|vital|significant) role\b
\b[Ww]ith the (rapid |growing |increasing )?development of\b
\bhas been widely (used|adopted|applied|employed)\b
\bhas attracted (much|considerable|significant|growing|widespread) attention\b
\bremains a(n)? (challenging|difficult|open|unsolved) (problem|issue|question)\b
\bis of great (significance|importance)\b
\bthere is a growing (need|demand) for\b
\bit is worth (noting|mentioning) that\b
\bit should be noted that\b
\bneedless to say\b
\bas we all know\b
```

---

## 6. Structural Patterns

These are document-level signals detectable by pattern analysis. They operate above the word level and are the strongest indicators of AI generation.

### 6.1 Significance Inflation

**Pattern**: Every result is "significant," "remarkable," or "substantial" regardless of actual effect size.

**Detection**: Count intensity adjectives per results section. AI text typically uses 3-5x more than human text.

**Fix**: Remove the adjective and let the numbers speak. If the result is genuinely notable, explain why in concrete terms.

### 6.2 Copula Avoidance

**Pattern**: AI avoids simple "is/has" constructions, replacing them with fancier verbs.

| AI-typical | Human-natural |
|---|---|
| serves as | is |
| functions as | is |
| acts as | is |
| features | has, includes |
| boasts | has |
| encompasses | includes |
| constitutes | is, makes up |
| represents | is |

**Detection regex**:
```regex
\b(serves|functions|acts) as\b
\b(boasts|encompasses|constitutes|represents)\s
```

**Fix**: Replace with "is" or "has" where meaning is preserved.

### 6.3 Synonym Cycling

**Pattern**: AI uses 4+ different synonyms for the same concept within a section, cycling through them mechanically to appear varied. For example: "method" then "approach" then "technique" then "strategy" then "framework" -- all referring to the same thing.

**Detection**: Track referents per concept. If one concept is named by 4+ different terms within 500 words and none are defined as distinct, flag it.

**Fix**: Pick one or two terms and use them consistently. Define terms if distinctions matter.

### 6.4 Rule of Three

**Pattern**: AI groups items in threes with suspicious consistency: "efficiency, scalability, and reliability"; "planning, executing, and evaluating"; "fast, accurate, and robust."

**Detection**: Count tricolon structures. More than 2 per 500 words is a strong AI signal.

**Detection regex**:
```regex
\b\w+,\s+\w+,\s+and\s+\w+\b
```

**Fix**: Vary group sizes. Use pairs, lists of four, or single items. Break some triads into separate sentences.

### 6.5 Negative Parallelism

**Pattern**: "It's not X, it's Y" or "not merely X, but Y" used repeatedly.

**Detection regex**:
```regex
\b(not|n't)\s+(just|merely|only|simply)\s+.{5,40},\s*(but|it's|it is)\b
```

**Fix**: Rephrase positively. State what something IS without the contrastive setup. Use this structure at most once per section.

### 6.6 Em Dash Overuse

**Pattern**: AI text uses em dashes (--) at 3-5x the rate of human text, often as a crutch for parenthetical insertion.

**Detection**: Count em dashes per 1000 words. Human average: 2-4. AI average: 8-15.

**Fix**: Replace most with commas, parentheses, or restructure as separate sentences. Keep 1-2 per 1000 words maximum.

### 6.7 Generic Conclusions

**Pattern**: Conclusions that could apply to any paper: "the future looks bright," "opens exciting avenues," "paves the way for future research."

**Detection regex**:
```regex
\b(future|exciting|promising|bright|pave|avenue|open.{0,10}door|open.{0,10}avenue|usher)\b
```

**Fix**: State specific next steps, open questions, or limitations. Name concrete future work with enough detail that it could not apply to a different paper.

### 6.8 Chatbot Artifacts

**Pattern**: Conversational phrases leaked from chat training data.

| Artifact | Action |
|---|---|
| Certainly! / Sure! / Absolutely! | Delete |
| Great question! | Delete |
| I hope this helps! | Delete |
| Let me know if you have any questions | Delete |
| Happy to help! | Delete |
| Here's what I found | Delete or rephrase |
| That's a great point | Delete |
| I'd be happy to explain | Delete |

**Detection regex**:
```regex
\b(Certainly|Sure|Absolutely|I hope this helps|Let me know if|Happy to help|Great question|That's a great point|I'd be happy to)\b
```

### 6.9 Sycophantic Tone

**Pattern**: Excessive agreement or flattery, praising the question or premise before answering.

**Detection**: Flag sentences that begin with praise or agreement markers before providing content.

**Fix**: Delete the praise. Start with the actual content.

### 6.10 Reasoning Chain Artifacts

**Pattern**: Thinking-out-loud phrases from chain-of-thought training.

| Artifact | Action |
|---|---|
| Let me think step by step | Delete |
| Let's break this down | Delete |
| First, let's consider | Rephrase or delete |
| To understand this, we need to | Delete or integrate naturally |
| The key insight here is | State the insight directly |
| Let's take a closer look | Delete |
| Now, let's examine | Delete |

**Detection regex**:
```regex
\b(Let me think|Let's break|Let's take a closer look|The key (insight|takeaway) here is|Now,? let's|To understand this)\b
```

### 6.11 Emotional Flatline

**Pattern**: AI inserts emotion markers that feel performative: "What surprised me most was..." or "Interestingly, ..." used as sentence starters without genuine surprise.

**Detection**: Flag "Interestingly," "Surprisingly," "Notably," "Remarkably," "Fascinatingly" at sentence start when the following content is not actually surprising.

**Fix**: Delete the emotion word. If the content is genuinely surprising, explain why it contradicts expectations.

### 6.12 Excessive Structure

**Pattern**: AI over-structures short text. Five headers in 200 words. Bullet points for two items. Numbered lists for non-sequential content.

**Detection**: Compute structure-to-content ratio. More than 1 header per 200 words, or bullet lists with fewer than 3 items, are signals.

**Fix**: Merge short sections. Use prose for small amounts of content. Reserve headers for sections with 150+ words of content.

### 6.13 Rhythm Uniformity

**Pattern**: All sentences fall within 15-25 words. Human writing varies from 5-word fragments to 40-word complex sentences.

**Detection**: Compute standard deviation of sentence length. AI text: stdev 3-5 words. Human text: stdev 8-15 words.

**Fix**: Vary sentence length deliberately. Add some short punchy sentences. Allow occasional long sentences with subordinate clauses. Break monotony.

---

## 7. False Positive Rules

Do NOT flag these patterns -- they represent legitimate, precise usage.

| Pattern | Context that cancels the flag | Reason |
|---|---|---|
| significant | Preceded by "statistically" | Statistical term of art |
| significant | Followed by p-value (p < 0.05, p = 0.01, etc.) | Quantified claim |
| significant | Preceded by "not" or "non-" | Negated claim is precise |
| improvement / gain | Followed by "by XX%" or "of XX%" | Quantified result |
| improvement / gain | Followed by specific metric name + number | Concrete measurement |
| comprehensive | Followed by specific range ("comprehensive dataset of 50k samples") | Scope is defined |
| comprehensive | Part of a proper name or title | Title reference |
| novel | In "Related Work" section summarizing others' claims | Reporting, not claiming |
| robust | Technical meaning in statistics/optimization ("robust optimization") | Domain term |
| leverage | Financial context ("financial leverage") | Domain term |
| landscape | Geographic/geological context | Literal meaning |
| ecosystem | Biological/ecological context | Literal meaning |
| paradigm | In philosophy of science context (Kuhn) | Precise usage |
| state-of-the-art | With specific benchmark name + score | Verified claim |
| scalable | With complexity analysis (O(n), O(log n)) | Technical claim |

### False Positive Regex

```regex
# Do not flag these patterns:
statistically\s+significant
significant\s*\(p\s*[<=]\s*0\.\d+\)
significant\s+at\s+(the\s+)?\d+%
improv(ement|ed)\s+by\s+\d+(\.\d+)?%
gain\s+of\s+\d+(\.\d+)?%
comprehensive\s+(dataset|corpus|collection)\s+of\s+[\d,]+
```

---

## 8. Section-Specific Guidelines

### Abstract

- **Max length**: Most venues specify 150-300 words. Stay within limits.
- **Common AI traces**: Template opening ("In this paper, we propose..."), significance inflation, vague claims.
- **Fix strategy**: Open with the problem or finding, not a meta-statement about the paper. Use one specific quantitative result. Avoid "novel" and "state-of-the-art" unless backed by concrete benchmark numbers.

### Introduction

- **Common AI traces**: "In recent years" opening, vague motivation ("has attracted much attention"), landscape metaphors, excessive background before stating the problem.
- **Fix strategy**: Start with a concrete problem statement or motivating example. Cite specific prior work rather than "many studies." State contributions as a list with concrete deliverables, not vague promises.

### Related Work

- **Common AI traces**: Synonym cycling (method/approach/technique/strategy for the same thing), template comparisons ("while X does A, Y does B"), mechanical organization.
- **Fix strategy**: Use consistent terminology per concept. Compare works on specific dimensions (accuracy on benchmark X, computational cost, assumption set). State what is missing, not just what exists.

### Methods

- **Common AI traces**: Over-confident descriptions ("our elegant formulation"), copula avoidance, unnecessary complexity in language for simple operations.
- **Fix strategy**: Describe procedures plainly. Use "is" and "has" freely. Let equations and algorithms carry the complexity -- the surrounding prose should be simple.

### Experiments / Setup

- **Common AI traces**: "Comprehensive experiments," vague dataset descriptions, template setup paragraphs.
- **Fix strategy**: Specify exact dataset sizes, splits, hardware, training time, hyperparameters. Replace "extensive experiments" with "N experiments across M configurations."

### Results

- **Common AI traces**: Significance inflation on every number, "notably" and "remarkably" as sentence starters, over-confident comparisons.
- **Fix strategy**: Report numbers and let readers judge significance. Use "outperforms X by Y%" instead of "significantly outperforms." Reserve superlatives for genuinely record-breaking results.

### Discussion

- **Common AI traces**: Generic implications, vague future work, restatement of results without analysis.
- **Fix strategy**: Discuss specific failure cases and why they occur. Connect results to specific prior findings. State limitations concretely (what breaks, when, why).

### Conclusion

- **Common AI traces**: Generic wrapup ("paves the way for future research"), restating the abstract, unfounded optimism.
- **Fix strategy**: Summarize 2-3 key findings with numbers. State 1-2 specific open problems. Avoid vague future directions -- name the next experiment or dataset.

---

## 9. Common Replacements Table

Quick-reference table for the most frequent substitutions.

| AI-typical (do not use) | Human-natural (use instead) |
|---|---|
| delve into | examine, explore, look at |
| utilize | use |
| leverage | use, apply, build on |
| in order to | to |
| due to the fact that | because |
| serves as | is |
| it is worth noting that | (delete) |
| a plethora of | many, a wide range of |
| myriad | many |
| plays a crucial role | is important for, is central to, directly affects |
| with the rapid development of | since [specific advance] |
| has attracted much attention | [cite 2-3 specific papers] |
| comprehensive experiments | N experiments across M settings |
| significant improvement | improved by X% |
| novel approach | (describe what is new) |
| state-of-the-art | outperforms [baseline] by X% on [benchmark] |
| robust performance | stable across [conditions], above X% accuracy |
| seamlessly integrates | works with, is compatible with |
| cutting-edge | recent, modern, advanced |
| Furthermore, | (delete or restructure) |
| Moreover, | (delete or restructure) |
| Additionally, | (delete or restructure) |
| In conclusion, | (start with the actual conclusion) |
| It is important to note | (delete -- just state the point) |
| paves the way for | enables, makes possible |
| the landscape of | the field of, the current state of |
| embrace | adopt, accept, use |
| foster | encourage, support, promote |
| empower | enable, allow, equip |
| streamline | simplify, reduce steps in |
| spearhead | lead, start, drive |
| holistic | overall, complete, full |
| actionable insights | specific recommendations |
| best practices | recommended methods, guidelines |
| game-changer | breakthrough, major advance |
| paradigm shift | fundamental change, major change in approach |
| synergy | combined effect, cooperation |
| ecosystem (metaphor) | community, environment, network |
| vibrant community | active community, large community of N members |
| nestled in | located in, based in |
| bustling | busy, active |
| deep dive | close look, detailed study |
| unpack | explain, break down |
