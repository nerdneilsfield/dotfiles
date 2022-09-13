# ===================================================================
# check tools exist
# ===================================================================

if ! type fzf > /dev/null; then
	echo fzf not found! use 'install_fzf' to install.
fi

if ! type rg > /dev/null; then
	echo rg not found! use 'install_ripgrep' to install.
fi

if ! type fd > /dev/null; then
	echo fd not found! use 'install_fd' to install.
fi

if ! type bat > /dev/null; then
	echo bat not found! use 'install_bat' to install.
fi

if ! type lazygit > /dev/null; then
	echo lazygit not found! use 'install_lazygit' to install.
fi

if ! type nvim > /dev/null; then
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
# update_nvim () {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export NVIM_REPO=$GITHUB_LOCATION/neovim/neovim
# 	if [ ! -d "$NVIM_REPO" ]; then
# 		git clone https://github.com/neovim/neovim.git $NVIM_REPO
# 	fi
# 	cd $NVIM_REPO
# 	git pull origin master
# 	sudo make CMAKE_BUILD_TYPE=Release
# 	sudo make install
# 	cd -
# 	nvim --version
# }
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

chtsh(){
  curl cht.sh/$1/$2
}


install_nvchad() {
	git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
}

install_neofetch(){
  wget -O ~/.local/bin/neofetch "https://github.com/dylanaraps/neofetch/raw/master/neofetch"
  chmod +x ~/.local/bin/neofetch
}

backup_nvim() {
  local _now_date=$(date +'%Y-%m-%d-%S')
  echo "now_date ${_now_date}"
  mv ~/.config/nvim  "~/.config/nvim_back_${_now_date}"
}

install_rust_built_local_tools(){
  cargo install cargo-quickinstall
  local _tools=(
    "tokei"
    "boringtun-cli"
    "hyperfine"
    "mdbook"
    "navi"
    "czkawka_cli"
    "broot"
    "xsv"
  )

  for _rust_tool in $_tools; do
    echo install $_rust_tool
    cargo quickinstall $_rust_tool
  done
}

install_python_related_local_tools() {
  # python3 -m pip install -U pip
  local _python_tools=(
    "glances"
    "tldr"
  )
  for _python_tool in $_python_tools; do
      echo install _python_tool
      python3 -m pip install --user $_python_tool
    done
}

install_modertools_local() {
  install_neofetch
  install_rust_built_local_tools
  install_python_related_local_tools
}

#=======================
#=====git diff difft====
export GIT_EXTERNAL_DIFF=difft

