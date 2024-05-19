function Install-Powershell-Soft {
    $powershell_soft=@(
        "starship",
        "zoxide",
        "fzf"
    )

    foreach ($soft in $powershell_soft) {
        scoop install $soft
    }

    # Install-Powershell-Moudle
    $powershell_modules=@(
        "posh-git",
        "PSReadLine",
        "PSFzf"
    )
    foreach ($module in $powershell_modules) {
        Install-Module -Name $module -Force
    }
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}
