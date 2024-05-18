function Install-Rust {
    scoop install rustup
    rustup install stable
}

function Install-RustTools {
    cargo install cargo-quickinstall

    cargo install cargo-binstall

    $rust_tools=@(
        "cargo-edit"
        "cargo-outdated"
        "cargo-release"
        "cargo-tarpaulin"
        "cargo-tree"
        "cargo-update"
        "cargo-watch"
        "watchexec-cli"
        "cargo-audit"
        "cargo-generate"
        "cargo-zigbuild"
    )
        # 循环安装每个工具
    foreach ($tool in $rust_tools) {
        Green-Echo "=======install $tool========="
        cargo-binstall --no-confirm $tool
    }
}


function Set-Rust-China-Env {
    $env:RUSTUP_DIST_SERVER = "https://mirrors.ustc.edu.cn/rust-static"
    $env:RUSTUP_UPDATE_ROOT = "https://mirrors.ustc.edu.cn/rust-static/rustup"
    # 定义要写入的内容
    $content = @"
[source.crates-io]
replace-with = 'mirror'

[source.mirror]
registry = "sparse+https://mirrors.tuna.tsinghua.edu.cn/crates.io-index/"
"@

    # 定义目标文件路径
    $configPath = "$env:CARGO_HOME\config.toml"

    # 将内容写入目标文件
    $content | Out-File -FilePath $configPath -Encoding UTF8

    # 输出确认信息
    Green-Echo "配置文件已写入 $configPath"
}