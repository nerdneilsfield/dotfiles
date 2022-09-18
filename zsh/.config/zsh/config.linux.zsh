alias to='jump'
alias s='sudo systemctl'

export LC_ALL="en_US.UTF-8"

if [  -n "$(ls /etc | grep apt)" ]; then
    echo "Packagemanger apt detect"
    alias pki='sudo apt install'
    alias pkr='sudo apt uninstall'
    alias pku='sudo apt update'
    alias pkd='sudo apt upgrade'
elif [ -n "$(ls /etc | grep pacman)" ]; then
    echo "Packagemanger pacman detect"
    alias pki='sudo pacman -S'
    alias pkr='sudo pacman -R'
    alias pku='sudo pacman -Su'
    alias pkd='sudo pacman -Syyu'
	  #export LANG=C.UTF-8; export LC_CTYPE=C.UTF-8;
elif [ -n "$(ls /etc | grep yum) "];then
    echo "Packagemanger yum detect"
    alias pki='sudo yum install'
    alias pkr='sudo yum remove'
    alias pku='sudo yum update'
    alias pkd='sudo yum upgrade'
fi

# # color
# zstyle :prompt:pure:path color 214
# zstyle :prompt:pure:prompt:error color 160
# zstyle :prompt:pure:prompt:success color 031

install_nvim () {
	setpx
	set -e
	set -o xtrace

    # install dependencies
    sudo apt install gettext libtool-bin

	export NVIM_REPO=https//github.com/neovim/neovim
    local NVIM_REPO=$HOME/Source/app/neovim
	if [ ! -d "$NVIM_REPO" ]; then
		git clone https://github.com/neovim/neovim.git $NVIM_REPO
	fi
	cd $NVIM_REPO
	git pull origin master
	make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/usr/local -j $(nproc)
	sudo make install
	cd -
	nvim --version
# }