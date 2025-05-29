# PowerShell 配置帮助系统
# 提供统一的帮助文档浏览和函数搜索功能

# 帮助系统配置
$script:HelpConfig = @{
    ConfigDir = if ($PSCommandPath) { 
        Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSCommandPath))
    } else {
        "$env:USERPROFILE\.config\powershell"
    }
    Categories = @('core', 'tools', 'platform', 'performance')
    Colors = @{
        Title = 'Green'
        Subtitle = 'Yellow'
        Command = 'Cyan'
        Description = 'White'
        Category = 'Magenta'
        Example = 'Gray'
        Error = 'Red'
        Success = 'Green'
    }
}

# 显示 README 文档
function Show-PWShReadme {
    <#
    .SYNOPSIS
    显示 PowerShell 配置的完整 README 文档
    
    .DESCRIPTION
    提供多种方式查看 README 文档，支持分页和语法高亮
    
    .PARAMETER Section
    显示特定章节
    
    .PARAMETER Raw
    显示原始文本，不使用语法高亮
    
    .EXAMPLE
    Show-PWShReadme
    显示完整 README
    
    .EXAMPLE
    Show-PWShReadme -Section "安装"
    只显示安装章节
    #>
    [CmdletBinding()]
    param(
        [string]$Section,
        [switch]$Raw
    )
    
    $readmePath = Join-Path $script:HelpConfig.ConfigDir "README.md"
    
    if (-not (Test-Path $readmePath)) {
        Write-Host "❌ README 文件不存在: $readmePath" -ForegroundColor $script:HelpConfig.Colors.Error
        return
    }
    
    try {
        $content = Get-Content $readmePath -Raw -Encoding UTF8
        
        if ($Section) {
            # 提取特定章节
            $pattern = "(?ms)^#{1,3}\s*$Section.*?(?=^#{1,3}\s|\z)"
            $matches = [regex]::Matches($content, $pattern)
            
            if ($matches.Count -eq 0) {
                Write-Host "⚠️  未找到章节: $Section" -ForegroundColor $script:HelpConfig.Colors.Error
                return
            }
            
            $content = $matches[0].Value
        }
        
        # 尝试使用语法高亮工具
        if (-not $Raw) {
            $tools = @('bat', 'mdcat', 'glow')
            $usedTool = $null
            
            foreach ($tool in $tools) {
                if (Get-Command $tool -ErrorAction SilentlyContinue) {
                    $usedTool = $tool
                    break
                }
            }
            
            if ($usedTool) {
                Write-Host "📖 PowerShell 配置文档 (使用 $usedTool)" -ForegroundColor $script:HelpConfig.Colors.Title
                $content | & $usedTool --language markdown
                return
            }
        }
        
        # 简单格式化输出
        Write-Host "📖 PowerShell 配置文档" -ForegroundColor $script:HelpConfig.Colors.Title
        Write-Host "=" * 60 -ForegroundColor $script:HelpConfig.Colors.Subtitle
        
        $lines = $content -split "`n"
        foreach ($line in $lines) {
            if ($line -match '^#{1,3}\s+(.+)') {
                Write-Host $line -ForegroundColor $script:HelpConfig.Colors.Subtitle
            } elseif ($line -match '^```') {
                Write-Host $line -ForegroundColor $script:HelpConfig.Colors.Example
            } elseif ($line -match '^\s*-\s+`([^`]+)`') {
                Write-Host $line -ForegroundColor $script:HelpConfig.Colors.Command
            } else {
                Write-Host $line -ForegroundColor $script:HelpConfig.Colors.Description
            }
        }
    } catch {
        Write-Host "❌ 读取 README 失败: $_" -ForegroundColor $script:HelpConfig.Colors.Error
    }
}

