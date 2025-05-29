# PowerShell 性能测试和优化工具
# 仿照 zsh/utils.zsh 的性能监控功能

# 测量 PowerShell 启动时间
function Measure-PowerShellStartup {
    [CmdletBinding()]
    param(
        [int]$Iterations = 5,
        [switch]$Detailed
    )
    
    Write-Host "🕐 测量 PowerShell 启动时间..." -ForegroundColor Cyan
    Write-Host ""
    
    $results = @()
    $totalTime = 0
    
    for ($i = 1; $i -le $Iterations; $i++) {
        Write-Host "第 $i 次测试..." -NoNewline
        
        $startTime = Get-Date
        
        # 测量完整配置加载时间
        $process = Start-Process -FilePath "pwsh" -ArgumentList "-NoLogo", "-Command", "& {. `$PROFILE; exit}" -WindowStyle Hidden -PassThru -Wait
        
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalMilliseconds
        
        $results += $duration
        $totalTime += $duration
        
        Write-Host " ${duration}ms" -ForegroundColor $(
            if ($duration -lt 200) { "Green" }
            elseif ($duration -lt 500) { "Yellow" }
            else { "Red" }
        )
    }
    
    Write-Host ""
    
    # 统计分析
    $average = $totalTime / $Iterations
    $min = ($results | Measure-Object -Minimum).Minimum
    $max = ($results | Measure-Object -Maximum).Maximum
    $median = ($results | Sort-Object)[[math]::Floor($Iterations / 2)]
    
    Write-Host "📊 性能统计:" -ForegroundColor Cyan
    Write-Host "  平均时间: " -NoNewline
    Write-Host "${average:F0}ms" -ForegroundColor $(
        if ($average -lt 200) { "Green" }
        elseif ($average -lt 500) { "Yellow" }
        else { "Red" }
    )
    Write-Host "  最快时间: ${min:F0}ms" -ForegroundColor Green
    Write-Host "  最慢时间: ${max:F0}ms" -ForegroundColor Red
    Write-Host "  中位数:   ${median:F0}ms"
    
    # 性能评级
    Write-Host ""
    Write-Host "🎯 性能评级: " -NoNewline
    if ($average -lt 200) {
        Write-Host "优秀 ✅" -ForegroundColor Green
        Write-Host "  启动速度非常快，配置优化良好"
    } elseif ($average -lt 500) {
        Write-Host "良好 ⚠️" -ForegroundColor Yellow
        Write-Host "  启动速度一般，可以进一步优化"
    } else {
        Write-Host "需要优化 🚨" -ForegroundColor Red
        Write-Host "  启动速度较慢，建议检查配置"
    }
    
    if ($Detailed) {
        Write-Host ""
        Write-Host "💡 优化建议:" -ForegroundColor Cyan
        Write-Host "  1. 运行 Clear-PowerShellCache 清理缓存"
        Write-Host "  2. 运行 Show-PowerShellCacheStatus 检查缓存状态"
        Write-Host "  3. 设置 `$env:PWSH_DEBUG='1' 启用详细日志"
        Write-Host "  4. 考虑禁用不必要的模块"
    }
    
    return @{
        Average = $average
        Min = $min
        Max = $max
        Median = $median
        Results = $results
    }
}

