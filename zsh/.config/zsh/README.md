# ZSH 配置文档

一个高性能、模块化的 ZSH 配置系统，支持智能缓存和按需加载。

## 🚀 特性

- **🎯 智能条件加载** - 只加载已安装工具的配置模块
- **⚡ 高性能缓存** - 网络检查和版本扫描结果缓存
- **🔧 模块化设计** - 各语言和工具独立配置
- **📊 性能监控** - 内置启动时间测量和优化工具
- **🌍 国际化支持** - 自动检测地区并配置镜像源

## 📁 文件结构

```
.config/zsh/
├── README.md              # 使用文档
├── index.zsh              # 主入口文件
├── config.zsh             # 基础环境配置
├── function.zsh           # 通用函数库
├── alias.zsh              # 命令别名
├── utils.zsh              # 性能工具
├── variables_example.zsh  # 变量模板
│
├── # 核心模块
├── completion.zsh         # 命令补全
├── starship.zsh           # 提示符配置
├── shell.zsh              # Shell 工具
├── help.zsh               # 帮助系统
│
├── # 编程语言模块
├── python.zsh             # Python 环境
├── node.zsh               # Node.js/npm
├── golang.zsh             # Go 语言
├── rust.zsh               # Rust 环境
├── java.zsh               # Java 环境
├── cc.zsh                 # C/C++ 工具
│
├── # 专业工具模块
├── docker.zsh             # Docker 配置
├── nix.zsh                # Nix 包管理器
├── cuda.zsh               # CUDA 开发
├── wasm.zsh               # WebAssembly
├── ros.zsh                # ROS 机器人
│
└── # 平台特定模块
    ├── config.macos.zsh   # macOS 配置
    ├── config.linux.zsh   # Linux 配置
    └── config.wsl.zsh     # WSL 配置
```

## 🛠️ 安装与配置

### 1. 基础安装

```bash
# 克隆配置到指定目录
export ZSH_CONF_DIR="$HOME/.config/zsh"

# 在 ~/.zshrc 中添加
source "$ZSH_CONF_DIR/index.zsh"
```

### 2. 敏感信息配置

本配置支持从外部仓库加载敏感信息，推荐的目录结构：

```bash
# 推荐结构 - 敏感信息独立仓库
~/
├── .config/zsh/           # 主配置仓库 (公开)
└── .config/secrets/       # 敏感信息仓库 (私有)
    ├── zsh_variables.zsh  # ZSH 敏感变量
    ├── api_tokens.zsh     # API 令牌
    └── proxy_config.zsh   # 代理配置
```

#### 必需的敏感信息配置

在你的敏感信息仓库中创建 `zsh_variables.zsh` 文件：

```bash
# 🔐 敏感配置文件 (独立仓库)
# 路径: ~/.config/secrets/zsh_variables.zsh

# === 网络代理配置 ===
export _proxy="http://127.0.0.1:7890"
export _gproxy="http://127.0.0.1:7890"

# === GitHub API Token (可选但推荐) ===
# 用于提高 GitHub API 访问限制，获取地址: https://github.com/settings/tokens
export GHHH_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# === 开发工具配置 ===
export USE_VCPKG="OFF"

# === 镜像源配置 (中国用户可选) ===
# 如果在中国，可以配置加速源
# export RUSTUP_DIST_SERVER="https://mirrors.tuna.tsinghua.edu.cn/rustup"
# export NODEJS_ORG_MIRROR="https://npm.taobao.org/mirrors/node"

# === 自定义路径 ===
# 根据你的环境调整
# export GOPATH="$HOME/go"
# export JAVA_HOME="/usr/lib/jvm/java-11-openjdk"

# === SSH 和 GPG 配置 ===
# export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
# export GPG_TTY=$(tty)
```

#### 在主配置中加载敏感信息

在你的 `~/.zshrc` 中添加：

```bash
# 设置配置目录
export ZSH_CONF_DIR="$HOME/.config/zsh"

# 加载敏感信息 (如果存在)
[[ -f "$HOME/.config/secrets/zsh_variables.zsh" ]] && 
    source "$HOME/.config/secrets/zsh_variables.zsh"

# 加载主配置
source "$ZSH_CONF_DIR/index.zsh"
```

#### 安全最佳实践

1. **分离仓库**: 敏感信息使用独立的私有仓库
2. **权限控制**: 确保敏感文件权限为 600
   ```bash
   chmod 600 ~/.config/secrets/zsh_variables.zsh
   ```
