# PowerShell 现代工具链配置

[![PowerShell](https://img.shields.io/badge/PowerShell-7.x-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D4.svg)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> 将 PowerShell 配置打造成媲美现代 ZSH 的高效命令行环境，深度集成 Scoop、WSL、Windows 特性和现代 CLI 工具。

## ✨ 特性

- 🚀 **高性能启动** - 智能条件加载，缓存优化，目标启动时间 < 300ms
- 📦 **模块化设计** - 清晰的目录结构，按需加载
- 🔧 **现代工具集成** - Scoop 包管理、eza、zoxide、fzf、ripgrep、fd 等
- ⭐ **Starship 提示符** - 现代化、快速、可定制的提示符
- 🎯 **智能补全** - PSReadLine 增强，fzf 集成，预测性 IntelliSense
- 📊 **性能监控** - 启动时间测量，性能诊断工具
- 🌐 **跨平台支持** - Windows PowerShell 和 PowerShell Core
- 🛠️ **开发者友好** - Git 集成、项目脚手架、智能路径导航

## 🚀 快速安装

### 方法一：使用安装脚本（推荐）

```powershell
# 1. 以管理员身份运行 PowerShell
# 2. 进入配置目录
cd /path/to/dotfiles/windows-powershell

# 3. 运行安装脚本
.\install.ps1

# 4. 安装现代工具套装 (可选但推荐)
Install-ToolSuite Essential
```

安装脚本会自动：
- 创建必要的目录结构
- 建立软链接到配置文件
- 设置缓存和私有配置目录
- 检查和报告安装状态

### 方法二：手动安装

```powershell
# 创建配置目录
New-Item -ItemType Directory -Path "$env:USERPROFILE\.config\powershell" -Force

# 创建软链接
New-Item -ItemType SymbolicLink -Path $PROFILE -Target "path\to\dotfiles\windows-powershell\Microsoft.PowerShell_profile.ps1"
New-Item -ItemType Junction -Path "$env:USERPROFILE\.config\powershell\modules" -Target "path\to\dotfiles\windows-powershell\modules"
```

### 后续步骤

```powershell
# 重启 PowerShell 或重新加载配置
. $PROFILE

# 检查安装状态
Get-PWShHelp
Get-ScoopStatus
Get-NavigationStatus

# 安装推荐的现代工具
Install-ToolSuite Essential
Install-Starship
New-StarshipConfig -Template Developer
```

## 📁 目录结构

```
windows-powershell/
├── Microsoft.PowerShell_profile.ps1     # 主配置文件
├── install.ps1                          # 安装脚本
├── TODO.md                              # 开发计划和进度
├── modules/                              # 模块目录
│   ├── core/                            # 核心模块
│   │   ├── config.ps1                   # 基础配置和环境设置
│   │   ├── aliases.ps1                  # Unix-like 别名
│   │   ├── functions.ps1                # 通用函数库
│   │   └── completion.ps1               # PSReadLine 和智能补全
│   ├── tools/                           # 现代工具集成
│   │   ├── scoop.ps1                    # Scoop 包管理器包装
│   │   ├── navigation.ps1               # eza + zoxide + fzf 导航
│   │   ├── starship.ps1                 # Starship 提示符管理
│   │   ├── git.ps1                      # Git 工具增强
│   │   ├── docker.ps1                   # Docker 支持
│   │   ├── development.ps1              # 开发环境管理
│   │   ├── node.ps1                     # Node.js 工具
│   │   ├── python.ps1                   # Python 工具
│   │   └── rust.ps1                     # Rust 工具
│   ├── platform/                        # 平台特定
│   │   ├── windows.ps1                  # Windows 特性
│   │   └── wsl.ps1                      # WSL 深度集成
│   └── performance/                      # 性能工具
│       └── benchmark.ps1                # 性能测试和优化
└── README.md                            # 说明文档
```

## 🔧 主要功能

### 🔨 Scoop 包管理器集成

```powershell
# 智能工具安装和管理
Install-ScoopTool git fd ripgrep eza fzf zoxide bat starship
Install-ToolSuite Essential              # 安装基础工具套装
Install-DevEnvironment Frontend          # 一键搭建前端开发环境
Update-AllScoopTools                     # 批量更新所有工具
Search-ScoopPackage ripgrep              # 模糊搜索包

# 别名
scoopi <tool>    # 安装工具
scoops <pattern> # 搜索包
scoopu           # 更新所有
scoopst          # 显示状态
```

### 🧭 现代文件导航 (eza + zoxide + fzf)

```powershell
# eza 文件列表增强
ll              # 详细列表，带图标和 Git 状态
la              # 显示所有文件 (包括隐藏)
lt              # 树形显示
lz              # 按大小排序
lr              # 按修改时间排序  
ld              # 只显示目录
lg              # 网格显示

# zoxide 智能跳转
z <pattern>     # 智能跳转到匹配目录
zi              # 交互式目录选择

# fzf 模糊搜索集成
fcd             # fuzzy cd - 递归搜索目录
fopen           # fuzzy 文件打开
fkill           # fuzzy 进程终止  
fhistory        # fuzzy 命令历史搜索
fjump           # 快速跳转常用目录
```

### ⭐ Starship 提示符

```powershell
# Starship 管理
Install-Starship                        # 安装 Starship
New-StarshipConfig -Template Developer  # 创建配置
Edit-StarshipConfig                     # 编辑配置
Test-StarshipConfig                     # 测试配置
Get-StarshipStatus                      # 显示状态

# 别名
starship-config   # 编辑配置
starship-status   # 显示状态
starship-reload   # 重新加载
```

### 🎯 智能补全和快捷键

```powershell
# PSReadLine 增强快捷键
Tab              # 菜单补全
Ctrl+R           # fzf 历史搜索
Ctrl+T           # fzf 文件选择
Alt+C            # fzf 目录跳转
Ctrl+D           # 删除字符或退出
Ctrl+A/E         # 行首/行尾
↑/↓             # 智能历史导航

# 预测性 IntelliSense (PowerShell 7.2+)
# 自动补全建议基于历史和插件
```

### 📁 系统信息和工具

```powershell
# 系统监控
ps              # 进程查看
top             # 系统资源监控 (bottom)
df              # 磁盘使用情况 (duf)
sysinfo         # 详细系统信息
Get-PublicIP    # 获取公网 IP

# 文件操作增强
mkcd <dir>      # 创建并进入目录
touch <file>    # 创建文件或更新时间戳
rm-safe <file>  # 安全删除 (需确认)
cp-tree         # 复制目录树
find-file       # 查找文件
find-dir        # 查找目录

# 文本处理 (现代工具)
grep <pattern>  # 文本搜索 (ripgrep)
wc <file>       # 统计行数/字数
head <file>     # 前几行
tail <file>     # 后几行  
Format-Json     # JSON 格式化

# 开发工具
which <cmd>     # 查找命令位置
curl <url>      # HTTP 请求
wget <url>      # 文件下载
New-Password    # 生成随机密码
Get-Hash        # 计算哈希值
```

### 📊 性能监控和优化

```powershell
# 性能测试
Measure-PowerShellStartup    # 测量启动时间
pwsh-bench                   # 别名

# 缓存管理
Show-PowerShellCacheStatus   # 显示缓存状态
Clear-PowerShellCache        # 清理缓存
Start-PowerShellCacheWarmup  # 预热缓存
pwsh-cache / pwsh-clear      # 别名

# 性能诊断
Test-PowerShellPerformance   # 系统性能诊断
Get-PowerShellOptimizationTips  # 优化建议
pwsh-test / pwsh-tips        # 别名

# 导航工具状态
Get-NavigationStatus         # 检查 eza/zoxide/fzf 状态
Install-NavigationTools      # 安装缺失的导航工具
```

### 🆘 帮助系统

```powershell
Get-PWShHelp      # 显示所有自定义函数
aliases           # 显示所有别名
Get-CompletionStatus      # 补全系统状态
Get-ScoopStatus          # Scoop 状态
Show-StarshipTemplates   # Starship 模板
```

## ⚙️ 配置选项

### 环境变量

```powershell
# 启用调试日志
$env:PWSH_DEBUG = "1"

# 禁用欢迎信息
$env:PWSH_NO_WELCOME = "1"
```

### 私有配置

创建 `~/.config/powershell/private/config.ps1` 文件来添加个人设置：

```powershell
# 个人别名
Set-Alias -Name 'my-command' -Value 'some-command'

# 环境变量
$env:MY_VAR = "value"

# 自定义函数
function My-Function {
    # 你的代码
}
```

## 📊 性能优化

### 启动时间优化技术

1. **智能条件加载** - 只在检测到工具时才加载相应模块
2. **多层缓存机制** - 缓存命令检查、版本信息和配置状态
3. **异步初始化** - 非阻塞的工具初始化过程
4. **最小化 I/O 操作** - 减少文件读取和网络请求
5. **工具可用性检测** - 快速检测和缓存工具安装状态

### 性能目标和实际表现

| 配置级别 | 目标启动时间 | 包含功能 |
|---------|-------------|----------|
| **最小配置** | < 100ms | 基础别名、函数 |
| **标准配置** | < 200ms | + Scoop、导航工具 |
| **完整配置** | < 300ms | + Starship、fzf、所有增强 |
| **开发环境** | < 500ms | + Git、Docker、语言工具 |

### 性能监控和诊断

```powershell
# 启动时间基准测试
Measure-PowerShellStartup              # 5次平均测试
Measure-PowerShellStartup -Iterations 10 -Detailed  # 详细分析

# 缓存和性能管理
Show-PowerShellCacheStatus             # 查看缓存状态
Clear-PowerShellCache                  # 清理过期缓存
Start-PowerShellCacheWarmup            # 预热缓存

# 工具性能检查
Get-NavigationStatus                   # 导航工具状态
```

## 🌟 Phase 2 新功能 (v1.1)

### 🐧 WSL 深度集成

```powershell
# WSL 发行版管理
wstart [distro]         # 启动 WSL 发行版
wstop [distro]          # 停止 WSL 发行版
wstatus                 # 显示 WSL 状态
Get-WSLDistros          # 列出所有发行版

# 路径转换
wpath "C:\Users"        # Windows -> WSL 路径
wslpath "/home/user"    # WSL -> Windows 路径

# 跨平台文件操作
Copy-ToWSL -Source "file.txt" -Destination "/home/user/"
Copy-FromWSL -Source "/home/user/file.txt" -Destination "C:\Temp\"

# 配置同步
wsync git               # 同步 Git 配置到 WSL
wsync zsh               # 同步 ZSH 配置到 WSL
wsync all               # 同步所有配置

# WSL 命令包装器
wsl-ls, wsl-grep, wsl-find, wsl-vim
wsl-git, wsl-docker, wsl-kubectl
```

### 🔍 高级搜索工具集成

```powershell
# 智能文件查找 (fd 增强)
find <pattern>          # 智能文件搜索
find-code <pattern>     # 查找代码文件
find-config <pattern>   # 查找配置文件
Find-Files -Type file -Extension "ps1,py,js"  # 高级过滤

# 高级内容搜索 (ripgrep 增强)
grep <pattern>          # 智能内容搜索
grep-code <pattern>     # 在代码文件中搜索
grep-todo               # 查找 TODO/FIXME 注释
Search-Content -Pattern "error" -Type "ps1" -Context 3

# 模糊搜索 (fzf 集成)
fgrep <query>           # 模糊内容搜索带预览
ffd <query>             # 模糊文件搜索带预览
search                  # 交互式搜索菜单

# 项目分析
Search-ProjectStructure # 分析项目结构和统计
```

### 🌿 Git 工具链增强

```powershell
# Lazygit 集成
lg                      # 启动 Lazygit
lgs -GitDir .git        # 指定 Git 目录启动

# GitHub CLI 集成
pr-create               # 创建 Pull Request
pr-list                 # 列出 PR (支持 fzf)
issue-create            # 创建 Issue

# Git 快捷操作
gco [branch]            # 交互式分支切换
gst                     # 增强的 Git 状态
glog                    # 交互式日志查看
gbr                     # 交互式分支列表
gclean                  # Git 仓库清理

# Git 工作流
Start-GitWorkflow -Type feature -Name "new-feature"
Initialize-GitConfig    # 配置 Git + Delta 集成
```

### 🧠 智能命令路由系统

```powershell
# 智能命令替换 (优先使用现代工具)
sls                     # 智能 ls (eza 优先)
sfind                   # 智能 find (fd 优先)  
sgrep                   # 智能 grep (ripgrep 优先)
scat                    # 智能 cat (bat 优先)

# 项目上下文感知
srun                    # 智能运行 (npm run, cargo run, etc.)
stest                   # 智能测试 (npm test, pytest, etc.)
sbuild                  # 智能构建 (npm build, cargo build, etc.)

# 智能建议系统
suggest                 # 根据当前目录提供建议
Get-ProjectContext      # 分析项目类型和工具
perf                    # 查看命令性能统计
```

### 🌐 跨平台文件操作

```powershell
# 统一的文件操作接口
xmkdir <path>           # 跨平台创建目录
xcp <src> <dest>        # 跨平台文件复制
xmv <src> <dest>        # 跨平台文件移动
xrm <path>              # 跨平台文件删除
xln <target> <link>     # 跨平台符号链接

# 高级文件管理
xstat <file>            # 跨平台文件信息
xchmod <perm> <file>    # 跨平台权限设置
xdf [path]              # 跨平台磁盘使用情况
xwhich <command>        # 跨平台命令查找

# 平台信息
Get-PlatformInfo        # 获取当前平台信息
ConvertTo-CrossPlatformPath  # 路径格式转换
Get-ScoopStatus                        # Scoop 工具状态
Get-CompletionStatus                   # 补全系统状态

# 系统级性能诊断
Test-PowerShellPerformance             # 综合性能测试
Get-PowerShellOptimizationTips         # 优化建议
```

### 调试和优化

```powershell
# 启用详细日志
$env:PWSH_DEBUG = "1"
. $PROFILE  # 重新加载查看详细加载信息

# 分析加载时间
$ProfileStartTime = Get-Date
. $PROFILE
$LoadTime = (Get-Date) - $ProfileStartTime
Write-Host "配置加载耗时: $($LoadTime.TotalMilliseconds)ms"
```

## 🔄 管理命令

### 安装管理

```powershell
# 查看安装状态
.\install.ps1

# 强制重新安装
.\install.ps1 -Force

# 卸载配置
.\install.ps1 -Uninstall
```

### 配置管理

```powershell
# 编辑配置文件
Edit-Profile

# 重新加载配置
Reload-Profile

# 清理缓存
Clear-PowerShellCache
```

## 🚨 故障排除

### 常见问题

1. **启动慢** - 运行 `pwsh-bench` 检查启动时间，使用 `pwsh-tips` 查看优化建议
2. **权限错误** - 确保以管理员身份运行安装脚本
3. **模块加载失败** - 检查模块路径和权限，运行 `$env:PWSH_DEBUG="1"` 启用调试

### 调试模式

```powershell
# 启用详细日志
$env:PWSH_DEBUG = "1"

# 重新加载配置查看日志
. $PROFILE
```

### 重置配置

```powershell
# 卸载现有配置
.\install.ps1 -Uninstall

# 清理缓存
Remove-Item "$env:USERPROFILE\.cache\powershell" -Recurse -Force

# 重新安装
.\install.ps1
```

## 🚀 最新更新 (v1.0-beta)

### ✅ 已完成功能 (Phase 1)

- **Scoop 工具链深度集成** - 智能包管理、工具套装、开发环境一键搭建
- **现代文件导航系统** - eza + zoxide + fzf 三件套完美集成
- **Starship 提示符管理** - 多种模板、可视化配置、智能检测
- **PSReadLine 增强** - fzf 集成、预测性补全、智能快捷键
- **性能优化系统** - 条件加载、多层缓存、启动时间监控

### 🚧 开发中功能 (Phase 2)

参见 [TODO.md](TODO.md) 查看完整开发计划：

- WSL 深度集成和跨平台操作
- Git 工具链增强 (lazygit + delta + gh)
- 搜索工具集成 (fd + ripgrep 增强)
- Windows 特性深度包装
- 容器和云工具支持

## 🤝 贡献指南

1. Fork 本仓库
2. 创建功能分支: `git checkout -b feature/amazing-feature`
3. 提交更改: `git commit -m 'Add amazing feature'`
4. 推送分支: `git push origin feature/amazing-feature`
5. 创建 Pull Request

### 📞 支持和反馈

- **Issues**: 报告 Bug 和请求新功能
- **讨论**: 分享使用经验和最佳实践
- **文档**: 查看 `Get-PWShHelp` 和各模块的内置帮助

## 📄 许可证

MIT License - 详见 LICENSE 文件

---

**最后更新**: 2025-01-29  
**当前版本**: v1.0-beta (Phase 1 完成)  
**下一版本**: v1.1 (Phase 2 开发中)