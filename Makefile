
install:
	echo "You must chose your config version"

install-mac:
	echo "Install the dotfiles of Mac OS...."

install-ubunut-server:
	echo "Install the dotfiles of ubuntu-server ...."

install-arch-server:
	echo "Install the dotfiles of arch-server ...."

install-ubuntu-desktop:
	echo "Install the dotfiles of ubuntu-desktop...."

install-arch-desktop:
	echo "Install the dotfiles of arch-desktop"

install-ubuntu-wsl:
	echo "Install the dotfiles of ubuntu-wsl"

install-windows:
	echo "Install the dotfiles of windows...."

sync:
	git pull

sync-force:
	git pull -f