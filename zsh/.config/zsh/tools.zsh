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
    echo "=========tpm already installed, updating======"
    cd $HOME/.tmux/plugins/tpm
    git pull
    echo "========tpm updated========"
  else
    echo "=========installing tpm======"
    git clone --recursive --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "=========tpm installed======"
  fi
}

install_neofetch() {
  wget -O ~/.local/bin/neofetch "https://github.com/dylanaraps/neofetch/raw/master/neofetch"
  chmod +x ~/.local/bin/neofetch
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
    "helix" # a better editor
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
  )

  local CODENAME=$(lsb_release -c | awk '{print $2}')
  # if codename is bionic or xenial
  local _install_command="binstall"
  if [[ $CODENAME == "bionic" || $CODENAME == "xenial" ]]; then
    _install_command="install"
  fi

  for _rust_tool in $_tools; do
    echo "-----------------------------"
    echo "------install ${_rust_tool}------"
    echo "$_install_command $_rust_tool"
    cargo $_install_command -y $_rust_tool
    echo "-----------------------------"
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
    echo install $_python_tool
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
    "github.com/muesli/duf"
    "github.com/rclone/rclone"
    "github.com/jesseduffield/lazydocker"
	  "github.com/dundee/gdu/v5/cmd/gdu"
    # "github.com/junegunn/fzf"
  )

  for _golang_tool in $_golang_tools; do
    echo "=====install $_golang_tool====="
    go install "${_golang_tool}@latest"
  done
}

install_modertools_local() {
  install_neofetch
  install_modertools_rust
  install_modertools_python
  install_modertools_go
}

install_modertools_local_by_download(){
  
}

#=======================
#=====git diff difft====
export GIT_EXTERNAL_DIFF=difft


show_ip_addr() {
  ip addr | grep -E "192.168" | awk '{print $2}' | cut -d "/" --field 1
  ip addr | grep -E "10.11" | awk '{print $2}' | cut -d "/" --field 1
  ip addr | grep -E "10.15" | awk '{print $2}' | cut -d "/" --field 1
  ip addr | grep -E "10.19" | awk '{print $2}' | cut -d "/" --field 1
  ip addr | grep -E "10.0." | awk '{print $2}' | cut -d "/" --field 1
  ip addr | grep -E "172." | awk '{print $2}' | cut -d "/" --field 1
}
