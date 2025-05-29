# PowerShell 配置快速设置向导
# 帮助用户快速配置和优化 PowerShell 环境

# 向导配置
$script:WizardConfig = @{
    Steps = @(
        'Welcome',
        'CheckEnvironment', 
        'InstallTools',
        'ConfigureProfile',
        'OptimizePerformance',
        'TestSetup',
        'Complete'
    )
    Colors = @{
        Title = 'Green'
        Step = 'Yellow'
        Success = 'Green'
        Warning = 'Yellow'
        Error = 'Red'
        Info = 'Cyan'
        Prompt = 'White'
    }
}

# 主向导入口
function Start-PWShSetupWizard {
    <#
    .SYNOPSIS
    启动 PowerShell 配置设置向导
    
    .DESCRIPTION
    交互式设置向导，帮助用户快速配置和优化 PowerShell 环境
    
    .PARAMETER SkipSteps
    跳过特定步骤
    
    .PARAMETER AutoConfirm
    自动确认所有选项
    
    .EXAMPLE
    Start-PWShSetupWizard
    启动完整设置向导
    
    .EXAMPLE
    Start-PWShSetupWizard -SkipSteps @('InstallTools') -AutoConfirm
    跳过工具安装，自动确认其他选项
    #>
    [CmdletBinding()]
    param(
        [string[]]$SkipSteps = @(),
        [switch]$AutoConfirm
    )
    
    Clear-Host
    
    $context = @{
        CurrentStep = 0
        TotalSteps = $script:WizardConfig.Steps.Count
        SkipSteps = $SkipSteps
        AutoConfirm = $AutoConfirm
        Results = @{}
    }
    
    foreach ($step in $script:WizardConfig.Steps) {
        $context.CurrentStep++
        
        if ($step -in $SkipSteps) {
            Write-Host "⏭️  跳过步骤: $step" -ForegroundColor $script:WizardConfig.Colors.Warning
            continue
        }
        
        $stepFunction = "Invoke-WizardStep$step"
        if (Get-Command $stepFunction -ErrorAction SilentlyContinue) {
            try {
                & $stepFunction -Context $context
            } catch {
                Write-Host "❌ 步骤 $step 执行失败: $_" -ForegroundColor $script:WizardConfig.Colors.Error
                if (-not $AutoConfirm) {
                    $continue = Read-Host "是否继续? (y/N)"
                    if ($continue -ne 'y' -and $continue -ne 'Y') {
                        Write-Host "🛑 向导已取消" -ForegroundColor $script:WizardConfig.Colors.Warning
                        return
                    }
                }
            }
        } else {
            Write-Host "⚠️  未找到步骤函数: $stepFunction" -ForegroundColor $script:WizardConfig.Colors.Warning
        }
    }
}

# 欢迎步骤
function Invoke-WizardStepWelcome {
    param($Context)
    
    Write-Host "🚀 PowerShell 现代工具链配置向导" -ForegroundColor $script:WizardConfig.Colors.Title
    Write-Host "=" * 60 -ForegroundColor $script:WizardConfig.Colors.Step
    Write-Host ""
    Write-Host "欢迎使用 PowerShell 现代工具链！" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host "此向导将帮助您：" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host "  • 检查和安装必要的工具" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host "  • 配置最佳实践设置" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host "  • 优化启动性能" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host "  • 验证安装结果" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host ""
    
    if (-not $Context.AutoConfirm) {
        $continue = Read-Host "按 Enter 继续，或输入 'q' 退出"
        if ($continue -eq 'q' -or $continue -eq 'Q') {
            throw "用户取消"
        }
    }
    
    Write-Host ""
}

