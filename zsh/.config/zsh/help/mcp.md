# MCP Guide

这份文档分三部分：

1. 各 CLI 的 MCP 配置说明（路径、格式、常用命令）
2. 本仓库转换命令用法（`mcp_convert_*`）
3. 一张异同对照表，方便快速选型和排障

## 各 CLI 配置说明

### Cursor

配置文件：

- `~/.cursor/mcp.json`（全局）
- `.cursor/mcp.json`（项目）

核心结构（`mcpServers`）：

```json
{
  "mcpServers": {
    "context7": {
      "url": "https://mcp.context7.com/mcp",
      "headers": { "CONTEXT7_API_KEY": "..." }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": { "NODE_ENV": "production" }
    }
  }
}
```

### Claude Code

推荐命令管理：

```zsh
claude mcp add -s user --transport http notion https://mcp.notion.com/mcp
claude mcp add -s user --transport stdio --env='API_KEY=your_key' my-local -- npx -y @modelcontextprotocol/server-memory
claude mcp list
```

项目共享配置：

- `.mcp.json`（项目根）
- 结构同 `mcpServers`，通常包含 `type`（`http`/`stdio`）、`url` 或 `command`

### Codex CLI

配置文件（TOML）：

- `~/.codex/config.toml`
- `.codex/config.toml`（可信项目）

核心结构（`[mcp_servers.<name>]`）：

```toml
[mcp_servers.context7]
url = "https://mcp.context7.com/mcp"
http_headers = { CONTEXT7_API_KEY = "..." }

[mcp_servers.memory]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-memory"]

[mcp_servers.memory.env]
NODE_ENV = "production"
```

命令：

```zsh
codex mcp add context7 -- npx -y @upstash/context7-mcp
codex mcp --help
```

### Gemini CLI

配置文件：

- `~/.gemini/settings.json`
- `.gemini/settings.json`

核心结构（`mcpServers`）：

- 本地进程：`command`/`args`/`env`
- 远端 HTTP：`httpUrl`
- SSE：`url`

```json
{
  "mcpServers": {
    "httpServer": {
      "httpUrl": "https://api.example.com/mcp",
      "headers": { "Authorization": "Bearer ..." }
    },
    "stdioServer": {
      "command": "python",
      "args": ["server.py"]
    }
  }
}
```

命令：

```zsh
gemini mcp add --transport http my-http https://api.example.com/mcp
gemini mcp add my-stdio npx -y @modelcontextprotocol/server-memory
gemini mcp list
```

### Kimi CLI

配置文件：

- `~/.kimi/mcp.json`

核心结构：

- 与 Cursor 风格兼容（`mcpServers` + `url/command/args/env`）

命令：

```zsh
kimi mcp add --transport http context7 https://mcp.context7.com/mcp
kimi mcp add --transport stdio memory -- npx -y @modelcontextprotocol/server-memory
kimi mcp list
```

### OpenCode

配置文件：

- `~/.config/opencode/opencode.json`
- `opencode.json`（项目）

核心结构（`mcp`）：

