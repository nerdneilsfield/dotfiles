# ZSH 性能调试和缓存管理工具

# @brief Benchmark ZSH startup time performance
# @return 0 on success
# @example benchmark_zsh
# @category performance
benchmark_zsh() {
    echo "🕐 测量 ZSH 启动时间..."
    
    local total_time=0
    local iterations=5
    
    for i in {1..$iterations}; do
        local start_time=$(date +%s%3N)
        zsh -c "source ~/.zshrc" >/dev/null 2>&1
        local end_time=$(date +%s%3N)
        
        # 确保时间变量是数字
        if [[ -n "$start_time" && -n "$end_time" && "$start_time" =~ ^[0-9]+$ && "$end_time" =~ ^[0-9]+$ ]]; then
            local duration=$((end_time - start_time))
        else
            local duration=0
            echo "第 $i 次: 时间获取失败"
            continue
        fi
        echo "第 $i 次: ${duration}ms"
        total_time=$((total_time + duration))
    done
    
    # 避免除零错误
    local avg_time=0
    if [[ $total_time -gt 0 && $iterations -gt 0 ]]; then
        avg_time=$((total_time / iterations))
    fi
    echo "📊 平均启动时间: ${avg_time}ms"
    
    if [[ $avg_time -lt 100 ]]; then
        echo "✅ 启动速度：优秀"
    elif [[ $avg_time -lt 300 ]]; then
        echo "⚠️  启动速度：一般"
    else
        echo "🚨 启动速度：需要优化"
    fi
}

# @brief Clear all ZSH configuration caches
# @return 0 on success
# @example clear_zsh_cache
# @category performance
clear_zsh_cache() {
    echo "🧹 清理 ZSH 缓存..."
    
    local cache_files=(
        "$HOME/.cache/zsh_location"
        "$HOME/.cache/zsh_python_versions"
        "$HOME/.cache/zsh_go_version"
        "$HOME/.cache/zsh_rust_version"
        "$HOME/.cache/zsh_node_version"
    )
    
    local cleaned=0
    for cache_file in "${cache_files[@]}"; do
        if [[ -f "$cache_file" ]]; then
            rm "$cache_file"
            echo "  删除: $cache_file"
            ((cleaned++))
        fi
    done
    
    if [[ $cleaned -eq 0 ]]; then
        echo "  没有找到缓存文件"
    else
        echo "✅ 清理了 $cleaned 个缓存文件"
    fi
}

# @brief Display current ZSH cache status and age
# @return 0 on success
# @example show_zsh_cache
# @category performance
show_zsh_cache() {
    echo "📋 ZSH 缓存状态："
    
    local cache_files=(
        "$HOME/.cache/zsh_location:地区检查"
        "$HOME/.cache/zsh_python_versions:Python版本"
    )
    
    for entry in "${cache_files[@]}"; do
        local file="${entry%:*}"
        local desc="${entry#*:}"
        
        if [[ -f "$file" ]]; then
            local mod_time=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
            local current_time=$(date +%s)
            
            # 确保时间变量不为空且为数字
            local age=0
            if [[ -n "$mod_time" && -n "$current_time" && "$mod_time" =~ ^[0-9]+$ && "$current_time" =~ ^[0-9]+$ ]]; then
                age=$(( (current_time - mod_time) / 60 ))
            fi
            local content=$(cat "$file" 2>/dev/null)
            
            printf "  %-15s | %3dm ago | %s\n" "$desc" "$age" "${content:0:20}"
        else
            printf "  %-15s | %s\n" "$desc" "无缓存"
        fi
    done
}

# @brief Warm up ZSH caches for better performance
# @return 0 on success
# @example warmup_cache
# @category performance
warmup_cache() {
    echo "🔥 预热缓存..."
    
    # 预热地区检查缓存
    echo -n "  地区检查... "
    if check_in_china >/dev/null 2>&1; then
        echo "✅"
    else
        echo "❌"
    fi
    
    # 预热 Python 版本缓存
    if command -v python3 >/dev/null 2>&1; then
        echo -n "  Python版本... "
        local python_ver=$(_get_python_versions 2>/dev/null)
        if [[ -n "$python_ver" ]]; then
            echo "✅ ($python_ver)"
        else
            echo "❌"
        fi
    fi
    
    echo "🎯 缓存预热完成"
}

