# Git Advanced Toolchain Integration
# 集成 lazygit + delta + gh + 高级 Git 操作

# 工具可用性检查
$script:GitAvailable = $null
$script:LazygitAvailable = $null
$script:DeltaAvailable = $null
$script:GhAvailable = $null
$script:FzfAvailable = $null

function Test-GitToolsAvailability {
    <#
    .SYNOPSIS
    检查 Git 工具链的可用性
    #>
    if ($null -eq $script:GitAvailable) {
        $script:GitAvailable = Get-Command git -ErrorAction SilentlyContinue
    }
    if ($null -eq $script:LazygitAvailable) {
        $script:LazygitAvailable = Get-Command lazygit -ErrorAction SilentlyContinue
    }
    if ($null -eq $script:DeltaAvailable) {
        $script:DeltaAvailable = Get-Command delta -ErrorAction SilentlyContinue
    }
    if ($null -eq $script:GhAvailable) {
        $script:GhAvailable = Get-Command gh -ErrorAction SilentlyContinue
    }
    if ($null -eq $script:FzfAvailable) {
        $script:FzfAvailable = Get-Command fzf -ErrorAction SilentlyContinue
    }
    
    return @{
        Git = $null -ne $script:GitAvailable
        Lazygit = $null -ne $script:LazygitAvailable
        Delta = $null -ne $script:DeltaAvailable
        GitHubCLI = $null -ne $script:GhAvailable
        Fzf = $null -ne $script:FzfAvailable
    }
}

function Initialize-GitConfig {
    <#
    .SYNOPSIS
    初始化 Git 配置，集成 delta 和现代工具
    #>
    $tools = Test-GitToolsAvailability
    
    if (-not $tools.Git) {
        Write-Error "Git 不可用"
        return
    }
    
    Write-Host "⚙️  配置 Git 集成..." -ForegroundColor Cyan
    
    # Delta 配置
    if ($tools.Delta) {
        Write-Host "🔧 配置 Delta 差异查看器" -ForegroundColor Green
        git config --global core.pager delta
        git config --global interactive.diffFilter "delta --color-only"
        git config --global delta.navigate true
        git config --global delta.side-by-side true
        git config --global delta.line-numbers true
        git config --global delta.syntax-theme "Monokai Extended"
        git config --global merge.conflictstyle diff3
        git config --global diff.colorMoved default
    }
    
    # 现代 Git 配置
    git config --global init.defaultBranch main
    git config --global push.default simple
    git config --global pull.rebase false
    git config --global core.autocrlf input
    git config --global core.editor "code --wait"
    
    # Git 别名
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.visual "!gitk"
    git config --global alias.tree "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    
    Write-Host "✅ Git 配置完成" -ForegroundColor Green
}

# Lazygit 集成
function Start-LazyGit {
    <#
    .SYNOPSIS
    启动 Lazygit
    .PARAMETER Path
    Git 仓库路径，默认当前目录
    #>
    param(
        [string]$Path = "."
    )
    
    $tools = Test-GitToolsAvailability
    if (-not $tools.Lazygit) {
        Write-Warning "Lazygit 不可用，使用标准 git status"
        git status
        return
    }
    
    try {
        Push-Location $Path
        Write-Host "🚀 启动 Lazygit..." -ForegroundColor Blue
        & lazygit
    }
    catch {
        Write-Error "启动 Lazygit 失败: $_"
    }
    finally {
        Pop-Location
    }
}

function Start-LazyGitWith {
    <#
    .SYNOPSIS
    在指定 Git 目录启动 Lazygit
    .PARAMETER GitDir
    .git 目录路径
    .PARAMETER WorkTree
    工作树路径
    #>
    param(
        [Parameter(Mandatory)]
        [string]$GitDir,
        [string]$WorkTree = "."
    )
    
    $tools = Test-GitToolsAvailability
    if (-not $tools.Lazygit) {
        Write-Error "Lazygit 不可用"
        return
    }
    
    try {
        $env:GIT_DIR = $GitDir
        $env:GIT_WORK_TREE = $WorkTree
        Write-Host "🚀 启动 Lazygit (Git Dir: $GitDir)" -ForegroundColor Blue
        & lazygit
    }
    catch {
        Write-Error "启动 Lazygit 失败: $_"
    }
    finally {
        Remove-Item env:GIT_DIR -ErrorAction SilentlyContinue
        Remove-Item env:GIT_WORK_TREE -ErrorAction SilentlyContinue
    }
}