- `type: "local"` + `command`（数组）
- `type: "remote"` + `url`
- 常用字段：`enabled`、`environment`、`headers`

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "enabled": true
    }
  }
}
```

官方命令入口：

```zsh
opencode mcp add
opencode mcp list
opencode mcp auth [name]
opencode mcp debug <name>
```

### Kilo

配置文件：

- `~/.config/kilo/kilo.json`
- `~/.config/kilo/kilo.jsonc`
- `kilo.json`
- `.kilo/kilo.json`

核心结构（`mcp`）：

- `type: "remote"` + `url`
- `type: "local"` + `command`（数组）
- 常用字段：`enabled`、`headers`、`environment`、`timeout`

```json
{
  "$schema": "https://kilo.ai/config.json",
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "enabled": true
    }
  }
}
```

官方命令入口：

```zsh
kilo mcp add
kilo mcp list
kilo mcp auth
```

### Factory Droid

配置文件：

- `~/.factory/mcp.json`
- `.factory/mcp.json`

核心结构（`mcpServers`）：

- `type: "http"` + `url`
- `type: "stdio"` + `command`/`args`
- 常用字段：`headers`、`env`、`disabled`

命令：

```zsh
droid mcp add linear https://mcp.linear.app/mcp --type http
droid mcp add memory "npx -y @modelcontextprotocol/server-memory"
droid mcp remove linear
```

### Goose

Goose 更偏“扩展管理”，MCP 常通过交互配置：

```zsh
goose configure
```

配置文件：

- `~/.config/goose/config.yaml`

对应关系：

- 远端 MCP -> `Remote Extension (Streamable HTTP)`
- 本地 MCP -> `Command-line Extension`

临时启用也可以直接从命令行开会话：

```zsh
goose session --with-extension "uvx mcp-server-fetch"
goose session --with-streamable-http-extension "https://example.com/mcp"
```

### Crush

配置文件：

- `.crush.json`
- `crush.json`
- `~/.config/crush/crush.json`

核心结构（`mcp`）：

- 远端 HTTP: `type: "http"` + `url`
- SSE: `type: "sse"` + `url`
- 本地进程: `type: "stdio"` + `command`/`args`
- 常用字段：`headers`、`env`、`timeout`、`disabled`、`disabled_tools`

```json
{
  "$schema": "https://charm.land/crush.json",
  "mcp": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp",
      "headers": { "Authorization": "Bearer ..." }
    },
    "memory": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

说明：

- `crush` 目前没有官方的 `mcp add` 子命令
- 本仓库提供 `mcp_convert_to crush ...` 直接生成 `crush.json`
- `mcp_generate_add_commands crush ...` 会输出可粘贴到 `mcp` 下的 JSON 片段

## 本仓库转换命令

交互式：

```zsh
mcp_convert_interactive
```

非交互：

```zsh
mcp_convert_to <factory|opencode|kilo|crush|goose|cursor|claude|gemini|kimi|codex|all> [source.json] [--write]
```

按 `--from/--to/--input` 风格直接打印到 stdout：

```zsh
mcp_convert_to_print --from <auto|cursor|factory|claude|gemini|kimi|opencode|kilo|crush|codex> --to <cursor|factory|claude|gemini|kimi|opencode|kilo|crush|codex> --input <path>
```

按目标 CLI 生成“直接命令、交互提示或配置片段”：

```zsh
mcp_generate_add_commands <claude|gemini|kimi|factory|codex|opencode|kilo|goose|crush|all> [source.json]
```

说明：`source` 可以是 JSON，也可以直接给 `~/.codex/config.toml`（会自动转成中间 JSON）。

常用例子：

```zsh
# 打印为 Codex TOML 片段
mcp_convert_to codex ~/.cursor/mcp.json

# 用 flag 风格打印成 Kilo JSON
mcp_convert_to_print --from auto --to kilo --input ~/.cursor/mcp.json

# 把 Codex TOML 转成 Crush JSON 并输出到 stdout
mcp_convert_to_print --from codex --to crush --input ~/.codex/config.toml

# 把 Cursor JSON 转成 Codex TOML 并输出到 stdout
mcp_convert_to_print --from cursor --to codex --input ~/.cursor/mcp.json

# 把 Cursor 配置写入 Gemini settings.json（合并 mcpServers）
mcp_convert_to gemini ~/.cursor/mcp.json --write

# 一次生成全部（含 Goose 引导信息）
mcp_convert_to all ~/.cursor/mcp.json

# 从任意已支持 MCP JSON 生成 Claude 命令
mcp_generate_add_commands claude ~/.cursor/mcp.json

# 生成 Gemini 命令（含 -H/-e 参数）
mcp_generate_add_commands gemini ~/.factory/mcp.json

# 生成 Factory Droid 命令
mcp_generate_add_commands factory ~/.kimi/mcp.json

# 生成 OpenCode 交互提示
mcp_generate_add_commands opencode ~/.cursor/mcp.json

# 生成 Kilo 交互提示
mcp_generate_add_commands kilo ~/.cursor/mcp.json

# 生成 Goose 交互配置提示
mcp_generate_add_commands goose ~/.cursor/mcp.json

# 生成 Crush 的 mcp JSON 片段
mcp_generate_add_commands crush ~/.cursor/mcp.json
```

