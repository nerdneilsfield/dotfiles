# PowerShell 通用函数库
# 提供常用的实用函数

# === 文件和目录操作 ===

# 创建目录并进入
function mkcd {
    param([string]$Path)
    
    if (!(Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "创建目录: $Path" -ForegroundColor Green
    }
    Set-Location $Path
    Write-Host "进入目录: $PWD" -ForegroundColor Green
}

# 安全删除 - 确认后删除
function rm-safe {
    param(
        [string[]]$Path,
        [switch]$Recursive,
        [switch]$Force
    )
    
    foreach ($item in $Path) {
        if (!(Test-Path $item)) {
            Write-Host "路径不存在: $item" -ForegroundColor Yellow
            continue
        }
        
        $itemInfo = Get-Item $item
        $isDirectory = $itemInfo.PSIsContainer
        $itemType = if ($isDirectory) { "目录" } else { "文件" }
        
        if (!$Force) {
            $confirmation = Read-Host "确认删除${itemType}: $item? (y/N)"
            if ($confirmation -notmatch '^[Yy]') {
                Write-Host "跳过删除: $item" -ForegroundColor Yellow
                continue
            }
        }
        
        try {
            if ($isDirectory -and $Recursive) {
                Remove-Item $item -Recurse -Force
            } elseif (!$isDirectory) {
                Remove-Item $item -Force
            } else {
                Write-Host "目录删除需要 -Recursive 参数: $item" -ForegroundColor Red
                continue
            }
            Write-Host "已删除: $item" -ForegroundColor Green
        } catch {
            Write-Host "删除失败: $item - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# 复制并保持目录结构
function cp-tree {
    param(
        [string]$Source,
        [string]$Destination,
        [switch]$Force
    )
    
    if (!(Test-Path $Source)) {
        Write-Host "源路径不存在: $Source" -ForegroundColor Red
        return
    }
    
    try {
        if (Test-Path $Source -PathType Container) {
            Copy-Item $Source $Destination -Recurse -Force:$Force
        } else {
            Copy-Item $Source $Destination -Force:$Force
        }
        Write-Host "复制完成: $Source -> $Destination" -ForegroundColor Green
    } catch {
        Write-Host "复制失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 查找文件
function find-file {
    param(
        [string]$Name,
        [string]$Path = ".",
        [switch]$Exact
    )
    
    $pattern = if ($Exact) { $Name } else { "*$Name*" }
    
    Get-ChildItem -Path $Path -Recurse -File -Filter $pattern -ErrorAction SilentlyContinue |
        Select-Object FullName, Length, LastWriteTime |
        Format-Table -AutoSize
}

# 查找目录
function find-dir {
    param(
        [string]$Name,
        [string]$Path = ".",
        [switch]$Exact
    )
    
    $pattern = if ($Exact) { $Name } else { "*$Name*" }
    
    Get-ChildItem -Path $Path -Recurse -Directory -Filter $pattern -ErrorAction SilentlyContinue |
        Select-Object FullName, LastWriteTime |
        Format-Table -AutoSize
}

# === 文本处理 ===

# 统计文件行数、字数、字符数
function wc {
    param(
        [string[]]$Path,
        [switch]$Lines,
        [switch]$Words,
        [switch]$Characters
    )
    
    if (!$Path) {
        Write-Host "用法: wc [-Lines] [-Words] [-Characters] <文件路径...>"
        return
    }
    
    foreach ($file in $Path) {
        if (!(Test-Path $file)) {
            Write-Host "文件不存在: $file" -ForegroundColor Red
            continue
        }
        
        $content = Get-Content $file -Raw
        $lineCount = ($content -split "`n").Count
        $wordCount = ($content -split '\s+' | Where-Object { $_ }).Count
        $charCount = $content.Length
        
        if ($Lines) {
            Write-Host "$lineCount $file"
        } elseif ($Words) {
            Write-Host "$wordCount $file"
        } elseif ($Characters) {
            Write-Host "$charCount $file"
        } else {
            Write-Host "$lineCount $wordCount $charCount $file"
        }
    }
}

# 显示文件前几行
function head {
    param(
        [string]$Path,
        [int]$Lines = 10
    )
    
    if (!(Test-Path $Path)) {
        Write-Host "文件不存在: $Path" -ForegroundColor Red
        return
    }
    
    Get-Content $Path | Select-Object -First $Lines
}

# 显示文件后几行
function tail {
    param(
        [string]$Path,
        [int]$Lines = 10,
        [switch]$Follow
    )
    
    if (!(Test-Path $Path)) {
        Write-Host "文件不存在: $Path" -ForegroundColor Red
        return
    }
    
    if ($Follow) {
        Get-Content $Path -Tail $Lines -Wait
    } else {
        Get-Content $Path | Select-Object -Last $Lines
    }
}

# === 系统信息 ===

# 显示系统信息
function sysinfo {
    Write-Host "🖥️  系统信息" -ForegroundColor Cyan
    Write-Host "============" -ForegroundColor Cyan
    Write-Host ""
    
    # 操作系统信息
    if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) {
        $os = Get-CimInstance Win32_OperatingSystem
        Write-Host "操作系统: " -NoNewline -ForegroundColor Gray
        Write-Host "$($os.Caption) $($os.Version)" -ForegroundColor Green
        
        $computer = Get-CimInstance Win32_ComputerSystem
        Write-Host "计算机名: " -NoNewline -ForegroundColor Gray
        Write-Host $computer.Name -ForegroundColor Green
        
        Write-Host "用户名:   " -NoNewline -ForegroundColor Gray
        Write-Host $env:USERNAME -ForegroundColor Green
        
        # 内存信息
        $totalRAM = [math]::Round($computer.TotalPhysicalMemory / 1GB, 2)
        Write-Host "总内存:   " -NoNewline -ForegroundColor Gray
        Write-Host "${totalRAM}GB" -ForegroundColor Green
        
        # CPU 信息
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        Write-Host "处理器:   " -NoNewline -ForegroundColor Gray
        Write-Host $cpu.Name -ForegroundColor Green
    } else {
        Write-Host "操作系统: " -NoNewline -ForegroundColor Gray
        Write-Host "$($PSVersionTable.Platform)" -ForegroundColor Green
        
        Write-Host "用户名:   " -NoNewline -ForegroundColor Gray
        Write-Host $env:USER -ForegroundColor Green
    }
    
    # PowerShell 信息
    Write-Host ""
    Write-Host "PowerShell: " -NoNewline -ForegroundColor Gray
    Write-Host "$($PSVersionTable.PSVersion)" -ForegroundColor Green
    
    Write-Host "PowerShell Edition: " -NoNewline -ForegroundColor Gray
    Write-Host "$($PSVersionTable.PSEdition)" -ForegroundColor Green
    
    # 当前目录
    Write-Host "当前目录: " -NoNewline -ForegroundColor Gray
    Write-Host $PWD -ForegroundColor Green
    
    # 网络信息
    Write-Host ""
    Write-Host "🌐 网络接口:" -ForegroundColor Cyan
    if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) {
        Get-NetAdapter | Where-Object Status -eq "Up" | 
            Format-Table Name, InterfaceDescription, LinkSpeed -AutoSize
    } else {
        Write-Host "使用 ip addr 或 ifconfig 查看网络接口"
    }
}

# 获取公网 IP
function Get-PublicIP {
    try {
        $ip = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5).Trim()
        Write-Host "公网 IP: " -NoNewline -ForegroundColor Gray
        Write-Host $ip -ForegroundColor Green
        return $ip
    } catch {
        Write-Host "无法获取公网 IP: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# === 开发工具 ===

# JSON 格式化
function Format-Json {
    param(
        [Parameter(ValueFromPipeline)]
        [string]$InputObject,
        [string]$FilePath
    )
    
    if ($FilePath) {
        if (!(Test-Path $FilePath)) {
            Write-Host "文件不存在: $FilePath" -ForegroundColor Red
            return
        }
        $InputObject = Get-Content $FilePath -Raw
    }
    
    try {
        $json = $InputObject | ConvertFrom-Json
        $formatted = $json | ConvertTo-Json -Depth 100 -Compress:$false
        Write-Host $formatted -ForegroundColor Cyan
    } catch {
        Write-Host "JSON 格式错误: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 生成随机密码
function New-Password {
    param(
        [int]$Length = 12,
        [switch]$NoSymbols
    )
    
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    if (!$NoSymbols) {
        $chars += '!@#$%^&*()_+-=[]{}|;:,.<>?'
    }
    
    $password = -join ((1..$Length) | ForEach-Object { Get-Random -InputObject $chars.ToCharArray() })
    Write-Host "生成的密码: " -NoNewline -ForegroundColor Gray
    Write-Host $password -ForegroundColor Green
    
    # 复制到剪贴板 (Windows)
    if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) {
        try {
            $password | Set-Clipboard
            Write-Host "密码已复制到剪贴板" -ForegroundColor Yellow
        } catch {
            Write-Host "无法复制到剪贴板" -ForegroundColor Red
        }
    }
    
    return $password
}

# 计算文件或字符串的哈希值
function Get-Hash {
    param(
        [string]$InputObject,
        [string]$FilePath,
        [ValidateSet('MD5', 'SHA1', 'SHA256', 'SHA512')]
        [string]$Algorithm = 'SHA256'
    )
    
    if ($FilePath) {
        if (!(Test-Path $FilePath)) {
            Write-Host "文件不存在: $FilePath" -ForegroundColor Red
            return
        }
        $hash = Get-FileHash -Path $FilePath -Algorithm $Algorithm
        Write-Host "$Algorithm ($FilePath): " -NoNewline -ForegroundColor Gray
        Write-Host $hash.Hash.ToLower() -ForegroundColor Green
    } elseif ($InputObject) {
        $stream = [System.IO.MemoryStream]::new([System.Text.Encoding]::UTF8.GetBytes($InputObject))
        $hash = Get-FileHash -InputStream $stream -Algorithm $Algorithm
        Write-Host "$Algorithm (字符串): " -NoNewline -ForegroundColor Gray
        Write-Host $hash.Hash.ToLower() -ForegroundColor Green
    } else {
        Write-Host "请提供 -InputObject 或 -FilePath 参数" -ForegroundColor Red
    }
}

# === 实用工具 ===

# 倒计时器
function Start-Countdown {
    param(
        [int]$Seconds,
        [int]$Minutes = 0,
        [string]$Message = "倒计时结束!"
    )
    
    $totalSeconds = $Seconds + ($Minutes * 60)
    
    for ($i = $totalSeconds; $i -gt 0; $i--) {
        $mins = [math]::Floor($i / 60)
        $secs = $i % 60
        Write-Host "`r倒计时: ${mins}:${secs:D2}" -NoNewline -ForegroundColor Yellow
        Start-Sleep 1
    }
    
    Write-Host "`r$Message" -ForegroundColor Green
    if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) {
        [System.Console]::Beep()
    }
}

# 颜色测试
function Test-Colors {
    Write-Host "🎨 PowerShell 颜色测试:" -ForegroundColor Cyan
    Write-Host ""
    
    $colors = @('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 
                'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 
                'Magenta', 'Yellow', 'White')
    
    foreach ($color in $colors) {
        Write-Host "这是 $color 颜色的文本" -ForegroundColor $color
    }
}

# 快速编辑配置文件
function Edit-Profile {
    if ($env:EDITOR) {
        & $env:EDITOR $PROFILE
    } elseif (Get-Command code -ErrorAction SilentlyContinue) {
        code $PROFILE
    } elseif (Get-Command notepad -ErrorAction SilentlyContinue) {
        notepad $PROFILE
    } else {
        Write-Host "未找到合适的编辑器，请手动编辑: $PROFILE" -ForegroundColor Yellow
    }
}

# 重新加载配置文件
function Reload-Profile {
    Write-Host "重新加载 PowerShell 配置..." -ForegroundColor Cyan
    . $PROFILE
    Write-Host "配置重新加载完成!" -ForegroundColor Green
}

# 显示所有可用函数
function Get-PWShHelp {
    Write-Host "🔧 PowerShell 自定义函数帮助:" -ForegroundColor Cyan
    Write-Host ""
    
    $functions = @(
        @{Name="mkcd"; Description="创建目录并进入"},
        @{Name="rm-safe"; Description="安全删除(需确认)"},
        @{Name="cp-tree"; Description="复制目录树"},
        @{Name="find-file"; Description="查找文件"},
        @{Name="find-dir"; Description="查找目录"},
        @{Name="wc"; Description="统计文件行数/字数"},
        @{Name="head"; Description="显示文件前几行"},
        @{Name="tail"; Description="显示文件后几行"},
        @{Name="sysinfo"; Description="显示系统信息"},
        @{Name="Get-PublicIP"; Description="获取公网IP"},
        @{Name="Format-Json"; Description="格式化JSON"},
        @{Name="New-Password"; Description="生成随机密码"},
        @{Name="Get-Hash"; Description="计算哈希值"},
        @{Name="Start-Countdown"; Description="倒计时器"},
        @{Name="Test-Colors"; Description="颜色测试"},
        @{Name="Edit-Profile"; Description="编辑配置文件"},
        @{Name="Reload-Profile"; Description="重新加载配置"},
        @{Name="aliases"; Description="显示所有别名"}
    )
    
    $functions | Format-Table @(
        @{Name="函数名"; Expression="Name"; Width=20},
        @{Name="描述"; Expression="Description"}
    ) -AutoSize
    
    Write-Host ""
    Write-Host "💡 提示:" -ForegroundColor Yellow
    Write-Host "• 使用 Get-Help <函数名> -Detailed 查看详细帮助"
    Write-Host "• 使用 aliases 查看所有别名"
    Write-Host "• 使用 pwsh-tips 查看性能优化建议"
}

Write-ProfileLog "通用函数库加载完成" -Level "DEBUG"