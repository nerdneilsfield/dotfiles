# PowerShell 现代工具链使用示例

本文档提供 PowerShell 现代工具链的实际使用示例和最佳实践。

## 🚀 快速开始

### 首次使用

```powershell
# 1. 运行设置向导
setup-wizard

# 2. 查看帮助系统
help

# 3. 检查系统状态
syshealth

# 4. 测试开发环境
devcheck
```

## 📁 文件和目录操作

### 现代化文件浏览

```powershell
# 基础文件列表（彩色、图标、Git 状态）
eza
ll        # 详细列表
la        # 包含隐藏文件
lt        # 树形显示
lz        # 按大小排序
lr        # 按时间排序

# 高级选项
eza -la --git --header    # 完整信息
eza -T -L 3               # 3层深度树形显示
eza --group-directories-first  # 目录优先
```

### 智能目录导航

```powershell
# zoxide 智能跳转
z docs          # 跳转到包含 docs 的最常用目录
z pro src       # 跳转到路径中包含 pro 和 src 的目录
zi              # 交互式目录选择

# 传统目录操作的现代化替代
cd $(fzf --preview 'eza --tree --level=2 {}')  # fzf 选择目录
```

### 文件搜索和查找

```powershell
# 快速文件查找
find config     # 查找包含 config 的文件
find *.ps1      # 查找 PowerShell 脚本
find-code api   # 在代码文件中查找 api

# 高级搜索
fd "\.ps1$" --type f --exec echo "PowerShell file: {}"
fd "test" --type d   # 查找包含 test 的目录
fd . --changed-within 1week  # 一周内修改的文件
```

### 内容搜索

```powershell
# 基础内容搜索
grep "function"     # 查找包含 function 的行
grep-code "TODO"    # 在代码文件中查找 TODO
grep-todo           # 查找所有 TODO/FIXME 注释

# 高级搜索选项
rg "function \w+" --type ps1     # 在 PS1 文件中查找函数定义
rg "error" -A 3 -B 3             # 显示匹配行的前后3行
rg "config" --json | jq .        # JSON 格式输出
```

## 🔍 交互式搜索工作流

### 模糊搜索集成

```powershell
# 文件模糊搜索
ffd "ps1"       # 模糊搜索 PS1 文件并预览
ffd             # 搜索所有文件

# 内容模糊搜索
fgrep "function"  # 模糊搜索内容并预览
fgrep            # 搜索所有内容

# 交互式搜索菜单
search          # 启动交互式搜索界面
```

### 历史命令搜索

```powershell
# fzf 历史搜索（Ctrl+R）
# 输入关键词，实时过滤历史命令

# 高级历史操作
Get-History | Out-GridView -PassThru | Invoke-Expression
```

## 🌿 Git 工作流

### 基础 Git 操作

```powershell
# Lazygit TUI
lg              # 启动 Lazygit
lgs             # 简化模式启动

# 快速 Git 操作
gst             # Git 状态（彩色输出）
gco main        # 切换到 main 分支
gco -           # 切换到上一个分支
glog            # 交互式日志查看
gbr             # 交互式分支列表
```

### GitHub 集成

```powershell
# Pull Requests
pr-create       # 创建 PR
pr-list         # 列出 PRs（支持 fzf 选择）
gh pr view      # 查看当前 PR

# Issues
issue-create    # 创建 Issue
gh issue list   # 列出 Issues
```

### Git 工作流示例

```powershell
# 功能开发工作流
Start-GitWorkflow -Type feature -Name "user-auth"

# 等价于：
gco -b feature/user-auth
git push -u origin feature/user-auth

# 提交和推送
git add .
git commit -m "Add user authentication"
git push

# 创建 PR
pr-create
```

## 🐧 WSL 集成

### WSL 管理

```powershell
# WSL 发行版管理
wstatus         # 查看 WSL 状态
wstart ubuntu   # 启动 Ubuntu
wstop ubuntu    # 停止 Ubuntu

# 路径转换
wpath "C:\Users\username\Documents"    # -> /mnt/c/Users/username/Documents
wslpath "/home/user/project"           # -> \\wsl$\Ubuntu\home\user\project
```

### 跨平台文件操作

```powershell
# 文件传输
Copy-ToWSL -Source "config.json" -Destination "/home/user/config/"
Copy-FromWSL -Source "/home/user/project/" -Destination "C:\Projects\"

# 配置同步
wsync git       # 同步 Git 配置到 WSL
wsync zsh       # 同步 ZSH 配置到 WSL
wsync all       # 同步所有配置
```

### WSL 命令包装

```powershell
# 在 WSL 中执行命令
wsl-ls /home/user
wsl-grep "pattern" /home/user/file.txt
wsl-find /home -name "*.log"

# 开发工具
wsl-git status
wsl-docker ps
wsl-kubectl get pods
```

## 🪟 Windows 系统管理

### 系统健康检查

