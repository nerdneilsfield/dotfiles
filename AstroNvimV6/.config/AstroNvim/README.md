# AstroNvim v6 使用说明

这份配置通过 `NVIM_APPNAME=AstroNvim` 使用，不要直接运行 `nvim`。

日常启动：

```shell
nv
# 或
nvim-astro
```

`~/.config/AstroNvim` 是指向本目录的符号链接，插件数据在 `~/.local/share/AstroNvim`。`<Leader>` 是空格。

## 打开这份说明

在已经启动的 Neovim 里，按 `<Leader>?`，或执行 `:ConfigHelp`。会在内置终端里用 [glow](https://github.com/charmbracelet/glow) 打开本文件，再按一次可以关掉。

本机需要已安装 `glow`（当前用 Homebrew 安装即可）。如果找不到命令，会给出提示。

查看当前所有快捷键，也可以按 `<Leader><Space>`。

## AI 功能

AI 默认关闭，每次新开 Neovim 都需要手动打开一次，只对当前这次会话生效。

- 打开或关闭：`<Leader>at`，或执行 `:AIToggle`
- 也可以用 `:AIEnable` / `:AIDisable`

打开之前，按其它 AI 快捷键会提示先打开，不会自动加载插件。打开后才会启用 Copilot 补全，并允许使用下面的功能。

第一次用 Copilot 如果还没登录，打开 AI 后再执行：

```vim
:Copilot auth
```

### AI 快捷键

下列快捷键都要在 AI 已打开后才有效（开关本身除外）。

| 按键 | 作用 |
| --- | --- |
| `<Leader>at` | 打开或关闭本次会话的 AI |
| `<Leader>ah` | CodeCompanion 聊天 |
| `<Leader>ai` | CodeCompanion 行内助手 |
| `<Leader>ap` | CodeCompanion 动作面板 |
| `<Leader>aa` | 普通模式：AiChat；可视模式：把选区加入 CodeCompanion |
| `<Leader>ac` / `<Leader>co` | Codex 弹窗 |
| `<Leader>aC` | Codex 命令行终端 |
| `<Leader>al` | Claude Code |
| `<Leader>ab` | 把当前文件加入 Claude Code |
| `<Leader>as` | 可视模式：把选区发给 Claude Code |
| `<Leader>ay` / `<Leader>an` | 接受 / 拒绝 Claude 的 diff |
| `<Leader>am` | 选择 Claude 模型 |
| `<Leader>ao` | OpenCode |
| `<Leader>ae` | 让 OpenCode 解释当前代码 |
| `<Leader>ak` | 向 OpenCode 提问 |
| `<Leader>ag` / `<Leader>aq` | Gemini / Qwen 命令行（本机没有对应命令时会提示） |

## 常用快捷键

| 按键 | 作用 |
| --- | --- |
| `<Leader>?` | 用 glow 打开这份使用说明 |
| `<Leader><Space>` | 搜索全部快捷键 |
| `<C-s>` / `<Leader>fs` | 保存文件 |
| `<Leader>ja` / `<Leader>jj` | Flash 跳转 |
| `<Leader>jt` | Flash Treesitter 跳转 |
| `<Leader>js` | 跳转到符号 |
| `<Leader>bn` | 新标签页 |
| `<Leader>bD` | 挑选并关闭缓冲区 |
| `<Leader>bQ` | 强制关闭当前缓冲区 |
| `<Leader>wh` / `<Leader>wj` / `<Leader>wk` / `<Leader>wl` | 窗口移动（左 / 下 / 上 / 右） |
| `<Leader>wv` / `<Leader>ws` | 垂直 / 水平分屏 |
| `<Leader>wq` | 关闭窗口 |
| `<Leader>wm` | 最大化当前窗口 |
| `<Leader>wt` | Trouble 诊断列表 |
| `<Leader>wu` | Undotree |
| `<Leader>ccc` / `<Leader>ccy` / `<Leader>cca` | 复制当前行 / 复制 / 复制全文 |
| `<Leader>ddd` | 删除当前行 |
| `<Leader>ddp` / `<Leader>ddP` | 删除段落 |
| `<Leader>dda` | 删除全文 |
| `<Leader>ddb` | 删除引号内的内容 |

剪贴板使用 Neovim 内置 OSC52。在远程或 tmux 里如果复制异常，再检查一下终端是否允许 OSC52。

保存时格式化走 `conform.nvim`，没有对应格式化器时再回退到 LSP。Lint 使用 `nvim-lint`。

## 更新插件

在 `nv` 或 `nvim-astro` 里执行两次 `:Lazy update` 或 `:AstroUpdate`，然后执行 `:TSUpdate`。不要直接运行普通的 `nvim` 来更新。
