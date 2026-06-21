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
# Unified I/O framework for tools.zsh
# ===================================================================
# Goal: consistent stdout/stderr separation, optional quiet/JSON/TSV/dry-run
# modes, and stdin support for batch functions.
#
# Inside a function that needs options:
#   __tools_parse_args "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
#   # IMPORTANT: snapshot flags into locals BEFORE calling any nested function
#   # that also calls __tools_parse_args (it resets all ZSH_TOOLS_* globals).
#   local _my_json=$ZSH_TOOLS_JSON _my_quiet=$ZSH_TOOLS_QUIET
#   local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
#
# Output helpers (always use printf, never echo, to avoid \t/\n/-n surprises):
#   __tools_info  "progress"    -> stderr (unless --quiet)
#   __tools_success "success"   -> stderr (unless --quiet)
#   __tools_warn  "warning"     -> stderr (always)
#   __tools_error "error"       -> stderr (always)
#   __tools_output "data"       -> stdout (always)
#   __tools_data "data"         -> stdout (always)
#
# Helpers:
#   __tools_json_escape <str>   -> escape \\ and " for JSON string content
#   __tools_read_stdin_or_args "$@"
#     # When called with args, uses them.
#     # When called with no args AND the SINGLE arg "-" was originally passed,
#     # reads stdin. To keep callers explicit, batch funcs forward args as-is;
#     # they pass an explicit sentinel "-" to request stdin reading.
# ===================================================================

typeset -g ZSH_TOOLS_QUIET=0
typeset -g ZSH_TOOLS_JSON=0
typeset -g ZSH_TOOLS_TSV=0
typeset -g ZSH_TOOLS_DRY_RUN=0
typeset -g ZSH_TOOLS_HELP=0
typeset -g ZSH_TOOLS_FORMAT="human"
typeset -g ZSH_TOOLS_OPT_INDEX=1

# @brief Parse common options and set global I/O flags
# @param $* All arguments passed to the calling function
# @return 0 on success, 1 on unknown option, 2 on --help (caller should print help)
# @example __tools_parse_args "$@" || return $?
# @category tools
__tools_parse_args() {
    ZSH_TOOLS_QUIET=0
    ZSH_TOOLS_JSON=0
    ZSH_TOOLS_TSV=0
    ZSH_TOOLS_DRY_RUN=0
    ZSH_TOOLS_HELP=0
    ZSH_TOOLS_FORMAT="human"
    ZSH_TOOLS_OPT_INDEX=1

    while [[ $ZSH_TOOLS_OPT_INDEX -le $# ]]; do
        local arg="${@[$ZSH_TOOLS_OPT_INDEX]}"
        case "$arg" in
            -q|--quiet) ZSH_TOOLS_QUIET=1 ;;
            --json) ZSH_TOOLS_JSON=1; ZSH_TOOLS_FORMAT="json" ;;
            --tsv) ZSH_TOOLS_TSV=1; ZSH_TOOLS_FORMAT="tsv" ;;
            --dry-run|--dryrun) ZSH_TOOLS_DRY_RUN=1 ;;
            -h|--help) ZSH_TOOLS_HELP=1; return 2 ;;
            --) ((ZSH_TOOLS_OPT_INDEX++)); return 0 ;;
            -)  return 0 ;;  # bare "-" is a positional sentinel, not an option
            -*) __tools_error "Unknown option: $arg"; return 1 ;;
            *)  return 0 ;;
        esac
        ((ZSH_TOOLS_OPT_INDEX++))
    done
    return 0
}

__tools_info()    { [[ $ZSH_TOOLS_QUIET -eq 0 ]] && printf '%s\n' "$*" >&2; return 0; }
__tools_success() { [[ $ZSH_TOOLS_QUIET -eq 0 ]] && printf '%s\n' "$*" >&2; return 0; }
__tools_warn()    { printf '%s\n' "$*" >&2; }
__tools_error()   { printf '%s\n' "$*" >&2; }
__tools_output()  { printf '%s\n' "$*"; }
__tools_data()    { printf '%s\n' "$*"; }

# @brief Standard parse_args entry for callers; prints $1 (usage) on -h/--help.
# @description Use as:
#   __tools_parse_or_help "Usage: install_fzf [-q] [--dry-run] [prefix]" "$@" \
#     || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
#   ZSH_TOOLS_HELP=0  # (already reset by parse_args next call)
# @param $1 Usage string
# @param $@ Forwarded to __tools_parse_args
# @return same as __tools_parse_args, but on rc=2 also prints usage to stdout
# @category tools
__tools_parse_or_help() {
    local _usage="$1"; shift
    __tools_parse_args "$@"
    local _rc=$?
    if [[ $_rc -eq 2 ]]; then
        __tools_output "$_usage"
    elif [[ $_rc -ne 0 ]]; then
        printf '%s\n' "$_usage" >&2
    fi
    return $_rc
}

# @brief Escape a string for embedding in a JSON string literal
# @description Escapes \ and " (other control chars rare in our domain are left as-is).
# @param $1 Raw string
# @return prints escaped string on stdout
# @example __tools_json_escape 'a"b\c'
# @category tools
__tools_json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    printf '%s' "$s"
}

