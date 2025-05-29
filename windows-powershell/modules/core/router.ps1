# Intelligent Command Routing and Tool Detection
# 智能命令路由系统，根据上下文自动选择最佳工具

# 全局工具状态缓存
$script:ToolCache = @{}
$script:ContextCache = @{}
$script:PerformanceLog = @()

function Get-ToolAvailability {
    <#
    .SYNOPSIS
    检查工具可用性并缓存结果
    .PARAMETER ToolName
    工具名称
    .PARAMETER Force
    强制重新检查
    #>
    param(
        [Parameter(Mandatory)]
        [string]$ToolName,
        [switch]$Force
    )
    
    if (-not $Force -and $script:ToolCache.ContainsKey($ToolName)) {
        return $script:ToolCache[$ToolName]
    }
    
    $available = $null -ne (Get-Command $ToolName -ErrorAction SilentlyContinue)
    $script:ToolCache[$ToolName] = $available
    
    return $available
}

function Get-ProjectContext {
    <#
    .SYNOPSIS
    分析当前目录的项目上下文
    .PARAMETER Path
    要分析的路径，默认当前目录
    #>
    param(
        [string]$Path = (Get-Location).Path
    )
    
    $cacheKey = $Path
    if ($script:ContextCache.ContainsKey($cacheKey)) {
        $cached = $script:ContextCache[$cacheKey]
        # 缓存5分钟
        if ((Get-Date) - $cached.Timestamp -lt [TimeSpan]::FromMinutes(5)) {
            return $cached.Context
        }
    }
    
    $context = @{
        Type = "Unknown"
        Language = @()
        Features = @()
        Tools = @()
        IsGitRepo = $false
        PackageFiles = @()
    }
    
    try {
        # 检查是否是 Git 仓库
        $gitDir = git rev-parse --git-dir 2>$null
        if ($LASTEXITCODE -eq 0) {
            $context.IsGitRepo = $true
            $context.Features += "Git"
        }
        
        # 检查项目类型和语言
        $files = Get-ChildItem -Path $Path -File | Select-Object -ExpandProperty Name
        
        # JavaScript/TypeScript 项目
        if ($files -contains "package.json") {
            $context.Type = "JavaScript"
            $context.Language += "JavaScript"
            $context.PackageFiles += "package.json"
            $context.Tools += "npm", "yarn", "node"
            
            if ($files -match "\.ts$|tsconfig\.json") {
                $context.Language += "TypeScript"
                $context.Tools += "tsc"
            }
            
            if ($files -contains "yarn.lock") {
                $context.Features += "Yarn"
            }
            if ($files -contains "pnpm-lock.yaml") {
                $context.Features += "PNPM"
            }
        }
        
        # Python 项目
        if ($files -match "requirements\.txt|setup\.py|pyproject\.toml|Pipfile") {
            $context.Type = "Python"
            $context.Language += "Python"
            $context.Tools += "python", "pip"
            
            if ($files -contains "Pipfile") {
                $context.Features += "Pipenv"
                $context.Tools += "pipenv"
            }
            if ($files -contains "pyproject.toml") {
                $context.Features += "Poetry"
                $context.Tools += "poetry"
            }
            if ($files -contains "requirements.txt") {
                $context.PackageFiles += "requirements.txt"
            }
        }
        
        # Rust 项目
        if ($files -contains "Cargo.toml") {
            $context.Type = "Rust"
            $context.Language += "Rust"
            $context.PackageFiles += "Cargo.toml"
            $context.Tools += "cargo", "rustc"
        }
        
        # Go 项目
        if ($files -contains "go.mod") {
            $context.Type = "Go"
            $context.Language += "Go"
            $context.PackageFiles += "go.mod"
            $context.Tools += "go"
        }
        
        # .NET 项目
        if ($files -match "\.csproj$|\.sln$|\.fsproj$|\.vbproj$") {
            $context.Type = "DotNet"
            $context.Language += "C#"
            $context.Tools += "dotnet"
        }
        
        # Java 项目
        if ($files -contains "pom.xml" -or $files -contains "build.gradle") {
            $context.Type = "Java"
            $context.Language += "Java"
            
            if ($files -contains "pom.xml") {
                $context.Features += "Maven"
                $context.Tools += "mvn"
            }
            if ($files -contains "build.gradle") {
                $context.Features += "Gradle"
                $context.Tools += "gradle"
            }
        }
        
        # Docker 项目
        if ($files -contains "Dockerfile" -or $files -contains "docker-compose.yml") {
            $context.Features += "Docker"
            $context.Tools += "docker"
            
            if ($files -contains "docker-compose.yml") {
                $context.Features += "DockerCompose"
                $context.Tools += "docker-compose"
            }
        }
        
        # Kubernetes
        if ($files -match "\.yaml$|\.yml$" -and ($files | Where-Object { (Get-Content (Join-Path $Path $_) -Raw -ErrorAction SilentlyContinue) -match "apiVersion|kind:" })) {
            $context.Features += "Kubernetes"
            $context.Tools += "kubectl"
        }
        
        # 缓存结果
        $script:ContextCache[$cacheKey] = @{
            Context = $context
            Timestamp = Get-Date
        }
        
        return $context
    }
    catch {
        Write-Warning "分析项目上下文失败: $_"
        return $context
    }
}