# 环境检查步骤
function Invoke-WizardStepCheckEnvironment {
    param($Context)
    
    Write-Host "[$($Context.CurrentStep)/$($Context.TotalSteps)] 🔍 检查环境" -ForegroundColor $script:WizardConfig.Colors.Step
    Write-Host "-" * 40 -ForegroundColor $script:WizardConfig.Colors.Step
    
    $checks = @{
        'PowerShell 版本' = {
            $version = $PSVersionTable.PSVersion
            $result = @{
                Status = if ($version.Major -ge 7) { 'Good' } elseif ($version.Major -eq 5 -and $version.Minor -eq 1) { 'OK' } else { 'Poor' }
                Message = "PowerShell $version"
                Recommendation = if ($version.Major -lt 7) { "建议升级到 PowerShell 7+" } else { $null }
            }
            return $result
        }
        
        '执行策略' = {
            $policy = Get-ExecutionPolicy
            $result = @{
                Status = if ($policy -in @('RemoteSigned', 'Unrestricted')) { 'Good' } else { 'Poor' }
                Message = "当前策略: $policy"
                Recommendation = if ($policy -notin @('RemoteSigned', 'Unrestricted')) { "运行: Set-ExecutionPolicy RemoteSigned" } else { $null }
            }
            return $result
        }
        
        '管理员权限' = {
            $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
            $result = @{
                Status = if ($isAdmin) { 'Good' } else { 'Warning' }
                Message = if ($isAdmin) { "具有管理员权限" } else { "普通用户权限" }
                Recommendation = if (-not $isAdmin) { "某些功能需要管理员权限" } else { $null }
            }
            return $result
        }
        
        'Windows 版本' = {
            $os = Get-CimInstance Win32_OperatingSystem
            $version = [Version]$os.Version
            $result = @{
                Status = if ($version.Build -ge 19041) { 'Good' } else { 'Warning' }
                Message = "$($os.Caption) ($($os.Version))"
                Recommendation = if ($version.Build -lt 19041) { "建议升级到 Windows 10 20H1 或更高版本" } else { $null }
            }
            return $result
        }
    }
    
    $Context.Results.EnvironmentChecks = @{}
    
    foreach ($checkName in $checks.Keys) {
        Write-Host "  检查 $checkName..." -ForegroundColor $script:WizardConfig.Colors.Info -NoNewline
        
        try {
            $result = & $checks[$checkName]
            $Context.Results.EnvironmentChecks[$checkName] = $result
            
            $statusColor = switch ($result.Status) {
                'Good' { $script:WizardConfig.Colors.Success }
                'OK' { $script:WizardConfig.Colors.Info }
                'Warning' { $script:WizardConfig.Colors.Warning }
                'Poor' { $script:WizardConfig.Colors.Error }
            }
            
            $statusIcon = switch ($result.Status) {
                'Good' { ' ✅' }
                'OK' { ' ℹ️ ' }
                'Warning' { ' ⚠️ ' }
                'Poor' { ' ❌' }
            }
            
            Write-Host $statusIcon -ForegroundColor $statusColor
            Write-Host "    $($result.Message)" -ForegroundColor $script:WizardConfig.Colors.Info
            
            if ($result.Recommendation) {
                Write-Host "    💡 $($result.Recommendation)" -ForegroundColor $script:WizardConfig.Colors.Warning
            }
            
        } catch {
            Write-Host " ❌" -ForegroundColor $script:WizardConfig.Colors.Error
            Write-Host "    检查失败: $_" -ForegroundColor $script:WizardConfig.Colors.Error
        }
        
        Write-Host ""
    }
    
    if (-not $Context.AutoConfirm) {
        Read-Host "按 Enter 继续"
    }
    Write-Host ""
}

