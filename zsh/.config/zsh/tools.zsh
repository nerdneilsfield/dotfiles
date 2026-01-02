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




# @brief Install eget for install package from github
# @return 0 on success
# @example install_eget
# @category tools
install_eget_proxy() {
    local EGET_REPO="zyedidia/eget"
	local EGET_RELEASE=$(GetLatestReleaseWithRetryProxy $EGET_REPO)
	echo "EGET_RELEASE: $EGET_RELEASE"

	# get the cpu arch
	local CPU_ARCH=$(uname -m)
	local ARCH
	echo "CPU_ARCH: $CPU_ARCH"

	    # 使用关联数组映射架构
    local -A ARCH_MAP=(
        ["x86_64"]="amd64"
        ["x86"]="386"
        ["arm64"]="arm64"
        ["aarch64"]="arm64"
        ["armv7l"]="arm"
        ["armv6l"]="arm"
    )

    # 获取映射后的架构
    ARCH=${ARCH_MAP[$CPU_ARCH]:-amd64}  # 如果键不存在，使用默认值amd64

	# download the binary
	local EGET_URL="https://ghproxy.dengqi.org/https://github.com/zyedidia/eget/releases/download/v$EGET_RELEASE/eget-$EGET_RELEASE-linux_$ARCH.tar.gz"
	mkdir -p /tmp/install
	echo "download... $EGET_URL"
	wget -O /tmp/install/eget.tar.gz $EGET_URL
	echo "extracting... eget.tar.gz"
	tar -xzf /tmp/install/eget.tar.gz -C /tmp/install
	cd "/tmp/install/eget-$EGET_RELEASE-linux_$ARCH"
	sudo cp eget /usr/local/bin/eget
	sudo chmod +x /usr/local/bin/eget
	sudo cp eget.1 /usr/local/share/man/man1/eget.1
}


# @brief Install fastfetch system information tool from source
# @return 0 on success
# @example install_fastfetch
# @category tools
install_fastfetch() {
  green_echo "======================================"
  green_echo "=========Install fastfetch========"
  green_echo "======================================"
  if test_brew_command; then
    brew install fastfetch
    return 0
  fi
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
    if test_brew_command; then
        brew install gh
        return 0
    fi
    local example_url="https://github.com/cli/cli/releases/download/v2.73.0/gh_2.73.0_linux_amd64.tar.gz" # 从 install_modern_tools_by_download 列表获取
    local install_prefix="$HOME/.local"

    if command -v batch_smart_download_tools >/dev/null 2>&1; then
        batch_smart_download_tools "$example_url" "$install_prefix"
        return $?
    else
        echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
        echo "   尝试使用旧方法回退安装 gh... (可能已移除)" >&2
        # Fallback to old method (which should ideally be removed or also made smart if kept)
        # For now, demonstrating the call to batch_smart_download_tools is the primary goal.
        # The original old code for gh was complex and is superseded.
        return 1
    fi
}

# @brief Install zellij terminal editor intelligently
# @return 0 on success
# @example install_zellij
# @category tools
install_zellij(){
    echo "🚀 智能安装 zellij..."
    if test_brew_command; then
        brew install zellij
        return 0
    fi
    local example_url="https://github.com/zellij-org/zellij/releases/download/v0.42.2/zellij-x86_64-unknown-linux-musl.tar.gz" # 从 install_modern_tools_by_download 列表获取
    local install_prefix="$HOME/.local"

    if command -v batch_smart_download_tools >/dev/null 2>&1; then
        batch_smart_download_tools "$example_url" "$install_prefix"
        return $?
    else
        echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
        echo "   尝试使用旧方法回退安装 zellij... (可能已移除)" >&2
        # Fallback to old method (which should ideally be removed or also made smart if kept)
        # For now, demonstrating the call to batch_smart_download_tools is the primary goal.
        # The original old code for gh was complex and is superseded.
        return 1
    fi
}

