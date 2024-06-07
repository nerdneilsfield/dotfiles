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

function Reload-Powershell-Profile
{
    . $PROFILE
}

function Show-Welcome-Pages
{
    $current_time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $current_dir = Get-Location -PSProvider FileSystem | Select-Object -ExpandProperty Path
    $welcome_pages=@(
        "====== Welcome to Powershell ======",
        "====== Current Time: $current_time ======",
        "====== Current Directory: $current_dir ======"
    )
    foreach ($page in $welcome_pages)
    {
        Write-Host $page -ForegroundColor Green
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

Show-Welcome-Pages