# 工具安装步骤
function Invoke-WizardStepInstallTools {
    param($Context)
    
    Write-Host "[$($Context.CurrentStep)/$($Context.TotalSteps)] 📦 安装现代工具" -ForegroundColor $script:WizardConfig.Colors.Step
    Write-Host "-" * 40 -ForegroundColor $script:WizardConfig.Colors.Step
    
    # 检查 Scoop
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "🔧 Scoop 未安装" -ForegroundColor $script:WizardConfig.Colors.Warning
        
        if ($Context.AutoConfirm -or (Read-Host "是否安装 Scoop? (Y/n)") -ne 'n') {
            try {
                Write-Host "正在安装 Scoop..." -ForegroundColor $script:WizardConfig.Colors.Info
                Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
                Invoke-RestMethod get.scoop.sh | Invoke-Expression
                Write-Host "✅ Scoop 安装成功" -ForegroundColor $script:WizardConfig.Colors.Success
            } catch {
                Write-Host "❌ Scoop 安装失败: $_" -ForegroundColor $script:WizardConfig.Colors.Error
            }
        }
    } else {
        Write-Host "✅ Scoop 已安装" -ForegroundColor $script:WizardConfig.Colors.Success
    }
    
    # 推荐的工具列表
    $recommendedTools = @{
        'git' = '版本控制'
        'starship' = '现代提示符'
        'eza' = '现代 ls 替代'
        'zoxide' = '智能目录跳转'
        'fzf' = '模糊搜索工具'
        'ripgrep' = '快速文本搜索'
        'fd' = '快速文件搜索'
        'bat' = '现代 cat 替代'
        'bottom' = '系统监控'
        'duf' = '磁盘使用查看'
        'dust' = '目录大小分析'
        'lazygit' = 'Git TUI'
        'gh' = 'GitHub CLI'
    }
    
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "🛠️ 检查推荐工具..." -ForegroundColor $script:WizardConfig.Colors.Info
        
        $toolsToInstall = @()
        
        foreach ($tool in $recommendedTools.Keys) {
            $isInstalled = Get-Command $tool -ErrorAction SilentlyContinue
            if ($isInstalled) {
                Write-Host "  ✅ $tool - $($recommendedTools[$tool])" -ForegroundColor $script:WizardConfig.Colors.Success
            } else {
                Write-Host "  ❌ $tool - $($recommendedTools[$tool])" -ForegroundColor $script:WizardConfig.Colors.Warning
                $toolsToInstall += $tool
            }
        }
        
        if ($toolsToInstall.Count -gt 0) {
            Write-Host ""
            Write-Host "发现 $($toolsToInstall.Count) 个未安装的推荐工具" -ForegroundColor $script:WizardConfig.Colors.Info
            
            if ($Context.AutoConfirm -or (Read-Host "是否安装缺失的工具? (Y/n)") -ne 'n') {
                Write-Host "正在安装工具..." -ForegroundColor $script:WizardConfig.Colors.Info
                
                # 添加额外的 bucket
                try {
                    scoop bucket add extras 2>$null
                    scoop bucket add versions 2>$null
                } catch {
                    Write-Host "⚠️  添加 bucket 时出现警告，继续安装..." -ForegroundColor $script:WizardConfig.Colors.Warning
                }
                
                foreach ($tool in $toolsToInstall) {
                    try {
                        Write-Host "  安装 $tool..." -ForegroundColor $script:WizardConfig.Colors.Info
                        scoop install $tool 2>$null
                        Write-Host "  ✅ $tool 安装成功" -ForegroundColor $script:WizardConfig.Colors.Success
                    } catch {
                        Write-Host "  ❌ $tool 安装失败" -ForegroundColor $script:WizardConfig.Colors.Error
                    }
                }
            }
        } else {
            Write-Host "🎉 所有推荐工具都已安装！" -ForegroundColor $script:WizardConfig.Colors.Success
        }
    }
    
    if (-not $Context.AutoConfirm) {
        Read-Host "按 Enter 继续"
    }
    Write-Host ""
}

# 配置步骤
function Invoke-WizardStepConfigureProfile {
    param($Context)
    
    Write-Host "[$($Context.CurrentStep)/$($Context.TotalSteps)] ⚙️  配置 PowerShell Profile" -ForegroundColor $script:WizardConfig.Colors.Step
    Write-Host "-" * 40 -ForegroundColor $script:WizardConfig.Colors.Step
    
    # 检查 Profile 是否已配置
    $profileConfigured = Test-Path $PROFILE -and (Get-Content $PROFILE -Raw) -match "PowerShell.*配置"
    
    if ($profileConfigured) {
        Write-Host "✅ PowerShell Profile 已配置" -ForegroundColor $script:WizardConfig.Colors.Success
    } else {
        Write-Host "⚠️  PowerShell Profile 未配置或配置不完整" -ForegroundColor $script:WizardConfig.Colors.Warning
        
        if ($Context.AutoConfirm -or (Read-Host "是否重新加载配置? (Y/n)") -ne 'n') {
            try {
                . $PROFILE
                Write-Host "✅ Profile 重新加载成功" -ForegroundColor $script:WizardConfig.Colors.Success
            } catch {
                Write-Host "❌ Profile 加载失败: $_" -ForegroundColor $script:WizardConfig.Colors.Error
            }
        }
    }
    
    # 配置建议
    Write-Host ""
    Write-Host "📋 配置建议:" -ForegroundColor $script:WizardConfig.Colors.Info
    
    $suggestions = @(
        "运行 'help' 查看可用命令和功能",
        "运行 'help functions' 浏览所有可用函数", 
        "运行 'syshealth' 检查系统状态",
        "运行 'devcheck' 检查开发环境",
        "使用 'z <目录>' 进行智能目录跳转",
        "使用 'search <查询>' 搜索文件和内容"
    )
    
    foreach ($suggestion in $suggestions) {
        Write-Host "  💡 $suggestion" -ForegroundColor $script:WizardConfig.Colors.Info
    }
    
    if (-not $Context.AutoConfirm) {
        Read-Host "按 Enter 继续"
    }
    Write-Host ""
}

