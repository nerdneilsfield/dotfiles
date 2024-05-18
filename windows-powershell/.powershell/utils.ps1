function Green-Echo {
    param([string]$message)
    Write-Host $message -ForegroundColor Green
}

function Red-Echo {
    param([string]$message)
    Write-Host $message -ForegroundColor Red
}

function Yellow-Echo {
    param([string]$message)
    Write-Host $message -ForegroundColor Yellow
}

function Blue-Echo {
    param([string]$message)
    Write-Host $message -ForegroundColor Blue
}

function Cyan-Echo {
    param([string]$message)
    Write-Host $message -ForegroundColor Cyan
}

function Magenta-Echo {
    param([string]$message)
    Write-Host $message -ForegroundColor Magenta
}

function White-Echo {
    param([string]$message)
    Write-Host $message -ForegroundColor White
}

function Black-Echo {
    param([string]$message)
    Write-Host $message -ForegroundColor Black
}

function Gray-Echo {
    param([string]$message)
    Write-Host $message -ForegroundColor Gray
}

function DarkGray-Echo {
    param([string]$message)
    Write-Host $message -ForegroundColor DarkGray
}

function DarkRed-Echo {
    param([string]$message)
    Write-Host $message -ForegroundColor DarkRed
}

function DarkGreen-Echo {
    param([string]$message)
    Write-Host $message -ForegroundColor DarkGreen
}

function DarkYellow-Echo {
    param([string]$message)
    Write-Host $message -ForegroundColor DarkYellow
}

function DarkBlue-Echo {
    param([string]$message)
    Write-Host $message -ForegroundColor DarkBlue
}

function DarkCyan-Echo {
    param([string]$message)
    Write-Host $message -ForegroundColor DarkCyan
}

function Add-To-Path {
    param (
        [string]$Path
    )
    if (-Not (Test-Path $Path)) {
        Write-Error "Path not found: $Path"
        return
    }
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -split ";" -notcontains $Path) {
        $newPath = $currentPath + ";" + $Path
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Green-Echo "Path added: $Path"
    } else {
        Yellow-Echo "Path already exists: $Path"
    }
}

function Remove-From-Path {
    param (
        [string]$Path
    )
    if (-Not (Test-Path $Path)) {
        Write-Error "Path not found: $Path"
        return
    }
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -split ";" -contains $Path) {
        $newPath = $currentPath -replace (";" + $Path), ""
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Green-Echo "Path removed: $Path"
    } else {
        Yellow-Echo "Path not found: $Path"
    }
}

function Set-Env {
    param (
        [string]$Name,
        [string]$Value
    )
    [Environment]::SetEnvironmentVariable($Name, $Value, "User")
    Green-Echo "Environment variable set: $Name=$Value"
}

function Remove-Env {
    param (
        [string]$Name
    )
    [Environment]::SetEnvironmentVariable($Name, $null, "User")
    Green-Echo "Environment variable removed: $Name"
}

function Set-Dotfiles-Dir {
    param (
        [string]$Path
    )
    Set-Env "DOTFILES" $Path
}

function Stow-Path {
    param (
        [string]$In,
        [string]$Out="$HOME"
    )
    if (-Not (Test-Path $In)) {
        Write-Error "Path not found: $In"
        return
    }
}

function Set-Commands-Run-Start {
    param (
        [string]$TaskName,
        [string]$Command
    )
    $command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `"$Command`""
    sudo Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $TaskName -Value $command
}

function Remove-Commands-Run-Start {
    param (
        [string]$TaskName
    )
    sudo Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $TaskName
}

function Make-Basic-Dir {
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