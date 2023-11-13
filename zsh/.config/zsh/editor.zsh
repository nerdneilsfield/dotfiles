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
	git clone  --recursive --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/AstroNvim
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

# function nvims() {
# 	items=("default" "kickstart" "LazyVim" "NvChad" "AstroNvim")
# 	config=$(printf "%s\n" "${items[@]}" | fzf --prompt="Neovim Config" --height=~50% --layout=reverse --border --exit-0)
# 	if [[ -z $config ]]; then
# 		echo "Nothing selected"
# 		return 0
# 	elif [[ $config == "default" ]]; then
# 		config=""
# 	fi
# 	NVIM_APPNAME=$config nvim $@
# }

# bindkey -s ^a "nvims\n"
#

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

uninstall_nvim() {
	sudo find /usr/local -name nvim -exec rm -rf {} \;
}
