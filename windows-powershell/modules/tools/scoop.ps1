# Scoop 工具链深度包装器
# 提供智能包管理和现代 CLI 工具集成

# 预定义现代工具集合
$script:ModernTools = @{
    'Essential' = @(
        'git', 'fd', 'ripgrep', 'eza', 'fzf', 'zoxide', 'bat', 'delta',
        'starship', 'aria2'
    )
    'Development' = @(
        'gh', 'lazygit', 'bottom', 'httpie', 'jq', 'yq', 'helix',
        'nodejs', 'python', 'go', 'rustup'
    )
    'System' = @(
        'fastfetch', 'duf', 'dust', 'procs', 'hyperfine', 'tokei',
        '7zip', 'curl', 'wget', 'make', 'cmake'
    )
    'Productivity' = @(
        'tealdeer', 'glow', 'pandoc', 'imagemagick', 'ffmpeg',
        'yt-dlp', 'rclone'
    )
    'Windows' = @(
        'powertoys', 'windowsterminal', 'vcredist2022', 'directx'
    )
}

# 重要的 Scoop buckets
$script:EssentialBuckets = @(
    'main',
    'extras', 
    'nerd-fonts',
    'java',
    'versions',
    'nirsoft',
    'sysinternals'
)

# 检查 Scoop 是否已安装
function Test-ScoopInstalled {
    return (Get-Command scoop -ErrorAction SilentlyContinue) -ne $null
}

# 检查 Scoop 是否需要初始化
function Test-ScoopInitialized {
    if (!(Test-ScoopInstalled)) { return $false }
    
    try {
        scoop list | Out-Null
        return $true
    } catch {
        return $false
    }
}

