# rust related config

export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUST_SRC_DIR=~/.cargo/bin

# rust
alias cbd='cargo build'
alias cbr='cargo build --release'
alias cr='cargo run'
alias cf='cargo fmt'
alias ct='cargo test'
alias cins="cargo_install"

# @brief Install Rust package using cargo with intelligent fallback
# @param $1 Package name to install
# @return 0 on success
# @example cargo_install ripgrep
# @category rust
cargo_install(){
  local CODENAME=$(lsb_release -c | awk '{print $2}')
  # if codename is bionic or xenial
  local _install_command="binstall"
  if [[ $CODENAME == "bionic" || $CODENAME == "xenial" ]]; then
    _install_command="install"
  fi
  cargo $_install_command -y $1
}

# @brief Install Rustup toolchain manager intelligently
# @return 0 on success
# @example install_rustup
# @category rust
install_rustup(){
    echo "🦀 智能安装 Rustup (Rust 工具链管理器)..."
    
    # 使用智能安装系统
    if command -v install_smart_tool >/dev/null 2>&1; then
        install_smart_tool rustup
    else
        # 回退到传统方法
        echo "⚠️  智能安装系统未加载，使用传统方法..."
        local pm=$(get_package_manager 2>/dev/null || echo "unknown")
        
        case "$pm" in
            "brew")
                echo "📦 通过 Homebrew 安装..."
                brew install rustup-init
                rustup-init -y
                ;;
            "pacman")
                echo "📦 通过 Pacman 安装..."
                sudo pacman -S rustup
                ;;
            *)
                # Ubuntu/CentOS 等系统使用官方脚本
                if ! command -v rustup &> /dev/null; then
                    echo "📦 使用官方脚本安装 rustup..."
                    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                else
                    echo "✅ rustup 已安装，更新中..."
                    rustup self update
                fi
                ;;
        esac
    fi
}

# @brief Install Rust language server for IDE support
# @return 0 on success
# @example install_rust_analyzer
# @category rust
install_rust_analyzer(){
  # rust lsp
  rustup component add rust-analyzer
}

# @brief Install essential Rust development tools and cargo extensions
# @return 0 on success
# @example install_rust_tools
# @category rust
install_rust_tools() {
  # some cargo extension
  cargo install cargo-quickinstall
  cargo quickinstall cargo-binstall
  local tools=(
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
  for tool in ${tools[@]}; do
    green_echo "---install $tool---"
    cargo_install $tool
  done
  install_rust_analyzer
}

# @brief Install TOML language server for configuration files
# @return 0 on success
# @example install_toml_lsp
# @category rust
install_toml_lsp() {
  npm install -g @taplo/cli
}

# @brief Configure cargo to use Chinese mirrors for faster downloads
# @return 0 on success
# @example set_cargo_mirrors
# @category rust
set_cargo_mirrors() {
  echo "[source.crates-io]\nreplace-with = 'mirror'\n\n[source.mirror]\nregistry = \"sparse+https://mirrors.tuna.tsinghua.edu.cn/crates.io-index/\"" | tee $HOME/.cargo/config.toml
}

# @brief Configure rustup to use Chinese mirrors for toolchain downloads
# @return 0 on success
# @example set_rustup_mirrors
# @category rust
set_rustup_mirrors() {
  export RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup
  export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
  echo "[source.crates-io]\nreplace-with = 'mirror'\n\n[source.mirror]\nregistry = \"https://mirrors.ustc.edu.cn/crates.io-index/\"" | tee $HOME/.cargo/config.toml
}

# 使用缓存的地区检查来设置镜像
if check_in_china; then
  export RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup
  export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
fi
