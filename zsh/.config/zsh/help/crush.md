# Crush 使用说明

这份文档基于 `charmbracelet/crush` 官方 README 整理，补成适合本机 `show-help` 阅读的中文版速查。

## 它是什么

- `Crush` 是一个终端里的 agentic coding CLI。
- 它支持多模型、多 provider、MCP、LSP、项目级配置和全局配置。
- 它可以在会话中切换模型，并保留上下文。

## 本机安装

本仓库已经提供了安装函数：

```zsh
install_crush_cli
```

当前本地安装优先级是：

1. `brew`
2. `yay`
3. `nix`
4. `eget`

如果 `crush` 已经存在，该函数会优先走升级逻辑。

## 官方安装方式

### macOS / Linux

```zsh
# Homebrew
brew install charmbracelet/tap/crush

# Arch Linux
yay -S crush-bin

# Nix（官方 README 给的是运行方式）
nix run github:numtide/nix-ai-tools#crush

# Debian / Ubuntu
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update && sudo apt install crush

# Fedora / RHEL
echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
sudo yum install crush

# Go
go install github.com/charmbracelet/crush@latest
```

### Windows

```powershell
# Winget
winget install charmbracelet.crush

# Scoop
scoop bucket add charm https://github.com/charmbracelet/scoop-bucket.git
scoop install crush
```

### Nix / NUR

官方 README 还给了 NUR 方式，适合想拿到更及时版本的人：

```zsh
nix-channel --add https://github.com/nix-community/NUR/archive/main.tar.gz nur
nix-channel --update
nix-shell -p '(import { pkgs = import {}; }).repos.charmbracelet.crush'
```

## 快速开始

最直接的用法就是直接启动：

```zsh
crush
```

首次使用时，你可以直接输入自己常用 provider 的 API Key；也可以提前在环境变量里配置。

常见环境变量：

- `ANTHROPIC_API_KEY`
- `OPENAI_API_KEY`
- `VERCEL_API_KEY`
- `GEMINI_API_KEY`
- `SYNTHETIC_API_KEY`
- `ZAI_API_KEY`
- `MINIMAX_API_KEY`
- `HF_TOKEN`
- `CEREBRAS_API_KEY`
- `OPENROUTER_API_KEY`
- `IONET_API_KEY`
- `GROQ_API_KEY`
- `VERTEXAI_PROJECT`
- `VERTEXAI_LOCATION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_PROFILE`
- `AWS_BEARER_TOKEN_BEDROCK`
- `AZURE_OPENAI_API_ENDPOINT`
- `AZURE_OPENAI_API_KEY`
- `AZURE_OPENAI_API_VERSION`

## 配置文件位置

`Crush` 配置优先级从高到低如下：

1. `.crush.json`
2. `crush.json`
3. `$HOME/.config/crush/crush.json`

另外它还会保存运行期数据：

```zsh
# Unix
$HOME/.local/share/crush/crush.json

# Windows
%LOCALAPPDATA%\crush\crush.json
```

如果你想改默认位置，可以设置：

- `CRUSH_GLOBAL_CONFIG`
- `CRUSH_GLOBAL_DATA`

## 最小配置示例

```json
{
  "$schema": "https://charm.land/crush.json",
  "providers": {
    "openai": {
      "type": "openai",
      "base_url": "https://api.openai.com/v1",
      "api_key": "$OPENAI_API_KEY",
      "models": [
        {
          "id": "gpt-4.1",
          "name": "GPT-4.1",
          "context_window": 1047576,
          "default_max_tokens": 32000
        }
      ]
    }
  }
}
```

## LSP 配置

`Crush` 可以接 LSP 给代理补上下文。README 里的写法是：

```json
{
  "$schema": "https://charm.land/crush.json",
  "lsp": {
    "go": {
      "command": "gopls",
      "env": {
        "GOTOOLCHAIN": "go1.24.5"
      }
    },
    "typescript": {
      "command": "typescript-language-server",
      "args": ["--stdio"]
    },
    "nix": {
      "command": "nil"
    }
  }
}
```

