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
  cargo install --locked cargo-outdated
  # cross compile
  cargo install cargo-zigbuild
  install_rust_analyzer
}

install_toml_lsp() {
  npm install -g @taplo/cli
}
