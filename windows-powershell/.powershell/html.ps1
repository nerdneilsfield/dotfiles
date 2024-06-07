function Install-Javascript-Tools
{
    $tools=@(
        "fnm",
        "bun",
        "deno"
    )

    foreach ($tool in $tools)
    {
        Green-Echo "=======install $tool========="
        scoop install $tool
        scoop update $tool
    }

    fnm install --lts
    fnm default lts-latest
}

function Install-Http-Tools
{
    $tools=@(
        "curl",
        "wget",
        "aria2",
        "Bruno",
        "xh",
        "monolith"
    )

    foreach ($tool in $tools)
    {
        Green-Echo "=======install $tool========="
        scoop install $tool
        scoop update $tool
    }
}

function Install-Firefox
{
    scoop install firefox
}

function Install-Chrome
{
    scoop install googlechrome
}

function Install-Edge
{
    scoop install microsoft-edge
}

function Install-Opera
{
    scoop install opera
}

function Install-Brave
{
    scoop install brave
}


if (Get-Command fnm -ErrorAction SilentlyContinue)
{
    fnm env --use-on-cd --shell power-shell | Out-String | Invoke-Expression
}