## MCP 配置

`Crush` 支持三种 MCP transport：

- `stdio`
- `http`
- `sse`

README 中给出的 MCP 配置结构如下：

```json
{
  "$schema": "https://charm.land/crush.json",
  "mcp": {
    "filesystem": {
      "type": "stdio",
      "command": "node",
      "args": ["/path/to/mcp-server.js"],
      "timeout": 120,
      "disabled": false,
      "disabled_tools": ["some-tool-name"],
      "env": {
        "NODE_ENV": "production"
      }
    },
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "timeout": 120,
      "disabled": false,
      "disabled_tools": ["create_issue", "create_pull_request"],
      "headers": {
        "Authorization": "Bearer $GH_PAT"
      }
    },
    "streaming-service": {
      "type": "sse",
      "url": "https://example.com/mcp/sse",
      "timeout": 120,
      "disabled": false,
      "headers": {
        "API-Key": "$(echo $API_KEY)"
      }
    }
  }
}
```

说明：

- 支持 `headers`、`env`、`timeout`
- 支持 `disabled` 和 `disabled_tools`
- 支持 `$(echo $VAR)` 这种环境变量展开

## 忽略文件

`Crush` 默认会尊重 `.gitignore`。

如果你还想额外排除文件或目录，可以加：

```text
.crushignore
```

语法和 `.gitignore` 一样，既可以放在项目根目录，也可以放在子目录。

## 权限与工具控制

默认情况下，`Crush` 在执行工具调用前会先征求许可。

### 允许部分工具免确认

```json
{
  "$schema": "https://charm.land/crush.json",
  "permissions": {
    "allowed_tools": [
      "view",
      "ls",
      "grep",
      "edit",
      "mcp_context7_get-library-doc"
    ]
  }
}
```

### 跳过所有权限确认

```zsh
crush --yolo
```

这个选项很危险，只适合你完全信任当前环境时使用。

### 禁用内置工具

```json
{
  "$schema": "https://charm.land/crush.json",
  "options": {
    "disabled_tools": ["bash", "sourcegraph"]
  }
}
```

## Skills

`Crush` 支持 Agent Skills 标准。

默认搜索目录：

