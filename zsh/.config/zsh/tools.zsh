# ===================================================================
# check tools exist
# ===================================================================

if ! type fzf >/dev/null; then
  echo fzf not found! use 'install_fzf' to install.
fi

if ! type rg >/dev/null; then
  echo rg not found! use 'install_ripgrep' to install.
fi

if ! type fd >/dev/null; then
  echo fd not found! use 'install_fd' to install.
fi

if ! type bat >/dev/null; then
  echo bat not found! use 'install_bat' to install.
fi

if ! type lazygit >/dev/null; then
  echo lazygit not found! use 'install_lazygit' to install.
fi

if ! type nvim >/dev/null; then
  echo nvim not found! use 'update_nvim' to install.
fi

export GITHUB_LOCATION="$HOME/Source/app"
export LOCAL_BIN="$HOME/.local/bin/"
export ASDF_DIR="$HOME/.local/share/asdf"

# ===================================================================
# install tools exist
# ===================================================================

# install_fzf_shell() {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export FZF_REPO=$HOME/.fzf
# 	if [ ! -d "$FZF_REPO" ]; then
# 		git clone https://github.com/junegunn/fzf.git $FZF_REPO
# 	fi
# 	cd $FZF_REPO
# 	git pull origin master
# 	#$FZF_REPO/install
# 	rm -rf $FZF_REPO/bin
# 	cd -
# }
#
#
# install_fzf () {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export FZF_REPO=$GITHUB_LOCATION/junegunn/fzf
# 	if [ ! -d "$FZF_REPO" ]; then
# 		git clone https://github.com/junegunn/fzf.git $FZF_REPO
# 	fi
# 	cd $FZF_REPO
# 	git pull origin master
# 	$FZF_REPO/install
# 	cd -
# 	fzf --version
# }
#
# install_ripgrep () {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export RG_REPO=$GITHUB_LOCATION/BurntSushi/ripgrep
# 	if [ ! -d "$RG_REPO" ]; then
# 		git clone https://github.com/BurntSushi/ripgrep.git $RG_REPO
# 	fi
# 	cd $RG_REPO
# 	git pull origin master
# 	cargo build --release
# 	mkdir -p $LOCAL_BIN
# 	ln -sf $GITHUB_LOCATION/BurntSushi/ripgrep/target/release/rg $LOCAL_BIN
# 	rg --version
# }
#
# install_fd () {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export FD_REPO=$GITHUB_LOCATION/sharkdp/fd
# 	if [ ! -d "$FD_REPO" ]; then
# 		git clone https://github.com/sharkdp/fd.git $FD_REPO
# 	fi
# 	cd $FD_REPO
# 	git pull origin master
# 	cargo build --release
# 	mkdir -p $LOCAL_BIN
# 	ln -sf $GITHUB_LOCATION/sharkdp/fd/target/release/fd $LOCAL_BIN
# 	fd --version
# }
#
# install_bat () {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export BAT_REPO=$GITHUB_LOCATION/sharkdp/bat
# 	if [ ! -d "$BAT_REPO" ]; then
# 		git clone https://github.com/sharkdp/bat.git $BAT_REPO
# 	fi
# 	cd $BAT_REPO
# 	cargo build --release
# 	mkdir -p $LOCAL_BIN
# 	ln -sf $GITHUB_LOCATION/sharkdp/bat/target/release/bat $LOCAL_BIN
# 	bat --version
# }
#
# install_gitui () {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export GITUI_REPO=$GITHUB_LOCATION/extrawurst/gitui
# 	if [ ! -d "$GITUI_REPO" ]; then
# 		git clone https://github.com/extrawurst/gitui.git $GITUI_REPO
# 	fi
# 	cd $GITUI_REPO
# 	cargo build --release
# 	mkdir -p $LOCAL_BIN
# 	ln -sf $GITHUB_LOCATION/extrawurst/gitui/target/release/gitui $LOCAL_BIN
# 	gitui --version
# }
#
# install_tpm () {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export TPM_REPO=$GITHUB_LOCATION/tmux-plugins/tpm
# 	if [ ! -d "$TPM_REPO" ]; then
# 		git clone https://github.com/tmux-plugins/tpm.git $TPM_REPO
# 	fi
# }
#
# install_lazygit() {
# 	setproxy
# 	set -e
# 	set -o xtrace
# 	go get -d github.com/jesseduffield/lazygit
# }
#
#
# update_vim () {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export VIM_REPO=$GITHUB_LOCATION/vim/vim
# 	if [ ! -d "$VIM_REPO" ]; then
# 		git clone https://github.com/vim/vim.git $VIM_REPO
# 	fi
# 	cd $VIM_REPO
# 	git pull origin master
# 	# https://github.com/vim/vim/blob/master/src/INSTALL
# 	make
# 	sudo make install
# 	cd -
# 	vim --version
# }

