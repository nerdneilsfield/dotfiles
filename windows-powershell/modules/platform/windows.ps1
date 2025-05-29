# Windows 功能深度包装
# 提供系统健康检查、性能优化、启动项管理等 Windows 特有功能

# 系统健康检查
function Get-SystemHealth {
    [CmdletBinding()]
    param()
    
    try {
        Write-Host "🔍 Windows 系统健康检查" -ForegroundColor Green
        Write-Host "=" * 50 -ForegroundColor Gray
        
        # 系统信息
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $cpu = Get-CimInstance -ClassName Win32_Processor
        $memory = Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
        
        Write-Host "📊 系统信息:" -ForegroundColor Yellow
        Write-Host "  OS: $($os.Caption) ($($os.Version))"
        Write-Host "  CPU: $($cpu.Name)"
        Write-Host "  内存: $([math]::Round($memory.Sum / 1GB, 2)) GB"
        Write-Host "  启动时间: $($os.LastBootUpTime)"
        Write-Host ""
        
        # 磁盘空间
        Write-Host "💾 磁盘空间:" -ForegroundColor Yellow
        Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | ForEach-Object {
            $freePercent = [math]::Round(($_.FreeSpace / $_.Size) * 100, 2)
            $status = if ($freePercent -lt 10) { "🔴" } elseif ($freePercent -lt 20) { "🟡" } else { "🟢" }
            Write-Host "  $status $($_.DeviceID) $([math]::Round($_.FreeSpace / 1GB, 2)) GB / $([math]::Round($_.Size / 1GB, 2)) GB ($freePercent%)"
        }
        Write-Host ""
        
        # CPU 和内存使用率
        Write-Host "⚡ 当前资源使用:" -ForegroundColor Yellow
        $perfCounters = @{
            CPU = (Get-Counter "\Processor(_Total)\% Processor Time").CounterSamples.CookedValue
            Memory = [math]::Round((Get-Counter "\Memory\% Committed Bytes In Use").CounterSamples.CookedValue, 2)
        }
        Write-Host "  CPU: $([math]::Round($perfCounters.CPU, 2))%"
        Write-Host "  内存: $($perfCounters.Memory)%"
        Write-Host ""
        
        # Windows 更新状态
        Write-Host "🔄 Windows 更新状态:" -ForegroundColor Yellow
        try {
            $updateSession = New-Object -ComObject Microsoft.Update.Session
            $updateSearcher = $updateSession.CreateUpdateSearcher()
            $searchResult = $updateSearcher.Search("IsInstalled=0")
            if ($searchResult.Updates.Count -eq 0) {
                Write-Host "  ✅ 无待安装更新"
            } else {
                Write-Host "  ⚠️  有 $($searchResult.Updates.Count) 个待安装更新"
            }
        } catch {
            Write-Host "  ⚠️  无法检查更新状态"
        }
        Write-Host ""
        
        # 系统服务状态
        Write-Host "🔧 关键服务状态:" -ForegroundColor Yellow
        $criticalServices = @('Themes', 'AudioSrv', 'BITS', 'wuauserv', 'EventLog')
        foreach ($service in $criticalServices) {
            $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
            if ($svc) {
                $status = if ($svc.Status -eq 'Running') { "🟢" } else { "🔴" }
                Write-Host "  $status $($svc.DisplayName): $($svc.Status)"
            }
        }
        
    } catch {
        Write-Error "系统健康检查失败: $_"
    }
}