# GitHub CLI 集成
function New-PullRequest {
    <#
    .SYNOPSIS
    创建 Pull Request
    .PARAMETER Title
    PR 标题
    .PARAMETER Body
    PR 描述
    .PARAMETER Draft
    创建草稿 PR
    .PARAMETER Base
    目标分支
    #>
    param(
        [string]$Title,
        [string]$Body,
        [switch]$Draft,
        [string]$Base = "main"
    )
    
    $tools = Test-GitToolsAvailability
    if (-not $tools.GitHubCLI) {
        Write-Error "GitHub CLI 不可用"
        return
    }
    
    try {
        $ghArgs = @("pr", "create")
        
        if ($Title) {
            $ghArgs += "--title", $Title
        } else {
            $ghArgs += "--fill"
        }
        
        if ($Body) {
            $ghArgs += "--body", $Body
        }
        
        if ($Draft) {
            $ghArgs += "--draft"
        }
        
        if ($Base -ne "main") {
            $ghArgs += "--base", $Base
        }
        
        Write-Host "📝 创建 Pull Request..." -ForegroundColor Blue
        & gh @ghArgs
    }
    catch {
        Write-Error "创建 PR 失败: $_"
    }
}

function Get-PullRequests {
    <#
    .SYNOPSIS
    列出 Pull Requests
    .PARAMETER State
    PR 状态
    .PARAMETER Interactive
    使用 fzf 交互式选择
    #>
    param(
        [ValidateSet("open", "closed", "merged", "all")]
        [string]$State = "open",
        [switch]$Interactive
    )
    
    $tools = Test-GitToolsAvailability
    if (-not $tools.GitHubCLI) {
        Write-Error "GitHub CLI 不可用"
        return
    }
    
    try {
        if ($Interactive -and $tools.Fzf) {
            & gh pr list --state $State | fzf --preview 'gh pr view {1}' --header 'Select PR to view'
        } else {
            & gh pr list --state $State
        }
    }
    catch {
        Write-Error "获取 PR 列表失败: $_"
    }
}

function New-Issue {
    <#
    .SYNOPSIS
    创建 GitHub Issue
    .PARAMETER Title
    Issue 标题
    .PARAMETER Body
    Issue 描述
    .PARAMETER Label
    标签
    #>
    param(
        [string]$Title,
        [string]$Body,
        [string[]]$Label
    )
    
    $tools = Test-GitToolsAvailability
    if (-not $tools.GitHubCLI) {
        Write-Error "GitHub CLI 不可用"
        return
    }
    
    try {
        $ghArgs = @("issue", "create")
        
        if ($Title) {
            $ghArgs += "--title", $Title
        } else {
            $ghArgs += "--fill"
        }
        
        if ($Body) {
            $ghArgs += "--body", $Body
        }
        
        if ($Label) {
            foreach ($l in $Label) {
                $ghArgs += "--label", $l
            }
        }
        
        Write-Host "🐛 创建 Issue..." -ForegroundColor Blue
        & gh @ghArgs
    }
    catch {
        Write-Error "创建 Issue 失败: $_"
    }
}

# Git 高级操作
function Get-GitBranches {
    <#
    .SYNOPSIS
    交互式分支选择
    .PARAMETER Remote
    包含远程分支
    #>
    param(
        [switch]$Remote
    )
    
    $tools = Test-GitToolsAvailability
    if (-not $tools.Git) {
        Write-Error "Git 不可用"
        return
    }
    
    try {
        if ($tools.Fzf) {
            if ($Remote) {
                git branch -a | fzf --preview 'git log --oneline --graph --color=always {1}' | ForEach-Object { $_.Trim() -replace '^\*\s*', '' -replace '^remotes/', '' }
            } else {
                git branch | fzf --preview 'git log --oneline --graph --color=always {1}' | ForEach-Object { $_.Trim() -replace '^\*\s*', '' }
            }
        } else {
            if ($Remote) {
                git branch -a
            } else {
                git branch
            }
        }
    }
    catch {
        Write-Error "获取分支列表失败: $_"
    }
}

