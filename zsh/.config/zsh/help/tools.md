# CLI 工具速查

## 安装入口

- `install_modern_tools_by_eget` - 安装到 `~/.local/bin`
- `install_modern_tools_by_eget local` - 同上
- `install_modern_tools_by_eget global` - 安装到 `/usr/local/bin`
- `install_modern_tools_by_eget /custom/prefix` - 安装到 `/custom/prefix/bin`

## 分项帮助

- 运行 `show-help`，在列表中选择 `tools/<tool>` 查看单个工具

## 文件与查找

- `rg "pattern" path` - 全局搜索
- `rg -g "*.md" "pattern"` - 按扩展名过滤
- `fd "pattern"` - 快速找文件/目录
- `fd -t f -e rs` - 仅文件 + 扩展名
- `eza -la` - 更好看的 ls
- `eza --tree -L 2` - 树形查看
- `bat file` - 带语法高亮查看
- `bat -n file` - 显示行号
- `yazi` - 终端文件管理器
- `nnn` - 轻量文件管理器

## 终端体验

- `zellij` - 终端复用器
- `zoxide init zsh` - 初始化 (通常写入 rc)
- `z <dir>` - 快速跳转 (需要初始化)
- `starship init zsh` - 初始化 (通常写入 rc)

## Git 与终端 UI

- `lazygit` - Git TUI
- `delta file` - 语法高亮 diff
- `git diff | delta` - 让 diff 更好看

## 模糊搜索

- `fzf` - 交互式选择器
- `fzf --preview 'bat --style=numbers --color=always {}'` - 预览

## HTTP 与 API

- `xh GET https://example.com` - 更友好的 curl
- `xh POST https://example.com key==value` - 发送 JSON
- `curlie https://example.com` - curl + httpie 风格

## 系统监控

- `duf` - 磁盘使用概览
- `dust` - 目录大小排行
- `gdu` - 交互式磁盘分析
- `procs` - 进程查看
- `btm` - bottom（系统监控）
- `ctop` - 容器资源监控（Docker）

## 效率与杂项

- `hyperfine "cmd"` - 基准测试
- `sd "from" "to" file` - 替换文本
- `tldr cmd` - 精简版手册
- `gh auth login` - GitHub CLI 登录
- `gh repo clone owner/repo` - 克隆仓库
- `glow README.md` - 终端渲染 Markdown
- `just --list` - 列出任务
- `just task` - 运行任务
- `navi` - 交互式命令速查

## 需要查看帮助的工具

- `fresh --help`
- `mole --help`
- `aichat --help`
