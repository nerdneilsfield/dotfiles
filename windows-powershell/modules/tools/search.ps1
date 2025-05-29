# Advanced Search Tools Integration
# fd + ripgrep + fzf 深度集成搜索功能

# 工具可用性检查
$script:FdAvailable = $null
$script:RipgrepAvailable = $null
$script:FzfAvailable = $null

function Test-SearchToolsAvailability {
    <#
    .SYNOPSIS
    检查搜索工具的可用性
    #>
    if ($null -eq $script:FdAvailable) {
        $script:FdAvailable = Get-Command fd -ErrorAction SilentlyContinue
    }
    if ($null -eq $script:RipgrepAvailable) {
        $script:RipgrepAvailable = Get-Command rg -ErrorAction SilentlyContinue
    }
    if ($null -eq $script:FzfAvailable) {
        $script:FzfAvailable = Get-Command fzf -ErrorAction SilentlyContinue
    }
    
    return @{
        Fd = $null -ne $script:FdAvailable
        Ripgrep = $null -ne $script:RipgrepAvailable
        Fzf = $null -ne $script:FzfAvailable
    }
}

# fd 增强文件查找
function Find-Files {
    <#
    .SYNOPSIS
    使用 fd 进行高级文件查找
    .PARAMETER Pattern
    搜索模式
    .PARAMETER Type
    文件类型过滤
    .PARAMETER Extension
    文件扩展名
    .PARAMETER MaxDepth
    最大搜索深度
    .PARAMETER Path
    搜索路径，默认当前目录
    .PARAMETER HiddenFiles
    是否包含隐藏文件
    #>
    param(
        [string]$Pattern = ".",
        [ValidateSet("file", "directory", "symlink")]
        [string]$Type,
        [string[]]$Extension,
        [int]$MaxDepth,
        [string]$Path = ".",
        [switch]$HiddenFiles,
        [switch]$Interactive
    )
    
    $tools = Test-SearchToolsAvailability
    if (-not $tools.Fd) {
        Write-Warning "fd 不可用，使用 Get-ChildItem 替代"
        if ($Extension) {
            Get-ChildItem -Path $Path -Recurse -File | Where-Object { $_.Extension -in $Extension }
        } else {
            Get-ChildItem -Path $Path -Recurse
        }
        return
    }
    
    $fdArgs = @()
    
    # 基础参数
    if ($Pattern -ne ".") {
        $fdArgs += $Pattern
    }
    
    if ($Type) {
        $fdArgs += "--type", $Type.Substring(0,1)  # f, d, l
    }
    
    if ($Extension) {
        foreach ($ext in $Extension) {
            $fdArgs += "--extension", $ext.TrimStart('.')
        }
    }
    
    if ($MaxDepth) {
        $fdArgs += "--max-depth", $MaxDepth
    }
    
    if ($HiddenFiles) {
        $fdArgs += "--hidden"
    }
    
    # 添加路径
    $fdArgs += $Path
    
    try {
        if ($Interactive -and $tools.Fzf) {
            & fd @fdArgs | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
        } else {
            & fd @fdArgs
        }
    }
    catch {
        Write-Error "文件查找失败: $_"
    }
}

function Find-CodeFiles {
    <#
    .SYNOPSIS
    查找代码文件
    .PARAMETER Pattern
    搜索模式
    .PARAMETER Path
    搜索路径
    #>
    param(
        [string]$Pattern = ".",
        [string]$Path = "."
    )
    
    $codeExtensions = @('ps1', 'py', 'js', 'ts', 'jsx', 'tsx', 'java', 'c', 'cpp', 'h', 'hpp', 'cs', 'php', 'rb', 'go', 'rs', 'swift', 'kt', 'scala', 'clj', 'hs', 'ml', 'fs', 'r', 'sh', 'bat', 'cmd')
    
    Find-Files -Pattern $Pattern -Extension $codeExtensions -Path $Path -Interactive
}

function Find-ConfigFiles {
    <#
    .SYNOPSIS
    查找配置文件
    .PARAMETER Pattern
    搜索模式
    .PARAMETER Path
    搜索路径
    #>
    param(
        [string]$Pattern = ".",
        [string]$Path = "."
    )
    
    $configExtensions = @('json', 'yaml', 'yml', 'toml', 'ini', 'conf', 'config', 'xml', 'properties')
    
    Find-Files -Pattern $Pattern -Extension $configExtensions -Path $Path -Interactive
}

