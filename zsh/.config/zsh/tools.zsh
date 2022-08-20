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

install_fzf_shell() {
	setpx
	set -e
	set -o xtrace
	export FZF_REPO=$HOME/.fzf
	if [ ! -d "$FZF_REPO" ]; then
		git clone https://github.com/junegunn/fzf.git $FZF_REPO
	fi 
	cd $FZF_REPO
	git pull origin master
	#$FZF_REPO/install
	rm -rf $FZF_REPO/bin
	cd -
}


install_fzf () {
	setpx
	set -e
	set -o xtrace
	export FZF_REPO=$GITHUB_LOCATION/junegunn/fzf
	if [ ! -d "$FZF_REPO" ]; then
		git clone https://github.com/junegunn/fzf.git $FZF_REPO
	fi 
	cd $FZF_REPO
	git pull origin master
	$FZF_REPO/install
	cd -
	fzf --version
}

install_ripgrep () {
	setpx
	set -e
	set -o xtrace
	export RG_REPO=$GITHUB_LOCATION/BurntSushi/ripgrep
	if [ ! -d "$RG_REPO" ]; then
		git clone https://github.com/BurntSushi/ripgrep.git $RG_REPO
	fi 
	cd $RG_REPO
	git pull origin master
	cargo build --release
	mkdir -p $LOCAL_BIN
	ln -sf $GITHUB_LOCATION/BurntSushi/ripgrep/target/release/rg $LOCAL_BIN
	rg --version
}

install_fd () {
	setpx
	set -e
	set -o xtrace
	export FD_REPO=$GITHUB_LOCATION/sharkdp/fd
	if [ ! -d "$FD_REPO" ]; then
		git clone https://github.com/sharkdp/fd.git $FD_REPO
	fi 
	cd $FD_REPO
	git pull origin master
	cargo build --release
	mkdir -p $LOCAL_BIN
	ln -sf $GITHUB_LOCATION/sharkdp/fd/target/release/fd $LOCAL_BIN
	fd --version
}

install_bat () {
	setpx
	set -e
	set -o xtrace
	export BAT_REPO=$GITHUB_LOCATION/sharkdp/bat
	if [ ! -d "$BAT_REPO" ]; then
		git clone https://github.com/sharkdp/bat.git $BAT_REPO
	fi
	cd $BAT_REPO
	cargo build --release
	mkdir -p $LOCAL_BIN
	ln -sf $GITHUB_LOCATION/sharkdp/bat/target/release/bat $LOCAL_BIN
	bat --version
}

install_gitui () {
	setpx
	set -e
	set -o xtrace
	export GITUI_REPO=$GITHUB_LOCATION/extrawurst/gitui
	if [ ! -d "$GITUI_REPO" ]; then
		git clone https://github.com/extrawurst/gitui.git $GITUI_REPO
	fi
	cd $GITUI_REPO
	cargo build --release
	mkdir -p $LOCAL_BIN
	ln -sf $GITHUB_LOCATION/extrawurst/gitui/target/release/gitui $LOCAL_BIN
	gitui --version
}

install_tpm () {
	setpx
	set -e
	set -o xtrace
	export TPM_REPO=$GITHUB_LOCATION/tmux-plugins/tpm
	if [ ! -d "$TPM_REPO" ]; then
		git clone https://github.com/tmux-plugins/tpm.git $TPM_REPO
	fi
}

install_lazygit() {
	setproxy
	set -e
	set -o xtrace
	go get -d github.com/jesseduffield/lazygit
}

update_nvim () {
	setpx
	set -e
	set -o xtrace
	export NVIM_REPO=$GITHUB_LOCATION/neovim/neovim
	if [ ! -d "$NVIM_REPO" ]; then
		git clone https://github.com/neovim/neovim.git $NVIM_REPO
	fi
	cd $NVIM_REPO
	git pull origin master
	sudo make CMAKE_BUILD_TYPE=Release
	sudo make install
	cd -
	nvim --version
}

update_vim () {
	setpx
	set -e
	set -o xtrace
	export VIM_REPO=$GITHUB_LOCATION/vim/vim
	if [ ! -d "$VIM_REPO" ]; then
		git clone https://github.com/vim/vim.git $VIM_REPO
	fi
	cd $VIM_REPO
	git pull origin master
	# https://github.com/vim/vim/blob/master/src/INSTALL
	make 
	sudo make install
	cd -
	vim --version
}



go_tools () {
	cd $HOME/Source/app
	setproxy
	export GOPROXY=https://goproxy.io 
	# gopls
	local _gogettools=(
		"golang.org/x/tools/gopls@latest"
		"github.com/uudashr/gopkgs/cmd/gopkgs"
		"github.com/ramya-rao-a/go-outline"
		"github.com/haya14busa/goplay/cmd/goplay"
		"github.com/fatih/gomodifytags"
		"github.com/josharian/impl"
		"github.com/cweill/gotests/..."
		"github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
		"golang.org/x/tools/cmd/goimports"
	)

	echo $PWD
	echo update go get tools
	for _gogettool in $_gogettools; do
		echo update go get tools: $_gogettool
		GO111MODULE=on go get -u $_gogettool
	done

	local -A _gotools=(
		"go-delve/delve" "go-delve/delve/cmd/dlv"
	)
	
	echo update go install tools
	for k v (${(kv)_gotools}) {
		echo update go install tools: $k
		local local_location=$GITHUB_LOCATION/$k
		local repo_url=https://github.com/$k
		if [ ! -d "$local_location" ]; then
			git clone $repo_url $local_location
		fi
		cd $local_location
		go install github.com/$v
	}
}

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


install_nvchad() {
	git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
}