- Unix: `~/.config/crush/skills/`
- Windows: `%LOCALAPPDATA%\crush\skills\`

也可以通过下面两个入口自定义：

- 环境变量 `CRUSH_SKILLS_DIR`
- 配置项 `options.skills_paths`

示例：

```jsonc
{
  "$schema": "https://charm.land/crush.json",
  "options": {
    "skills_paths": [
      "~/.config/crush/skills",
      "./project-skills"
    ]
  }
}
```

## 初始化项目上下文

README 提到，初始化项目时 `Crush` 会生成一个上下文文件，默认名称是：

```text
AGENTS.md
```

你也可以改成别的名字：

```json
{
  "$schema": "https://charm.land/crush.json",
  "options": {
    "initialize_as": "AGENTS.md"
  }
}
```

适用场景：

- 想改成 `CRUSH.md`
- 想改成 `docs/LLMs.md`
- 想把项目约定、构建命令、代码风格固定下来

## Attribution

`Crush` 默认会给它生成的 commit / PR 添加 attribution。

相关配置：

```json
{
  "$schema": "https://charm.land/crush.json",
  "options": {
    "attribution": {
      "trailer_style": "co-authored-by",
      "generated_with": true
    }
  }
}
```

`trailer_style` 可选值：

- `assisted-by`
- `co-authored-by`
- `none`

## 自定义 Provider

README 里特别强调了两种 OpenAI 风格：

- `openai`
  - 适合真正通过 OpenAI 转发或路由的场景
- `openai-compat`
  - 适合非 OpenAI 但兼容 OpenAI API 的服务

### OpenAI-Compatible 示例

```json
{
  "$schema": "https://charm.land/crush.json",
  "providers": {
    "deepseek": {
      "type": "openai-compat",
      "base_url": "https://api.deepseek.com/v1",
      "api_key": "$DEEPSEEK_API_KEY",
      "models": [
        {
          "id": "deepseek-chat",
          "name": "Deepseek V3",
          "cost_per_1m_in": 0.27,
          "cost_per_1m_out": 1.1,
          "context_window": 64000,
          "default_max_tokens": 5000
        }
      ]
    }
  }
}
```

### Anthropic-Compatible 示例

```json
{
  "$schema": "https://charm.land/crush.json",
  "providers": {
    "custom-anthropic": {
      "type": "anthropic",
      "base_url": "https://api.anthropic.com/v1",
      "api_key": "$ANTHROPIC_API_KEY",
      "extra_headers": {
        "anthropic-version": "2023-06-01"
      },
      "models": [
        {
          "id": "claude-sonnet-4-20250514",
          "name": "Claude Sonnet 4",
          "context_window": 200000,
          "default_max_tokens": 50000,
          "can_reason": true,
          "supports_attachments": true
        }
      ]
    }
  }
}
```

### 本地模型

官方 README 里给了两个常见的本地 OpenAI-compatible 例子：

- `Ollama`
- `LM Studio`

这类 provider 的关键点通常是：

- `type: "openai-compat"`
- `base_url` 指向本地服务
- `models` 手工列出你打算用的模型

## Bedrock / Vertex AI

### Amazon Bedrock

README 中明确提到：

- 先跑过 `aws configure`
- 设置 `AWS_REGION` 或 `AWS_DEFAULT_REGION`
- 如果要特定 profile，设置 `AWS_PROFILE`
- 或直接设置 `AWS_BEARER_TOKEN_BEDROCK`

### Vertex AI

你至少需要：

- `VERTEXAI_PROJECT`
- `VERTEXAI_LOCATION`

并完成：

```zsh
gcloud auth application-default login
```

## 日志与调试

日志默认保存在项目目录下：

```text
./.crush/logs/crush.log
```

常用日志命令：

```zsh
# 最近 1000 行
crush logs

# 最近 500 行
crush logs --tail 500

# 实时跟随
crush logs --follow
```

如果想开更多调试信息：

```zsh
crush --debug
```

或者写进配置：

```json
{
  "$schema": "https://charm.land/crush.json",
  "options": {
    "debug": true,
    "debug_lsp": true
  }
}
```

## Provider 自动更新

`Crush` 默认会自动从 `Catwalk` 更新 provider / model 列表。

如果你不想自动更新：

```json
{
  "$schema": "https://charm.land/crush.json",
  "options": {
    "disable_provider_auto_update": true
  }
}
```

或者：

```zsh
export CRUSH_DISABLE_PROVIDER_AUTO_UPDATE=1
```

手工更新方式：

```zsh
# 从 Catwalk 远端更新
crush update-providers

# 使用自定义 URL
crush update-providers https://example.com/

# 使用本地文件
crush update-providers /path/to/local-providers.json

# 回退到构建时内置版本
crush update-providers embedded
```

## Metrics

README 说明：

- `Crush` 会记录匿名化、与设备哈希相关的 usage metadata
- 不会采集 prompt 和 response 内容

关闭方式：

```zsh
export CRUSH_DISABLE_METRICS=1
```

或者：

```json
{
  "options": {
    "disable_metrics": true
  }
}
```

它也尊重：

```zsh
export DO_NOT_TRACK=1
```

## 你在本仓库里最常用的几个点

- 安装 / 升级：`install_crush_cli`
- 帮助文档：`show-help crush`
- 如果要接 MCP，可参考 `show-help mcp`
- 如果要统一管理 CLI 安装策略，可参考 `show-help installer`

## 参考

- 官方仓库: [charmbracelet/crush](https://github.com/charmbracelet/crush)
- 官方 README: [README.md](https://github.com/charmbracelet/crush/blob/main/README.md)
- 原始 README 源文件: [raw README](https://raw.githubusercontent.com/charmbracelet/crush/main/README.md)
