# Claude Code 使用说明

这份文档基于 Anthropic 官方 Claude Code 文档整理。

## 它是什么

- `Claude Code` 是 Anthropic 的 agentic coding tool。
- 它可以读代码、改文件、跑命令、接 MCP、用 skills / hooks / memory。
- 不只在终端里能用，也支持 VS Code、JetBrains、Desktop、Web、Slack、CI。

## 本仓库安装入口

```zsh
install_claude_code
```

当前本仓库用的是 npm 安装：

```zsh
npm install -g @anthropic-ai/claude-code
```

## 官方安装方式

### 官方推荐：原生安装脚本

macOS / Linux / WSL：

```zsh
curl -fsSL https://claude.ai/install.sh | bash
```

Windows PowerShell：

```powershell
irm https://claude.ai/install.ps1 | iex
```

Windows CMD：

```cmd
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

原生安装的特点：

- 官方推荐
- 会自动后台更新

### Homebrew

```zsh
brew install --cask claude-code
brew upgrade claude-code
```

### WinGet

```powershell
winget install Anthropic.ClaudeCode
winget upgrade Anthropic.ClaudeCode
```

## 快速开始

### 启动

```zsh
cd your-project
claude
```

首次登录时支持：

- Claude Pro / Max / Teams / Enterprise
- Claude Console
- Amazon Bedrock / Google Vertex AI / Microsoft Foundry

### 一次性执行

```zsh
claude "fix the build error"
claude -p "explain this function"
```

### 恢复最近会话

```zsh
claude -c
claude -r
```

### Git

```zsh
claude commit
```

## 官方文档里的典型能力

- 理解整个代码库
- 跨多个文件实现功能
- 修 bug
- 写测试
- 跑 lint / test
- 直接和 git 协作
- 通过 MCP 连接外部工具
- 用 `CLAUDE.md`、skills、hooks 做定制
- 运行多 agent 协作

## 常见自然语言任务

官方 quickstart 里给的典型例子包括：

- `what does this project do?`
- `what technologies does this project use?`
- `where is the main entry point?`
- `add a hello world function to the main file`
- `commit my changes with a descriptive message`
- `there's a bug where users can submit empty forms - fix it`
- `write unit tests for the calculator functions`
- `review my changes and suggest improvements`

## 常用命令

官方 quickstart 页明确列出的常用项：

- `claude`
- `claude "task"`
- `claude -p "query"`
- `claude -c`
- `claude -r`
- `claude commit`
- `/clear`
- `/help`
- `exit`

## 配置体系

Claude Code 的配置有 scope 概念。

### 作用域

- `Managed`
- `User`
- `Project`
- `Local`

### 位置

| Scope | 主要位置 |
| --- | --- |
| User | `~/.claude/settings.json` |
| Project | `.claude/settings.json` |
| Local | `.claude/settings.local.json` |
| MCP user/local | `~/.claude.json` |
| MCP project | `.mcp.json` |
| 全局 memory | `~/.claude/CLAUDE.md` |
| 项目 memory | `CLAUDE.md` 或 `.claude/CLAUDE.md` |

### 优先级

官方 settings 文档给出的优先级：

1. Managed
2. CLI arguments
3. Local
4. Project
5. User

## `CLAUDE.md`、Memory、Skills、Hooks

### `CLAUDE.md`

`CLAUDE.md` 是 Claude Code 会在会话开始时读取的 Markdown 指令文件。

适合放：

- 代码规范
- 架构决策
- 常用命令
- review checklist

### Skills

官方文档说明，团队可以把可复用工作流打包成 skills。

### Hooks

hooks 可以在工具动作前后执行 shell 命令，例如：

- 编辑后自动格式化
- 提交前先跑 lint
- 拦截对敏感配置的写入

## 权限与工具

Claude Code 有比较完整的权限系统。

官方 settings 页列出的核心工具包括：

- `Bash`
- `Read`
- `Write`
- `Edit`
- `Glob`
- `Grep`
- `WebFetch`
- `WebSearch`
- `Skill`
- `Agent`
- `LSP`
- `Task*`
- `TodoWrite`
- `ListMcpResourcesTool`
- `ReadMcpResourceTool`

### 工具权限示例

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(npm run lint)",
      "Bash(npm run test *)",
      "Read(~/.zshrc)"
    ],
    "deny": [
      "Bash(curl *)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ]
  }
}
```

### Bash 工具的一个关键点

官方文档特别提醒：

- 工作目录会在 bash 命令之间保持
- 但 bash 里临时 `export` 的环境变量不会自动持久

如果你想让环境持续存在，官方建议三种方式：

1. 先在外部终端激活环境，再启动 `claude`
2. 设置 `CLAUDE_ENV_FILE`
3. 用 `SessionStart` hook 写入环境

## MCP

Claude Code 的 MCP 位置在本仓库里已经整理过，直接看：

```zsh
show-help mcp
```

本仓库已有的常用命令示例：

```zsh
claude mcp add -s user --transport http notion https://mcp.notion.com/mcp
claude mcp add -s user --transport stdio --env='API_KEY=your_key' my-local -- npx -y @modelcontextprotocol/server-memory
claude mcp list
```

## 输出、语言、模型、环境变量

官方 settings 文档里还支持很多常用项：

- `model`
- `availableModels`
- `language`
- `outputStyle`
- `statusLine`
- `fileSuggestion`
- `respectGitignore`
- `plansDirectory`
- `autoUpdatesChannel`
- `prefersReducedMotion`

以及大量环境变量，例如：

- `CLAUDE_CONFIG_DIR`
- `CLAUDE_CODE_USE_BEDROCK`
- `CLAUDE_CODE_USE_VERTEX`
- `CLAUDE_CODE_USE_FOUNDRY`
- `CLAUDE_CODE_SHELL`
- `CLAUDE_CODE_SHELL_PREFIX`
- `CLAUDE_CODE_ENABLE_TELEMETRY`
- `DISABLE_AUTOUPDATER`
- `DISABLE_TELEMETRY`
- `HTTP_PROXY`
- `HTTPS_PROXY`

## 使用建议

- 团队协作时，把共享规则写进仓库里的 `CLAUDE.md`
- 私人偏好写到 `~/.claude/settings.json`
- 敏感或机器相关配置放 `.claude/settings.local.json`
- 想共享外部工具链时，用项目级 `.mcp.json`
- 想强制团队执行特定动作时，用 hooks 或 managed settings

## 在本仓库里最相关的几个点

- 安装：`install_claude_code`
- MCP：`show-help mcp`
- 本仓库本身已经大量使用 `AGENTS.md` / skills 工作流

## 参考

- 官方 overview: [Claude Code overview](https://docs.anthropic.com/en/docs/claude-code/overview)
- 官方 quickstart: [Quickstart](https://docs.anthropic.com/en/docs/claude-code/quickstart)
- 官方 settings: [Claude Code settings](https://docs.anthropic.com/en/docs/claude-code/settings)
