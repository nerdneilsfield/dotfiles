# AGENTS.md

## Repository rules

- 禁止在本仓库创建、写入或提交任务计划文档；`docs/superpowers/`、`.superpowers/`、`plans/`、`planning/` 与 `.plans/` 一律视为计划产物。
- 普通文档允许且应按需维护：README、命令行帮助、配置说明、用户操作文档、技能模板均不受此规则限制。
- 复杂任务的临时计划只放仓库外（如 `/Users/dengqi/.codex/work/` 或 `/tmp`），完成后清理。
- 提交前检查 `git status` 与暂存文件清单；不得使用 `git add -f` 或 `git commit --no-verify` 绕过规则。
- 已提交的计划文档从当前分支删除并正常提交；只有用户明确要求时才重写历史。
