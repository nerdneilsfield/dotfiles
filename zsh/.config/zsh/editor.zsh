
install_nvim() {
	set -e
	# set -o xtrace

	# install dependencies
	pki gettext libtool-bin

	export NVIM_REPO=https//github.com/neovim/neovim
	local NVIM_REPO=$HOME/Source/app/neovim
	if [ ! -d "$NVIM_REPO" ]; then
		git clone --depth 1 https://github.com/neovim/neovim.git $NVIM_REPO
	fi
	cd $NVIM_REPO
	git pull origin master
	rm -rf build
	make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/usr/local -j $(nproc)
	sudo make install
	cd -
	nvim --version
}

uninstall_nvim() {
	sudo find /usr/local -name nvim -exec rm -rf {} \;
}