function Invoke-SmartCommand {
    <#
    .SYNOPSIS
    智能命令路由，根据上下文选择最佳工具
    .PARAMETER Command
    基础命令
    .PARAMETER Arguments
    命令参数
    .PARAMETER PreferModern
    优先使用现代工具
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Command,
        [string[]]$Arguments = @(),
        [switch]$PreferModern
    )
    
    $startTime = Get-Date
    $context = Get-ProjectContext
    
    try {
        switch ($Command.ToLower()) {
            "ls" {
                if ($PreferModern -and (Get-ToolAvailability "eza")) {
                    & eza --icons --group-directories-first @Arguments
                } elseif (Get-ToolAvailability "eza") {
                    & eza @Arguments
                } else {
                    Get-ChildItem @Arguments
                }
            }
            
            "find" {
                if ($PreferModern -and (Get-ToolAvailability "fd")) {
                    & fd @Arguments
                } elseif (Get-ToolAvailability "rg") {
                    & rg --files @Arguments
                } else {
                    Get-ChildItem -Recurse @Arguments
                }
            }
            
            "grep" {
                if ($PreferModern -and (Get-ToolAvailability "rg")) {
                    & rg @Arguments
                } else {
                    Select-String @Arguments
                }
            }
            
            "cat" {
                if ($PreferModern -and (Get-ToolAvailability "bat")) {
                    & bat @Arguments
                } else {
                    Get-Content @Arguments
                }
            }
            
            "git" {
                # Git 上下文感知
                if ($context.IsGitRepo) {
                    if ($Arguments[0] -eq "log" -and (Get-ToolAvailability "fzf")) {
                        # 使用交互式日志查看
                        git log --oneline | fzf --preview 'git show --color=always {1}'
                    } elseif ($Arguments[0] -eq "status" -and (Get-ToolAvailability "lazygit")) {
                        # 提示使用 lazygit
                        Write-Host "💡 使用 'lg' 启动 Lazygit 获得更好体验" -ForegroundColor Yellow
                        & git @Arguments
                    } else {
                        & git @Arguments
                    }
                } else {
                    Write-Warning "当前目录不是 Git 仓库"
                }
            }
            
            "run" {
                # 项目上下文感知的运行命令
                switch ($context.Type) {
                    "JavaScript" {
                        if ($Arguments[0] -and (Get-ToolAvailability "npm")) {
                            & npm run @Arguments
                        } else {
                            Write-Host "📦 可用的 npm scripts:" -ForegroundColor Blue
                            $packageJson = Get-Content "package.json" | ConvertFrom-Json
                            if ($packageJson.scripts) {
                                $packageJson.scripts | Format-Table
                            }
                        }
                    }
                    "Python" {
                        if ($context.Features -contains "Poetry" -and (Get-ToolAvailability "poetry")) {
                            & poetry run @Arguments
                        } elseif ($context.Features -contains "Pipenv" -and (Get-ToolAvailability "pipenv")) {
                            & pipenv run @Arguments
                        } else {
                            & python @Arguments
                        }
                    }
                    "Rust" {
                        & cargo run @Arguments
                    }
                    "Go" {
                        & go run @Arguments
                    }
                    "DotNet" {
                        & dotnet run @Arguments
                    }
                    default {
                        Write-Warning "无法确定项目类型，请指定具体命令"
                    }
                }
            }
            
            "test" {
                # 项目上下文感知的测试命令
                switch ($context.Type) {
                    "JavaScript" {
                        & npm test @Arguments
                    }
                    "Python" {
                        if ($context.Features -contains "Poetry") {
                            & poetry run pytest @Arguments
                        } elseif (Get-ToolAvailability "pytest") {
                            & pytest @Arguments
                        } else {
                            & python -m unittest @Arguments
                        }
                    }
                    "Rust" {
                        & cargo test @Arguments
                    }
                    "Go" {
                        & go test @Arguments
                    }
                    "DotNet" {
                        & dotnet test @Arguments
                    }
                    default {
                        Write-Warning "无法确定测试命令，请指定具体测试框架"
                    }
                }
            }
            
            "build" {
                # 项目上下文感知的构建命令
                switch ($context.Type) {
                    "JavaScript" {
                        & npm run build @Arguments
                    }
                    "Python" {
                        if ($context.Features -contains "Poetry") {
                            & poetry build @Arguments
                        } else {
                            & python setup.py build @Arguments
                        }
                    }
                    "Rust" {
                        & cargo build @Arguments
                    }
                    "Go" {
                        & go build @Arguments
                    }
                    "DotNet" {
                        & dotnet build @Arguments
                    }
                    default {
                        Write-Warning "无法确定构建命令，请指定具体构建工具"
                    }
                }
            }
            
            default {
                # 尝试直接执行命令
                if (Get-ToolAvailability $Command) {
                    & $Command @Arguments
                } else {
                    Write-Error "命令 '$Command' 不可用"
                }
            }
        }
        
        # 记录性能
        $duration = (Get-Date) - $startTime
        $script:PerformanceLog += @{
            Command = $Command
            Arguments = $Arguments -join ' '
            Duration = $duration.TotalMilliseconds
            Context = $context.Type
            Timestamp = Get-Date
        }
        
    }
    catch {
        Write-Error "执行命令失败: $_"
    }
}