3. **备份策略**: 敏感仓库使用加密备份
4. **定期轮换**: 定期更换 API Token 等凭据

### 3. 防止意外进入 Emacs 模式

配置已强制使用 vi 模式，避免 Home/End 等键意外触发 emacs 模式：

```bash
# 已在 keymap.zsh 中配置
bindkey -v              # 强制 vi 模式  
export KEYTIMEOUT=1     # 快速键超时
# 安全的 Home/End 键绑定
```

### 4. 首次使用

```bash
# 重新加载配置
source ~/.zshrc

# 预热缓存（推荐）
zsh-warmup

# 检查启动性能
zsh-bench
```

## ⚡ 性能优化

### 缓存系统

配置使用智能缓存系统减少启动时间：

- **地区检查缓存**: 24小时TTL，避免重复网络请求
- **Python版本缓存**: 1小时TTL，避免重复文件系统扫描
- **工具检测缓存**: 自动检测已安装的开发工具

### 性能监控命令

```bash
# 测量启动时间
zsh-bench

# 查看缓存状态
zsh-cache

# 清理所有缓存
zsh-clear

# 预热缓存
zsh-warmup

# 性能优化建议
zsh-tips
```

### 性能指标

| 操作 | 优化前 | 优化后 | 提升 |
|------|--------|--------|------|
| 地区检查 | ~2000ms | ~5ms | 99.7% |
| Python版本扫描 | ~50ms | ~2ms | 96% |
| fnm初始化 | ~100ms | ~50ms | 50% |
| 模块加载 | 全部加载 | 按需加载 | 40-60% |

## 🔧 主要功能

### 网络代理管理

```bash
# 设置代理 (新函数名)
proxy_enable http://127.0.0.1:7890

# 从DNS TXT记录设置代理
setpx_with_dns your-proxy-domain.com

# 测试连接
test_connectivity

# 取消代理
proxy_disable

# 查看代理状态
show_proxy_status

# 兼容别名 (推荐使用新函数名)
setpx http://127.0.0.1:7890     # 等同于 proxy_enable
unsetpx                        # 等同于 proxy_disable  
testconn                       # 等同于 test_connectivity
printpx                        # 等同于 show_proxy_status
```

### 智能包管理系统

配置自动检测平台和包管理器，优先使用原生包管理器：

```bash
# 智能工具安装 - 自动选择最佳安装方法
install_smart_tool fnm           # Node.js 版本管理器
install_smart_tool rustup        # Rust 工具链
install_smart_tool docker        # Docker 容器
install_smart_tool uv            # Python 包管理器
install_smart_tool pyenv         # Python 版本管理器

# 查看当前平台推荐的安装方法
install-guide

# 通用包安装
pki package_name                 # 等同于 install_with_manager
install_with_manager package    # 使用检测到的包管理器安装
```

### 🌟 ARM64 架构智能支持

配置系统支持完整的 ARM64/AArch64 架构，包含智能下载和多层回退机制：

#### 🔧 **核心特性**

- **智能架构检测**: 自动识别 `aarch64`, `arm64`, `armv8` 等变体
- **多层回退策略**: GitHub API → 架构变体 → GitHub代理 → 传统方法
- **项目适配**: 支持不同项目的架构命名习惯

#### 🚀 **架构命名映射**

不同项目使用不同的 ARM64 命名约定：

| 项目类型 | 主要命名 | 备选命名 | 示例项目 |
|---------|----------|----------|----------|
| **Rust** | `aarch64-unknown-linux-gnu` | `aarch64-unknown-linux-musl` | rustup, ripgrep, fd |
| **Go** | `arm64` | `aarch64` | golang releases |
| **Node.js** | `arm64` | `aarch64` | node.js releases |
| **GitHub Actions** | `arm64` | `aarch64` | gh-cli, act |
| **系统工具** | `aarch64` | `arm64` | 系统级别工具 |

#### 🛠️ **智能下载函数**

```bash
# 智能架构检测
get_cpu_arch                     # 获取标准化架构名
get_arch_variants               # 获取所有可能的架构变体

# 智能下载 - 自动处理架构适配
smart_download_tool helix       # 自动选择正确的 ARM64 变体
download_with_arch_fallback <url_pattern> <tool_name>

# 批量工具安装 - ARM64 优化
install_modern_tools_by_download # 智能批量安装，全架构支持
install_smart_tool_direct <tool> # 直接安装，自动处理架构
```