# @brief Install fzf fuzzy finder intelligently
# @return 0 on success
# @example install_fzf
# @category tools
install_fzf(){
    echo "🚀 智能安装 fzf..."
    if test_brew_command; then
        brew install fzf
        return 0
    fi
    local example_url="https://github.com/junegunn/fzf/releases/download/v0.62.0/fzf-0.62.0-linux_amd64.tar.gz" # 从 install_modern_tools_by_download 列表获取
    local install_prefix="$HOME/.local"

    if command -v batch_smart_download_tools >/dev/null 2>&1; then
        batch_smart_download_tools "$example_url" "$install_prefix"
        # fzf also needs its shell integrations installed.
        # The smart_install_downloaded function might handle some of this if completions/scripts are in standard locations.
        # However, fzf often requires sourcing specific files or running an install script found within its extracted contents.
        # This part might need additional logic after batch_smart_download_tools if the generic install isn't enough.
        echo "请记得根据 fzf 的文档或提示，确保其 shell 集成 (key bindings, completion) 已正确配置。"
        echo "通常这涉及到在 .zshrc 或类似文件中 source 一些脚本，或者运行解压后的 fzf/install 脚本。"
        echo "智能安装程序会尝试将可执行文件放到 $install_prefix/bin，并将补全脚本放到标准位置。"
        return $?
    else
        echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
        return 1
    fi
}

# @brief Install eza modern ls replacement intelligently
# @return 0 on success
# @example install_eza
# @category tools
install_eza(){
    echo "🚀 智能安装 eza..."
    if test_brew_command; then
        brew install eza
        return 0
    fi
    local example_url="https://github.com/eza-community/eza/releases/download/v0.21.3/eza_x86_64-unknown-linux-gnu.tar.gz" # 从 install_modern_tools_by_download 列表获取
    local install_prefix="$HOME/.local"

    if command -v batch_smart_download_tools >/dev/null 2>&1; then
        batch_smart_download_tools "$example_url" "$install_prefix"
        return $?
    else
        echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
        return 1
    fi
}

# @brief Install lazygit Git TUI
# @return 0 on success
# @example install_lazygit
# @category tools
install_lazygit(){
    echo "🚀 智能安装 lazygit..."
    if test_brew_command; then
        brew install lazygit
        return 0
    fi
    local example_url="https://github.com/jesseduffield/lazygit/releases/download/v0.51.1/lazygit_0.51.1_Linux_x86_64.tar.gz" # 从 install_modern_tools_by_download 列表获取
    local install_prefix="$HOME/.local"

    if command -v batch_smart_download_tools >/dev/null 2>&1; then
        batch_smart_download_tools "$example_url" "$install_prefix"
        return $?
    else
        echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
        return 1 # Or fallback to old method if one existed and was simple enough
    fi
}

# @brief Install lazydocker Docker TUI
# @return 0 on success
# @example install_lazydocker
# @category tools
install_lazydocker(){
    echo "🚀 智能安装 lazydocker..."
    if test_brew_command; then
        brew install lazydocker
        return 0
    fi
    # 注意: 下面的 URL 是基于常见模式推测的，如果 lazydocker 的发布资源命名不同，可能需要调整。
    # 或者，确保此工具包含在 install_modern_tools_by_download 的 URL 列表中以获得更准确的模式学习。
    local example_url="https://github.com/jesseduffield/lazydocker/releases/download/v0.23.1/lazydocker_0.23.1_Linux_x86_64.tar.gz" # 推测的示例 URL
    local install_prefix="$HOME/.local"

    if command -v batch_smart_download_tools >/dev/null 2>&1; then
        batch_smart_download_tools "$example_url" "$install_prefix"
        return $?
    else
        echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
        return 1
    fi
}

# @brief Install duf disk usage utility
# @return 0 on success
# @example install_duf
# @category tools
install_duf(){
    echo "🚀 智能安装 duf..."
    if test_brew_command; then
        brew install duf
        return 0
    fi
    local example_url="https://github.com/muesli/duf/releases/download/v0.8.1/duf_0.8.1_linux_x86_64.tar.gz" # 从 install_modern_tools_by_download 列表获取
    local install_prefix="$HOME/.local"

    if command -v batch_smart_download_tools >/dev/null 2>&1; then
        batch_smart_download_tools "$example_url" "$install_prefix"
        return $?
    else
        echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
        return 1
    fi
}

# @brief Install gdu disk usage analyzer
# @return 0 on success
# @example install_gdu
# @category tools
install_gdu(){
    echo "🚀 智能安装 gdu..."
    if test_brew_command; then
        brew install gdu
        return 0
    fi
    local example_url="https://github.com/dundee/gdu/releases/download/v5.30.1/gdu_linux_amd64.tgz" # 从 install_modern_tools_by_download 列表获取
    local install_prefix="$HOME/.local"

    if command -v batch_smart_download_tools >/dev/null 2>&1; then
        batch_smart_download_tools "$example_url" "$install_prefix"
        return $?
    else
        echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
        return 1
    fi
}

