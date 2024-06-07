function Green-Echo
{
    param([string]$message)
    Write-Host $message -ForegroundColor Green
}

function Red-Echo
{
    param([string]$message)
    Write-Host $message -ForegroundColor Red
}

function Yellow-Echo
{
    param([string]$message)
    Write-Host $message -ForegroundColor Yellow
}

function Blue-Echo
{
    param([string]$message)
    Write-Host $message -ForegroundColor Blue
}

function Cyan-Echo
{
    param([string]$message)
    Write-Host $message -ForegroundColor Cyan
}

function Magenta-Echo
{
    param([string]$message)
    Write-Host $message -ForegroundColor Magenta
}

function White-Echo
{
    param([string]$message)
    Write-Host $message -ForegroundColor White
}

function Black-Echo
{
    param([string]$message)
    Write-Host $message -ForegroundColor Black
}

function Gray-Echo
{
    param([string]$message)
    Write-Host $message -ForegroundColor Gray
}

function DarkGray-Echo
{
    param([string]$message)
    Write-Host $message -ForegroundColor DarkGray
}

function DarkRed-Echo
{
    param([string]$message)
    Write-Host $message -ForegroundColor DarkRed
}

function DarkGreen-Echo
{
    param([string]$message)
    Write-Host $message -ForegroundColor DarkGreen
}

function DarkYellow-Echo
{
    param([string]$message)
    Write-Host $message -ForegroundColor DarkYellow
}

function DarkBlue-Echo
{
    param([string]$message)
    Write-Host $message -ForegroundColor DarkBlue
}

function DarkCyan-Echo
{
    param([string]$message)
    Write-Host $message -ForegroundColor DarkCyan
}

function Add-To-Path
{
    param (
        [string]$Path
    )
    if (-Not (Test-Path $Path))
    {
        Write-Error "Path not found: $Path"
        return
    }
    # backup path
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    Green-Echo "Backup...... Path"
    [Environment]::SetEnvironmentVariable("BackupPath", $currentPath, "User")
    if ($currentPath -split ";" -notcontains $Path)
    {
        $newPath = $currentPath + ";" + $Path
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Green-Echo "Path added: $Path"
    } else
    {
        Yellow-Echo "Path already exists: $Path"
    }
}

function Remove-From-Path
{
    param (
        [string]$Path
    )
    if (-Not (Test-Path $Path))
    {
        Write-Error "Path not found: $Path"
        return
    }
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    Green-Echo "Backup...... Path"
    [Environment]::SetEnvironmentVariable("BackupPath", $currentPath, "User")
    if ($currentPath -split ";" -contains $Path)
    {
        $newPath = $currentPath -replace (";" + $Path), ""
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Green-Echo "Path removed: $Path"
    } else
    {
        Yellow-Echo "Path not found: $Path"
    }
}

function List-Path
{
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $currentPath -split ";"
}

function Set-Env
{
    param (
        [string]$Name,
        [string]$Value
    )
    [Environment]::SetEnvironmentVariable($Name, $Value, "User")
    Green-Echo "Environment variable set: $Name=$Value"
}

function Remove-Env
{
    param (
        [string]$Name
    )
    [Environment]::SetEnvironmentVariable($Name, $null, "User")
    Green-Echo "Environment variable removed: $Name"
}

function Set-Dotfiles-Dir
{
    param (
        [string]$Path
    )
    Set-Env "DOTFILES" $Path
}

function Set-Private-Dotfiles-Dir
{
    param (
        [string]$Path
    )
    Set-Env "PRIVATE_DOTFILES" $Path
}

# function Stow-Path {
#     param (
#         [string]$In,
#         [string]$Out="$HOME"
#     )
#     if (-Not (Test-Path $In)) {
#         Write-Error "Path not found: $In"
#         return
#     }
# }

function Set-Commands-Run-Start
{
    param (
        [string]$TaskName,
        [string]$Command
    )
    $command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `"$Command`""
    sudo Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $TaskName -Value $command
}

function Remove-Commands-Run-Start
{
    param (
        [string]$TaskName
    )
    sudo Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $TaskName
}

function New-BasicDir
{
    $local = $env:USERPROFILE + "\.local"
    $bin = $local + "\bin"
    $config = $local + "\config"
    $cache = $local + "\cache"
    $temp = $local + "\temp"

    New-Item -ItemType Directory -Force $local
    New-Item -ItemType Directory -Force $bin
    New-Item -ItemType Directory -Force $config
    New-Item -ItemType Directory -Force $cache
    New-Item -ItemType Directory -Force $temp
}

<#
.SYNOPSIS
Creates a symbolic link.

.DESCRIPTION
The New-SymbolicLink function creates a symbolic link using the `New-Item` cmdlet with the `-ItemType SymbolicLink` parameter.

.PARAMETER Target
Specifies the target of the symbolic link.

.PARAMETER Path
Specifies the path where the symbolic link will be created.

.EXAMPLE
New-SymbolicLink -Target "C:\path\to\file.txt" -Path "C:\path\to\symlink.txt"
Creates a symbolic link named "symlink.txt" that points to the file "file.txt" located at "C:\path\to\".

#>
function New-SymbolicLink
{
    sudo New-Item -ItemType SymbolicLink -Path $args[1] -Value $args[0]
}

function New-Junction
{
    sudo New-Item -ItemType Junction -Path $args[1] -Value $args[0]
}

function New-HardLink
{
    sudo New-Item -ItemType HardLink -Path $args[1] -Value $args[0]
}

function New-Recursive-HardLink
{
    $source = $args[0]
    $destination = $args[1]
    Get-ChildItem -Recurse -Path $source | ForEach-Object {
        $target = $_.FullName.Replace($source, $destination)
        New-HardLink $_.FullName $target
    }
}


function New-UUId
{
    $guid = [guid]::NewGuid()
    $guid.ToString()
}

# random generate 32-bit string
function New-Token
{
    $token = [System.Web.Security.Membership]::GeneratePassword(32, 0)
    $token
}

function New-RandomToken
{
    param (
        [int]$length = 32  # 默认长度为32
    )

    # 定义字符集，包括大小写字母和数字
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".ToCharArray()

    # 使用 Get-Random 生成随机字符
    $random = New-Object System.Random
    $token = -join ((1..$length) | ForEach-Object { $chars[$random.Next(0, $chars.Length)] })
    return $token
}

function New-Deeplx-Translate
{
    param (
        [string]$Text,
        [string]$TargetLang="EN"
    )
    $url = "https://api-free.deepl.com/v2/translate"
    $authKey = "auth_key"
    $data = @{
        "auth_key" = $authKey
        "text" = $Text
        "target_lang" = $TargetLang
    }
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $data
    $response.translations.text
}

# List fonts install
function Get-InstalledFonts
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    $fonts = New-Object System.Drawing.Text.InstalledFontCollection
    $fontNames = $fonts.Families | ForEach-Object { $_.Name }
    Write-Output "Installed Fonts using System.Drawing:"
    $fontNames
}

# github new release
function Get-Github-NewRelease
{
    param (
        [string]$Owner,
        [string]$Repo
    )
    if (-not $Owner -or -not $Repo)
    {
        Green-Echo "Owner or Repo is required"
        return
    }
    $url = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
    if ([System.Environment]::GetEnvironmentVariable("GITHUB_TOKEN"))
    {
        $token = [System.Environment]::GetEnvironmentVariable
        $response = Invoke-RestMethod -Uri $url -Headers @{ Authorization="Bearer $token" }
    } else
    {
        $response = Invoke-RestMethod -Uri $url
    }
    # deal the respose
    $response.tag_name
}
