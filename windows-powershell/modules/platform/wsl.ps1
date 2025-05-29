# WSL Deep Integration Module
# 深度集成 WSL 功能，提供跨平台操作和无缝体验

# 存储模块状态
$script:WSLAvailable = $null
$script:WSLDistros = @{}
$script:WSLDefaultDistro = $null

function Test-WSLAvailability {
    <#
    .SYNOPSIS
    检查 WSL 是否可用
    .DESCRIPTION
    检测系统是否安装了 WSL 并且可以正常使用
    #>
    if ($null -eq $script:WSLAvailable) {
        try {
            $result = wsl --status 2>$null
            $script:WSLAvailable = $LASTEXITCODE -eq 0
        }
        catch {
            $script:WSLAvailable = $false
        }
    }
    return $script:WSLAvailable
}

function Get-WSLDistros {
    <#
    .SYNOPSIS
    获取已安装的 WSL 发行版列表
    .DESCRIPTION
    返回所有已安装的 WSL 发行版信息
    #>
    if (-not (Test-WSLAvailability)) {
        Write-Warning "WSL 不可用"
        return @()
    }
    
    try {
        $distros = wsl --list --verbose | Select-Object -Skip 1
        $result = @()
        
        foreach ($line in $distros) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            
            $parts = $line -split '\s+' | Where-Object { $_ -ne '' }
            if ($parts.Count -ge 2) {
                $name = $parts[0] -replace '\*', ''  # 移除默认标记
                $isDefault = $parts[0].Contains('*')
                $state = $parts[1]
                $version = if ($parts.Count -gt 2) { $parts[2] } else { "1" }
                
                $result += [PSCustomObject]@{
                    Name = $name
                    State = $state
                    Version = $version
                    IsDefault = $isDefault
                }
                
                if ($isDefault) {
                    $script:WSLDefaultDistro = $name
                }
            }
        }
        
        $script:WSLDistros = $result
        return $result
    }
    catch {
        Write-Error "获取 WSL 发行版列表失败: $_"
        return @()
    }
}

function Start-WSLDistro {
    <#
    .SYNOPSIS
    启动指定的 WSL 发行版
    .PARAMETER Distro
    发行版名称，如果不指定则使用默认发行版
    #>
    param(
        [string]$Distro
    )
    
    if (-not (Test-WSLAvailability)) {
        Write-Error "WSL 不可用"
        return
    }
    
    if ([string]::IsNullOrEmpty($Distro)) {
        if ([string]::IsNullOrEmpty($script:WSLDefaultDistro)) {
            Get-WSLDistros | Out-Null
        }
        $Distro = $script:WSLDefaultDistro
    }
    
    if ([string]::IsNullOrEmpty($Distro)) {
        Write-Error "未找到可用的 WSL 发行版"
        return
    }
    
    try {
        Write-Host "🐧 启动 WSL 发行版: $Distro" -ForegroundColor Green
        wsl --distribution $Distro
    }
    catch {
        Write-Error "启动 WSL 发行版失败: $_"
    }
}

function Stop-WSLDistro {
    <#
    .SYNOPSIS
    停止指定的 WSL 发行版
    .PARAMETER Distro
    发行版名称，如果不指定则停止所有运行的发行版
    #>
    param(
        [string]$Distro
    )
    
    if (-not (Test-WSLAvailability)) {
        Write-Error "WSL 不可用"
        return
    }
    
    try {
        if ([string]::IsNullOrEmpty($Distro)) {
            Write-Host "🛑 停止所有 WSL 发行版" -ForegroundColor Yellow
            wsl --shutdown
        } else {
            Write-Host "🛑 停止 WSL 发行版: $Distro" -ForegroundColor Yellow
            wsl --terminate $Distro
        }
    }
    catch {
        Write-Error "停止 WSL 发行版失败: $_"
    }
}