# 智能安装 Scoop
function Install-Scoop {
    [CmdletBinding()]
    param(
        [string]$InstallDir = "",
        [string]$GlobalDir = "",
        [switch]$NoAria2
    )
    
    if (Test-ScoopInstalled) {
        Write-Host "✅ Scoop 已安装" -ForegroundColor Green
        return $true
    }
    
    Write-Host "🚀 安装 Scoop 包管理器..." -ForegroundColor Cyan
    
    # 设置安装目录
    if ($InstallDir) {
        $env:SCOOP = $InstallDir
        [Environment]::SetEnvironmentVariable('SCOOP', $InstallDir, 'User')
    }
    
    if ($GlobalDir) {
        $env:SCOOP_GLOBAL = $GlobalDir
        [Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $GlobalDir, 'Machine')
    }
    
    try {
        # 设置执行策略
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        
        # 安装 Scoop
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        
        if (Test-ScoopInstalled) {
            Write-Host "✅ Scoop 安装成功!" -ForegroundColor Green
            
            # 安装 aria2 (除非明确禁用)
            if (!$NoAria2) {
                Write-Host "📥 安装 aria2 下载加速器..." -ForegroundColor Yellow
                scoop install aria2
            }
            
            return $true
        }
    } catch {
        Write-Host "❌ Scoop 安装失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 添加重要的 buckets
function Add-EssentialBuckets {
    [CmdletBinding()]
    param(
        [string[]]$Buckets = $script:EssentialBuckets,
        [switch]$Force
    )
    
    if (!(Test-ScoopInstalled)) {
        Write-Host "❌ Scoop 未安装，请先运行 Install-Scoop" -ForegroundColor Red
        return $false
    }
    
    Write-Host "📦 添加重要的 Scoop buckets..." -ForegroundColor Cyan
    
    $added = 0
    $existing = scoop bucket list | ForEach-Object { $_.Name }
    
    foreach ($bucket in $Buckets) {
        if ($existing -contains $bucket -and !$Force) {
            Write-Host "  ⏭️  跳过已存在的 bucket: $bucket" -ForegroundColor Yellow
            continue
        }
        
        try {
            Write-Host "  📥 添加 bucket: $bucket" -NoNewline
            scoop bucket add $bucket 2>$null
            Write-Host " ✅" -ForegroundColor Green
            $added++
        } catch {
            Write-Host " ❌ 失败: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "🎉 成功添加 $added 个 buckets" -ForegroundColor Green
    return $true
}

# 智能工具安装
function Install-ScoopTool {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Tools,
        [switch]$Global,
        [switch]$Force,
        [switch]$NoCache
    )
    
    if (!(Test-ScoopInstialized)) {
        if (!(Install-Scoop)) {
            return $false
        }
        Add-EssentialBuckets
    }
    
    Write-Host "🔧 安装工具: $($Tools -join ', ')" -ForegroundColor Cyan
    
    $installed = @()
    $failed = @()
    $skipped = @()
    
    foreach ($tool in $Tools) {
        # 检查工具是否已安装
        if (!$Force) {
            $existing = scoop list $tool 2>$null
            if ($existing) {
                Write-Host "  ⏭️  跳过已安装: $tool" -ForegroundColor Yellow
                $skipped += $tool
                continue
            }
        }
        
        Write-Host "  📥 安装: $tool" -NoNewline
        
        try {
            $params = @($tool)
            if ($Global) { $params += '--global' }
            if ($NoCache) { $params += '--no-cache' }
            
            $result = scoop install @params 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host " ✅" -ForegroundColor Green
                $installed += $tool
            } else {
                Write-Host " ❌" -ForegroundColor Red
                $failed += $tool
                Write-Host "    错误: $result" -ForegroundColor Red
            }
        } catch {
            Write-Host " ❌ 异常: $($_.Exception.Message)" -ForegroundColor Red
            $failed += $tool
        }
    }
    
    # 显示安装结果
    Write-Host ""
    Write-Host "📊 安装结果:" -ForegroundColor Cyan
    if ($installed.Count -gt 0) {
        Write-Host "  ✅ 成功: $($installed -join ', ')" -ForegroundColor Green
    }
    if ($skipped.Count -gt 0) {
        Write-Host "  ⏭️  跳过: $($skipped -join ', ')" -ForegroundColor Yellow
    }
    if ($failed.Count -gt 0) {
        Write-Host "  ❌ 失败: $($failed -join ', ')" -ForegroundColor Red
    }
    
    return $failed.Count -eq 0
}

# 安装预定义工具套装
function Install-ToolSuite {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Essential', 'Development', 'System', 'Productivity', 'Windows', 'All')]
        [string]$Suite,
        [switch]$Global,
        [switch]$Force
    )
    
    if ($Suite -eq 'All') {
        $allTools = @()
        foreach ($category in $script:ModernTools.Keys) {
            $allTools += $script:ModernTools[$category]
        }
        $tools = $allTools | Sort-Object | Get-Unique
    } else {
        $tools = $script:ModernTools[$Suite]
    }
    
    if (!$tools) {
        Write-Host "❌ 未知的工具套装: $Suite" -ForegroundColor Red
        return $false
    }
    
    Write-Host "🎯 安装工具套装: $Suite" -ForegroundColor Cyan
    Write-Host "包含工具: $($tools -join ', ')" -ForegroundColor Gray
    Write-Host ""
    
    return Install-ScoopTool -Tools $tools -Global:$Global -Force:$Force
}

# 智能搜索包
function Search-ScoopPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Pattern,
        [int]$Limit = 20,
        [switch]$Exact
    )
    
    if (!(Test-ScoopInstalled)) {
        Write-Host "❌ Scoop 未安装" -ForegroundColor Red
        return
    }
    
    Write-Host "🔍 搜索包: $Pattern" -ForegroundColor Cyan
    
    try {
        $searchPattern = if ($Exact) { $Pattern } else { "*$Pattern*" }
        $results = scoop search $searchPattern | Select-Object -First $Limit
        
        if ($results) {
            $results | ForEach-Object {
                $parts = $_ -split '\s+'
                if ($parts.Count -ge 3) {
                    $name = $parts[0]
                    $version = $parts[1]
                    $bucket = $parts[2]
                    Write-Host "  📦 " -NoNewline -ForegroundColor Blue
                    Write-Host "$name" -NoNewline -ForegroundColor White
                    Write-Host " ($version)" -NoNewline -ForegroundColor Gray
                    Write-Host " [$bucket]" -ForegroundColor DarkGray
                }
            }
        } else {
            Write-Host "  ❌ 未找到匹配的包" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ 搜索失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 显示工具信息
function Show-ScoopToolInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Tool
    )
    
    if (!(Test-ScoopInstalled)) {
        Write-Host "❌ Scoop 未安装" -ForegroundColor Red
        return
    }
    
    Write-Host "ℹ️  工具信息: $Tool" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        # 检查是否已安装
        $installed = scoop list $Tool 2>$null
        if ($installed) {
            Write-Host "✅ 已安装" -ForegroundColor Green
            $installed | ForEach-Object {
                Write-Host "  版本: $($_.Version)" -ForegroundColor Gray
                Write-Host "  位置: $($_.Source)" -ForegroundColor Gray
            }
        } else {
            Write-Host "❌ 未安装" -ForegroundColor Red
        }
        
        Write-Host ""
        
        # 显示包信息
        scoop info $Tool
    } catch {
        Write-Host "❌ 获取信息失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 批量更新所有工具
function Update-AllScoopTools {
    [CmdletBinding()]
    param(
        [switch]$Force,
        [switch]$Global
    )
    
    if (!(Test-ScoopInstalled)) {
        Write-Host "❌ Scoop 未安装" -ForegroundColor Red
        return $false
    }
    
    Write-Host "🔄 更新所有 Scoop 工具..." -ForegroundColor Cyan
    
    try {
        # 更新 Scoop 本身和 manifests
        Write-Host "📥 更新 Scoop 和 manifests..." -ForegroundColor Yellow
        scoop update
        
        # 更新所有已安装的包
        Write-Host "📦 更新已安装的包..." -ForegroundColor Yellow
        $params = @('*')
        if ($Force) { $params += '--force' }
        if ($Global) { $params += '--global' }
        
        scoop update @params
        
        Write-Host "✅ 更新完成!" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ 更新失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 清理旧版本
function Clear-ScoopCache {
    [CmdletBinding()]
    param(
        [switch]$All,
        [switch]$Global
    )
    
    if (!(Test-ScoopInstalled)) {
        Write-Host "❌ Scoop 未安装" -ForegroundColor Red
        return
    }
    
    Write-Host "🧹 清理 Scoop 缓存..." -ForegroundColor Cyan
    
    try {
        if ($All) {
            Write-Host "📦 清理所有缓存..." -ForegroundColor Yellow
            scoop cache rm *
        }
        
        Write-Host "🗂️  清理旧版本..." -ForegroundColor Yellow
        $params = @('*')
        if ($Global) { $params += '--global' }
        scoop cleanup @params
        
        Write-Host "✅ 清理完成!" -ForegroundColor Green
    } catch {
        Write-Host "❌ 清理失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 显示 Scoop 状态
function Get-ScoopStatus {
    Write-Host "📊 Scoop 状态报告" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    Write-Host ""
    
    # 检查 Scoop 安装状态
    if (!(Test-ScoopInstalled)) {
        Write-Host "❌ Scoop 未安装" -ForegroundColor Red
        Write-Host "运行 Install-Scoop 安装 Scoop" -ForegroundColor Yellow
        return
    }
    
    Write-Host "✅ Scoop 已安装" -ForegroundColor Green
    
    # 显示版本信息
    try {
        $version = scoop --version 2>$null
        Write-Host "版本: $version" -ForegroundColor Gray
    } catch {
        Write-Host "版本: 未知" -ForegroundColor Red
    }
    
    # 显示安装目录
    if ($env:SCOOP) {
        Write-Host "安装目录: $env:SCOOP" -ForegroundColor Gray
    }
    
    Write-Host ""
    
    # 显示已安装的 buckets
    try {
        $buckets = scoop bucket list
        Write-Host "📦 已安装的 Buckets:" -ForegroundColor Cyan
        if ($buckets) {
            $buckets | ForEach-Object {
                Write-Host "  • $($_.Name)" -ForegroundColor Green
            }
        } else {
            Write-Host "  无" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  获取失败" -ForegroundColor Red
    }
    
    Write-Host ""
    
    # 显示已安装的工具数量
    try {
        $installed = scoop list
        $count = if ($installed) { $installed.Count } else { 0 }
        Write-Host "🔧 已安装工具: $count 个" -ForegroundColor Cyan
        
        if ($count -gt 0 -and $count -le 20) {
            $installed | ForEach-Object {
                Write-Host "  • $($_.Name) ($($_.Version))" -ForegroundColor Green
            }
        } elseif ($count -gt 20) {
            Write-Host "  (工具过多，使用 scoop list 查看详情)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  获取失败" -ForegroundColor Red
    }
    
    Write-Host ""
    
    # 检查是否有可更新的工具
    try {
        Write-Host "🔄 检查更新..." -ForegroundColor Cyan
        $status = scoop status
        if ($status -match "Updates are available") {
            Write-Host "  有可用更新，运行 Update-AllScoopTools 更新" -ForegroundColor Yellow
        } else {
            Write-Host "  所有工具都是最新版本" -ForegroundColor Green
        }
    } catch {
        Write-Host "  检查更新失败" -ForegroundColor Red
    }
}

# 一键开发环境搭建
function Install-DevEnvironment {
    [CmdletBinding()]
    param(
        [ValidateSet('Frontend', 'Backend', 'FullStack', 'DevOps', 'DataScience', 'Minimal')]
        [string]$Profile = 'Minimal',
        [switch]$Global
    )
    
    $environments = @{
        'Minimal' = @('git', 'fd', 'ripgrep', 'eza', 'fzf', 'zoxide', 'bat', 'starship')
        'Frontend' = @('git', 'nodejs', 'fd', 'ripgrep', 'eza', 'fzf', 'zoxide', 'bat', 'starship', 'gh')
        'Backend' = @('git', 'python', 'go', 'rustup', 'fd', 'ripgrep', 'eza', 'fzf', 'zoxide', 'bat', 'starship', 'gh', 'httpie', 'jq')
        'FullStack' = @('git', 'nodejs', 'python', 'go', 'fd', 'ripgrep', 'eza', 'fzf', 'zoxide', 'bat', 'starship', 'gh', 'httpie', 'jq', 'docker')
        'DevOps' = @('git', 'python', 'go', 'fd', 'ripgrep', 'eza', 'fzf', 'zoxide', 'bat', 'starship', 'gh', 'kubectl', 'terraform', 'docker', 'aws')
        'DataScience' = @('git', 'python', 'r', 'fd', 'ripgrep', 'eza', 'fzf', 'zoxide', 'bat', 'starship', 'gh', 'jq', 'pandoc')
    }
    
    $tools = $environments[$Profile]
    if (!$tools) {
        Write-Host "❌ 未知的环境配置: $Profile" -ForegroundColor Red
        return $false
    }
    
    Write-Host "🚀 安装 $Profile 开发环境..." -ForegroundColor Cyan
    Write-Host "包含工具: $($tools -join ', ')" -ForegroundColor Gray
    Write-Host ""
    
    # 确保 Scoop 已安装和配置
    if (!(Test-ScoopInitialized)) {
        if (!(Install-Scoop)) { return $false }
        Add-EssentialBuckets
    }
    
    # 安装工具
    $success = Install-ScoopTool -Tools $tools -Global:$Global
    
    if ($success) {
        Write-Host ""
        Write-Host "🎉 $Profile 开发环境安装完成!" -ForegroundColor Green
        Write-Host "建议重启 PowerShell 或运行 refreshenv 刷新环境变量" -ForegroundColor Yellow
    }
    
    return $success
}

# 导出配置和已安装工具
function Export-ScoopConfig {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "scoop-backup.json"
    )
    
    if (!(Test-ScoopInstalled)) {
        Write-Host "❌ Scoop 未安装" -ForegroundColor Red
        return $false
    }
    
    Write-Host "💾 导出 Scoop 配置..." -ForegroundColor Cyan
    
    try {
        $config = @{
            'timestamp' = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            'scoop_version' = (scoop --version)
            'buckets' = @()
            'installed_apps' = @()
        }
        
        # 导出 buckets
        $buckets = scoop bucket list
        if ($buckets) {
            $config.buckets = $buckets | ForEach-Object { $_.Name }
        }
        
        # 导出已安装的应用
        $apps = scoop list
        if ($apps) {
            $config.installed_apps = $apps | ForEach-Object {
                @{
                    'name' = $_.Name
                    'version' = $_.Version
                    'bucket' = $_.Source
                }
            }
        }
        
        $config | ConvertTo-Json -Depth 3 | Out-File $OutputPath -Encoding UTF8
        Write-Host "✅ 配置已导出到: $OutputPath" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ 导出失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 设置常用别名
Set-Alias -Name scoopi -Value Install-ScoopTool
Set-Alias -Name scoops -Value Search-ScoopPackage
Set-Alias -Name scoopu -Value Update-AllScoopTools
Set-Alias -Name scoopc -Value Clear-ScoopCache
Set-Alias -Name scoopst -Value Get-ScoopStatus
Set-Alias -Name scoopinfo -Value Show-ScoopToolInfo

Write-ProfileLog "Scoop 工具链包装器加载完成" -Level "DEBUG"

# 导出函数和别名
Export-ModuleMember -Function @(
    'Test-ScoopInstalled',
    'Install-Scoop',
    'Test-ScoopInitialized',
    'Add-EssentialBuckets',
    'Install-ScoopTool',
    'Search-ScoopPackage',
    'Show-ScoopToolInfo',
    'Update-AllScoopTools',
    'Clear-ScoopCache',
    'Get-ScoopStatus',
    'Install-DevEnvironment',
    'Export-ScoopConfig'
) -Alias @(
    'scoopi',
    'scoops',
    'scoopu',
    'scoopc',
    'scoopst',
    'scoopinfo'
)