# 性能优化
function Optimize-WindowsPerformance {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$CleanTemp,
        [switch]$OptimizeStartup,
        [switch]$CleanRegistry,
        [switch]$DefragmentDisks,
        [switch]$All
    )
    
    if (-not $PSBoundParameters.Keys.Count -or $All) {
        $CleanTemp = $OptimizeStartup = $CleanRegistry = $DefragmentDisks = $true
    }
    
    Write-Host "🚀 Windows 性能优化" -ForegroundColor Green
    Write-Host "=" * 50 -ForegroundColor Gray
    
    if ($CleanTemp) {
        Write-Host "🧹 清理临时文件..." -ForegroundColor Yellow
        if ($PSCmdlet.ShouldProcess("临时文件", "清理")) {
            try {
                $tempPaths = @(
                    $env:TEMP,
                    "$env:WINDIR\Temp",
                    "$env:LOCALAPPDATA\Temp",
                    "$env:USERPROFILE\AppData\Local\Microsoft\Windows\INetCache"
                )
                
                $totalCleaned = 0
                foreach ($path in $tempPaths) {
                    if (Test-Path $path) {
                        $before = (Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
                        Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                        $after = (Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
                        $cleaned = $before - $after
                        $totalCleaned += $cleaned
                    }
                }
                Write-Host "  ✅ 已清理 $([math]::Round($totalCleaned / 1MB, 2)) MB 临时文件"
            } catch {
                Write-Warning "清理临时文件时出错: $_"
            }
        }
    }
    
    if ($OptimizeStartup) {
        Write-Host "⚡ 优化启动项..." -ForegroundColor Yellow
        if ($PSCmdlet.ShouldProcess("启动项", "优化")) {
            try {
                $startupApps = Get-CimInstance Win32_StartupCommand | Where-Object { $_.Location -ne "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" }
                Write-Host "  📋 当前非系统启动项: $($startupApps.Count)"
                $startupApps | ForEach-Object {
                    Write-Host "    - $($_.Name): $($_.Command)"
                }
            } catch {
                Write-Warning "无法获取启动项信息: $_"
            }
        }
    }
    
    if ($CleanRegistry) {
        Write-Host "🔧 清理注册表..." -ForegroundColor Yellow
        if ($PSCmdlet.ShouldProcess("注册表", "清理")) {
            Write-Host "  ⚠️  注册表清理需要第三方工具或手动操作"
        }
    }
    
    if ($DefragmentDisks) {
        Write-Host "💿 磁盘碎片整理..." -ForegroundColor Yellow
        if ($PSCmdlet.ShouldProcess("磁盘", "碎片整理")) {
            try {
                $drives = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
                foreach ($drive in $drives) {
                    Write-Host "  检查驱动器 $($drive.DeviceID)..."
                    $result = Optimize-Volume -DriveLetter $drive.DeviceID.TrimEnd(':') -Analyze -Verbose
                    Write-Host "    分析完成"
                }
            } catch {
                Write-Warning "磁盘分析失败: $_"
            }
        }
    }
}

# 启动项管理
function Manage-StartupPrograms {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('List', 'Disable', 'Enable')]
        [string]$Action = 'List',
        
        [Parameter(Mandatory = $false)]
        [string]$ProgramName
    )
    
    Write-Host "🚀 启动项管理" -ForegroundColor Green
    Write-Host "=" * 30 -ForegroundColor Gray
    
    try {
        switch ($Action) {
            'List' {
                $startupApps = Get-CimInstance Win32_StartupCommand
                Write-Host "📋 当前启动项:" -ForegroundColor Yellow
                $startupApps | Sort-Object Name | ForEach-Object {
                    $status = if ($_.Command -match "disabled") { "🔴" } else { "🟢" }
                    Write-Host "  $status $($_.Name)"
                    Write-Host "    路径: $($_.Command)"
                    Write-Host "    位置: $($_.Location)"
                    Write-Host ""
                }
            }
            
            'Disable' {
                if (-not $ProgramName) {
                    Write-Error "请指定要禁用的程序名称"
                    return
                }
                Write-Host "🔴 禁用启动项: $ProgramName" -ForegroundColor Red
                Write-Host "  ⚠️  请使用任务管理器或 msconfig 手动禁用"
            }
            
            'Enable' {
                if (-not $ProgramName) {
                    Write-Error "请指定要启用的程序名称"
                    return
                }
                Write-Host "🟢 启用启动项: $ProgramName" -ForegroundColor Green
                Write-Host "  ⚠️  请使用任务管理器或 msconfig 手动启用"
            }
        }
    } catch {
        Write-Error "启动项管理失败: $_"
    }
}

