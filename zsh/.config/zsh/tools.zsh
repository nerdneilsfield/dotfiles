# ===================================================================
# check tools exist
# ===================================================================

if ! type fzf >/dev/null; then
  echo fzf not found! use 'install_fzf' to install.
fi

if ! type rg >/dev/null; then
  echo rg not found! use 'install_ripgrep' to install.
fi

if ! type fd >/dev/null; then
  echo fd not found! use 'install_fd' to install.
fi

if ! type bat >/dev/null; then
  echo bat not found! use 'install_bat' to install.
fi

if ! type lazygit >/dev/null; then
  echo lazygit not found! use 'install_lazygit' to install.
fi

if ! type nvim >/dev/null; then
  echo nvim not found! use 'update_nvim' to install.
fi

export GITHUB_LOCATION="$HOME/Source/app"
export LOCAL_BIN="$HOME/.local/bin/"
export ASDF_DIR="$HOME/.local/share/asdf"

# ===================================================================
# install tools exist
# ===================================================================

# install_fzf_shell() {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export FZF_REPO=$HOME/.fzf
# 	if [ ! -d "$FZF_REPO" ]; then
# 		git clone https://github.com/junegunn/fzf.git $FZF_REPO
# 	fi
# 	cd $FZF_REPO
# 	git pull origin master
# 	#$FZF_REPO/install
# 	rm -rf $FZF_REPO/bin
# 	cd -
# }
#
#
# install_fzf () {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export FZF_REPO=$GITHUB_LOCATION/junegunn/fzf
# 	if [ ! -d "$FZF_REPO" ]; then
# 		git clone https://github.com/junegunn/fzf.git $FZF_REPO
# 	fi
# 	cd $FZF_REPO
# 	git pull origin master
# 	$FZF_REPO/install
# 	cd -
# 	fzf --version
# }
#
# install_ripgrep () {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export RG_REPO=$GITHUB_LOCATION/BurntSushi/ripgrep
# 	if [ ! -d "$RG_REPO" ]; then
# 		git clone https://github.com/BurntSushi/ripgrep.git $RG_REPO
# 	fi
# 	cd $RG_REPO
# 	git pull origin master
# 	cargo build --release
# 	mkdir -p $LOCAL_BIN
# 	ln -sf $GITHUB_LOCATION/BurntSushi/ripgrep/target/release/rg $LOCAL_BIN
# 	rg --version
# }
#
# install_fd () {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export FD_REPO=$GITHUB_LOCATION/sharkdp/fd
# 	if [ ! -d "$FD_REPO" ]; then
# 		git clone https://github.com/sharkdp/fd.git $FD_REPO
# 	fi
# 	cd $FD_REPO
# 	git pull origin master
# 	cargo build --release
# 	mkdir -p $LOCAL_BIN
# 	ln -sf $GITHUB_LOCATION/sharkdp/fd/target/release/fd $LOCAL_BIN
# 	fd --version
# }
#
# install_bat () {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export BAT_REPO=$GITHUB_LOCATION/sharkdp/bat
# 	if [ ! -d "$BAT_REPO" ]; then
# 		git clone https://github.com/sharkdp/bat.git $BAT_REPO
# 	fi
# 	cd $BAT_REPO
# 	cargo build --release
# 	mkdir -p $LOCAL_BIN
# 	ln -sf $GITHUB_LOCATION/sharkdp/bat/target/release/bat $LOCAL_BIN
# 	bat --version
# }
#
# install_gitui () {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export GITUI_REPO=$GITHUB_LOCATION/extrawurst/gitui
# 	if [ ! -d "$GITUI_REPO" ]; then
# 		git clone https://github.com/extrawurst/gitui.git $GITUI_REPO
# 	fi
# 	cd $GITUI_REPO
# 	cargo build --release
# 	mkdir -p $LOCAL_BIN
# 	ln -sf $GITHUB_LOCATION/extrawurst/gitui/target/release/gitui $LOCAL_BIN
# 	gitui --version
# }
#
# install_tpm () {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export TPM_REPO=$GITHUB_LOCATION/tmux-plugins/tpm
# 	if [ ! -d "$TPM_REPO" ]; then
# 		git clone https://github.com/tmux-plugins/tpm.git $TPM_REPO
# 	fi
# }
#
# install_lazygit() {
# 	setproxy
# 	set -e
# 	set -o xtrace
# 	go get -d github.com/jesseduffield/lazygit
# }
#
#
# update_vim () {
# 	setpx
# 	set -e
# 	set -o xtrace
# 	export VIM_REPO=$GITHUB_LOCATION/vim/vim
# 	if [ ! -d "$VIM_REPO" ]; then
# 		git clone https://github.com/vim/vim.git $VIM_REPO
# 	fi
# 	cd $VIM_REPO
# 	git pull origin master
# 	# https://github.com/vim/vim/blob/master/src/INSTALL
# 	make
# 	sudo make install
# 	cd -
# 	vim --version
# }

#=======================
# Tool Usage
#=======================

install_fzf_zsh() {

}

