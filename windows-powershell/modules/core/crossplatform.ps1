# Cross-Platform File Operations Helper
# 跨平台文件操作辅助函数，统一 Windows/WSL/Unix 操作

# 平台检测
$script:IsWindows = $PSVersionTable.PSVersion.Major -le 5 -or $IsWindows
$script:IsLinux = $PSVersionTable.PSVersion.Major -gt 5 -and $IsLinux
$script:IsMacOS = $PSVersionTable.PSVersion.Major -gt 5 -and $IsMacOS
$script:IsWSL = $false

# WSL 检测
if ($script:IsLinux) {
    try {
        $wslInfo = Get-Content "/proc/version" -ErrorAction SilentlyContinue
        $script:IsWSL = $wslInfo -match "Microsoft|WSL"
    }
    catch {
        $script:IsWSL = $false
    }
}

function Get-PlatformInfo {
    <#
    .SYNOPSIS
    获取当前平台信息
    #>
    return @{
        IsWindows = $script:IsWindows
        IsLinux = $script:IsLinux
        IsMacOS = $script:IsMacOS
        IsWSL = $script:IsWSL
        PowerShellVersion = $PSVersionTable.PSVersion
        OS = if ($script:IsWindows) { "Windows" } 
             elseif ($script:IsLinux) { if ($script:IsWSL) { "WSL" } else { "Linux" } }
             elseif ($script:IsMacOS) { "macOS" }
             else { "Unknown" }
    }
}

function Get-PathSeparator {
    <#
    .SYNOPSIS
    获取路径分隔符
    #>
    if ($script:IsWindows) {
        return "\"
    } else {
        return "/"
    }
}

function ConvertTo-CrossPlatformPath {
    <#
    .SYNOPSIS
    转换为跨平台路径
    .PARAMETER Path
    要转换的路径
    .PARAMETER TargetPlatform
    目标平台: Windows, Unix, Auto
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [ValidateSet("Windows", "Unix", "Auto")]
        [string]$TargetPlatform = "Auto"
    )
    
    if ($TargetPlatform -eq "Auto") {
        $TargetPlatform = if ($script:IsWindows) { "Windows" } else { "Unix" }
    }
    
    switch ($TargetPlatform) {
        "Windows" {
            return $Path -replace "/", "\"
        }
        "Unix" {
            return $Path -replace "\\", "/"
        }
    }
}

function Test-CrossPlatformPath {
    <#
    .SYNOPSIS
    跨平台路径存在性检查
    .PARAMETER Path
    要检查的路径
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    
    try {
        $normalizedPath = ConvertTo-CrossPlatformPath -Path $Path
        return Test-Path $normalizedPath
    }
    catch {
        return $false
    }
}

function New-CrossPlatformDirectory {
    <#
    .SYNOPSIS
    跨平台创建目录
    .PARAMETER Path
    目录路径
    .PARAMETER Force
    强制创建（如果父目录不存在）
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [switch]$Force
    )
    
    try {
        $normalizedPath = ConvertTo-CrossPlatformPath -Path $Path
        
        if (-not (Test-Path $normalizedPath)) {
            New-Item -ItemType Directory -Path $normalizedPath -Force:$Force | Out-Null
            Write-Host "✅ 创建目录: $normalizedPath" -ForegroundColor Green
        } else {
            Write-Host "📁 目录已存在: $normalizedPath" -ForegroundColor Yellow
        }
        
        return $true
    }
    catch {
        Write-Error "创建目录失败: $_"
        return $false
    }
}

