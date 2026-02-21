# PowerShell Profile - 主入口文件
# 模仿 ZSH 的高效加载机制

# 性能监控 - 启动时间测量
$script:ProfileStartTime = Get-Date

# 配置路径 - 检测并使用正确的配置目录
$script:PWSH_SCRIPT_DIR = Split-Path $MyInvocation.MyCommand.Path -Parent

# 如果当前脚本在默认 PowerShell 目录，则使用 dotfiles 目录
if ($script:PWSH_SCRIPT_DIR -like "*Documents\PowerShell*" -or $script:PWSH_SCRIPT_DIR -like "*Documents\WindowsPowerShell*") {
    $script:PWSH_CONFIG_DIR = "$env:USERPROFILE\.config\powershell"
} else {
    $script:PWSH_CONFIG_DIR = $script:PWSH_SCRIPT_DIR
}
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

# 启动模式：非交互会话默认走轻量模式，避免加载大量会话增强模块
if (-not $env:PWSH_FAST_STARTUP) {
    $env:PWSH_FAST_STARTUP = if ([Environment]::UserInteractive) { "0" } else { "1" }
}

$script:PWSH_FAST_STARTUP = $env:PWSH_FAST_STARTUP -eq "1"
$script:PWSH_BENCHMARK_STARTUP = $env:PWSH_BENCHMARK_STARTUP -eq "1"

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
                Write-ProfileLog "加载模块 (全局): $Description ($ModulePath)"
                return Invoke-TimedModuleLoad -Name $Description -Path $fullPath -LoadAction {
                    Import-PowerShellProfileScriptModule -ModulePath $fullPath
                } -ImportAsModule:$false
            } else {
                Write-ProfileLog "跳过模块: $Description (条件不满足)"
                Add-ProfileModuleLoadStat -Name $Description -Path $fullPath -Status "Skipped" -ElapsedMs 0 -Reason "ConditionFalse"
                return $false
            }
        } catch {
            Write-ProfileLog "模块加载失败: $Description - $($_.Exception.Message)" "ERROR"
            return $false
        }
    } else {
        Write-ProfileLog "模块不存在: $fullPath" "WARN"
        Add-ProfileModuleLoadStat -Name $Description -Path $fullPath -Status "Skipped" -ElapsedMs 0 -Reason "ModuleMissing"
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

# 模块耗时统计
$script:ProfileModuleLoadStats = @()

function Add-ProfileModuleLoadStat {
    param(
        [string]$Name,
        [string]$Path = "",
        [string]$Status = "Loaded",
        [double]$ElapsedMs = 0,
        [string]$Reason = ""
    )

    $script:ProfileModuleLoadStats += [PSCustomObject]@{
        Module   = $Name
        Path     = $Path
        Status   = $Status
        ElapsedMs = [math]::Round($ElapsedMs, 2)
        Reason   = $Reason
    }
}

function Import-PowerShellProfileScriptModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ModulePath
    )

    $moduleContent = Get-Content -Path $ModulePath -Raw
    # 创建唯一的动态模块名称，基于文件名，并清理特殊字符
    $dynamicModuleName = "DynamicPSModule_$(($ModulePath | Split-Path -Leaf) -replace '[^a-zA-Z0-9_]', '_')"

    # 如果模块已存在（例如 profile 重载），先移除
    if (Get-Module $dynamicModuleName -ErrorAction SilentlyContinue) {
        Write-ProfileLog "重新加载模块: 移除旧的 $dynamicModuleName"
        Remove-Module $dynamicModuleName -Force -ErrorAction SilentlyContinue
    }

    New-Module -Name $dynamicModuleName -ScriptBlock ([scriptblock]::Create($moduleContent)) |
        Import-Module -Global -Force -DisableNameChecking | Out-Null
}

function Invoke-TimedModuleLoad {
    [CmdletBinding()]
    param(
        [string]$Name,
        [string]$Path,
        [scriptblock]$LoadAction = { },
        [switch]$ImportAsModule = $true
    )

    $startTime = Get-Date
    $status = "Loaded"
    $reason = ""

    try {
        if ($ImportAsModule -and $Path) {
            Import-PowerShellProfileScriptModule -ModulePath $Path
        } else {
            & $LoadAction
        }
        return $true
    } catch {
        $status = "Failed"
        $reason = $_.Exception.Message
        Write-ProfileLog "模块加载失败: $Name - $reason" "ERROR"
        return $false
    } finally {
        $elapsedMs = ((Get-Date) - $startTime).TotalMilliseconds
        Add-ProfileModuleLoadStat -Name $Name -Path $Path -Status $status -ElapsedMs $elapsedMs -Reason $reason
    }
}

