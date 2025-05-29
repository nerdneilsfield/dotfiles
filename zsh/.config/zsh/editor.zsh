export NVIMRUNTIME="${HOME}/.local/share/nvim/runtime"

# @brief Compare Neovim versions between source build and system
# @return 0 on success
# @example check_nvim_version
# @category editor
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

# @brief Install Neovim from source code
# @return 0 on success
# @example install_nvim_source
# @category editor
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

# @brief Install stable Neovim release from GitHub
# @return 0 on success
# @example install_nvim_release
# @category editor
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

# @brief Install Neovim release using GitHub proxy for faster download
# @return 0 on success
# @example install_nvim_release_proxy
# @category editor
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

# @brief Install Kakoune editor from source
# @return 0 on success
# @example install_kakoune
# @category editor
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

# @brief Backup current Neovim configuration
# @return 0 on success
# @example backup_nvim
# @category editor
backup_nvim() {
	local _now_date=$(date +'%Y_%m_%d_%S')
	echo "now_date ${_now_date}"
	mv ~/.config/nvim "$HOME/.config/nvim_back_${_now_date}"
}

# @brief Backup all Neovim data folders
# @return 0 on success
# @example backup_nvim_folder
# @category editor
backup_nvim_folder() {
	local _now_date=$(date +'%Y_%m_%d_%S')
	echo "now_date ${_now_date}"
	mv $HOME/.local/share/nvim "$HOME/.local/share/nvim.bak_back_${_now_date}"
	mv $HOME/.local/state/nvim "$HOME/.local/state/nvim.bak_back_${_now_date}"
	mv $HOME/.cache/nvim "$HOME/.cache/nvim.bak_back_${_now_date}"
}

# @brief Install NvChad Neovim configuration
# @return 0 on success
# @example install_nvchad
# @category editor
install_nvchad() {
	git clone --recursive --depth 1 https://github.com/NvChad/NvChad ~/.config/NvChad
	rm -rf ~/.config/NvChad/lua/custom/chadrc.lua
}

install_astro() {
	# git clone  --recursive --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/AstroNvim
}

# @brief Install Kickstart.nvim configuration
# @return 0 on success
# @example install_kickstart
# @category editor
install_kickstart() {
	git clone --recursive --depth 1 https://github.com/nvim-lua/kickstart.nvim.git ~/.config/kickstart
}

# @brief Install LazyVim Neovim configuration
# @return 0 on success
# @example install_lazyvim
# @category editor
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

# @brief Install all popular Neovim configurations
# @return 0 on success
# @example install_nvims
# @category editor
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

# @brief Install Vim editor from source
# @return 0 on success
# @example install_vim
# @category editor
install_vim(){
	mkdir -p ~/Source/app/vim 
	git clone https://github.com/vim/vim.git ~/Source/app/vim/vim
	cd ~/Source/app/vim/vim
	./configure
	make -j $(nproc)
	sudo make install
}

# @brief Install GitHub Copilot plugin for Vim
# @return 0 on success
# @example install_vim_copilot
# @category editor
install_vim_copilot(){
	mkdir -p ~/.vim/pack/github/start
	git clone https://github.com/github/copilot.vim.git \
  	~/.vim/pack/github/start/copilot.vim
}

# @brief Uninstall system-wide Neovim installation
# @return 0 on success
# @example uninstall_nvim_sudo
# @category editor
uninstall_nvim_sudo() {
	sudo find /usr/local -name nvim -exec rm -rf {} \;
}

# @brief Uninstall local Neovim installation
# @return 0 on success
# @example uninstall_nvim
# @category editor
uninstall_nvim() {
	sudo find $HOME/.local -name nvim -exec rm -rf {} \;
}

# @brief Install Helix editor intelligently
# @return 0 on success
# @example install_helix
# @category editor
install_helix(){
    echo "🚀 智能安装 Helix 编辑器..."
    
    # 使用智能安装系统
    if command -v install_smart_tool >/dev/null 2>&1; then
        install_smart_tool helix
        return $?
    fi
    
    # 回退到传统方法
    echo "⚠️  智能安装系统未加载，使用传统方法..."
	green_echo "======================================"
	green_echo "=========Install helix========"
	green_echo "======================================"
	local _helix_version=$(GetLatestReleaseWithRetryProxy "helix-editor/helix")
	local _arch=$(uname -m)
	local _helix_url="https://ghproxy.dengqi.org/https://github.com/helix-editor/helix/releases/download/${_helix_version}/helix-${_helix_version}-${_arch}-linux.tar.xz"
	mkdir -p ~/Source/app/helix
	cd ~/Source/app/helix
	rm -rf helix-${_helix_version}-${_arch}-linux
	rm -rf helix.tar.xz
	wget -O helix.tar.xz $_helix_url
	tar -xf helix.tar.xz
	mkdir -p $HOME/.local/share/helix
	rm -rf $HOME/.local/share/helix/*
	mv helix-${_helix_version}-${_arch}-linux/* $HOME/.local/share/helix
	ln -sf $HOME/.local/share/helix/hx $HOME/.local/bin/hx
	sudo ln -sf $HOME/.local/share/helix/hx /usr/local/bin/hx
	rm -rf helix.tar.xz
}

