function Install-Basic-Tools
{
    $tools=@(
        "fzf",
        "ripgrep",
        "fd",
        "bat",
        "eza",
        "lazygit",
        "just",
        "fastfetch",
        "gh",
        "duf",
        "gdu",
        "ripgrep",
        "tokei",
        "onefetch",
        "git-cliff",
        "procs",
        "grex",
        "tealdeer",
        "yazi",
        "navi",
        "difftastic",
        "gping",
        # "rm-improved",
        # "bandwhich",
        "hexyl",
        # "inlyne",
        "dust",
        "himalaya",
        "xh",
        # "killport",
        "czkawka",
        "dprint",
        "fselect",
        "dog",
        # "choose",
        "xsv",
        "bottom",
        "trippy",
        "sops",
        "typos",
        "dnslookup",
        "ast-grep",
        "jq",
        "rclone",
        "restic",
        "nali",
        "qsv",
        "dufs"
    )
    foreach ($tool in $tools)
    {
        Green-Echo "=======install $tool========="
        scoop install $tool
    }
}

function Install-Basic-Tools-In-Rust
{
    $tools=@(
        "rm-improved",
        "bandwhich",
        "inlyne",
        "killport",
        "choose",
        "hck"
    )
    foreach ($tool in $tools)
    {
        Green-Echo "=======install $tool========="
        cargo binstall $tool
    }
}

function Install-Gui-Tools
{
    $tools=@(
        "putty",
        "winscp",
        "mobaxterm",
        "filezilla",
        "windirstat",
        "everything",
        "listary",
        "bandizip",
        "Flow-Launcher"
    )

    foreach ($tool in $tools)
    {
        Green-Echo "=======install $tool========="
        scoop install $tool
    }
}


function Extract-7Zip
{
    param (
        [string]$in,  # 压缩文件路径
        [string]$out,     # 输出目录
        [string]$password = $null  # 解压密码
    )

    # 7-Zip 可执行文件的路径
    $sevenZipExecutable = "7z.exe"

    # 检查 7-Zip 可执行文件是否存在
    if (-Not (Get-Command $sevenZipExecutable -ErrorAction SilentlyContinue))
    {
        Write-Error "7-Zip 可执行文件未找到，请检查路径：$sevenZipExecutable"
        return
    }

    # 创建输出目录（如果不存在）
    if (-Not (Test-Path $out))
    {
        New-Item -ItemType Directory -Path $out | Out-Null
    }

    # 调用 7-Zip 解压缩文件
    & $sevenZipExecutable x "$in" -o"$out" -p$password -y

    # 检查解压缩结果
    if ($LASTEXITCODE -eq 0)
    {
        Green-Echo "文件解压缩成功：$in 到 $out"
    } else
    {
        Write-Error "文件解压缩失败：$in"
    }
}

# 定义函数调用 7-Zip 压缩文件或文件夹
function Compress-7Zip
{
    param (
        [string]$in,  # 要压缩的文件或文件夹路径
        [string]$out,  # 输出压缩文件路径
        [string]$password = $null  # 压缩密码
    )

    # 7-Zip 可执行文件的路径
    $sevenZipExecutable = "7z.exe"

    # 检查 7-Zip 可执行文件是否存在
    if (-Not (Get-Command $sevenZipExecutable -ErrorAction SilentlyContinue))
    {
        Write-Error "7-Zip 可执行文件未找到，请检查路径：$sevenZipExecutable"
        return
    }

    # 检查源文件或文件夹是否存在
    if (-Not (Test-Path $in))
    {
        Write-Error "源文件或文件夹未找到：$in"
        return
    }

    # 调用 7-Zip 压缩文件或文件夹
    & $sevenZipExecutable a "$out" "$in" -p$password -y

    # 检查压缩结果
    if ($LASTEXITCODE -eq 0)
    {
        Green-Echo "文件或文件夹压缩成功：$in 到 $out"
    } else
    {
        Write-Error "文件或文件夹压缩失败：$in"
    }
}