# @brief Display ZSH performance optimization tips
# @return 0 on success
# @example zsh_performance_tips
# @category performance
zsh_performance_tips() {
    echo "🚀 ZSH 性能优化建议："
    echo ""
    echo "1. 📦 只安装需要的工具 - 避免不必要的模块加载"
    echo "2. 🗂️  定期清理缓存 - 运行 clear_zsh_cache"
    echo "3. ⏱️  监控启动时间 - 运行 benchmark_zsh"
    echo "4. 🔥 预热缓存 - 运行 warmup_cache"
    echo "5. 🔍 检查缓存状态 - 运行 show_zsh_cache"
    echo ""
    echo "缓存文件位置: ~/.cache/zsh_*"
    echo "缓存默认TTL: 地区检查(24h), Python版本(1h)"
}

# @brief Check if smart installation system is available
# @return 0 if available, 1 otherwise
# @example check_smart_install_available
# @category utils
check_smart_install_available() {
    command -v install_smart_tool >/dev/null 2>&1
}

# @brief Get system package manager type
# @return Package manager name
# @example get_system_package_manager
# @category utils
get_system_package_manager() {
    if command -v get_package_manager >/dev/null 2>&1; then
        get_package_manager
    else
        echo "unknown"
    fi
}

# @brief Show available installation methods for a tool
# @param $1 Tool name
# @return 0 on success
# @example show_install_methods curl
# @category utils
show_install_methods() {
    local tool="$1"
    if [[ -z "$tool" ]]; then
        echo "Usage: show_install_methods <tool_name>"
        return 1
    fi
    
    echo "🔧 工具 '$tool' 的可用安装方法："
    echo ""
    
    # 检查智能安装系统
    if check_smart_install_available; then
        echo "✅ 智能安装: install_smart_tool $tool"
    else
        echo "❌ 智能安装: 不可用"
    fi
    
    # 检查系统包管理器
    local pm=$(get_system_package_manager)
    case "$pm" in
        "brew")
            echo "✅ Homebrew: brew install $tool"
            ;;
        "pacman")
            echo "✅ Pacman: sudo pacman -S $tool"
            ;;
        "apt")
            echo "✅ APT: sudo apt install $tool"
            ;;
        "yum")
            echo "✅ YUM: sudo yum install $tool"
            ;;
        *)
            echo "❌ 系统包管理器: 未检测到"
            ;;
    esac
    
    # 检查 Cargo
    if command -v cargo >/dev/null 2>&1; then
        echo "✅ Cargo: cargo install $tool"
    else
        echo "❌ Cargo: 不可用"
    fi
    
    # 检查 NPM
    if command -v npm >/dev/null 2>&1; then
        echo "✅ NPM: npm install -g $tool"
    else
        echo "❌ NPM: 不可用"
    fi
    
    # 检查 pip
    if command -v pip3 >/dev/null 2>&1; then
        echo "✅ Pip: pip3 install --user $tool"
    else
        echo "❌ Pip: 不可用"
    fi
}

# @brief List all available install functions
# @return 0 on success
# @example list_install_functions
# @category utils
list_install_functions() {
    echo "📝 可用的安装函数："
    echo ""
    
    # 使用 help 系统查找所有 install_ 开头的函数
    if command -v show_functions_by_pattern >/dev/null 2>&1; then
        show_functions_by_pattern "^install_"
    else
        # 回退方法：直接搜索
        grep -r "^install_" ~/.config/zsh/*.zsh 2>/dev/null | \
            grep -E "^[^#]*install_[a-zA-Z0-9_]+\(\)" | \
            sed 's/.*\/\([^:]*\):\(install_[^(]*\).*/\2 (\1)/' | \
            sort | uniq
    fi
}

# @brief Get system CPU architecture with normalization
# @return Normalized architecture name
# @example get_cpu_arch
# @category utils
get_cpu_arch() {
    local arch=$(uname -m)
    
    # MSYS2/Windows 特殊处理
    if [[ "$(uname -o 2>/dev/null)" == "Msys" ]]; then
        # MSYS2 环境下，检查处理器架构
        case "$arch" in
            "x86_64"|"amd64")
                echo "x86_64"
                ;;
            "i686"|"i386")
                echo "i386"
                ;;
            *)
                # 尝试从 Windows 环境变量获取
                if [[ -n "$PROCESSOR_ARCHITECTURE" ]]; then
                    case "$PROCESSOR_ARCHITECTURE" in
                        "AMD64") echo "x86_64" ;;
                        "x86") echo "i386" ;;
                        *) echo "x86_64" ;;  # 默认假设 x86_64
                    esac
                else
                    echo "x86_64"  # MSYS2 默认 x86_64
                fi
                ;;
        esac
    else
        # 常规 Unix/Linux 系统
        case "$arch" in
            "x86_64"|"amd64")
                echo "x86_64"
                ;;
            "aarch64"|"arm64")
                echo "aarch64"
                ;;
            "armv7l")
                echo "armv7"
                ;;
            "i386"|"i686")
                echo "i386"
                ;;
            *)
                echo "$arch"
                ;;
        esac
    fi
}