# 性能优化步骤
function Invoke-WizardStepOptimizePerformance {
    param($Context)
    
    Write-Host "[$($Context.CurrentStep)/$($Context.TotalSteps)] ⚡ 性能优化" -ForegroundColor $script:WizardConfig.Colors.Step
    Write-Host "-" * 40 -ForegroundColor $script:WizardConfig.Colors.Step
    
    # 测量当前启动时间
    Write-Host "🔍 测量启动性能..." -ForegroundColor $script:WizardConfig.Colors.Info
    
    try {
        if (Get-Command Measure-PowerShellStartup -ErrorAction SilentlyContinue) {
            $startupTime = Measure-PowerShellStartup -Quiet
            Write-Host "  当前启动时间: $($startupTime)ms" -ForegroundColor $script:WizardConfig.Colors.Info
            
            $performanceLevel = if ($startupTime -lt 200) {
                "优秀"
            } elseif ($startupTime -lt 500) {
                "良好" 
            } elseif ($startupTime -lt 1000) {
                "一般"
            } else {
                "需要优化"
            }
            
            Write-Host "  性能评级: $performanceLevel" -ForegroundColor $script:WizardConfig.Colors.Info
            
            if ($startupTime -gt 500) {
                Write-Host ""
                Write-Host "🔧 性能优化建议:" -ForegroundColor $script:WizardConfig.Colors.Warning
                Write-Host "  • 清理缓存: Clear-PowerShellCache" -ForegroundColor $script:WizardConfig.Colors.Info
                Write-Host "  • 预热缓存: Start-PowerShellCacheWarmup" -ForegroundColor $script:WizardConfig.Colors.Info
                Write-Host "  • 检查模块加载: `$env:PWSH_DEBUG='1'" -ForegroundColor $script:WizardConfig.Colors.Info
                
                if ($Context.AutoConfirm -or (Read-Host "是否执行缓存优化? (Y/n)") -ne 'n') {
                    try {
                        Write-Host "正在优化缓存..." -ForegroundColor $script:WizardConfig.Colors.Info
                        if (Get-Command Clear-PowerShellCache -ErrorAction SilentlyContinue) {
                            Clear-PowerShellCache
                        }
                        if (Get-Command Start-PowerShellCacheWarmup -ErrorAction SilentlyContinue) {
                            Start-PowerShellCacheWarmup
                        }
                        Write-Host "✅ 缓存优化完成" -ForegroundColor $script:WizardConfig.Colors.Success
                    } catch {
                        Write-Host "❌ 缓存优化失败: $_" -ForegroundColor $script:WizardConfig.Colors.Error
                    }
                }
            }
        } else {
            Write-Host "⚠️  性能测试功能不可用" -ForegroundColor $script:WizardConfig.Colors.Warning
        }
    } catch {
        Write-Host "❌ 性能测试失败: $_" -ForegroundColor $script:WizardConfig.Colors.Error
    }
    
    if (-not $Context.AutoConfirm) {
        Read-Host "按 Enter 继续"
    }
    Write-Host ""
}

