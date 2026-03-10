# Kilo CLI 使用说明

这份文档基于 Kilo 官方 CLI 文档整理，适合本机 `show-help` 速查。

## 它是什么

- `Kilo CLI` 是一个终端里的 coding agent。
- 官方定位是键盘优先的 TUI / CLI，支持规划、调试、编码、会话管理和 MCP。
- 当前文档明确适用于 `1.0` 及以后版本。

## 本仓库安装入口

```zsh
install_kilo_cli
```

当前本仓库安装方式：

```zsh
npm install -g @kilocode/cli
```

批量更新 / 重装也已接入：

```zsh
update_ai_tools
reinstall_ai_tools
```

## 官方安装与升级

### 安装

```zsh
npm install -g @kilocode/cli
```

### 升级

```zsh
kilo upgrade
npm update -g @kilocode/cli
```

### 验证

```zsh
kilo --version
kilo --help
```

### 老 CPU 注意

官方说明里提到，没有 AVX 的旧 CPU 可能会遇到 `Illegal instruction`，这种情况下建议从 GitHub Releases 下载 `-baseline` 变体直接运行。

## 启动方式

### TUI

```zsh
kilo
kilo /path/to/project
```

### 非交互

```zsh
kilo run "Explain how this repo is structured"
```

### Headless / Web / Attach

```zsh
kilo serve
kilo web
kilo attach http://localhost:4096
```

## 首次使用

安装后进入项目目录运行：

```zsh
kilo
```

首次配置 provider，官方建议用：

```text
/connect
```

这是交互式添加 provider 凭据的主入口。

## 常用 CLI 命令

- `kilo`
- `kilo run [message..]`
- `kilo attach <url>`
- `kilo serve`
- `kilo web`
- `kilo auth`
- `kilo agent`
- `kilo mcp`
- `kilo models [provider]`
- `kilo stats`
- `kilo session`
- `kilo export [sessionID]`
- `kilo import <file>`
- `kilo upgrade [target]`
- `kilo uninstall`
- `kilo pr <number>`
- `kilo github`
- `kilo debug`
- `kilo completion`

## 常用 Slash Commands

### 会话

- `/sessions`
- `/resume`
- `/continue`
- `/new`
- `/clear`
- `/share`
- `/rename`
- `/timeline`
- `/fork`
- `/compact`
- `/undo`
- `/redo`

### Agent / Model / MCP

- `/models`
- `/agents`
- `/mcps`
- `/connect`

### 系统

- `/status`
- `/themes`
- `/help`
- `/editor`
- `/exit`

### 内置辅助

- `/init`
- `/local-review`
- `/local-review-uncommitted`

## 配置文件

MCP 文档页当前推荐的配置文件是：

- `~/.config/kilo/kilo.json`
- `~/.config/kilo/kilo.jsonc`
- `kilo.json`
- `.kilo/kilo.json`

官方 CLI 页还提到过：

- `~/.config/kilo/opencode.json`
- `~/.config/kilo/opencode.jsonc`

所以如果你在旧配置里看到 `opencode.json`，不奇怪；但新写法建议优先用 `kilo.json`。

## MCP

`Kilo` 官方明确支持 CLI 内 MCP。

常用命令：

```zsh
kilo mcp add
kilo mcp list
kilo mcp auth
```

配置放在 `mcp` 键下，结构和 OpenCode 很接近：

```json
{
  "$schema": "https://kilo.ai/config.json",
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "enabled": true
    },
    "memory": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

本仓库也已经接入：

```zsh
mcp_convert_to kilo ~/.cursor/mcp.json
mcp_generate_add_commands kilo ~/.cursor/mcp.json
```

更多 MCP 细节可直接看：

```zsh
show-help mcp
```

## 权限

Kilo 的 permission 配置支持三种动作：

- `allow`
- `ask`
- `deny`

可按工具和模式匹配规则细分，例如：

- `bash`
- `edit`
- `external_directory`

并且是“最后匹配规则生效”。

## Autonomous Mode

非交互自动模式：

```zsh
kilo run --auto "Implement feature X"
```

官方说明里：

- 无需用户交互
- 未自动批准的操作不会执行
- 完成后自动退出

常见退出码：

- `0` 成功
- `124` 超时
- `1` 初始化或执行失败

## 与 OpenCode 的关系

官方文档明确说明，Kilo CLI 在配置能力上和 OpenCode 很接近，很多配置项也兼容 OpenCode 风格。

实操上可以理解为：

- `mcp` 结构几乎同类
- provider / permission / instructions 这些配置也接近
- 但 schema、命令名前缀、默认配置路径按 Kilo 自己的文档来

## 与本仓库的关系

- 安装：`install_kilo_cli`
- MCP 转换：`show-help mcp`
- 安装器总览：`show-help installer`

## 参考

- 官方 CLI 文档: [Kilo CLI](https://kilo.ai/docs/code-with-ai/platforms/cli)
- 官方 MCP 文档: [Using MCP in CLI](https://kilo.ai/docs/automate/mcp/using-in-cli)
- 官方仓库: [Kilo-Org/kilocode](https://github.com/Kilo-Org/kilocode)
