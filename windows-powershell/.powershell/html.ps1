function Install-Javascript-Tools {
    $tools=@(
        "fnm",
        "bun",
        "deno"
    )

    foreach ($tool in $tools) {
        Green-Echo "=======install $tool========="
        scoop install $tool
    }
}

function Install-Firefox {
    scoop install firefox
}

function Install-Chrome {
    scoop install googlechrome
}

function Install-Edge {
    scoop install microsoft-edge
}

function Install-Opera {
    scoop install opera
}

function Install-Brave {
    scoop install brave
}

function Fnm-Install-Lts {
    fnm install --lts
}

if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd --shell power-shell | Out-String | Invoke-Expression
}
