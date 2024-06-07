$PowerShellConfDir="$HOME\.powershell"

if ($null -eq [System.Environment]::GetEnvironmentVariable("PRIVATE_DOTFILES"))
{
    Write-Host "PRIVATE_DOTFILES is not set, please set it first" -ForegroundColor Red
    Write-Host "Set-Env PRIVATE_DOTFILES <path>" -ForegroundColor Yellow
}

if (Test-Path $env:PRIVATE_DOTFILES -ErrorAction SilentlyContinue)
{
    if (Test-Path $env:PRIVATE_DOTFILES\powershell\main.ps1 -ErrorAction SilentlyContinue)
    {
        . $env:PRIVATE_DOTFILES\powershell\main.ps1
    }
}

. $PowerShellConfDir\utils.ps1
. $PowerShellConfDir\alias.ps1
. $PowerShellConfDir\scoop.ps1
. $PowerShellConfDir\powershell.ps1
. $PowerShellConfDir\networks.ps1
. $PowerShellConfDir\format.ps1
. $PowerShellConfDir\tools.ps1
. $PowerShellConfDir\editor.ps1
. $PowerShellConfDir\wsl.ps1
. $PowerShellConfDir\html.ps1
. $PowerShellConfDir\matlab.ps1
. $PowerShellConfDir\python.ps1
. $PowerShellConfDir\golang.ps1
. $PowerShellConfDir\rust.ps1
. $PowerShellConfDir\media.ps1
. $PowerShellConfDir\zig.ps1
. $PowerShellConfDir\cc.ps1
. $PowerShellConfDir\windows.ps1