#=======================
# Tool Usage
#=======================

install_fzf_zsh() {

}

export FZF_DEFAULT_COMMAND="fd --exclude={.git,.idea,.vscode,.sass-cache,node_modules,build} --type f"
export FZF_PREVIEW_COMMAND="bat --style=numbers,changes --wrap never --color always {} || cat {} || tree -C {}"
# export FZF_CTRL_T_OPTS="--min-height 30 --preview-window down:60% --preview-window noborder --preview '($FZF_PREVIEW_COMMAND) 2> /dev/null'"
export FZF_COMPLETION_TRIGGER='ll'
# export FZF_DEFAULT_OPTS="--min-height 30 --preview-window down:60% --preview-window noborder --preview '($FZF_PREVIEW_COMMAND) 2> /dev/null'"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview '${FZF_PREVIEW_COMMAND}'"
[ -f ~/.config/zsh/fzf/completion.zsh ] && source ~/.config/zsh/fzf/completion.zsh
[ -f ~/.config/zsh/fzf/key-bindings.zsh ] && source ~/.config/zsh/fzf/key-bindings.zsh

# alias fpreview="fzf --min-height 30 --preview-window down:60% --preview-window noborder --preview '($FZF_PREVIEW_COMMAND) 2> /dev/null'"

# cdf - cd into the directory of the selected file
# # alias cdf="cd $(ls | fzf)"
# alias vif="nvim $(fd --exclude={.git,.idea,.vscode,.sass-cache,node_modules,build} --type f)"

fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

chtsh() {
  curl cht.sh/$1/$2
}

install_tpm(){
  mkdir -p $HOME/.tmux/plugins
  if [[ -d $HOME/.tmux/plugins/tpm ]]; then
    green_echo "=========tpm already installed, updating======"
    cd $HOME/.tmux/plugins/tpm
    git pull
    green_echo "========tpm updated========"
  else
    green_echo "=========installing tpm======"
    git clone --recursive --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    green_echo "=========tpm installed======"
  fi
}

install_neofetch() {
  wget -O ~/.local/bin/neofetch "https://github.com/dylanaraps/neofetch/raw/master/neofetch"
  chmod +x ~/.local/bin/neofetch
}


