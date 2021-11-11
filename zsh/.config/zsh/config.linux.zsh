alias to='jump'
alias s='sudo systemctl'

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
	export LANG=C.UTF-8; export LC_CTYPE=C.UTF-8;
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