function Copy-CrossPlatformFile {
    <#
    .SYNOPSIS
    跨平台文件复制
    .PARAMETER Source
    源文件路径
    .PARAMETER Destination
    目标路径
    .PARAMETER Force
    强制覆盖
    .PARAMETER CreateDirectories
    创建目标目录
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Source,
        [Parameter(Mandatory)]
        [string]$Destination,
        [switch]$Force,
        [switch]$CreateDirectories
    )
    
    try {
        $normalizedSource = ConvertTo-CrossPlatformPath -Path $Source
        $normalizedDest = ConvertTo-CrossPlatformPath -Path $Destination
        
        if (-not (Test-Path $normalizedSource)) {
            Write-Error "源文件不存在: $normalizedSource"
            return $false
        }
        
        if ($CreateDirectories) {
            $destDir = Split-Path $normalizedDest -Parent
            if (-not [string]::IsNullOrEmpty($destDir) -and -not (Test-Path $destDir)) {
                New-CrossPlatformDirectory -Path $destDir -Force | Out-Null
            }
        }
        
        Copy-Item -Path $normalizedSource -Destination $normalizedDest -Force:$Force
        Write-Host "📄 复制文件: $normalizedSource -> $normalizedDest" -ForegroundColor Blue
        
        return $true
    }
    catch {
        Write-Error "复制文件失败: $_"
        return $false
    }
}

function Move-CrossPlatformFile {
    <#
    .SYNOPSIS
    跨平台文件移动
    .PARAMETER Source
    源文件路径
    .PARAMETER Destination
    目标路径
    .PARAMETER Force
    强制覆盖
    .PARAMETER CreateDirectories
    创建目标目录
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Source,
        [Parameter(Mandatory)]
        [string]$Destination,
        [switch]$Force,
        [switch]$CreateDirectories
    )
    
    try {
        $normalizedSource = ConvertTo-CrossPlatformPath -Path $Source
        $normalizedDest = ConvertTo-CrossPlatformPath -Path $Destination
        
        if (-not (Test-Path $normalizedSource)) {
            Write-Error "源文件不存在: $normalizedSource"
            return $false
        }
        
        if ($CreateDirectories) {
            $destDir = Split-Path $normalizedDest -Parent
            if (-not [string]::IsNullOrEmpty($destDir) -and -not (Test-Path $destDir)) {
                New-CrossPlatformDirectory -Path $destDir -Force | Out-Null
            }
        }
        
        Move-Item -Path $normalizedSource -Destination $normalizedDest -Force:$Force
        Write-Host "🚚 移动文件: $normalizedSource -> $normalizedDest" -ForegroundColor Magenta
        
        return $true
    }
    catch {
        Write-Error "移动文件失败: $_"
        return $false
    }
}

function Remove-CrossPlatformFile {
    <#
    .SYNOPSIS
    跨平台文件删除
    .PARAMETER Path
    要删除的文件或目录路径
    .PARAMETER Recurse
    递归删除目录
    .PARAMETER Force
    强制删除
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [switch]$Recurse,
        [switch]$Force
    )
    
    try {
        $normalizedPath = ConvertTo-CrossPlatformPath -Path $Path
        
        if (-not (Test-Path $normalizedPath)) {
            Write-Warning "路径不存在: $normalizedPath"
            return $false
        }
        
        Remove-Item -Path $normalizedPath -Recurse:$Recurse -Force:$Force
        Write-Host "🗑️  删除: $normalizedPath" -ForegroundColor Red
        
        return $true
    }
    catch {
        Write-Error "删除失败: $_"
        return $false
    }
}

