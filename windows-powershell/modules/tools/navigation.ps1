# 现代文件导航系统
# 深度集成 eza + zoxide + fzf，提供类似 ZSH 的导航体验

# eza 配置和别名
$script:EzaInstalled = $null
$script:ZoxideInstalled = $null  
$script:FzfInstalled = $null

# 检查现代工具是否已安装
function Test-ModernNavTools {
    if ($null -eq $script:EzaInstalled) {
        $script:EzaInstalled = [bool](Get-Command eza -ErrorAction SilentlyContinue)
    }
    if ($null -eq $script:ZoxideInstalled) {
        $script:ZoxideInstalled = [bool](Get-Command zoxide -ErrorAction SilentlyContinue)
    }
    if ($null -eq $script:FzfInstalled) {
        $script:FzfInstalled = [bool](Get-Command fzf -ErrorAction SilentlyContinue)
    }
    
    return @{
        Eza = $script:EzaInstalled
        Zoxide = $script:ZoxideInstalled
        Fzf = $script:FzfInstalled
    }
}

# 安装缺失的导航工具
function Install-NavigationTools {
    [CmdletBinding()]
    param(
        [switch]$Force
    )
    
    $tools = Test-ModernNavTools
    $missing = @()
    
    if (!$tools.Eza) { $missing += 'eza' }
    if (!$tools.Zoxide) { $missing += 'zoxide' }
    if (!$tools.Fzf) { $missing += 'fzf' }
    
    if ($missing.Count -eq 0 -and !$Force) {
        Write-Host "✅ 所有导航工具都已安装" -ForegroundColor Green
        return $true
    }
    
    if ($missing.Count -gt 0) {
        Write-Host "📥 安装缺失的导航工具: $($missing -join ', ')" -ForegroundColor Cyan
        
        if (Get-Command Install-ScoopTool -ErrorAction SilentlyContinue) {
            Install-ScoopTool -Tools $missing -Force:$Force
        } else {
            Write-Host "❌ 请先安装 Scoop 工具链或手动安装以下工具:" -ForegroundColor Red
            $missing | ForEach-Object { Write-Host "  • $_" -ForegroundColor Yellow }
            return $false
        }
    }
    
    # 重新检查安装状态
    $script:EzaInstalled = $null
    $script:ZoxideInstalled = $null
    $script:FzfInstalled = $null
    
    return $true
}

# === EZA 文件列表增强 ===

# 基础 ls 替代 - 详细列表
function ll {
    param(
        [string]$Path = ".",
        [switch]$All,
        [switch]$Tree,
        [int]$Level = 2
    )
    
    if (!(Test-ModernNavTools).Eza) {
        Write-Host "⚠️  eza 未安装，使用原生 Get-ChildItem" -ForegroundColor Yellow
        if ($All) {
            Get-ChildItem -Path $Path -Force | Format-Table -AutoSize
        } else {
            Get-ChildItem -Path $Path | Format-Table -AutoSize
        }
        return
    }
    
    $args = @('--long', '--all', '--group-directories-first', '--git')
    
    # 添加图标支持 (如果终端支持)
    if ($env:WT_SESSION -or $env:TERM_PROGRAM) {
        $args += '--icons'
    }
    
    if ($Tree) {
        $args += @('--tree', "--level=$Level")
    }
    
    if ($All) {
        $args += '--all'
    }
    
    $args += $Path
    
    & eza @args
}

# 显示所有文件 (包括隐藏)
function la {
    param([string]$Path = ".")
    ll -Path $Path -All
}

# 树形显示
function lt {
    param(
        [string]$Path = ".", 
        [int]$Level = 2
    )
    ll -Path $Path -Tree -Level $Level
}

# 按大小排序显示
function lz {
    param([string]$Path = ".")
    
    if (!(Test-ModernNavTools).Eza) {
        Get-ChildItem -Path $Path | Sort-Object Length -Descending | Format-Table Name, Length, LastWriteTime -AutoSize
        return
    }
    
    $args = @('--long', '--all', '--group-directories-first', '--sort=size', '--reverse')
    if ($env:WT_SESSION -or $env:TERM_PROGRAM) {
        $args += '--icons'
    }
    $args += $Path
    
    & eza @args
}

