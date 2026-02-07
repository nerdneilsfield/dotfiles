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
# @description 基于 install_route 进行策略化安装（默认 latest）
# @param $1 工具名称
# @return 0 安装成功, 1 安装失败或不支持的工具
# @example install_smart_tool fnm
# @example install_smart_tool docker
# @category install
##
install_smart_tool() {
    local tool="$1"
    if [[ -z "$tool" ]]; then
        echo "Usage: install_smart_tool <tool_name>" >&2
        return 1
    fi

    if command -v install_route >/dev/null 2>&1 && install_catalog_supported_methods "$tool" >/dev/null 2>&1; then
        install_route "$tool"
        return $?
    fi

    # fallback for tools not in router catalog yet
    case "$tool" in
        zoxide)
            if [[ "$(get_package_manager)" == "unknown" ]]; then
                install_zoxide_from_github
            else
                install_with_manager zoxide
            fi
            ;;
        go|golang) install_with_manager go ;;
        docker)
            if [[ "$(get_package_manager)" == "brew" ]]; then
                brew install --cask docker
            else
                install_with_manager docker
            fi
            ;;
        black)
            if command -v pip >/dev/null 2>&1; then
                pip install black
            else
                install_with_manager black
            fi
            ;;
        *)
            echo "❌ 不支持的工具: $tool" >&2
            echo "💡 使用 install_help <tool> 查看路由信息"
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

# 向后兼容入口
unalias smart_install 2>/dev/null
function smart_install {
    install_with_manager "$@"
}
alias install_tool_smart="install_smart_tool"
alias detect_package_manager="get_package_manager"
alias show_install_recommendations="show_install_guide"
alias install-rec="show_install_guide"
