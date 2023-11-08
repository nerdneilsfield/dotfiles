# rust related config

export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUST_SRC_DIR=~/.cargo/bin

# rust
alias cb='cargo build'
alias cr='cargo run'
alias cf='cargo fmt'
alias ct='cargo test'
alias cins="cargo install"

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
  cargo binstall --no-confirm cargo-edit cargo-watch cargo-tarpaulin watchexec-cli cargo-outdated cargo-update
  # cross compile
  cargo binstall --no-confirm cargo-zigbuild cargo-generate
  install_rust_analyzer
}

install_toml_lsp() {
  npm install -g @taplo/cli
}

set_cargo_mirrors() {
  echo "[source.crates-io]\nreplace-with = 'mirror'\n\n[source.mirror]\nregistry = \"sparse+https://mirrors.tuna.tsinghua.edu.cn/crates.io-index/\"" | tee $HOME/.cargo/config
}

set_rustup_mirrors() {
  export RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup
  export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
  echo "[source.crates-io]\nreplace-with = 'mirror'\n\n[source.mirror]\nregistry = \"https://mirrors.ustc.edu.cn/crates.io-index/\"" | tee $HOME/.cargo/config
}