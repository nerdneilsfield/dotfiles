# PowerShell Profile - 主入口文件
# 模仿 ZSH 的高效加载机制

# 性能监控 - 启动时间测量
$script:ProfileStartTime = Get-Date

# 配置路径
$script:PWSH_CONFIG_DIR = "$env:USERPROFILE\.config\powershell"
$script:PWSH_CACHE_DIR = "$env:USERPROFILE\.cache\powershell"
$script:PWSH_PRIVATE_DIR = "$script:PWSH_CONFIG_DIR\private"

# 确保目录存在
@($script:PWSH_CONFIG_DIR, $script:PWSH_CACHE_DIR, $script:PWSH_PRIVATE_DIR) | ForEach-Object {
    if (!(Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

# 性能优化设置
$PSDefaultParameterValues = @{
    '*:Encoding' = 'UTF8'
    'Out-File:Encoding' = 'UTF8'
    'Export-Csv:NoTypeInformation' = $true
}

# PowerShell 7+ 特性检查
$script:IsPowerShell7Plus = $PSVersionTable.PSVersion.Major -ge 7

# 日志函数 - 轻量级
function Write-ProfileLog {
    param([string]$Message, [string]$Level = "DEBUG")
    if ($env:PWSH_DEBUG -eq "1") {
        $elapsed = ((Get-Date) - $script:ProfileStartTime).TotalMilliseconds
        Write-Host "[$($elapsed.ToString('F0'))ms] [$Level] $Message" -ForegroundColor DarkGray
    }
}

Write-ProfileLog "开始加载 PowerShell 配置"

# 智能条件加载函数（性能优化版本）
function Invoke-ConditionalLoad {
    param(
        [string]$ModulePath,
        [scriptblock]$Condition = { $true },
        [string]$Description = ""
    )
    
    # 缓存文件路径计算
    if (-not $script:PathCache) { $script:PathCache = @{} }
    
    if (-not $script:PathCache.ContainsKey($ModulePath)) {
        $script:PathCache[$ModulePath] = if ([System.IO.Path]::IsPathRooted($ModulePath)) {
            $ModulePath
        } else {
            Join-Path $script:PWSH_CONFIG_DIR $ModulePath
        }
    }
    
    $fullPath = $script:PathCache[$ModulePath]
    
    # 缓存文件存在性检查
    if (-not $script:FileExistsCache) { $script:FileExistsCache = @{} }
    
    if (-not $script:FileExistsCache.ContainsKey($fullPath)) {
        $script:FileExistsCache[$fullPath] = Test-Path $fullPath
    }
    
    if ($script:FileExistsCache[$fullPath]) {
        try {
            # 条件检查缓存（对于静态条件）
            $conditionKey = $Condition.ToString()
            if (-not $script:ConditionCache) { $script:ConditionCache = @{} }
            
            $shouldLoad = $true
            if ($script:ConditionCache.ContainsKey($conditionKey)) {
                $shouldLoad = $script:ConditionCache[$conditionKey]
            } else {
                $shouldLoad = & $Condition
                # 只缓存静态条件（不包含命令检查）
                if ($conditionKey -notmatch "Get-Command") {
                    $script:ConditionCache[$conditionKey] = $shouldLoad
                }
            }
            
            if ($shouldLoad) {
                Write-ProfileLog "加载模块: $Description ($ModulePath)"
                # 读取并在当前作用域执行脚本内容
                $scriptContent = Get-Content $fullPath -Raw
                Invoke-Expression $scriptContent
                return $true
            } else {
                Write-ProfileLog "跳过模块: $Description (条件不满足)"
                return $false
            }
        } catch {
            Write-ProfileLog "模块加载失败: $Description - $($_.Exception.Message)" "ERROR"
            return $false
        }
    } else {
        Write-ProfileLog "模块不存在: $fullPath" "WARN"
        return $false
    }
}

# 缓存函数 - 高性能版本
function Get-CachedResult {
    param(
        [string]$CacheKey,
        [scriptblock]$ScriptBlock,
        [int]$TTLSeconds = 3600
    )
    
    $cacheFile = Join-Path $script:PWSH_CACHE_DIR "$CacheKey.cache"
    $timeFile = Join-Path $script:PWSH_CACHE_DIR "$CacheKey.time"
    
    # 检查缓存是否有效
    if ((Test-Path $cacheFile) -and (Test-Path $timeFile)) {
        try {
            $cacheTime = [DateTime]::FromBinary([Convert]::ToInt64((Get-Content $timeFile)))
            $age = (Get-Date) - $cacheTime
            
            if ($age.TotalSeconds -lt $TTLSeconds) {
                Write-ProfileLog "使用缓存: $CacheKey (年龄: $($age.TotalSeconds.ToString('F0'))s)"
                return Get-Content $cacheFile -Raw
            }
        } catch {
            Write-ProfileLog "缓存文件损坏，重新生成: $CacheKey" "WARN"
        }
    }
    
    # 生成新缓存
    Write-ProfileLog "生成缓存: $CacheKey"
    try {
        $result = & $ScriptBlock
        $result | Out-File $cacheFile -Encoding UTF8
        [Convert]::ToInt64((Get-Date).ToBinary()) | Out-File $timeFile -Encoding ASCII
        return $result
    } catch {
        Write-ProfileLog "缓存生成失败: $CacheKey - $($_.Exception.Message)" "ERROR"
        return $null
    }
}

# === 核心模块加载 (总是加载) ===
Write-ProfileLog "加载核心模块"

# 直接加载核心模块（绕过函数作用域问题）
$moduleList = @(
    @{Path="modules\core\config.ps1"; Condition={$true}; Name="基础配置"},
    @{Path="modules\core\aliases.ps1"; Condition={$true}; Name="别名定义"},
    @{Path="modules\core\functions.ps1"; Condition={$true}; Name="通用函数"}, 
    @{Path="modules\performance\benchmark.ps1"; Condition={$true}; Name="性能测试工具"}
)

foreach ($module in $moduleList) {
    $fullPath = if ([System.IO.Path]::IsPathRooted($module.Path)) {
        $module.Path
    } else {
        Join-Path $script:PWSH_CONFIG_DIR $module.Path
    }
    
    if ((Test-Path $fullPath) -and (& $module.Condition)) {
        try {
            Write-ProfileLog "加载模块: $($module.Name) ($($module.Path))"
            . $fullPath
        } catch {
            Write-ProfileLog "模块加载失败: $($module.Name) - $($_.Exception.Message)" "ERROR"
        }
    }
}

# === 条件加载模块 ===
Write-ProfileLog "开始条件加载"

# Git 集成 (如果 Git 可用) - 直接加载
$gitModulePath = Join-Path $script:PWSH_CONFIG_DIR "modules\tools\git.ps1"
if ((Test-Path $gitModulePath) -and (Get-Command git -ErrorAction SilentlyContinue)) {
    try {
        Write-ProfileLog "加载模块: Git 集成 (modules\tools\git.ps1)"
        . $gitModulePath
    } catch {
        Write-ProfileLog "模块加载失败: Git 集成 - $($_.Exception.Message)" "ERROR"
    }
}

# Docker 支持 (如果 Docker 可用)
Invoke-ConditionalLoad "modules\tools\docker.ps1" { 
    Get-Command docker -ErrorAction SilentlyContinue 
} "Docker 支持" | Out-Null

# 开发工具集成
Invoke-ConditionalLoad "modules\tools\development.ps1" { 
    (Get-Command code -ErrorAction SilentlyContinue) -or 
    (Get-Command nvim -ErrorAction SilentlyContinue) -or
    (Get-Command vim -ErrorAction SilentlyContinue)
} "开发工具" | Out-Null

# Node.js 工具
Invoke-ConditionalLoad "modules\tools\node.ps1" { 
    (Get-Command node -ErrorAction SilentlyContinue) -or
    (Get-Command fnm -ErrorAction SilentlyContinue) -or
    (Get-Command nvm -ErrorAction SilentlyContinue)
} "Node.js 工具" | Out-Null

# Python 工具
Invoke-ConditionalLoad "modules\tools\python.ps1" { 
    (Get-Command python -ErrorAction SilentlyContinue) -or
    (Get-Command python3 -ErrorAction SilentlyContinue) -or
    (Get-Command py -ErrorAction SilentlyContinue)
} "Python 工具" | Out-Null

# Rust 工具
Invoke-ConditionalLoad "modules\tools\rust.ps1" { 
    (Get-Command cargo -ErrorAction SilentlyContinue) -or
    (Test-Path "$env:USERPROFILE\.cargo\bin")
} "Rust 工具" | Out-Null

# === 平台特定配置 ===
Write-ProfileLog "加载平台特定配置"

# WSL 集成 (如果在 WSL 环境中)
Invoke-ConditionalLoad "modules\platform\wsl.ps1" { 
    $env:WSL_DISTRO_NAME -or (Get-Command wsl -ErrorAction SilentlyContinue)
} "WSL 集成" | Out-Null

# === PowerShell 增强 ===
Write-ProfileLog "加载 PowerShell 增强功能"

# PSReadLine 增强 (PowerShell 5.1+)
if (Get-Module PSReadLine -ListAvailable) {
    Write-ProfileLog "配置 PSReadLine"
    
    # 设置预测性 IntelliSense (PowerShell 7.2+)
    if ($script:IsPowerShell7Plus -and $PSVersionTable.PSVersion -ge [Version]"7.2") {
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle ListView
    }
    
    # 键绑定
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key "Ctrl+d" -Function DeleteCharOrExit
    Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo
    
    # 历史记录搜索
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# 自动补全增强
Invoke-ConditionalLoad "modules\core\completion.ps1" { $true } "自动补全增强" | Out-Null

# 帮助系统
# 帮助文档系统 - 直接加载
$helpModulePath = Join-Path $script:PWSH_CONFIG_DIR "modules\core\help.ps1"
if (Test-Path $helpModulePath) {
    try {
        Write-ProfileLog "加载模块: 帮助文档系统 (modules\core\help.ps1)"
        . $helpModulePath
    } catch {
        Write-ProfileLog "模块加载失败: 帮助文档系统 - $($_.Exception.Message)" "ERROR"
    }
}

# 设置向导
Invoke-ConditionalLoad "modules\core\wizard.ps1" { $true } "快速设置向导" | Out-Null

# 导航增强
Invoke-ConditionalLoad "modules\tools\navigation.ps1" { $true } "智能导航" | Out-Null

# Scoop 工具链 - 直接加载
$scoopModulePath = Join-Path $script:PWSH_CONFIG_DIR "modules\tools\scoop.ps1"
if ((Test-Path $scoopModulePath) -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
    try {
        Write-ProfileLog "加载模块: Scoop 工具链 (modules\tools\scoop.ps1)"
        . $scoopModulePath
    } catch {
        Write-ProfileLog "模块加载失败: Scoop 工具链 - $($_.Exception.Message)" "ERROR"
    }
}

# Starship 提示符
Invoke-ConditionalLoad "modules\tools\starship.ps1" { 
    Get-Command starship -ErrorAction SilentlyContinue 
} "Starship 提示符" | Out-Null

# 搜索工具集成
Invoke-ConditionalLoad "modules\tools\search.ps1" { 
    (Get-Command fd -ErrorAction SilentlyContinue) -or 
    (Get-Command rg -ErrorAction SilentlyContinue) -or
    (Get-Command fzf -ErrorAction SilentlyContinue)
} "高级搜索工具" | Out-Null

# 智能路由系统
Invoke-ConditionalLoad "modules\core\router.ps1" { $true } "智能命令路由" | Out-Null

# 跨平台操作
Invoke-ConditionalLoad "modules\core\crossplatform.ps1" { $true } "跨平台文件操作" | Out-Null

# === Phase 3: 高级工具集成 ===
Write-ProfileLog "加载 Phase 3 高级工具"

# Windows 功能深度集成
Invoke-ConditionalLoad "modules\platform\windows.ps1" { 
    $IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)
} "Windows 深度功能" | Out-Null

# 系统监控工具
Invoke-ConditionalLoad "modules\tools\monitoring.ps1" { $true } "系统监控工具" | Out-Null

# 开发环境集成
Invoke-ConditionalLoad "modules\tools\devenv.ps1" { $true } "开发环境集成" | Out-Null

# === 私有配置加载 ===
Write-ProfileLog "加载私有配置"

# 私有配置 (不被版本控制)
$privateConfig = Join-Path $script:PWSH_PRIVATE_DIR "config.ps1"
if (Test-Path $privateConfig) {
    try {
        . $privateConfig
        Write-ProfileLog "已加载私有配置"
    } catch {
        Write-ProfileLog "私有配置加载失败: $($_.Exception.Message)" "ERROR"
    }
}

# === 性能报告 ===
$script:ProfileEndTime = Get-Date
$script:ProfileLoadTime = ($script:ProfileEndTime - $script:ProfileStartTime).TotalMilliseconds

Write-ProfileLog "配置加载完成，耗时: $($script:ProfileLoadTime.ToString('F0'))ms"

# 如果启动时间过长，显示警告
if ($script:ProfileLoadTime -gt 500) {
    Write-Host "⚠️  PowerShell 启动时间较长 ($($script:ProfileLoadTime.ToString('F0'))ms)，建议运行 Measure-PowerShellStartup 进行性能诊断" -ForegroundColor Yellow
} elseif ($env:PWSH_DEBUG -eq "1") {
    Write-Host "✅ PowerShell 加载完成 ($($script:ProfileLoadTime.ToString('F0'))ms)" -ForegroundColor Green
}

# 清理临时变量和缓存
Remove-Variable ProfileStartTime, ProfileEndTime -Scope Script -ErrorAction SilentlyContinue

# 清理性能优化缓存（保留条件缓存用于后续重新加载）
Remove-Variable PathCache, FileExistsCache -Scope Script -ErrorAction SilentlyContinue

# 欢迎信息 (仅在交互式会话中显示)
if ([Environment]::UserInteractive -and !$env:PWSH_NO_WELCOME) {
    Write-Host "🚀 PowerShell 现代工具链已加载 " -ForegroundColor Cyan -NoNewline
    Write-Host "| 运行 " -ForegroundColor DarkGray -NoNewline
    Write-Host "phelp" -ForegroundColor Yellow -NoNewline
    Write-Host " 或 " -ForegroundColor DarkGray -NoNewline
    Write-Host "docs" -ForegroundColor Yellow -NoNewline
    Write-Host " 查看帮助" -ForegroundColor DarkGray
}