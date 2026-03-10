# OpenCode 使用说明

这份文档基于 OpenCode 官方文档整理，偏向本机 `show-help` 的速查用法。

## 它是什么

- `OpenCode` 是一个开源 coding agent。
- 默认进入 TUI，也支持非交互、HTTP server、Web UI、ACP、GitHub agent。
- 配置使用 JSON / JSONC，而不是 TOML。

## 本仓库安装入口

```zsh
install_opencode_cli
```

当前本仓库的安装逻辑是：

- 有 `npm` 时安装 `opencode`
- 否则回退到官方安装脚本

升级：

```zsh
opencode upgrade
```

## 官方使用入口

### 启动 TUI

```zsh
opencode
opencode /path/to/project
```

### 非交互模式

```zsh
opencode run "Explain how closures work in JavaScript"
```

### 远程 / Headless

```zsh
opencode serve
opencode web
opencode acp
opencode attach http://localhost:4096
```

## 常用 CLI 命令

### 会话与执行

- `opencode`：启动 TUI
- `opencode run ...`：非交互执行
- `opencode session list`：列出会话
- `opencode export [sessionID]`：导出会话 JSON
- `opencode import <file|share-url>`：导入会话
- `opencode stats`：看 token / cost 统计

### Agent / Model / Auth

- `opencode agent list`
- `opencode agent create`
- `opencode auth login`
- `opencode auth list`
- `opencode auth logout`
- `opencode models`
- `opencode models anthropic`
- `opencode models --refresh`

### MCP

- `opencode mcp add`
- `opencode mcp list`
- `opencode mcp auth [name]`
- `opencode mcp auth list`
- `opencode mcp logout [name]`
- `opencode mcp debug <name>`

### GitHub / 运维

- `opencode github install`
- `opencode github run`
- `opencode upgrade`
- `opencode uninstall`

## TUI 内常用能力

### 文件引用

在消息里用 `@` 引文件：

```text
How is auth handled in @packages/functions/src/api/index.ts?
```

### 直接跑 shell

以 `!` 开头运行 shell 命令：

```text
!ls -la
```

### 常用 slash commands

- `/connect`：添加 provider
- `/compact`：压缩上下文
- `/details`：切换工具执行细节
- `/editor`：外部编辑器
- `/help`：帮助
- `/init`：创建或更新 `AGENTS.md`
- `/models`：列模型
- `/new` / `/clear`：新会话
- `/sessions` / `/resume` / `/continue`：切会话
- `/share` / `/unshare`：分享会话
- `/themes`：切主题
- `/thinking`：显示/隐藏 reasoning
- `/undo` / `/redo`：回滚 / 重做
- `/exit` / `/quit` / `/q`：退出

## 配置文件

OpenCode 使用 JSON / JSONC 配置。

### 主要位置

配置按以下顺序合并，后者覆盖前者冲突字段：

1. 远端组织配置 `.well-known/opencode`
2. 全局配置 `~/.config/opencode/opencode.json`
3. `OPENCODE_CONFIG`
4. 项目配置 `opencode.json`
5. `.opencode/` 目录里的 agents / commands / plugins
6. `OPENCODE_CONFIG_CONTENT`

TUI 配置单独放：

- `~/.config/opencode/tui.json`
- 项目下 `tui.json`
- 也可用 `OPENCODE_TUI_CONFIG`

### 最小配置示例

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "anthropic/claude-sonnet-4-5",
  "autoupdate": true,
  "server": {
    "port": 4096
  }
}
```

### 常见配置项

- `model`
- `small_model`
- `provider`
- `permission`
- `mcp`
- `agent`
- `default_agent`
- `command`
- `formatter`
- `share`
- `plugins`
- `instructions`
- `enabled_providers`
- `disabled_providers`
- `compaction`
- `watcher.ignore`

## Provider / Model

### 登录凭据

```zsh
opencode auth login
```

认证信息保存在：

```text
~/.local/share/opencode/auth.json
```

OpenCode 启动时会同时读取：

- 认证文件里的 provider
- 环境变量里的 API key
- 项目 `.env`

### 选模型

模型名格式是：

```text
provider/model
```

例如：

```json
{
  "model": "anthropic/claude-sonnet-4-5",
  "small_model": "anthropic/claude-haiku-4-5"
}
```

## Permissions

OpenCode 的一个重要特点是：默认比较宽松。

官方文档说明：

- 大多数操作默认是 `allow`
- 你可以把权限改成 `allow` / `ask` / `deny`

### 最简单写法

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "*": "ask",
    "bash": "allow",
    "edit": "deny"
  }
}
```

### 更细粒度 bash / edit 规则

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "bash": {
      "*": "ask",
      "git *": "allow",
      "npm *": "allow",
      "rm *": "deny"
    },
    "edit": {
      "*": "deny",
      "docs/*.md": "allow"
    }
  }
}
```

规则特点：

- 支持 `*` 和 `?`
- 同一个权限下，最后匹配的规则生效
- `external_directory` 和 `doom_loop` 是单独的保护项
- `.env` 默认就会被拒读，`.env.example` 例外

## MCP

OpenCode 用 `mcp` 配置项管理 MCP server。

本仓库里相关格式说明可以直接看：

```zsh
show-help mcp
```

官方命令入口：

```zsh
opencode mcp add
opencode mcp list
opencode mcp auth
opencode mcp debug
```

## 自定义 Agents / Commands / Plugins

### Agents

你可以在配置里写 agent，也可以放在：

- `~/.config/opencode/agents/`
- `.opencode/agents/`

### Commands

你可以在配置里写 `command`，也可以放在：

- `~/.config/opencode/commands/`
- `.opencode/commands/`

### Plugins

插件目录：

- `.opencode/plugins/`
- `~/.config/opencode/plugins/`

也可以直接在配置里写 npm 包名。

## 其他常用点

### 共享会话

```json
{
  "share": "manual"
}
```

可选值：

- `"manual"`
- `"auto"`
- `"disabled"`

### 自动更新

```json
{
  "autoupdate": false
}
```

如果不是包管理器安装，也可以用 `"notify"` 只提醒不自动更。

### 外部编辑器

`/editor` 和 `/export` 依赖 `EDITOR` 环境变量：

```zsh
export EDITOR="code --wait"
```

## 在本仓库里最相关的几个点

- 安装：`install_opencode_cli`
- 更新：`opencode upgrade`
- MCP 转换：`show-help mcp`
- 安装策略：`show-help installer`

## 参考

- 官方 CLI 文档: [CLI](https://opencode.ai/docs/cli/)
- 官方配置文档: [Config](https://opencode.ai/docs/config/)
- 官方权限文档: [Permissions](https://opencode.ai/docs/permissions/)
- 官方 TUI 文档: [TUI](https://opencode.ai/docs/tui/)