export FZF_DEFAULT_COMMAND="fd --exclude={.git,.idea,.vscode,.sass-cache,node_modules,build} --type f"
export FZF_PREVIEW_COMMAND="bat --style=numbers,changes --wrap never --color always {} || cat {} || tree -C {}"
# export FZF_CTRL_T_OPTS="--min-height 30 --preview-window down:60% --preview-window noborder --preview '($FZF_PREVIEW_COMMAND) 2> /dev/null'"
export FZF_COMPLETION_TRIGGER='ll'
# export FZF_DEFAULT_OPTS="--min-height 30 --preview-window down:60% --preview-window noborder --preview '($FZF_PREVIEW_COMMAND) 2> /dev/null'"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview '${FZF_PREVIEW_COMMAND}'"
# source ${ZSH_CONF_DIR}/fzf/completion.zsh
# source ${ZSH_CONF_DIR}/fzf/key-bindings.zsh
[[ $- == *i* ]] && source "${ZSH_CONF_DIR}/fzf/completion.zsh" 2> /dev/null
source "${ZSH_CONF_DIR}/fzf/key-bindings.zsh"

alias fpreview="fzf --min-height 30 --preview-window down:60% --preview-window noborder --preview '($FZF_PREVIEW_COMMAND) 2> /dev/null'"

# cdf - cd into the directory of the selected file
# # alias cdf="cd $(ls | fzf)"
# Interactive file edit with fzf+fd
alias vif='fd --exclude={.git,.idea,.vscode,.sass-cache,node_modules,build} --type f | fzf --preview "$FZF_PREVIEW_COMMAND" | xargs -r nvim'

# Advanced search integrations
alias rgf='rg --files-with-matches --no-messages | fzf --preview "rg --context 3 --color=always {}" | xargs -r nvim'
alias fdf='fd --type d | fzf --preview "eza --tree --level=2 --color=always {}" | xargs -r cd'
alias rgp='rg --line-number --no-heading --color=always . | fzf --delimiter : --preview "bat --color=always --highlight-line {2} {1}" --preview-window +{2}-/2'

# Tool upgrade aliases  
alias upgrade-tools='bash ~/Source/configs/dotfiles/init/init_ubuntu_root.sh UpgradeAllTools'
alias check-versions='for tool in fzf rg fd bat starship lazygit nvim; do echo -n "$tool: "; $tool --version 2>/dev/null | head -n1 || echo "未安装"; done'

# User-friendly upgrade functions (no sudo required for checking)
function check-tool-updates() {
	echo "🔍 检查工具更新状态..."
	for tool in fzf rg fd bat starship lazygit nvim; do
		echo -n "🔍 $tool: "
		local current_version=$($tool --version 2>/dev/null | head -n1 | awk '{print $2}' 2>/dev/null)
		if [[ -n "$current_version" ]]; then
			echo "当前版本 $current_version"
		else
			echo "❌ 未安装"
		fi
	done
	echo ""
	echo "💡 运行 'upgrade-tools' 来升级所有工具"
}

# @brief Execute command from shell history using fzf
# @return 0 on success
# @example fh
# @category tools
fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# @brief Query cheat.sh for command help
# @param $1 Language or tool name
# @param $2 Topic or function
# @return 0 on success
# @example chtsh python list
# @category tools
chtsh() {
  curl cht.sh/$1/$2
}

# @brief Install Tmux Plugin Manager
# @return 0 on success
# @example install_tpm
# @category tools
install_tpm(){
  mkdir -p $HOME/.tmux/plugins
  if [[ -d $HOME/.tmux/plugins/tpm ]]; then
    green_echo "=========tpm already installed, updating======"
    cd $HOME/.tmux/plugins/tpm
    git pull
    green_echo "========tpm updated========"
  else
    green_echo "=========installing tpm======"
    git clone --recursive --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    green_echo "=========tpm installed======"
  fi
}

# @brief Install neofetch system information tool
# @return 0 on success
# @example install_neofetch
# @category tools
install_neofetch() {
  wget -O ~/.local/bin/neofetch "https://github.com/dylanaraps/neofetch/raw/master/neofetch"
  chmod +x ~/.local/bin/neofetch
}

# @brief Install fastfetch system information tool from source
# @return 0 on success
# @example install_fastfetch
# @category tools
install_fastfetch() {
  green_echo "======================================"
  green_echo "=========Install fastfetch========"
  green_echo "======================================"
  local _fastfetch_dir="$HOME/Source/app/fastfetch"
  local _fastfetch_url="https://github.com/fastfetch-cli/fastfetch.git"
  mkdir -p $HOME/Source/app 
  if [[ -d $_fastfetch_dir ]]; then
    green_echo "=========fastfetch already installed, updating======"
    cd $_fastfetch_dir
    git pull
    green_echo "========fastfetch updated========"
  else
    green_echo "=========installing fastfetch======"
    git clone --recursive --depth 1 $_fastfetch_url $_fastfetch_dir
    green_echo "=========fastfetch cloned======"
  fi
  cd $_fastfetch_dir
  set_cxx clang
  rm -rf build
  cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME/.local
  cmake --build build -j $(nproc)
  cmake --install build
}


