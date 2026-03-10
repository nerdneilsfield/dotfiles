# Kimi Code CLI 使用说明

这份文档基于 Moonshot AI 官方 Kimi Code CLI 文档整理。

## 它是什么

- `Kimi Code CLI` 是运行在终端中的 AI agent。
- 它可以读写代码、执行 shell、搜索网页、抓取 URL，并自主规划执行步骤。
- 除了终端交互，还支持 `kimi web` 和 `kimi acp`。

## 本仓库安装入口

```zsh
install_kimi_cli
```

本仓库当前安装 / 升级方式：

```zsh
uv tool install kimi-cli --no-cache
uv tool upgrade kimi-cli --no-cache
```

## 官方安装与升级

### 官方安装脚本

```zsh
curl -LsSf https://code.kimi.com/install.sh | bash
```

Windows PowerShell：

```powershell
Invoke-RestMethod https://code.kimi.com/install.ps1 | Invoke-Expression
```

### 已有 uv 时

```zsh
uv tool install --python 3.13 kimi-cli
```

官方建议：

- 支持 Python `3.12` 到 `3.14`
- 推荐 Python `3.13`

### 升级 / 卸载

```zsh
uv tool upgrade kimi-cli --no-cache
uv tool uninstall kimi-cli
```

## 启动方式

### 交互模式

```zsh
kimi
```

### Browser UI

```zsh
kimi web
```

### Agent integration

```zsh
kimi acp
```

## 首次使用

进入项目目录后启动：

```zsh
cd your-project
kimi
```

首次运行建议先执行：

```text
/login
```

官方文档说明：

- 选择 `Kimi Code` 时，会走浏览器 OAuth
- 其他平台通常走 API key
- 配置完成后会自动写入 `~/.kimi/config.toml`

如果项目里没有 `AGENTS.md`，官方建议可以直接：

```text
/init
```

## 配置与 Provider

### 配置文件

主要配置文件：

```text
~/.kimi/config.toml
```

### `/login` 支持的平台

官方文档当前写明：

- `Kimi Code`
- `Moonshot AI Open Platform (moonshot.cn)`
- `Moonshot AI Open Platform (moonshot.ai)`

### 支持的 provider type

- `kimi`
- `openai_legacy`
- `openai_responses`
- `anthropic`
- `gemini`
- `vertexai`

### 示例

#### Kimi

```toml
[providers.kimi-for-coding]
type = "kimi"
base_url = "https://api.kimi.com/coding/v1"
api_key = "sk-xxx"
```

#### OpenAI Responses

```toml
[providers.openai-responses]
type = "openai_responses"
base_url = "https://api.openai.com/v1"
api_key = "sk-xxx"
```

#### Anthropic

```toml
[providers.anthropic]
type = "anthropic"
base_url = "https://api.anthropic.com"
api_key = "sk-ant-xxx"
```

## Model capabilities

官方文档里，模型 capability 会影响功能是否可用：

- `thinking`
- `always_thinking`
- `image_in`
- `video_in`

例如：

```toml
[models.gemini-3-pro-preview]
provider = "gemini"
model = "gemini-3-pro-preview"
max_context_size = 262144
capabilities = ["thinking", "image_in"]
```

### thinking mode

支持 `thinking` 的模型：

- 可以在 `/model` 里切
- 启动时也可以用 `--thinking` / `--no-thinking`

### image / video input

- `image_in`：可粘贴图片
- `video_in`：可发送视频内容

## Search / Fetch 服务

官方文档强调：

- `SearchWeb`
- `FetchURL`

依赖外部服务，目前只有 `Kimi Code` 平台提供完整服务。

具体行为：

- `moonshot_search` 对应 `SearchWeb`
- `moonshot_fetch` 对应 `FetchURL`

如果不是 Kimi Code 平台：

- `SearchWeb` 可能不可用
- `FetchURL` 会回退到本地抓取

## 常用 slash commands

### 帮助与信息

- `/help`
- `/version`
- `/changelog`
- `/feedback`

### 账号与配置

- `/login` / `/setup`
- `/logout`
- `/model`
- `/editor`
- `/reload`
- `/debug`
- `/usage` / `/status`
- `/mcp`

### 会话管理

- `/new`
- `/sessions` / `/resume`
- `/export`
- `/import`
- `/clear` / `/reset`
- `/compact`

### Skills / Flows

- `/skill:<name>`
- `/flow:<name>`

### 工作区

- `/add-dir`

### 其他

- `/init`
- `/yolo`
- `/web`

## 几个重点命令

### `/model`

- 刷新可用模型列表
- 交互切模型
- 如果模型支持，还会切 thinking mode
- 改完后自动写回配置文件并 reload

### `/sessions`

- 列出当前工作目录下的会话
- 可直接切换
- 别名是 `/resume`

### `/export`

导出当前会话为 Markdown，包含：

- session ID
- 导出时间
- 工作目录
- 消息数 / token 数
- 对话概览
- 完整对话历史

### `/import`

可导入：

- 文本文件
- 源代码
- 配置文件
- 其他会话

不支持二进制文件。

### `/add-dir`

把额外目录加入工作区范围，之后：

- `ReadFile`
- `WriteFile`
- `Glob`
- `Grep`
- `StrReplaceFile`

等文件工具都能访问。

### `/yolo`

打开后会跳过确认，风险较高。

## 使用建议

- 初次进入一个新仓库，先让它分析项目，再考虑 `/init`
- 想用 Kimi 官方搜索 / 抓取能力时，优先选择 `Kimi Code` 平台
- 多 provider 场景下，优先把通用 provider 写在 `~/.kimi/config.toml`
- 跨目录协作时，用 `/add-dir` 比随便放开权限更清晰

## 在本仓库里最相关的几个点

- 安装：`install_kimi_cli`
- MCP 文件路径：`show-help mcp`
- AGENTS.md：本仓库本身已经在大量使用

## 参考

- 官方入门: [Getting Started](https://moonshotai.github.io/kimi-cli/en/guides/getting-started.html)
- 官方 Providers: [Providers and Models](https://moonshotai.github.io/kimi-cli/en/configuration/providers.html)
- 官方 slash commands: [Slash Commands](https://moonshotai.github.io/kimi-cli/en/reference/slash-commands.html)
- 官方仓库: [MoonshotAI/kimi-cli](https://github.com/MoonshotAI/kimi-cli)
