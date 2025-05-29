# Starship 提示符配置和管理
# 现代化、快速、可定制的跨 shell 提示符

# 检查 Starship 是否已安装
function Test-StarshipInstalled {
    return [bool](Get-Command starship -ErrorAction SilentlyContinue)
}

# 安装 Starship
function Install-Starship {
    [CmdletBinding()]
    param(
        [switch]$Force
    )
    
    if (Test-StarshipInstalled -and !$Force) {
        Write-Host "✅ Starship 已安装" -ForegroundColor Green
        return $true
    }
    
    Write-Host "🚀 安装 Starship 提示符..." -ForegroundColor Cyan
    
    # 优先使用 Scoop 安装
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        try {
            scoop install starship
            if (Test-StarshipInstalled) {
                Write-Host "✅ Starship 通过 Scoop 安装成功!" -ForegroundColor Green
                return $true
            }
        } catch {
            Write-Host "⚠️  Scoop 安装失败，尝试其他方法..." -ForegroundColor Yellow
        }
    }
    
    # 使用官方安装脚本
    try {
        if ($script:IsWindows) {
            Invoke-Expression (& { (Invoke-WebRequest -Uri "https://starship.rs/install.ps1").Content })
        } else {
            # Unix-like 系统
            Invoke-Expression (& { (Invoke-WebRequest -Uri "https://starship.rs/install.sh").Content })
        }
        
        if (Test-StarshipInstalled) {
            Write-Host "✅ Starship 安装成功!" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "❌ Starship 安装失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 创建默认配置文件
function New-StarshipConfig {
    [CmdletBinding()]
    param(
        [ValidateSet('Minimal', 'Developer', 'Poweruser', 'Custom')]
        [string]$Template = 'Developer',
        [string]$ConfigPath = "",
        [switch]$Force
    )
    
    # 确定配置文件路径
    if (!$ConfigPath) {
        $ConfigPath = if ($script:IsWindows) {
            "$env:USERPROFILE\.config\starship.toml"
        } else {
            "$env:HOME/.config/starship.toml"
        }
    }
    
    # 检查配置文件是否已存在
    if ((Test-Path $ConfigPath) -and !$Force) {
        Write-Host "⚠️  配置文件已存在: $ConfigPath" -ForegroundColor Yellow
        Write-Host "使用 -Force 参数覆盖现有配置" -ForegroundColor Yellow
        return $false
    }
    
    # 确保配置目录存在
    $configDir = Split-Path $ConfigPath -Parent
    if (!(Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
    
    Write-Host "📝 创建 Starship 配置: $Template" -ForegroundColor Cyan
    
    $config = switch ($Template) {
        'Minimal' {
            @'
# Starship 最小配置
format = """
$character"""

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"
'@
        }
        
        'Developer' {
            @'
# Starship 开发者配置
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_state\
$git_status\
$git_metrics\
$fill\
$nodejs\
$python\
$rust\
$golang\
$java\
$dotnet\
$docker_context\
$cmd_duration\
$line_break\
$character"""

[fill]
symbol = " "

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"

[directory]
style = "blue bold"
read_only = " 🔒"
truncation_length = 3
truncate_to_repo = true
format = "[$path]($style)[$read_only]($read_only_style) "

[git_branch]
symbol = "🌱 "
format = "[$symbol$branch]($style) "
style = "bright-green"

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
style = "cyan"

[git_state]
format = '[\($state( $progress_current of $progress_total)\)]($style) '
cherry_pick = "[🍒 PICKING](bold red)"

[git_metrics]
added_style = "bold blue"
format = '[+$added]($added_style)/[-$deleted]($deleted_style) '

[nodejs]
symbol = "⬢ "
format = "[$symbol($version )]($style)"

[python]
symbol = "🐍 "
format = '[${symbol}${pyenv_prefix}(${version} )(\($virtualenv\) )]($style)'

[rust]
symbol = "🦀 "
format = "[$symbol($version )]($style)"

[golang]
symbol = "🐹 "
format = "[$symbol($version )]($style)"

[java]
symbol = "☕ "
format = "[$symbol($version )]($style)"

[dotnet]
symbol = "🔷 "
format = "[$symbol($version )]($style)"

[docker_context]
symbol = "🐳 "
format = "[$symbol$context]($style) "

[cmd_duration]
min_time = 2_000
format = "took [$duration](bold yellow) "

[memory_usage]
disabled = false
threshold = 70
symbol = "🐏 "
format = "$symbol[${ram_pct}]($style) "

[username]
style_user = "yellow bold"
style_root = "red bold"
format = "[$user]($style) "
disabled = false
show_always = true

[hostname]
ssh_only = false
format = "on [$hostname](bold red) "
disabled = false

[time]
disabled = false
format = '🕙[\[ $time \]]($style) '
time_format = "%T"
utc_time_offset = "local"
'@
        }
        
        'Poweruser' {
            @'
# Starship 高级用户配置
format = """
$os\
$username\
$hostname\
$shlvl\
$kubernetes\
$directory\
$vcsh\
$git_branch\
$git_commit\
$git_state\
$git_metrics\
$git_status\
$hg_branch\
$docker_context\
$package\
$cmake\
$dart\
$deno\
$dotnet\
$elixir\
$elm\
$erlang\
$golang\
$helm\
$java\
$julia\
$kotlin\
$lua\
$nim\
$nodejs\
$ocaml\
$perl\
$php\
$pulumi\
$purescript\
$python\
$ruby\
$rust\
$scala\
$swift\
$terraform\
$vlang\
$vagrant\
$zig\
$nix_shell\
$conda\
$memory_usage\
$aws\
$gcloud\
$openstack\
$azure\
$env_var\
$crystal\
$custom\
$sudo\
$cmd_duration\
$line_break\
$jobs\
$battery\
$time\
$status\
$shell\
$character"""

[os]
disabled = false
style = "bg:blue"

[os.symbols]
Windows = " "
Ubuntu = " "
Macos = " "

[character]
success_symbol = "[❯](purple)"
error_symbol = "[❯](red)"
vicmd_symbol = "[❮](green)"

[directory]
style = "fg:cyan"
read_only = " 󰌾"
truncation_length = 4
truncate_to_repo = true

[git_branch]
symbol = " "
format = "[$symbol$branch]($style) "
style = "bright-green"

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
style = "cyan"

[nodejs]
symbol = " "
format = "[$symbol($version )]($style)"

[python]
symbol = " "
format = '[${symbol}${pyenv_prefix}(${version} )(\($virtualenv\) )]($style)'

[rust]
symbol = " "
format = "[$symbol($version )]($style)"

[golang]
symbol = " "
format = "[$symbol($version )]($style)"

[java]
symbol = " "
format = "[$symbol($version )]($style)"

[kotlin]
symbol = " "
format = "[$symbol($version )]($style)"

[docker_context]
symbol = " "
format = "[$symbol$context]($style) "

[cmd_duration]
min_time = 500
format = " took [$duration](bold yellow)"

[memory_usage]
disabled = false
threshold = 70
symbol = "󰍛 "

[battery]
full_symbol = " "
charging_symbol = " "
discharging_symbol = " "

[[battery.display]]
threshold = 10
style = "bold red"

[time]
disabled = false
format = "🕙 $time"
time_format = "%R"
'@
        }
        
        'Custom' {
            @'
# Starship 自定义配置模板
# 请根据需要自定义以下配置

format = """
$all\
$character"""

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"

# 在这里添加你的自定义配置
'@
        }
    }
    
    try {
        $config | Out-File -FilePath $ConfigPath -Encoding UTF8
        Write-Host "✅ 配置文件已创建: $ConfigPath" -ForegroundColor Green
        
        # 设置环境变量
        $env:STARSHIP_CONFIG = $ConfigPath
        
        return $true
    } catch {
        Write-Host "❌ 配置文件创建失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 初始化 Starship
function Initialize-Starship {
    [CmdletBinding()]
    param(
        [string]$ConfigPath = ""
    )
    
    if (!(Test-StarshipInstalled)) {
        Write-Host "❌ Starship 未安装，请先运行 Install-Starship" -ForegroundColor Red
        return $false
    }
    
    # 设置配置文件路径
    if (!$ConfigPath) {
        $ConfigPath = if ($script:IsWindows) {
            "$env:USERPROFILE\.config\starship.toml"
        } else {
            "$env:HOME/.config/starship.toml"
        }
    }
    
    # 如果配置文件不存在，创建默认配置
    if (!(Test-Path $ConfigPath)) {
        Write-Host "📝 创建默认 Starship 配置..." -ForegroundColor Yellow
        New-StarshipConfig -Template Developer -ConfigPath $ConfigPath
    }
    
    # 设置环境变量
    $env:STARSHIP_CONFIG = $ConfigPath
    [Environment]::SetEnvironmentVariable('STARSHIP_CONFIG', $ConfigPath, 'User')
    
    try {
        # 初始化 Starship
        Invoke-Expression (& starship init powershell)
        Write-ProfileLog "Starship 初始化成功" -Level "DEBUG"
        return $true
    } catch {
        Write-Host "❌ Starship 初始化失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 显示 Starship 状态
function Get-StarshipStatus {
    Write-Host "⭐ Starship 状态" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    
    # 检查安装状态
    Write-Host "安装状态: " -NoNewline
    if (Test-StarshipInstalled) {
        Write-Host "✅ 已安装" -ForegroundColor Green
        
        try {
            $version = starship --version 2>$null
            Write-Host "版本: $version" -ForegroundColor Gray
        } catch {
            Write-Host "版本: 未知" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ 未安装" -ForegroundColor Red
        Write-Host "运行 Install-Starship 安装 Starship" -ForegroundColor Yellow
        return
    }
    
    # 配置文件状态
    $configPath = $env:STARSHIP_CONFIG
    if (!$configPath) {
        $configPath = if ($script:IsWindows) {
            "$env:USERPROFILE\.config\starship.toml"
        } else {
            "$env:HOME/.config/starship.toml"
        }
    }
    
    Write-Host "配置文件: " -NoNewline
    if (Test-Path $configPath) {
        Write-Host "✅ $configPath" -ForegroundColor Green
        
        try {
            $size = (Get-Item $configPath).Length
            $lastModified = (Get-Item $configPath).LastWriteTime
            Write-Host "  大小: $size 字节" -ForegroundColor Gray
            Write-Host "  修改时间: $lastModified" -ForegroundColor Gray
        } catch {
            Write-Host "  无法读取文件信息" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ 不存在" -ForegroundColor Red
        Write-Host "运行 New-StarshipConfig 创建配置文件" -ForegroundColor Yellow
    }
    
    # 环境变量
    Write-Host "环境变量: " -NoNewline
    if ($env:STARSHIP_CONFIG) {
        Write-Host "✅ STARSHIP_CONFIG=$env:STARSHIP_CONFIG" -ForegroundColor Green
    } else {
        Write-Host "⚠️  STARSHIP_CONFIG 未设置" -ForegroundColor Yellow
    }
}

# 测试 Starship 配置
function Test-StarshipConfig {
    [CmdletBinding()]
    param(
        [string]$ConfigPath = $env:STARSHIP_CONFIG
    )
    
    if (!$ConfigPath) {
        $ConfigPath = if ($script:IsWindows) {
            "$env:USERPROFILE\.config\starship.toml"
        } else {
            "$env:HOME/.config/starship.toml"
        }
    }
    
    if (!(Test-Path $ConfigPath)) {
        Write-Host "❌ 配置文件不存在: $ConfigPath" -ForegroundColor Red
        return $false
    }
    
    Write-Host "🧪 测试 Starship 配置..." -ForegroundColor Cyan
    
    try {
        # 验证配置文件语法
        $env:STARSHIP_CONFIG = $ConfigPath
        $result = starship config 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ 配置文件语法正确" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ 配置文件语法错误:" -ForegroundColor Red
            Write-Host $result -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ 配置测试失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 编辑 Starship 配置
function Edit-StarshipConfig {
    [CmdletBinding()]
    param(
        [string]$ConfigPath = $env:STARSHIP_CONFIG,
        [string]$Editor = $env:EDITOR
    )
    
    if (!$ConfigPath) {
        $ConfigPath = if ($script:IsWindows) {
            "$env:USERPROFILE\.config\starship.toml"
        } else {
            "$env:HOME/.config/starship.toml"
        }
    }
    
    if (!$Editor) {
        $Editor = if (Get-Command code -ErrorAction SilentlyContinue) { 'code' }
                  elseif (Get-Command nvim -ErrorAction SilentlyContinue) { 'nvim' }
                  elseif (Get-Command vim -ErrorAction SilentlyContinue) { 'vim' }
                  elseif (Get-Command notepad -ErrorAction SilentlyContinue) { 'notepad' }
                  else { $null }
    }
    
    if (!$Editor) {
        Write-Host "❌ 未找到可用的编辑器" -ForegroundColor Red
        return
    }
    
    if (!(Test-Path $ConfigPath)) {
        Write-Host "📝 配置文件不存在，创建新配置..." -ForegroundColor Yellow
        New-StarshipConfig -ConfigPath $ConfigPath
    }
    
    Write-Host "📝 使用 $Editor 编辑配置文件..." -ForegroundColor Cyan
    & $Editor $ConfigPath
}

# 重新加载 Starship 配置
function Reload-StarshipConfig {
    Write-Host "🔄 重新加载 Starship 配置..." -ForegroundColor Cyan
    
    try {
        # 重新初始化 Starship
        Initialize-Starship
        Write-Host "✅ Starship 配置重新加载完成" -ForegroundColor Green
    } catch {
        Write-Host "❌ 重新加载失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 显示可用的配置模板
function Show-StarshipTemplates {
    Write-Host "📋 可用的 Starship 配置模板:" -ForegroundColor Cyan
    Write-Host ""
    
    $templates = @(
        @{Name="Minimal"; Description="最简配置，只显示必要信息"},
        @{Name="Developer"; Description="开发者配置，显示语言和版本信息"},
        @{Name="Poweruser"; Description="高级用户配置，显示所有可用信息"},
        @{Name="Custom"; Description="自定义模板，提供基础结构"}
    )
    
    $templates | ForEach-Object {
        Write-Host "  $($_.Name)" -ForegroundColor Yellow -NoNewline
        Write-Host " - $($_.Description)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "使用方法: New-StarshipConfig -Template <模板名>" -ForegroundColor Cyan
}

# 设置别名
Set-Alias -Name starship-status -Value Get-StarshipStatus
Set-Alias -Name starship-config -Value Edit-StarshipConfig
Set-Alias -Name starship-test -Value Test-StarshipConfig
Set-Alias -Name starship-reload -Value Reload-StarshipConfig
Set-Alias -Name starship-templates -Value Show-StarshipTemplates

# 如果 Starship 已安装，自动初始化
if (Test-StarshipInstalled) {
    Initialize-Starship
}

Write-ProfileLog "Starship 模块加载完成" -Level "DEBUG"

# Note: Functions and aliases are automatically available when dot-sourced