# @brief Install GitHub CLI tool intelligently
# @return 0 on success
# @example install_gh
# @category tools
install_gh(){
    echo "🚀 智能安装 GitHub CLI..."
    
    # 使用智能安装系统
    if command -v install_smart_tool >/dev/null 2>&1; then
        install_smart_tool gh
        return $?
    fi
    
    # 回退到传统方法
    echo "⚠️  智能安装系统未加载，使用传统方法..."
    green_echo "======================================"
    green_echo "=========Install gh========"
    green_echo "======================================"
  local _gh_version=$(GetLatestReleaseWithRetryProxy "cli/cli")
  local _arch=$(uname -m)
  if [[ $_arch == "x86_64" ]]; then
    _arch="amd64"
  fi
  local _gh_url="https://ghproxy.dengqi.org/https://github.com/cli/cli/releases/download/v${_gh_version}/gh_${_gh_version}_linux_${_arch}.tar.gz"

  mkdir -p /tmp/install
  cd /tmp/install
  wget -O gh.tar.gz $_gh_url
  tar -xzf gh.tar.gz
  cd "gh_${_gh_version}_linux_${_arch}"
  mv bin/gh $HOME/.local/bin/
  mkdir -p $HOME/.local/share/man/man1
  cp share/man/man1/* $HOME/.local/share/man/man1/
  sudo rm -rf /usr/local/bin/gh
  sudo cp $HOME/.local/bin/gh /usr/local/bin/gh
}

# @brief Install fzf fuzzy finder intelligently
# @return 0 on success
# @example install_fzf
# @category tools
install_fzf(){
    echo "🚀 智能安装 fzf..."
    
    # 使用智能安装系统
    if command -v install_smart_tool >/dev/null 2>&1; then
        install_smart_tool fzf
        return $?
    fi
    
    # 回退到传统方法
    echo "⚠️  智能安装系统未加载，使用传统方法..."
    green_echo "======================================"
    green_echo "=========Install fzf========"
    green_echo "======================================"
  local _fzf_version=$(GetLatestReleaseWithRetryProxy "junegunn/fzf")
  local _arch=$(uname -m)
  if [[ $_arch == "x86_64" ]]; then
    _arch="amd64"
  fi
  # link is like: https://github.com/junegunn/fzf/releases/download/v0.55.0/fzf-0.55.0-linux_amd64.tar.gz
  local _fzf_url="https://ghproxy.dengqi.org/https://github.com/junegunn/fzf/releases/download/v${_fzf_version}/fzf-${_fzf_version}-linux_${_arch}.tar.gz"
  green_echo "downloading $_fzf_url ......"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O fzf.tar.gz $_fzf_url
  tar -xzf fzf.tar.gz
  mv fzf $HOME/.local/bin/
  sudo rm -rf /usr/local/bin/fzf
  sudo cp $HOME/.local/bin/fzf /usr/local/bin/fzf
}

# @brief Install eza modern ls replacement intelligently
# @return 0 on success
# @example install_eza
# @category tools
install_eza(){
    echo "🚀 智能安装 eza..."
    
    # 使用智能安装系统
    if command -v install_smart_tool >/dev/null 2>&1; then
        install_smart_tool eza
        return $?
    fi
    
    # 回退到传统方法
    echo "⚠️  智能安装系统未加载，使用传统方法..."
    green_echo "======================================"
    green_echo "=========Install eza========"
    green_echo "======================================"
  local _eza_version=$(GetLatestReleaseWithRetryProxy "eza-community/eza")
  local _arch=$(uname -m)
  local _eza_url="https://ghproxy.dengqi.org/https://github.com/eza-community/eza/releases/download/v${_eza_version}/eza_${_arch}-unknown-linux-gnu.tar.gz"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O eza.tar.gz $_eza_url
  tar -xzf eza.tar.gz
  mv eza $HOME/.local/bin/
  sudo rm -rf /usr/local/bin/eza
  sudo cp $HOME/.local/bin/eza /usr/local/bin/eza
}

# @brief Install lazygit Git TUI
# @return 0 on success
# @example install_lazygit
# @category tools
install_lazygit(){
  green_echo "======================================"
  green_echo "=========Install lazygit========"
  green_echo "======================================"
  local _lazygit_version=$(GetLatestReleaseWithRetryProxy "jesseduffield/lazygit")
  local _arch=$(uname -m)
  local _lazygit_url="https://ghproxy.dengqi.org/https://github.com/jesseduffield/lazygit/releases/download/v${_lazygit_version}/lazygit_${_lazygit_version}_Linux_${_arch}.tar.gz"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O lazygit.tar.gz $_lazygit_url
  tar -xzf lazygit.tar.gz
  mv lazygit $HOME/.local/bin/
  sudo rm -rf /usr/local/bin/lazygit
  sudo cp $HOME/.local/bin/lazygit /usr/local/bin/lazygit
}

# @brief Install lazydocker Docker TUI
# @return 0 on success
# @example install_lazydocker
# @category tools
install_lazydocker(){
  green_echo "======================================"
  green_echo "=========Install lazydocker========"
  green_echo "======================================"
  local _lazydocker_version=$(GetLatestReleaseWithRetryProxy "jesseduffield/lazydocker")
  local _arch=$(uname -m)
  local _lazydocker_url="https://ghproxy.dengqi.org/https://github.com/jesseduffield/lazydocker/releases/download/v${_lazydocker_version}/lazydocker_${_lazydocker_version}_Linux_${_arch}.tar.gz"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O lazydocker.tar.gz $_lazydocker_url
  tar -xzf lazydocker.tar.gz
  mv lazydocker $HOME/.local/bin/
  sudo rm -rf /usr/local/bin/lazydocker
  sudo cp $HOME/.local/bin/lazydocker /usr/local/bin/lazydocker
}

# @brief Install duf disk usage utility
# @return 0 on success
# @example install_duf
# @category tools
install_duf(){
  green_echo "======================================"
  green_echo "=========Install duf========"
  green_echo "======================================"
  local _duf_version=$(GetLatestReleaseWithRetryProxy "muesli/duf")
  local _arch=$(uname -m)
  # if [[ $_arch == "x86_64" ]]; then
  #   _arch="amd64"
  # fi
  local _duf_url="https://ghproxy.dengqi.org/https://github.com/muesli/duf/releases/download/v${_duf_version}/duf_${_duf_version}_linux_${_arch}.tar.gz"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O duf.tar.gz $_duf_url
  tar -xzf duf.tar.gz
  mv duf $HOME/.local/bin/
  sudo rm -rf /usr/local/bin/duf
  sudo cp $HOME/.local/bin/duf /usr/local/bin/duf
}

# @brief Install gdu disk usage analyzer
# @return 0 on success
# @example install_gdu
# @category tools
install_gdu(){
  green_echo "======================================"
  green_echo "=========Install gdu========"
  green_echo "======================================"
  local _gdu_version=$(GetLatestReleaseWithRetryProxy "dundee/gdu")
  local _arch=$(uname -m)
  if [[ $_arch == "x86_64" ]]; then
    _arch="amd64"
  fi
  local _gdu_url="https://ghproxy.dengqi.org/https://github.com/dundee/gdu/releases/download/v${_gdu_version}/gdu_linux_${_arch}.tgz"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O gdu.tar.gz $_gdu_url
  tar -xzf gdu.tar.gz
  mv "gdu_linux_${_arch}" $HOME/.local/bin/gdu
  sudo rm -rf /usr/local/bin/gdu
  sudo cp $HOME/.local/bin/gdu /usr/local/bin/gdu
}

# @brief Install ripgrep fast text search tool intelligently
# @return 0 on success
# @example install_ripgrep
# @category tools
install_ripgrep(){
    echo "🚀 智能安装 ripgrep..."
    
    # 使用智能安装系统
    if command -v install_smart_tool >/dev/null 2>&1; then
        install_smart_tool ripgrep
        return $?
    fi
    
    # 回退到传统方法
    echo "⚠️  智能安装系统未加载，使用传统方法..."
    green_echo "======================================"
    green_echo "=========Install ripgrep========"
    green_echo "======================================"
  local _rg_version=$(GetLatestReleaseWithRetryProxy "BurntSushi/ripgrep")
  local _arch=$(uname -m)
  # if [[ $_arch == "x86_64" ]]; then
  #   _arch="amd64"
  # fi
  local _rg_url="https://ghproxy.dengqi.org/https://github.com/BurntSushi/ripgrep/releases/download/${_rg_version}/ripgrep-${_rg_version}-${_arch}-unknown-linux-musl.tar.gz"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O rg.tar.gz $_rg_url
  tar -xzf rg.tar.gz
  cd ripgrep-${_rg_version}-${_arch}-unknown-linux-musl
  mv rg $HOME/.local/bin/
  sudo rm -rf /usr/local/bin/rg
  sudo cp $HOME/.local/bin/rg /usr/local/bin/rg
}

# @brief Install fd fast file finder
# @return 0 on success
# @example install_fd
# @category tools
install_fd(){
  green_echo "======================================"
  green_echo "=========Install fd========"
  green_echo "======================================"
  local _fd_version=$(GetLatestReleaseWithRetryProxy "sharkdp/fd")
  local _arch=$(uname -m)
  # if [[ $_arch == "x86_64" ]]; then
  #   _arch="amd64"
  # fi
  local _fd_url="https://ghproxy.dengqi.org/https://github.com/sharkdp/fd/releases/download/v${_fd_version}/fd-v${_fd_version}-${_arch}-unknown-linux-gnu.tar.gz"
  mkdir -p /tmp/install
  cd /tmp/install
  wget -O fd.tar.gz $_fd_url
  tar -xzf fd.tar.gz
  cd fd-v${_fd_version}-${_arch}-unknown-linux-gnu
  mv fd $HOME/.local/bin/
  cp fd.1 $HOME/.local/share/man/man1/
  sudo rm -rf /usr/local/bin/fd
  sudo cp $HOME/.local/bin/fd /usr/local/bin/fd
}

# @brief Install mise runtime version manager
# @return 0 on success
# @example install_mise
# @category tools
install_mise(){
  green_echo "======================================"
  green_echo "=========Install mise========"
  green_echo "======================================"
  local _mise_version=$(GetLatestReleaseWithRetryProxy "jdx/mise")
  local _arch=$(uname -m)
  if [[ $_arch == "x86_64" ]]; then
    _arch="x64"
  elif [[ $_arch == "aarch64" ]]; then
    _arch="arm64"
  fi
  # https://github.com/jdx/mise/releases/download/v2024.5.16/mise-v2024.5.16-linux-x64-musl.tar.xz
  local _mise_url="https://ghproxy.dengqi.org/https://github.com/jdx/mise/releases/download/v${_mise_version}/mise-v${_mise_version}-linux-${_arch}-musl.tar.xz"
  wget -O /tmp/mise.tar.xz $_mise_url
  tar -xvf /tmp/mise.tar.xz -C $HOME/.local/share
  ln -sf $HOME/.local/share/mise/bin/mise $HOME/.local/bin/mise
}

# @brief Install asdf version manager
# @return 0 on success
# @example install_asdf
# @category tools
install_asdf(){
  green_echo "======================================"
  green_echo "=========Install asdf========"
  green_echo "======================================"
  if [[ -d $ASDF_DIR ]]; then
    green_echo "=========asdf already installed, updating======"
    cd $ASDF_DIR
    git pull
    green_echo "========asdf updated========"
  else
    green_echo "=========installing asdf======"
    git clone https://github.com/asdf-vm/asdf.git $ASDF_DIR
    green_echo "=========asdf installed======"
  fi
}

# @brief Install Xray proxy tool intelligently
# @return 0 on success
# @example install_xray
# @category tools
install_xray(){
    echo "🚀 智能安装 Xray..."
    
    # 使用智能安装系统
    if command -v install_smart_tool >/dev/null 2>&1; then
        install_smart_tool xray
    else
        # 回退到传统方法
        echo "⚠️  智能安装系统未加载，使用传统方法..."
        local _xray_version=$(GetLatestReleaseWithRetryProxy "XTLS/Xray-core")
        local _arch=$(get_cpu_arch)
        local _xray_url="https://ghproxy.dengqi.org/https://github.com/XTLS/Xray-core/releases/download/v${_xray_version}/Xray-linux-${_arch}.zip"
        
        mkdir -p /tmp/install
        cd /tmp/install
        wget -O xray.zip $_xray_url
        unzip xray.zip
        mv xray $HOME/.local/bin/
        chmod +x $HOME/.local/bin/xray
        sudo cp $HOME/.local/bin/xray /usr/local/bin/ 2>/dev/null || true
    fi
}

# @brief Install sing-box proxy tool intelligently
# @return 0 on success
# @example install_sing_box
# @category tools
install_sing_box(){
    echo "🚀 智能安装 sing-box..."
    
    # 使用智能安装系统
    if command -v install_smart_tool >/dev/null 2>&1; then
        install_smart_tool sing-box
    else
        # 回退到传统方法
        echo "⚠️  智能安装系统未加载，使用传统方法..."
        local _sing_box_version=$(GetLatestReleaseWithRetryProxy "SagerNet/sing-box")
        local _arch=$(get_cpu_arch)
        local _sing_box_url="https://ghproxy.dengqi.org/https://github.com/SagerNet/sing-box/releases/download/v${_sing_box_version}/sing-box-${_arch}.tar.gz"
        
        mkdir -p /tmp/install
        cd /tmp/install
        wget -O sing-box.tar.gz $_sing_box_url
        tar -xzf sing-box.tar.gz
        mv sing-box $HOME/.local/bin/
        chmod +x $HOME/.local/bin/sing-box
        sudo cp $HOME/.local/bin/sing-box /usr/local/bin/ 2>/dev/null || true
    fi
}

# @brief Install mihomo (Clash Meta) proxy tool intelligently
# @return 0 on success
# @example install_mihomo
# @category tools
install_mihomo(){
    echo "🚀 智能安装 mihomo (Clash Meta)..."
    
    # 使用智能安装系统
    if command -v install_smart_tool >/dev/null 2>&1; then
        install_smart_tool mihomo
    else
        # 回退到传统方法
        echo "⚠️  智能安装系统未加载，使用传统方法..."
        local _mihomo_version=$(GetLatestReleaseWithRetryProxy "MetaCubeX/mihomo")
        local _arch=$(get_cpu_arch)
        local _mihomo_url="https://ghproxy.dengqi.org/https://github.com/MetaCubeX/mihomo/releases/download/v${_mihomo_version}/mihomo-linux-${_arch}-v${_mihomo_version}.gz"
        
        mkdir -p /tmp/install
        cd /tmp/install
        wget -O mihomo.gz $_mihomo_url
        gunzip mihomo.gz
        mv mihomo $HOME/.local/bin/
        chmod +x $HOME/.local/bin/mihomo
        sudo cp $HOME/.local/bin/mihomo /usr/local/bin/ 2>/dev/null || true
    fi
}

##
# @brief 批量安装现代命令行工具
# @description 智能安装一套现代化的命令行工具：fzf、ripgrep、fd、bat、eza、lazygit、gh、yazi、bottom
# @return 0 安装完成
# @example install_batch_modern
# @category install
##
install_batch_modern(){
    echo "🚀 智能批量安装现代命令行工具..."
    
    local modern_tools=(
        "fzf"
        "ripgrep"
        "fd" 
        "bat"
        "eza"
        "lazygit"
        "gh"
        "yazi"
        "bottom"
    )
    
    for tool in "${modern_tools[@]}"; do
        echo ""
        echo "📦 安装 $tool..."
        if command -v install_smart_tool >/dev/null 2>&1; then
            install_smart_tool "$tool"
        else
            echo "⚠️  智能安装系统不可用，使用传统方法"
            case "$tool" in
                "fzf") install_fzf ;;
                "ripgrep") install_ripgrep ;;
                "fd") install_fd ;;
                "eza") install_eza ;;
                "lazygit") install_lazygit ;;
                "gh") install_gh ;;
                *) echo "❌ 无法安装 $tool" ;;
            esac
        fi
    done
    
    echo ""
    echo "✅ 现代工具安装完成！"
}

# 传统批量安装 (保持向后兼容)
# @brief Install batch of essential CLI tools via releases
# @return 0 on success
# @example install_batch_release
# @category tools
install_batch_release(){
  install_gh
  install_fzf
  install_eza
  install_lazygit
  install_lazydocker
  install_duf
  install_gdu
  install_ripgrep
  install_fd
}

# @brief Install modern tools via Rust package manager
# @return 0 on success
# @example install_modern_tools_rust
# @category tools
install_modern_tools_rust() {
    echo "🦀 安装现代 Rust 工具..."
    
    local rust_tools=(
        "bat"
        "ripgrep"
        "fd-find"
        "eza"
        "bottom"
        "dust"
        "procs"
        "sd"
        "tokei"
        "hyperfine"
        "delta"
        "tealdeer"
        "zoxide"
        "starship"
    )
    
    for tool in "${rust_tools[@]}"; do
        echo "📦 安装 $tool..."
        if command -v install_smart_tool >/dev/null 2>&1; then
            install_smart_tool "$tool"
        else
            cargo install "$tool" 2>/dev/null || echo "❌ 无法通过 Cargo 安装 $tool"
        fi
    done
    
    echo "✅ Rust 工具安装完成！"
}

# @brief Install development tools collection
# @return 0 on success
# @example install_dev_tools
# @category tools
install_dev_tools() {
    echo "🛠️ 安装开发工具集..."
    
    local dev_tools=(
        "git"
        "curl"
        "wget"
        "jq"
        "tmux"
        "tree"
        "htop"
        "vim"
        "rsync"
    )
    
    for tool in "${dev_tools[@]}"; do
        echo "📦 安装 $tool..."
        if command -v install_smart_tool >/dev/null 2>&1; then
            install_smart_tool "$tool"
        else
            echo "⚠️ 请手动安装 $tool"
        fi
    done
    
    echo "✅ 开发工具安装完成！"
}

# 向后兼容别名 (统一命名规范)
alias install_modertools_smart="install_batch_modern"
alias install_modertools_release="install_batch_release"
alias install_modertools_rust="install_modern_tools_rust"
alias install_modertools_python="install_modern_tools_python"
alias install_modertools_go="install_modern_tools_go"

# @brief Install code-server (VS Code in browser) on Ubuntu
# @return 0 on success
# @example install_code_server_ubuntu
# @category tools
install_code_server_ubuntu(){
  green_echo "======================================"
  green_echo "=========Install code-server========"
  green_echo "======================================"
  local _code_server_version=$(GetLatestReleaseWithRetryProxy "coder/code-server")
  local _arch=$(uname -m)
  if [[ $_arch == "x86_64" ]]; then
    _arch="amd64"
  fi
  local _code_server_url="https://ghproxy.dengqi.org/https://github.com/coder/code-server/releases/download/v${_code_server_version}/code-server_${_code_server_version}_${_arch}.deb"

  mkdir -p /tmp/install
  cd /tmp/install
  wget -O code-server.deb $_code_server_url
  sudo apt install ./code-server.deb
  cd -
}


# @brief Install modern Python-based command line tools (legacy name)
# @return 0 on success
# @example install_modertools_python
# @category tools
install_modern_tools_python() {
  # python3 -m pip install -U pip
  local _python_tools=(
    "glances"
    # "tldr"
    "yt-dlp"
    "gitsome"
    "httpie"
    # "jrnl"
  )
  for _python_tool in $_python_tools; do
    green_echo "install $_python_tool"
    python3 -m pip install --user $_python_tool
  done
}

# @brief Install modern Go-based command line tools (legacy name)
# @return 0 on success
# @example install_modertools_go
# @category tools
install_modern_tools_go() {
  echo "======================================"
  echo "=========Install Modertools Go========"
  echo "======================================"
  local _golang_tools=(
    # "github.com/zulk/nali"
    "moul.io/assh/v2"
    # "github.com/muesli/duf"
    "github.com/rclone/rclone"
    # "github.com/jesseduffield/lazydocker"
	  # "github.com/dundee/gdu/v5/cmd/gdu"
    # "github.com/junegunn/fzf"
  )

  for _golang_tool in $_golang_tools; do
    green_echo "=====install $_golang_tool====="
    go install "${_golang_tool}@latest"
  done
}

# @brief Install all modern tools from local compilation
# @return 0 on success
# @example install_modern_tools_local
# @category tools
install_modern_tools_local() {
  install_neofetch
  install_modern_tools_rust
  install_modern_tools_python
  install_modern_tools_go
  install_jq_from_source
}

# @brief Install modern tools via binary downloads with architecture fallback
# @param $1 Optional target installation prefix (e.g., /usr/local, $HOME/.local). Defaults to $HOME/.local.
# @return 0 on success
# @example install_modern_tools_by_download
# @example install_modern_tools_by_download /usr/local
# @category tools
install_modern_tools_by_download(){
    local requested_install_prefix="${1:-$HOME/.local}" # Use provided prefix or default to $HOME/.local
    echo "📞 智能下载安装现代工具 (学习模式) 到 '$requested_install_prefix'..." >&2
    
    # 定义工具和它们的下载模式 或 示例URL
    declare -A tool_entries=(
        ["ripgrep"]="BurntSushi/ripgrep|https://github.com/BurntSushi/ripgrep/releases/download/v14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz"
        ["fd"]="sharkdp/fd|https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz"
        ["eza"]="eza-community/eza|https://github.com/eza-community/eza/releases/download/v0.21.3/eza_x86_64-unknown-linux-gnu.tar.gz" # No {VERSION} in pattern
        ["bat"]="sharkdp/bat|https://github.com/sharkdp/bat/releases/download/v0.25.0/bat-v0.25.0-x86_64-unknown-linux-gnu.tar.gz"
        ["fzf"]="junegunn/fzf|https://github.com/junegunn/fzf/releases/download/v0.62.0/fzf-0.62.0-linux_amd64.tar.gz"
        ["lazygit"]="jesseduffield/lazygit|https://github.com/jesseduffield/lazygit/releases/download/v0.51.1/lazygit_0.51.1_Linux_x86_64.tar.gz"
        ["gh"]="cli/cli|https://github.com/cli/cli/releases/download/v2.73.0/gh_2.73.0_linux_amd64.tar.gz"
        ["duf"]="muesli/duf|https://github.com/muesli/duf/releases/download/v0.8.1/duf_0.8.1_linux_x86_64.tar.gz"
        ["dust"]="bootandy/dust|https://github.com/bootandy/dust/releases/download/v1.2.0/dust-v1.2.0-x86_64-unknown-linux-gnu.tar.gz"
        ["gdu"]="dundee/gdu|https://github.com/dundee/gdu/releases/download/v5.30.1/gdu_linux_amd64.tgz"
        ["procs"]="dalance/procs|https://github.com/dalance/procs/releases/download/v0.14.0/procs-v0.14.0-x86_64-linux.tar.gz"
        ["sd"]="chmln/sd|https://github.com/chmln/sd/releases/download/v0.9.0/sd-v0.9.0-x86_64-unknown-linux-gnu.tar.gz"
        # ["tokei"]="XAMPPRocky/tokei|https://github.com/XAMPPRocky/tokei/releases/download/v14.1.0/tokei-x86_64-unknown-linux-gnu.tar.gz"
        ["hyperfine"]="sharkdp/hyperfine|https://github.com/sharkdp/hyperfine/releases/download/v1.17.0/hyperfine-v1.17.0-x86_64-unknown-linux-gnu.tar.gz"
        ["delta"]="dandavison/delta|https://github.com/dandavison/delta/releases/download/0.20.1/delta-0.20.1-x86_64-unknown-linux-gnu.tar.gz"
        ["tealdeer"]="dbrgn/tealdeer|https://github.com/dbrgn/tealdeer/releases/download/v1.8.0/tealdeer-v1.8.0-x86_64-unknown-linux-gnu.tar.gz"
        # Example of a tool where the version is part of the asset name in a non-standard way or URL provides it directly
        # ["another-tool"]="another/repo|https://example.com/another-tool-stable-x86_64.zip" 
    )
    
    local success_count=0
    local total_count=${#tool_entries[@]}
    local func_name="install_modern_tools_by_download"

    if ! command -v smart_download_tool >/dev/null 2>&1 || \
       ! command -v extract_download_pattern >/dev/null 2>&1 || \
       ! command -v GetLatestReleaseProxy >/dev/null 2>&1; then # Assuming GetLatestReleaseProxy is preferred or available
        echo "❌ $func_name: 关键辅助函数 (smart_download_tool, extract_download_pattern, GetLatestReleaseProxy) 未找到。请确保 utils.zsh 已加载。" >&2
        return 1
    fi
    
    local tool_key
    local version # Declare version local to the loop
    for tool_key in ${(k)tool_entries}; do
        local entry_value="${tool_entries[$tool_key]}"
        local repo="${entry_value%%|*}" # owner/repo
        local pattern_or_url="${entry_value#*|}"
        
        # Infer tool_name from repo string (e.g., "BurntSushi/ripgrep" -> "ripgrep")
        # Or use the tool_key if repo parsing is tricky (e.g. if repo is not owner/repo)
        local tool_name_from_repo="${repo#*/}" 
        local tool_name_to_use="${tool_name_from_repo:-$tool_key}"

        echo "" >&2
        echo "🚀 处理工具: $tool_name_to_use (Key: $tool_key, Repo: $repo)" >&2
        
        local asset_pattern="$pattern_or_url" # Default to this if not a URL
        local example_tag_from_url_path=""

        if [[ "$pattern_or_url" == "https://"* || "$pattern_or_url" == "http://"* ]]; then
            echo "ℹ️ 检测到示例 URL，尝试从中学习模式: $pattern_or_url" >&2
            # Extract the example tag from the example URL's path
            local dir_name_from_example_url
            dir_name_from_example_url=$(dirname "$pattern_or_url")
            if [[ "$dir_name_from_example_url" != "." && "$dir_name_from_example_url" != "/" ]]; then
                example_tag_from_url_path=$(basename "$dir_name_from_example_url")
            fi
            
            asset_pattern=$(extract_download_pattern "$pattern_or_url")
            if [[ $? -ne 0 || -z "$asset_pattern" ]]; then
                echo "❌ $func_name: 无法从示例 URL 为 $tool_name_to_use 提取下载模式。跳过。" >&2
                continue
            fi
            echo "✅ 从 URL 学到的模式: $asset_pattern" >&2
            if [[ -n "$example_tag_from_url_path" ]]; then
                echo "ℹ️ 从示例 URL 路径中提取的标签: $example_tag_from_url_path" >&2
            fi
        else
            echo "ℹ️ 使用预定义的资源模式: $asset_pattern" >&2
        fi

        # 获取最新版本号
        # local version # Moved declaration outside the loop and made local
        echo "🔄 正在为 $repo 获取最新的 release tag..." >&2
        version=$(GetLatestReleaseWithRetryProxy "$repo" 2>/dev/null) # Or your preferred version fetching function
        
        if [[ -z "$version" ]]; then
            echo "⚠️  $func_name: 获取 $tool_name_to_use ($repo) 的版本失败。跳过。" >&2
            continue
        fi
        echo "✅ 获取到版本: $version" >&2
        
        # 使用函数参数提供的或默认的安装前缀
        local target_install_prefix="$requested_install_prefix" 

        echo "⚙️  准备使用 smart_download_tool 安装 $tool_name_to_use 到 $target_install_prefix" >&2
        # Pass example_tag_from_url_path to smart_download_tool
        if smart_download_tool "$tool_name_to_use" "$repo" "$version" "$asset_pattern" "$target_install_prefix" "$example_tag_from_url_path"; then
            echo "✅ $tool_name_to_use 成功处理完毕。" >&2
            ((success_count++))
        else
            echo "❌ $tool_name_to_use 处理失败。" >&2
        fi
    done
    
    echo "" >&2
    echo "📈 安装总结: $success_count / $total_count 工具成功处理。" >&2
    
    if [[ $success_count -eq $total_count ]]; then
        echo "✅ 所有选定工具处理完成！" >&2
        return 0
    else
        echo "⚠️  部分工具处理失败。" >&2
        return 1
    fi
}