function Switch-GitBranch {
    <#
    .SYNOPSIS
    交互式切换分支
    .PARAMETER Branch
    分支名，如果不提供则交互式选择
    #>
    param(
        [string]$Branch
    )
    
    if ([string]::IsNullOrEmpty($Branch)) {
        $Branch = Get-GitBranches
    }
    
    if (-not [string]::IsNullOrEmpty($Branch)) {
        try {
            Write-Host "🔄 切换到分支: $Branch" -ForegroundColor Blue
            git checkout $Branch
        }
        catch {
            Write-Error "切换分支失败: $_"
        }
    }
}

function Get-GitLog {
    <#
    .SYNOPSIS
    交互式查看 Git 日志
    .PARAMETER Count
    显示的提交数量
    .PARAMETER Oneline
    单行显示
    #>
    param(
        [int]$Count = 20,
        [switch]$Oneline
    )
    
    $tools = Test-GitToolsAvailability
    if (-not $tools.Git) {
        Write-Error "Git 不可用"
        return
    }
    
    try {
        if ($tools.Fzf) {
            if ($Oneline) {
                git log --oneline -n $Count | fzf --preview 'git show --color=always {1}'
            } else {
                git log --color=always --format="%C(cyan)%h %C(blue)%ar%C(auto)%d %C(yellow)%s%+b %C(black)%ae" -n $Count | fzf --ansi --preview 'git show --color=always {1}'
            }
        } else {
            if ($Oneline) {
                git log --oneline -n $Count
            } else {
                git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -n $Count
            }
        }
    }
    catch {
        Write-Error "查看日志失败: $_"
    }
}

