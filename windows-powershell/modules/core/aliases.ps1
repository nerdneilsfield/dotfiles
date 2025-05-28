# PowerShell 别名定义
# 仿照 Unix/Linux 常用命令，提供 PowerShell 风格的实现

# === 基础文件操作别名 ===
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value Get-ChildItem
Set-Alias -Name ls -Value Get-ChildItem -Option AllScope
Set-Alias -Name grep -Value Select-String
Set-Alias -Name which -Value Get-Command
Set-Alias -Name touch -Value New-Item
Set-Alias -Name cat -Value Get-Content
Set-Alias -Name head -Value Select-Object
Set-Alias -Name tail -Value Select-Object

# === 增强版别名函数 ===

# ls 增强版 - 显示详细信息
function ll {
    param(
        [string]$Path = ".",
        [switch]$All,
        [switch]$Human
    )
    
    $items = Get-ChildItem -Path $Path -Force:$All
    
    if ($Human) {
        $items | Format-Table @(
            @{Name="Mode"; Expression={$_.Mode}; Width=10},
            @{Name="Length"; Expression={
                if ($_.PSIsContainer) { "<DIR>" }
                elseif ($_.Length -lt 1KB) { "$($_.Length)B" }
                elseif ($_.Length -lt 1MB) { "$([math]::Round($_.Length/1KB, 1))K" }
                elseif ($_.Length -lt 1GB) { "$([math]::Round($_.Length/1MB, 1))M" }
                else { "$([math]::Round($_.Length/1GB, 1))G" }
            }; Width=8; Alignment="Right"},
            @{Name="LastWriteTime"; Expression={$_.LastWriteTime.ToString("yyyy-MM-dd HH:mm")}; Width=16},
            @{Name="Name"; Expression={
                if ($_.PSIsContainer) { 
                    Write-Host $_.Name -ForegroundColor Blue -NoNewline
                    $_.Name
                } else { $_.Name }
            }}
        ) -AutoSize
    } else {
        $items | Format-Table Mode, Length, LastWriteTime, Name -AutoSize
    }
}

# la - 显示所有文件包括隐藏文件
function la {
    param([string]$Path = ".")
    ll -Path $Path -All -Human
}

# grep 增强版
function grep {
    param(
        [string]$Pattern,
        [string[]]$Path = @("."),
        [switch]$Recursive,
        [switch]$IgnoreCase,
        [switch]$LineNumber
    )
    
    $selectStringParams = @{
        Pattern = $Pattern
        Path = $Path
    }
    
    if ($Recursive) { $selectStringParams.Recurse = $true }
    if ($IgnoreCase) { $selectStringParams.CaseSensitive = $false }
    if ($LineNumber) { $selectStringParams.IncludeLineNumber = $true }
    
    Select-String @selectStringParams
}