```powershell
# 完整系统检查
syshealth

# 输出示例：
# 🔍 Windows 系统健康检查
# ===============================================
# 📊 系统信息:
#   OS: Windows 11 Pro (10.0.22000)
#   CPU: Intel Core i7-10700K
#   内存: 32.0 GB
#   启动时间: 2023-01-15 09:30:00
#
# 💾 磁盘空间:
#   🟢 C: 250.5 GB / 500.0 GB (50.1%)
#   🟢 D: 800.0 GB / 1000.0 GB (80.0%)
```

### 性能优化

```powershell
# 系统优化
sysopt -CleanTemp -OptimizeStartup

# 启动项管理
startup         # 查看启动项
startup -Action Disable -ProgramName "Skype"

# 系统清理
cleancache      # 清理所有缓存
cleancache -DNS -WindowsStore  # 只清理特定缓存
```

### Windows 包管理

```powershell
# winget 操作
wg "visual studio code"    # 搜索包
wgi "Microsoft.VisualStudioCode"  # 安装包
wgu                        # 更新所有包
```

## 📊 系统监控

### 现代系统监控

```powershell
# 系统资源监控
top             # 启动 bottom（现代 top）
htop            # 别名

# 进程监控
ps              # procs（现代 ps）
ps --tree       # 树形显示进程
ps rust         # 只显示包含 rust 的进程
```

### 磁盘和存储

```powershell
# 磁盘使用情况
df              # duf（现代 df）
df --json       # JSON 格式输出

# 目录大小分析
du              # dust（现代 du）
du --depth 2    # 限制深度
du --reverse    # 反向排序
```

### 实时监控面板

```powershell
# 启动监控面板
dashboard       # 综合性能面板
perf            # 别名

# 网络监控
netmon          # 网络流量监控
```

## 🛠️ 开发环境

### 版本管理器

```powershell
# Node.js 环境
node-install            # 安装 fnm 和最新 Node.js
fnm install 18.17.0     # 安装特定版本
fnm use 18.17.0         # 切换版本
fnm list                # 列出已安装版本

# Python 环境
py-install              # 安装 pyenv 和 Python
pyenv install 3.11.5    # 安装特定版本
pyenv global 3.11.5     # 设置全局版本
pyenv versions          # 列出版本

# Rust 环境
rust-install            # 安装 Rust 工具链
rustup update           # 更新 Rust
cargo --version         # 检查版本
```

### 项目脚手架

```powershell
# React 项目
new-react "my-react-app" -Template vite -TypeScript
cd my-react-app
npm run dev

# Python 项目
new-python "my-python-app" -Template flask -VirtualEnv
cd my-python-app
.\venv\Scripts\Activate.ps1
python app.py

# Rust 项目
new-rust "my-rust-app" -Type bin
cd my-rust-app
cargo run
```

### 容器开发

```powershell
# Docker 操作
docker-cleanup          # 清理 Docker 系统
docker-stats-live       # 实时容器统计

# Kubernetes 操作
k get pods              # kubectl 简写
kgp                     # 获取 pods
kgs                     # 获取 services
kdesc pod my-pod        # 描述资源
klogs my-pod            # 查看日志
```

## 🧠 智能命令路由

### 智能命令替换

```powershell
# 自动选择最佳工具
sls             # 智能 ls（优先 eza）
sfind "*.ps1"   # 智能 find（优先 fd）
sgrep "error"   # 智能 grep（优先 ripgrep）
scat file.txt   # 智能 cat（优先 bat）
```

### 项目上下文感知

```powershell
# 进入不同类型的项目目录

# Node.js 项目
cd my-react-app
srun            # 自动运行 npm run dev
stest           # 自动运行 npm test
sbuild          # 自动运行 npm run build

# Python 项目
cd my-python-app
srun            # 自动运行 python main.py 或 flask run
stest           # 自动运行 pytest 或 python -m unittest

# Rust 项目
cd my-rust-app
srun            # 自动运行 cargo run
stest           # 自动运行 cargo test
sbuild          # 自动运行 cargo build
```

### 智能建议

```powershell
# 获取上下文相关建议
suggest

# 示例输出（在 Node.js 项目中）：
# 🧠 项目上下文建议
# 📦 检测到 Node.js 项目
# 💡 建议的操作：
#   srun    - 启动开发服务器
#   stest   - 运行测试
#   sbuild  - 构建项目
#   npm install  - 安装依赖
#   npm audit    - 安全检查
```

## 📚 帮助和文档

### 帮助系统使用

```powershell
# 主帮助菜单
help            # 显示帮助菜单

# 查看文档
help readme     # 显示 README 文档
docs            # 别名

# 浏览函数
help functions  # 显示所有函数
funcs           # 别名
help functions -Interactive  # 交互式函数浏览器
```

### 搜索功能

```powershell
# 搜索特定功能
help search git     # 搜索 git 相关功能
search docker       # 别名：搜索 docker 功能

# 查看特定函数帮助
Show-PWShFunctionHelp Get-SystemHealth
Get-Help New-ReactProject -Full
```

