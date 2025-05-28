# @brief Install Nix package manager
# @return 0 on success
# @example install-nix
# @category nix
install-nix() {
  curl -L https://nixos.org/nix/install | sh
}

# @brief Install Nix using Chinese mirror for faster download
# @return 0 on success
# @example install-nix-china
# @category nix
install-nix-china(){
 sh <(curl https://mirrors.tuna.tsinghua.edu.cn/nix/latest/install)
}

# @brief Uninstall Nix package manager completely
# @return 0 on success
# @example uninstall-nix
# @category nix
uninstall-nix() {
  sudo rm -rf /nix
}

# @brief Update Nix channels and packages
# @return 0 on success
# @example update-nix
# @category nix
update-nix() {
  nix-channel --update
  nix upgrade-nix
  nix-env -u
}

# @brief Update Nix using Chinese mirrors
# @return 0 on success
# @example update-nix-china
# @category nix
update-nix-china(){
  nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable nixpkgs
  nix-channel --update
  nix upgrade-nix
  nix-env -u
}

# @brief Configure Nix to use Tsinghua mirrors
# @return 0 on success
# @example set-nix-channel-tuna
# @category nix
set-nix-channel-tuna() {
  nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable nixpkgs
  nix-channel --update

  # use tee to write to file
  echo "substituters = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" > $HOME/.config/nix/nix.conf
}
