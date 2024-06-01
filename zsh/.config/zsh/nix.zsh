install-nix() {
  curl -L https://nixos.org/nix/install | sh
}

install-nix-china(){
 sh <(curl https://mirrors.tuna.tsinghua.edu.cn/nix/latest/install)
}

uninstall-nix() {
  sudo rm -rf /nix
}

update-nix() {
  nix-channel --update
  nix upgrade-nix
  nix-env -u
}

update-nix-china(){
  nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable nixpkgs
  nix-channel --update
  nix upgrade-nix
  nix-env -u
}

set-nix-channel-tuna() {
  nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable nixpkgs
  nix-channel --update

  # use tee to write to file
  echo "substituters = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" > $HOME/.config/nix/nix.conf
}