# ripgrep 增强内容搜索
function Search-Content {
    <#
    .SYNOPSIS
    使用 ripgrep 进行高级内容搜索
    .PARAMETER Pattern
    搜索模式（支持正则表达式）
    .PARAMETER Type
    文件类型
    .PARAMETER Extension
    文件扩展名
    .PARAMETER Path
    搜索路径
    .PARAMETER CaseSensitive
    区分大小写
    .PARAMETER WholeWord
    全词匹配
    .PARAMETER Context
    显示上下文行数
    .PARAMETER MaxCount
    每个文件最大匹配数
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Pattern,
        [string[]]$Type,
        [string[]]$Extension,
        [string]$Path = ".",
        [switch]$CaseSensitive,
        [switch]$WholeWord,
        [int]$Context = 0,
        [int]$MaxCount,
        [switch]$Interactive
    )
    
    $tools = Test-SearchToolsAvailability
    if (-not $tools.Ripgrep) {
        Write-Warning "ripgrep 不可用，使用 Select-String 替代"
        Get-ChildItem -Path $Path -Recurse -File | Select-String -Pattern $Pattern -CaseSensitive:$CaseSensitive
        return
    }
    
    $rgArgs = @()
    
    # 基础参数
    $rgArgs += $Pattern
    
    if ($Type) {
        foreach ($t in $Type) {
            $rgArgs += "--type", $t
        }
    }
    
    if ($Extension) {
        foreach ($ext in $Extension) {
            $rgArgs += "--glob", "*.$($ext.TrimStart('.'))"
        }
    }
    
    if (-not $CaseSensitive) {
        $rgArgs += "--ignore-case"
    }
    
    if ($WholeWord) {
        $rgArgs += "--word-regexp"
    }
    
    if ($Context -gt 0) {
        $rgArgs += "--context", $Context
    }
    
    if ($MaxCount) {
        $rgArgs += "--max-count", $MaxCount
    }
    
    # 添加路径
    $rgArgs += $Path
    
    try {
        if ($Interactive -and $tools.Fzf) {
            & rg @rgArgs --color=always | fzf --ansi --preview 'echo {}' --delimiter ':' --preview 'bat --style=numbers --color=always --highlight-line {2} {1}'
        } else {
            & rg @rgArgs
        }
    }
    catch {
        Write-Error "内容搜索失败: $_"
    }
}

function Search-CodeContent {
    <#
    .SYNOPSIS
    在代码文件中搜索内容
    .PARAMETER Pattern
    搜索模式
    .PARAMETER Path
    搜索路径
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Pattern,
        [string]$Path = "."
    )
    
    $codeTypes = @('ps1', 'py', 'js', 'ts', 'java', 'c', 'cpp', 'cs', 'php', 'rb', 'go', 'rs')
    
    Search-Content -Pattern $Pattern -Type $codeTypes -Path $Path -Interactive
}

function Search-TodoComments {
    <#
    .SYNOPSIS
    查找 TODO、FIXME、HACK 等注释
    .PARAMETER Path
    搜索路径
    #>
    param(
        [string]$Path = "."
    )
    
    $pattern = "TODO|FIXME|HACK|XXX|BUG|NOTE"
    
    Search-Content -Pattern $pattern -Path $Path -Context 2 -Interactive
}

# fzf 增强交互式搜索
function Invoke-FuzzyGrep {
    <#
    .SYNOPSIS
    模糊内容搜索 (fzf + ripgrep)
    .PARAMETER InitialQuery
    初始查询
    .PARAMETER Path
    搜索路径
    #>
    param(
        [string]$InitialQuery,
        [string]$Path = "."
    )
    
    $tools = Test-SearchToolsAvailability
    if (-not ($tools.Fzf -and $tools.Ripgrep)) {
        Write-Warning "需要 fzf 和 ripgrep"
        return
    }
    
    try {
        $env:FZF_DEFAULT_COMMAND = "rg --files --hidden --follow --glob '!.git/*' $Path"
        
        if ($InitialQuery) {
            & fzf --query $InitialQuery --preview 'bat --style=numbers --color=always --line-range :500 {}'
        } else {
            & fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
        }
    }
    catch {
        Write-Error "模糊搜索失败: $_"
    }
    finally {
        Remove-Item env:FZF_DEFAULT_COMMAND -ErrorAction SilentlyContinue
    }
}

function Invoke-FuzzyFind {
    <#
    .SYNOPSIS
    模糊文件查找 (fzf + fd)
    .PARAMETER InitialQuery
    初始查询
    .PARAMETER Path
    搜索路径
    #>
    param(
        [string]$InitialQuery,
        [string]$Path = "."
    )
    
    $tools = Test-SearchToolsAvailability
    if (-not ($tools.Fzf -and $tools.Fd)) {
        Write-Warning "需要 fzf 和 fd"
        return
    }
    
    try {
        if ($InitialQuery) {
            & fd . $Path | fzf --query $InitialQuery --preview 'bat --style=numbers --color=always --line-range :500 {}'
        } else {
            & fd . $Path | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
        }
    }
    catch {
        Write-Error "模糊查找失败: $_"
    }
}