# 向后兼容别名
alias install_modertools_local_by_download="install_modern_tools_by_download"

# @brief Install jq JSON processor from source
# @return 0 on success
# @example install_jq_from_source
# @category tools
install_jq_from_source() {
    echo "🚀 智能安装 jq..."
    
    # 使用智能安装系统
    if command -v install_smart_tool >/dev/null 2>&1; then
        install_smart_tool jq
        return $?
    fi
    
    # 回退到源码编译
    echo "⚠️  智能安装系统未加载，从源码编译..."
    local jq_dir="${HOME}/Source/app/jq"
    mkdir -p "$jq_dir"
    
    if [ ! -d "$jq_dir/.git" ]; then
        git clone --depth 1 --recursive https://github.com/jqlang/jq.git "$jq_dir"
    fi
    
    cd "$jq_dir"
    git pull origin main 2>/dev/null || git pull origin master
    
    # 清理和构建
    make clean 2>/dev/null || true
    make distclean 2>/dev/null || true
    
    # 检查依赖
    if ! command -v autoreconf >/dev/null 2>&1; then
        echo "❌ 请先安装 autotools: sudo apt install autotools-dev autoconf"
        return 1
    fi
    
    autoreconf -i
    ./configure --prefix="${HOME}/.local" --disable-maintainer-mode
    make -j $(nproc)
    make install
    
    green_echo "✅ jq 安装完成"
}