# 系统清理
function Clean-SystemCache {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$DNS,
        [switch]$WindowsStore,
        [switch]$Thumbnails,
        [switch]$Prefetch,
        [switch]$All
    )
    
    if (-not $PSBoundParameters.Keys.Count -or $All) {
        $DNS = $WindowsStore = $Thumbnails = $Prefetch = $true
    }
    
    Write-Host "🧹 系统缓存清理" -ForegroundColor Green
    Write-Host "=" * 40 -ForegroundColor Gray
    
    if ($DNS) {
        Write-Host "🌐 清理 DNS 缓存..." -ForegroundColor Yellow
        if ($PSCmdlet.ShouldProcess("DNS 缓存", "清理")) {
            try {
                Clear-DnsClientCache
                Write-Host "  ✅ DNS 缓存已清理"
            } catch {
                Write-Warning "DNS 缓存清理失败: $_"
            }
        }
    }
    
    if ($WindowsStore) {
        Write-Host "🏪 重置 Windows Store 缓存..." -ForegroundColor Yellow
        if ($PSCmdlet.ShouldProcess("Windows Store 缓存", "重置")) {
            try {
                Start-Process "wsreset.exe" -NoNewWindow -Wait
                Write-Host "  ✅ Windows Store 缓存已重置"
            } catch {
                Write-Warning "Windows Store 缓存重置失败: $_"
            }
        }
    }
    
    if ($Thumbnails) {
        Write-Host "🖼️ 清理缩略图缓存..." -ForegroundColor Yellow
        if ($PSCmdlet.ShouldProcess("缩略图缓存", "清理")) {
            try {
                $thumbPath = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
                if (Test-Path $thumbPath) {
                    Get-ChildItem $thumbPath -Filter "*.db" | Remove-Item -Force
                    Write-Host "  ✅ 缩略图缓存已清理"
                }
            } catch {
                Write-Warning "缩略图缓存清理失败: $_"
            }
        }
    }
    
    if ($Prefetch) {
        Write-Host "⚡ 清理预读取文件..." -ForegroundColor Yellow
        if ($PSCmdlet.ShouldProcess("预读取文件", "清理")) {
            try {
                $prefetchPath = "$env:WINDIR\Prefetch"
                if (Test-Path $prefetchPath) {
                    Get-ChildItem $prefetchPath -Filter "*.pf" | Remove-Item -Force
                    Write-Host "  ✅ 预读取文件已清理"
                }
            } catch {
                Write-Warning "预读取文件清理失败: $_"
            }
        }
    }
}

# Windows Terminal 配置
function Set-TerminalProfile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('PowerShell', 'Cmd', 'WSL')]
        [string]$DefaultProfile = 'PowerShell',
        
        [switch]$EnableAcrylic,
        [switch]$SetColorScheme
    )
    
    Write-Host "🖥️ Windows Terminal 配置" -ForegroundColor Green
    
    $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    
    if (-not (Test-Path $settingsPath)) {
        Write-Warning "未找到 Windows Terminal 配置文件"
        return
    }
    
    try {
        $settings = Get-Content $settingsPath | ConvertFrom-Json
        Write-Host "📝 当前配置已读取" -ForegroundColor Yellow
        
        if ($EnableAcrylic) {
            Write-Host "🎨 启用亚克力效果..." -ForegroundColor Yellow
        }
        
        if ($SetColorScheme) {
            Write-Host "🌈 设置配色方案..." -ForegroundColor Yellow
        }
        
        Write-Host "  ⚠️  请手动编辑 Windows Terminal 配置文件"
        Write-Host "  📁 路径: $settingsPath"
        
    } catch {
        Write-Error "配置 Windows Terminal 失败: $_"
    }
}

# winget 包装函数
function Install-WingetPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName,
        
        [switch]$Force
    )
    
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "winget 未安装或不可用"
        return
    }
    
    $args = @('install', $PackageName)
    if ($Force) { $args += '--force' }
    
    Write-Host "📦 安装包: $PackageName" -ForegroundColor Green
    & winget @args
}

function Search-WingetPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Query
    )
    
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "winget 未安装或不可用"
        return
    }
    
    Write-Host "🔍 搜索包: $Query" -ForegroundColor Green
    winget search $Query
}

function Update-WingetPackages {
    [CmdletBinding()]
    param()
    
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "winget 未安装或不可用"
        return
    }
    
    Write-Host "📦 更新所有包..." -ForegroundColor Green
    winget upgrade --all
}

# 别名
Set-Alias -Name syshealth -Value Get-SystemHealth -Force
Set-Alias -Name sysopt -Value Optimize-WindowsPerformance -Force
Set-Alias -Name startup -Value Manage-StartupPrograms -Force
Set-Alias -Name cleancache -Value Clean-SystemCache -Force
Set-Alias -Name terminal -Value Set-TerminalProfile -Force
Set-Alias -Name wg -Value Search-WingetPackage -Force
Set-Alias -Name wgi -Value Install-WingetPackage -Force
Set-Alias -Name wgu -Value Update-WingetPackages -Force

# 导出函数
Export-ModuleMember -Function @(
    'Get-SystemHealth',
    'Optimize-WindowsPerformance',
    'Manage-StartupPrograms',
    'Clean-SystemCache',
    'Set-TerminalProfile',
    'Install-WingetPackage',
    'Search-WingetPackage',
    'Update-WingetPackages'
) -Alias @(
    'syshealth',
    'sysopt',
    'startup',
    'cleancache',
    'terminal',
    'wg',
    'wgi',
    'wgu'
)