# 获取所有可用函数及其文档
function Get-PWShFunctions {
    <#
    .SYNOPSIS
    获取 PowerShell 配置中定义的所有函数
    
    .DESCRIPTION
    扫描所有模块文件，提取函数定义和帮助信息
    
    .PARAMETER Category
    筛选特定类别的函数
    
    .PARAMETER Pattern
    按名称模式筛选函数
    
    .EXAMPLE
    Get-PWShFunctions -Category tools
    获取工具类函数
    
    .EXAMPLE
    Get-PWShFunctions -Pattern "*git*"
    获取包含 git 的函数
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('core', 'tools', 'platform', 'performance', 'all')]
        [string]$Category = 'all',
        
        [string]$Pattern = '*'
    )
    
    $functions = @()
    $moduleDir = Join-Path $script:HelpConfig.ConfigDir "modules"
    
    # 确定要扫描的目录
    $dirsToScan = if ($Category -eq 'all') {
        $script:HelpConfig.Categories
    } else {
        @($Category)
    }
    
    foreach ($cat in $dirsToScan) {
        $catDir = Join-Path $moduleDir $cat
        
        if (Test-Path $catDir) {
            $psFiles = Get-ChildItem $catDir -Filter "*.ps1" -Recurse
            
            foreach ($file in $psFiles) {
                try {
                    $content = Get-Content $file.FullName -Raw -Encoding UTF8
                    
                    # 提取函数定义
                    $funcPattern = '(?ms)^function\s+([a-zA-Z][a-zA-Z0-9_-]*)\s*\{.*?^}'
                    $funcMatches = [regex]::Matches($content, $funcPattern)
                    
                    foreach ($match in $funcMatches) {
                        $funcName = $match.Groups[1].Value
                        
                        if ($funcName -like $Pattern) {
                            # 提取帮助信息
                            $helpPattern = "(?ms)<#.*?\.SYNOPSIS\s+(.*?)(?:\.DESCRIPTION|\s*#>)"
                            $helpMatch = [regex]::Match($match.Value, $helpPattern)
                            
                            $synopsis = if ($helpMatch.Success) {
                                $helpMatch.Groups[1].Value.Trim()
                            } else {
                                "无描述"
                            }
                            
                            $functions += [PSCustomObject]@{
                                Name = $funcName
                                Category = $cat
                                File = $file.Name
                                Synopsis = $synopsis
                                FullPath = $file.FullName
                            }
                        }
                    }
                } catch {
                    Write-Warning "解析文件失败: $($file.FullName) - $_"
                }
            }
        }
    }
    
    return $functions | Sort-Object Category, Name
}