# 按修改时间排序显示  
function lr {
    param([string]$Path = ".")
    
    if (!(Test-ModernNavTools).Eza) {
        Get-ChildItem -Path $Path | Sort-Object LastWriteTime -Descending | Format-Table Name, LastWriteTime, Length -AutoSize
        return
    }
    
    $args = @('--long', '--all', '--group-directories-first', '--sort=modified', '--reverse')
    if ($env:WT_SESSION -or $env:TERM_PROGRAM) {
        $args += '--icons'
    }
    $args += $Path
    
    & eza @args
}

# 只显示目录
function ld {
    param([string]$Path = ".")
    
    if (!(Test-ModernNavTools).Eza) {
        Get-ChildItem -Path $Path -Directory | Format-Table Name, LastWriteTime -AutoSize
        return
    }
    
    $args = @('--long', '--only-dirs', '--group-directories-first')
    if ($env:WT_SESSION -or $env:TERM_PROGRAM) {
        $args += '--icons'
    }
    $args += $Path
    
    & eza @args
}

# 网格显示
function lg {
    param([string]$Path = ".")
    
    if (!(Test-ModernNavTools).Eza) {
        Get-ChildItem -Path $Path | Format-Wide -AutoSize
        return
    }
    
    $args = @('--grid', '--all')
    if ($env:WT_SESSION -or $env:TERM_PROGRAM) {
        $args += '--icons'
    }
    $args += $Path
    
    & eza @args
}

# === ZOXIDE 智能跳转 ===