# 清理 PowerShell 缓存
function Clear-PowerShellCache {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$Force
    )
    
    $cacheDir = "$env:USERPROFILE\.cache\powershell"
    
    Write-Host "🧹 清理 PowerShell 缓存..." -ForegroundColor Cyan
    
    if (!(Test-Path $cacheDir)) {
        Write-Host "  缓存目录不存在: $cacheDir" -ForegroundColor Yellow
        return
    }
    
    $cacheFiles = Get-ChildItem $cacheDir -File -Filter "*.cache", "*.time"
    
    if ($cacheFiles.Count -eq 0) {
        Write-Host "  没有找到缓存文件" -ForegroundColor Yellow
        return
    }
    
    Write-Host "  找到 $($cacheFiles.Count) 个缓存文件"
    
    if ($PSCmdlet.ShouldProcess("$($cacheFiles.Count) 个缓存文件", "删除")) {
        $cleaned = 0
        foreach ($file in $cacheFiles) {
            try {
                Remove-Item $file.FullName -Force
                Write-Host "  删除: $($file.Name)" -ForegroundColor DarkGray
                $cleaned++
            } catch {
                Write-Host "  删除失败: $($file.Name) - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        Write-Host "✅ 清理了 $cleaned 个缓存文件" -ForegroundColor Green
    }
}

# 显示缓存状态
function Show-PowerShellCacheStatus {
    $cacheDir = "$env:USERPROFILE\.cache\powershell"
    
    Write-Host "📋 PowerShell 缓存状态:" -ForegroundColor Cyan
    Write-Host ""
    
    if (!(Test-Path $cacheDir)) {
        Write-Host "  缓存目录不存在: $cacheDir" -ForegroundColor Red
        return
    }
    
    $cacheFiles = Get-ChildItem $cacheDir -File -Filter "*.cache"
    
    if ($cacheFiles.Count -eq 0) {
        Write-Host "  没有缓存文件" -ForegroundColor Yellow
        return
    }
    
    Write-Host "  缓存位置: $cacheDir"
    Write-Host "  文件数量: $($cacheFiles.Count)"
    Write-Host ""
    
    # 显示每个缓存文件的信息
    $totalSize = 0
    foreach ($file in $cacheFiles) {
        $timeFile = $file.FullName -replace '\.cache$', '.time'
        $age = "未知"
        $size = $file.Length
        $totalSize += $size
        
        if (Test-Path $timeFile) {
            try {
                $cacheTime = [DateTime]::FromBinary([Convert]::ToInt64((Get-Content $timeFile)))
                $ageSpan = (Get-Date) - $cacheTime
                
                if ($ageSpan.TotalDays -ge 1) {
                    $age = "$($ageSpan.TotalDays.ToString('F0'))天"
                } elseif ($ageSpan.TotalHours -ge 1) {
                    $age = "$($ageSpan.TotalHours.ToString('F0'))小时"
                } else {
                    $age = "$($ageSpan.TotalMinutes.ToString('F0'))分钟"
                }
            } catch {
                $age = "损坏"
            }
        }
        
        $sizeStr = if ($size -lt 1024) {
            "${size}B"
        } elseif ($size -lt 1MB) {
            "$([math]::Round($size/1KB, 1))KB"
        } else {
            "$([math]::Round($size/1MB, 1))MB"
        }
        
        $name = $file.BaseName
        Write-Host "  $name" -NoNewline
        Write-Host " | " -ForegroundColor DarkGray -NoNewline
        Write-Host "$age" -NoNewline
        Write-Host " | " -ForegroundColor DarkGray -NoNewline
        Write-Host "$sizeStr" -ForegroundColor DarkGray
    }
    
    Write-Host ""
    $totalSizeStr = if ($totalSize -lt 1024) {
        "${totalSize}B"
    } elseif ($totalSize -lt 1MB) {
        "$([math]::Round($totalSize/1KB, 1))KB"
    } else {
        "$([math]::Round($totalSize/1MB, 1))MB"
    }
    Write-Host "  总大小: $totalSizeStr" -ForegroundColor Yellow
}

# 预热缓存
function Start-PowerShellCacheWarmup {
    Write-Host "🔥 预热 PowerShell 缓存..." -ForegroundColor Cyan
    
    $tasks = @()
    
    # 预热常用命令检查
    Write-Host "  检查常用工具..." -NoNewline
    $tools = @('git', 'docker', 'node', 'python', 'code', 'nvim')
    foreach ($tool in $tools) {
        Get-Command $tool -ErrorAction SilentlyContinue | Out-Null
    }
    Write-Host " ✅"
    
    # 预热路径检查
    Write-Host "  检查常用路径..." -NoNewline
    $paths = @(
        "$env:USERPROFILE\.cargo\bin",
        "$env:PROGRAMFILES\Git\bin",
        "$env:PROGRAMDATA\chocolatey\bin"
    )
    foreach ($path in $paths) {
        Test-Path $path | Out-Null
    }
    Write-Host " ✅"
    
    # 预热模块信息
    Write-Host "  预加载模块信息..." -NoNewline
    Get-Module -ListAvailable | Out-Null
    Write-Host " ✅"
    
    Write-Host ""
    Write-Host "🎯 缓存预热完成" -ForegroundColor Green
}

# 分析模块加载时间
function Measure-ModuleLoadTime {
    [CmdletBinding()]
    param(
        [string[]]$ModuleName = @()
    )
    
    if ($ModuleName.Count -eq 0) {
        $ModuleName = (Get-Module -ListAvailable).Name | Select-Object -First 10
    }
    
    Write-Host "⚡ 测量模块加载时间..." -ForegroundColor Cyan
    Write-Host ""
    
    $results = @()
    
    foreach ($module in $ModuleName) {
        Write-Host "测试模块: $module" -NoNewline
        
        try {
            # 确保模块未加载
            Remove-Module $module -Force -ErrorAction SilentlyContinue
            
            $startTime = Get-Date
            Import-Module $module -Force -ErrorAction Stop
            $endTime = Get-Date
            
            $duration = ($endTime - $startTime).TotalMilliseconds
            
            Write-Host " - ${duration:F0}ms" -ForegroundColor $(
                if ($duration -lt 50) { "Green" }
                elseif ($duration -lt 200) { "Yellow" }
                else { "Red" }
            )
            
            $results += [PSCustomObject]@{
                Module = $module
                LoadTime = $duration
                Status = "Success"
            }
            
        } catch {
            Write-Host " - 加载失败" -ForegroundColor Red
            $results += [PSCustomObject]@{
                Module = $module
                LoadTime = 0
                Status = "Failed: $($_.Exception.Message)"
            }
        }
    }
    
    Write-Host ""
    Write-Host "📊 模块加载性能排序:" -ForegroundColor Cyan
    $results | Where-Object { $_.Status -eq "Success" } | 
               Sort-Object LoadTime -Descending |
               Format-Table @(
                   @{Name="模块名"; Expression="Module"; Width=30}
                   @{Name="加载时间"; Expression={"{0:F0}ms" -f $_.LoadTime}; Width=10}
               ) -AutoSize
    
    return $results
}

# PowerShell 性能优化建议
function Get-PowerShellOptimizationTips {
    Write-Host "🚀 PowerShell 性能优化建议:" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "1. 📦 模块管理" -ForegroundColor Yellow
    Write-Host "   • 只加载需要的模块 - 使用条件加载"
    Write-Host "   • 延迟加载非关键模块"
    Write-Host "   • 定期清理不用的模块"
    Write-Host ""
    
    Write-Host "2. 🗂️  缓存优化" -ForegroundColor Yellow
    Write-Host "   • 定期运行 Clear-PowerShellCache"
    Write-Host "   • 使用 Start-PowerShellCacheWarmup 预热缓存"
    Write-Host "   • 检查 Show-PowerShellCacheStatus"
    Write-Host ""
    
    Write-Host "3. ⏱️  启动优化" -ForegroundColor Yellow
    Write-Host "   • 使用 Measure-PowerShellStartup 监控性能"
    Write-Host "   • 避免在配置中进行网络请求"
    Write-Host "   • 使用异步加载对非关键功能"
    Write-Host ""
    
    Write-Host "4. 🔍 调试工具" -ForegroundColor Yellow
    Write-Host "   • 设置 `$env:PWSH_DEBUG='1' 启用详细日志"
    Write-Host "   • 使用 Measure-Command 测量命令性能"
    Write-Host "   • 定期运行性能基准测试"
    Write-Host ""
    
    Write-Host "5. 💾 系统优化" -ForegroundColor Yellow
    Write-Host "   • 确保 PowerShell 和模块是最新版本"
    Write-Host "   • 考虑使用 PowerShell 7+ 获得更好性能"
    Write-Host "   • 定期重启 PowerShell 会话"
}

# 系统诊断
function Test-PowerShellPerformance {
    Write-Host "🔍 PowerShell 性能诊断..." -ForegroundColor Cyan
    Write-Host ""
    
    # 检查 PowerShell 版本
    Write-Host "PowerShell 版本: $($PSVersionTable.PSVersion)" -ForegroundColor Green
    Write-Host "平台: $($PSVersionTable.Platform)" -ForegroundColor Green
    Write-Host ""
    
    # 检查已加载的模块数量
    $loadedModules = Get-Module
    Write-Host "已加载模块: $($loadedModules.Count) 个" -ForegroundColor $(
        if ($loadedModules.Count -lt 10) { "Green" }
        elseif ($loadedModules.Count -lt 20) { "Yellow" }
        else { "Red" }
    )
    
    # 检查缓存状态
    $cacheDir = "$env:USERPROFILE\.cache\powershell"
    if (Test-Path $cacheDir) {
        $cacheFiles = Get-ChildItem $cacheDir -File
        Write-Host "缓存文件: $($cacheFiles.Count) 个" -ForegroundColor Green
    } else {
        Write-Host "缓存目录: 不存在" -ForegroundColor Yellow
    }
    
    # 检查配置文件大小
    if (Test-Path $PROFILE) {
        $profileSize = (Get-Item $PROFILE).Length
        Write-Host "配置文件大小: $([math]::Round($profileSize/1KB, 1))KB" -ForegroundColor $(
            if ($profileSize -lt 10KB) { "Green" }
            elseif ($profileSize -lt 50KB) { "Yellow" }
            else { "Red" }
        )
    }
    
    Write-Host ""
    Write-Host "运行 Measure-PowerShellStartup 获取详细性能数据" -ForegroundColor Cyan
}

# 别名定义
Set-Alias pwsh-bench Measure-PowerShellStartup
Set-Alias pwsh-cache Show-PowerShellCacheStatus
Set-Alias pwsh-clear Clear-PowerShellCache
Set-Alias pwsh-warmup Start-PowerShellCacheWarmup
Set-Alias pwsh-tips Get-PowerShellOptimizationTips
Set-Alias pwsh-test Test-PowerShellPerformance

# 注意：通过 dot sourcing 加载时，Export-ModuleMember 不生效
# 函数和别名会自动在全局作用域中可用