# which 增强版 - 显示命令完整信息
function which {
    param([string]$Command)
    
    $cmd = Get-Command $Command -ErrorAction SilentlyContinue
    if ($cmd) {
        if ($cmd.CommandType -eq 'Application') {
            Write-Host "类型: " -NoNewline -ForegroundColor Gray
            Write-Host "可执行文件" -ForegroundColor Green
            Write-Host "路径: " -NoNewline -ForegroundColor Gray
            Write-Host $cmd.Source -ForegroundColor Yellow
        } elseif ($cmd.CommandType -eq 'Function') {
            Write-Host "类型: " -NoNewline -ForegroundColor Gray
            Write-Host "函数" -ForegroundColor Green
            Write-Host "定义: " -NoNewline -ForegroundColor Gray
            Write-Host $cmd.Definition.Split("`n")[0] -ForegroundColor Cyan
        } elseif ($cmd.CommandType -eq 'Alias') {
            Write-Host "类型: " -NoNewline -ForegroundColor Gray
            Write-Host "别名" -ForegroundColor Green
            Write-Host "指向: " -NoNewline -ForegroundColor Gray
            Write-Host $cmd.ResolvedCommandName -ForegroundColor Yellow
        } else {
            Write-Host "类型: " -NoNewline -ForegroundColor Gray
            Write-Host $cmd.CommandType -ForegroundColor Green
            if ($cmd.Source) {
                Write-Host "来源: " -NoNewline -ForegroundColor Gray
                Write-Host $cmd.Source -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "命令 '$Command' 未找到" -ForegroundColor Red
    }
}

# touch - 创建文件或更新时间戳
function touch {
    param([string[]]$Path)
    
    foreach ($file in $Path) {
        if (Test-Path $file) {
            (Get-Item $file).LastWriteTime = Get-Date
            Write-Host "更新时间戳: $file" -ForegroundColor Green
        } else {
            New-Item -Path $file -ItemType File | Out-Null
            Write-Host "创建文件: $file" -ForegroundColor Green
        }
    }
}

# === 导航增强别名 ===
Set-Alias -Name .. -Value Set-LocationUp
Set-Alias -Name ... -Value Set-LocationUp2
Set-Alias -Name .... -Value Set-LocationUp3

function Set-LocationUp { Set-Location .. }
function Set-LocationUp2 { Set-Location ..\.. }
function Set-LocationUp3 { Set-Location ..\..\.. }

# cd 增强 - 支持 - 返回上一个目录
$script:PreviousLocation = $PWD
function cd {
    param([string]$Path = "~")
    
    if ($Path -eq "-") {
        $temp = $PWD
        Set-Location $script:PreviousLocation
        $script:PreviousLocation = $temp
        Write-Host "返回: $PWD" -ForegroundColor Green
    } else {
        $script:PreviousLocation = $PWD
        Set-Location $Path
    }
}

# === 系统信息别名 ===

# ps 增强版 - 进程查看
function ps {
    param(
        [string]$Name,
        [switch]$All
    )
    
    if ($Name) {
        Get-Process -Name "*$Name*" -ErrorAction SilentlyContinue | 
            Format-Table Id, ProcessName, CPU, WorkingSet, StartTime -AutoSize
    } elseif ($All) {
        Get-Process | Format-Table Id, ProcessName, CPU, WorkingSet -AutoSize
    } else {
        Get-Process | Where-Object { $_.MainWindowTitle } | 
            Format-Table Id, ProcessName, MainWindowTitle -AutoSize
    }
}

# top 替代 - 显示系统资源使用情况
function top {
    param([int]$Count = 10)
    
    Write-Host "系统资源使用情况 (前 $Count 名)" -ForegroundColor Cyan
    Write-Host ""
    
    Get-Process | Sort-Object CPU -Descending | Select-Object -First $Count |
        Format-Table @(
            @{Name="PID"; Expression="Id"; Width=8},
            @{Name="进程名"; Expression="ProcessName"; Width=20},
            @{Name="CPU%"; Expression={
                if ($_.CPU) { "{0:F1}" -f $_.CPU } else { "0.0" }
            }; Width=8; Alignment="Right"},
            @{Name="内存(MB)"; Expression={
                "{0:F0}" -f ($_.WorkingSet / 1MB)
            }; Width=10; Alignment="Right"}
        ) -AutoSize
}

# df 替代 - 磁盘使用情况
function df {
    if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) {
        Get-WmiObject -Class Win32_LogicalDisk | 
            Format-Table @(
                @{Name="磁盘"; Expression="DeviceID"; Width=6},
                @{Name="大小(GB)"; Expression={"{0:F1}" -f ($_.Size / 1GB)}; Width=10; Alignment="Right"},
                @{Name="已用(GB)"; Expression={"{0:F1}" -f (($_.Size - $_.FreeSpace) / 1GB)}; Width=10; Alignment="Right"},
                @{Name="可用(GB)"; Expression={"{0:F1}" -f ($_.FreeSpace / 1GB)}; Width=10; Alignment="Right"},
                @{Name="使用率"; Expression={"{0:F1}%" -f ((($_.Size - $_.FreeSpace) / $_.Size) * 100)}; Width=8; Alignment="Right"},
                @{Name="文件系统"; Expression="FileSystem"; Width=12}
            ) -AutoSize
    } else {
        # Unix-like 系统使用 Get-PSDrive
        Get-PSDrive -PSProvider FileSystem |
            Format-Table Name, 
                @{Name="大小(GB)"; Expression={if ($_.Used -and $_.Free) {"{0:F1}" -f (($_.Used + $_.Free) / 1GB)} else {"N/A"}}; Width=10; Alignment="Right"},
                @{Name="已用(GB)"; Expression={if ($_.Used) {"{0:F1}" -f ($_.Used / 1GB)} else {"N/A"}}; Width=10; Alignment="Right"},
                @{Name="可用(GB)"; Expression={if ($_.Free) {"{0:F1}" -f ($_.Free / 1GB)} else {"N/A"}}; Width=10; Alignment="Right"},
                Root -AutoSize
    }
}

# === 网络工具别名 ===

# 简化的 curl 
function curl {
    param(
        [string]$Url,
        [string]$OutFile,
        [switch]$Silent,
        [hashtable]$Headers = @{}
    )
    
    $params = @{
        Uri = $Url
        UseBasicParsing = $true
    }
    
    if ($OutFile) { $params.OutFile = $OutFile }
    if ($Headers.Count -gt 0) { $params.Headers = $Headers }
    
    try {
        if ($Silent) {
            Invoke-WebRequest @params | Out-Null
        } else {
            $response = Invoke-WebRequest @params
            if (!$OutFile) {
                $response.Content
            }
        }
    } catch {
        Write-Error "请求失败: $($_.Exception.Message)"
    }
}

# wget 替代
function wget {
    param(
        [string]$Url,
        [string]$OutFile
    )
    
    if (!$OutFile) {
        $OutFile = Split-Path $Url -Leaf
    }
    
    Write-Host "下载: $Url -> $OutFile" -ForegroundColor Green
    curl -Url $Url -OutFile $OutFile -Silent
    
    if (Test-Path $OutFile) {
        $size = (Get-Item $OutFile).Length
        Write-Host "下载完成: $OutFile ($size 字节)" -ForegroundColor Green
    }
}

# === 开发工具别名 ===

# tree 替代 - 显示目录树
function tree {
    param(
        [string]$Path = ".",
        [int]$Depth = 3,
        [switch]$All
    )
    
    function Show-Tree {
        param(
            [string]$Path,
            [int]$CurrentDepth,
            [int]$MaxDepth,
            [string]$Prefix = "",
            [bool]$IsLast = $true,
            [bool]$ShowHidden = $false
        )
        
        if ($CurrentDepth -gt $MaxDepth) { return }
        
        $items = Get-ChildItem -Path $Path -Force:$ShowHidden | Sort-Object { $_.PSIsContainer }, Name
        
        for ($i = 0; $i -lt $items.Count; $i++) {
            $item = $items[$i]
            $isLast = ($i -eq ($items.Count - 1))
            $currentPrefix = if ($isLast) { "└── " } else { "├── " }
            $nextPrefix = if ($isLast) { "    " } else { "│   " }
            
            $displayName = if ($item.PSIsContainer) {
                Write-Host "$Prefix$currentPrefix" -NoNewline
                Write-Host $item.Name -ForegroundColor Blue
                $item.Name
            } else {
                "$Prefix$currentPrefix$($item.Name)"
            }
            
            if (!$item.PSIsContainer) {
                Write-Host $displayName
            }
            
            if ($item.PSIsContainer -and $CurrentDepth -lt $MaxDepth) {
                Show-Tree -Path $item.FullName -CurrentDepth ($CurrentDepth + 1) -MaxDepth $MaxDepth -Prefix "$Prefix$nextPrefix" -IsLast $isLast -ShowHidden $ShowHidden
            }
        }
    }
    
    Write-Host $Path -ForegroundColor Yellow
    Show-Tree -Path $Path -CurrentDepth 0 -MaxDepth $Depth -ShowHidden $All
}

# === 清理和帮助 ===

# clear 增强
function clear {
    [System.Console]::Clear()
    if ([Environment]::UserInteractive -and !$env:PWSH_NO_WELCOME) {
        Write-Host "PowerShell $($PSVersionTable.PSVersion) " -ForegroundColor Green -NoNewline
        Write-Host "| 当前目录: " -ForegroundColor DarkGray -NoNewline
        Write-Host $PWD -ForegroundColor Yellow
    }
}

# 历史记录清理
function clear-history {
    Clear-History
    if (Test-Path (Get-PSReadlineOption).HistorySavePath) {
        Remove-Item (Get-PSReadlineOption).HistorySavePath -Force
        Write-Host "历史记录已清空" -ForegroundColor Green
    }
}

# 显示所有自定义别名
function Show-CustomAliases {
    Write-Host "🔧 自定义别名和函数:" -ForegroundColor Cyan
    Write-Host ""
    
    $functions = @(
        @{Name="ll"; Description="详细列表显示"},
        @{Name="la"; Description="显示所有文件(包括隐藏)"},
        @{Name="grep"; Description="文本搜索"},
        @{Name="which"; Description="查找命令位置"},
        @{Name="touch"; Description="创建文件或更新时间戳"},
        @{Name="cd -"; Description="返回上一个目录"},
        @{Name=".."; Description="上级目录"},
        @{Name="..."; Description="上两级目录"},
        @{Name="ps"; Description="进程查看"},
        @{Name="top"; Description="系统资源监控"},
        @{Name="df"; Description="磁盘使用情况"},
        @{Name="tree"; Description="目录树显示"},
        @{Name="curl"; Description="HTTP 请求"},
        @{Name="wget"; Description="文件下载"},
        @{Name="clear"; Description="清屏"},
        @{Name="clear-history"; Description="清空历史记录"}
    )
    
    $functions | Format-Table @(
        @{Name="命令"; Expression="Name"; Width=15},
        @{Name="描述"; Expression="Description"}
    ) -AutoSize
}

Set-Alias -Name aliases -Value Show-CustomAliases

Write-ProfileLog "别名定义加载完成" -Level "DEBUG"