# 向后兼容别名
alias install_modertools_jq="install_jq_from_source"

#=======================
#=====git diff difft====
export GIT_EXTERNAL_DIFF=difft


# use ip address
# @brief Show all IPv4 addresses on system
# @return 0 on success
# @example show_ipv4_addr
# @category tools
show_ipv4_addr() {
  # ip addr | grep -E "192.168" | awk '{print $2}' | cut -d "/" --field 1
  ip addr | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"
}


# show_ipv6_addr() {
#   ip addr | grep -E -o "([0-9a-fA-F]{1,4}:){7}([0-9a-fA-F]{1,4}|:)|([0-9a-fA-F]{1,4}:){6}(:[0-9a-fA-F]{1,4}|:)|([0-9a-fA-F]{1,4}:){5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])"
# }

# @brief Show all IP addresses (IPv4 and IPv6) on system
# @return 0 on success
# @example show_ip_addr
# @category tools
show_ip_addr(){
  show_ipv4_addr
  show_ipv6_addr
}


if [[ -f $HOME/.local/bin/mise ]]; then
  eval "$(mise activate zsh)"
fi

if [[ -d $ASDF_DIR ]]; then
  . $ASDF_DIR/asdf.sh
  fpath=(${ASDF_DIR}/completions $fpath)
  autoload -Uz compinit && compinit
fi

if [[ -d $HOME/.config/broot/launcher/bash ]] then
 source $HOME/.config/broot/launcher/bash/br
fi