function Invoke-TimedModuleFileLoad {
    [CmdletBinding()]
    param(
        [string]$Name,
        [string]$ModulePath,
        [scriptblock]$Condition = { $true }
    )

    try {
        $shouldLoad = & $Condition
    } catch {
        $shouldLoad = $false
    }

    if (-not $shouldLoad) {
        Write-ProfileLog "跳过模块: $Name (条件不满足)"
        Add-ProfileModuleLoadStat -Name $Name -Path $ModulePath -Status "Skipped" -ElapsedMs 0 -Reason "ConditionFalse"
        return $false
    }

    if (!(Test-Path $ModulePath)) {
        Write-ProfileLog "模块不存在: $ModulePath" "WARN"
        Add-ProfileModuleLoadStat -Name $Name -Path $ModulePath -Status "Skipped" -ElapsedMs 0 -Reason "ModuleMissing"
        return $false
    }

    return Invoke-TimedModuleLoad -Name $Name -Path $ModulePath
}

function Show-PowerShellProfileModuleTimings {
    [CmdletBinding()]
    param(
        [int]$Top = 20,
        [switch]$IncludeSkipped
    )

    if (!$script:ProfileModuleLoadStats -or $script:ProfileModuleLoadStats.Count -eq 0) {
        Write-Host "未采集到模块加载耗时数据" -ForegroundColor Yellow
        return
    }

    $statsForDisplay = if ($IncludeSkipped) {
        $script:ProfileModuleLoadStats
    } else {
        $script:ProfileModuleLoadStats | Where-Object { $_.Status -ne "Skipped" }
    }

    $summary = $script:ProfileModuleLoadStats | Group-Object Status
    $summaryText = ($summary | ForEach-Object { "$($_.Name):$($_.Count)" }) -join " / "
    Write-Host "`n模块加载耗时 Top $Top (加载/失败模块):" -ForegroundColor Cyan
    Write-Host "  模块状态: $summaryText" -ForegroundColor DarkGray

    if (!$statsForDisplay -or $statsForDisplay.Count -eq 0) {
        Write-Host "  未发现可计时模块（已全部跳过）" -ForegroundColor Yellow
        return
    }

    $statsForDisplay |
        Sort-Object ElapsedMs -Descending |
        Select-Object -First $Top |
        Format-Table Module, Status, ElapsedMs, Path, Reason -AutoSize
}

# === 核心模块加载 (总是加载) ===
Write-ProfileLog "加载核心模块"

# 直接加载核心模块（绕过函数作用域问题）
$moduleList = @(
    @{Path="modules/core/config.ps1"; Condition={$true}; Name="基础配置"},
    @{Path="modules/core/aliases.ps1"; Condition={-not $script:PWSH_FAST_STARTUP -or -not $script:PWSH_BENCHMARK_STARTUP}; Name="别名定义"},
    @{Path="modules/core/functions.ps1"; Condition={-not $script:PWSH_FAST_STARTUP -or -not $script:PWSH_BENCHMARK_STARTUP}; Name="通用函数"},
    # @{Path="modules/core/crossplatform.ps1"; Condition={$true}; Name="跨平台工具"},
    @{Path="modules/performance/benchmark.ps1"; Condition={$true}; Name="性能测试工具"}

)

foreach ($module in $moduleList) {
    $fullPath = if ([System.IO.Path]::IsPathRooted($module.Path)) {
        $module.Path
    } else {
        Join-Path $script:PWSH_CONFIG_DIR $module.Path
    }

    if ((& $module.Condition)) {
        if (Test-Path $fullPath) {
            Invoke-TimedModuleLoad -Name $module.Name -Path $fullPath | Out-Null
        } else {
            Add-ProfileModuleLoadStat -Name $module.Name -Path $fullPath -Status "Skipped" -ElapsedMs 0 -Reason "ModuleMissing"
        }
    } else {
        Add-ProfileModuleLoadStat -Name $module.Name -Path $fullPath -Status "Skipped" -ElapsedMs 0 -Reason "ConditionFalse"
    }
}

# === 条件加载模块 ===
Write-ProfileLog "开始条件加载"

