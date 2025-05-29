# PowerShell 自动补全和 PSReadLine 增强
# 现代化命令行体验，集成 fzf 和智能补全

# PSReadLine 模块检查和配置
function Initialize-PSReadLine {
    <#
    .SYNOPSIS
    初始化PSReadLine模块和配置
    #>
    # 检查 PSReadLine 是否可用
    if (!(Get-Module PSReadLine -ListAvailable)) {
        Write-ProfileLog "PSReadLine 模块不可用" -Level "WARN"
        return $false
    }
    
    # 导入 PSReadLine
    try {
        Import-Module PSReadLine -Force
        Write-ProfileLog "PSReadLine 模块导入成功" -Level "DEBUG"
    } catch {
        Write-ProfileLog "PSReadLine 模块导入失败: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
    
    # 基础设置
    Set-PSReadLineOption -HistoryNoDuplicates:$true
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd:$true
    Set-PSReadLineOption -MaximumHistoryCount 10000
    Set-PSReadLineOption -ShowToolTips:$true
    
    # PowerShell 7.2+ 预测性智能感知
    if ($script:IsPowerShell7Plus -and $PSVersionTable.PSVersion -ge [Version]"7.2") {
        try {
            Set-PSReadLineOption -PredictionSource HistoryAndPlugin
            Set-PSReadLineOption -PredictionViewStyle ListView
            Write-ProfileLog "启用预测性智能感知" -Level "DEBUG"
        } catch {
            Write-ProfileLog "预测性智能感知设置失败，使用基础模式" -Level "WARN"
            Set-PSReadLineOption -PredictionSource History
        }
    } elseif ($script:IsPowerShell7Plus) {
        Set-PSReadLineOption -PredictionSource History
    }
    
    # 颜色主题
    $colors = @{
        Command                = [ConsoleColor]::Green
        Parameter              = [ConsoleColor]::Gray
        Operator               = [ConsoleColor]::DarkCyan
        Variable               = [ConsoleColor]::Yellow
        String                 = [ConsoleColor]::Blue
        Number                 = [ConsoleColor]::Magenta
        Type                   = [ConsoleColor]::DarkGreen
        Comment                = [ConsoleColor]::DarkGray
        Keyword                = [ConsoleColor]::DarkBlue
        Error                  = [ConsoleColor]::Red
        Emphasis               = [ConsoleColor]::Cyan
        Selection              = [ConsoleColor]::DarkYellow
        InlinePrediction       = [ConsoleColor]::DarkGray
    }
    
    Set-PSReadLineOption -Colors $colors
    
    # 编辑模式 - 类似 Emacs
    Set-PSReadLineOption -EditMode Emacs
    
    return $true
}

# 设置键绑定
function Set-PSReadLineKeyBindings {
    <#
    .SYNOPSIS
    设置PSReadLine键位绑定
    #>
    if (!(Get-Module PSReadLine)) {
        return
    }
    
    # 基础导航和编辑
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
    Set-PSReadLineKeyHandler -Key Ctrl+z -Function Undo
    Set-PSReadLineKeyHandler -Key Ctrl+y -Function Redo
    
    # 历史记录导航
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
    Set-PSReadLineKeyHandler -Key Ctrl+s -Function ForwardSearchHistory
    
    # 字符和单词操作
    Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+Backspace -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Key Ctrl+Delete -Function DeleteWord
    
    # 行操作
    Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine
    Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine
    Set-PSReadLineKeyHandler -Key Ctrl+k -Function DeleteToEnd
    Set-PSReadLineKeyHandler -Key Ctrl+u -Function DeleteLine
    
    # 智能补全
    Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function Complete
    Set-PSReadLineKeyHandler -Key Alt+? -Function WhatIsKey
    
    Write-ProfileLog "PSReadLine 键绑定设置完成" -Level "DEBUG"
}

# FZF 集成键绑定
function Set-FzfKeyBindings {
    <#
    .SYNOPSIS
    设置fzf模糊搜索键位绑定
    #>
    # 检查 fzf 是否可用
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-ProfileLog "fzf 未安装，跳过 fzf 键绑定" -Level "DEBUG"
        return
    }
    
    if (!(Get-Module PSReadLine)) {
        return
    }
    
    try {
        # Ctrl+T - 文件选择
        Set-PSReadLineKeyHandler -Key Ctrl+t -ScriptBlock {
            $selected = Get-ChildItem -Recurse -File | ForEach-Object { $_.FullName } | fzf --height=40% --reverse
            if ($selected) {
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected)
            }
        }
        
        # Alt+C - 目录跳转
        Set-PSReadLineKeyHandler -Key Alt+c -ScriptBlock {
            $selected = Get-ChildItem -Recurse -Directory | ForEach-Object { $_.FullName } | fzf --height=40% --reverse
            if ($selected) {
                Set-Location $selected
                [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
            }
        }
        
        # Ctrl+R - 历史记录搜索 (覆盖默认行为)
        Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock {
            $history = Get-History | ForEach-Object { $_.CommandLine } | Get-Unique
            $selected = $history | fzf --height=40% --reverse --query=(Get-PSReadLineOption).HistorySearchCaseSensitive
            if ($selected) {
                [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected)
            }
        }
        
        Write-ProfileLog "fzf 键绑定设置完成" -Level "DEBUG"
    } catch {
        Write-ProfileLog "fzf 键绑定设置失败: $($_.Exception.Message)" -Level "WARN"
    }
}