示例输出（Claude）：

```zsh
claude mcp add -s user --transport http 'notion' 'https://mcp.notion.com/mcp'
claude mcp add -s user --transport stdio --env='NODE_ENV=production' 'memory' -- 'npx' '-y' '@modelcontextprotocol/server-memory'
```

## 异同对照表

| CLI | 主配置文件 | 配置格式 | 服务器根字段 | 远端字段 | 本地字段 | 备注 |
|---|---|---|---|---|---|---|
| Cursor | `~/.cursor/mcp.json` | JSON | `mcpServers` | `url` | `command` + `args` | 生态最常见 JSON 结构 |
| Claude Code | `.mcp.json` / `~/.claude.json` | JSON | `mcpServers` | `type=http/sse` + `url` | `type=stdio` + `command` | 强调 `claude mcp add` 命令管理 |
| Codex CLI | `~/.codex/config.toml` | TOML | `[mcp_servers.<name>]` | `url` | `command` + `args` | 唯一 TOML，转换时最容易踩坑 |
| Gemini CLI | `~/.gemini/settings.json` | JSON | `mcpServers` | `httpUrl` 或 `url`(SSE) | `command` + `args` | 对 HTTP/SSE 字段区分更明显 |
| Kimi CLI | `~/.kimi/mcp.json` | JSON | `mcpServers` | `url` | `command` + `args` | 与 Cursor 风格高度兼容 |
| OpenCode | `~/.config/opencode/opencode.json` | JSON | `mcp` | `type=remote` + `url` | `type=local` + `command`(数组) | 字段命名差异最大 |
| Kilo | `~/.config/kilo/kilo.json` | JSON | `mcp` | `type=remote` + `url` | `type=local` + `command`(数组) | 和 OpenCode 很像，但 schema / 默认路径不同 |
| Crush | `.crush.json` / `crush.json` / `~/.config/crush/crush.json` | JSON | `mcp` | `type=http/sse` + `url` | `type=stdio` + `command` | 支持 `timeout`、`disabled_tools`，但无官方 `mcp add` |
| Factory | `~/.factory/mcp.json` | JSON | `mcpServers` | `type=http` + `url` | `type=stdio` + `command` | `disabled`、`env` 很常用 |
| Goose | `~/.config/goose/config.yaml` | YAML | `extensions` | `streamable_http` | `cmd/args` | 以交互配置为主，不是纯 mcpServers 文件 |

## 排障提示

- JSON 源文件校验失败：先 `jq empty your.json`
- Codex 不吃 JSON：先转 `codex` 目标再合并 TOML
- 如果你只想拿 stdout，不想写文件：用 `mcp_convert_to_print --from --to --input`
- Gemini 写入后不生效：确认写的是 `settings.json` 对应 scope（user/project）
- Kilo 的 MCP 配置优先用 `~/.config/kilo/kilo.json` 或项目 `kilo.json`
- Goose 无法自动全量落盘：先看 `mcp_convert_to goose` 输出映射，再 `goose configure`
- OpenCode/Goose/Crush 不一定有单行 `mcp add`：优先看 `mcp_generate_add_commands <target> <source>` 给出的交互提示或配置片段
- `Pi` 当前官方明确是 `No MCP`：它走 `extensions` / `skills` / `pi packages`，不在这套 `mcp_convert_*` / `mcp_generate_add_commands` 链路里
- TOML 解析建议优先安装 `taplo`：`install_taplo_by_brew` 或 `install_taplo_by_eget`