# @brief Install ripgrep fast text search tool intelligently
# @return 0 on success
# @example install_ripgrep
# @category tools
install_ripgrep(){
    echo "🚀 智能安装 ripgrep..."
    if test_brew_command; then
        brew install ripgrep
        return 0
    fi
    local example_url="https://github.com/BurntSushi/ripgrep/releases/download/v14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz" # 从 install_modern_tools_by_download 列表获取
    local install_prefix="$HOME/.local"

    if command -v batch_smart_download_tools >/dev/null 2>&1; then
        batch_smart_download_tools "$example_url" "$install_prefix"
        return $?
    else
        echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
        return 1
    fi
}

# @brief Install fd fast file finder
# @return 0 on success
# @example install_fd
# @category tools
install_fd(){
    echo "🚀 智能安装 fd..."
    if test_brew_command; then
        brew install fd
        return 0
    fi
    local example_url="https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz" # 从 install_modern_tools_by_download 列表获取
    local install_prefix="$HOME/.local"

    if command -v batch_smart_download_tools >/dev/null 2>&1; then
        batch_smart_download_tools "$example_url" "$install_prefix"
        return $?
    else
        echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
        return 1
    fi
}

# @brief Install mise runtime version manager
# @return 0 on success
# @example install_mise
# @category tools
install_mise(){
    echo "🚀 智能安装 mise..."
    if test_brew_command; then
        brew install mise
        return 0
    fi
    # 根据其传统安装逻辑，推测的示例 URL。musl 版本，架构为 x64/arm64。
    local example_url="https://github.com/jdx/mise/releases/download/v2024.7.1/mise-v2024.7.1-linux-x64-musl.tar.xz"
    local install_prefix="$HOME/.local" # mise 通常期望安装到特定目录，然后符号链接，但 smart_install 会处理到 $HOME/.local/bin

    if command -v batch_smart_download_tools >/dev/null 2>&1; then
        # smart_install_downloaded 会将可执行文件放到 $install_prefix/bin (即 $HOME/.local/bin/mise)
        # mise 的激活 (eval "$(mise activate zsh)") 仍然需要用户在 .zshrc 中配置，
        # 或者依赖于 $HOME/.local/bin 在 PATH 中且 mise 能够自激活。
        # 对于 mise，我们智能安装其二进制文件。其 shell 集成和环境管理是其核心功能，需按其文档操作。
        batch_smart_download_tools "$example_url" "$install_prefix"
        if [[ $? -eq 0 ]]; then
             echo "✅ mise 二进制文件已尝试安装到 $install_prefix/bin。"
             echo "   请确保根据 mise 文档完成 shell 集成 (例如，在 .zshrc 中添加 'eval "$(mise activate zsh)"')。"
             return 0
        else
            echo "❌ mise 安装失败。"
            return 1
        fi
    else
        echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
        return 1
    fi
}

# @brief Install asdf version manager
# @return 0 on success
# @example install_asdf
# @category tools
install_asdf(){
  green_echo "======================================"
  green_echo "=========Install asdf========"
  green_echo "======================================"
  if test_brew_command; then
    brew install asdf
    return 0
  fi
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
    if test_brew_command; then
        brew install xray
        return 0
    fi
    # Xray-core 的资源名通常是 Xray-linux-64.zip 或 Xray-linux-arm64-v8a.zip
    local example_url="https://github.com/XTLS/Xray-core/releases/download/v1.8.10/Xray-linux-64.zip"
    local install_prefix="$HOME/.local"

    if command -v batch_smart_download_tools >/dev/null 2>&1; then
        batch_smart_download_tools "$example_url" "$install_prefix"
        # Xray 安装后通常需要配置文件，这超出了智能安装的范围
        if [[ $? -eq 0 ]]; then
            echo "✅ Xray 二进制文件已尝试安装到 $install_prefix/bin。"
            echo "   请记得为 Xray 配置 config.json。"
            return 0
        else
            echo "❌ Xray 安装失败。"
            return 1
        fi
    else
        echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
        return 1
    fi
}

# @brief Install sing-box proxy tool intelligently
# @return 0 on success
# @example install_sing_box
# @category tools
install_sing_box(){
    echo "🚀 智能安装 sing-box..."
    if test_brew_command; then
        brew install sing-box
        return 0
    fi
    local example_url="https://github.com/SagerNet/sing-box/releases/download/v1.9.0/sing-box-1.9.0-linux-amd64.tar.gz" # 推测的示例 URL
    local install_prefix="$HOME/.local"

    if command -v batch_smart_download_tools >/dev/null 2>&1; then
        batch_smart_download_tools "$example_url" "$install_prefix"
        if [[ $? -eq 0 ]]; then
            echo "✅ sing-box 二进制文件已尝试安装到 $install_prefix/bin。"
            echo "   请记得为 sing-box 配置 config.json。"
            return 0
        else
            echo "❌ sing-box 安装失败。"
            return 1
        fi
    else
        echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
        return 1
    fi
}