# @brief Get architecture variants for different naming conventions
# @param $1 Architecture type (optional, defaults to current system)
# @return List of architecture variants
# @example get_arch_variants aarch64
# @category utils
get_arch_variants() {
    local base_arch="${1:-$(get_cpu_arch)}"
    
    case "$base_arch" in
        "aarch64")
            # ARM64架构的各种命名变体
            echo "aarch64 arm64 aarch64-unknown-linux-gnu aarch64-unknown-linux-musl aarch64-apple-darwin arm64-v8a"
            ;;
        "x86_64")
            # x86_64架构的各种命名变体
            if [[ "$(uname -o 2>/dev/null)" == "Msys" ]]; then
                # MSYS2/Windows 特定命名
                echo "x86_64 amd64 x86_64-pc-windows-msvc x86_64-pc-windows-gnu windows-x64 win64"
            else
                # Unix/Linux 命名
                echo "x86_64 amd64 x86_64-unknown-linux-gnu x86_64-unknown-linux-musl x86_64-apple-darwin"
            fi
            ;;
        "armv7")
            # ARMv7架构的各种命名变体
            echo "armv7 armv7l arm armhf armv7-unknown-linux-gnueabihf"
            ;;
        "i386")
            # 32位x86架构的各种命名变体
            if [[ "$(uname -o 2>/dev/null)" == "Msys" ]]; then
                # MSYS2/Windows 特定命名
                echo "i386 i686 x86 i586 i686-pc-windows-msvc i686-pc-windows-gnu windows-x86 win32"
            else
                # Unix/Linux 命名
                echo "i386 i686 x86 i586 i686-unknown-linux-gnu"
            fi
            ;;
        *)
            echo "$base_arch"
            ;;
    esac
}

# @brief Download with architecture fallback mechanism
# @param $1 Base URL pattern with {ARCH} placeholder
# @param $2 Output file path
# @param $3 Tool name for logging
# @return 0 on success, 1 on failure
# @example download_with_arch_fallback "https://github.com/user/tool/releases/download/v1.0/tool-{ARCH}.tar.gz" "/tmp/tool.tar.gz" "mytool"
# @category utils
download_with_arch_fallback() {
    local url_pattern="$1"
    local output_file="$2"
    local tool_name="${3:-unknown}"
    
    if [[ -z "$url_pattern" || -z "$output_file" ]]; then
        echo "❌ Usage: download_with_arch_fallback <url_pattern> <output_file> [tool_name]"
        return 1
    fi
    
    # 获取当前系统架构的所有变体
    local arch_variants=($(get_arch_variants))
    
    echo "🔍 尝试下载 $tool_name，检测到架构变体: ${arch_variants[*]}"
    
    # 尝试每个架构变体
    for arch in "${arch_variants[@]}"; do
        local download_url="${url_pattern//\{ARCH\}/$arch}"
        echo "📥 尝试下载: $download_url"
        
        # 使用curl下载，静默模式但显示错误
        if curl -L --fail --connect-timeout 10 --max-time 30 \
               --output "$output_file" "$download_url" 2>/dev/null; then
            echo "✅ 成功下载 $tool_name (架构: $arch)"
            return 0
        else
            echo "⚠️  架构 $arch 下载失败，尝试下一个..."
        fi
    done
    
    echo "❌ 所有架构变体都下载失败: ${arch_variants[*]}"
    return 1
}