if ($script:PWSH_FAST_STARTUP) {
    Write-ProfileLog "快速启动模式：跳过条件加载模块"
} else {

    # Git 集成 (如果 Git 可用) - 直接加载
    $gitModulePath = Join-Path $script:PWSH_CONFIG_DIR "modules/tools/git.ps1"
    Invoke-TimedModuleFileLoad -Name "Git 集成" -ModulePath $gitModulePath -Condition {
        (Test-Path $gitModulePath) -and (Get-Command git -ErrorAction SilentlyContinue)
    } | Out-Null

    # Docker 支持 (如果 Docker 可用)
    Invoke-ConditionalLoad "modules/tools/docker.ps1" { 
        Get-Command docker -ErrorAction SilentlyContinue 
    } "Docker 支持" | Out-Null

    # 开发工具集成
    Invoke-ConditionalLoad "modules/tools/development.ps1" { 
        (Get-Command code -ErrorAction SilentlyContinue) -or 
        (Get-Command nvim -ErrorAction SilentlyContinue) -or
        (Get-Command vim -ErrorAction SilentlyContinue)
    } "开发工具" | Out-Null

    # Node.js 工具
    Invoke-ConditionalLoad "modules/tools/node.ps1" { 
        (Get-Command node -ErrorAction SilentlyContinue) -or
        (Get-Command fnm -ErrorAction SilentlyContinue) -or
        (Get-Command nvm -ErrorAction SilentlyContinue)
    } "Node.js 工具" | Out-Null

    # Python 工具
    Invoke-ConditionalLoad "modules/tools/python.ps1" { 
        (Get-Command python -ErrorAction SilentlyContinue) -or
        (Get-Command python3 -ErrorAction SilentlyContinue) -or
        (Get-Command py -ErrorAction SilentlyContinue)
    } "Python 工具" | Out-Null

    # Rust 工具
    Invoke-ConditionalLoad "modules/tools/rust.ps1" { 
        (Get-Command cargo -ErrorAction SilentlyContinue) -or
        (Test-Path "$env:USERPROFILE\.cargo\bin")
    } "Rust 工具" | Out-Null

    # === 平台特定配置 ===
    Write-ProfileLog "加载平台特定配置"

    # WSL 集成 - 直接加载
    $wslModulePath = Join-Path $script:PWSH_CONFIG_DIR "modules/platform/wsl.ps1"
    Invoke-TimedModuleFileLoad -Name "WSL 集成" -ModulePath $wslModulePath -Condition {
        (Test-Path $wslModulePath) -and ($env:WSL_DISTRO_NAME -or (Get-Command wsl -ErrorAction SilentlyContinue))
    } | Out-Null
}

