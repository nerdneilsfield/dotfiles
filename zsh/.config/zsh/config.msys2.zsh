# MSYS2 Windows 环境特定配置
# 检测: uname -o == "Msys"

##
# @brief Set up MSYS2 environment variables and paths
# @return 0 on success
# @example setup_msys2_environment
# @category config
##
setup_msys2_environment() {
    # MSYS2 基础路径
    export MSYS2_ROOT="/msys64"
    [[ -d "/c/msys64" ]] && export MSYS2_ROOT="/c/msys64"
    
    # Windows 系统路径映射
    export WINDOWS_HOME="/c/Users/$USER"
    [[ -d "$WINDOWS_HOME" ]] && export WIN_HOME="$WINDOWS_HOME"
    
    # MSYS2 特定环境变量
    export MSYSTEM_CARCH="x86_64"
    export MSYSTEM_CHOST="x86_64-pc-msys"
    
    # Git 配置优化
    export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"
    
    green_echo "MSYS2 环境配置完成"
}

##
# @brief Install packages using MSYS2 pacman
# @param $* Package names to install
# @return 0 on success
# @example install_msys2_packages git curl
# @category install
##
install_msys2_packages() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: install_msys2_packages <package1> [package2] ..."
        return 1
    fi
    
    green_echo "使用 pacman 安装 MSYS2 包: $*"
    pacman -S --needed --noconfirm "$@"
}

##
# @brief Install development tools for MSYS2
# @return 0 on success
# @example install_msys2_dev_tools
# @category install
##
install_msys2_dev_tools() {
    green_echo "安装 MSYS2 开发工具..."
    
    local dev_packages=(
        "base-devel"          # 基础开发工具
        "mingw-w64-x86_64-toolchain"  # MinGW-w64 工具链
        "git"                 # Git 版本控制
        "curl"                # 网络工具
        "wget"                # 下载工具
        "unzip"               # 解压工具
        "tar"                 # 压缩工具
        "make"                # 构建工具
        "cmake"               # CMake
        "ninja"               # Ninja 构建系统
        "diffutils"           # diff 工具
        "patch"               # 补丁工具
    )
    
    install_msys2_packages "${dev_packages[@]}"
}

##
# @brief Install modern command line tools for MSYS2
# @return 0 on success
# @example install_msys2_modern_tools
# @category install
##
install_msys2_modern_tools() {
    green_echo "安装现代命令行工具..."
    
    local modern_tools=(
        "mingw-w64-x86_64-ripgrep"    # rg - 更快的 grep
        "mingw-w64-x86_64-fd"         # fd - 更快的 find
        "mingw-w64-x86_64-bat"        # bat - 更好的 cat
        "mingw-w64-x86_64-eza"        # eza - 更好的 ls
        "mingw-w64-x86_64-fzf"        # fzf - 模糊查找
        "mingw-w64-x86_64-jq"         # jq - JSON 处理
        "mingw-w64-x86_64-delta"      # delta - 更好的 git diff
        "mingw-w64-x86_64-bottom"     # btm - 系统监控
        "mingw-w64-x86_64-dust"       # dust - 磁盘使用分析
    )
    
    install_msys2_packages "${modern_tools[@]}"
}

##
# @brief Set up programming language environments for MSYS2
# @return 0 on success
# @example setup_msys2_languages
# @category config
##
setup_msys2_languages() {
    green_echo "配置编程语言环境..."
    
    # Python
    if command -v python >/dev/null 2>&1; then
        green_echo "Python 已安装: $(python --version)"
        # 添加 Python Scripts 到 PATH
        [[ -d "/mingw64/bin" ]] && export PATH="/mingw64/bin:$PATH"
    fi
    
    # Node.js
    if command -v node >/dev/null 2>&1; then
        green_echo "Node.js 已安装: $(node --version)"
        # npm 全局路径
        [[ -d "/mingw64/lib/node_modules" ]] && export NODE_PATH="/mingw64/lib/node_modules"
    fi
    
    # Rust
    if [[ -d "$HOME/.cargo" ]]; then
        green_echo "Rust 环境检测到"
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
    
    # Go
    if command -v go >/dev/null 2>&1; then
        green_echo "Go 已安装: $(go version)"
        export GOPATH="$HOME/go"
        export PATH="$GOPATH/bin:$PATH"
    fi
}

