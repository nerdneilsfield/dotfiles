$PowerShellConfDir="$HOME\.powershell"

if (Test-Path $PRIVATE_DOTFILES) {
    if (Test-Path $PRIVATE_DOTFILES\powershell\main.ps1) {
        . $PRIVATE_DOTFILES\powershell\main.ps1
    }
}

. $PowerShellConfDir\utils.ps1
. $PowerShellConfDir\alias.ps1
. $PowerShellConfDir\scoop.ps1
. $PowerShellConfDir\powershell.ps1
. $PowerShellConfDir\format.ps1
. $PowerShellConfDir\tools.ps1
. $PowerShellConfDir\editor.ps1
. $PowerShellConfDir\wsl.ps1
. $PowerShellConfDir\html.ps1
. $PowerShellConfDir\matlab.ps1
. $PowerShellConfDir\python.ps1
. $PowerShellConfDir\rust.ps1
. $PowerShellConfDir\media.ps1
