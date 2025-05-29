# 智能导航系统 - zoxide 优先，z.lua 备选

##
# @brief Install zoxide smart directory jumper
# @return 0 on success
# @example install_zoxide
# @category install
##
install_zoxide() {
    local pm=$(get_package_manager)
    local platform=$(get_platform)
    
    green_echo "🚀 安装 zoxide..."
    
    case "$pm" in
        "brew")
            green_echo "📦 使用 Homebrew 安装 zoxide..."
            brew install zoxide
            ;;
        "pacman")
            if [[ "$platform" == "msys2" ]]; then
                green_echo "📦 使用 MSYS2 Pacman 安装 zoxide..."
                pacman -S --needed --noconfirm mingw-w64-x86_64-zoxide
            else
                green_echo "📦 使用 Pacman 安装 zoxide..."
                sudo pacman -S zoxide
            fi
            ;;
        "yay")
            green_echo "📦 使用 Yay 安装 zoxide..."
            yay -S zoxide
            ;;
        "apt")
            green_echo "📦 从 GitHub 下载安装 zoxide..."
            install_zoxide_from_github
            ;;
        "dnf")
            green_echo "📦 使用 DNF 安装 zoxide..."
            sudo dnf install zoxide
            ;;
        *)
            green_echo "📦 从 GitHub 下载安装 zoxide..."
            install_zoxide_from_github
            ;;
    esac
    
    if command -v zoxide >/dev/null 2>&1; then
        green_echo "✅ zoxide 安装成功!"
        green_echo "💡 重新加载 shell 配置以启用 zoxide"
    else
        echo "❌ zoxide 安装失败，将回退到 z.lua"
    fi
}

##
# @brief Install zoxide from GitHub releases
# @return 0 on success
# @example install_zoxide_from_github
# @category install
##
install_zoxide_from_github() {
    green_echo "📥 从 GitHub 下载 zoxide..."
    
    if command -v smart_download_tool >/dev/null 2>&1; then
        # 使用智能下载系统
        smart_download_tool "zoxide" "ajeetdsouza/zoxide" "latest" \
            "zoxide-{VERSION}-{ARCH}-unknown-linux-musl.tar.gz" "/tmp/zoxide"
        
        
        if [[ -f "/tmp/zoxide" ]]; then
            mkdir -p "$HOME/.local/bin"
            mv "/tmp/zoxide" "$HOME/.local/bin/"
            chmod +x "$HOME/.local/bin/zoxide"
            green_echo "✅ zoxide 安装到 $HOME/.local/bin/zoxide"
        fi
    else
        # 传统方法
        local arch=$(get_cpu_arch)
        local download_url=""
        
        case "$arch" in
            "x86_64")
                if [[ "$(uname -o 2>/dev/null)" == "Msys" ]]; then
                    download_url="https://github.com/ajeetdsouza/zoxide/releases/latest/download/zoxide-x86_64-pc-windows-msvc.zip"
                else
                    download_url="https://github.com/ajeetdsouza/zoxide/releases/latest/download/zoxide-x86_64-unknown-linux-musl.tar.gz"
                fi
                ;;
            "aarch64")
                download_url="https://github.com/ajeetdsouza/zoxide/releases/latest/download/zoxide-aarch64-unknown-linux-musl.tar.gz"
                ;;
            *)
                echo "❌ 不支持的架构: $arch"
                return 1
                ;;
        esac
        
        green_echo "📥 下载 zoxide: $download_url"
        
        mkdir -p /tmp/zoxide_install
        cd /tmp/zoxide_install
        
        if curl -L "$download_url" -o zoxide_archive; then
            if [[ "$download_url" == *.zip ]]; then
                unzip zoxide_archive
            else
                tar -xzf zoxide_archive
            fi
            
            # 查找 zoxide 二进制文件
            local binary_file=$(find . -name "zoxide" -type f | head -1)
            if [[ -n "$binary_file" ]]; then
                mkdir -p "$HOME/.local/bin"
                cp "$binary_file" "$HOME/.local/bin/"
                chmod +x "$HOME/.local/bin/zoxide"
                green_echo "✅ zoxide 安装到 $HOME/.local/bin/zoxide"
            else
                echo "❌ 找不到 zoxide 二进制文件"
                return 1
            fi
        else
            echo "❌ 下载失败"
            return 1
        fi
        
        cd - >/dev/null
        rm -rf /tmp/zoxide_install
    fi
}

##
# @brief Initialize navigation system (zoxide or z.lua)
# @return 0 on success
# @example init_navigation
# @category config
##
init_navigation() {
    # 检查 zoxide 是否可用
    if command -v zoxide >/dev/null 2>&1; then
        green_echo "🎯 使用 zoxide 作为主要导航工具"
        
        # 初始化 zoxide
        eval "$(zoxide init zsh)"
        
        # 确保 z 命令指向 zoxide
        alias z="zoxide query -ls"
        
        # 添加一些有用的别名
        alias zi="zoxide query -i"  # 交互式选择
        alias za="zoxide add"       # 手动添加路径
        alias zr="zoxide remove"    # 移除路径
        alias zq="zoxide query"     # 查询路径
        
        green_echo "✅ zoxide 初始化完成"
        
        # 显示使用提示
        echo "💡 zoxide 使用方法:"
        echo "   z <path>    - 跳转到匹配的目录"
        echo "   zi          - 交互式选择目录"
        echo "   za <path>   - 手动添加目录"
        echo "   zr <path>   - 移除目录"
        
    elif [[ -f "$ZSH_CONF_DIR/z.lua" ]] && command -v lua >/dev/null 2>&1; then
        green_echo "🎯 zoxide 未找到，使用 z.lua 作为备选"
        
        # 初始化 z.lua
        eval "$(lua "$ZSH_CONF_DIR/z.lua" --init zsh)"
        
        green_echo "✅ z.lua 初始化完成"
        
        # 显示使用提示
        echo "💡 z.lua 使用方法:"
        echo "   z <path>    - 跳转到匹配的目录"
        echo "   z -l        - 列出所有记录的目录"
        echo "   z -c        - 按访问次数排序"
        echo "   z -r        - 按最近访问排序"
        
    else
        echo "⚠️  未找到 zoxide 和 z.lua，安装其中一个以启用智能导航"
        echo "💡 运行 'install_zoxide' 安装 zoxide"
        echo "💡 或确保 lua 和 z.lua 文件存在"
        return 1
    fi
}

