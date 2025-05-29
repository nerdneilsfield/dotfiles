# 系统监控工具集成
# 提供现代化的系统监控工具包装器：bottom、procs、duf、dust 等

# 检查并安装监控工具
function Install-MonitoringTools {
    [CmdletBinding()]
    param(
        [switch]$Force
    )
    
    Write-Host "📊 安装现代监控工具..." -ForegroundColor Green
    
    $tools = @{
        'bottom' = 'ClementTsang.bottom'
        'procs' = 'dalance.procs'
        'duf' = 'muesli.duf'
        'dust' = 'bootandy.dust'
        'fastfetch' = 'Fastfetch-cli.Fastfetch'
        'btop' = 'aristocratos.btop4win'
    }
    
    foreach ($tool in $tools.Keys) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue) -or $Force) {
            Write-Host "📦 安装 $tool..." -ForegroundColor Yellow
            try {
                if (Get-Command scoop -ErrorAction SilentlyContinue) {
                    scoop install $tool
                } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
                    winget install $tools[$tool]
                } else {
                    Write-Warning "需要 Scoop 或 Winget 来安装 $tool"
                }
            } catch {
                Write-Warning "安装 $tool 失败: $_"
            }
        } else {
            Write-Host "✅ $tool 已安装" -ForegroundColor Green
        }
    }
}

# 现代化 top 命令 (bottom)
function Invoke-ModernTop {
    [CmdletBinding()]
    param(
        [switch]$Basic,
        [switch]$Tree,
        [switch]$Battery,
        [switch]$Network,
        [int]$Rate = 1000
    )
    
    if (-not (Get-Command bottom -ErrorAction SilentlyContinue)) {
        Write-Warning "bottom 未安装，正在尝试安装..."
        Install-MonitoringTools
        if (-not (Get-Command bottom -ErrorAction SilentlyContinue)) {
            Write-Error "无法安装 bottom"
            return
        }
    }
    
    $args = @()
    
    if ($Basic) { $args += '--basic' }
    if ($Tree) { $args += '--tree' }
    if ($Battery) { $args += '--battery' }
    if ($Network) { $args += '--network' }
    $args += '--rate', $Rate
    
    Write-Host "🔝 启动现代系统监控 (bottom)..." -ForegroundColor Green
    & bottom @args
}

# 现代化 ps 命令 (procs)
function Invoke-ModernPS {
    [CmdletBinding()]
    param(
        [string]$Filter,
        [switch]$Tree,
        [switch]$Watch,
        [string]$SortBy = 'cpu',
        [int]$Top = 10
    )
    
    if (-not (Get-Command procs -ErrorAction SilentlyContinue)) {
        Write-Warning "procs 未安装，正在尝试安装..."
        Install-MonitoringTools
        if (-not (Get-Command procs -ErrorAction SilentlyContinue)) {
            Write-Error "无法安装 procs"
            return
        }
    }
    
    $args = @()
    
    if ($Tree) { $args += '--tree' }
    if ($Watch) { $args += '--watch' }
    if ($SortBy) { $args += '--sortd', $SortBy }
    
    if ($Filter) {
        $args += $Filter
    }
    
    Write-Host "🔍 进程监控 (procs)..." -ForegroundColor Green
    & procs @args | Select-Object -First $Top
}

# 现代化 df 命令 (duf)
function Invoke-ModernDF {
    [CmdletBinding()]
    param(
        [switch]$HideSpecial,
        [switch]$HideLoops,
        [switch]$JSON,
        [string[]]$Only
    )
    
    if (-not (Get-Command duf -ErrorAction SilentlyContinue)) {
        Write-Warning "duf 未安装，正在尝试安装..."
        Install-MonitoringTools
        if (-not (Get-Command duf -ErrorAction SilentlyContinue)) {
            Write-Error "无法安装 duf"
            return
        }
    }
    
    $args = @()
    
    if ($HideSpecial) { $args += '--hide-special' }
    if ($HideLoops) { $args += '--hide-loops' }
    if ($JSON) { $args += '--json' }
    if ($Only) { $args += '--only', ($Only -join ',') }
    
    Write-Host "💾 磁盘使用情况 (duf)..." -ForegroundColor Green
    & duf @args
}

# 现代化 du 命令 (dust)
function Invoke-ModernDU {
    [CmdletBinding()]
    param(
        [string]$Path = ".",
        [int]$Depth = 3,
        [switch]$Reverse,
        [switch]$NoPercent,
        [int]$Number = 20
    )
    
    if (-not (Get-Command dust -ErrorAction SilentlyContinue)) {
        Write-Warning "dust 未安装，正在尝试安装..."
        Install-MonitoringTools
        if (-not (Get-Command dust -ErrorAction SilentlyContinue)) {
            Write-Error "无法安装 dust"
            return
        }
    }
    
    $args = @($Path)
    $args += '--depth', $Depth
    $args += '--number-of-lines', $Number
    
    if ($Reverse) { $args += '--reverse' }
    if ($NoPercent) { $args += '--no-percent-bar' }
    
    Write-Host "📁 目录大小分析 (dust)..." -ForegroundColor Green
    & dust @args
}