# 智能补全函数
function Register-CustomCompleters {
    <#
    .SYNOPSIS
    注册自定义命令补全器
    #>
    # Git 分支补全
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Register-ArgumentCompleter -Native -CommandName git -ScriptBlock {
            param($wordToComplete, $commandAst, $cursorPosition)
            
            $gitSubcommands = @('add', 'commit', 'push', 'pull', 'checkout', 'branch', 'merge', 'status', 'log', 'diff')
            
            # 简单的子命令补全
            if ($commandAst.CommandElements.Count -eq 2) {
                $gitSubcommands | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
            }
            # 分支名补全 (对于 checkout, merge 等)
            elseif ($commandAst.CommandElements.Count -ge 3 -and 
                    $commandAst.CommandElements[1].Value -in @('checkout', 'merge', 'branch')) {
                try {
                    $branches = git branch --format='%(refname:short)' 2>$null | Where-Object { $_ -like "$wordToComplete*" }
                    $branches | ForEach-Object {
                        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "分支: $_")
                    }
                } catch {
                    # 忽略错误，可能不在 git 仓库中
                }
            }
        }
    }
    
    # Docker 补全
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        Register-ArgumentCompleter -Native -CommandName docker -ScriptBlock {
            param($wordToComplete, $commandAst, $cursorPosition)
            
            $dockerCommands = @('run', 'build', 'pull', 'push', 'ps', 'images', 'exec', 'logs', 'stop', 'start', 'restart', 'rm', 'rmi')
            
            if ($commandAst.CommandElements.Count -eq 2) {
                $dockerCommands | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
            }
        }
    }
    
    # Scoop 补全
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Register-ArgumentCompleter -Native -CommandName scoop -ScriptBlock {
            param($wordToComplete, $commandAst, $cursorPosition)
            
            $scoopCommands = @('install', 'uninstall', 'update', 'search', 'list', 'info', 'bucket', 'cache', 'cleanup', 'status')
            
            if ($commandAst.CommandElements.Count -eq 2) {
                $scoopCommands | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
            }
            # 已安装包补全 (对于 uninstall, update)
            elseif ($commandAst.CommandElements.Count -ge 3 -and 
                    $commandAst.CommandElements[1].Value -in @('uninstall', 'update', 'info')) {
                try {
                    $installed = scoop list | ForEach-Object { $_.Name } | Where-Object { $_ -like "$wordToComplete*" }
                    $installed | ForEach-Object {
                        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "已安装: $_")
                    }
                } catch {
                    # 忽略错误
                }
            }
        }
    }
    
    Write-ProfileLog "自定义补全器注册完成" -Level "DEBUG"
}

# 智能路径补全增强
function Enable-SmartPathCompletion {
    <#
    .SYNOPSIS
    启用智能路径补全功能
    #>
    if (!(Get-Module PSReadLine)) {
        return
    }
    
    # 智能引号处理
    Set-PSReadLineOption -CompletionQueryItems 100
    
    # 大小写不敏感补全
    if ($script:IsPowerShell7Plus) {
        Set-PSReadLineOption -HistorySearchCaseSensitive:$false
    }
    
    Write-ProfileLog "智能路径补全启用" -Level "DEBUG"
}

# 补全菜单增强
function Set-CompletionMenuStyle {
    <#
    .SYNOPSIS
    设置补全菜单样式
    #>
    if (!(Get-Module PSReadLine)) {
        return
    }
    
    # 设置补全菜单样式
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineOption -ShowToolTips:$true
    
    # PowerShell 7+ 增强
    if ($script:IsPowerShell7Plus) {
        try {
            # 列表视图补全 (PowerShell 7.2+)
            if ($PSVersionTable.PSVersion -ge [Version]"7.2") {
                Set-PSReadLineOption -PredictionViewStyle ListView
            }
        } catch {
            Write-ProfileLog "高级补全菜单设置失败" -Level "WARN"
        }
    }
    
    Write-ProfileLog "补全菜单样式设置完成" -Level "DEBUG"
}