# @brief Smart download with multiple fallback strategies
# @param $1 Tool name
# @param $2 GitHub repo (owner/repo)
# @param $3 Version tag
# @param $4 File pattern with {ARCH} placeholder
# @param $5 Output directory
# @return 0 on success, 1 on failure
# @example smart_download_tool "ripgrep" "BurntSushi/ripgrep" "14.1.1" "ripgrep-{VERSION}-{ARCH}-unknown-linux-gnu.tar.gz" "/tmp"
# @category utils
smart_download_tool() {
    local tool_name="$1"
    local repo="$2"
    local version="$3"
    local pattern="$4"
    local output_dir="${5:-/tmp}"
    
    if [[ -z "$tool_name" || -z "$repo" || -z "$version" || -z "$pattern" ]]; then
        echo "❌ Usage: smart_download_tool <tool> <repo> <version> <pattern> [output_dir]"
        echo "   Pattern should include {VERSION} and {ARCH} placeholders"
        return 1
    fi
    
    echo "🚀 智能下载 $tool_name v$version..."
    
    # 创建输出目录
    mkdir -p "$output_dir"
    
    # 准备URL模式
    local base_url=""
    if [ "${version}" == "latest" ]; then
        base_url="https://github.com/$repo/releases/download/$version"
    else
        base_url="https://github.com/$repo/releases/download/v$version"
    fi
    local file_pattern="${pattern//\{VERSION\}/$version}"
    local full_url_pattern="$base_url/$file_pattern"
    local output_file="$output_dir/${tool_name}.tar.gz"
    
    # 首先尝试直接下载
    if download_with_arch_fallback "$full_url_pattern" "$output_file" "$tool_name"; then
        return 0
    fi
    
    # 如果直接下载失败，尝试GitHub代理
    echo "🔄 尝试GitHub代理下载..."
    local proxy_url_pattern="https://ghproxy.dengqi.org/$full_url_pattern"
    if download_with_arch_fallback "$proxy_url_pattern" "$output_file" "$tool_name"; then
        return 0
    fi
    
    echo "❌ $tool_name 下载失败"
    return 1
}

# @brief Test architecture detection and variants
# @return 0 on success
# @example test_arch_detection
# @category utils
test_arch_detection() {
    echo "🔍 架构检测测试:"
    echo "当前系统架构: $(uname -m)"
    echo "标准化架构: $(get_cpu_arch)"
    echo "架构变体: $(get_arch_variants)"
    echo ""
    
    echo "📝 其他架构的变体示例:"
    for arch in "aarch64" "x86_64" "armv7" "i386"; do
        echo "$arch: $(get_arch_variants $arch)"
    done
}

# @brief Demo smart download with architecture fallback
# @return 0 on success
# @example demo_smart_download
# @category utils
demo_smart_download() {
    echo "🎆 智能下载架构回退演示"
    echo ""
    
    # 演示架构检测
    test_arch_detection
    echo ""
    
    # 演示下载 URL 生成
    echo "🔗 URL 模式生成示例:"
    local demo_pattern="https://github.com/BurntSushi/ripgrep/releases/download/v14.1.1/ripgrep-14.1.1-{ARCH}-unknown-linux-musl.tar.gz"
    echo "原始模式: $demo_pattern"
    echo ""
    
    local arch_variants=($(get_arch_variants))
    for arch in "${arch_variants[@]}"; do
        local url="${demo_pattern//\{ARCH\}/$arch}"
        echo "  $arch: $url"
    done
    
    echo ""
    echo "📦 实际下载测试 (仅测试连接性):"
    echo "使用命令: smart_download_tool ripgrep BurntSushi/ripgrep 14.1.1 'ripgrep-{VERSION}-{ARCH}-unknown-linux-musl.tar.gz' /tmp/demo"
    echo ""
    echo "⚠️  这只是演示，不会实际下载文件"
}

# @brief Show common architecture naming patterns for different projects
# @return 0 on success
# @example show_arch_patterns
# @category utils
show_arch_patterns() {
    echo "📋 常见项目的架构命名模式:"
    echo ""
    
    echo "🦀 Rust 项目 (ripgrep, fd, eza, bat):"
    echo "  x86_64: x86_64-unknown-linux-gnu, x86_64-unknown-linux-musl"
    echo "  ARM64:  aarch64-unknown-linux-gnu, aarch64-unknown-linux-musl"
    echo "  ARMv7:  armv7-unknown-linux-gnueabihf"
    echo ""
    
    echo "🐍 Go 项目 (lazygit, gh, docker):"
    echo "  x86_64: x86_64, amd64"
    echo "  ARM64:  arm64, aarch64"
    echo "  ARMv7:  armv7, arm"
    echo ""
    
    echo "🔧 C/C++ 项目 (cmake, ninja):"
    echo "  x86_64: x86_64, amd64"
    echo "  ARM64:  aarch64, arm64"
    echo "  ARMv7:  armhf, arm"
    echo ""
    
    echo "📱 Node.js 项目:"
    echo "  x86_64: x64"
    echo "  ARM64:  arm64"
    echo "  ARMv7:  armv7l"
    echo ""
    
    echo "🚀 智能下载系统会自动尝试这些变体！"
}

# 别名
alias zsh-bench="benchmark_zsh"
alias zsh-cache="show_zsh_cache"
alias zsh-clear="clear_zsh_cache"
alias zsh-warmup="warmup_cache"
alias zsh-tips="zsh_performance_tips"
alias show-install="show_install_methods"
alias list-installs="list_install_functions"
alias test-arch="test_arch_detection"
alias demo-download="demo_smart_download"
alias show-arch="show_arch_patterns"