function Get-SmartSuggestions {
    <#
    .SYNOPSIS
    根据上下文提供智能建议
    #>
    $context = Get-ProjectContext
    
    Write-Host "💡 智能建议 (基于当前上下文)" -ForegroundColor Cyan
    Write-Host "=" * 40
    
    Write-Host "`n📁 项目类型: $($context.Type)" -ForegroundColor Green
    
    if ($context.Language.Count -gt 0) {
        Write-Host "🔤 语言: $($context.Language -join ', ')" -ForegroundColor Blue
    }
    
    if ($context.Features.Count -gt 0) {
        Write-Host "⚡ 功能: $($context.Features -join ', ')" -ForegroundColor Yellow
    }
    
    # 根据项目类型提供建议
    Write-Host "`n🚀 推荐命令:" -ForegroundColor Magenta
    
    switch ($context.Type) {
        "JavaScript" {
            Write-Host "   npm install          # 安装依赖"
            Write-Host "   npm run dev          # 开发服务器"
            Write-Host "   npm run build        # 构建项目"
            Write-Host "   npm test             # 运行测试"
        }
        "Python" {
            if ($context.Features -contains "Poetry") {
                Write-Host "   poetry install       # 安装依赖"
                Write-Host "   poetry run python    # 运行 Python"
                Write-Host "   poetry run pytest    # 运行测试"
            } else {
                Write-Host "   pip install -r requirements.txt  # 安装依赖"
                Write-Host "   python main.py       # 运行主程序"
                Write-Host "   pytest               # 运行测试"
            }
        }
        "Rust" {
            Write-Host "   cargo build          # 构建项目"
            Write-Host "   cargo run            # 运行项目"
            Write-Host "   cargo test           # 运行测试"
            Write-Host "   cargo check          # 快速检查"
        }
        "Go" {
            Write-Host "   go mod tidy          # 整理依赖"
            Write-Host "   go run main.go       # 运行主程序"
            Write-Host "   go test ./...        # 运行测试"
            Write-Host "   go build             # 构建项目"
        }
    }
    
    if ($context.IsGitRepo) {
        Write-Host "`n🌿 Git 操作:"
        Write-Host "   lg                   # 启动 Lazygit"
        Write-Host "   gst                  # Git 状态"
        Write-Host "   glog                 # 交互式日志"
    }
    
    # 可用的现代工具
    Write-Host "`n🔧 可用的现代工具:" -ForegroundColor Cyan
    $modernTools = @{
        "eza" = "增强的 ls"
        "fd" = "快速文件查找"
        "rg" = "快速内容搜索"
        "bat" = "语法高亮的 cat"
        "fzf" = "模糊查找"
        "lazygit" = "Git TUI"
        "delta" = "Git diff 增强"
        "zoxide" = "智能目录跳转"
    }
    
    foreach ($tool in $modernTools.Keys) {
        $status = if (Get-ToolAvailability $tool) { "✅" } else { "❌" }
        Write-Host "   $status $tool - $($modernTools[$tool])"
    }
}