# 历史记录增强
function Configure-HistoryFeatures {
    <#
    .SYNOPSIS
    配置历史记录功能
    #>
    if (!(Get-Module PSReadLine)) {
        return
    }
    
    # 历史记录文件路径
    $historyPath = if ($script:IsWindows) {
        "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    } else {
        "$env:HOME/.local/share/powershell/PSReadLine/ConsoleHost_history.txt"
    }
    
    # 确保历史记录目录存在
    $historyDir = Split-Path $historyPath -Parent
    if (!(Test-Path $historyDir)) {
        New-Item -ItemType Directory -Path $historyDir -Force | Out-Null
    }
    
    # 历史记录设置
    Set-PSReadLineOption -MaximumHistoryCount 10000
    Set-PSReadLineOption -HistoryNoDuplicates:$true
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd:$true
    
    # 敏感命令过滤
    $sensitivePatterns = @(
        '*password*', '*secret*', '*token*', '*key*', 
        '*credential*', '*auth*', 'Set-Secret*'
    )
    
    Set-PSReadLineOption -AddToHistoryHandler {
        param($command)
        
        # 过滤敏感命令
        foreach ($pattern in $sensitivePatterns) {
            if ($command -like $pattern) {
                return $false
            }
        }
        
        # 过滤太短的命令
        if ($command.Length -lt 3) {
            return $false
        }
        
        return $true
    }
    
    Write-ProfileLog "历史记录功能配置完成" -Level "DEBUG"
}

# 显示补全状态
function Get-CompletionStatus {
    <#
    .SYNOPSIS
    显示补全系统状态信息
    #>
    Write-Host "🔤 补全系统状态" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    
    # PSReadLine 状态
    Write-Host "PSReadLine: " -NoNewline
    if (Get-Module PSReadLine) {
        Write-Host "✅ 已加载" -ForegroundColor Green
        $version = (Get-Module PSReadLine).Version
        Write-Host "  版本: $version" -ForegroundColor Gray
        
        $options = Get-PSReadLineOption
        Write-Host "  预测源: $($options.PredictionSource)" -ForegroundColor Gray
        Write-Host "  编辑模式: $($options.EditMode)" -ForegroundColor Gray
        Write-Host "  历史记录: $($options.MaximumHistoryCount) 条" -ForegroundColor Gray
    } else {
        Write-Host "❌ 未加载" -ForegroundColor Red
    }
    
    # FZF 集成状态
    Write-Host "FZF 集成: " -NoNewline
    if (Get-Command fzf -ErrorAction SilentlyContinue) {
        Write-Host "✅ 可用" -ForegroundColor Green
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
    Write-Host "⌨️  可用快捷键:" -ForegroundColor Cyan
    Write-Host "  Tab           - 菜单补全" -ForegroundColor Yellow
    Write-Host "  Ctrl+R        - 历史搜索 (fzf)" -ForegroundColor Yellow
    Write-Host "  Ctrl+T        - 文件选择 (fzf)" -ForegroundColor Yellow
    Write-Host "  Alt+C         - 目录跳转 (fzf)" -ForegroundColor Yellow
    Write-Host "  ↑/↓          - 历史导航" -ForegroundColor Yellow
    Write-Host "  Ctrl+D        - 删除字符或退出" -ForegroundColor Yellow
    Write-Host "  Ctrl+A/E      - 行首/行尾" -ForegroundColor Yellow
    Write-Host "  Ctrl+W        - 删除单词" -ForegroundColor Yellow
    Write-Host "  Ctrl+K/U      - 删除到行尾/删除整行" -ForegroundColor Yellow
}

# 主初始化函数
function Initialize-CompletionSystem {
    <#
    .SYNOPSIS
    初始化整个补全系统
    #>
    Write-ProfileLog "初始化补全系统" -Level "DEBUG"
    
    # 初始化 PSReadLine
    if (Initialize-PSReadLine) {
        Set-PSReadLineKeyBindings
        Set-CompletionMenuStyle
        Configure-HistoryFeatures
        Enable-SmartPathCompletion
        
        # FZF 集成
        Set-FzfKeyBindings
        
        # 自定义补全器
        Register-CustomCompleters
        
        Write-ProfileLog "补全系统初始化完成" -Level "DEBUG"
        return $true
    } else {
        Write-ProfileLog "补全系统初始化失败" -Level "ERROR"
        return $false
    }
}

# 启动补全系统
Initialize-CompletionSystem

Write-ProfileLog "自动补全模块加载完成" -Level "DEBUG"