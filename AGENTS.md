# AGENTS.md

## Repository rules

- 禁止在本仓库创建、写入或提交 `docs/superpowers/`、`.superpowers/`，以及任何 plan/spec/design 产物。
- 复杂任务说明只放仓库外（如 `/Users/dengqi/.codex/work/` 或 `/tmp`），完成后清理。
- 提交前检查 `git status` 与暂存文件清单；不得使用 `git add -f` 或 `git commit --no-verify` 绕过规则。
- 若历史出现上述路径，先从所有相关 refs 重写清除，再推送；不得补回仓库。