# 显示函数详细帮助
function Show-PWShFunctionHelp {
    <#
    .SYNOPSIS
    显示特定函数的详细帮助信息
    
    .DESCRIPTION
    提取并显示函数的完整帮助文档，包括参数、示例等
    
    .PARAMETER FunctionName
    要显示帮助的函数名称
    
    .EXAMPLE
    Show-PWShFunctionHelp -FunctionName "Get-SystemHealth"
    显示系统健康检查函数的帮助
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FunctionName
    )
    
    # 首先尝试获取已加载函数的帮助
    try {
        $help = Get-Help $FunctionName -ErrorAction Stop
        
        Write-Host "📚 $($help.Name)" -ForegroundColor $script:HelpConfig.Colors.Title
        Write-Host "=" * 60 -ForegroundColor $script:HelpConfig.Colors.Subtitle
        
        if ($help.Synopsis) {
            Write-Host "概述:" -ForegroundColor $script:HelpConfig.Colors.Subtitle
            Write-Host "  $($help.Synopsis)" -ForegroundColor $script:HelpConfig.Colors.Description
            Write-Host ""
        }
        
        if ($help.Description) {
            Write-Host "描述:" -ForegroundColor $script:HelpConfig.Colors.Subtitle
            Write-Host "  $($help.Description.Text)" -ForegroundColor $script:HelpConfig.Colors.Description
            Write-Host ""
        }
        
        if ($help.Parameters) {
            Write-Host "参数:" -ForegroundColor $script:HelpConfig.Colors.Subtitle
            foreach ($param in $help.Parameters.Parameter) {
                Write-Host "  -$($param.Name)" -ForegroundColor $script:HelpConfig.Colors.Command -NoNewline
                if ($param.Type) {
                    Write-Host " [$($param.Type.Name)]" -ForegroundColor $script:HelpConfig.Colors.Category -NoNewline
                }
                Write-Host ""
                if ($param.Description) {
                    Write-Host "    $($param.Description.Text)" -ForegroundColor $script:HelpConfig.Colors.Description
                }
                Write-Host ""
            }
        }
        
        if ($help.Examples) {
            Write-Host "示例:" -ForegroundColor $script:HelpConfig.Colors.Subtitle
            foreach ($example in $help.Examples.Example) {
                Write-Host "  $($example.Title)" -ForegroundColor $script:HelpConfig.Colors.Command
                Write-Host "  $($example.Code)" -ForegroundColor $script:HelpConfig.Colors.Example
                if ($example.Remarks) {
                    Write-Host "  $($example.Remarks.Text)" -ForegroundColor $script:HelpConfig.Colors.Description
                }
                Write-Host ""
            }
        }
        
        return
    } catch {
        # 函数未加载，尝试从文件中提取
    }
    
    # 从文件中搜索函数
    $functions = Get-PWShFunctions -Pattern $FunctionName
    $targetFunc = $functions | Where-Object { $_.Name -eq $FunctionName }
    
    if (-not $targetFunc) {
        Write-Host "❌ 未找到函数: $FunctionName" -ForegroundColor $script:HelpConfig.Colors.Error
        return
    }
    
    try {
        $content = Get-Content $targetFunc.FullPath -Raw -Encoding UTF8
        
        # 提取函数完整定义
        $funcPattern = "(?ms)^function\s+$FunctionName\s*\{.*?^}"
        $match = [regex]::Match($content, $funcPattern)
        
        if ($match.Success) {
            # 提取帮助块
            $helpPattern = '(?ms)<#(.*?)#>'
            $helpMatch = [regex]::Match($match.Value, $helpPattern)
            
            Write-Host "📚 $FunctionName" -ForegroundColor $script:HelpConfig.Colors.Title
            Write-Host "=" * 60 -ForegroundColor $script:HelpConfig.Colors.Subtitle
            Write-Host "文件: $($targetFunc.File)" -ForegroundColor $script:HelpConfig.Colors.Category
            Write-Host "类别: $($targetFunc.Category)" -ForegroundColor $script:HelpConfig.Colors.Category
            Write-Host ""
            
            if ($helpMatch.Success) {
                $helpText = $helpMatch.Groups[1].Value
                $lines = $helpText -split "`n"
                
                $currentSection = ""
                foreach ($line in $lines) {
                    $line = $line.Trim()
                    
                    if ($line -match '^\.(SYNOPSIS|DESCRIPTION|PARAMETER|EXAMPLE)') {
                        $currentSection = $matches[1]
                        Write-Host "$($currentSection.ToLower()):" -ForegroundColor $script:HelpConfig.Colors.Subtitle
                    } elseif ($line -and $line -notmatch '^\s*$') {
                        $color = switch ($currentSection) {
                            'EXAMPLE' { $script:HelpConfig.Colors.Example }
                            'PARAMETER' { $script:HelpConfig.Colors.Command }
                            default { $script:HelpConfig.Colors.Description }
                        }
                        Write-Host "  $line" -ForegroundColor $color
                    }
                }
            } else {
                Write-Host "无帮助文档" -ForegroundColor $script:HelpConfig.Colors.Error
            }
        }
    } catch {
        Write-Host "❌ 读取函数帮助失败: $_" -ForegroundColor $script:HelpConfig.Colors.Error
    }
}

