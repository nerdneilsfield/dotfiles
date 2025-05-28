# 智能包管理器选择系统

##
# @brief 获取当前系统的包管理器
# @description 自动检测当前系统可用的包管理器，优先级: brew > pacman > yay > apt > dnf > yum
# @return 包管理器名称 (brew|pacman|yay|apt|dnf|yum|unknown)
# @example local pm=$(get_package_manager)
# @category check
##
get_package_manager() {
    if command -v brew >/dev/null 2>&1; then
        echo "brew"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v yay >/dev/null 2>&1; then
        echo "yay"
    elif command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    else
        echo "unknown"
    fi
}

##
# @brief 获取当前操作系统平台信息
# @return 平台名称 (macos|arch|debian|redhat|msys2|linux|unknown)
# @example local platform=$(get_platform)
# @category check
##
get_platform() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)
            if [[ -f /etc/arch-release ]]; then
                echo "arch"
            elif [[ -f /etc/debian_version ]]; then
                echo "debian"
            elif [[ -f /etc/redhat-release ]]; then
                echo "redhat"
            else
                echo "linux"
            fi
            ;;
        *)
            # 检查 MSYS2/Cygwin
            if [[ "$(uname -o 2>/dev/null)" == "Msys" ]]; then
                echo "msys2"
            elif [[ "$(uname -o 2>/dev/null)" == "Cygwin" ]]; then
                echo "msys2"  # 将 Cygwin 也归类为 msys2
            else
                echo "unknown"
            fi
            ;;
    esac
}

##
# @brief 使用包管理器智能安装软件包
# @description 根据当前系统的包管理器自动选择合适的安装命令
# @param $1 软件包名称
# @return 0 安装成功, 1 安装失败
# @example install_with_manager docker
# @category install
##
install_with_manager() {
    local package="$1"
    local pm=$(get_package_manager)
    local platform=$(get_platform)
    
    if [[ -z "$package" ]]; then
        echo "Usage: smart_install <package_name>" >&2
        return 1
    fi
    
    echo "🔍 检测到平台: $platform, 包管理器: $pm"
    
    case "$pm" in
        "brew")
            echo "📦 使用 Homebrew 安装 $package..."
            brew install "$package"
            ;;
        "pacman")
            # 区分 MSYS2 和 Arch Linux
            if [[ "$platform" == "msys2" ]]; then
                echo "📦 使用 MSYS2 Pacman 安装 $package..."
                pacman -S --needed --noconfirm "$package"
            else
                echo "📦 使用 Pacman 安装 $package..."
                sudo pacman -S "$package"
            fi
            ;;
        "yay")
            echo "📦 使用 Yay 安装 $package..."
            yay -S "$package"
            ;;
        "apt")
            echo "📦 使用 APT 安装 $package..."
            sudo apt update && sudo apt install -y "$package"
            ;;
        "dnf")
            echo "📦 使用 DNF 安装 $package..."
            sudo dnf install -y "$package"
            ;;
        "yum")
            echo "📦 使用 YUM 安装 $package..."
            sudo yum install -y "$package"
            ;;
        *)
            echo "❌ 未检测到支持的包管理器" >&2
            return 1
            ;;
    esac
}