function Get-CommandPerformance {
    <#
    .SYNOPSIS
    显示命令性能统计
    .PARAMETER Last
    显示最近N条记录
    #>
    param(
        [int]$Last = 10
    )
    
    if ($script:PerformanceLog.Count -eq 0) {
        Write-Host "暂无性能数据" -ForegroundColor Yellow
        return
    }
    
    Write-Host "⚡ 命令性能统计" -ForegroundColor Cyan
    Write-Host "=" * 50
    
    $recent = $script:PerformanceLog | Select-Object -Last $Last
    $recent | Format-Table @{
        Label = "命令"
        Expression = { "$($_.Command) $($_.Arguments)" }
        Width = 30
    }, @{
        Label = "耗时(ms)"
        Expression = { [math]::Round($_.Duration, 2) }
        Width = 10
    }, @{
        Label = "上下文"
        Expression = { $_.Context }
        Width = 15
    }, @{
        Label = "时间"
        Expression = { $_.Timestamp.ToString("HH:mm:ss") }
        Width = 10
    } -AutoSize
    
    # 平均性能
    $avgDuration = ($recent | Measure-Object -Property Duration -Average).Average
    Write-Host "`n📊 平均响应时间: $([math]::Round($avgDuration, 2))ms" -ForegroundColor Green
}

function Clear-CommandCache {
    <#
    .SYNOPSIS
    清除缓存
    #>
    $script:ToolCache = @{}
    $script:ContextCache = @{}
    $script:PerformanceLog = @()
    Write-Host "✅ 缓存已清除" -ForegroundColor Green
}

# 智能别名
function smart-ls { Invoke-SmartCommand "ls" -Arguments $args -PreferModern }
function smart-find { Invoke-SmartCommand "find" -Arguments $args -PreferModern }
function smart-grep { Invoke-SmartCommand "grep" -Arguments $args -PreferModern }
function smart-cat { Invoke-SmartCommand "cat" -Arguments $args -PreferModern }
function smart-run { Invoke-SmartCommand "run" -Arguments $args }
function smart-test { Invoke-SmartCommand "test" -Arguments $args }
function smart-build { Invoke-SmartCommand "build" -Arguments $args }

# 设置别名
Set-Alias -Name sls -Value smart-ls
Set-Alias -Name sfind -Value smart-find
Set-Alias -Name sgrep -Value smart-grep
Set-Alias -Name scat -Value smart-cat
Set-Alias -Name srun -Value smart-run
Set-Alias -Name stest -Value smart-test
Set-Alias -Name sbuild -Value smart-build
Set-Alias -Name suggest -Value Get-SmartSuggestions
Set-Alias -Name perf -Value Get-CommandPerformance

# 模块初始化
Write-Host "🧠 智能路由系统已加载" -ForegroundColor Green
Write-Host "   使用 'suggest' 获取上下文建议" -ForegroundColor Blue
Write-Host "   使用 's<command>' 智能执行命令" -ForegroundColor Blue

# Note: Functions and aliases are automatically available when dot-sourced