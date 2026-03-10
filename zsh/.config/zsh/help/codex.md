# Codex CLI 使用说明

这份文档基于 OpenAI 官方 Codex CLI 文档整理，只覆盖官方明确文档化的能力。

## 它是什么

- `Codex CLI` 是 OpenAI 的本地 coding agent。
- 它可以读取、修改、执行代码，也支持 review、resume、MCP、web search、cloud task。
- 配置文件使用 TOML。

## 本仓库安装入口

```zsh
install_codex
```

当前本仓库安装方式：

```zsh
npm install -g @openai/codex
```

## 官方安装与升级

### 安装

```zsh
npm i -g @openai/codex
```

### 启动

```zsh
codex
```

首次运行会要求登录：

- ChatGPT 账号
- 或 API key

### 升级

```zsh
npm i -g @openai/codex@latest
```

## 常见启动方式

### 交互模式

```zsh
codex
```

### 直接带 prompt

```zsh
codex "Explain this codebase to me"
```

### 指定模型

```zsh
codex --model gpt-5.4
```

### 图片输入

```zsh
codex -i screenshot.png "Explain this error"
codex --image img1.png,img2.jpg "Summarize these diagrams"
```

### 非交互执行

```zsh
codex exec "fix the CI failure"
```

### 恢复会话

```zsh
codex resume
codex resume --last
codex resume --all
codex resume <SESSION_ID>
```

也支持恢复 `exec` 会话：

```zsh
codex exec resume --last "Implement the plan"
```

## 常用能力

### Review

官方文档里，`/review` 会启动一个独立 reviewer：

- review against base branch
- review uncommitted changes
- review a commit
- custom review instructions

### Web search

Codex CLI 默认就有 web search。

可选模式：

- `cached`
- `live`
- `disabled`

例如：

```toml
web_search = "cached"
```

### Cloud task

```zsh
codex cloud
codex cloud exec --env ENV_ID "Summarize open bugs"
```

### Shell completion

```zsh
codex completion bash
codex completion zsh
codex completion fish
```

例如 `zsh`：

```zsh
eval "$(codex completion zsh)"
```

## Approval modes

官方文档提到 3 个主要模式：

- `Auto`
  - 默认；允许在工作目录里读、写、执行命令
- `Read-only`
  - 只读咨询模式
- `Full Access`
  - 对机器和网络放开，风险最高

会话内可以用：

```text
/permissions
```

切换。

## 常用 slash commands

官方文档明确列出的常用命令包括：

- `/permissions`
- `/agent`
- `/apps`
- `/clear`
- `/compact`
- `/copy`
- `/diff`
- `/experimental`
- `/feedback`
- `/init`
- `/logout`
- `/mcp`
- `/mention`
- `/model`
- `/plan`
- `/personality`
- `/ps`
- `/fork`
- `/resume`
- `/new`
- `/review`
- `/status`
- `/debug-config`
- `/statusline`
- `/quit`
- `/exit`

其中最常用的几个：

- `/model`：切模型
- `/personality`：切风格
- `/plan`：进 plan mode
- `/permissions`：切审批策略
- `/compact`：压缩上下文
- `/diff`：看工作区 diff
- `/review`：做本地代码审查
- `/mcp`：看当前 MCP 工具
- `/init`：生成 `AGENTS.md`

## 配置文件

### 配置位置

官方文档说明的主要层级：

- 用户配置：`~/.codex/config.toml`
- 项目配置：`.codex/config.toml`
- 系统配置：`/etc/codex/config.toml`

### 优先级

从高到低：

1. CLI flags / `--config`
2. `--profile <name>`
3. 项目 `.codex/config.toml`
4. `~/.codex/config.toml`
5. `/etc/codex/config.toml`
6. 内建默认值

项目如果被标记为 untrusted，会跳过项目层 `.codex/` 配置。

### 常见配置项

```toml
model = "gpt-5.4"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
web_search = "cached"
model_reasoning_effort = "high"
personality = "friendly"
log_dir = "/absolute/path/to/codex-logs"
```

Windows 原生模式还可以设置：

```toml
[windows]
sandbox = "elevated"
```

### Features

官方支持在 `[features]` 里切功能开关，例如：

```toml
[features]
shell_snapshot = true
multi_agent = false
unified_exec = false
undo = true
```

也可以直接用 CLI：

```zsh
codex features list
codex features enable unified_exec
codex features disable shell_snapshot
```

## MCP

Codex 的 MCP 配置官方明确放在：

```text
~/.codex/config.toml
```

项目级也可以：

```text
.codex/config.toml
```

### CLI 方式

```zsh
codex mcp add context7 -- npx -y @upstash/context7-mcp
codex mcp --help
```

### 配置文件方式

```toml
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]

[mcp_servers.context7.env]
MY_ENV_VAR = "MY_ENV_VALUE"
```

HTTP MCP 也支持：

- `url`
- `bearer_token_env_var`
- `http_headers`
- `env_http_headers`
- `enabled_tools`
- `disabled_tools`
- `startup_timeout_sec`
- `tool_timeout_sec`

会话内查看：

```text
/mcp
```

## 常用小技巧

- `@`：在 composer 里模糊找文件并插入路径
- `!command`：把本地 shell 命令结果作为用户输入注入
- `Ctrl+G`：打开外部编辑器编辑 prompt
- `Tab`：给下一轮排队 follow-up prompt
- `Enter`：任务执行中追加指令
- `Esc` 连按：回到前面的用户消息并 fork
- `codex --cd <path>`：不先 `cd` 也能指定项目根
- `codex --add-dir ...`：加额外 writable/readable roots

## 在本仓库里最相关的几个点

- 安装：`install_codex`
- MCP 配置与转换：`show-help mcp`
- AGENTS.md：本仓库自己也大量使用

## 参考

- 官方 CLI 概览: [Codex CLI](https://developers.openai.com/codex/cli/)
- 官方功能页: [Codex CLI features](https://developers.openai.com/codex/cli/features/)
- 官方 slash commands: [Slash commands in Codex CLI](https://developers.openai.com/codex/cli/slash-commands/)
- 官方配置基础: [Config basics](https://developers.openai.com/codex/config-basic/)
- 官方 MCP: [Model Context Protocol](https://developers.openai.com/codex/mcp/)