# 测试设置步骤
function Invoke-WizardStepTestSetup {
    param($Context)
    
    Write-Host "[$($Context.CurrentStep)/$($Context.TotalSteps)] 🧪 测试设置" -ForegroundColor $script:WizardConfig.Colors.Step
    Write-Host "-" * 40 -ForegroundColor $script:WizardConfig.Colors.Step
    
    $tests = @{
        '帮助系统' = {
            try {
                Get-Command Get-PWShHelp -ErrorAction Stop | Out-Null
                return @{ Success = $true; Message = "帮助系统可用" }
            } catch {
                return @{ Success = $false; Message = "帮助系统不可用" }
            }
        }
        
        '导航工具' = {
            $tools = @('eza', 'zoxide', 'fzf')
            $available = $tools | Where-Object { Get-Command $_ -ErrorAction SilentlyContinue }
            $success = $available.Count -eq $tools.Count
            return @{ 
                Success = $success
                Message = if ($success) { "所有导航工具可用" } else { "缺少工具: $($tools | Where-Object { $_ -notin $available })" }
            }
        }
        
        '搜索工具' = {
            $tools = @('ripgrep', 'fd')
            $available = $tools | Where-Object { Get-Command $_ -ErrorAction SilentlyContinue }
            $success = $available.Count -eq $tools.Count
            return @{
                Success = $success
                Message = if ($success) { "搜索工具可用" } else { "缺少工具: $($tools | Where-Object { $_ -notin $available })" }
            }
        }
        
        'Git 工具' = {
            $hasGit = Get-Command git -ErrorAction SilentlyContinue
            $hasLazygit = Get-Command lazygit -ErrorAction SilentlyContinue
            $success = $hasGit -and $hasLazygit
            return @{
                Success = $success
                Message = if ($success) { "Git 工具链完整" } else { "Git 工具不完整" }
            }
        }
        
        '监控工具' = {
            $tools = @('bottom', 'procs', 'duf', 'dust')
            $available = $tools | Where-Object { Get-Command $_ -ErrorAction SilentlyContinue }
            $success = $available.Count -gt 0
            return @{
                Success = $success
                Message = if ($success) { "监控工具可用 ($($available.Count)/$($tools.Count))" } else { "监控工具不可用" }
            }
        }
    }
    
    $Context.Results.TestResults = @{}
    $passedTests = 0
    
    foreach ($testName in $tests.Keys) {
        Write-Host "  测试 $testName..." -ForegroundColor $script:WizardConfig.Colors.Info -NoNewline
        
        try {
            $result = & $tests[$testName]
            $Context.Results.TestResults[$testName] = $result
            
            if ($result.Success) {
                Write-Host " ✅" -ForegroundColor $script:WizardConfig.Colors.Success
                $passedTests++
            } else {
                Write-Host " ❌" -ForegroundColor $script:WizardConfig.Colors.Error
            }
            
            Write-Host "    $($result.Message)" -ForegroundColor $script:WizardConfig.Colors.Info
            
        } catch {
            Write-Host " ❌" -ForegroundColor $script:WizardConfig.Colors.Error
            Write-Host "    测试失败: $_" -ForegroundColor $script:WizardConfig.Colors.Error
        }
        
        Write-Host ""
    }
    
    $totalTests = $tests.Count
    $passRate = [math]::Round(($passedTests / $totalTests) * 100, 1)
    
    Write-Host "📊 测试结果: $passedTests/$totalTests 通过 ($passRate%)" -ForegroundColor $(
        if ($passRate -ge 80) { $script:WizardConfig.Colors.Success }
        elseif ($passRate -ge 60) { $script:WizardConfig.Colors.Warning }
        else { $script:WizardConfig.Colors.Error }
    )
    
    if (-not $Context.AutoConfirm) {
        Read-Host "按 Enter 继续"
    }
    Write-Host ""
}

