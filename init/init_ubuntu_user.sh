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
	# su $GLOABAL_USER
	#CheckNotRoot
	git clone https://github.com/nvm-sh/nvm.git ~/.config/nvm 
	source ~/.config/nvm/nvm.sh
	nvm ls-remote
	nvm install --lts
}


function InstallRust() {
	echo "----install rustup ------"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

function InstallGoTools() {
	echo "-----install golang toolchain ------"
}

function InstallDoomEmacs() {
	git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
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