# @brief Install mihomo (Clash Meta) proxy tool intelligently
# @return 0 on success
# @example install_mihomo
# @category tools
install_mihomo(){
    echo "🚀 智能安装 mihomo (Clash Meta)..."
    if test_brew_command; then
        brew install mihomo
        return 0
    fi
    # mihomo 的资源名通常是 mihomo-linux-amd64-vX.Y.Z.gz
    local example_url="https://github.com/MetaCubeX/mihomo/releases/download/v1.18.4/mihomo-linux-amd64-v1.18.4.gz"
    local install_prefix="$HOME/.local"

    if command -v batch_smart_download_tools >/dev/null 2>&1; then
        batch_smart_download_tools "$example_url" "$install_prefix"
        if [[ $? -eq 0 ]]; then
            echo "✅ mihomo 二进制文件已尝试安装到 $install_prefix/bin。"
            echo "   请记得为 mihomo (Clash Meta) 配置 config.yaml 及 Country.mmdb。"
            return 0
        else
            echo "❌ mihomo 安装失败。"
            return 1
        fi
    else
        echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
        return 1
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
    local requested_install_prefix="${1:-$HOME/.local}"
    echo "📞 调用批量智能下载安装现代工具 (URL 学习模式) 到 '$requested_install_prefix'..." >&2

    # 定义工具的示例 GitHub Release 下载 URL 列表
    local -a example_tool_urls=(
        "https://github.com/BurntSushi/ripgrep/releases/download/v14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz"
        "https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz"
        "https://github.com/eza-community/eza/releases/download/v0.21.3/eza_x86_64-unknown-linux-gnu.tar.gz"
        "https://github.com/sharkdp/bat/releases/download/v0.25.0/bat-v0.25.0-x86_64-unknown-linux-gnu.tar.gz"
        "https://github.com/junegunn/fzf/releases/download/v0.62.0/fzf-0.62.0-linux_amd64.tar.gz"
        "https://github.com/jesseduffield/lazygit/releases/download/v0.51.1/lazygit_0.51.1_Linux_x86_64.tar.gz"
        "https://github.com/cli/cli/releases/download/v2.73.0/gh_2.73.0_linux_amd64.tar.gz"
        "https://github.com/muesli/duf/releases/download/v0.8.1/duf_0.8.1_linux_x86_64.tar.gz"
        "https://github.com/bootandy/dust/releases/download/v1.2.0/dust-v1.2.0-x86_64-unknown-linux-gnu.tar.gz"
        "https://github.com/dundee/gdu/releases/download/v5.30.1/gdu_linux_amd64.tgz"
        "https://github.com/dalance/procs/releases/download/v0.14.0/procs-v0.14.0-x86_64-linux.tar.gz"
        "https://github.com/chmln/sd/releases/download/v0.9.0/sd-v0.9.0-x86_64-unknown-linux-gnu.tar.gz"
        # "https://github.com/XAMPPRocky/tokei/releases/download/v14.1.0/tokei-x86_64-unknown-linux-gnu.tar.gz" # Example
        "https://github.com/sharkdp/hyperfine/releases/download/v1.17.0/hyperfine-v1.17.0-x86_64-unknown-linux-gnu.tar.gz"
        "https://github.com/dandavison/delta/releases/download/0.20.1/delta-0.20.1-x86_64-unknown-linux-gnu.tar.gz"
        "https://github.com/dbrgn/tealdeer/releases/download/v1.8.0/tealdeer-v1.8.0-x86_64-unknown-linux-gnu.tar.gz"
        "https://github.com/zellij-org/zellij/releases/download/v0.42.2/zellij-x86_64-unknown-linux-musl.tar.gz"
        # Add more URLs here
    )

    if ! command -v batch_smart_download_tools >/dev/null 2>&1; then
        echo "❌ install_modern_tools_by_download: 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
        return 1
    fi

    # Call the main batch processing function from utils.zsh
    # Pass the array éléments and then the install prefix
    batch_smart_download_tools "${example_tool_urls[@]}" "$requested_install_prefix"
    return $? # Return the status of the batch processing
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

install_modern_tools_brew(){
  brew install fastfetch gh zellij fzf eza \
   lazygit lazydocker duf gdu ripgrep fd \
   rclone bat hyperfine delta tealdeer zoxide starship \
   jq bottom procs tokei ripgrep-all sd dust git
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
