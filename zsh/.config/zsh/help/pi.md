# Pi Agent 使用说明

这份文档基于 `@mariozechner/pi-coding-agent` 官方 npm README 整理，适合本机 `show-help` 速查。

## 它是什么

- `Pi` 是一个终端里的 coding agent CLI。
- 它强调最小内核和强扩展性，核心内置 `read`、`write`、`edit`、`bash` 等工具。
- 它支持 interactive、print、JSON、RPC 和 SDK 集成模式。

## 本仓库安装入口

```zsh
install_pi_agent
```

当前本仓库安装方式：

```zsh
npm install -g @mariozechner/pi-coding-agent
```

批量更新 / 重装也已接入：

```zsh
update_ai_tools
reinstall_ai_tools
```

## 官方安装与升级

### 安装

```zsh
npm install -g @mariozechner/pi-coding-agent
```

### 运行

```zsh
pi
```

### 首次登录

```text
/login
```

官方说明里支持两类方式：

- 直接用 API key
- 用已有订阅登录

最常见的 API key 方式：

```zsh
export ANTHROPIC_API_KEY=sk-ant-...
pi
```

## 常用启动方式

### 交互模式

```zsh
pi
```

### 非交互打印

```zsh
pi -p "Summarize this codebase"
```

### JSON 事件流

```zsh
pi --mode json
```

### RPC 模式

```zsh
pi --mode rpc
```

### 继续 / 恢复会话

```zsh
pi -c
pi -r
pi --session <path-or-id>
pi --no-session
```

## 常用命令

交互里常见 slash commands：

- `/login` / `/logout`
- `/model`
- `/settings`
- `/resume`
- `/new`
- `/name <name>`
- `/session`
- `/tree`
- `/fork`
- `/compact [prompt]`
- `/reload`
- `/hotkeys`
- `/quit`

## 配置文件与目录

主要目录默认在：

```text
~/.pi/agent
```

常见文件：

- `~/.pi/agent/settings.json`
- `.pi/settings.json`
- `~/.pi/agent/models.json`
- `~/.pi/agent/keybindings.json`
- `~/.pi/agent/sessions/`

环境变量：

- `PI_CODING_AGENT_DIR`
- `PI_PACKAGE_DIR`
- `PI_SKIP_VERSION_CHECK`
- `PI_CACHE_RETENTION`
- `VISUAL`
- `EDITOR`

## Context / Skills / Extensions

### Context Files

`Pi` 启动时会加载：

- `~/.pi/agent/AGENTS.md`
- 父目录链上的 `AGENTS.md`
- 当前目录的 `AGENTS.md`

也兼容读取 `CLAUDE.md`。

### Skills

官方说明支持 Agent Skills 标准，常见目录：

- `~/.pi/agent/skills/`
- `~/.agents/skills/`
- `.pi/skills/`
- `.agents/skills/`

### Extensions

`Pi` 的很多高级能力都走 extension：

- 自定义 tools
- 自定义 commands
- UI 扩展
- permission gate
- sub-agent / plan mode 风格能力
- MCP 集成

常见目录：

- `~/.pi/agent/extensions/`
- `.pi/extensions/`

## Pi Packages

`Pi` 可以安装第三方 package 来分发扩展、skills、prompts、themes：

```zsh
pi install npm:@foo/pi-tools
pi install git:github.com/user/repo
pi remove npm:@foo/pi-tools
pi list
pi update
pi config
```

提示：

- git 包默认放到 `~/.pi/agent/git/`
- npm 包默认全局安装
- `-l` 可改成项目本地安装

## MCP 说明

这一点需要单独注意：

- 官方当前明确写了 `No MCP`
- `Pi` 本身没有像 `claude mcp add` / `codex mcp add` 这种内建 MCP 配置入口
- 如果你想接 MCP，要靠 extension 或第三方 `pi package`

所以本仓库的：

```zsh
mcp_convert_to
mcp_generate_add_commands
```

当前不把 `pi` 作为目标 CLI。

## 常见命令行选项

### 模型相关

- `--provider <name>`
- `--model <pattern>`
- `--api-key <key>`
- `--thinking <level>`
- `--models <patterns>`
- `--list-models [search]`

### 工具相关

- `--tools <list>`
- `--no-tools`

内建工具包括：

- `read`
- `bash`
- `edit`
- `write`
- `grep`
- `find`
- `ls`

### 资源相关

- `-e, --extension <source>`
- `--skill <path>`
- `--prompt-template <path>`
- `--theme <path>`

## 与本仓库的关系

- 安装：`install_pi_agent`
- 安装器总览：`show-help installer`
- MCP 转换说明：`show-help mcp`

## 参考

- npm 包页面: [@mariozechner/pi-coding-agent](https://www.npmjs.com/package/@mariozechner/pi-coding-agent)
- 官方主页: [shittycodingagent.ai](https://shittycodingagent.ai/)
