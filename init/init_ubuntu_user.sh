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
  cargo install quickinstall
}

function InstallGoTools() {
	echo "-----install golang toolchain ------"
}

function InstallDoomEmacs() {
	git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
}

function InstallHow2() {
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	echo "--------Install How2 From npm -----------------"
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
  # check a npm is installed
  nvm
  if ! which npm > /dev/null; then
    echo "npm is not installed"
    exit 1
  fi
  npm install -g how2
}

function InstallTldr() {
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	echo "--------Install tldr From pip -----------------"
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
  if ! which python3 > /dev/null; then
    echo "python3 is not installed"
    exit 1
  fi
  python3 -m pip install --user tldr
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
