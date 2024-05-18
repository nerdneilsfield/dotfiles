function Install-Scoop {
    param (
        [string]$DIR="C:\Users\$env:USERNAME\scoop"
    )
    Set-Env SCOOP $DIR
    Set-Env 
    Set-ExecutionPolicy RemoteSigned -scope CurrentUser
    iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
    scoop config aria2-enabled false
}

function Update-Scoop-Aria2-Config {
    # 定义配置文件路径
    $configPath = "$env:USERPROFILE\.config\scoop\config.json"

    # 检查配置文件是否存在
    if (Test-Path -Path $configPath) {
        # 读取现有的 JSON 配置文件
        $configContent = Get-Content -Path $configPath -Raw | ConvertFrom-Json
    } else {
        # 如果文件不存在，创建一个新的空对象
        $configContent = @{}
    }

    # 确保配置对象是一个哈希表
    if (-not ($configContent -is [hashtable])) {
        $configContent = @{}
    }

    # 添加或修改配置项
    $configContent["aria2-enabled"] = $true
    $configContent["aria2-args"] = @(
        "--max-connection-per-server=5",
        "--split=5",
        "--min-split-size=10M",
        "--async-dns=false",
        "--all-proxy=$env:https_proxy"
    )

    # 将修改后的 JSON 对象写回到配置文件中
    $configContent | ConvertTo-Json -Depth 10 | Set-Content -Path $configPath -Encoding UTF8

    scoop config aria2-enabled true

    Write-Output "Scoop 的 aria2 默认参数已设置。"
}

function Install-Scoop-Basic {
    scoop install aria2 git openssh sudo winget git-lfs
    git lfs install
}

function Scoop-Deep-Clean {
    scoop cache rm *
    scoop cleanup *
}

function Scoop-Add-Buckets {
    $buckets = @(
        "extras",
        "nerd-fonts",
        "versions",
        "games",
        "nightlies",
        "nonportable"
    )

    foreach ($bucket in $buckets) {
        scoop bucket add $bucket
    }
}