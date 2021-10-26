#!/usr/bin/env bash


function MakeLocalDirectory {
	mkdir -p ~/.local/bin
	mkdir -p ~/.local/lib
	mkdir -p ~/.local/share
	mkdir -p ~/Source/configs
	mkdir -p ~/.config
	mkdir -p ~/.ssh
}


function GenLocalSSHKey() {
	echo "-----generate local ssh key---------"
	ssh-keygen -b 4096 -t ed25519

	cat ~/.ssh/id_ed25519.pub
	
	echo "please copy the public key"
	read $text
}


function InstallNvm() {
	su $GLOABAL_USER
	CheckNotRoot
	git clone https://github.com/nvm-sh/nvm.git ~/.config/nvm 
}


function InstallRust() {
	echo "----install rustup ------"
}

function InstallGoTools() {
	echo "-----install golang toolchain ------"
}

function InstallDoomEmacs() {
}

function SetFcitxAsDefault() {
	tee ~/.xprofile 2>&1 << EOF
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
fcitx&
EOF
im-config -n fcitx
echo "Please relogin to make it work"
}

function CloneConfigs() {
	cd ~/Source/configs/
	gh repo clone nerdneilsfield/dotfiles
	gh repo clone nerdneilsfield/private_dotfiles
	
	cd ~/Source/configs/dotfiles
	stow -vt ~ zsh
	cd ~/Source/confgis/private_dotfiles
}


function main() {
	MakeLocalDirectory
	InstallNvm
	GenLocalSSHKey
}
