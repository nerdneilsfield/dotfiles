# PowerShell 核心配置
# 基础设置和环境配置

# 简单日志函数 - 确保在模块中可用
if (-not (Get-Command Write-ProfileLog -ErrorAction SilentlyContinue)) {
    function Write-ProfileLog {
        param([string]$Message, [string]$Level = "DEBUG")
        if ($env:PWSH_DEBUG -eq "1") {
            Write-Host "[$Level] $Message" -ForegroundColor DarkGray
        }
    }
}

# PowerShell 行为优化
$PSDefaultParameterValues = @{
    # 编码设置
    '*:Encoding' = 'UTF8'
    'Out-File:Encoding' = 'UTF8'
    'Export-Csv:NoTypeInformation' = $true
    
    # 网络优化
    'Invoke-WebRequest:UseBasicParsing' = $true
    'Invoke-RestMethod:UseBasicParsing' = $true
    
    # 进度条优化 (对脚本性能有帮助)
    'Invoke-WebRequest:ProgressAction' = 'SilentlyContinue'
    'Invoke-RestMethod:ProgressAction' = 'SilentlyContinue'
}

# 错误处理优化
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"  # 提升脚本性能

# PowerShell 7+ 特性检测
$script:IsPowerShell7Plus = $PSVersionTable.PSVersion.Major -ge 7
$script:IsWindows = $IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)
$script:IsLinux = $IsLinux
$script:IsMacOS = $IsMacOS

# 环境变量设置
if ($script:IsWindows) {
    # Windows 特定环境变量
    $env:PWSH_CONFIG_DIR = "$env:USERPROFILE\.config\powershell"
    $env:PWSH_CACHE_DIR = "$env:USERPROFILE\.cache\powershell"
    
    # Git 配置 (如果使用 Git for Windows)
    if (Test-Path "$env:PROGRAMFILES\Git\bin") {
        $env:PATH += ";$env:PROGRAMFILES\Git\bin"
    }
    
    # Scoop 路径 (如果安装)
    if (Test-Path "$env:USERPROFILE\scoop\shims") {
        $env:PATH += ";$env:USERPROFILE\scoop\shims"
    }
    if (Test-Path "$env:PROGRAMDATA\scoop\shims") {
        $env:PATH += ";$env:PROGRAMDATA\scoop\shims"
    }
    
    # Chocolatey 路径 (如果安装)
    if (Test-Path "$env:PROGRAMDATA\chocolatey\bin") {
        $env:PATH += ";$env:PROGRAMDATA\chocolatey\bin"
    }
} else {
    # Unix-like 系统
    $env:PWSH_CONFIG_DIR = "$env:HOME/.config/powershell"
    $env:PWSH_CACHE_DIR = "$env:HOME/.cache/powershell"
}

if ($script:PWSH_FAST_STARTUP) {
    Write-ProfileLog "快速启动模式：跳过开发者模式检测、路径扫描与高级配置"
    
    if ([Environment]::UserInteractive) {
        $Host.UI.RawUI.WindowTitle = "PowerShell $($PSVersionTable.PSVersion)"
    }
    
    return
}

# 历史记录优化
if (Get-Module PSReadLine -ListAvailable) {
    # 历史记录文件位置
    $historyPath = if ($script:IsWindows) {
        "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    } else {
        "$env:HOME/.local/share/powershell/PSReadLine/ConsoleHost_history.txt"
    }
    
    # 确保历史记录目录存在
    $historyDir = Split-Path $historyPath -Parent
    if (!(Test-Path $historyDir)) {
        New-Item -ItemType Directory -Path $historyDir -Force | Out-Null
    }
    
    # 历史记录设置
    Set-PSReadLineOption -HistoryNoDuplicates:$true
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd:$true
    Set-PSReadLineOption -MaximumHistoryCount 10000
}

# 控制台外观设置
if ([Environment]::UserInteractive) {
    # 窗口标题
    $Host.UI.RawUI.WindowTitle = "PowerShell $($PSVersionTable.PSVersion)"
    
    # 颜色主题
    if ($script:IsPowerShell7Plus) {
        # PowerShell 7+ 的现代颜色
        $PSStyle.FileInfo.Directory = $PSStyle.Foreground.Blue
        $PSStyle.FileInfo.SymbolicLink = $PSStyle.Foreground.Cyan
        $PSStyle.FileInfo.Executable = $PSStyle.Foreground.Green
    }
}