#### 🔄 **多层回退机制**

1. **GitHub API 查询**: 首先通过 API 获取 release 信息
2. **架构变体尝试**: 依次尝试 `aarch64`, `arm64`, `armv8` 等变体
3. **GitHub 代理**: 使用 ghproxy.com 等镜像站点
4. **传统方法**: 回退到包管理器或官方安装脚本

#### ⚡ **性能优化**

- **缓存机制**: 架构检测结果缓存，避免重复计算
- **并行下载**: 支持并发检测多个架构变体
- **网络优化**: 在中国自动使用镜像加速

#### 📖 **使用示例**

```bash
# 检查系统架构
get_cpu_arch                    # 输出: aarch64 (或 x86_64, arm64 等)

# 获取架构变体
get_arch_variants              # 输出: aarch64 arm64 armv8 等

# 智能安装工具 (自动处理 ARM64)
install_smart_tool helix       # 自动检测 ARM64 并下载合适版本
install_smart_tool ripgrep     # 支持 Rust 项目的复杂架构名

# 批量安装现代工具
install_modern_tools_by_download  # 一键安装所有工具，全架构支持

# 手动下载特定架构
download_with_arch_fallback \
  "https://github.com/helix-editor/helix/releases/download/*/helix-*-{arch}-*.tar.xz" \
  "helix"
```

#### 🔍 **故障排除**

```bash
# 检查架构检测
get_cpu_arch && echo "架构检测正常"

# 查看支持的架构变体
get_arch_variants

# 测试下载函数
smart_download_tool --dry-run helix  # 预览下载URL，不实际下载

# 详细日志模式
export SMART_DOWNLOAD_DEBUG=1
install_smart_tool ripgrep          # 查看详细的下载尝试过程
```

参考完整文档: [`ARCHITECTURE_SUPPORT.md`](./ARCHITECTURE_SUPPORT.md)

### 平台特定优化

#### macOS (Homebrew)
- ✅ fnm, rustup-init, go, docker, pyenv, uv, black
- 🔧 自动使用 `brew install` 或 `brew install --cask`

#### Arch Linux (Pacman/AUR)  
- ✅ fnm-bin, rustup, go, docker, pyenv, uv, python-black
- 🔧 优先使用 `pacman -S`，AUR 包通过 `yay` 安装

#### Ubuntu/Debian/CentOS
- 🔄 回退到官方安装脚本或传统方法
- 📦 保持现有的 apt/yum/dnf 兼容性

### 传统开发工具管理

```bash
# Python工具
pipi package_name          # 使用清华源安装
pipgi package_name         # 用户安装
install_python_tools       # 安装开发工具集
install_pythontools_uv     # 智能安装 uv

# Node.js工具
install_fnm                # 智能安装 fnm
install_node               # 安装最新LTS

# Rust工具
install_rustup             # 智能安装 Rust
install_rust_tools         # 安装工具链
cargo_install package      # 智能安装

# Docker工具
install_docker_smart       # 智能安装 Docker
install_docker_lsp         # Docker 语言服务器

# 批量安装工具
install_batch_modern        # 智能批量安装现代工具
install_batch_release       # 传统批量安装
```

### 系统工具

```bash
# 文件操作
mc dir_name                # 创建并进入目录
copypath [file]            # 复制当前路径/文件路径
copyfile file              # 复制文件内容

# 网络工具
hostip                     # 获取本机IP
wanip                      # 获取公网IP
check_in_china             # 检测是否在中国

# 安全工具
sec-audit                  # 完整安全审计
sec-check                  # 环境变量安全检查
sec-fix                    # 修复文件权限问题

# 帮助系统
show_help                  # 显示帮助系统概览
show_functions [category]  # 显示函数文档
search_functions <keyword> # 搜索函数
show_readme [section]      # 显示 README 文档
```

## 📚 智能帮助系统

配置内置了强大的帮助系统，可以快速查找和了解所有可用函数：

### 🔍 **主要功能**

```bash
# 显示帮助系统概览
show_help

# 查看所有函数文档
show_functions

# 按分类查看函数 (install|config|check|network|tool|security|cache)
show_functions install     # 查看安装相关函数
show_functions network     # 查看网络相关函数

# 搜索函数
search_functions docker    # 搜索包含 'docker' 的函数
search_functions proxy     # 搜索代理相关函数

# 查看 README 文档
show_readme                # 显示完整 README
show_readme "安装与配置"    # 显示特定章节
```