##
# @brief Check navigation system status
# @return 0 on success
# @example check_navigation_status
# @category tool
##
check_navigation_status() {
    echo "🧭 导航系统状态检查:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 检查 zoxide
    if command -v zoxide >/dev/null 2>&1; then
        echo "✅ zoxide: $(zoxide --version)"
        echo "📍 数据库位置: $(zoxide query --list | wc -l) 条记录"
        echo "🎯 状态: 主要导航工具"
    else
        echo "❌ zoxide: 未安装"
    fi
    
    echo ""
    
    # 检查 z.lua
    if [[ -f "$ZSH_CONF_DIR/z.lua" ]]; then
        if command -v lua >/dev/null 2>&1; then
            echo "✅ z.lua: 可用 (lua $(lua -v 2>&1 | head -1 | cut -d' ' -f2))"
            if [[ -f "$HOME/.zlua" ]]; then
                echo "📍 数据库位置: $(wc -l < "$HOME/.zlua") 条记录"
            else
                echo "📍 数据库: 尚未创建"
            fi
            if command -v zoxide >/dev/null 2>&1; then
                echo "🎯 状态: 备选导航工具"
            else
                echo "🎯 状态: 主要导航工具"
            fi
        else
            echo "⚠️  z.lua: 存在但 lua 未安装"
        fi
    else
        echo "❌ z.lua: 未找到"
    fi
    
    echo ""
    
    # 检查 z 命令
    if command -v z >/dev/null 2>&1; then
        echo "✅ z 命令: 可用"
        local z_type=$(type z | head -1)
        echo "🔗 类型: $z_type"
    else
        echo "❌ z 命令: 不可用"
    fi
    
    echo ""
    echo "💡 建议:"
    if ! command -v zoxide >/dev/null 2>&1 && ! command -v z >/dev/null 2>&1; then
        echo "   运行 'install_zoxide' 安装现代导航工具"
    elif ! command -v zoxide >/dev/null 2>&1; then
        echo "   运行 'install_zoxide' 升级到更快的 zoxide"
    else
        echo "   导航系统配置正常！"
    fi
}

##
# @brief Show navigation usage examples
# @return 0 on success
# @example show_navigation_help
# @category tool
##
show_navigation_help() {
    echo "🧭 智能导航使用指南"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if command -v zoxide >/dev/null 2>&1; then
        echo "🎯 当前使用: zoxide (推荐)"
        echo ""
        echo "📖 基本用法:"
        echo "   z <keyword>     - 跳转到匹配的目录"
        echo "   z foo           - 跳转到包含 'foo' 的目录"
        echo "   z foo bar       - 跳转到同时包含 'foo' 和 'bar' 的目录"
        echo ""
        echo "🔧 高级功能:"
        echo "   zi              - 交互式选择目录 (使用 fzf)"
        echo "   za /path        - 手动添加目录到数据库"
        echo "   zr pattern      - 移除匹配的目录"
        echo "   zq pattern      - 查询匹配的目录（不跳转）"
        echo ""
        echo "📊 查看信息:"
        echo "   zoxide query --list           - 列出所有目录"
        echo "   zoxide query --list --score   - 显示评分"
    elif command -v z >/dev/null 2>&1; then
        echo "🎯 当前使用: z.lua (备选)"
        echo ""
        echo "📖 基本用法:"
        echo "   z <keyword>     - 跳转到匹配的目录"
        echo "   z foo           - 跳转到包含 'foo' 的目录"
        echo "   z foo bar       - 跳转到同时包含 'foo' 和 'bar' 的目录"
        echo ""
        echo "🔧 高级功能:"
        echo "   z -l            - 列出所有记录的目录"
        echo "   z -l foo        - 列出包含 'foo' 的目录"
        echo "   z -c foo        - 按访问次数排序"
        echo "   z -r foo        - 按最近访问排序"
        echo "   z -t foo        - 按时间排序"
        echo ""
        echo "📊 查看信息:"
        echo "   z -l            - 列出所有目录和评分"
        echo "   z --purge       - 清理不存在的目录"
    else
        echo "❌ 未安装导航工具"
        echo ""
        echo "💡 安装建议:"
        echo "   install_zoxide  - 安装现代高性能的 zoxide"
        echo "   然后重新加载配置: source ~/.zshrc"
    fi
    
    echo ""
    echo "🚀 性能提示:"
    echo "   • zoxide 比 z.lua 更快，推荐使用"
    echo "   • 使用频率越高的目录评分越高"
    echo "   • 支持模糊匹配和多关键词搜索"
    echo "   • 自动学习你的使用习惯"
}

# 自动初始化导航系统
init_navigation

# 别名
alias nav-status="check_navigation_status"
alias nav-help="show_navigation_help"
alias install-zoxide="install_zoxide"