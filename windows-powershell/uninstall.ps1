# PowerShell 现代工具链卸载脚本
# 安全地移除配置文件和软链接

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$Force,
    [switch]$KeepCache,
    [switch]$KeepPrivateConfig,
    [switch]$RemoveTools
)

# 获取脚本目录
$ScriptRoot = $PSScriptRoot
if (!$ScriptRoot) {
    $ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
}

# 配置路径
$ProfilePath = $PROFILE
$ConfigDir = "$env:USERPROFILE\.config\powershell"
$CacheDir = "$env:USERPROFILE\.cache\powershell"
$PrivateDir = "$ConfigDir\private"

# 日志函数
function Write-UninstallLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        "SUCCESS" { "Green" }
        default { "White" }
    }
    
    $icon = switch ($Level) {
        "ERROR" { "❌" }
        "WARN" { "⚠️" }
        "SUCCESS" { "✅" }
        default { "ℹ️" }
    }
    
    Write-Host "$icon $Message" -ForegroundColor $color
}

# 确认函数
function Confirm-Action {
    param(
        [string]$Message,
        [switch]$Force
    )
    
    if ($Force) { return $true }
    
    $response = Read-Host "$Message (y/N)"
    return $response -match '^[Yy]'
}

# 安全移除文件或目录
function Remove-SafeItem {
    param(
        [string]$Path,
        [string]$Description,
        [switch]$Recurse
    )
    
    if (-not (Test-Path $Path)) {
        Write-UninstallLog "$Description 不存在，跳过" "WARN"
        return
    }
    
    try {
        if ($Recurse) {
            Remove-Item $Path -Recurse -Force -ErrorAction Stop
        } else {
            Remove-Item $Path -Force -ErrorAction Stop
        }
        Write-UninstallLog "已移除 $Description" "SUCCESS"
    } catch {
        Write-UninstallLog "移除 $Description 失败: $_" "ERROR"
    }
}

# 检查是否为软链接
function Test-SymbolicLink {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) { return $false }
    
    $item = Get-Item $Path
    return ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -eq [System.IO.FileAttributes]::ReparsePoint
}