### 🏷️ **函数分类**

- `install` - 安装相关函数 (install_smart_tool, install_batch_modern 等)
- `config` - 配置相关函数 (setup_*, config_* 等)
- `check` - 检查验证函数 (get_package_manager, validate_* 等)
- `network` - 网络代理函数 (proxy_enable, test_connectivity 等)
- `tool` - 工具辅助函数 (show_help, search_functions 等)
- `security` - 安全相关函数 (security_audit, validate_url 等)
- `cache` - 缓存相关函数 (cache_*, clear_zsh_cache 等)

### 💡 **快捷别名**

```bash
help                      # 等同于 show_help
docs                      # 等同于 show_readme
funcs                     # 等同于 show_functions
search-func <keyword>     # 等同于 search_functions
```

### 📝 **函数文档格式**

所有函数都使用统一的文档格式：

```bash
##
# @brief 函数的简短描述
# @description 详细描述 (可选)
# @param $1 参数说明
# @return 返回值说明
# @example function_name arg1 arg2
# @category 功能分类
##
function_name() {
    # 函数实现
}
```

## 📦 模块说明

### 条件加载模块

以下模块只在检测到相应工具时加载：

- `docker.zsh` - 检测到 docker 命令时加载
- `golang.zsh` - 检测到 go 命令或 /usr/local/go 目录
- `python.zsh` - 检测到 python3 命令时加载
- `rust.zsh` - 检测到 cargo 命令或 ~/.cargo 目录
- `node.zsh` - 检测到 node/fnm 时加载

### 核心模块

以下模块总是加载：

- `config.zsh` - 基础环境变量和PATH配置
- `function.zsh` - 通用函数库
- `alias.zsh` - 命令别名
- `completion.zsh` - 命令补全
- `utils.zsh` - 性能工具

## 🎨 自定义配置

### 添加新模块

1. 创建新的 `.zsh` 文件
2. 在 `index.zsh` 中添加条件加载：

```bash
_conditional_source "new_tool.zsh" "command -v new_tool >/dev/null 2>&1"
```

### 自定义缓存

在你的模块中使用缓存模式：

```bash
_cache_function() {
  local _cache_file="$HOME/.cache/zsh_your_cache"
  local _cache_ttl=3600  # 1小时
  
  # 检查缓存
  if [[ -f "$_cache_file" ]]; then
    local _cache_time=$(stat -f %m "$_cache_file" 2>/dev/null || stat -c %Y "$_cache_file" 2>/dev/null)
    local _current_time=$(date +%s)
    
    if [[ $((_current_time - _cache_time)) -lt $_cache_ttl ]]; then
      cat "$_cache_file"
      return 0
    fi
  fi
  
  # 生成新数据并缓存
  local result=$(expensive_operation)
  echo "$result" > "$_cache_file"
  echo "$result"
}
```

## 🔍 故障排除

### 常见问题

1. **启动缓慢**
   ```bash
   zsh-bench  # 检查启动时间
   zsh-clear  # 清理缓存
   ```

2. **命令不存在**
   ```bash
   # 检查模块是否被加载
   echo $ZSH_CONF_DIR
   ls -la $ZSH_CONF_DIR
   ```

3. **代理设置问题**
   ```bash
   printpx    # 检查当前代理
   testconn   # 测试连接
   ```

4. **安全配置问题**
   ```bash
   sec-audit  # 运行安全审计
   sec-check  # 检查环境变量安全
   sec-fix    # 修复文件权限
   ```

5. **意外进入 Emacs 模式**
   ```bash
   # 如果仍然出现问题，手动重置
   bindkey -v  # 强制 vi 模式
   # 检查是否有冲突的按键绑定
   bindkey | grep emacs
   ```

### 调试模式

```bash
# 启用详细输出
set -x
source ~/.zshrc
set +x
```

### 缓存位置

所有缓存文件位于 `~/.cache/zsh_*`：

```bash
ls -la ~/.cache/zsh_*
```

## 📚 更多信息

### 相关文档

