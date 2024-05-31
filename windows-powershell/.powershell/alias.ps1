# windows
Set-Alias -Name exp -Value explorer

# web server
function Start-PyHttpServer {
    param (
        [int]$Port = 8000,
        [string]$Dir = ".",
        [string]$Bind = "localhost"
    )
    python3 -m http.server --bind $Bind --directory $Dir $Port
}
Set-Alias -Name httpserver -Value Start-PyHttpServer

# ls
# 检查 eza 是否存在
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function els { eza @args }
    function el { eza -l --all --group-directories-first --git @args }
    function ell { eza -l --all --all --group-directories-first --git @args }
    function elt { eza -T --git-ignore --level=2 --group-directories-first @args }
    function ellt { eza -lT --git-ignore --level=2 --group-directories-first @args }
    function elT { eza -T --git-ignore --level=4 --group-directories-first @args }
} elseif (Get-Command exa -ErrorAction SilentlyContinue) {
    function els { exa @args }
    function el { exa -l --all --group-directories-first --git @args }
    function ell { exa -l --all --all --group-directories-first --git @args }
    function elt { exa -T --git-ignore --level=2 --group-directories-first @args }
    function ellt { exa -lT --git-ignore --level=2 --group-directories-first @args }
    function elT { exa -T --git-ignore --level=4 --group-directories-first @args }
}

# ssh
function wssh {
    wsl -d Ubuntu-20.04 ssh -XY $args
}

# file
function rmrf {
    param (
        [string]$Path
    )
    Remove-Item -Recurse -Force $Path
}

function cpr {
    param (
        [string]$Source,
        [string]$Destination
    )
    Copy-Item -Recurse -Force $Source $Destination
}

function mvf {
    param (
        [string]$Source,
        [string]$Destination
    )
    Move-Item -Force $Source $Destination
}

function mkdirp {
    param (
        [string]$Path
    )
    New-Item -ItemType Directory -Force $Path
}

function Get-Command-FullPath {
    $command = Get-Command $args[0] -ErrorAction SilentlyContinue
    if ($command) {
        $command.Path
    } else {
        Write-Error "Command not found: $args[0]"
    }
}

function ar2cx {
    & aria2c -c -x 16 @args
    if ($LASTEXITCODE -eq 0) {
        Green-Echo "下载完成"
    } else {
        Write-Error "下载失败"
    }
}

function ar2cxp {
    & aria2c -c -x 16 --all-proxy $env:https_proxy @args
    if ($LASTEXITCODE -eq 0) {
        Green-Echo "下载完成"
    } else {
        Write-Error "下载失败"
    }
}

function gtrigger {
    & git amend
    & git push -f
    if ($LASTEXITCODE -eq 0) {
        Green-Echo "触发成功"
    } else {
        Write-Error "触发失败"
    }
}


function gitcrd {
    & git clone --recursive --depth 1 @args
    if ($LASTEXITCODE -eq 0) {
        Green-Echo "克隆完成"
    } else {
        Write-Error "克隆失败"
    }
}

function Invoke-ProfileReload {
    . $PROFILE
}

Set-Alias -Name lgit -Value lazygit

function dateunix {
    # 将当前时间转换为 Unix 时间戳
    $unixTimestamp = [System.DateTimeOffset]::Now.ToUnixTimeSeconds()

    # 输出 Unix 时间戳
    Write-Output $unixTimestamp
}

function setpx {
    $env:https_proxy = $args[0]
    $env:http_proxy = $args[0]
    $env:all_proxy = $args[0]
    $env:ftp_proxy = $args[0]
    $env:socks_proxy = $args[0]
    $env:socks5_proxy = $args[0]
    $env:no_proxy = "localhost,10.0.0.0/8,192.168.0.0/16"
}

function unsetpx {
    $env:https_proxy = ""
    $env:http_proxy = ""
    $env:all_proxy = ""
    $env:ftp_proxy = ""
    $env:socks_proxy = ""
    $env:socks5_proxy = ""
    $env:no_proxy = ""
}

function Test-Connection-Tcp {
    param (
        [string]$IP,
        [int]$Port = 80
    )

    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($IP, $Port)
        $tcpClient.Close()
        return $true
    } catch {
        return $false
    }
}

function Test-Connection-Http {
    param (
        [string]$URL
    )

    try {
        $request = [System.Net.WebRequest]::Create($URL)
        $request.Timeout = 5000
        $response = $request.GetResponse()
        $response.Close()
        return $true
    } catch {
        return $false
    }
}

function Test-Connection-Ping {
    param (
        [string]$IP
    )

    try {
        $ping = New-Object System.Net.NetworkInformation.Ping
        $reply = $ping.Send($IP)
        return $reply.Status -eq "Success"
    } catch {
        return $false
    }
}

function testconn {
    $google=Test-Connection-Http "https://www.gstatic.com/generate_204"
    $github=Test-Connection-Http "https://www.github.com/favicon.ico"
    if ($google -and $github) {
        Green-Echo "网络连接正常"
    } else {
        Red-Echo "网络连接异常"
    }
}

function ghcrd {
    gh repo clone @args -- --depth 1 --recursive
}