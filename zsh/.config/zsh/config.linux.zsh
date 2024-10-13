alias to='jump'
alias s='sudo systemctl'

export LC_ALL="en_US.UTF-8"
export LINUX_DISTR=""

if [  -n "$(ls /etc | grep apt)" ]; then
    echo "Packagemanger apt detect"
    alias pki='sudo apt install'
    alias pkr='sudo apt uninstall'
    alias pku='sudo apt update'
    alias pkd='sudo apt upgrade'
    source $ZSH_CONF_DIR/config.ubuntu.zsh
    export LINUX_DISTR="ubuntu"
elif [ -n "$(ls /etc | grep pacman)" ]; then
    echo "Packagemanger pacman detect"
    alias pki='sudo pacman -S'
    alias pkr='sudo pacman -R'
    alias pku='sudo pacman -Su'
    alias pkd='sudo pacman -Syyu'
    source $ZSH_CONF_DIR/config.arch.zsh
    export LINUX_DISTR="arch"
	  #export LANG=C.UTF-8; export LC_CTYPE=C.UTF-8;
elif [ -n "$(ls /etc | grep yum) "];then
    echo "Packagemanger yum detect"
    alias pki='sudo yum install'
    alias pkr='sudo yum remove'
    alias pku='sudo yum update'
    alias pkd='sudo yum upgrade'
    source $ZSH_CONF_DIR/config.centos.zsh
    export LINUX_DISTR="centos"
fi

# # color
# zstyle :prompt:pure:path color 214
# zstyle :prompt:pure:prompt:error color 160

# export CC=/usr/bin/clang-16
# export CXX=/usr/bin/clang++-16



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

fw_open_port_udp(){
    # if command firewall-cmd exists
    if command -v firewall-cmd &> /dev/null
    then
        sudo firewall-cmd --zone=public --add-port=$1/udp --permanent
        sudo firewall-cmd --reload
        sudo firewall-cmd --list-ports | grep $1
    else
        echo "firewall-cmd not found"
    fi
}

check_is_ubuntu(){
    # if zorin os also return true
    if [ -f /etc/os-release ] && [[ "$(cat /etc/os-release | grep -i ubuntu)" || "$(cat /etc/os-release | grep -i zorin)" ]]; then
        return 0
    else
        return 1
    fi
}

check_is_debian(){
    if [ -f /etc/os-release ] && [[ "$(cat /etc/os-release | grep -i 'Debian GNU')" ]]; then
        return 0
    else
        return 1
    fi
}

get_ubuntu_codename(){
    if check_is_ubuntu; then
        grep -i "UBUNTU_CODENAME" /etc/os-release | cut -d= -f2 | tr -d '"'
    else
        red_echo "Not ubuntu"
        return 1
    fi
}

get_debian_version(){
    if check_is_debian; then
        grep -i "VERSION=" /etc/os-release | cut -d= -f2 | tr -d '"' | awk '{print $1}'
    else
        red_echo "Not debian"
        return 1
    fi
}

get_debian_codename(){
    local _version=$(get_debian_version)
    case $_version in
        12) echo "bookworm";;
        11) echo "bullseye";;
    esac
}