---
name: co-commit
description: 分析 git 变更，自动拆分为多个 Conventional Commits 提交
---

# 当前上下文

- 当前分支: !`git branch --show-current`
- 最近 5 条提交: !`git log --oneline -5`
- 完整变更状态: !`git status --porcelain=v1`
- 完整 diff: !`git diff HEAD`

# 任务

根据上方 diff，将所有未提交的变更**按逻辑分组**，拆分成多个 Conventional Commits 提交。

如果提供了 `$ARGUMENTS`，将其作为 scope 或摘要补充提示。

## 第一步：分析并制定提交计划

先输出一个提交计划，格式如下：

```
📋 提交计划（共 N 次）：

 feat(auth): add login endpoint
    涉及文件: src/auth/login.ts, src/auth/types.ts

 test(auth): add login unit tests
    涉及文件: tests/auth/login.test.ts

 docs: update README with auth usage
    涉及文件: README.md
```

## 第二步：逐次执行提交

按计划顺序，对每一组：

1. 用 `git add <具体文件路径>` 只暂存该组的文件（**不要用 git add -A**）
2. 执行 `git commit -m "..."` 提交
3. 报告该次提交结果，再进行下一组

## 拆分原则

- **不同 type** 必须分开（feat 和 fix 不可合并）
- **不同模块/scope** 尽量分开，除非改动极小（≤3 行）
- **测试代码**独立为 `test` 提交
- **文档/注释**独立为 `docs` 或 `chore` 提交
- 如果所有变更确实只属于同一个 type+scope，则直接单次提交，无需强行拆分

## Conventional Commits 格式

```
<type>(<scope>): <简短描述，≤50 字符>

[正文：说明改了什么、为什么，每行 ≤72 字符]

[Footer：Closes #123、BREAKING CHANGE 等]
```

规则如下:

```
**type**：feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert

**规则**：使用祈使句、首字母大写、结尾不加句号
```

## 关键设计说明

| 要点         | 做法                                            |
| ------------ | ----------------------------------------------- |
| 防止误提交   | 用 `git add <文件>` 精确暂存，不用 `git add -A` |
| 透明可控     | 先输出完整计划，再执行，方便你审查              |
| 不强行拆分   | 变更真的是单一 type 时，直接单次提交            |
| 兼容单次场景 | 与之前的 `/co-commit` 行为完全向后兼容          |

使用时直接输入 `/co-commit`，Claude 会先给出拆分计划，你确认后（或直接让它继续）再逐步执行提交 。
