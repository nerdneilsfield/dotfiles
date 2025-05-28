# PowerShell Configuration Installer
# 类似于 stow 的功能，为 PowerShell 配置创建软链接
# 需要管理员权限运行

param(
    [switch]$Uninstall,
    [switch]$Force,
    [string]$ConfigPath = $PSScriptRoot
)

# 配置路径
$DOTFILES_PWSH = $ConfigPath
$USER_PROFILE_DIR = Split-Path $PROFILE -Parent
$USER_PROFILE_FILE = $PROFILE
$PWSH_CONFIG_DIR = "$env:USERPROFILE\.config\powershell"

# 日志函数
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN"  { "Yellow" }
        "INFO"  { "Green" }
        default { "White" }
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

# 检查管理员权限
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# 创建软链接
function New-SafeSymLink {
    param(
        [string]$Target,
        [string]$Link,
        [string]$Description
    )
    
    Write-Log "创建软链接: $Description"
    Write-Log "  目标: $Target"
    Write-Log "  链接: $Link"
    
    # 检查目标是否存在
    if (!(Test-Path $Target)) {
        Write-Log "目标文件不存在: $Target" "ERROR"
        return $false
    }
    
    # 检查链接是否已存在
    if (Test-Path $Link) {
        if ($Force) {
            Write-Log "强制删除现有文件: $Link" "WARN"
            Remove-Item $Link -Force -Recurse
        } else {
            Write-Log "目标位置已存在文件，使用 -Force 强制覆盖: $Link" "WARN"
            return $false
        }
    }
    
    # 确保父目录存在
    $parentDir = Split-Path $Link -Parent
    if (!(Test-Path $parentDir)) {
        Write-Log "创建父目录: $parentDir"
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    
    try {
        # 创建软链接
        if (Test-Path $Target -PathType Container) {
            # 目录链接
            New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
        } else {
            # 文件链接
            New-Item -ItemType SymbolicLink -Path $Link -Target $Target | Out-Null
        }
        Write-Log "✅ 软链接创建成功" "INFO"
        return $true
    } catch {
        Write-Log "❌ 软链接创建失败: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# 删除软链接
function Remove-SafeSymLink {
    param(
        [string]$Link,
        [string]$Description
    )
    
    Write-Log "删除软链接: $Description"
    Write-Log "  链接: $Link"
    
    if (Test-Path $Link) {
        try {
            Remove-Item $Link -Force
            Write-Log "✅ 软链接删除成功" "INFO"
            return $true
        } catch {
            Write-Log "❌ 软链接删除失败: $($_.Exception.Message)" "ERROR"
            return $false
        }
    } else {
        Write-Log "软链接不存在，跳过删除" "WARN"
        return $true
    }
}

# 安装配置
function Install-PowerShellConfig {
    Write-Log "🚀 开始安装 PowerShell 配置..."
    
    $success = $true
    
    # 1. 创建配置目录的软链接
    if (Test-Path "$DOTFILES_PWSH\modules") {
        $success = $success -and (New-SafeSymLink -Target "$DOTFILES_PWSH\modules" -Link "$PWSH_CONFIG_DIR\modules" -Description "PowerShell 模块目录")
    }
    
    # 2. 创建主配置文件的软链接
    if (Test-Path "$DOTFILES_PWSH\Microsoft.PowerShell_profile.ps1") {
        $success = $success -and (New-SafeSymLink -Target "$DOTFILES_PWSH\Microsoft.PowerShell_profile.ps1" -Link $USER_PROFILE_FILE -Description "PowerShell 主配置文件")
    } else {
        # 如果主配置文件不存在，使用当前的 init.ps1
        if (Test-Path "$DOTFILES_PWSH\init.ps1") {
            $success = $success -and (New-SafeSymLink -Target "$DOTFILES_PWSH\init.ps1" -Link $USER_PROFILE_FILE -Description "PowerShell 主配置文件 (init.ps1)")
        }
    }
    
    # 3. 创建缓存目录
    $cacheDir = "$env:USERPROFILE\.cache\powershell"
    if (!(Test-Path $cacheDir)) {
        Write-Log "创建缓存目录: $cacheDir"
        New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
    }
    
    # 4. 创建私有配置目录
    $privateDir = "$PWSH_CONFIG_DIR\private"
    if (!(Test-Path $privateDir)) {
        Write-Log "创建私有配置目录: $privateDir"
        New-Item -ItemType Directory -Path $privateDir -Force | Out-Null
        
        # 创建示例私有配置文件
        @"
# PowerShell 私有配置
# 此文件不会被版本控制，用于存储个人设置

# 示例：个人别名
# Set-Alias -Name 'll' -Value 'Get-ChildItem'

# 示例：环境变量
# `$env:MY_PRIVATE_VAR = "value"

Write-Host "已加载私有配置" -ForegroundColor DarkGray
"@ | Out-File "$privateDir\config.ps1" -Encoding UTF8
    }
    
    if ($success) {
        Write-Log "🎉 PowerShell 配置安装完成！"
        Write-Log "请重新启动 PowerShell 或运行 '. `$PROFILE' 来加载配置"
        
        # 显示安装信息
        Write-Log ""
        Write-Log "📁 配置文件位置:"
        Write-Log "  主配置: $USER_PROFILE_FILE"
        Write-Log "  模块目录: $PWSH_CONFIG_DIR\modules"
        Write-Log "  缓存目录: $cacheDir"
        Write-Log "  私有配置: $privateDir"
    } else {
        Write-Log "❌ 配置安装过程中出现错误" "ERROR"
        exit 1
    }
}

# 卸载配置
function Uninstall-PowerShellConfig {
    Write-Log "🗑️  开始卸载 PowerShell 配置..."
    
    $success = $true
    
    # 删除软链接
    $success = $success -and (Remove-SafeSymLink -Link $USER_PROFILE_FILE -Description "PowerShell 主配置文件")
    $success = $success -and (Remove-SafeSymLink -Link "$PWSH_CONFIG_DIR\modules" -Description "PowerShell 模块目录")
    
    if ($success) {
        Write-Log "🎉 PowerShell 配置卸载完成！"
    } else {
        Write-Log "❌ 配置卸载过程中出现错误" "ERROR"
        exit 1
    }
}

# 显示当前状态
function Show-InstallStatus {
    Write-Log "📋 PowerShell 配置状态:"
    Write-Log ""
    
    # 检查主配置文件
    Write-Log "主配置文件:"
    if (Test-Path $USER_PROFILE_FILE) {
        $item = Get-Item $USER_PROFILE_FILE
        if ($item.LinkType) {
            Write-Log "  ✅ $USER_PROFILE_FILE -> $($item.Target)" "INFO"
        } else {
            Write-Log "  ⚠️  $USER_PROFILE_FILE (常规文件，非软链接)" "WARN"
        }
    } else {
        Write-Log "  ❌ $USER_PROFILE_FILE (不存在)" "ERROR"
    }
    
    # 检查模块目录
    Write-Log "模块目录:"
    $modulesPath = "$PWSH_CONFIG_DIR\modules"
    if (Test-Path $modulesPath) {
        $item = Get-Item $modulesPath
        if ($item.LinkType) {
            Write-Log "  ✅ $modulesPath -> $($item.Target)" "INFO"
        } else {
            Write-Log "  ⚠️  $modulesPath (常规目录，非软链接)" "WARN"
        }
    } else {
        Write-Log "  ❌ $modulesPath (不存在)" "ERROR"
    }
    
    # 检查缓存目录
    $cacheDir = "$env:USERPROFILE\.cache\powershell"
    Write-Log "缓存目录:"
    if (Test-Path $cacheDir) {
        Write-Log "  ✅ $cacheDir" "INFO"
    } else {
        Write-Log "  ❌ $cacheDir (不存在)" "ERROR"
    }
}

# 主逻辑
function Main {
    Write-Log "=== PowerShell 配置安装器 ==="
    Write-Log "配置路径: $DOTFILES_PWSH"
    Write-Log ""
    
    # 检查管理员权限
    if (!(Test-Administrator)) {
        Write-Log "需要管理员权限来创建软链接，请以管理员身份运行 PowerShell" "ERROR"
        Write-Log "提示：右键点击 PowerShell 图标，选择 '以管理员身份运行'" "ERROR"
        exit 1
    }
    
    if ($Uninstall) {
        Uninstall-PowerShellConfig
    } else {
        # 显示当前状态
        Show-InstallStatus
        Write-Log ""
        
        if ($Force -or !(Test-Path $USER_PROFILE_FILE)) {
            Install-PowerShellConfig
        } else {
            Write-Log "配置文件已存在，使用 -Force 参数强制重新安装" "WARN"
            Show-InstallStatus
        }
    }
}

# 如果直接运行此脚本
if ($MyInvocation.InvocationName -ne '.') {
    Main
}