# === PowerShell 增强 ===
if ($script:PWSH_FAST_STARTUP) {
    Write-ProfileLog "快速启动模式：跳过 PowerShell 增强与高级工具加载"
} else {
    Write-ProfileLog "加载 PowerShell 增强功能"
    
    # PSReadLine 增强 (PowerShell 5.1+)
    if (Get-Module PSReadLine -ListAvailable) {
        Write-ProfileLog "配置 PSReadLine"
        
        # 设置预测性 IntelliSense (PowerShell 7.2+)
        $allowPrediction = (-not [Console]::IsOutputRedirected) -and (-not $env:PWSH_BENCHMARK_STARTUP)
        if ($script:IsPowerShell7Plus -and $PSVersionTable.PSVersion -ge [Version]"7.2" -and $allowPrediction) {
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
    Invoke-ConditionalLoad "modules/core/completion.ps1" { $true } "自动补全增强" | Out-Null
    
    # 帮助系统
    # 帮助文档系统 - 直接加载
    $helpModulePath = Join-Path $script:PWSH_CONFIG_DIR "modules/core/help.ps1"
    Invoke-TimedModuleFileLoad -Name "帮助文档系统" -ModulePath $helpModulePath -Condition {
        Test-Path $helpModulePath
    } | Out-Null
    
    # 设置向导
    Invoke-ConditionalLoad "modules/core/wizard.ps1" { $true } "快速设置向导" | Out-Null
    
    # 导航增强
    Invoke-ConditionalLoad "modules/tools/navigation.ps1" { $true } "智能导航" | Out-Null
    
    # Scoop 工具链 - 直接加载
    $scoopModulePath = Join-Path $script:PWSH_CONFIG_DIR "modules/tools/scoop.ps1"
    Invoke-TimedModuleFileLoad -Name "Scoop 工具链" -ModulePath $scoopModulePath -Condition {
        (Test-Path $scoopModulePath) -and (Get-Command scoop -ErrorAction SilentlyContinue)
    } | Out-Null
    
    # Starship 提示符
    Invoke-ConditionalLoad "modules/tools/starship.ps1" { 
        Get-Command starship -ErrorAction SilentlyContinue 
    } "Starship 提示符" | Out-Null
    
    # 搜索工具集成
    Invoke-ConditionalLoad "modules/tools/search.ps1" { 
        (Get-Command fd -ErrorAction SilentlyContinue) -or 
        (Get-Command rg -ErrorAction SilentlyContinue) -or
        (Get-Command fzf -ErrorAction SilentlyContinue)
    } "高级搜索工具" | Out-Null
    
    # 智能路由系统
    Invoke-ConditionalLoad "modules/core/router.ps1" { $true } "智能命令路由" | Out-Null
    
    # 跨平台操作 - 直接加载
    $crossplatformModulePath = Join-Path $script:PWSH_CONFIG_DIR "modules/core/crossplatform.ps1"
    Invoke-TimedModuleFileLoad -Name "跨平台文件操作" -ModulePath $crossplatformModulePath -Condition {
        Test-Path $crossplatformModulePath
    } | Out-Null
    
    # === Phase 3: 高级工具集成 ===
    Write-ProfileLog "加载 Phase 3 高级工具"
    
    # Windows 功能深度集成 - 直接加载
    $windowsModulePath = Join-Path $script:PWSH_CONFIG_DIR "modules/platform/windows.ps1"
    Invoke-TimedModuleFileLoad -Name "Windows 深度功能" -ModulePath $windowsModulePath -Condition {
        (Test-Path $windowsModulePath) -and ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6))
    } | Out-Null
    
    # 系统监控工具 - 直接加载
    $monitoringModulePath = Join-Path $script:PWSH_CONFIG_DIR "modules/tools/monitoring.ps1"
    Invoke-TimedModuleFileLoad -Name "系统监控工具" -ModulePath $monitoringModulePath -Condition {
        Test-Path $monitoringModulePath
    } | Out-Null
    
    # 开发环境集成 - 直接加载
    $devenvModulePath = Join-Path $script:PWSH_CONFIG_DIR "modules/tools/devenv.ps1"
    Invoke-TimedModuleFileLoad -Name "开发环境集成" -ModulePath $devenvModulePath -Condition {
        Test-Path $devenvModulePath
    } | Out-Null
}

# === 私有配置加载 ===
Write-ProfileLog "加载私有配置"

# 私有配置 (不被版本控制)
$privateConfig = Join-Path $script:PWSH_PRIVATE_DIR "config.ps1"
if (Test-Path $privateConfig) {
    if (Invoke-TimedModuleLoad -Name "私有配置" -Path $privateConfig) {
        Write-ProfileLog "已加载私有配置"
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

if ($env:PWSH_PROFILE_TIMING -eq "1") {
    if ($env:PWSH_PROFILE_TIMING_JSON -eq "1") {
        $timingPayload = @{
            ProfileLoadMs = [math]::Round($script:ProfileLoadTime, 2)
            ModuleTimings = $script:ProfileModuleLoadStats
        }
        Write-Output "__PWSH_MODULE_TIMING_JSON_START__"
        $timingPayload | ConvertTo-Json -Depth 5 -Compress
        Write-Output "__PWSH_MODULE_TIMING_JSON_END__"
    } else {
        Show-PowerShellProfileModuleTimings -Top 50
    }
}

# 若主流程中性能模块未加载成功（如条件加载被跳过、导入失败），兜底加载测量函数
if (-not (Get-Command Measure-PowerShellStartup -ErrorAction SilentlyContinue)) {
    $benchmarkFallbackPath = Join-Path $script:PWSH_CONFIG_DIR "modules/performance/benchmark.ps1"
    if (Test-Path $benchmarkFallbackPath) {
        try {
            . $benchmarkFallbackPath
        } catch {
            Write-ProfileLog "性能模块兜底加载失败: $($_.Exception.Message)" "WARN"
        }
    } else {
        Write-ProfileLog "性能模块不存在: $benchmarkFallbackPath" "WARN"
    }
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