# 搜索函数
function Search-PWShFunctions {
    <#
    .SYNOPSIS
    搜索 PowerShell 配置中的函数
    
    .DESCRIPTION
    按名称或描述搜索函数，支持交互式选择
    
    .PARAMETER Query
    搜索查询字符串
    
    .PARAMETER Interactive
    启用交互式选择模式
    
    .EXAMPLE
    Search-PWShFunctions "git"
    搜索包含 git 的函数
    
    .EXAMPLE
    Search-PWShFunctions -Interactive
    启动交互式函数浏览器
    #>
    [CmdletBinding()]
    param(
        [string]$Query,
        [switch]$Interactive
    )
    
    $functions = Get-PWShFunctions
    
    if ($Query) {
        $functions = $functions | Where-Object {
            $_.Name -like "*$Query*" -or $_.Synopsis -like "*$Query*"
        }
    }
    
    if ($functions.Count -eq 0) {
        Write-Host "❌ 未找到匹配的函数" -ForegroundColor $script:HelpConfig.Colors.Error
        return
    }
    
    if ($Interactive -and (Get-Command Out-GridView -ErrorAction SilentlyContinue)) {
        # 使用 Out-GridView 进行交互式选择
        $selected = $functions | Out-GridView -Title "PowerShell 函数浏览器" -OutputMode Single
        
        if ($selected) {
            Show-PWShFunctionHelp -FunctionName $selected.Name
        }
    } else {
        # 显示搜索结果
        Write-Host "🔍 找到 $($functions.Count) 个函数:" -ForegroundColor $script:HelpConfig.Colors.Title
        Write-Host ""
        
        $functions | Group-Object Category | ForEach-Object {
            Write-Host "📁 $($_.Name)" -ForegroundColor $script:HelpConfig.Colors.Category
            
            $_.Group | ForEach-Object {
                Write-Host "  • " -ForegroundColor $script:HelpConfig.Colors.Command -NoNewline
                Write-Host $_.Name -ForegroundColor $script:HelpConfig.Colors.Command -NoNewline
                Write-Host " - $($_.Synopsis)" -ForegroundColor $script:HelpConfig.Colors.Description
            }
            Write-Host ""
        }
        
        Write-Host "💡 使用 " -ForegroundColor $script:HelpConfig.Colors.Description -NoNewline
        Write-Host "Show-PWShFunctionHelp <函数名>" -ForegroundColor $script:HelpConfig.Colors.Command -NoNewline
        Write-Host " 查看详细帮助" -ForegroundColor $script:HelpConfig.Colors.Description
    }
}

# 显示所有可用别名
function Show-PWShAliases {
    <#
    .SYNOPSIS
    显示 PowerShell 配置中定义的所有别名
    
    .DESCRIPTION
    列出自定义别名及其对应的命令
    
    .PARAMETER Pattern
    筛选特定模式的别名
    
    .EXAMPLE
    Show-PWShAliases
    显示所有别名
    
    .EXAMPLE
    Show-PWShAliases -Pattern "git*"
    显示 git 相关别名
    #>
    [CmdletBinding()]
    param(
        [string]$Pattern = '*'
    )
    
    Write-Host "🔗 PowerShell 配置别名" -ForegroundColor $script:HelpConfig.Colors.Title
    Write-Host "=" * 50 -ForegroundColor $script:HelpConfig.Colors.Subtitle
    
    # 获取自定义别名（排除系统默认别名）
    $customAliases = Get-Alias | Where-Object {
        $_.Name -like $Pattern -and
        $_.Source -eq '' -and
        $_.Name -notmatch '^[%?]$'
    } | Sort-Object Name
    
    if ($customAliases.Count -eq 0) {
        Write-Host "❌ 未找到匹配的别名" -ForegroundColor $script:HelpConfig.Colors.Error
        return
    }
    
    $customAliases | ForEach-Object {
        Write-Host "  $($_.Name)" -ForegroundColor $script:HelpConfig.Colors.Command -NoNewline
        Write-Host " → " -ForegroundColor $script:HelpConfig.Colors.Description -NoNewline
        Write-Host $_.Definition -ForegroundColor $script:HelpConfig.Colors.Description
    }
    
    Write-Host ""
    Write-Host "总计: $($customAliases.Count) 个别名" -ForegroundColor $script:HelpConfig.Colors.Success
}