# 初始化 zoxide (如果可用)
function Initialize-Zoxide {
    if (!(Test-ModernNavTools).Zoxide) {
        Write-ProfileLog "zoxide 未安装，跳过初始化" -Level "DEBUG"
        return $false
    }
    
    try {
        # 初始化 zoxide 集成
        Invoke-Expression (& zoxide init powershell | Out-String)
        Write-ProfileLog "zoxide 初始化成功" -Level "DEBUG"
        return $true
    } catch {
        Write-ProfileLog "zoxide 初始化失败: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

# 智能 cd 函数 (z)
function z {
    param([string]$Query)
    
    if (!(Test-ModernNavTools).Zoxide) {
        Write-Host "⚠️  zoxide 未安装，使用普通 cd" -ForegroundColor Yellow
        if ($Query) {
            Set-Location $Query
        } else {
            Set-Location ~
        }
        return
    }
    
    if ($Query) {
        zoxide query --exclude (Get-Location).Path $Query | ForEach-Object {
            Set-Location $_
        }
    } else {
        Set-Location ~
    }
}

# 交互式目录选择 (zi)
function zi {
    param([string]$Query = "")
    
    $tools = Test-ModernNavTools
    
    if (!$tools.Zoxide) {
        Write-Host "❌ zoxide 未安装" -ForegroundColor Red
        return
    }
    
    if (!$tools.Fzf) {
        Write-Host "⚠️  fzf 未安装，使用简单模式" -ForegroundColor Yellow
        $dirs = zoxide query --list $Query | Select-Object -First 10
        if ($dirs) {
            Write-Host "📁 最近访问的目录:" -ForegroundColor Cyan
            for ($i = 0; $i -lt $dirs.Count; $i++) {
                Write-Host "  [$i] $($dirs[$i])" -ForegroundColor Yellow
            }
            $choice = Read-Host "选择目录 (0-$($dirs.Count-1))"
            if ($choice -match '^\d+$' -and [int]$choice -lt $dirs.Count) {
                Set-Location $dirs[[int]$choice]
            }
        }
        return
    }
    
    try {
        $selected = zoxide query --list $Query | fzf --height=40% --reverse --header="选择目录"
        if ($selected) {
            Set-Location $selected
        }
    } catch {
        Write-Host "❌ 交互式选择失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# === FZF 增强导航 ===

# fuzzy cd - 递归搜索目录
function fcd {
    param(
        [string]$StartPath = ".",
        [int]$MaxDepth = 5
    )
    
    if (!(Test-ModernNavTools).Fzf) {
        Write-Host "❌ fzf 未安装" -ForegroundColor Red
        return
    }
    
    try {
        if ((Test-ModernNavTools).Eza) {
            # 使用 fd 如果可用，否则使用 PowerShell
            if (Get-Command fd -ErrorAction SilentlyContinue) {
                $selected = fd --type d --max-depth $MaxDepth . $StartPath | fzf --height=40% --reverse --header="选择目录"
            } else {
                $dirs = Get-ChildItem -Path $StartPath -Directory -Recurse -Depth $MaxDepth | ForEach-Object { $_.FullName }
                $selected = $dirs | fzf --height=40% --reverse --header="选择目录"
            }
        } else {
            $dirs = Get-ChildItem -Path $StartPath -Directory -Recurse -Depth $MaxDepth | ForEach-Object { $_.FullName }
            $selected = $dirs | fzf --height=40% --reverse --header="选择目录"
        }
        
        if ($selected) {
            Set-Location $selected
            Write-Host "📁 进入目录: $selected" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ fuzzy cd 失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# fuzzy open - 选择并打开文件
function fopen {
    param(
        [string]$StartPath = ".",
        [string]$Editor = $env:EDITOR
    )
    
    if (!(Test-ModernNavTools).Fzf) {
        Write-Host "❌ fzf 未安装" -ForegroundColor Red
        return
    }
    
    if (!$Editor) {
        $Editor = if (Get-Command code -ErrorAction SilentlyContinue) { 'code' }
                  elseif (Get-Command nvim -ErrorAction SilentlyContinue) { 'nvim' }
                  elseif (Get-Command notepad -ErrorAction SilentlyContinue) { 'notepad' }
                  else { $null }
    }
    
    if (!$Editor) {
        Write-Host "❌ 未找到可用的编辑器" -ForegroundColor Red
        return
    }
    
    try {
        if (Get-Command fd -ErrorAction SilentlyContinue) {
            $selected = fd --type f . $StartPath | fzf --height=40% --reverse --header="选择文件" --preview="bat --color=always --style=numbers --line-range=:500 {}" 2>$null
        } else {
            $files = Get-ChildItem -Path $StartPath -File -Recurse | ForEach-Object { $_.FullName }
            $selected = $files | fzf --height=40% --reverse --header="选择文件"
        }
        
        if ($selected) {
            Write-Host "📝 打开文件: $selected" -ForegroundColor Green
            & $Editor $selected
        }
    } catch {
        Write-Host "❌ fuzzy open 失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# fuzzy kill - 选择并终止进程
function fkill {
    if (!(Test-ModernNavTools).Fzf) {
        Write-Host "❌ fzf 未安装" -ForegroundColor Red
        return
    }
    
    try {
        $processes = Get-Process | Where-Object { $_.ProcessName -ne 'Idle' } | 
                     ForEach-Object { "$($_.Id)`t$($_.ProcessName)`t$($_.CPU)`t$($_.WorkingSet / 1MB):F1 MB" }
        
        $selected = $processes | fzf --height=40% --reverse --header="选择要终止的进程 (PID<TAB>名称<TAB>CPU<TAB>内存)" --delimiter="`t" --nth=2
        
        if ($selected) {
            $pid = ($selected -split "`t")[0]
            $name = ($selected -split "`t")[1]
            
            $confirm = Read-Host "确认终止进程 '$name' (PID: $pid)? (y/N)"
            if ($confirm -match '^[Yy]') {
                Stop-Process -Id $pid -Force
                Write-Host "✅ 已终止进程: $name (PID: $pid)" -ForegroundColor Green
            } else {
                Write-Host "❌ 取消操作" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "❌ fuzzy kill 失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# fuzzy history - 从历史记录中选择命令
function fhistory {
    if (!(Test-ModernNavTools).Fzf) {
        Write-Host "❌ fzf 未安装" -ForegroundColor Red
        return
    }
    
    try {
        $history = Get-History | ForEach-Object { $_.CommandLine } | Get-Unique
        $selected = $history | fzf --height=40% --reverse --header="选择历史命令"
        
        if ($selected) {
            Write-Host "🔄 执行命令: $selected" -ForegroundColor Green
            Invoke-Expression $selected
        }
    } catch {
        Write-Host "❌ fuzzy history 失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 快速跳转到常用目录
function fjump {
    $commonDirs = @{
        'home' = $env:USERPROFILE
        'desktop' = "$env:USERPROFILE\Desktop"
        'documents' = "$env:USERPROFILE\Documents"
        'downloads' = "$env:USERPROFILE\Downloads"
        'projects' = "$env:USERPROFILE\Projects"
        'repos' = "$env:USERPROFILE\repos"
        'dotfiles' = "$env:USERPROFILE\dotfiles"
        'temp' = $env:TEMP
    }
    
    if (!(Test-ModernNavTools).Fzf) {
        Write-Host "📁 常用目录:" -ForegroundColor Cyan
        $commonDirs.GetEnumerator() | ForEach-Object {
            Write-Host "  $($_.Key) -> $($_.Value)" -ForegroundColor Yellow
        }
        $choice = Read-Host "输入目录名"
        if ($commonDirs.ContainsKey($choice)) {
            Set-Location $commonDirs[$choice]
        }
        return
    }
    
    try {
        $options = $commonDirs.GetEnumerator() | ForEach-Object { "$($_.Key)`t$($_.Value)" }
        $selected = $options | fzf --height=40% --reverse --header="选择常用目录" --delimiter="`t" --with-nth=1 --preview="echo {2}"
        
        if ($selected) {
            $path = ($selected -split "`t")[1]
            Set-Location $path
            Write-Host "📁 进入目录: $path" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ 快速跳转失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 显示导航工具状态
function Get-NavigationStatus {
    Write-Host "🧭 导航工具状态" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    
    $tools = Test-ModernNavTools
    
    Write-Host "eza (现代 ls):  " -NoNewline
    if ($tools.Eza) {
        Write-Host "✅ 已安装" -ForegroundColor Green
        try {
            $version = eza --version 2>$null | Select-Object -First 1
            Write-Host "  版本: $version" -ForegroundColor Gray
        } catch {
            Write-Host "  版本: 未知" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ 未安装" -ForegroundColor Red
    }
    
    Write-Host "zoxide (智能 cd): " -NoNewline
    if ($tools.Zoxide) {
        Write-Host "✅ 已安装" -ForegroundColor Green
        try {
            $version = zoxide --version 2>$null
            Write-Host "  版本: $version" -ForegroundColor Gray
        } catch {
            Write-Host "  版本: 未知" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ 未安装" -ForegroundColor Red
    }
    
    Write-Host "fzf (模糊搜索): " -NoNewline
    if ($tools.Fzf) {
        Write-Host "✅ 已安装" -ForegroundColor Green
        try {
            $version = fzf --version 2>$null
            Write-Host "  版本: $version" -ForegroundColor Gray
        } catch {
            Write-Host "  版本: 未知" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ 未安装" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "💡 可用命令:" -ForegroundColor Cyan
    Write-Host "  ll, la, lt, lz, lr, ld, lg  - eza 文件列表" -ForegroundColor Yellow
    Write-Host "  z <pattern>, zi             - zoxide 智能跳转" -ForegroundColor Yellow  
    Write-Host "  fcd, fopen, fkill, fhistory - fzf 交互式操作" -ForegroundColor Yellow
    Write-Host "  fjump                       - 快速跳转常用目录" -ForegroundColor Yellow
    
    if (!$tools.Eza -or !$tools.Zoxide -or !$tools.Fzf) {
        Write-Host ""
        Write-Host "运行 Install-NavigationTools 安装缺失工具" -ForegroundColor Cyan
    }
}

# 初始化 zoxide
if ((Test-ModernNavTools).Zoxide) {
    Initialize-Zoxide
}

# 设置别名
if ((Test-ModernNavTools).Eza) {
    # 覆盖默认的 ls 别名
    Set-Alias -Name ls -Value ll -Option AllScope -Force
}

Write-ProfileLog "现代导航系统加载完成" -Level "DEBUG"