function Get-WSLStatus {
    <#
    .SYNOPSIS
    获取 WSL 状态信息
    .DESCRIPTION
    显示所有 WSL 发行版的状态和系统信息
    #>
    if (-not (Test-WSLAvailability)) {
        Write-Warning "WSL 不可用"
        return
    }
    
    Write-Host "🐧 WSL 状态信息" -ForegroundColor Cyan
    Write-Host "=" * 50
    
    # WSL 版本信息
    try {
        Write-Host "`n📋 WSL 版本信息:" -ForegroundColor Green
        wsl --status
        
        Write-Host "`n📦 已安装的发行版:" -ForegroundColor Green
        $distros = Get-WSLDistros
        if ($distros.Count -eq 0) {
            Write-Host "   无已安装的发行版" -ForegroundColor Yellow
        } else {
            $distros | Format-Table Name, State, Version, @{
                Label="Default"; Expression={ if ($_.IsDefault) { "✓" } else { "" } }
            } -AutoSize
        }
        
        # 显示正在运行的发行版
        Write-Host "`n🏃 运行状态:" -ForegroundColor Green
        $running = $distros | Where-Object { $_.State -eq "Running" }
        if ($running.Count -eq 0) {
            Write-Host "   无正在运行的发行版" -ForegroundColor Yellow
        } else {
            $running | ForEach-Object {
                Write-Host "   ✅ $($_.Name) - $($_.State)" -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Error "获取 WSL 状态失败: $_"
    }
}

function Convert-WindowsPath {
    <#
    .SYNOPSIS
    将 Windows 路径转换为 WSL 路径
    .PARAMETER Path
    Windows 路径
    .PARAMETER Distro
    目标发行版，默认使用默认发行版
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [string]$Distro
    )
    
    if (-not (Test-WSLAvailability)) {
        Write-Error "WSL 不可用"
        return $Path
    }
    
    try {
        $cmd = if ([string]::IsNullOrEmpty($Distro)) {
            "wsl wslpath '$Path'"
        } else {
            "wsl --distribution $Distro wslpath '$Path'"
        }
        
        $result = Invoke-Expression $cmd
        return $result.Trim()
    }
    catch {
        Write-Error "路径转换失败: $_"
        return $Path
    }
}

function Convert-WSLPath {
    <#
    .SYNOPSIS
    将 WSL 路径转换为 Windows 路径
    .PARAMETER Path
    WSL 路径
    .PARAMETER Distro
    源发行版，默认使用默认发行版
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [string]$Distro
    )
    
    if (-not (Test-WSLAvailability)) {
        Write-Error "WSL 不可用"
        return $Path
    }
    
    try {
        $cmd = if ([string]::IsNullOrEmpty($Distro)) {
            "wsl wslpath -w '$Path'"
        } else {
            "wsl --distribution $Distro wslpath -w '$Path'"
        }
        
        $result = Invoke-Expression $cmd
        return $result.Trim()
    }
    catch {
        Write-Error "路径转换失败: $_"
        return $Path
    }
}

function Copy-ToWSL {
    <#
    .SYNOPSIS
    复制文件到 WSL 发行版
    .PARAMETER Source
    源文件路径（Windows）
    .PARAMETER Destination
    目标路径（WSL）
    .PARAMETER Distro
    目标发行版
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Source,
        [Parameter(Mandatory)]
        [string]$Destination,
        [string]$Distro
    )
    
    if (-not (Test-WSLAvailability)) {
        Write-Error "WSL 不可用"
        return
    }
    
    try {
        $wslSource = Convert-WindowsPath -Path $Source -Distro $Distro
        Write-Host "📂 复制文件到 WSL: $Source -> $Destination" -ForegroundColor Blue
        
        $cmd = if ([string]::IsNullOrEmpty($Distro)) {
            "wsl cp '$wslSource' '$Destination'"
        } else {
            "wsl --distribution $Distro cp '$wslSource' '$Destination'"
        }
        
        Invoke-Expression $cmd
        Write-Host "✅ 复制完成" -ForegroundColor Green
    }
    catch {
        Write-Error "复制到 WSL 失败: $_"
    }
}

function Copy-FromWSL {
    <#
    .SYNOPSIS
    从 WSL 发行版复制文件
    .PARAMETER Source
    源文件路径（WSL）
    .PARAMETER Destination
    目标路径（Windows）
    .PARAMETER Distro
    源发行版
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Source,
        [Parameter(Mandatory)]
        [string]$Destination,
        [string]$Distro
    )
    
    if (-not (Test-WSLAvailability)) {
        Write-Error "WSL 不可用"
        return
    }
    
    try {
        Write-Host "📂 从 WSL 复制文件: $Source -> $Destination" -ForegroundColor Blue
        
        $cmd = if ([string]::IsNullOrEmpty($Distro)) {
            "wsl cat '$Source'"
        } else {
            "wsl --distribution $Distro cat '$Source'"
        }
        
        $content = Invoke-Expression $cmd
        $content | Out-File -FilePath $Destination -Encoding UTF8
        Write-Host "✅ 复制完成" -ForegroundColor Green
    }
    catch {
        Write-Error "从 WSL 复制失败: $_"
    }
}

