function Install-Powershell-Soft
{
    $powershell_soft=@(
        "starship",
        "zoxide",
        "fzf"
    )

    foreach ($soft in $powershell_soft)
    {
        scoop install $soft
    }

    # Install-Powershell-Moudle
    $powershell_modules=@(
        "posh-git",
        "PSReadLine",
        "PSFzf"
    )
    foreach ($module in $powershell_modules)
    {
        Install-Module -Name $module -Force
    }
}

if (Get-Command starship -ErrorAction SilentlyContinue)
{
    Invoke-Expression (&starship init powershell)
}

if (Get-Command zoxide -ErrorAction SilentlyContinue)
{
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# if installed module PSFzf PSReadLine then set up fzf key bindings
if (Get-Module -ListAvailable PSFzf -ErrorAction SilentlyContinue)
{
    Import-Module PSFzf -Force
}

if (Get-Module -ListAvailable PSReadLine -ErrorAction SilentlyContinue)
{
    Import-Module PSReadLine -Force
}

if (Get-Module -ListAvailable PSReadLine -ErrorAction SilentlyContinue)
{
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

    Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -ScriptBlock {
        Invoke-FuzzyHistory
    }
}