function New-CrossPlatformSymlink {
    <#
    .SYNOPSIS
    跨平台创建符号链接
    .PARAMETER Target
    链接目标
    .PARAMETER LinkPath
    链接路径
    .PARAMETER Directory
    是否为目录链接
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$LinkPath,
        [switch]$Directory
    )
    
    try {
        $normalizedTarget = ConvertTo-CrossPlatformPath -Path $Target
        $normalizedLink = ConvertTo-CrossPlatformPath -Path $LinkPath
        
        if ($script:IsWindows) {
            # Windows 需要管理员权限创建符号链接
            if ($Directory) {
                $result = cmd /c "mklink /D `"$normalizedLink`" `"$normalizedTarget`""
            } else {
                $result = cmd /c "mklink `"$normalizedLink`" `"$normalizedTarget`""
            }
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "🔗 创建符号链接: $normalizedLink -> $normalizedTarget" -ForegroundColor Cyan
                return $true
            } else {
                Write-Error "创建符号链接失败，可能需要管理员权限"
                return $false
            }
        } else {
            # Unix-like 系统
            $result = & ln -sf $normalizedTarget $normalizedLink
            if ($LASTEXITCODE -eq 0) {
                Write-Host "🔗 创建符号链接: $normalizedLink -> $normalizedTarget" -ForegroundColor Cyan
                return $true
            } else {
                Write-Error "创建符号链接失败"
                return $false
            }
        }
    }
    catch {
        Write-Error "创建符号链接失败: $_"
        return $false
    }
}

function Get-CrossPlatformFileInfo {
    <#
    .SYNOPSIS
    获取跨平台文件信息
    .PARAMETER Path
    文件路径
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    
    try {
        $normalizedPath = ConvertTo-CrossPlatformPath -Path $Path
        
        if (-not (Test-Path $normalizedPath)) {
            Write-Error "文件不存在: $normalizedPath"
            return $null
        }
        
        $item = Get-Item $normalizedPath
        $info = @{
            Name = $item.Name
            FullName = $item.FullName
            Size = if ($item.PSIsContainer) { $null } else { $item.Length }
            IsDirectory = $item.PSIsContainer
            LastWriteTime = $item.LastWriteTime
            CreationTime = $item.CreationTime
            Attributes = $item.Attributes
            Extension = $item.Extension
        }
        
        # Unix 特有属性
        if (-not $script:IsWindows) {
            try {
                $statInfo = & stat -c "%a %U %G" $normalizedPath 2>$null
                if ($LASTEXITCODE -eq 0) {
                    $parts = $statInfo -split '\s+'
                    $info.Permissions = $parts[0]
                    $info.Owner = $parts[1]
                    $info.Group = $parts[2]
                }
            }
            catch {
                # stat 命令不可用
            }
        }
        
        return [PSCustomObject]$info
    }
    catch {
        Write-Error "获取文件信息失败: $_"
        return $null
    }
}

function Set-CrossPlatformPermissions {
    <#
    .SYNOPSIS
    设置跨平台文件权限
    .PARAMETER Path
    文件路径
    .PARAMETER Permissions
    权限（Unix 数字格式或 Windows 字符串）
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Permissions
    )
    
    try {
        $normalizedPath = ConvertTo-CrossPlatformPath -Path $Path
        
        if (-not (Test-Path $normalizedPath)) {
            Write-Error "文件不存在: $normalizedPath"
            return $false
        }
        
        if ($script:IsWindows) {
            # Windows 权限设置更复杂，这里提供基础实现
            if ($Permissions -match "readonly|hidden|system") {
                $attr = [System.IO.FileAttributes]::Normal
                
                if ($Permissions -match "readonly") {
                    $attr = $attr -bor [System.IO.FileAttributes]::ReadOnly
                }
                if ($Permissions -match "hidden") {
                    $attr = $attr -bor [System.IO.FileAttributes]::Hidden
                }
                if ($Permissions -match "system") {
                    $attr = $attr -bor [System.IO.FileAttributes]::System
                }
                
                Set-ItemProperty -Path $normalizedPath -Name Attributes -Value $attr
                Write-Host "🔐 设置权限: $normalizedPath -> $Permissions" -ForegroundColor Yellow
            }
        } else {
            # Unix-like 系统
            & chmod $Permissions $normalizedPath
            if ($LASTEXITCODE -eq 0) {
                Write-Host "🔐 设置权限: $normalizedPath -> $Permissions" -ForegroundColor Yellow
                return $true
            } else {
                Write-Error "设置权限失败"
                return $false
            }
        }
        
        return $true
    }
    catch {
        Write-Error "设置权限失败: $_"
        return $false
    }
}