function Sync-WSLConfig {
    <#
    .SYNOPSIS
    同步配置文件到 WSL
    .PARAMETER ConfigType
    配置类型: git, zsh, vim, all
    .PARAMETER Distro
    目标发行版
    #>
    param(
        [ValidateSet("git", "zsh", "vim", "all")]
        [string]$ConfigType = "all",
        [string]$Distro
    )
    
    if (-not (Test-WSLAvailability)) {
        Write-Error "WSL 不可用"
        return
    }
    
    Write-Host "🔄 同步配置到 WSL ($ConfigType)" -ForegroundColor Cyan
    
    try {
        $dotfilesPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        
        if ($ConfigType -eq "git" -or $ConfigType -eq "all") {
            $gitConfigWin = Join-Path $env:USERPROFILE ".gitconfig"
            if (Test-Path $gitConfigWin) {
                $cmd = if ([string]::IsNullOrEmpty($Distro)) {
                    "wsl cp '$gitConfigWin' ~/.gitconfig"
                } else {
                    "wsl --distribution $Distro cp '$gitConfigWin' ~/.gitconfig"
                }
                Invoke-Expression $cmd
                Write-Host "✅ Git 配置已同步" -ForegroundColor Green
            }
        }
        
        if ($ConfigType -eq "zsh" -or $ConfigType -eq "all") {
            $zshPath = Join-Path $dotfilesPath "zsh"
            if (Test-Path $zshPath) {
                $wslZshPath = Convert-WindowsPath -Path $zshPath -Distro $Distro
                $cmd = if ([string]::IsNullOrEmpty($Distro)) {
                    "wsl ln -sf '$wslZshPath/.zshrc' ~/.zshrc"
                } else {
                    "wsl --distribution $Distro ln -sf '$wslZshPath/.zshrc' ~/.zshrc"
                }
                Invoke-Expression $cmd
                Write-Host "✅ ZSH 配置已同步" -ForegroundColor Green
            }
        }
        
        Write-Host "🎉 配置同步完成" -ForegroundColor Green
    }
    catch {
        Write-Error "配置同步失败: $_"
    }
}

# WSL 命令包装器
function Invoke-WSLCommand {
    <#
    .SYNOPSIS
    在 WSL 中执行命令
    .PARAMETER Command
    要执行的命令
    .PARAMETER Distro
    目标发行版
    .PARAMETER WorkingDirectory
    工作目录（WSL 路径）
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Command,
        [string]$Distro,
        [string]$WorkingDirectory
    )
    
    if (-not (Test-WSLAvailability)) {
        Write-Error "WSL 不可用"
        return
    }
    
    try {
        $fullCommand = $Command
        
        if (-not [string]::IsNullOrEmpty($WorkingDirectory)) {
            $fullCommand = "cd '$WorkingDirectory' && $Command"
        }
        
        if ([string]::IsNullOrEmpty($Distro)) {
            wsl bash -c $fullCommand
        } else {
            wsl --distribution $Distro bash -c $fullCommand
        }
    }
    catch {
        Write-Error "WSL 命令执行失败: $_"
    }
}

# 常用 WSL 别名和函数
function wsl-ls { Invoke-WSLCommand "ls $args" }
function wsl-grep { Invoke-WSLCommand "grep $args" }
function wsl-find { Invoke-WSLCommand "find $args" }
function wsl-vim { Invoke-WSLCommand "vim $args" }
function wsl-git { Invoke-WSLCommand "git $args" }
function wsl-docker { Invoke-WSLCommand "docker $args" }
function wsl-kubectl { Invoke-WSLCommand "kubectl $args" }

# 别名
Set-Alias -Name wstart -Value Start-WSLDistro
Set-Alias -Name wstop -Value Stop-WSLDistro
Set-Alias -Name wstatus -Value Get-WSLStatus
Set-Alias -Name wpath -Value Convert-WindowsPath
Set-Alias -Name wslpath -Value Convert-WSLPath
Set-Alias -Name wsync -Value Sync-WSLConfig

# 模块初始化
if (Test-WSLAvailability) {
    Write-Host "🐧 WSL 集成已加载" -ForegroundColor Green
    
    # 缓存发行版信息
    Get-WSLDistros | Out-Null
} else {
    Write-Host "⚠️  WSL 不可用，WSL 功能已禁用" -ForegroundColor Yellow
}

# Note: Functions and aliases are automatically available when dot-sourced