function Invoke-InteractiveSearch {
    <#
    .SYNOPSIS
    交互式搜索界面
    .PARAMETER Path
    搜索路径
    #>
    param(
        [string]$Path = "."
    )
    
    Write-Host "🔍 交互式搜索菜单" -ForegroundColor Cyan
    Write-Host "=" * 30
    Write-Host "1. 文件名搜索 (fd + fzf)"
    Write-Host "2. 内容搜索 (rg + fzf)"
    Write-Host "3. 代码文件搜索"
    Write-Host "4. 配置文件搜索"
    Write-Host "5. TODO 注释搜索"
    Write-Host "6. 退出"
    
    do {
        $choice = Read-Host "`n请选择 (1-6)"
        
        switch ($choice) {
            "1" {
                $query = Read-Host "文件名模式 (可选)"
                Invoke-FuzzyFind -InitialQuery $query -Path $Path
            }
            "2" {
                $query = Read-Host "搜索内容"
                if ($query) {
                    Search-Content -Pattern $query -Path $Path -Interactive
                }
            }
            "3" {
                Find-CodeFiles -Path $Path
            }
            "4" {
                Find-ConfigFiles -Path $Path
            }
            "5" {
                Search-TodoComments -Path $Path
            }
            "6" {
                break
            }
            default {
                Write-Host "无效选择，请重试" -ForegroundColor Red
            }
        }
    } while ($choice -ne "6")
}

# 别名定义
function find { Find-Files @args }
function find-code { Find-CodeFiles @args }
function find-config { Find-ConfigFiles @args }
function grep { Search-Content @args }
function grep-code { Search-CodeContent @args }
function grep-todo { Search-TodoComments @args }
function fgrep { Invoke-FuzzyGrep @args }
function ffd { Invoke-FuzzyFind @args }
function search { Invoke-InteractiveSearch @args }

# 高级搜索组合功能
function Search-ProjectStructure {
    <#
    .SYNOPSIS
    分析项目结构
    .PARAMETER Path
    项目路径
    #>
    param(
        [string]$Path = "."
    )
    
    Write-Host "📊 项目结构分析: $Path" -ForegroundColor Cyan
    Write-Host "=" * 50
    
    # 文件类型统计
    Write-Host "`n📁 文件类型统计:" -ForegroundColor Green
    if ((Test-SearchToolsAvailability).Fd) {
        & fd . $Path --type f | ForEach-Object { 
            [System.IO.Path]::GetExtension($_) 
        } | Where-Object { $_ } | Group-Object | Sort-Object Count -Descending | Select-Object -First 10 | Format-Table Name, Count -AutoSize
    }
    
    # 代码行数统计
    Write-Host "`n📝 代码文件:" -ForegroundColor Green
    Find-CodeFiles -Path $Path | Measure-Object | Select-Object Count
    
    # 配置文件
    Write-Host "`n⚙️  配置文件:" -ForegroundColor Green
    Find-ConfigFiles -Path $Path | Measure-Object | Select-Object Count
    
    # TODO 注释
    Write-Host "`n📋 TODO 注释:" -ForegroundColor Green
    if ((Test-SearchToolsAvailability).Ripgrep) {
        $todoCount = & rg "TODO|FIXME|HACK|XXX" $Path --count-matches | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        Write-Host "   发现 $todoCount 个待办项"
    }
}

# 模块初始化
$tools = Test-SearchToolsAvailability

Write-Host "🔍 搜索工具状态:" -ForegroundColor Cyan
Write-Host "   fd: $(if($tools.Fd) { '✅' } else { '❌' })"
Write-Host "   ripgrep: $(if($tools.Ripgrep) { '✅' } else { '❌' })"
Write-Host "   fzf: $(if($tools.Fzf) { '✅' } else { '❌' })"

if ($tools.Fd -and $tools.Ripgrep -and $tools.Fzf) {
    Write-Host "🎉 所有搜索工具已就绪" -ForegroundColor Green
} else {
    Write-Host "⚠️  部分搜索工具不可用，功能可能受限" -ForegroundColor Yellow
    Write-Host "   运行 'Install-DevEnvironment' 安装缺失工具" -ForegroundColor Blue
}

# Note: Functions and aliases are automatically available when dot-sourced