##
# @brief 智能安装特定开发工具
# @description 根据平台自动选择最佳安装方法，支持 fnm、rustup、docker、uv、pyenv 等开发工具
# @param $1 工具名称 (fnm|rustup|docker|uv|pyenv|ruff|black|fzf|ripgrep|fd|bat|lazygit|eza|gh|yazi|bottom)
# @return 0 安装成功, 1 安装失败或不支持的工具
# @example install_smart_tool fnm
# @example install_smart_tool docker
# @category install
##
install_smart_tool() {
    local tool="$1"
    local pm=$(get_package_manager)
    local platform=$(get_platform)
    
    case "$tool" in
        "fnm")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 fnm..."
                    brew install fnm
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 AUR 安装 fnm (使用预编译版本)..."
                    if command -v yay >/dev/null 2>&1; then
                        yay -S fnm-bin
                    else
                        echo "⚠️  建议安装 yay 来管理 AUR 包，回退到 cargo 安装..."
                        cargo install fnm
                    fi
                    ;;
                *)
                    echo "📦 使用 cargo 安装 fnm..."
                    cargo install fnm
                    ;;
            esac
            ;;
            
        "rustup"|"rust")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 Rust 工具链..."
                    brew install rustup-init
                    rustup-init -y
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 Pacman 安装 Rust 工具链..."
                    smart_install rustup
                    ;;
                *)
                    echo "📦 使用官方脚本安装 Rustup..."
                    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                    ;;
            esac
            ;;
            
        "go"|"golang")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 Go..."
                    brew install go
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 Pacman 安装 Go..."
                    smart_install go
                    ;;
                *)
                    echo "📦 需要手动下载 Go 安装包..."
                    echo "请访问: https://golang.org/dl/"
                    ;;
            esac
            ;;
            
        "docker")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 Docker Desktop..."
                    brew install --cask docker
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 Pacman 安装 Docker..."
                    smart_install docker
                    smart_install docker-compose
                    echo "🔧 启用 Docker 服务..."
                    sudo systemctl enable --now docker.service
                    ;;
                *)
                    echo "📦 使用 Docker 官方脚本安装..."
                    curl -fsSL https://get.docker.com | sh
                    ;;
            esac
            ;;
            
        "pyenv")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 pyenv..."
                    brew install pyenv
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 Pacman 安装 pyenv..."
                    smart_install pyenv
                    ;;
                *)
                    echo "📦 使用 pyenv 官方脚本安装..."
                    curl https://pyenv.run | bash
                    ;;
            esac
            ;;
            
        "uv")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 uv..."
                    brew install uv
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 Pacman 安装 uv..."
                    smart_install uv
                    ;;
                *)
                    echo "📦 使用 uv 官方脚本安装..."
                    curl -LsSf https://astral.sh/uv/install.sh | sh
                    ;;
            esac
            ;;
            
        "ruff")
            case "$pm" in
                "brew"|"pacman"|"yay")
                    echo "📦 使用 uv 安装 ruff (推荐)..."
                    if command -v uv >/dev/null 2>&1; then
                        uv tool install ruff
                    else
                        echo "⚠️  请先安装 uv，或使用 pip install ruff"
                    fi
                    ;;
                *)
                    echo "📦 使用 pip 安装 ruff..."
                    pip install ruff
                    ;;
            esac
            ;;
            
        "black")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 black..."
                    brew install black
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 Pacman 安装 black..."
                    smart_install python-black
                    ;;
                *)
                    echo "📦 使用 pip 安装 black..."
                    pip install black
                    ;;
            esac
            ;;
            
        "fzf")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 fzf..."
                    brew install fzf
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 Pacman 安装 fzf..."
                    smart_install fzf
                    ;;
                *)
                    echo "📦 使用发布版本安装 fzf..."
                    install_fzf  # 回退到现有函数
                    ;;
            esac
            ;;
            
        "ripgrep"|"rg")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 ripgrep..."
                    brew install ripgrep
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 Pacman 安装 ripgrep..."
                    smart_install ripgrep
                    ;;
                *)
                    echo "📦 使用发布版本安装 ripgrep..."
                    install_ripgrep  # 回退到现有函数
                    ;;
            esac
            ;;
            
        "fd")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 fd..."
                    brew install fd
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 Pacman 安装 fd..."
                    smart_install fd
                    ;;
                *)
                    echo "📦 使用发布版本安装 fd..."
                    install_fd  # 回退到现有函数
                    ;;
            esac
            ;;
            
        "bat")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 bat..."
                    brew install bat
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 Pacman 安装 bat..."
                    smart_install bat
                    ;;
                *)
                    echo "📦 使用 cargo 安装 bat..."
                    cargo install bat
                    ;;
            esac
            ;;
            
        "lazygit")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 lazygit..."
                    brew install lazygit
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 Pacman 安装 lazygit..."
                    smart_install lazygit
                    ;;
                *)
                    echo "📦 使用发布版本安装 lazygit..."
                    install_lazygit  # 回退到现有函数
                    ;;
            esac
            ;;
            
        "eza"|"exa")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 eza..."
                    brew install eza
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 Pacman 安装 eza..."
                    smart_install eza
                    ;;
                *)
                    echo "📦 使用发布版本安装 eza..."
                    install_eza  # 回退到现有函数
                    ;;
            esac
            ;;
            
        "gh")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 GitHub CLI..."
                    brew install gh
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 Pacman 安装 GitHub CLI..."
                    smart_install github-cli
                    ;;
                *)
                    echo "📦 使用发布版本安装 GitHub CLI..."
                    install_gh  # 回退到现有函数
                    ;;
            esac
            ;;
            
        "yazi")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 yazi..."
                    brew install yazi
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 Pacman 安装 yazi..."
                    smart_install yazi
                    ;;
                *)
                    echo "📦 使用 cargo 安装 yazi..."
                    cargo install --locked yazi-fm yazi-cli
                    ;;
            esac
            ;;
            
        "bottom"|"btm")
            case "$pm" in
                "brew")
                    echo "📦 通过 Homebrew 安装 bottom..."
                    brew install bottom
                    ;;
                "pacman"|"yay")
                    echo "📦 通过 Pacman 安装 bottom..."
                    smart_install bottom
                    ;;
                *)
                    echo "📦 使用 cargo 安装 bottom..."
                    cargo install bottom
                    ;;
            esac
            ;;
            
        *)
            echo "❌ 不支持的工具: $tool" >&2
            echo "💡 使用 smart_install <package_name> 进行通用安装"
            echo "💡 支持的工具: fnm, rustup, go, docker, pyenv, uv, ruff, black, fzf, ripgrep, fd, bat, lazygit, eza, gh, yazi, bottom"
            return 1
            ;;
    esac
}