# 系统信息概览
function Get-SystemInfoModern {
    [CmdletBinding()]
    param(
        [switch]$Detailed,
        [switch]$JSON
    )
    
    if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
        Write-Host "💻 系统信息 (fastfetch)..." -ForegroundColor Green
        $args = @()
        if ($JSON) { $args += '--json' }
        & fastfetch @args
    } else {
        Write-Host "💻 系统信息 (PowerShell)..." -ForegroundColor Green
        
        # 基础系统信息
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $cpu = Get-CimInstance -ClassName Win32_Processor
        $memory = Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
        $gpu = Get-CimInstance -ClassName Win32_VideoController | Where-Object { $_.Name -notlike "*Microsoft*" } | Select-Object -First 1
        
        Write-Host "🖥️  OS: $($os.Caption) $($os.Version)" -ForegroundColor Cyan
        Write-Host "🧠 CPU: $($cpu.Name)" -ForegroundColor Yellow
        Write-Host "💾 RAM: $([math]::Round($memory.Sum / 1GB, 2)) GB" -ForegroundColor Green
        if ($gpu) {
            Write-Host "🎮 GPU: $($gpu.Name)" -ForegroundColor Magenta
        }
        Write-Host "⏰ 运行时间: $((Get-Date) - $os.LastBootUpTime)" -ForegroundColor Blue
        
        if ($Detailed) {
            Write-Host "`n📊 详细信息:" -ForegroundColor White
            Write-Host "  主板: $((Get-CimInstance Win32_BaseBoard).Product)"
            Write-Host "  BIOS: $((Get-CimInstance Win32_BIOS).SMBIOSBIOSVersion)"
            Write-Host "  网卡: $((Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.NetEnabled -eq $true } | Select-Object -First 1).Name)"
        }
    }
}

# 网络监控
function Monitor-Network {
    [CmdletBinding()]
    param(
        [int]$Interval = 2,
        [int]$Count = 10
    )
    
    Write-Host "🌐 网络监控..." -ForegroundColor Green
    
    for ($i = 0; $i -lt $Count; $i++) {
        $networkStats = Get-Counter "\Network Interface(*)\Bytes Total/sec" | 
                       Where-Object { $_.CounterSamples.InstanceName -notmatch "isatap|teredo|loopback" }
        
        Clear-Host
        Write-Host "🌐 网络流量监控 ($($i + 1)/$Count)" -ForegroundColor Green
        Write-Host "=" * 50 -ForegroundColor Gray
        
        foreach ($sample in $networkStats.CounterSamples) {
            if ($sample.CookedValue -gt 0) {
                $speed = [math]::Round($sample.CookedValue / 1MB, 2)
                Write-Host "$($sample.InstanceName): $speed MB/s"
            }
        }
        
        Start-Sleep $Interval
    }
}

# 性能监控面板
function Show-PerformanceDashboard {
    [CmdletBinding()]
    param(
        [int]$RefreshInterval = 3
    )
    
    Write-Host "📊 启动性能监控面板..." -ForegroundColor Green
    
    while ($true) {
        Clear-Host
        Write-Host "🚀 系统性能监控面板" -ForegroundColor Green
        Write-Host "=" * 50 -ForegroundColor Gray
        Write-Host "按 Ctrl+C 退出" -ForegroundColor Yellow
        Write-Host ""
        
        # CPU 使用率
        $cpu = (Get-Counter "\Processor(_Total)\% Processor Time").CounterSamples.CookedValue
        Write-Host "🧠 CPU: $([math]::Round($cpu, 1))%" -ForegroundColor $(if ($cpu -gt 80) { 'Red' } elseif ($cpu -gt 60) { 'Yellow' } else { 'Green' })
        
        # 内存使用率
        $memory = [math]::Round((Get-Counter "\Memory\% Committed Bytes In Use").CounterSamples.CookedValue, 1)
        Write-Host "💾 内存: $memory%" -ForegroundColor $(if ($memory -gt 80) { 'Red' } elseif ($memory -gt 60) { 'Yellow' } else { 'Green' })
        
        # 磁盘使用率
        try {
            $disk = (Get-Counter "\PhysicalDisk(_Total)\% Disk Time").CounterSamples.CookedValue
            Write-Host "💿 磁盘: $([math]::Round($disk, 1))%" -ForegroundColor $(if ($disk -gt 80) { 'Red' } elseif ($disk -gt 60) { 'Yellow' } else { 'Green' })
        } catch {
            Write-Host "💿 磁盘: 无法获取" -ForegroundColor Gray
        }
        
        # 网络使用率
        try {
            $network = (Get-Counter "\Network Interface(*)\Bytes Total/sec" | 
                       Where-Object { $_.CounterSamples.InstanceName -eq "Ethernet" -or $_.CounterSamples.InstanceName -match "Wi-Fi" } |
                       Select-Object -First 1).CounterSamples.CookedValue
            $networkMB = [math]::Round($network / 1MB, 2)
            Write-Host "🌐 网络: $networkMB MB/s" -ForegroundColor Cyan
        } catch {
            Write-Host "🌐 网络: 无法获取" -ForegroundColor Gray
        }
        
        # 进程信息
        Write-Host "`n🔝 资源占用最高的进程:" -ForegroundColor Yellow
        if (Get-Command procs -ErrorAction SilentlyContinue) {
            & procs --sortd cpu | Select-Object -First 5
        } else {
            Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | 
                Format-Table Name, CPU, WorkingSet -AutoSize
        }
        
        Start-Sleep $RefreshInterval
    }
}

# 别名定义
Set-Alias -Name top -Value Invoke-ModernTop -Force
Set-Alias -Name htop -Value Invoke-ModernTop -Force
Set-Alias -Name ps -Value Invoke-ModernPS -Force
Set-Alias -Name df -Value Invoke-ModernDF -Force
Set-Alias -Name du -Value Invoke-ModernDU -Force
Set-Alias -Name sysinfo -Value Get-SystemInfoModern -Force
Set-Alias -Name neofetch -Value Get-SystemInfoModern -Force
Set-Alias -Name netmon -Value Monitor-Network -Force
Set-Alias -Name dashboard -Value Show-PerformanceDashboard -Force
Set-Alias -Name perf -Value Show-PerformanceDashboard -Force

# Note: Functions and aliases are automatically available when dot-sourced