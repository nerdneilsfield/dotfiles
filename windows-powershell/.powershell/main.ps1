$PowerShellConfDir="$HOME\.powershell"

$PrivateDotfilesDir = [System.Environment]::GetEnvironmentVariable("PRIVATE_DOTFILES", [System.EnvironmentVariableTarget]::User)
if ($null -eq $PrivateDotfilesDir)
{
    Write-Host "PRIVATE_DOTFILES is not set, please set it first" -ForegroundColor Red
    Write-Host "Set-Env PRIVATE_DOTFILES <path>" -ForegroundColor Yellow
}

Write-Host "Loaded private dotfiles: $PrivateDotfilesDir" -ForegroundColor Green
if (Test-Path $PrivateDotfilesDir\powershell\main.ps1 -ErrorAction SilentlyContinue)
{
    . $PrivateDotfilesDir\powershell\main.ps1
    Write-Host "Loaded private powershell configuration" -ForegroundColor Green
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
