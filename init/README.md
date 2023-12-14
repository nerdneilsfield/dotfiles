# Init Scripts

Some init scripts for different platforms.

1. Change the mirror of software manager for fast speed in China
2. Install some basic package
   1. `git` and `git-lfs` and `gitui` and `lazygit` and `hg` and `svn`
   2. `vim` and `nvim`
   3. `gcc` and `cmake` and another build toolchains
   4. `tmux` and `screen`
   5. `python3` and `pip`
   6. `top`, `bottom`, `vtop`, `ncdu` for performance monitor
   7. `fd`, `fzf`, `ripgrep`, `exa`, `lsd` and `bat`

## Initialize Ubuntu

```bash
# run in sudo
# if in china
wget https://ghproxy.dengqi.org/https://github.com/nerdneilsfield/dotfiles/raw/mac/init/init_ubuntu_root_proxy.sh
source init_ubuntu_root_proxy.sh
# if outside china
wget https://github.com/nerdneilsfield/dotfiles/raw/mac/init/init_ubuntu_root.sh
source init_ubuntu_root.sh

# Change the mirror of software manager for fast speed in China
ChangeMirror
# Update system
UpdateSystem
# Install baisic software
InstallBasic
# Install Network software
InstallNetworkTools
# Install c++/c build essential toolchains
InstallBuildEssential
# Install docker
InstallDocker
# Install Some modern tools
InstallModernTools
# Install neovim editor
InstallNeovimGithub
# Install ros2
InstallRos2
# Add user
AddUser [your username]
```