- [ZSH 官方文档](https://zsh.sourceforge.io/Doc/)
- [Starship 提示符](https://starship.rs/)
- [FNM Node 管理器](https://github.com/Schniz/fnm)

### 贡献指南

1. Fork 本项目
2. 创建功能分支
3. 提交更改
4. 发起 Pull Request

## 📄 许可证

MIT License

## 🙏 致谢

感谢所有开源项目和贡献者的支持。

---

*最后更新: 2025-05-29*

---

## 🏗️ 架构支持

本配置系统经过优化，全面支持多种系统架构：

- **✅ x86_64**: Intel/AMD 64位处理器完全支持
- **✅ ARM64/AArch64**: Apple Silicon, ARM服务器, 树莓派等 ARM64 设备完全支持
- **✅ 智能架构适配**: 自动检测并下载适配当前架构的工具版本
- **✅ 多层回退机制**: 确保在各种网络环境下都能成功安装工具

参考完整的架构支持文档: [`ARCHITECTURE_SUPPORT.md`](./ARCHITECTURE_SUPPORT.md)

## 🪟 MSYS2 Windows 支持

本配置系统现已完全支持 **MSYS2** 环境，为 Windows 用户提供完整的 Unix-like 开发体验：

### 🎯 **核心特性**

- **🔧 智能环境检测**: 自动识别 MSYS2 环境并应用特定配置
- **📦 包管理集成**: 完整支持 MSYS2 pacman 包管理器
- **🛠️ 开发工具链**: 一键安装完整的开发环境
- **🏗️ Windows 集成**: 与 Windows 系统深度集成

### 🚀 **快速开始**

在 MSYS2 终端中：

```bash
# 检查 MSYS2 环境信息
show_msys2_info

# 一键配置开发环境
msys2_quick_setup

# 安装现代命令行工具
msys2_modern_tools

# 安装特定编程语言工具
install_msys2_language_tools python
install_msys2_language_tools node
```

### 📦 **包管理支持**

```bash
# 使用智能包管理器（自动检测 MSYS2 pacman）
install_with_manager git curl

# 直接使用 MSYS2 包安装
install_msys2_packages base-devel mingw-w64-x86_64-toolchain

# 安装开发工具
install_msys2_dev_tools

# 安装现代工具
install_msys2_modern_tools
```

### 🛠️ **支持的工具**

#### 开发工具链
- **base-devel**: 基础开发工具
- **mingw-w64-x86_64-toolchain**: MinGW-w64 工具链
- **cmake, ninja**: 构建系统
- **git, curl, wget**: 版本控制和网络工具

#### 现代命令行工具
- **ripgrep (rg)**: 更快的 grep
- **fd**: 更快的 find  
- **bat**: 更好的 cat
- **eza**: 更好的 ls
- **fzf**: 模糊查找
- **bottom**: 系统监控

#### 编程语言
- **Python**: 完整 Python 开发环境
- **Node.js**: JavaScript 运行时和 npm
- **Go**: Go 编程语言
- **Rust**: 通过 rustup 安装

### 🔧 **Windows 集成功能**

```bash
# Windows 路径快捷访问
cdwin          # 进入 Windows 用户目录
cddocs         # 进入文档目录  
cddesk         # 进入桌面
cddown         # 进入下载目录

# 启动 Windows 程序
notepad file.txt     # 打开记事本
explorer .           # 打开文件资源管理器
code .               # 打开 VS Code (如已安装)
```

### 🏗️ **架构特定支持**

MSYS2 环境下的架构检测和工具下载：

- **Windows-specific naming**: 支持 `x86_64-pc-windows-msvc`, `win64` 等命名
- **智能下载回退**: 优先尝试 Windows 版本，回退到通用版本
- **包管理器优先**: 优先使用 MSYS2 pacman，回退到直接下载

### 📋 **系统要求**

- **MSYS2**: 最新版本的 MSYS2 环境
- **ZSH**: 在 MSYS2 中安装 zsh (`pacman -S zsh`)
- **网络访问**: 用于下载软件包和工具

### 🔍 **故障排除**

```bash
# 检查环境状态
show_msys2_info

# 更新包数据库
pacman -Sy

# 清理缓存
clear_zsh_cache

# 重新配置环境
msys2_quick_setup
```

### 💡 **最佳实践**

1. **定期更新**: 运行 `pacman -Syu` 保持系统最新
2. **使用 mintty**: 推荐使用 mintty 终端获得最佳体验  
3. **路径管理**: 避免路径中包含空格和特殊字符
4. **权限设置**: 某些操作可能需要管理员权限

MSYS2 支持让 Windows 用户也能享受完整的 Unix-like 开发体验！