# 主卸载函数
function Start-Uninstall {
    Write-Host "🗑️ PowerShell 现代工具链卸载程序" -ForegroundColor Red
    Write-Host "=" * 60 -ForegroundColor Red
    Write-Host ""
    
    Write-Host "此操作将移除以下内容：" -ForegroundColor Yellow
    Write-Host "  • PowerShell Profile 配置文件" -ForegroundColor Yellow
    Write-Host "  • 模块软链接" -ForegroundColor Yellow
    
    if (-not $KeepCache) {
        Write-Host "  • 缓存文件" -ForegroundColor Yellow
    }
    
    if (-not $KeepPrivateConfig) {
        Write-Host "  • 私有配置文件" -ForegroundColor Yellow
    }
    
    if ($RemoveTools) {
        Write-Host "  • 已安装的工具 (通过 Scoop)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    
    if (-not (Confirm-Action "确认继续卸载?" -Force:$Force)) {
        Write-UninstallLog "卸载已取消" "WARN"
        return
    }
    
    Write-Host ""
    Write-Host "开始卸载..." -ForegroundColor Cyan
    Write-Host ""
    
    # 1. 备份当前 Profile（如果不是软链接）
    if (Test-Path $ProfilePath) {
        if (Test-SymbolicLink $ProfilePath) {
            Write-UninstallLog "检测到 Profile 软链接，准备移除" "INFO"
        } else {
            $backupPath = "$ProfilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            try {
                Copy-Item $ProfilePath $backupPath
                Write-UninstallLog "Profile 已备份到: $backupPath" "SUCCESS"
            } catch {
                Write-UninstallLog "备份 Profile 失败: $_" "ERROR"
            }
        }
    }
    
    # 2. 移除 Profile 软链接或配置
    if (Test-Path $ProfilePath) {
        if (Test-SymbolicLink $ProfilePath -or (Confirm-Action "移除现有 Profile 文件?" -Force:$Force)) {
            Remove-SafeItem $ProfilePath "PowerShell Profile"
        }
    }
    
    # 3. 移除模块软链接
    $moduleLink = "$ConfigDir\modules"
    if (Test-Path $moduleLink) {
        if (Test-SymbolicLink $moduleLink) {
            Remove-SafeItem $moduleLink "模块软链接"
        } else {
            Write-UninstallLog "模块目录不是软链接，请手动检查: $moduleLink" "WARN"
        }
    }
    
    # 4. 移除缓存
    if (-not $KeepCache -and (Test-Path $CacheDir)) {
        if (Confirm-Action "移除缓存目录?" -Force:$Force) {
            Remove-SafeItem $CacheDir "缓存目录" -Recurse
        }
    }
    
    # 5. 移除私有配置
    if (-not $KeepPrivateConfig -and (Test-Path $PrivateDir)) {
        if (Confirm-Action "移除私有配置?" -Force:$Force) {
            Remove-SafeItem $PrivateDir "私有配置目录" -Recurse
        }
    }
    
    # 6. 清理空的配置目录
    if (Test-Path $ConfigDir) {
        $items = Get-ChildItem $ConfigDir -ErrorAction SilentlyContinue
        if (-not $items -or $items.Count -eq 0) {
            Remove-SafeItem $ConfigDir "空的配置目录"
        } else {
            Write-UninstallLog "配置目录非空，保留: $ConfigDir" "INFO"
        }
    }
    
    # 7. 移除工具（可选）
    if ($RemoveTools) {
        Write-Host ""
        Write-UninstallLog "开始移除已安装的工具..." "INFO"
        
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            $toolsToRemove = @(
                'starship', 'eza', 'zoxide', 'fzf', 'ripgrep', 'fd', 'bat', 'delta',
                'lazygit', 'gh', 'bottom', 'procs', 'duf', 'dust', 'fastfetch'
            )
            
            foreach ($tool in $toolsToRemove) {
                try {
                    $installed = scoop list $tool 2>$null
                    if ($installed) {
                        if (Confirm-Action "移除工具: $tool?" -Force:$Force) {
                            scoop uninstall $tool
                            Write-UninstallLog "已移除工具: $tool" "SUCCESS"
                        }
                    }
                } catch {
                    Write-UninstallLog "检查工具 $tool 时出错: $_" "WARN"
                }
            }
        } else {
            Write-UninstallLog "Scoop 未安装或不可用，跳过工具移除" "WARN"
        }
    }
    
    # 8. 清理环境变量
    Write-Host ""
    Write-UninstallLog "清理环境变量..." "INFO"
    
    $envVarsToRemove = @('STARSHIP_CONFIG', 'PWSH_DEBUG', 'PWSH_NO_WELCOME')
    foreach ($envVar in $envVarsToRemove) {
        try {
            [Environment]::SetEnvironmentVariable($envVar, $null, 'User')
            Write-UninstallLog "已清理环境变量: $envVar" "SUCCESS"
        } catch {
            Write-UninstallLog "清理环境变量 $envVar 失败: $_" "WARN"
        }
    }
    
    Write-Host ""
    Write-Host "🎉 卸载完成！" -ForegroundColor Green
    Write-Host ""
    Write-Host "清理摘要：" -ForegroundColor Cyan
    Write-Host "  • PowerShell 配置已移除" -ForegroundColor White
    
    if (-not $KeepCache) {
        Write-Host "  • 缓存文件已清理" -ForegroundColor White
    } else {
        Write-Host "  • 缓存文件已保留" -ForegroundColor Yellow
    }
    
    if (-not $KeepPrivateConfig) {
        Write-Host "  • 私有配置已移除" -ForegroundColor White
    } else {
        Write-Host "  • 私有配置已保留" -ForegroundColor Yellow
    }
    
    if ($RemoveTools) {
        Write-Host "  • 相关工具已移除" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "注意事项：" -ForegroundColor Yellow
    Write-Host "  • 建议重启 PowerShell 以确保所有更改生效" -ForegroundColor Yellow
    Write-Host "  • 备份文件（如有）请手动清理" -ForegroundColor Yellow
    
    if ($RemoveTools -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "  • Scoop 本身未被移除，如需移除请手动执行" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "感谢使用 PowerShell 现代工具链！" -ForegroundColor Green
}

# 显示帮助信息
function Show-UninstallHelp {
    Write-Host "PowerShell 现代工具链卸载脚本" -ForegroundColor Green
    Write-Host ""
    Write-Host "用法:" -ForegroundColor Yellow
    Write-Host "  .\uninstall.ps1 [参数]"
    Write-Host ""
    Write-Host "参数:" -ForegroundColor Yellow
    Write-Host "  -Force              : 跳过所有确认提示"
    Write-Host "  -KeepCache          : 保留缓存文件"
    Write-Host "  -KeepPrivateConfig  : 保留私有配置"
    Write-Host "  -RemoveTools        : 同时移除已安装的工具"
    Write-Host "  -WhatIf             : 显示将要执行的操作但不执行"
    Write-Host "  -Help               : 显示此帮助信息"
    Write-Host ""
    Write-Host "示例:" -ForegroundColor Yellow
    Write-Host "  .\uninstall.ps1                          # 交互式卸载"
    Write-Host "  .\uninstall.ps1 -Force                   # 静默卸载"
    Write-Host "  .\uninstall.ps1 -KeepCache               # 卸载但保留缓存"
    Write-Host "  .\uninstall.ps1 -RemoveTools -Force      # 完全卸载包括工具"
    Write-Host "  .\uninstall.ps1 -WhatIf                  # 预览操作"
}

# 主逻辑
if ($args -contains '-Help' -or $args -contains '--help' -or $args -contains '/?') {
    Show-UninstallHelp
    exit 0
}

if ($WhatIf) {
    Write-Host "预览模式 - 以下操作将被执行：" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. 检查并移除 PowerShell Profile: $ProfilePath"
    Write-Host "2. 移除模块软链接: $ConfigDir\modules"
    
    if (-not $KeepCache) {
        Write-Host "3. 移除缓存目录: $CacheDir"
    }
    
    if (-not $KeepPrivateConfig) {
        Write-Host "4. 移除私有配置: $PrivateDir"
    }
    
    if ($RemoveTools) {
        Write-Host "5. 移除相关工具（通过 Scoop）"
    }
    
    Write-Host "6. 清理环境变量"
    Write-Host ""
    Write-Host "使用不带 -WhatIf 的参数来执行实际卸载操作。"
    exit 0
}

# 检查权限
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-UninstallLog "建议以管理员身份运行以确保完全清理" "WARN"
    Write-Host ""
}

# 执行卸载
try {
    Start-Uninstall
} catch {
    Write-UninstallLog "卸载过程中发生错误: $_" "ERROR"
    Write-Host ""
    Write-Host "如果问题持续，请手动清理以下位置：" -ForegroundColor Yellow
    Write-Host "  • $ProfilePath"
    Write-Host "  • $ConfigDir"
    Write-Host "  • $CacheDir"
    exit 1
}