install_gh(){
  green_echo "======================================"
  green_echo "=========Install gh========"
  green_echo "======================================"
  local _gh_version=$(GetLatestReleaseProxy "cli/cli")
  local _arch=$(uname -m)
  if [[ $_arch == "x86_64" ]]; then
    _arch="amd64"
  fi
  local _gh_url="https://ghproxy.dengqi.org/https://github.com/cli/cli/releases/download/v${_gh_version}/gh_${_gh_version}_linux_${_arch}.tar.gz"

  mkdir -p /tmp/install
  cd /tmp/install
  wget -O gh.tar.gz $_gh_url
  tar -xzf gh.tar.gz
  cd "gh_${_gh_version}_linux_${_arch}"
  mv bin/gh $HOME/.local/bin/
  mkdir -p $HOME/.local/share/man/man1
  cp share/man/man1/* $HOME/.local/share/man/man1/
  sudo rm -rf /usr/local/bin/gh
  sudo cp $HOME/.local/bin/gh /usr/local/bin/gh
}

install_fzf(){
  green_echo "======================================"
  green_echo "=========Install fzf========"
  green_echo "======================================"
  local _fzf_version=$(GetLatestReleaseProxy "junegunn/fzf")
  local _arch=$(uname -m)
  if [[ $_arch == "x86_64" ]]; then
    _arch="amd64"
  fi
  local _fzf_url="https://ghproxy.dengqi.org/https://github.com/junegunn/fzf/releases/download/${_fzf_version}/fzf-${_fzf_version}-linux_${_arch}.tar.gz"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O fzf.tar.gz $_fzf_url
  tar -xzf fzf.tar.gz
  mv fzf $HOME/.local/bin/
  sudo rm -rf /usr/local/bin/fzf
  sudo cp $HOME/.local/bin/fzf /usr/local/bin/fzf
}

install_eza(){
  green_echo "======================================"
  green_echo "=========Install eza========"
  green_echo "======================================"
  local _eza_version=$(GetLatestReleaseProxy "eza-community/eza")
  local _arch=$(uname -m)
  local _eza_url="https://ghproxy.dengqi.org/https://github.com/eza-community/eza/releases/download/v${_eza_version}/eza_${_arch}-unknown-linux-gnu.tar.gz"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O eza.tar.gz $_eza_url
  tar -xzf eza.tar.gz
  mv eza $HOME/.local/bin/
  sudo rm -rf /usr/local/bin/eza
  sudo cp $HOME/.local/bin/eza /usr/local/bin/eza
}

install_lazygit(){
  green_echo "======================================"
  green_echo "=========Install lazygit========"
  green_echo "======================================"
  local _lazygit_version=$(GetLatestReleaseProxy "jesseduffield/lazygit")
  local _arch=$(uname -m)
  local _lazygit_url="https://ghproxy.dengqi.org/https://github.com/jesseduffield/lazygit/releases/download/v${_lazygit_version}/lazygit_${_lazygit_version}_Linux_${_arch}.tar.gz"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O lazygit.tar.gz $_lazygit_url
  tar -xzf lazygit.tar.gz
  mv lazygit $HOME/.local/bin/
  sudo rm -rf /usr/local/bin/lazygit
  sudo cp $HOME/.local/bin/lazygit /usr/local/bin/lazygit
}

install_lazydocker(){
  green_echo "======================================"
  green_echo "=========Install lazydocker========"
  green_echo "======================================"
  local _lazydocker_version=$(GetLatestReleaseProxy "jesseduffield/lazydocker")
  local _arch=$(uname -m)
  local _lazydocker_url="https://ghproxy.dengqi.org/https://github.com/jesseduffield/lazydocker/releases/download/v${_lazydocker_version}/lazydocker_${_lazydocker_version}_Linux_${_arch}.tar.gz"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O lazydocker.tar.gz $_lazydocker_url
  tar -xzf lazydocker.tar.gz
  mv lazydocker $HOME/.local/bin/
  sudo rm -rf /usr/local/bin/lazydocker
  sudo cp $HOME/.local/bin/lazydocker /usr/local/bin/lazydocker
}

install_duf(){
  green_echo "======================================"
  green_echo "=========Install duf========"
  green_echo "======================================"
  local _duf_version=$(GetLatestReleaseProxy "muesli/duf")
  local _arch=$(uname -m)
  # if [[ $_arch == "x86_64" ]]; then
  #   _arch="amd64"
  # fi
  local _duf_url="https://ghproxy.dengqi.org/https://github.com/muesli/duf/releases/download/v${_duf_version}/duf_${_duf_version}_linux_${_arch}.tar.gz"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O duf.tar.gz $_duf_url
  tar -xzf duf.tar.gz
  mv duf $HOME/.local/bin/
  sudo rm -rf /usr/local/bin/duf
  sudo cp $HOME/.local/bin/duf /usr/local/bin/duf
}

install_gdu(){
  green_echo "======================================"
  green_echo "=========Install gdu========"
  green_echo "======================================"
  local _gdu_version=$(GetLatestReleaseProxy "dundee/gdu")
  local _arch=$(uname -m)
  if [[ $_arch == "x86_64" ]]; then
    _arch="amd64"
  fi
  local _gdu_url="https://ghproxy.dengqi.org/https://github.com/dundee/gdu/releases/download/v${_gdu_version}/gdu_linux_${_arch}.tgz"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O gdu.tar.gz $_gdu_url
  tar -xzf gdu.tar.gz
  mv "gdu_linux_${_arch}" $HOME/.local/bin/gdu
  sudo rm -rf /usr/local/bin/gdu
  sudo cp $HOME/.local/bin/gdu /usr/local/bin/gdu
}

install_ripgrep(){
  green_echo "======================================"
  green_echo "=========Install ripgrep========"
  green_echo "======================================"
  local _rg_version=$(GetLatestReleaseProxy "BurntSushi/ripgrep")
  local _arch=$(uname -m)
  # if [[ $_arch == "x86_64" ]]; then
  #   _arch="amd64"
  # fi
  local _rg_url="https://ghproxy.dengqi.org/https://github.com/BurntSushi/ripgrep/releases/download/${_rg_version}/ripgrep-${_rg_version}-${_arch}-unknown-linux-musl.tar.gz"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O rg.tar.gz $_rg_url
  tar -xzf rg.tar.gz
  cd ripgrep-${_rg_version}-${_arch}-unknown-linux-musl
  mv rg $HOME/.local/bin/
  sudo rm -rf /usr/local/bin/rg
  sudo cp $HOME/.local/bin/rg /usr/local/bin/rg
}

install_fd(){
  green_green_echo "======================================"
  green_green_echo "=========Install fd========"
  green_green_echo "======================================"
  local _fd_version=$(GetLatestReleaseProxy "sharkdp/fd")
  local _arch=$(uname -m)
  # if [[ $_arch == "x86_64" ]]; then
  #   _arch="amd64"
  # fi
  local _fd_url="https://ghproxy.dengqi.org/https://github.com/sharkdp/fd/releases/download/v${_fd_version}/fd-v${_fd_version}-${_arch}-unknown-linux-gnu.tar.gz"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O fd.tar.gz $_fd_url
  tar -xzf fd.tar.gz
  cd fd-v${_fd_version}-${_arch}-unknown-linux-gnu
  mv fd $HOME/.local/bin/
  cp fd.1 $HOME/.local/share/man/man1/
  sudo rm -rf /usr/local/bin/fd
  sudo cp $HOME/.local/bin/fd /usr/local/bin/fd
}

install_mise(){
  green_echo "======================================"
  green_echo "=========Install mise========"
  green_echo "======================================"
  local _mise_version=$(GetLatestReleaseProxy "jdx/mise")
  local _arch=$(uname -m)
  if [[ $_arch == "x86_64" ]]; then
    _arch="x64"
  elif [[ $_arch == "aarch64" ]]; then
    _arch="arm64"
  fi
  # https://github.com/jdx/mise/releases/download/v2024.5.16/mise-v2024.5.16-linux-x64-musl.tar.xz
  local _mise_url="https://ghproxy.dengqi.org/https://github.com/jdx/mise/releases/download/v${_mise_version}/mise-v${_mise_version}-linux-${_arch}-musl.tar.xz"
  wget -O /tmp/mise.tar.xz $_mise_url
  tar -xvf /tmp/mise.tar.xz -C $HOME/.local/share
  ln -sf $HOME/.local/share/mise/bin/mise $HOME/.local/bin/mise
}

install_asdf(){
  green_echo "======================================"
  green_echo "=========Install asdf========"
  green_echo "======================================"
  if [[ -d $ASDF_DIR ]]; then
    green_echo "=========asdf already installed, updating======"
    cd $ASDF_DIR
    git pull
    green_echo "========asdf updated========"
  else
    green_echo "=========installing asdf======"
    git clone https://github.com/asdf-vm/asdf.git $ASDF_DIR
    green_echo "=========asdf installed======"
  fi
}


install_modertools_release(){
  install_gh
  install_fzf
  install_eza
  install_lazygit
  install_lazydocker
  install_duf
  install_gdu
  install_ripgrep
  install_fd
}

install_code_server_ubuntu(){
  green_echo "======================================"
  green_echo "=========Install code-server========"
  green_echo "======================================"
  local _code_server_version=$(GetLatestReleaseProxy "coder/code-server")
  local _arch=$(uname -m)
  if [[ $_arch == "x86_64" ]]; then
    _arch="amd64"
  fi
  local _code_server_url="https://ghproxy.dengqi.org/https://github.com/coder/code-server/releases/download/v${_code_server_version}/code-server_${_code_server_version}_${_arch}.deb"

  mkdir -p /tmp/install
  cd /tmp/install
  wget -O code-server.deb $_code_server_url
  sudo apt install ./code-server.deb
  cd -
}

install_modertools_rust() {
  # cargo install cargo-quickinstall
  local _tools=(
    "tokei"
    "boringtun-cli"
    "hyperfine"
    # "mdbook"
    "navi"
    "czkawka_cli" # duplicate file finder
    "broot"
    "xsv"
    # "gping"
    "hexyl" # a hex viewer in command line
    "ffsend"
    "onefetch"
    "mdbook"
    "rustscan"
    # "lemmeknow"
    "xcp" # better cp
    "choose" # cut and awk
    "xh" # an alternative to httpie
    "mdcat" # cat for makrdown
    "rm-improved" # safe rm
    "just" # build system
    "grex" # regex generator
    # "helix" # a better editor
    "bandwhich" # network bandwith monitor
    # "dog" # a dns client
    "bottom"
    "git-cliff" # git-cliff
    "miniserve" # mini http server
    "pastel" # color manager
    "monolith" # save html file to one file
    "tealdeer" # a fast tldr
    "sd" # sed alternative
    "bat"
    "procs"
    "yazi"
    "inlyne"
    "killport"
    "himalaya"
    "dprint"
    "fselect"
    "trippy"
    "hck"
    "aichat"
    "typos-cli"
    "ast-grep"
  )

  for local _rust_tool in $_tools; do
    green_echo "-----------------------------"
    green_echo "------install ${_rust_tool}------"
    cargo_install $_rust_tool
    green_echo "-----------------------------"
  done
}

install_modertools_python() {
  # python3 -m pip install -U pip
  local _python_tools=(
    "glances"
    # "tldr"
    "yt-dlp"
    "gitsome"
    "httpie"
    # "jrnl"
  )
  for _python_tool in $_python_tools; do
    green_echo "install $_python_tool"
    python3 -m pip install --user $_python_tool
  done
}

install_modertools_go() {
  echo "======================================"
  echo "=========Install Modertools Go========"
  echo "======================================"
  local _golang_tools=(
    # "github.com/zulk/nali"
    "moul.io/assh/v2"
    # "github.com/muesli/duf"
    "github.com/rclone/rclone"
    # "github.com/jesseduffield/lazydocker"
	  # "github.com/dundee/gdu/v5/cmd/gdu"
    # "github.com/junegunn/fzf"
  )

  for _golang_tool in $_golang_tools; do
    green_echo "=====install $_golang_tool====="
    go install "${_golang_tool}@latest"
  done
}

install_modertools_local() {
  install_neofetch
  install_modertools_rust
  install_modertools_python
  install_modertools_go
  install_modertools_jq
}

install_modertools_local_by_download(){
  
}

install_modertools_jq() {
  local jq_dir="${HOME}/Source/app/jq"
  mkdir -p  $jq_dir 
	if [ ! -d "$jq_dir" ]; then
		git clone --depth 1 --recursive https://github.com/neovim/neovim.git $jq_dir
	fi
  cd $jq_dir
  git pull origin
  make clean
  make distclean
  autoreconf -i
  ./configure --prefix="${HOME}/.local"
  make -j $(nproc)
  make install
  green_echo "----jq installed----"
}

#=======================
#=====git diff difft====
export GIT_EXTERNAL_DIFF=difft


# use ip address
show_ipv4_addr() {
  # ip addr | grep -E "192.168" | awk '{print $2}' | cut -d "/" --field 1
  ip addr | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"
}


show_ipv6_addr() {
  ip addr | grep -E -o "([0-9a-fA-F]{1,4}:){7}([0-9a-fA-F]{1,4}|:)|([0-9a-fA-F]{1,4}:){6}(:[0-9a-fA-F]{1,4}|:)|([0-9a-fA-F]{1,4}:){5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])"
}

show_ip_addr(){
  show_ipv4_addr
  show_ipv6_addr
}


if [[ -f $HOME/.local/bin/mise ]]; then
  eval "$(mise activate zsh)"
fi

if [[ -d $ASDF_DIR ]]; then
  . $ASDF_DIR/asdf.sh
  fpath=(${ASDF_DIR}/completions $fpath)
  autoload -Uz compinit && compinit
fi