# 完成步骤
function Invoke-WizardStepComplete {
    param($Context)
    
    Write-Host "[$($Context.CurrentStep)/$($Context.TotalSteps)] 🎉 设置完成" -ForegroundColor $script:WizardConfig.Colors.Step
    Write-Host "-" * 40 -ForegroundColor $script:WizardConfig.Colors.Step
    
    Write-Host "恭喜！PowerShell 现代工具链设置完成！" -ForegroundColor $script:WizardConfig.Colors.Success
    Write-Host ""
    
    Write-Host "🚀 接下来你可以：" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host "  • 运行 'help' 探索所有功能" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host "  • 运行 'help functions' 查看可用函数" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host "  • 运行 'help search <查询>' 搜索特定功能" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host "  • 使用 'z <目录>' 快速目录跳转" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host "  • 使用 'search' 启动交互式搜索" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host "  • 运行 'syshealth' 检查系统状态" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host "  • 运行 'dashboard' 查看系统监控面板" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host ""
    
    Write-Host "📚 文档和支持：" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host "  • 运行 'help readme' 查看完整文档" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host "  • 查看 README.md 了解详细功能" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host "  • 查看 TODO.md 了解开发进度" -ForegroundColor $script:WizardConfig.Colors.Info
    Write-Host ""
    
    Write-Host "感谢使用 PowerShell 现代工具链！" -ForegroundColor $script:WizardConfig.Colors.Success
    Write-Host "🌟 如果觉得有用，别忘了给项目点个星！" -ForegroundColor $script:WizardConfig.Colors.Info
}

# 快速修复功能
function Invoke-PWShQuickFix {
    <#
    .SYNOPSIS
    快速修复常见问题
    
    .DESCRIPTION
    自动检测和修复 PowerShell 配置的常见问题
    
    .EXAMPLE
    Invoke-PWShQuickFix
    运行快速修复
    #>
    [CmdletBinding()]
    param()
    
    Write-Host "🔧 PowerShell 快速修复工具" -ForegroundColor Green
    Write-Host "=" * 40 -ForegroundColor Yellow
    
    $fixes = @{
        '重新加载配置' = {
            try {
                . $PROFILE
                return @{ Success = $true; Message = "配置重新加载成功" }
            } catch {
                return @{ Success = $false; Message = "配置加载失败: $_" }
            }
        }
        
        '清理缓存' = {
            try {
                if (Get-Command Clear-PowerShellCache -ErrorAction SilentlyContinue) {
                    Clear-PowerShellCache
                    return @{ Success = $true; Message = "缓存清理成功" }
                } else {
                    return @{ Success = $false; Message = "缓存清理功能不可用" }
                }
            } catch {
                return @{ Success = $false; Message = "缓存清理失败: $_" }
            }
        }
        
        '检查工具状态' = {
            try {
                $tools = @('git', 'starship', 'eza', 'zoxide', 'fzf', 'ripgrep', 'fd')
                $missing = $tools | Where-Object { -not (Get-Command $_ -ErrorAction SilentlyContinue) }
                
                if ($missing.Count -eq 0) {
                    return @{ Success = $true; Message = "所有核心工具都可用" }
                } else {
                    return @{ Success = $false; Message = "缺少工具: $($missing -join ', ')" }
                }
            } catch {
                return @{ Success = $false; Message = "工具检查失败: $_" }
            }
        }
    }
    
    foreach ($fixName in $fixes.Keys) {
        Write-Host "执行: $fixName..." -ForegroundColor Cyan -NoNewline
        
        $result = & $fixes[$fixName]
        
        if ($result.Success) {
            Write-Host " ✅" -ForegroundColor Green
        } else {
            Write-Host " ❌" -ForegroundColor Red
        }
        
        Write-Host "  $($result.Message)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "💡 如果问题持续，请运行 'Start-PWShSetupWizard' 重新设置" -ForegroundColor Yellow
}

# 别名
Set-Alias -Name setup-wizard -Value Start-PWShSetupWizard -Force
Set-Alias -Name pwsh-wizard -Value Start-PWShSetupWizard -Force
Set-Alias -Name quick-fix -Value Invoke-PWShQuickFix -Force
Set-Alias -Name pwsh-fix -Value Invoke-PWShQuickFix -Force

# 导出函数
Export-ModuleMember -Function @(
    'Start-PWShSetupWizard',
    'Invoke-PWShQuickFix'
) -Alias @(
    'setup-wizard',
    'pwsh-wizard', 
    'quick-fix',
    'pwsh-fix'
)