# @brief Read input lines from stdin when caller passes the "-" sentinel
# @description Args take priority. If args are exactly ("-"), reads stdin.
#              Otherwise uses args as-is. Never silently consumes script stdin.
# @param $* Positional arguments
# @sets ZSH_TOOLS_INPUT_LINES
# @example __tools_read_stdin_or_args "$@"
# @example printf "fzf\nbat\n" | install_batch_modern -
# @category tools
__tools_read_stdin_or_args() {
    typeset -g ZSH_TOOLS_INPUT_LINES=()
    if [[ $# -eq 1 && "$1" == "-" ]]; then
        local line
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" ]] && continue
            ZSH_TOOLS_INPUT_LINES+=("$line")
        done
        return 0
    fi
    if [[ $# -gt 0 ]]; then
        ZSH_TOOLS_INPUT_LINES=("$@")
        return 0
    fi
    # No args, no sentinel: leave ZSH_TOOLS_INPUT_LINES empty so caller can
    # fall back to its default list. Do NOT consume parent stdin.
    return 0
}

# @brief Common single-tool installer via smart download or Homebrew
# @param $1 Tool name (also brew formula by default)
# @param $2 Example GitHub release URL used by batch_smart_download_tools
# @param $3 Optional install prefix (default $HOME/.local)
# @param $4 Optional brew formula override (when differs from tool name)
# @return 0 on success, 1 on failure
# @example __install_tool_by_download "fzf" "https://github.com/junegunn/fzf/releases/..." "$HOME/.local"
# @category tools
__install_tool_by_download() {
    local tool_name="$1"
    local example_url="$2"
    local install_prefix="${3:-$HOME/.local}"
    local brew_formula="${4:-$tool_name}"

    if [[ -z "$tool_name" || -z "$example_url" ]]; then
        __tools_error "Usage: __install_tool_by_download <tool_name> <example_url> [install_prefix] [brew_formula]"
        return 1
    fi

    __tools_info "🚀 智能安装 $tool_name..."
    if test_brew_command >/dev/null 2>&1; then
        if [[ $ZSH_TOOLS_DRY_RUN -eq 1 ]]; then
            __tools_info "🔍 [dry-run] brew install $brew_formula"
            return 0
        fi
        __tools_info "📦 使用 Homebrew 安装 $brew_formula..."
        brew install "$brew_formula"
        return $?
    fi

    if [[ $ZSH_TOOLS_DRY_RUN -eq 1 ]]; then
        __tools_info "🔍 [dry-run] 将从 $example_url 下载并安装 $tool_name 到 $install_prefix"
        return 0
    fi

    if command -v batch_smart_download_tools >/dev/null 2>&1; then
        batch_smart_download_tools "$example_url" "$install_prefix"
        return $?
    else
        __tools_error "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。"
        return 1
    fi
}

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

# @brief Check installed versions of modern tools
# @option --quiet Suppress header/trailer and only emit data rows
# @option --json Output JSON array instead of human-readable text
# @option --tsv Output tab-separated values (tool<TAB>installed<TAB>version)
# @option --dry-run Show what would be checked without checking
# @return 0 on success
# @example check-tool-updates
# @example check-tool-updates --json
# @example check-tool-updates --tsv
# @category tools
check-tool-updates() {
    __tools_parse_args "$@"
    local pa_rc=$?
    if [[ $pa_rc -eq 2 ]]; then
        __tools_output "Usage: check-tool-updates [-q|--quiet] [--json|--tsv] [--dry-run] [-h|--help]"
        return 0
    fi
    [[ $pa_rc -ne 0 ]] && return $pa_rc

    # Snapshot flags so nested calls cannot reset them mid-flow.
    local _json=$ZSH_TOOLS_JSON _tsv=$ZSH_TOOLS_TSV _quiet=$ZSH_TOOLS_QUIET _dry=$ZSH_TOOLS_DRY_RUN

    local tools=(fzf rg fd bat starship lazygit nvim)
    local -a data=()
    local tool version

    for tool in "${tools[@]}"; do
        version=$($tool --version 2>/dev/null | head -n1 | awk '{print $2}')
        if [[ -n "$version" ]]; then
            data+=("$tool|yes|$version")
        else
            data+=("$tool|no|null")
        fi
    done

    if [[ $_dry -eq 1 ]]; then
        ZSH_TOOLS_QUIET=$_quiet
        __tools_info "🔍 [dry-run] 将检查 ${#tools[@]} 个工具的版本"
        return 0
    fi

    if [[ $_json -eq 1 ]]; then
        if command -v python3 >/dev/null 2>&1; then
            # Pipe data via stdin to avoid any shell/Python source injection.
            printf '%s\n' "${data[@]}" | python3 -c '
import json, sys
out = []
for line in sys.stdin:
    line = line.rstrip("\n")
    if not line:
        continue
    tool, installed, version = line.split("|", 2)
    out.append({"tool": tool, "installed": installed == "yes", "version": None if version == "null" else version})
print(json.dumps(out, ensure_ascii=False))
'
        else
            __tools_output "["
            local -a json_lines=()
            local entry t iv v v_json esc_t esc_v installed_json
            for entry in "${data[@]}"; do
                IFS='|' read -r t iv v <<< "$entry"
                esc_t=$(__tools_json_escape "$t")
                if [[ "$v" == "null" ]]; then
                    v_json="null"
                else
                    esc_v=$(__tools_json_escape "$v")
                    v_json="\"$esc_v\""
                fi
                [[ "$iv" == "yes" ]] && installed_json="true" || installed_json="false"
                json_lines+=("  {\"tool\":\"$esc_t\",\"installed\":$installed_json,\"version\":$v_json}")
            done
            local i n=${#json_lines[@]}
            for ((i=1; i<=n; i++)); do
                if [[ $i -lt $n ]]; then
                    __tools_output "${json_lines[$i]},"
                else
                    __tools_output "${json_lines[$i]}"
                fi
            done
            __tools_output "]"
        fi
    elif [[ $_tsv -eq 1 ]]; then
        __tools_output $'tool\tinstalled\tversion'
        local entry t iv v
        for entry in "${data[@]}"; do
            IFS='|' read -r t iv v <<< "$entry"
            printf '%s\t%s\t%s\n' "$t" "$iv" "$v"
        done
    else
        ZSH_TOOLS_QUIET=$_quiet
        __tools_info "🔍 检查工具更新状态..."
        local entry t iv v
        for entry in "${data[@]}"; do
            IFS='|' read -r t iv v <<< "$entry"
            if [[ "$iv" == "yes" ]]; then
                __tools_output "🔍 $t: 当前版本 $v"
            else
                __tools_output "🔍 $t: ❌ 未安装"
            fi
        done
        __tools_info ""
        __tools_info "💡 运行 'upgrade-tools' 来升级所有工具"
    fi
    return 0
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
        ["i386"]="386"
        ["i686"]="386"
        ["arm64"]="arm64"
        ["aarch64"]="arm64"
        ["armv8l"]="arm"
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
    sudo mkdir -p /usr/local/share/man/man1
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
# @param $1 Optional install prefix (default $HOME/.local)
# @return 0 on success
# @example install_gh
# @example install_gh --quiet
# @example install_gh /usr/local
# @category tools
install_gh(){
    __tools_parse_or_help "Usage: install_gh [-q|--quiet] [--dry-run] [-h|--help] [install_prefix]" "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local install_prefix="${args[1]:-$HOME/.local}"
    __install_tool_by_download "gh" "https://github.com/cli/cli/releases/download/v2.73.0/gh_2.73.0_linux_amd64.tar.gz" "$install_prefix"
}

# @brief Install zellij terminal editor intelligently
# @param $1 Optional install prefix (default $HOME/.local)
# @return 0 on success
# @example install_zellij
# @example install_zellij --quiet
# @example install_zellij /usr/local
# @category tools
install_zellij(){
    __tools_parse_or_help "Usage: install_zellij [-q|--quiet] [--dry-run] [-h|--help] [install_prefix]" "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local install_prefix="${args[1]:-$HOME/.local}"
    __install_tool_by_download "zellij" "https://github.com/zellij-org/zellij/releases/download/v0.42.2/zellij-x86_64-unknown-linux-musl.tar.gz" "$install_prefix"
}

# @brief Install fzf fuzzy finder intelligently
# @param $1 Optional install prefix (default $HOME/.local)
# @return 0 on success
# @example install_fzf
# @example install_fzf --quiet
# @example install_fzf /usr/local
# @category tools
install_fzf(){
    __tools_parse_or_help "Usage: install_fzf [-q|--quiet] [--dry-run] [-h|--help] [install_prefix]" "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local install_prefix="${args[1]:-$HOME/.local}"
    __install_tool_by_download "fzf" "https://github.com/junegunn/fzf/releases/download/v0.62.0/fzf-0.62.0-linux_amd64.tar.gz" "$install_prefix"
    local rc=$?
    if [[ $rc -eq 0 && $ZSH_TOOLS_QUIET -eq 0 && $ZSH_TOOLS_DRY_RUN -eq 0 ]]; then
        __tools_info "💡 请确保 fzf 的 shell 集成 (key bindings, completion) 已正确配置。"
    fi
    return $rc
}

# @brief Install eza modern ls replacement intelligently
# @param $1 Optional install prefix (default $HOME/.local)
# @return 0 on success
# @example install_eza
# @example install_eza --quiet
# @example install_eza /usr/local
# @category tools
install_eza(){
    __tools_parse_or_help "Usage: install_eza [-q|--quiet] [--dry-run] [-h|--help] [install_prefix]" "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local install_prefix="${args[1]:-$HOME/.local}"
    __install_tool_by_download "eza" "https://github.com/eza-community/eza/releases/download/v0.21.3/eza_x86_64-unknown-linux-gnu.tar.gz" "$install_prefix"
}

# @brief Install lazygit Git TUI
# @param $1 Optional install prefix (default $HOME/.local)
# @return 0 on success
# @example install_lazygit
# @example install_lazygit --quiet
# @example install_lazygit /usr/local
# @category tools
install_lazygit(){
    __tools_parse_or_help "Usage: install_lazygit [-q|--quiet] [--dry-run] [-h|--help] [install_prefix]" "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local install_prefix="${args[1]:-$HOME/.local}"
    __install_tool_by_download "lazygit" "https://github.com/jesseduffield/lazygit/releases/download/v0.51.1/lazygit_0.51.1_Linux_x86_64.tar.gz" "$install_prefix"
}

# @brief Install lazydocker Docker TUI
# @param $1 Optional install prefix (default $HOME/.local)
# @return 0 on success
# @example install_lazydocker
# @example install_lazydocker --quiet
# @example install_lazydocker /usr/local
# @category tools
install_lazydocker(){
    __tools_parse_or_help "Usage: install_lazydocker [-q|--quiet] [--dry-run] [-h|--help] [install_prefix]" "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local install_prefix="${args[1]:-$HOME/.local}"
    # 注意: 下面的 URL 是基于常见模式推测的，如果 lazydocker 的发布资源命名不同，可能需要调整。
    __install_tool_by_download "lazydocker" "https://github.com/jesseduffield/lazydocker/releases/download/v0.23.1/lazydocker_0.23.1_Linux_x86_64.tar.gz" "$install_prefix"
}

# @brief Install duf disk usage utility
# @param $1 Optional install prefix (default $HOME/.local)
# @return 0 on success
# @example install_duf
# @example install_duf --quiet
# @example install_duf /usr/local
# @category tools
install_duf(){
    __tools_parse_or_help "Usage: install_duf [-q|--quiet] [--dry-run] [-h|--help] [install_prefix]" "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local install_prefix="${args[1]:-$HOME/.local}"
    __install_tool_by_download "duf" "https://github.com/muesli/duf/releases/download/v0.8.1/duf_0.8.1_linux_x86_64.tar.gz" "$install_prefix"
}

# @brief Install gdu disk usage analyzer
# @param $1 Optional install prefix (default $HOME/.local)
# @return 0 on success
# @example install_gdu
# @example install_gdu --quiet
# @example install_gdu /usr/local
# @category tools
install_gdu(){
    __tools_parse_or_help "Usage: install_gdu [-q|--quiet] [--dry-run] [-h|--help] [install_prefix]" "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local install_prefix="${args[1]:-$HOME/.local}"
    __install_tool_by_download "gdu" "https://github.com/dundee/gdu/releases/download/v5.30.1/gdu_linux_amd64.tgz" "$install_prefix"
}

# @brief Install ripgrep fast text search tool intelligently
# @param $1 Optional install prefix (default $HOME/.local)
# @return 0 on success
# @example install_ripgrep
# @example install_ripgrep --quiet
# @example install_ripgrep /usr/local
# @category tools
install_ripgrep(){
    __tools_parse_or_help "Usage: install_ripgrep [-q|--quiet] [--dry-run] [-h|--help] [install_prefix]" "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local install_prefix="${args[1]:-$HOME/.local}"
    __install_tool_by_download "ripgrep" "https://github.com/BurntSushi/ripgrep/releases/download/v14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz" "$install_prefix"
}

# @brief Install fd fast file finder
# @param $1 Optional install prefix (default $HOME/.local)
# @return 0 on success
# @example install_fd
# @example install_fd --quiet
# @example install_fd /usr/local
# @category tools
install_fd(){
    __tools_parse_or_help "Usage: install_fd [-q|--quiet] [--dry-run] [-h|--help] [install_prefix]" "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local install_prefix="${args[1]:-$HOME/.local}"
    __install_tool_by_download "fd" "https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz" "$install_prefix"
}

# @brief Install mise runtime version manager
# @param $1 Optional install prefix (default $HOME/.local)
# @return 0 on success
# @example install_mise
# @example install_mise --quiet
# @example install_mise /usr/local
# @category tools
install_mise(){
    __tools_parse_or_help "Usage: install_mise [-q|--quiet] [--dry-run] [-h|--help] [install_prefix]" "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local install_prefix="${args[1]:-$HOME/.local}"
    # 根据其传统安装逻辑，推测的示例 URL。musl 版本，架构为 x64/arm64。
    __install_tool_by_download "mise" "https://github.com/jdx/mise/releases/download/v2024.7.1/mise-v2024.7.1-linux-x64-musl.tar.xz" "$install_prefix"
    local rc=$?
    if [[ $rc -eq 0 && $ZSH_TOOLS_QUIET -eq 0 && $ZSH_TOOLS_DRY_RUN -eq 0 ]]; then
        __tools_info "✅ mise 二进制文件已尝试安装到 $install_prefix/bin。"
        __tools_info '   请确保根据 mise 文档完成 shell 集成 (例如，在 .zshrc 中添加 eval "$(mise activate zsh)" )。'
    fi
    return $rc
}


# @brief Install asdf version manager
# @param $1 Optional install prefix (default $HOME/.local/share/asdf)
# @option --quiet Suppress progress messages
# @return 0 on success
# @example install_asdf
# @example install_asdf --quiet
# @category tools
install_asdf(){
  __tools_parse_or_help "Usage: install_asdf [-q|--quiet] [--dry-run] [-h|--help] [install_prefix]" "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
  local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
  local install_prefix="${args[1]:-$ASDF_DIR}"
  __tools_info "======================================"
  __tools_info "=========Install asdf========"
  __tools_info "======================================"
  if test_brew_command >/dev/null 2>&1; then
    brew install asdf
    return 0
  fi
  if [[ -d $install_prefix ]]; then
    __tools_info "=========asdf already installed, updating======"
    cd "$install_prefix" || { __tools_error "❌ 无法进入 $install_prefix"; return 1; }
    git pull
    __tools_info "========asdf updated========"
  else
    __tools_info "=========installing asdf======"
    git clone https://github.com/asdf-vm/asdf.git "$install_prefix"
    __tools_info "=========asdf installed======"
  fi
}

# @brief Install Xray proxy tool intelligently
# @param $1 Optional install prefix (default $HOME/.local)
# @return 0 on success
# @example install_xray
# @example install_xray --quiet
# @example install_xray /usr/local
# @category tools
install_xray(){
    __tools_parse_or_help "Usage: install_xray [-q|--quiet] [--dry-run] [-h|--help] [install_prefix]" "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local install_prefix="${args[1]:-$HOME/.local}"
    # Xray-core 的资源名通常是 Xray-linux-64.zip 或 Xray-linux-arm64-v8a.zip
    __install_tool_by_download "xray" "https://github.com/XTLS/Xray-core/releases/download/v1.8.10/Xray-linux-64.zip" "$install_prefix"
    local rc=$?
    if [[ $rc -eq 0 && $ZSH_TOOLS_QUIET -eq 0 && $ZSH_TOOLS_DRY_RUN -eq 0 ]]; then
        __tools_info "✅ Xray 二进制文件已尝试安装到 $install_prefix/bin。"
        __tools_info "   请记得为 Xray 配置 config.json。"
    fi
    return $rc
}

# @brief Install sing-box proxy tool intelligently
# @param $1 Optional install prefix (default $HOME/.local)
# @return 0 on success
# @example install_sing_box
# @example install_sing_box --quiet
# @example install_sing_box /usr/local
# @category tools
install_sing_box(){
    __tools_parse_or_help "Usage: install_sing_box [-q|--quiet] [--dry-run] [-h|--help] [install_prefix]" "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local install_prefix="${args[1]:-$HOME/.local}"
    local example_url="https://github.com/SagerNet/sing-box/releases/download/v1.9.0/sing-box-1.9.0-linux-amd64.tar.gz" # 推测的示例 URL
    __install_tool_by_download "sing-box" "$example_url" "$install_prefix"
    local rc=$?
    if [[ $rc -eq 0 && $ZSH_TOOLS_QUIET -eq 0 && $ZSH_TOOLS_DRY_RUN -eq 0 ]]; then
        __tools_info "✅ sing-box 二进制文件已尝试安装到 $install_prefix/bin。"
        __tools_info "   请记得为 sing-box 配置 config.json。"
    fi
    return $rc
}

# @brief Install mihomo (Clash Meta) proxy tool intelligently
# @param $1 Optional install prefix (default $HOME/.local)
# @return 0 on success
# @example install_mihomo
# @example install_mihomo --quiet
# @example install_mihomo /usr/local
# @category tools
install_mihomo(){
    __tools_parse_or_help "Usage: install_mihomo [-q|--quiet] [--dry-run] [-h|--help] [install_prefix]" "$@" || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local install_prefix="${args[1]:-$HOME/.local}"
    # mihomo 的资源名通常是 mihomo-linux-amd64-vX.Y.Z.gz
    local example_url="https://github.com/MetaCubeX/mihomo/releases/download/v1.18.4/mihomo-linux-amd64-v1.18.4.gz"
    __install_tool_by_download "mihomo" "$example_url" "$install_prefix"
    local rc=$?
    if [[ $rc -eq 0 && $ZSH_TOOLS_QUIET -eq 0 && $ZSH_TOOLS_DRY_RUN -eq 0 ]]; then
        __tools_info "✅ mihomo 二进制文件已尝试安装到 $install_prefix/bin。"
        __tools_info "   请记得为 mihomo (Clash Meta) 配置 config.yaml 及 Country.mmdb。"
    fi
    return $rc
}

##
# @brief 批量安装现代命令行工具
# @description 智能安装一套现代化的命令行工具：fzf、ripgrep、fd、bat、eza、lazygit、gh、yazi、bottom
# @description 也可从 stdin 读取工具列表（每行一个），或作为位置参数传入。
# @param $* Optional list of tools to install (overrides default)
# @option --quiet Suppress progress messages
# @option --dry-run Show what would be installed
# @option --json Emit JSON summary instead of human text
# @return 0 全部成功, 1 部分失败
# @example install_batch_modern
# @example echo -e "fzf\nripgrep" | install_batch_modern
# @example install_batch_modern fzf bat --quiet
# @category install
##
install_batch_modern(){
    __tools_parse_args "$@"
    local pa_rc=$?
    if [[ $pa_rc -eq 2 ]]; then
        __tools_output "Usage: install_batch_modern [-q] [--json] [--dry-run] [tool...|-]"
        __tools_output "  Pass '-' as the only argument to read tool names from stdin."
        return 0
    fi
    [[ $pa_rc -ne 0 ]] && return $pa_rc

    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    # Snapshot flags BEFORE nested install_* calls reset them.
    local _json=$ZSH_TOOLS_JSON _quiet=$ZSH_TOOLS_QUIET _dry=$ZSH_TOOLS_DRY_RUN

    __tools_read_stdin_or_args "${args[@]}"

    local default_tools=(fzf ripgrep fd bat eza lazygit gh yazi bottom)
    local -a modern_tools
    if [[ ${#ZSH_TOOLS_INPUT_LINES[@]} -gt 0 ]]; then
        modern_tools=("${ZSH_TOOLS_INPUT_LINES[@]}")
    else
        modern_tools=("${default_tools[@]}")
    fi

    # Restore quiet for our own info call (nested calls will reset again).
    ZSH_TOOLS_QUIET=$_quiet
    __tools_info "🚀 智能批量安装现代命令行工具 (${#modern_tools[@]} 个)..."

    local -a results=()
    local tool rc total_ok=0 total_fail=0

    for tool in "${modern_tools[@]}"; do
        ZSH_TOOLS_QUIET=$_quiet
        __tools_info ""
        __tools_info "📦 安装 $tool..."
        if [[ $_dry -eq 1 ]]; then
            __tools_info "🔍 [dry-run] 将安装 $tool"
            results+=("$tool|dry-run")
            continue
        fi
        rc=0
        if command -v install_smart_tool >/dev/null 2>&1; then
            install_smart_tool "$tool"
            rc=$?
        else
            ZSH_TOOLS_QUIET=$_quiet
            __tools_warn "⚠️  智能安装系统不可用，使用传统方法"
            case "$tool" in
                fzf)      install_fzf;     rc=$? ;;
                ripgrep)  install_ripgrep; rc=$? ;;
                fd)       install_fd;      rc=$? ;;
                eza)      install_eza;     rc=$? ;;
                lazygit)  install_lazygit; rc=$? ;;
                gh)       install_gh;      rc=$? ;;
                *)        __tools_error "❌ 无法安装 $tool"; rc=1 ;;
            esac
        fi
        if [[ $rc -eq 0 ]]; then
            results+=("$tool|ok")
            ((total_ok++))
        else
            results+=("$tool|fail")
            ((total_fail++))
        fi
    done

    if [[ $_json -eq 1 ]]; then
        __tools_output "{"
        __tools_output "  \"total\": ${#modern_tools[@]},"
        __tools_output "  \"ok\": $total_ok,"
        __tools_output "  \"fail\": $total_fail,"
        __tools_output "  \"results\": ["
        local -a json_lines=()
        local entry t s esc_t esc_s
        for entry in "${results[@]}"; do
            IFS='|' read -r t s <<< "$entry"
            esc_t=$(__tools_json_escape "$t")
            esc_s=$(__tools_json_escape "$s")
            json_lines+=("    {\"tool\":\"$esc_t\",\"status\":\"$esc_s\"}")
        done
        local i n=${#json_lines[@]}
        for ((i=1; i<=n; i++)); do
            if [[ $i -lt $n ]]; then
                __tools_output "${json_lines[$i]},"
            else
                __tools_output "${json_lines[$i]}"
            fi
        done
        __tools_output "  ]"
        __tools_output "}"
    else
        ZSH_TOOLS_QUIET=$_quiet
        __tools_info ""
        __tools_info "✅ 现代工具安装完成！($total_ok 成功 / $total_fail 失败 / 共 ${#modern_tools[@]})"
    fi
    [[ $total_fail -gt 0 ]] && return 1
    return 0
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
# @description 默认列表 bat/ripgrep/fd-find/eza/bottom/dust/procs/sd/tokei/hyperfine/delta/tealdeer/zoxide/starship。
# @description 可从 stdin 读取工具列表（每行一个），或作为位置参数传入。
# @param $* Optional tool list to override defaults
# @option --quiet Suppress progress messages
# @option --dry-run Show what would be installed
# @return 0 on success
# @example install_modern_tools_rust
# @example echo "ripgrep" | install_modern_tools_rust
# @example install_modern_tools_rust ripgrep fd --quiet
# @category tools
install_modern_tools_rust() {
    __tools_parse_args "$@"
    local pa_rc=$?
    if [[ $pa_rc -eq 2 ]]; then
        __tools_output "Usage: install_modern_tools_rust [-q] [--dry-run] [tool...|-]"
        return 0
    fi
    [[ $pa_rc -ne 0 ]] && return $pa_rc
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local _quiet=$ZSH_TOOLS_QUIET _dry=$ZSH_TOOLS_DRY_RUN
    __tools_read_stdin_or_args "${args[@]}"

    local default_tools=(
        bat ripgrep fd-find eza bottom dust procs sd tokei
        hyperfine delta tealdeer zoxide starship
    )
    local -a rust_tools
    if [[ ${#ZSH_TOOLS_INPUT_LINES[@]} -gt 0 ]]; then
        rust_tools=("${ZSH_TOOLS_INPUT_LINES[@]}")
    else
        rust_tools=("${default_tools[@]}")
    fi

    ZSH_TOOLS_QUIET=$_quiet
    __tools_info "🦀 安装现代 Rust 工具 (${#rust_tools[@]} 个)..."

    local tool
    for tool in "${rust_tools[@]}"; do
        ZSH_TOOLS_QUIET=$_quiet
        __tools_info "📦 安装 $tool..."
        if [[ $_dry -eq 1 ]]; then
            __tools_info "🔍 [dry-run] 将安装 $tool"
            continue
        fi
        if command -v install_smart_tool >/dev/null 2>&1; then
            install_smart_tool "$tool"
        else
            cargo install "$tool" 2>/dev/null || { ZSH_TOOLS_QUIET=$_quiet; __tools_warn "❌ 无法通过 Cargo 安装 $tool"; }
        fi
    done

    ZSH_TOOLS_QUIET=$_quiet
    __tools_info "✅ Rust 工具安装完成！"
}

# @brief Install development tools collection
# @description 默认列表 git/curl/wget/jq/tmux/tree/htop/vim/rsync。
# @description 可从 stdin 读取工具列表（每行一个），或作为位置参数传入。
# @param $* Optional tool list to override defaults
# @option --quiet Suppress progress messages
# @option --dry-run Show what would be installed
# @return 0 on success
# @example install_dev_tools
# @example echo "git" | install_dev_tools
# @category tools
install_dev_tools() {
    __tools_parse_args "$@"
    local pa_rc=$?
    if [[ $pa_rc -eq 2 ]]; then
        __tools_output "Usage: install_dev_tools [-q] [--dry-run] [tool...|-]"
        return 0
    fi
    [[ $pa_rc -ne 0 ]] && return $pa_rc
    local args=("${@:$ZSH_TOOLS_OPT_INDEX}")
    local _quiet=$ZSH_TOOLS_QUIET _dry=$ZSH_TOOLS_DRY_RUN
    __tools_read_stdin_or_args "${args[@]}"

    local default_tools=(git curl wget jq tmux tree htop vim rsync)
    local -a dev_tools
    if [[ ${#ZSH_TOOLS_INPUT_LINES[@]} -gt 0 ]]; then
        dev_tools=("${ZSH_TOOLS_INPUT_LINES[@]}")
    else
        dev_tools=("${default_tools[@]}")
    fi

    ZSH_TOOLS_QUIET=$_quiet
    __tools_info "🛠️ 安装开发工具集 (${#dev_tools[@]} 个)..."

    local tool
    for tool in "${dev_tools[@]}"; do
        ZSH_TOOLS_QUIET=$_quiet
        __tools_info "📦 安装 $tool..."
        if [[ $_dry -eq 1 ]]; then
            __tools_info "🔍 [dry-run] 将安装 $tool"
            continue
        fi
        if command -v install_smart_tool >/dev/null 2>&1; then
            install_smart_tool "$tool"
        else
            ZSH_TOOLS_QUIET=$_quiet
            __tools_warn "⚠️ 请手动安装 $tool"
        fi
    done

    ZSH_TOOLS_QUIET=$_quiet
    __tools_info "✅ 开发工具安装完成！"
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

# @brief Install modern tools via eget (GitHub releases)
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @return 0 on success
# @example install_modern_tools_by_eget
# @example install_modern_tools_by_eget global
# @example install_modern_tools_by_eget /usr/local
# @category tools
install_modern_tools_by_eget(){
    local requested_install_prefix="${1:-local}"
    local install_prefix

    case "$requested_install_prefix" in
        global) install_prefix="/usr/local" ;;
        local) install_prefix="$HOME/.local" ;;
        *) install_prefix="$requested_install_prefix" ;;
    esac

    echo "📦 使用 eget 安装现代工具到 '$install_prefix'..." >&2

    if ! command -v eget >/dev/null 2>&1; then
        echo "❌ install_modern_tools_by_eget: eget 未找到。请先安装 eget。" >&2
        return 1
    fi

    local eget_bin="${install_prefix}/bin"
    local use_sudo=0

    if [[ "$install_prefix" == "/usr/local" || "$install_prefix" == "/usr" ]]; then
        use_sudo=1
    fi

    if [[ "$use_sudo" -eq 1 ]]; then
        sudo -v || return 1
        sudo mkdir -p "$eget_bin"
    else
        mkdir -p "$eget_bin"
    fi
    export EGET_BIN="$eget_bin"

    # 需要安装的工具列表（GitHub repo）
    local -a eget_tools=(
        "BurntSushi/ripgrep"
        "sharkdp/fd"
        "eza-community/eza"
        "sharkdp/bat"
        "charmbracelet/glow"
        "casey/just"
        "sinelaw/fresh"
        "junegunn/fzf"
        "jesseduffield/lazygit"
        "cli/cli"
        "muesli/duf"
        "bootandy/dust"
        "dundee/gdu"
        "dalance/procs"
        "chmln/sd"
        "sharkdp/hyperfine"
        "dandavison/delta"
        "dbrgn/tealdeer"
        "zellij-org/zellij"
        "ajeetdsouza/zoxide"
        "sigoden/aichat"
        "starship/starship"
        "ducaale/xh"
        "ClementTsang/bottom"
        "rs/curlie"
        "sxyazi/yazi"
        "tw93/Mole"
        "jarun/nnn"
        "bcicen/ctop"
        "denisidoro/navi"
        # Add more repos here
    )

    for tool in "${eget_tools[@]}"; do
        echo "➡️  eget $tool" >&2
        _install_tool_by_eget "$tool" "$install_prefix"
    done
}

# @brief Install a single tool via eget
# @param $1 GitHub repo (e.g., owner/repo)
# @param $2 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @return 0 on success
# @example _install_tool_by_eget BurntSushi/ripgrep global
# @category tools
_install_tool_by_eget(){
    local tool="$1"
    local requested_install_prefix="${2:-local}"
    local install_prefix
    local eget_bin
    local use_sudo=0

    if [[ -z "$tool" ]]; then
        echo "Usage: _install_tool_by_eget <owner/repo> [global|local|/prefix]" >&2
        return 1
    fi

    case "$requested_install_prefix" in
        global) install_prefix="/usr/local" ;;
        local) install_prefix="$HOME/.local" ;;
        *) install_prefix="$requested_install_prefix" ;;
    esac

    eget_bin="${install_prefix}/bin"
    if [[ "$install_prefix" == "/usr/local" || "$install_prefix" == "/usr" ]]; then
        use_sudo=1
    fi

    if [[ "$use_sudo" -eq 1 ]]; then
        sudo -v || return 1
        sudo mkdir -p "$eget_bin"
    else
        mkdir -p "$eget_bin"
    fi

    export EGET_BIN="$eget_bin"

    if [[ "$use_sudo" -eq 1 ]]; then
        sudo -E eget "$tool"
    else
        eget "$tool"
    fi
}

# @brief Install ctop via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_ctop_by_eget
# @example install_ctop_by_eget global
# @category tools
install_ctop_by_eget(){
    _install_tool_by_eget "bcicen/ctop" "${1:-local}"
}

# @brief Install procs via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_procs_by_eget
# @example install_procs_by_eget global
# @category tools
install_procs_by_eget(){
    _install_tool_by_eget "dalance/procs" "${1:-local}"
}

# @brief Install tealdeer (tldr) via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_tealdeer_by_eget
# @example install_tealdeer_by_eget global
# @category tools
install_tealdeer_by_eget(){
    _install_tool_by_eget "dbrgn/tealdeer" "${1:-local}"
}

# @brief Install ripgrep via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_ripgrep_by_eget
# @example install_ripgrep_by_eget global
# @category tools
install_ripgrep_by_eget(){
    _install_tool_by_eget "BurntSushi/ripgrep" "${1:-local}"
}

# @brief Install fd via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_fd_by_eget
# @example install_fd_by_eget global
# @category tools
install_fd_by_eget(){
    _install_tool_by_eget "sharkdp/fd" "${1:-local}"
}

# @brief Install eza via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_eza_by_eget
# @example install_eza_by_eget global
# @category tools
install_eza_by_eget(){
    _install_tool_by_eget "eza-community/eza" "${1:-local}"
}

# @brief Install bat via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_bat_by_eget
# @example install_bat_by_eget global
# @category tools
install_bat_by_eget(){
    _install_tool_by_eget "sharkdp/bat" "${1:-local}"
}

# @brief Install glow via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_glow_by_eget
# @example install_glow_by_eget global
# @category tools
install_glow_by_eget(){
    _install_tool_by_eget "charmbracelet/glow" "${1:-local}"
}

# @brief Install taplo via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_taplo_by_eget
# @example install_taplo_by_eget global
# @category tools
install_taplo_by_eget(){
    _install_tool_by_eget "tamasfe/taplo" "${1:-local}"
}

# @brief Install taplo via Homebrew
# @return 0 on success
# @example install_taplo_by_brew
# @category tools
install_taplo_by_brew(){
    if command -v brew >/dev/null 2>&1; then
        brew install taplo
    else
        echo "❌ Homebrew 未安装，无法使用 brew 安装 taplo。" >&2
        return 1
    fi
}

# @brief Install just via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_just_by_eget
# @example install_just_by_eget global
# @category tools
install_just_by_eget(){
    _install_tool_by_eget "casey/just" "${1:-local}"
}

# @brief Install fresh via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_fresh_by_eget
# @example install_fresh_by_eget global
# @category tools
install_fresh_by_eget(){
    _install_tool_by_eget "sinelaw/fresh" "${1:-local}"
}

# @brief Install fzf via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_fzf_by_eget
# @example install_fzf_by_eget global
# @category tools
install_fzf_by_eget(){
    _install_tool_by_eget "junegunn/fzf" "${1:-local}"
}

# @brief Install lazygit via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_lazygit_by_eget
# @example install_lazygit_by_eget global
# @category tools
install_lazygit_by_eget(){
    _install_tool_by_eget "jesseduffield/lazygit" "${1:-local}"
}

# @brief Install gh (GitHub CLI) via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_gh_by_eget
# @example install_gh_by_eget global
# @category tools
install_gh_by_eget(){
    _install_tool_by_eget "cli/cli" "${1:-local}"
}

# backward compatible alias
alias install_cli_by_eget="install_gh_by_eget"

# @brief Install duf via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_duf_by_eget
# @example install_duf_by_eget global
# @category tools
install_duf_by_eget(){
    _install_tool_by_eget "muesli/duf" "${1:-local}"
}

# @brief Install dust via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_dust_by_eget
# @example install_dust_by_eget global
# @category tools
install_dust_by_eget(){
    _install_tool_by_eget "bootandy/dust" "${1:-local}"
}

# @brief Install gdu via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_gdu_by_eget
# @example install_gdu_by_eget global
# @category tools
install_gdu_by_eget(){
    _install_tool_by_eget "dundee/gdu" "${1:-local}"
}

# @brief Install sd via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_sd_by_eget
# @example install_sd_by_eget global
# @category tools
install_sd_by_eget(){
    _install_tool_by_eget "chmln/sd" "${1:-local}"
}

# @brief Install hyperfine via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_hyperfine_by_eget
# @example install_hyperfine_by_eget global
# @category tools
install_hyperfine_by_eget(){
    _install_tool_by_eget "sharkdp/hyperfine" "${1:-local}"
}

# @brief Install delta via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_delta_by_eget
# @example install_delta_by_eget global
# @category tools
install_delta_by_eget(){
    _install_tool_by_eget "dandavison/delta" "${1:-local}"
}

# @brief Install zellij via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_zellij_by_eget
# @example install_zellij_by_eget global
# @category tools
install_zellij_by_eget(){
    _install_tool_by_eget "zellij-org/zellij" "${1:-local}"
}

# @brief Install zoxide via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_zoxide_by_eget
# @example install_zoxide_by_eget global
# @category tools
install_zoxide_by_eget(){
    _install_tool_by_eget "ajeetdsouza/zoxide" "${1:-local}"
}

# @brief Install aichat via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_aichat_by_eget
# @example install_aichat_by_eget global
# @category tools
install_aichat_by_eget(){
    _install_tool_by_eget "sigoden/aichat" "${1:-local}"
}

# @brief Install starship via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_starship_by_eget
# @example install_starship_by_eget global
# @category tools
install_starship_by_eget(){
    _install_tool_by_eget "starship/starship" "${1:-local}"
}

# @brief Install xh via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_xh_by_eget
# @example install_xh_by_eget global
# @category tools
install_xh_by_eget(){
    _install_tool_by_eget "ducaale/xh" "${1:-local}"
}

# @brief Install bottom via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_bottom_by_eget
# @example install_bottom_by_eget global
# @category tools
install_bottom_by_eget(){
    _install_tool_by_eget "ClementTsang/bottom" "${1:-local}"
}

# @brief Install curlie via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_curlie_by_eget
# @example install_curlie_by_eget global
# @category tools
install_curlie_by_eget(){
    _install_tool_by_eget "rs/curlie" "${1:-local}"
}

# @brief Install yazi via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_yazi_by_eget
# @example install_yazi_by_eget global
# @category tools
install_yazi_by_eget(){
    _install_tool_by_eget "sxyazi/yazi" "${1:-local}"
}

# @brief Install mole via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_mole_by_eget
# @example install_mole_by_eget global
# @category tools
install_mole_by_eget(){
    _install_tool_by_eget "tw93/Mole" "${1:-local}"
}

# @brief Install nnn via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_nnn_by_eget
# @example install_nnn_by_eget global
# @category tools
install_nnn_by_eget(){
    _install_tool_by_eget "jarun/nnn" "${1:-local}"
}

# @brief Install navi via eget
# @param $1 Optional install location: "global" (/usr/local), "local" (~/.local), or a custom prefix path.
# @example install_navi_by_eget
# @example install_navi_by_eget global
# @category tools
install_navi_by_eget(){
    _install_tool_by_eget "denisidoro/navi" "${1:-local}"
}

# 向后兼容别名
alias install_modertools_local_by_eget="install_modern_tools_by_eget"

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
# @brief Show IP addresses cross-platform, table output (Interface | Family | Address)
# @option --quiet Suppress header row
# @option --json Output JSON array of {interface, family, address}
# @option --tsv Output raw TSV without column alignment
# @return 0 on success, 1 on unsupported OS
# @example show-ip-addr
# @example show-ipv4-addr --tsv
# @example show-ipv6-addr --json
# @category tools
_show-ip-addr() {
  local want="$1"; shift 2>/dev/null
  __tools_parse_args "$@"
  local pa_rc=$?
  if [[ $pa_rc -eq 2 ]]; then
    __tools_output "Usage: show-ip-addr [-q|--quiet] [--json|--tsv] [-h|--help]"
    return 0
  fi
  [[ $pa_rc -ne 0 ]] && return $pa_rc

  local os=$(uname -s)
  local -a rows=()
  local iface fam_norm addr

  if [[ "$os" == "Linux" ]]; then
    if ! command -v ip >/dev/null 2>&1; then
      __tools_error "Unsupported: 'ip' command not found"; return 1
    fi
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      rows+=("$line")
    done < <(ip -o addr show 2>/dev/null | while read -r _ iface fam addr _; do
      [[ "$fam" == "inet" || "$fam" == "inet6" ]] || continue
      addr=${addr%%/*}
      [[ "$addr" == "127.0.0.1" || "$addr" == "::1" ]] && continue
      fam_norm="IPv6"; [[ "$fam" == "inet" ]] && fam_norm="IPv4"
      [[ -n "$want" && "$fam_norm" != "$want" ]] && continue
      printf "%s\t%s\t%s\n" "$iface" "$fam_norm" "$addr"
    done)
  elif [[ "$os" == "Darwin" ]]; then
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      rows+=("$line")
    done < <(ifconfig 2>/dev/null | awk -v want="$want" '
        /^[a-z0-9]/ { iface=$1; gsub(/:$/,"",iface) }
        /inet [0-9]/ && $2 != "127.0.0.1" {
          if (want == "" || want == "IPv4") print iface "\tIPv4\t" $2
        }
        /inet6 / && $2 != "::1" {
          if (want == "" || want == "IPv6") print iface "\tIPv6\t" $2
        }
      ')
  else
    __tools_error "Unsupported: $os"; return 1
  fi

  if [[ $ZSH_TOOLS_JSON -eq 1 ]]; then
    __tools_output "["
    local -a json_lines=()
    local row r_iface r_fam r_addr e_i e_f e_a
    for row in "${rows[@]}"; do
      IFS=$'\t' read -r r_iface r_fam r_addr <<< "$row"
      e_i=$(__tools_json_escape "$r_iface")
      e_f=$(__tools_json_escape "$r_fam")
      e_a=$(__tools_json_escape "$r_addr")
      json_lines+=("  {\"interface\":\"$e_i\",\"family\":\"$e_f\",\"address\":\"$e_a\"}")
    done
    local i n=${#json_lines[@]}
    for ((i=1; i<=n; i++)); do
      if [[ $i -lt $n ]]; then
        __tools_output "${json_lines[$i]},"
      else
        __tools_output "${json_lines[$i]}"
      fi
    done
    __tools_output "]"
  elif [[ $ZSH_TOOLS_TSV -eq 1 ]]; then
    [[ $ZSH_TOOLS_QUIET -eq 0 ]] && __tools_output $'Interface\tFamily\tAddress'
    local row
    for row in "${rows[@]}"; do
      __tools_output "$row"
    done
  else
    local fmt_input=""
    [[ $ZSH_TOOLS_QUIET -eq 0 ]] && fmt_input+=$'Interface\tFamily\tAddress\n'
    local row
    for row in "${rows[@]}"; do
      fmt_input+="$row"$'\n'
    done
    if command -v column >/dev/null 2>&1; then
      printf '%s' "$fmt_input" | column -t -s $'\t'
    else
      printf '%s' "$fmt_input"
    fi
  fi
}

show-ip-addr()   { _show-ip-addr "" "$@"; }
show-ipv4-addr() { _show-ip-addr "IPv4" "$@"; }
show-ipv6-addr() { _show-ip-addr "IPv6" "$@"; }

# backward compat
show_ip_addr()   { show-ip-addr "$@"; }
show_ipv4_addr() { show-ipv4-addr "$@"; }
show_ipv6_addr() { show-ipv6-addr "$@"; }


if [[ -f $HOME/.local/bin/mise ]]; then
  eval "$(mise activate zsh)"
fi

if [[ -d $ASDF_DIR ]]; then
  . $ASDF_DIR/asdf.sh
  fpath=(${ASDF_DIR}/completions $fpath)
fi

if [[ -d $HOME/.config/broot/launcher/bash ]] then
 source $HOME/.config/broot/launcher/bash/br
fi
