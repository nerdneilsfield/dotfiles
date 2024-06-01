install_nix() {
  curl -L https://nixos.org/nix/install | sh
}

install_nix_china(){
 sh <(curl https://mirrors.tuna.tsinghua.edu.cn/nix/latest/install)
}

uninstall_nix() {
  sudo rm -rf /nix
}

update_nix() {
  nix-channel --update
  nix upgrade-nix
  nix-env -u
}

update_nix_china(){
  nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable nixpkgs
  nix-channel --update
  nix upgrade-nix
  nix-env -u
}