# 显示当前平台的安装指南
show_install_guide() {
    local pm=$(get_package_manager)
    local platform=$(get_platform)
    
    echo "🎯 当前环境推荐的安装方法"
    echo "================================"
    echo "平台: $platform"
    echo "包管理器: $pm"
    echo ""
    
    case "$pm" in
        "brew")
            echo "✅ 推荐使用 Homebrew 安装的工具:"
            echo "  🔧 开发工具: fnm, rustup-init, go, docker, pyenv, uv"
            echo "  🎨 格式化: black, ruff"
            echo "  📁 现代CLI: fzf, ripgrep, fd, bat, eza, lazygit"
            echo "  🔍 其他工具: gh, yazi, bottom"
            ;;
        "pacman"|"yay")
            echo "✅ 推荐使用 Pacman/AUR 安装的工具:"
            echo "  🔧 开发工具: fnm-bin (AUR), rustup, go, docker, pyenv, uv"
            echo "  🎨 格式化: python-black, ruff"
            echo "  📁 现代CLI: fzf, ripgrep, fd, bat, eza, lazygit"
            echo "  🔍 其他工具: github-cli, yazi, bottom"
            ;;
        *)
            echo "⚠️  当前环境建议使用官方安装脚本或手动安装"
            ;;
    esac
    
    echo ""
    echo "💡 使用方法:"
    echo "  install_tool_smart <tool_name>  # 智能安装指定工具"
    echo "  smart_install <package_name>    # 通用包安装"
}

# 新别名 (推荐使用)
alias pki="install_with_manager"
alias install-tool="install_smart_tool"
alias install-guide="show_install_guide"

# 向后兼容别名 (逐步废弃)
alias smart_install="install_with_manager"
alias install_tool_smart="install_smart_tool"
alias detect_package_manager="get_package_manager"
alias show_install_recommendations="show_install_guide"
alias install-rec="show_install_guide"