function Get-GitStatus {
    <#
    .SYNOPSIS
    增强的 Git 状态显示
    .PARAMETER Short
    简短显示
    #>
    param(
        [switch]$Short
    )
    
    $tools = Test-GitToolsAvailability
    if (-not $tools.Git) {
        Write-Error "Git 不可用"
        return
    }
    
    try {
        Write-Host "📊 Git 仓库状态" -ForegroundColor Cyan
        Write-Host "=" * 30
        
        if ($Short) {
            git status --short
        } else {
            git status
        }
        
        # 显示最近提交
        Write-Host "`n📝 最近提交:" -ForegroundColor Green
        git log --oneline -5
        
        # 显示分支信息
        Write-Host "`n🌿 分支信息:" -ForegroundColor Green
        $currentBranch = git rev-parse --abbrev-ref HEAD
        $upstream = git rev-parse --abbrev-ref "@{upstream}" 2>$null
        
        Write-Host "   当前分支: $currentBranch"
        if ($upstream) {
            Write-Host "   上游分支: $upstream"
            
            $ahead = git rev-list --count "$upstream..HEAD" 2>$null
            $behind = git rev-list --count "HEAD..$upstream" 2>$null
            
            if ($ahead -gt 0) {
                Write-Host "   领先: $ahead 个提交" -ForegroundColor Yellow
            }
            if ($behind -gt 0) {
                Write-Host "   落后: $behind 个提交" -ForegroundColor Red
            }
            if ($ahead -eq 0 -and $behind -eq 0) {
                Write-Host "   与上游同步 ✅" -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Error "获取状态失败: $_"
    }
}

function Invoke-GitCleanup {
    <#
    .SYNOPSIS
    Git 仓库清理
    .PARAMETER DryRun
    试运行，不实际删除
    #>
    param(
        [switch]$DryRun
    )
    
    $tools = Test-GitToolsAvailability
    if (-not $tools.Git) {
        Write-Error "Git 不可用"
        return
    }
    
    Write-Host "🧹 Git 仓库清理" -ForegroundColor Cyan
    
    try {
        # 清理已合并的分支
        Write-Host "`n🗂️  检查已合并的分支..." -ForegroundColor Blue
        $mergedBranches = git branch --merged | Where-Object { $_ -notmatch "main|master|\*" } | ForEach-Object { $_.Trim() }
        
        if ($mergedBranches.Count -gt 0) {
            Write-Host "发现已合并的分支:"
            $mergedBranches | ForEach-Object { Write-Host "   - $_" -ForegroundColor Yellow }
            
            if (-not $DryRun) {
                $confirm = Read-Host "是否删除这些分支? (y/N)"
                if ($confirm -eq 'y' -or $confirm -eq 'Y') {
                    $mergedBranches | ForEach-Object {
                        git branch -d $_
                        Write-Host "✅ 已删除分支: $_" -ForegroundColor Green
                    }
                }
            }
        } else {
            Write-Host "✅ 没有已合并的本地分支需要清理" -ForegroundColor Green
        }
        
        # 清理远程追踪分支
        Write-Host "`n🌐 清理远程追踪分支..." -ForegroundColor Blue
        if (-not $DryRun) {
            git remote prune origin
        } else {
            git remote prune origin --dry-run
        }
        
        # 垃圾回收
        Write-Host "`n🗑️  执行垃圾回收..." -ForegroundColor Blue
        if (-not $DryRun) {
            git gc --auto
        } else {
            Write-Host "   (试运行模式，跳过垃圾回收)"
        }
        
        Write-Host "`n🎉 清理完成" -ForegroundColor Green
    }
    catch {
        Write-Error "清理失败: $_"
    }
}

# Git 别名和快捷函数
function lg { Start-LazyGit @args }
function lgs { Start-LazyGitWith @args }
function pr-create { New-PullRequest @args }
function pr-list { Get-PullRequests @args }
function issue-create { New-Issue @args }
function gco { Switch-GitBranch @args }
function gst { Get-GitStatus @args }
function glog { Get-GitLog @args }
function gbr { Get-GitBranches @args }
function gclean { Invoke-GitCleanup @args }

# Git 工作流函数
function Start-GitWorkflow {
    <#
    .SYNOPSIS
    开始新的 Git 工作流
    .PARAMETER Type
    工作流类型: feature, bugfix, hotfix
    .PARAMETER Name
    分支名称
    #>
    param(
        [ValidateSet("feature", "bugfix", "hotfix")]
        [string]$Type = "feature",
        [Parameter(Mandatory)]
        [string]$Name
    )
    
    $branchName = "$Type/$Name"
    
    try {
        Write-Host "🚀 开始新工作流: $branchName" -ForegroundColor Blue
        
        # 确保在主分支
        git checkout main
        git pull origin main
        
        # 创建新分支
        git checkout -b $branchName
        
        Write-Host "✅ 工作流已开始，当前分支: $branchName" -ForegroundColor Green
        Write-Host "💡 使用 'lg' 打开 Lazygit 管理代码" -ForegroundColor Yellow
    }
    catch {
        Write-Error "启动工作流失败: $_"
    }
}

# 模块初始化
$tools = Test-GitToolsAvailability

Write-Host "🌿 Git 工具链状态:" -ForegroundColor Cyan
Write-Host "   Git: $(if($tools.Git) { '✅' } else { '❌' })"
Write-Host "   Lazygit: $(if($tools.Lazygit) { '✅' } else { '❌' })"
Write-Host "   Delta: $(if($tools.Delta) { '✅' } else { '❌' })"
Write-Host "   GitHub CLI: $(if($tools.GitHubCLI) { '✅' } else { '❌' })"
Write-Host "   Fzf: $(if($tools.Fzf) { '✅' } else { '❌' })"

if ($tools.Git -and $tools.Lazygit -and $tools.Delta -and $tools.GitHubCLI) {
    Write-Host "🎉 完整 Git 工具链已就绪" -ForegroundColor Green
    
    # 自动配置 Git（如果尚未配置）
    $deltaConfigured = git config --global core.pager
    if (-not $deltaConfigured -and $tools.Delta) {
        $autoConfig = Read-Host "是否自动配置 Git + Delta 集成? (Y/n)"
        if ($autoConfig -ne 'n' -and $autoConfig -ne 'N') {
            Initialize-GitConfig
        }
    }
} else {
    Write-Host "⚠️  部分 Git 工具不可用，功能可能受限" -ForegroundColor Yellow
    Write-Host "   运行 'Install-DevEnvironment' 安装缺失工具" -ForegroundColor Blue
}

# Note: Functions and aliases are automatically available when dot-sourced