### 查看别名

```powershell
# 显示所有自定义别名
help aliases
Show-PWShAliases -Pattern "git*"  # 只显示 git 相关别名
```

## 🎯 高级使用场景

### 开发工作流整合

```powershell
# 1. 创建新项目
new-react "dashboard-app" -TypeScript
cd dashboard-app

# 2. 初始化 Git
git init
gh repo create dashboard-app --public
git remote add origin https://github.com/username/dashboard-app.git
git add .
git commit -m "Initial commit"
git push -u origin main

# 3. 创建功能分支
Start-GitWorkflow -Type feature -Name "user-auth"

# 4. 开发过程中的操作
srun            # 启动开发服务器
z src comp      # 快速跳转到 src/components
find auth       # 查找认证相关文件
grep-code "useState"  # 查找 Hook 使用

# 5. 提交和创建 PR
git add .
git commit -m "Add user authentication"
git push
pr-create
```

### 系统维护工作流

```powershell
# 1. 系统健康检查
syshealth

# 2. 性能优化
sysopt -All
dashboard       # 查看优化后的性能

# 3. 开发环境检查
devcheck
quick-fix       # 修复常见问题

# 4. 工具更新
wgu             # 更新 winget 包
scoop update *  # 更新 Scoop 包
```

### 多项目管理

```powershell
# 1. 项目导航
z proj          # 跳转到项目目录
zi              # 交互式选择项目

# 2. 项目状态检查
foreach ($dir in Get-ChildItem -Directory) {
    Push-Location $dir
    Write-Host "=== $($dir.Name) ===" -ForegroundColor Green
    if (Test-Path .git) { gst }
    Pop-Location
}

# 3. 批量操作
Get-ChildItem -Directory | Where-Object { Test-Path "$_\.git" } | ForEach-Object {
    Push-Location $_
    git fetch --all
    gst
    Pop-Location
}
```

## 💡 最佳实践

### 性能优化建议

1. **定期清理缓存**
   ```powershell
   # 每周运行一次
   Clear-PowerShellCache
   cleancache
   ```

2. **监控启动时间**
   ```powershell
   # 定期检查启动性能
   Measure-PowerShellStartup
   
   # 如果启动时间 > 500ms，运行优化
   if ((Measure-PowerShellStartup) -gt 500) {
       Start-PowerShellCacheWarmup
   }
   ```

3. **使用智能命令**
   ```powershell
   # 优先使用智能路由命令
   sls instead of ls
   sfind instead of Get-ChildItem -Recurse
   sgrep instead of Select-String
   ```

### 工作流最佳实践

1. **项目初始化标准流程**
   ```powershell
   # 使用脚手架创建项目
   new-react "project-name" -TypeScript
   cd "project-name"
   
   # 立即初始化版本控制
   git init
   gh repo create "project-name"
   
   # 设置开发环境
   code .  # 或你喜欢的编辑器
   ```

2. **日常开发习惯**
   ```powershell
   # 每天开始工作前
   z proj && zi         # 选择项目
   srun                 # 启动开发服务器
   lg                   # 检查 Git 状态
   
   # 定期检查
   suggest              # 获取建议
   syshealth           # 系统状态
   ```

3. **代码质量保证**
   ```powershell
   # 搜索代码问题
   grep-todo           # 查找未完成的 TODO
   grep-code "console.log"  # 查找调试代码
   grep-code "debugger"     # 查找断点
   ```

### 定制化建议

1. **创建个人别名**
   ```powershell
   # 在 ~/.config/powershell/private/config.ps1 中添加
   Set-Alias -Name myproject -Value "z my-project && code ."
   Set-Alias -Name dailycheck -Value "syshealth && devcheck"
   ```

2. **自定义函数**
   ```powershell
   function Start-MyWorkflow {
       syshealth
       z projects && zi
       lg
   }
   ```

3. **环境变量优化**
   ```powershell
   # 在私有配置中设置
   $env:PWSH_DEBUG = "0"        # 关闭调试输出
   $env:PWSH_NO_WELCOME = "1"   # 关闭欢迎信息（可选）
   ```

## 🔧 故障排除示例

### 常见问题解决

1. **启动缓慢**
   ```powershell
   # 诊断启动时间
   $env:PWSH_DEBUG = "1"
   . $PROFILE
   
   # 清理和优化
   Clear-PowerShellCache
   Start-PowerShellCacheWarmup
   ```

2. **工具不可用**
   ```powershell
   # 检查工具状态
   devcheck
   
   # 重新安装缺失工具
   setup-wizard -SkipSteps @('Welcome', 'CheckEnvironment')
   ```

3. **命令不工作**
   ```powershell
   # 快速修复
   quick-fix
   
   # 重新加载配置
   . $PROFILE
   ```

这些示例展示了 PowerShell 现代工具链的强大功能和灵活性。通过组合使用这些工具，你可以大大提高命令行工作效率！