# 统一帮助入口
function Get-PWShHelp {
    <#
    .SYNOPSIS
    PowerShell 配置帮助系统主入口
    
    .DESCRIPTION
    提供统一的帮助系统入口，支持多种帮助模式
    
    .PARAMETER Topic
    帮助主题：readme, functions, aliases, search
    
    .PARAMETER Query
    搜索查询（用于 search 主题）
    
    .PARAMETER Interactive
    启用交互式模式
    
    .EXAMPLE
    Get-PWShHelp
    显示帮助菜单
    
    .EXAMPLE
    Get-PWShHelp readme
    显示 README 文档
    
    .EXAMPLE
    Get-PWShHelp functions
    显示所有函数
    
    .EXAMPLE
    Get-PWShHelp search git
    搜索 git 相关功能
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('readme', 'functions', 'aliases', 'search', 'menu')]
        [string]$Topic = 'menu',
        
        [string]$Query,
        [switch]$Interactive
    )
    
    switch ($Topic) {
        'readme' {
            Show-PWShReadme
        }
        'functions' {
            if ($Query) {
                Search-PWShFunctions -Query $Query -Interactive:$Interactive
            } else {
                $functions = Get-PWShFunctions
                $functions | Group-Object Category | ForEach-Object {
                    Write-Host "📁 $($_.Name) ($($_.Count))" -ForegroundColor $script:HelpConfig.Colors.Category
                    $_.Group | ForEach-Object {
                        Write-Host "  • $($_.Name) - $($_.Synopsis)" -ForegroundColor $script:HelpConfig.Colors.Description
                    }
                    Write-Host ""
                }
            }
        }
        'aliases' {
            Show-PWShAliases -Pattern $Query
        }
        'search' {
            if ($Query) {
                Search-PWShFunctions -Query $Query -Interactive:$Interactive
            } else {
                Write-Host "❌ 搜索需要提供查询字符串" -ForegroundColor $script:HelpConfig.Colors.Error
                Write-Host "示例: Get-PWShHelp search git" -ForegroundColor $script:HelpConfig.Colors.Example
            }
        }
        'menu' {
            Write-Host "🚀 PowerShell 配置帮助系统" -ForegroundColor $script:HelpConfig.Colors.Title
            Write-Host "=" * 50 -ForegroundColor $script:HelpConfig.Colors.Subtitle
            Write-Host ""
            Write-Host "📖 可用命令:" -ForegroundColor $script:HelpConfig.Colors.Subtitle
            Write-Host "  Get-PWShHelp readme" -ForegroundColor $script:HelpConfig.Colors.Command -NoNewline
            Write-Host "          显示完整文档" -ForegroundColor $script:HelpConfig.Colors.Description
            Write-Host "  Get-PWShHelp functions" -ForegroundColor $script:HelpConfig.Colors.Command -NoNewline
            Write-Host "        显示所有函数" -ForegroundColor $script:HelpConfig.Colors.Description
            Write-Host "  Get-PWShHelp aliases" -ForegroundColor $script:HelpConfig.Colors.Command -NoNewline
            Write-Host "          显示所有别名" -ForegroundColor $script:HelpConfig.Colors.Description
            Write-Host "  Get-PWShHelp search <查询>" -ForegroundColor $script:HelpConfig.Colors.Command -NoNewline
            Write-Host "    搜索功能" -ForegroundColor $script:HelpConfig.Colors.Description
            Write-Host ""
            Write-Host "🔍 快捷命令:" -ForegroundColor $script:HelpConfig.Colors.Subtitle
            Write-Host "  help, docs" -ForegroundColor $script:HelpConfig.Colors.Command -NoNewline
            Write-Host "             显示此帮助" -ForegroundColor $script:HelpConfig.Colors.Description
            Write-Host "  funcs" -ForegroundColor $script:HelpConfig.Colors.Command -NoNewline
            Write-Host "                  显示所有函数" -ForegroundColor $script:HelpConfig.Colors.Description
            Write-Host "  search <查询>" -ForegroundColor $script:HelpConfig.Colors.Command -NoNewline
            Write-Host "           搜索功能" -ForegroundColor $script:HelpConfig.Colors.Description
            Write-Host ""
            Write-Host "💡 提示: 添加 " -ForegroundColor $script:HelpConfig.Colors.Description -NoNewline
            Write-Host "-Interactive" -ForegroundColor $script:HelpConfig.Colors.Command -NoNewline
            Write-Host " 启用交互式模式" -ForegroundColor $script:HelpConfig.Colors.Description
        }
    }
}

# 快捷函数
function Show-PWShFunctionsList {
    Get-PWShHelp functions
}

# 别名定义（避免与系统 help 冲突）
Set-Alias -Name pwsh-help -Value Get-PWShHelp -Force
Set-Alias -Name phelp -Value Get-PWShHelp -Force
Set-Alias -Name docs -Value Get-PWShHelp -Force
Set-Alias -Name funcs -Value Show-PWShFunctionsList -Force
Set-Alias -Name psearch -Value "Search-PWShFunctions" -Force

# 注意：通过 dot sourcing 加载时，Export-ModuleMember 不生效
# 函数和别名会自动在全局作用域中可用