function Get-CrossPlatformDiskUsage {
    <#
    .SYNOPSIS
    获取跨平台磁盘使用情况
    .PARAMETER Path
    路径，默认当前目录
    #>
    param(
        [string]$Path = "."
    )
    
    try {
        $normalizedPath = ConvertTo-CrossPlatformPath -Path $Path
        
        if ($script:IsWindows) {
            # Windows 使用 Get-PSDrive 或 WMI
            $drive = (Get-Item $normalizedPath).PSDrive
            if ($drive) {
                return @{
                    Path = $normalizedPath
                    TotalSize = $drive.Used + $drive.Free
                    UsedSize = $drive.Used
                    FreeSize = $drive.Free
                    UsedPercent = [math]::Round(($drive.Used / ($drive.Used + $drive.Free)) * 100, 2)
                }
            }
        } else {
            # Unix-like 系统使用 df
            $dfOutput = & df -h $normalizedPath 2>$null | Select-Object -Skip 1
            if ($LASTEXITCODE -eq 0 -and $dfOutput) {
                $parts = $dfOutput -split '\s+' | Where-Object { $_ -ne '' }
                if ($parts.Count -ge 6) {
                    return @{
                        Path = $normalizedPath
                        Filesystem = $parts[0]
                        TotalSize = $parts[1]
                        UsedSize = $parts[2]
                        FreeSize = $parts[3]
                        UsedPercent = $parts[4] -replace '%', ''
                        MountPoint = $parts[5]
                    }
                }
            }
        }
        
        return $null
    }
    catch {
        Write-Error "获取磁盘使用情况失败: $_"
        return $null
    }
}

function Find-CrossPlatformExecutable {
    <#
    .SYNOPSIS
    跨平台查找可执行文件
    .PARAMETER Name
    可执行文件名
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )
    
    try {
        # 使用 Get-Command
        $cmd = Get-Command $Name -ErrorAction SilentlyContinue
        if ($cmd) {
            return $cmd.Source
        }
        
        # 在 PATH 中搜索
        $pathDirs = $env:PATH -split [System.IO.Path]::PathSeparator
        
        foreach ($dir in $pathDirs) {
            if ([string]::IsNullOrWhiteSpace($dir)) { continue }
            
            $fullPath = Join-Path $dir $Name
            
            # Windows 需要检查多个扩展名
            if ($script:IsWindows) {
                $extensions = @(".exe", ".cmd", ".bat", ".ps1")
                foreach ($ext in $extensions) {
                    $pathWithExt = $fullPath + $ext
                    if (Test-Path $pathWithExt) {
                        return $pathWithExt
                    }
                }
            } else {
                if (Test-Path $fullPath) {
                    return $fullPath
                }
            }
        }
        
        return $null
    }
    catch {
        return $null
    }
}

# 便捷别名
function xmkdir { New-CrossPlatformDirectory @args }
function xcp { Copy-CrossPlatformFile @args }
function xmv { Move-CrossPlatformFile @args }
function xrm { Remove-CrossPlatformFile @args }
function xln { New-CrossPlatformSymlink @args }
function xstat { Get-CrossPlatformFileInfo @args }
function xchmod { Set-CrossPlatformPermissions @args }
function xdf { Get-CrossPlatformDiskUsage @args }
function xwhich { Find-CrossPlatformExecutable @args }

# 模块初始化
$platformInfo = Get-PlatformInfo
Write-Host "🌐 跨平台操作模块已加载" -ForegroundColor Green
Write-Host "   平台: $($platformInfo.OS)" -ForegroundColor Blue
Write-Host "   PowerShell: $($platformInfo.PowerShellVersion)" -ForegroundColor Blue

if ($script:IsWSL) {
    Write-Host "   🐧 WSL 环境检测到" -ForegroundColor Cyan
}

# Note: Functions and aliases are automatically available when dot-sourced