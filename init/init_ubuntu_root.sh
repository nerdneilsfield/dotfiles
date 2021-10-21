#!/usr/bin/env bash

GLOBAL_USER=""
GLOBAL_USER_EXISTS=""

function GetLatestRelease() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"v*([^"]+)".*/\1/'
}


function CheckRoot() {
	if (( $EUID != 0 )); then
		echo "Please run as root"
		exit
	fi
}

function CheckNotRoot() {
	if (( $EUID == 0 )); then
		echo "Please do not run the command as root"
		exit
	fi
}


function CheckUserExists() {
	passwd_log=$(cat /etc/passwd | grep $1)

	if (( ${#passwd_log} == 0 )); then
		echo "User $1 not exists"
		GLOBAL_USER_EXISTS=0
		return 0;
	else
		echo "User $1 exists"
		GLOBAL_USER_EXISTS=1
		return 1;
	fi
}


function AddUser() {
	echo "Please enter a username for admin"
	read InputUserName
	GLOBAL_USER=$InputUserName
	exists=$GLOBAL_USER_EXISTS
	echo "Add user $GLOBAL_USER"
	useradd -m -g admin -s /usr/bin/zsh $GLOBAL_USER
	echo "Please enter the password for $GLOBAL_USER"
	passwd $GLOBAL_USER
}

function ChangeMirror(){
	mv /etc/apt/sources.list /etc/apt/sources.list.back
	CODENAME=$(lsb_release -c | awk '{print $2}')
	tee /etc/apt/sources.list &>/dev/null << EOF
deb http://mirrors.ustc.edu.cn/ubuntu/ ${CODENAME} main restricted
deb http://mirrors.ustc.edu.cn/ubuntu/ ${CODENAME}-updates main restricted
deb http://mirrors.ustc.edu.cn/ubuntu/ ${CODENAME} universe
deb http://mirrors.ustc.edu.cn/ubuntu/ ${CODENAME}-updates universe
deb http://mirrors.ustc.edu.cn/ubuntu/ ${CODENAME} multiverse
deb http://mirrors.ustc.edu.cn/ubuntu/ ${CODENAME}-updates multiverse
deb http://mirrors.ustc.edu.cn/ubuntu/ ${CODENAME}-backports main restricted universe multiverse
deb http://mirrors.ustc.edu.cn/ubuntu ${CODENAME}-security main restricted
deb http://mirrors.ustc.edu.cn/ubuntu ${CODENAME}-security universe
deb http://mirrors.ustc.edu.cn/ubuntu ${CODENAME}-security multiverse
EOF
	apt-get update
	apt-get -y install python3-pip
	pip install -U pip wheel
	pip install -U apt-select
	apt-select -C $1 -c -t 3
	mv /etc/apt/sources.list /etc/apt/sources.list_ustc
	mv sources.list /etc/apt/sources.list
	apt update
}

function UpgradeSystem() {
	apt-get update
	apt-get -y upgrade
}


function InstallBasic(){
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	echo "---------------Install Basic From Mirror------------"
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	apt-get install -y wget curl stow gpg zsh htop rsync unzip unrar p7zip openssh-server vim
	apt-get install -y cifs-utils exfat-utils
}

function InstallRos() {
	CODENAME=$(lsb_release -c | awk '{print $2}')
	tee /etc/apt/sources.list.d/ros-latest.list &>/dev/null << EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ros/ubuntu/ ${CODENAME} main
EOF
	apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
	apt-get update
}

function InstallLazyGit(){	
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	echo "---------------Install Lazygit From Github------------"
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	mkdir -p /tmp/install_app && cd /tmp/install_app/
	LAZYGIT_VERSION=$(GetLatestRelease "jesseduffield/lazygit")
	wget -O /tmp/install_app/lazygit_latest.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit_latest.tar.gz && mv lazygit /usr/local/bin/
}

function InstallFzf() {
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	echo "---------------Install Fzf From Github------------"
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	mkdir -p /tmp/install_app && cd /tmp/install_app
	FZF_VERSION=$(GetLatestRelease "junegunn/fzf")
	wget -O /tmp/install_app/fzf_latest.tar.gz "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz"
	tar xf fzf_latest.tar.gz && mv fzf /usr/local/bin
}

function InstallStarShip() {
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	echo "---------------Install StarShip From Github------------"
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	mkdir -p /tmp/install_app && cd /tmp/install_app
	SS_VERSION=$(GetLatestRelease "starship/starship")
	wget -O /tmp/install_app/starship_latest.tar.gz "https://github.com/starship/starship/releases/download/v${SS_VERSION}/starship-x86_64-unknown-linux-musl.tar.gz"
	tar xf starship_latest.tar.gz
	mv starship /usr/local/bin
}

function InstallFd() {
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	echo "---------------Install Fd From Github------------"
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	mkdir -p /tmp/install_app && cd /tmp/install_app
	FD_VERSION=$(GetLatestRelease "sharkdp/fd")
	wget -O /tmp/install_app/fd_latest.tar.gz "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz"
	tar xf fd_latest.tar.gz && cd fd-v${FD_VERSION}-x86_64-unknown-linux-musl
	mkdir -p /usr/local/share/man/man1/
	mv fd /usr/local/bin
	mv fd.1 /usr/local/share/man/man1/
	mv autocomplete/fd.bash-completion  /usr/share/bash-completion/completions
	mv autocomplete/_fd /usr/share/zsh/vendor-completions/
}

function InstallBat() {
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	echo "---------------Install Bat From Github------------"
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	mkdir -p /tmp/install_app && cd /tmp/install_app
	BAT_VERSION=$(GetLatestRelease "sharkdp/bat")
	wget -O /tmp/install_app/bat_latest.tar.gz "https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz"
	tar xf bat_latest.tar.gz && cd bat-v${BAT_VERSION}-x86_64-unknown-linux-musl
	mv bat /usr/local/bin
	mv bat.1 /usr/local/share/man/man1/
	mv autocomplete/bat.bash-completion  /usr/share/bash-completion/completions
	mv autocomplete/_bat /usr/share/zsh/vendor-completions/
}

function InstallExa() {
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	echo "---------------Install Exa From Github------------"
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	mkdir -p /tmp/install_app && cd /tmp/install_app
	EXA_VERSION=$(GetLatestRelease "ogham/exa")
	wget -O /tmp/install_app/exa_latest.zip "https://github.com/ogham/exa/releases/download/v${EXA_VERSION}/exa-linux-x86_64-musl-v${EXA_VERSION}.zip"
	mkdir -p exa && cd exa && unzip ../exa_latest.zip && mv bin/exa /usr/local/bin
}

function InstallGitui() {
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	echo "---------------Install Gitui From Github------------"
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	mkdir -p /tmp/install_app && cd /tmp/install_app
	GITUI_VERSION=$(GetLatestRelease "extrawurst/gitui")
	wget -O /tmp/install_app/gitui_latest.tar.gz "https://github.com/extrawurst/gitui/releases/download/v${GITUI_VERSION}/gitui-linux-musl.tar.gz"
	tar xf gitui_latest.tar.gz && mv gitui /usr/local/bin
}

function InstallRg() {
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	echo "---------------Install Rg From Github------------"
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	mkdir -p /tmp/install_app && cd /tmp/install_app
	RG_VERSION=$(GetLatestRelease "BurntSushi/ripgrep")
	wget -O /tmp/install_app/rg_latest.tar.gz "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz"
	tar xf rg_latest.tar.gz && cd "ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl/"
	mv rg /usr/local/bin
	mv complete/_rg  /usr/share/zsh/vendor-completions/
	mv complete/rg.bash  /usr/share/bash-completion/completions 
}

function InstallGithubCli() {
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	echo "--------Install GithubCli From Github------------"
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	mkdir -p /tmp/install_app && cd /tmp/install_app
	CLI_VERSION=$(GetLatestRelease "cli/cli")
	wget -O /tmp/install_app/github_cli_latest.tar.gz "https://github.com/cli/cli/releases/download/v${CLI_VERSION}/gh_${CLI_VERSION}_linux_amd64.tar.gz"
	tar xf github_cli_latest.tar.gz && cd gh_${CLI_VERSION}_linux_amd64
	mv bin/gh /usr/local/bin
	mv share/man/man1/* /usr/local/share/man/man1/
}

function InstallNeovimGithub() {
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	echo "-----------Install Neovim From Github------------"
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	mkdir -p /tmp/install_app && /tmp/install_app
	NVIM_VERSION=$(GetLatestRelease  "neovim/neovim")
	echo "-----The version of NVIM is ${NVIM_VERSION}-----"
	wget -O /tmp/install_app/neovim.tar.gz "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux64.tar.gz"
	tar xf /tmp/install_app/neovim.tar.gz
	cd /tmp/install_app/nvim-linux64
	cp -r bin/* /usr/local/bin/
	cp -r lib/* /usr/local/lib/
	cp -r share/* /usr/local/share/
}


function InstallNinjaBuild() {
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	echo "---------------Install Ninja Build From Github------------"
	echo "-------------------------------------------------"
	mkdir -p /tmp/install_app && cd /tmp/install_app
	Ninja_VERSION=$(GetLatestRelease "ninja-build/ninja")
	wget -O /tmp/install_app/ninja_build.zip "https://github.com/ninja-build/ninja/releases/download/v${Ninja_VERSION}/ninja-linux.zip"
	unzip ninja_build.zip
	mv ninja /usr/local/bin
}

function InstallVersionControl() {
	echo "-------------------------------------------------"
	echo "-------------------------------------------------"
	echo "---------------Install Version Control From Github------------"
	echo "-------------------------------------------------"
	curl -s https://packagecloud.io/install/repositories/dirk-thomas/vcstool/script.deb.sh | bash
	add-apt-repository -y ppa:git-core/ppa
	apt update
	apt-get install -y git git-lfs  subversion mercurial repo myrepos python3-vcstool
} 

function InstallGccToolChain() {
	add-apt-repository -y ppa:ubuntu-toolchain-r/test
	apt update
	apt install -y binutils gcc-10 gcc-11 gcc-9
}

function InstallLlvm() {
	CODENAME=$(lsb_release -c | awk '{print $2}')
	tee /etc/apt/sources.list.d/llvm-latest.list &>/dev/null << EOF
# i386 not available
deb http://apt.llvm.org/${CODENAME}/ llvm-toolchain-${CODENAME} main
deb-src http://apt.llvm.org/${CODENAME}/ llvm-toolchain-${CODENAME} main
# 12
deb http://apt.llvm.org/${CODENAME}/ llvm-toolchain-${CODENAME}-12 main
deb-src http://apt.llvm.org/${CODENAME}/ llvm-toolchain-${CODENAME}-12 main
# 13
deb http://apt.llvm.org/${CODENAME}/ llvm-toolchain-${CODENAME}-13 main
deb-src http://apt.llvm.org/${CODENAME}/ llvm-toolchain-${CODENAME}-13 main
EOF
   wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
   # Fingerprint: 6084 F3CF 814B 57C1 CF12 EFD5 15CF 4D18 AF4F 7421
    apt-get update
	   # LLVM
	apt-get -y  install libllvm-13-ocaml-dev libllvm13 llvm-13 llvm-13-dev llvm-13-doc llvm-13-examples llvm-13-runtime
	# Clang and co
	apt-get -y  install clang-13 clang-tools-13 clang-13-doc libclang-common-13-dev libclang-13-dev libclang1-13 clang-format-13 python-clang-13 clangd-13
	# libfuzzer
	apt-get -y  install libfuzzer-13-dev
	# lldb
	apt-get -y  install lldb-13
	# lld (linker)
	apt-get -y  install lld-13
	# libc++
	apt-get -y  install libc++-13-dev libc++abi-13-dev
	# OpenMP
	apt-get -y  install libomp-13-dev
	# libclc
	apt-get -y  install libclc-13-dev
	# libunwind
	apt-get -y  install libunwind-13-dev
	#clang-tidy
	apt install -y clang-tidy
	ln -sf /usr/bin/clangd-13 /usr/bin/clangd
	ln -sf /usr/bin/clang-format-13 /usr/bin/clang-format
	ln -sf /usr/bin/clang-tidy-13 /usr/bin/clang-tidy-13
}


function InstallCmake(){
	CODENAME=$(lsb_release -c | awk '{print $2}')
	wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
	tee /etc/apt/sources.list.d/cmake-latest.list &>/dev/null << EOF
deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ ${CODENAME} main
EOF
	apt-get update 
	apt-get install -y cmake 
}


function InstallBuildEssentail() {
	apt-get install -y build-essential ccache autoconf texinfo pkg-config
	InstallGccToolChain
	InstallLlvm
	InstallCmake
	InstallNinjaBuild
}

# function InstallNeovim() {
# 	add-apt-repository -y ppa:neovim-ppa/stable	
# 	apt update
# 	apt install -y neovim python3-neovim lua-compat53 
# }

function InstallNeovim() {
	InstallNeovimGithub
	apt install -y python3-neovim luajit
	ln -sf /usr/bin/luajit /usr/bin/lua	
}



function InstallModernTools() {
	mkdir -p /usr/local/share/man/man1/
	mkdir -p /usr/share/bash-completion/completions
	mkdir -p autocomplete/_fd /usr/share/zsh/vendor-completions/
	InstallLazyGit
	InstallGitui
	InstallBat
	InstallExa
	InstallRg
	InstallFd
	InstallStarShip
	InstallGithubCli
	InstallFzf
}

function InstallNetworkTools() {
	apt install -y tinc nmap net-tools
}

function InstallEmacs() {
	add-apt-repository ppa:kelleyk/emacs
	apt install -y emacs27 
}

function InstallProxyTools() {
	echo "Hello World"
}

function InstallMicrosoftApp() {
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
	sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
	rm microsoft.gpg
	apt update
	apt install -y microsoft-edge-beta code
}
 
# INSTALL_PARTS=(     \ 
# 	"VERSION_CONTROL" \
# 	"GCC-TOOLCHAIN"   \ 
# 	"LLVM-TOOLCHAIN"  \ 
# 	"NODEJS"          \ 
# 	"SHELL"           \ 
# ) 
 
# for PART in "${INSTALL_PARTS[*]}"; do
# 	echo ${PART};
# done


function main() {
	ChangeMirror "CN"
	UpdateSystem
	InstallBasic
	InstallNetworkTools
	InstallVersionControl
	InstallBuildEssentail
	InstallNeovim
	InstallModernTools
	AddUser
}

#main
