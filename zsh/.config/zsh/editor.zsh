export VIMRUNTIME="${HOME}/.local/share/nvim/runtime"

check_nvim_version(){
	local source_build_version=$("$HOME/Source/app/neovim/build/bin/nvim" -version)
	local system_default_version=$(nvim -version)
	if [[ "$source_build_version" == "$system_default_version" ]]; then
		green_echo ">>>>Version is same!<<<<<"
		green_echo ">>>>>here is the version:"
		echo "$source_build_version"
	else
		red_echo ">>>>Version is not same<<<<"
		cyan_echo "-------source build version-------"
		echo "$source_build_version"
		cyan_echo "-------system_default_version-----"
		echo "$system_default_version"
	fi
}

install_nvim_source() {
	# install dependencies
	# pki gettext libtool-bin

	#export NVIM_REPO=https//github.com/neovim/neovim
	local NVIM_REPO=$HOME/Source/app/neovim
	if [ ! -d "$NVIM_REPO" ]; then
		git clone --depth 1 --recursive https://github.com/neovim/neovim.git $NVIM_REPO
	fi
	cd $NVIM_REPO
	git pull origin master
	make distclean
	make clean
	rm -rf build
	make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/.local -j $(nproc)
	make install 
	mkdir -p $HOME/.local/share/nvim/runtime
	rm -rf $HOME/.local/share/nvim/runtime/*
	cp -r runtime/* $HOME/.local/share/nvim/runtime/
	cd -
	check_nvim_version
}

install_nvim_release(){
	# install dependencies
	# pki gettext libtool-bin
	echo "-------------------install_nvim_release-------------------"
	export NVIM_REPO="neovim/neovim"
	local NVIM_DIR=$HOME/Source/app/neovim_release
	mkdir -p $NVIM_DIR
	# local NVIM_RELEASE=$(GetLatestRelease $NVIM_REPO)
	# echo "NVIM_RELEASE: $NVIM_RELEASE"
	local NVIM_RELEASE_PATH="${NVIM_DIR}/nvim-linux64.tar.gz"
	echo "NVIM_RELEASE_PATH: $NVIM_RELEASE_PATH"
	wget -O $NVIM_RELEASE_PATH https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz
	tar -xzf $NVIM_RELEASE_PATH -C $NVIM_DIR
	# rm -rf $HOME/.local/share/nvim/runtime/*
	cp -r $NVIM_DIR/nvim-linux64 $HOME/.local/share/
	ln -sf $HOME/.local/share/nvim-linux64/bin/nvim $HOME/.local/bin/nvim
	nvim --version
}

install_nvim_release_proxy(){
	# install dependencies
	# pki gettext libtool-bin
	echo "-------------------install_nvim_release-------------------"
	export NVIM_REPO="neovim/neovim"
	local NVIM_DIR=$HOME/Source/app/neovim_release
	mkdir -p $NVIM_DIR
	# local NVIM_RELEASE=$(GetLatestRelease $NVIM_REPO)
	# echo "NVIM_RELEASE: $NVIM_RELEASE"
	local NVIM_RELEASE_PATH="${NVIM_DIR}/nvim-linux64.tar.gz"
	echo "NVIM_RELEASE_PATH: $NVIM_RELEASE_PATH"
	wget -O $NVIM_RELEASE_PATH https://ghproxy.dengqi.org/https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz
	tar -xzf $NVIM_RELEASE_PATH -C $NVIM_DIR
	# rm -rf $HOME/.local/share/nvim/runtime/*
	cp -r $NVIM_DIR/nvim-linux64 $HOME/.local/share/
	ln -sf $HOME/.local/share/nvim-linux64/bin/nvim $HOME/.local/bin/nvim
	nvim --version
}

install_kakoune(){
	# pki libncurse-dev libstdc++-dev
	KAKOUNE_REPO=https://github.com/mawww/kakoune.git
	local KAKOUNE_DIR=$HOME/Source/app/kakoune
	if [ ! -d "$KAKOUNE_DIR" ]; then
		git clone --depth 1 --recursive $KAKOUNE_REPO $KAKOUNE_DIR
	fi
	cd $KAKOUNE_DIR
	make clean
	make -j $(nproc)
	PREFIX=$HOME/.local make install 
	cd -
	kak -version
}

install_kakoune_lsp(){
	pki libncurse-dev libstdc++-dev
	KAKOUNE_REPO=https://github.com/mawww/kakoune.git
	local KAKOUNE_DIR=$HOME/Source/app/kakoune
	if [ ! -d "$KAKOUNE_DIR" ]; then
		git clone --depth 1 --recursive $KAKOUNE_REPO $KAKOUNE_DIR
	fi
	cd $KAKOUNE_DIR
	make clean
	make -j $(nproc)
	PREFIX=$HOME/.local make install 
	cd -
	kak -version
}

backup_nvim() {
	local _now_date=$(date +'%Y_%m_%d_%S')
	echo "now_date ${_now_date}"
	mv ~/.config/nvim "$HOME/.config/nvim_back_${_now_date}"
}

backup_nvim_folder() {
	local _now_date=$(date +'%Y_%m_%d_%S')
	echo "now_date ${_now_date}"
	mv $HOME/.local/share/nvim "$HOME/.local/share/nvim.bak_back_${_now_date}"
	mv $HOME/.local/state/nvim "$HOME/.local/state/nvim.bak_back_${_now_date}"
	mv $HOME/.cache/nvim "$HOME/.cache/nvim.bak_back_${_now_date}"
}

install_nvchad() {
	git clone --recursive --depth 1 https://github.com/NvChad/NvChad ~/.config/NvChad
	rm -rf ~/.config/NvChad/lua/custom/chadrc.lua
}

install_astro() {
	# git clone  --recursive --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/AstroNvim
}

install_kickstart() {
	git clone --recursive --depth 1 https://github.com/nvim-lua/kickstart.nvim.git ~/.config/kickstart
}

install_lazyvim() {
	git clone --recursive --depth 1 https://github.com/LazyVim/LazyVim.git ~/.config/LazyVim
}

remove_astro() {
	rm -rf ~/.config/AstroNvim
	rm -rf ~/.local/share/AstroNvim
	rm -rf ~/.local/state/AstroNvim
	rm -rf ~/.cache/AstroNvim
}

remove_nvchad() {
	rm -rf ~/.config/NvChad
	rm -rf ~/.local/share/NvChad
	rm -rf ~/.local/state/NvChad
	rm -rf ~/.cache/NvChad
}

install_nvims() {
	install_nvchad
	install_astro
	install_kickstart
	install_lazyvim
}

alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
alias nvim-kick="NVIM_APPNAME=kickstart nvim"
alias nvim-chad="NVIM_APPNAME=NvChad nvim"
alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"
alias nv="nvim-astro"

install_vim(){
	mkdir -p ~/Source/app/vim 
	git clone https://github.com/vim/vim.git ~/Source/app/vim/vim
	cd ~/Source/app/vim/vim
	./configure
	make -j $(nproc)
	sudo make install
}

install_vim_copilot(){
	mkdir ~/.vim/pack/github/start
	git clone https://github.com/github/copilot.vim.git \
  	~/.vim/pack/github/start/copilot.vim
}

uninstall_nvim_sudo() {
	sudo find /usr/local -name nvim -exec rm -rf {} \;
}

uninstall_nvim() {
	sudo find $HOME/.local -name nvim -exec rm -rf {} \;
}

