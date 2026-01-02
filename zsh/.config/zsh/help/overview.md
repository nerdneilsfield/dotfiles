# ZSH 配置概览

本文件是 `zsh/.config/zsh` 的整体功能说明与加载结构摘要，便于快速理解项目全貌。

## 总览

- **入口**：`index.zsh` 是统一加载入口，按平台与工具存在性进行条件加载。
- **核心模块**：别名、函数库、提示符、基础配置、补全、Shell 辅助与帮助系统等。
- **按需模块**：语言/工具链模块（Python/Go/Rust/Node/Java 等）、专业领域（CUDA/ROS/FPGA 等）。
- **平台适配**：macOS / Linux / MSYS2/WSL 的差异化配置。
- **工具安装体系**：智能包管理器 + 架构适配下载 + 批量安装。
- **导航系统**：优先 zoxide，回退 z.lua。
- **帮助系统**：函数文档解析 + README 分段阅读 + 自定义帮助文档。

## 加载顺序与策略（index.zsh）

1) **平台配置**
- `config.macos.zsh` / `config.linux.zsh` / `config.msys2.zsh`

2) **核心模块（始终加载）**
- `alias.zsh`：命令别名
- `function.zsh`：通用函数库
- `starship.zsh`：提示符配置
- `config.zsh`：环境变量、PATH、历史与基础设置
- `completion.zsh`：补全
- `shell.zsh`：Shell 工具
- `help.zsh`：轻量帮助入口
- `ai.zsh`：AI CLI 安装/更新

3) **按工具存在性加载**
- `docker.zsh` / `golang.zsh` / `rust.zsh` / `python.zsh` / `node.zsh` / `java.zsh` / `nix.zsh`

4) **专业环境**
- `cc.zsh` / `cuda.zsh` / `wasm.zsh` / `zig.zsh`
- `hdl.zsh` / `xilinx.zsh` / `ros.zsh` / `robotics.zsh`

5) **始终加载的基础系统**
- `html.zsh`：Web 相关轻量工具
- `security.zsh`：安全检查/审计
- `navigation.zsh`：智能跳转
- `package_manager.zsh`：智能包管理
- `help_system.zsh`：高级帮助系统

> 说明：`utils.zsh` 在入口中被注释，属于可选性能工具模块。

## 核心配置与环境（config.zsh）

- **编辑器与语言环境**：`EDITOR/VISUAL/GIT_EDITOR/LANG`
- **路径管理**：统一追加常用工具目录
- **历史与补全设置**：历史共享、去重、大小写补全
- **基础目录创建**：如 `$HOME/.local/bin`、`$HOME/Source/*`

## 功能模块说明

### 1) 智能包管理（package_manager.zsh）
- 自动检测系统包管理器：`brew/pacman/yay/apt/dnf/yum`
- 统一安装入口：`install_with_manager` / `install_smart_tool`
- 针对开发工具（fnm/rustup/docker/uv 等）提供最佳路径

### 2) 智能下载与架构适配（tools.zsh / utils.zsh）
- 统一处理 CPU 架构、下载源、回退逻辑
- 支持批量工具安装与智能适配（ARM64、MSYS2 等）
- `install_modern_tools_by_download` / `install_modern_tools_by_eget`

### 3) 导航系统（navigation.zsh）
- **首选 zoxide**：自动初始化、补全与别名
- **回退 z.lua**：无 zoxide 时自动启用
- 提供 `z/za/zr/zq/zl` 等快捷命令

### 4) 帮助系统（help.zsh / help_system.zsh / help/*）
- `show-help`：选择并展示 `help/*.md`、`help/tools/*.md`、`help/commands/*.md`
- `show_help`：增强帮助系统（函数文档解析、README 分段阅读）
- `help/tools.md`：工具总览；`help/tools/*.md`：工具细化
- `help/commands/*.md`：Linux 常用命令速查

### 5) 安全与诊断（security.zsh）
- 安全审计、环境变量检查、权限修复等工具

### 6) AI CLI 工具（ai.zsh）
- 安装/更新 `codex/claude-code/gemini-cli/qwen-code`
- `aichat` 安装入口

### 7) 语言与工具链
- 各语言模块提供版本管理、工具链安装与别名
- 对应文件：`python.zsh` / `node.zsh` / `golang.zsh` / `rust.zsh` / `java.zsh` 等

## 帮助文档结构

- `help/overview.md`（本文件）
- `help/tools.md` + `help/tools/*.md`（工具说明）
- `help/commands/*.md`（系统命令速查）
- `help/vim.md` / `help/emacs.md` / `help/helix.md`
- `help/keymap.md`（zsh 快捷键）

## 可选/未默认加载的模块

- `keymap.zsh`：键位与编辑器绑定（如需启用可在 `index.zsh` 或 `.zshrc` 中手动 `source`）
- `utils.zsh`：性能与缓存工具（入口中默认注释）

## 敏感信息建议

建议把敏感信息放在独立仓库（例如 `~/.config/zsh_private` 或 `~/private_dotfiles`），并在 `~/.zshrc` 中加载。
本机还存在 `~/.zsh_local` 用于本地覆盖配置。

## 快速上手

- `show-help`：查看所有帮助文档
- `show_help`：高级帮助系统入口
- `install_smart_tool <tool>`：智能安装工具
- `install_modern_tools_by_eget local`：批量安装 CLI 工具到 `~/.local`