# 性能优化设置
if ($script:IsPowerShell7Plus) {
    # 并发任务优化
    $PSDefaultParameterValues['ForEach-Object:Parallel'] = $true
    
    # 更好的错误视图
    $ErrorView = 'ConciseView'
}

# 模块自动加载配置
$PSModuleAutoLoadingPreference = 'All'

# 智能大小写补全 (PowerShell 5.1+)
if ($PSVersionTable.PSVersion.Major -ge 5) {
    Set-PSReadLineOption -CompletionQueryItems 100
    
    # 智能补全
    if ($script:IsPowerShell7Plus) {
        Set-PSReadLineOption -PredictionSource History
    }
}

# 开发者模式检测和设置
function Test-DeveloperMode {
    <#
    .SYNOPSIS
    检测Windows开发者模式状态
    #>
    if ($script:IsWindows) {
        try {
            $devMode = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
            return $devMode.AllowDevelopmentWithoutDevLicense -eq 1
        } catch {
            return $false
        }
    }
    return $true  # Unix-like 系统默认为开发者友好
}

$script:IsDeveloperMode = Test-DeveloperMode

# 网络配置
if ($script:IsWindows) {
    # 检查代理设置
    $proxySettings = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -ErrorAction SilentlyContinue
    if ($proxySettings -and $proxySettings.ProxyEnable -eq 1) {
        $env:HTTP_PROXY = "http://$($proxySettings.ProxyServer)"
        $env:HTTPS_PROXY = "http://$($proxySettings.ProxyServer)"
    }
}

# 工具检测缓存
$script:ToolCache = @{}

function Test-CommandAvailable {
    <#
    .SYNOPSIS
    检查命令是否可用并缓存结果
    #>
    param([string]$Command)
    
    if (!$script:ToolCache.ContainsKey($Command)) {
        $script:ToolCache[$Command] = [bool](Get-Command $Command -ErrorAction SilentlyContinue)
    }
    
    return $script:ToolCache[$Command]
}

# 常用工具可用性检测
$script:HasGit = Test-CommandAvailable 'git'
$script:HasDocker = Test-CommandAvailable 'docker'
$script:HasNode = Test-CommandAvailable 'node'
$script:HasPython = Test-CommandAvailable 'python' -or (Test-CommandAvailable 'python3') -or (Test-CommandAvailable 'py')
$script:HasCargo = Test-CommandAvailable 'cargo'

# 路径优化函数
function Add-PathIfExists {
    <#
    .SYNOPSIS
    将存在的路径添加到PATH环境变量
    #>
    param([string]$Path)
    
    if ((Test-Path $Path) -and ($env:PATH -notlike "*$Path*")) {
        if ($script:IsWindows) {
            $env:PATH += ";$Path"
        } else {
            $env:PATH += ":$Path"
        }
    }
}

# 常用路径添加
$commonPaths = if ($script:IsWindows) {
    @(
        "$env:USERPROFILE\.cargo\bin",
        "$env:USERPROFILE\.local\bin",
        "$env:USERPROFILE\go\bin",
        "$env:USERPROFILE\AppData\Local\Programs\Python\Python*\Scripts",
        "$env:USERPROFILE\AppData\Roaming\npm"
    )
} else {
    @(
        "$env:HOME/.cargo/bin",
        "$env:HOME/.local/bin",
        "$env:HOME/go/bin",
        "$env:HOME/.npm-global/bin"
    )
}

foreach ($path in $commonPaths) {
    if ($path -like "*`**") {
        # 处理通配符路径
        Get-ChildItem (Split-Path $path -Parent) -Directory -ErrorAction SilentlyContinue | 
            Where-Object { $_.Name -like (Split-Path $path -Leaf) } |
            ForEach-Object { Add-PathIfExists $_.FullName }
    } else {
        Add-PathIfExists $path
    }
}

# 编辑器检测和设置
$editors = @('code', 'nvim', 'vim', 'nano', 'notepad')
foreach ($editor in $editors) {
    if (Test-CommandAvailable $editor) {
        $env:EDITOR = $editor
        break
    }
}

# Git 配置检测
if ($script:HasGit) {
    # 设置 Git 默认编辑器
    if ($env:EDITOR -and !(git config --global --get core.editor)) {
        git config --global core.editor $env:EDITOR 2>$null
    }
}

# 临时文件路径
$env:TEMP_DIR = if ($script:IsWindows) { $env:TEMP } else { "/tmp" }

Write-ProfileLog "核心配置加载完成" -Level "DEBUG"
