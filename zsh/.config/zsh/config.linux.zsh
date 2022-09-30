alias to='jump'
alias s='sudo systemctl'

export LC_ALL="en_US.UTF-8"

if [  -n "$(ls /etc | grep apt)" ]; then
    echo "Packagemanger apt detect"
    alias pki='sudo apt install'
    alias pkr='sudo apt uninstall'
    alias pku='sudo apt update'
    alias pkd='sudo apt upgrade'
    source $ZSH_CONF_DIR/config.ubuntu.zsh
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
    source $ZSH_CONF_DIR/config.centos.zsh
fi

# # color
# zstyle :prompt:pure:path color 214
# zstyle :prompt:pure:prompt:error color 160

export CC=/usr/bin/clang-16
export CXX=/usr/bin/clang++-16

install_nvim () {
	set -e
	set -o xtrace

  # install dependencies
  pki gettext libtool-bin

	export NVIM_REPO=https//github.com/neovim/neovim
    local NVIM_REPO=$HOME/Source/app/neovim
	if [ ! -d "$NVIM_REPO" ]; then
		git clone --depth 1 https://github.com/neovim/neovim.git $NVIM_REPO
	fi
	cd $NVIM_REPO
	git pull origin master
	make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/usr/local -j $(nproc)
	sudo make install
	cd -
	nvim --version
}


disable_ipv6() {
    sudo ping
	sudo echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
	sudo echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
	sudo sysctl -p
}


# open the port firewall
fw_open_port_tcp(){
    # if command firewall-cmd exists
    if command -v firewall-cmd &> /dev/null
    then
        sudo firewall-cmd --zone=public --add-port=$1/tcp --permanent
        sudo firewall-cmd --reload
        sudo firewall-cmd --list-ports | grep $1
    else
        echo "firewall-cmd not found"
    fi
}