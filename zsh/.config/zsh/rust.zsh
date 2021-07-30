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
    setproxy
	set -e
	set -o xtrace
    echo "Installing rustup...."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
}