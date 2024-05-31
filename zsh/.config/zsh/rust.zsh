# rust related config

export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUST_SRC_DIR=~/.cargo/bin

# rust
alias cbd='cargo build'
alias cbr='cargo build --release'
alias cr='cargo run'
alias cf='cargo fmt'
alias ct='cargo test'
alias cins="cargo-install"

cargo_install(){
  local CODENAME=$(lsb_release -c | awk '{print $2}')
  # if codename is bionic or xenial
  local _install_command="binstall"
  if [[ $CODENAME == "bionic" || $CODENAME == "xenial" ]]; then
    _install_command="install"
  fi
  cargo $_install_command $1
}

install_rustup(){
    # setproxy
	set -e
	set -o xtrace
  echo "Installing rustup...."
  curl https://sh.rustup.rs -sSf | sh -s -- -y
}

install_rust_analyzer(){
  # rust lsp
  # rustup component add rust-analyzer
  mkdir -p $HOME/.local/bin
  curl -L https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer
  chmod +x $HOME/.local/bin/rust-analyzer

}

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

install_toml_lsp() {
  npm install -g @taplo/cli
}

set_cargo_mirrors() {
  echo "[source.crates-io]\nreplace-with = 'mirror'\n\n[source.mirror]\nregistry = \"sparse+https://mirrors.tuna.tsinghua.edu.cn/crates.io-index/\"" | tee $HOME/.cargo/config.toml
}

set_rustup_mirrors() {
  export RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup
  export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
  echo "[source.crates-io]\nreplace-with = 'mirror'\n\n[source.mirror]\nregistry = \"https://mirrors.ustc.edu.cn/crates.io-index/\"" | tee $HOME/.cargo/config.toml
}


export RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup
export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