##
# @brief Configure Windows-specific settings for MSYS2
# @return 0 on success
# @example setup_msys2_windows_integration
# @category config
##
setup_msys2_windows_integration() {
    # Windows 路径别名
    alias cdwin="cd '$WIN_HOME'"
    alias cddocs="cd '$WIN_HOME/Documents'"
    alias cddesk="cd '$WIN_HOME/Desktop'"
    alias cddown="cd '$WIN_HOME/Downloads'"
    
    # Windows 程序启动别名
    alias notepad="notepad.exe"
    alias explorer="explorer.exe"
    alias code="code.exe"  # 如果安装了 VS Code
    
    # 文件系统优化
    export CYGWIN="winsymlinks:nativestrict"
    
    green_echo "Windows 集成配置完成"
}

##
# @brief Install specific language tools for MSYS2
# @param $1 Language (python|node|rust|go|all)
# @return 0 on success
# @example install_msys2_language_tools python
# @category install
##
install_msys2_language_tools() {
    local language="${1:-all}"
    
    case "$language" in
        "python")
            green_echo "安装 Python 开发工具..."
            install_msys2_packages \
                "mingw-w64-x86_64-python" \
                "mingw-w64-x86_64-python-pip" \
                "mingw-w64-x86_64-python-setuptools"
            ;;
        "node")
            green_echo "安装 Node.js 开发工具..."
            install_msys2_packages \
                "mingw-w64-x86_64-nodejs" \
                "mingw-w64-x86_64-npm"
            ;;
        "rust")
            green_echo "Rust 建议使用 rustup 官方安装器"
            echo "运行: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
            ;;
        "go")
            green_echo "安装 Go 开发工具..."
            install_msys2_packages "mingw-w64-x86_64-go"
            ;;
        "all")
            install_msys2_language_tools python
            install_msys2_language_tools node
            install_msys2_language_tools go
            ;;
        *)
            echo "支持的语言: python, node, rust, go, all"
            return 1
            ;;
    esac
}

##
# @brief Show MSYS2 system information
# @return 0 on success
# @example show_msys2_info
# @category tool
##
show_msys2_info() {
    echo "🖥️  MSYS2 系统信息:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    echo "🏠 MSYS2 根目录: ${MSYS2_ROOT:-未设置}"
    echo "🏡 Windows 用户目录: ${WIN_HOME:-未设置}"
    echo "🏗️  架构: ${MSYSTEM_CARCH:-未设置}"
    echo "🖥️  主机: ${MSYSTEM_CHOST:-未设置}"
    echo ""
    
    echo "📦 包管理器信息:"
    if command -v pacman >/dev/null 2>&1; then
        echo "✅ Pacman: $(pacman --version | head -1)"
        echo "📊 已安装包数量: $(pacman -Q | wc -l)"
    else
        echo "❌ Pacman 未找到"
    fi
    echo ""
    
    echo "🛠️  开发工具状态:"
    local tools=("git" "gcc" "make" "cmake" "python" "node" "go" "rustc")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "✅ $tool: $(command -v "$tool")"
        else
            echo "❌ $tool: 未安装"
        fi
    done
}

##
# @brief Quick setup for new MSYS2 installation
# @return 0 on success
# @example msys2_quick_setup
# @category install
##
msys2_quick_setup() {
    green_echo "🚀 MSYS2 快速配置开始..."
    
    # 更新系统
    green_echo "📦 更新 MSYS2 包数据库..."
    pacman -Sy --noconfirm
    
    # 安装基础工具
    setup_msys2_environment
    install_msys2_dev_tools
    install_msys2_modern_tools
    
    # 配置语言环境
    setup_msys2_languages
    
    # Windows 集成
    setup_msys2_windows_integration
    
    green_echo "✅ MSYS2 快速配置完成！"
    green_echo "💡 运行 'show_msys2_info' 查看系统信息"
    green_echo "💡 运行 'install_msys2_language_tools <language>' 安装特定语言工具"
}

# 自动运行环境设置
if [[ "$(uname -o)" == "Msys" ]]; then
    setup_msys2_environment
    
    # 如果是首次运行，提示用户
    if [[ ! -f "$HOME/.msys2_configured" ]]; then
        echo ""
        green_echo "🎉 检测到 MSYS2 环境！"
        echo "💡 运行 'msys2_quick_setup' 进行一键配置"
        echo "💡 运行 'show_msys2_info' 查看系统信息"
        echo ""
        touch "$HOME/.msys2_configured"
    fi
fi

# 别名
alias msys2-info="show_msys2_info"
alias msys2-setup="msys2_quick_setup"
alias msys2-install="install_msys2_packages"
alias msys2-dev="install_msys2_dev_tools"
alias msys2-modern="install_msys2_modern_tools"