# echo ">>>> STARTING utils.zsh execution (Timestamp: $(date +%s.%N)) <<<<"
# echo ">>>> SOURCING FILE: $0 <<<<"

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
    
    # 预热地区检查缓存 (Simplified Echo)
    echo "Checking location..."
    if check_in_china >/dev/null 2>&1; then
        echo "In China"
    else
        echo "Not in China"
    fi
    
    # 预热 Python 版本缓存 (Simplified Echo)
    if command -v python3 >/dev/null 2>&1; then
        echo "Checking Python version..."
        local python_ver=$(_get_python_versions 2>/dev/null)
        if [[ -n "$python_ver" ]]; then
            echo "Python version found"
        else
            echo "Python version not found"
        fi
    fi
    
    echo "🎯 缓存预热完成"
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
# @param $2 Output directory
# @param $3 Filename pattern with {ARCH} placeholder (VERSION already resolved)
# @param $4 Tool name for logging
# @return 0 on success, 1 on failure
# @example download_with_arch_fallback "https://example.com/tool-{ARCH}.zip" "/tmp" "tool-{ARCH}.zip" "mytool"
# @category utils
download_with_arch_fallback() {
    local url_template="$1"          # e.g., https://.../tool-{VERSION}-{ARCH}.ext (VERSION already resolved by caller)
    local output_dir="$2"
    local filename_template="$3"     # e.g., tool-{VERSION}-{ARCH}.ext (VERSION already resolved by caller)
    local tool_name="${4:-unknown}"

    if [[ -z "$url_template" || -z "$output_dir" || -z "$filename_template" ]]; then
        echo "❌ Usage: download_with_arch_fallback <url_template_with_arch> <output_dir> <filename_template_with_arch> [tool_name]" >&2
        return 1
    fi

    local arch_variants=($(get_arch_variants))
    echo "🔍 尝试下载 $tool_name，检测到架构变体: ${arch_variants[*]}" >&2

    for arch in "${arch_variants[@]}"; do
        # Use single substitution to prevent issues if $arch contains parts of the template
        local current_download_url="${url_template/\{ARCH\}/$arch}"
        local current_filename="${filename_template/\{ARCH\}/$arch}"
        local output_file_path="$output_dir/$current_filename"

        mkdir -p "$(dirname "$output_file_path")"

        echo "📥 尝试下载 (Arch: $arch)" >&2
        echo "💻 Curling URL: $current_download_url" >&2
        echo "   保存到: $output_file_path" >&2
        
        if curl -L --fail --connect-timeout 10 --max-time 300 \
               --output "$output_file_path" "$current_download_url" 2>/dev/null; then
            echo "✅ 成功下载 $tool_name (架构: $arch) 到 $output_file_path" >&2
            echo "$output_file_path" # Return the successful file path on stdout
            return 0
        else
            echo "⚠️  架构 $arch 下载失败 ($current_download_url)，尝试下一个..." >&2
            rm -f "$output_file_path" 2>/dev/null
        fi
    done

    echo "❌ 所有架构变体都下载失败 ($tool_name) 使用 URL 模板: $url_template" >&2
    return 1
}

# @brief Smart download with multiple fallback strategies
# @param $1 Tool name
# @param $2 GitHub repo (owner/repo)
# @param $3 Version tag (e.g., "v1.2.3", "1.2.3", or "latest")
# @param $4 Asset filename pattern (e.g., "tool-{VERSION}-{ARCH}.tar.gz")
# @param $5 Target installation prefix (e.g., $HOME/.local or /usr/local). Files will be downloaded to a temporary dir.
# @param $6 (Optional) Example tag extracted from a sample URL path, to guide tag formatting (e.g., "v0.1.0")
# @return 0 on success, 1 on failure
# @example smart_download_tool "ripgrep" "BurntSushi/ripgrep" "14.1.1" "ripgrep-{VERSION}-{ARCH}-unknown-linux-gnu.tar.gz" "$HOME/.local"
# @example smart_download_tool "mytool" "owner/mytool" "v0.1.0" "mytool-v{VERSION}-dist-{ARCH}.zip" "/opt/tools"
# @example smart_download_tool "another" "user/another" "latest" "another-tool-{VERSION}_{ARCH}.deb" "/usr/local"
# @example smart_download_tool "gh" "cli/cli" "2.40.0" "gh_{VERSION}_linux_{ARCH}.tar.gz" "$HOME/.local" "v2.40.0"
# @category utils
smart_download_tool() {
    local tool_name="$1"
    local repo="$2"
    local version_arg="$3"
    local asset_pattern_arg="$4"
    local final_install_prefix="${5:-$HOME/.local}" # Default install prefix
    local example_tag_for_guidance="$6" # Optional example tag from URL

    if [[ -z "$tool_name" || -z "$repo" || -z "$version_arg" || -z "$asset_pattern_arg" || -z "$final_install_prefix" ]]; then # example_tag is optional
        echo "❌ Usage: smart_download_tool <tool_name> <repo> <version_tag> <asset_pattern> <install_prefix> [example_tag_from_url]" >&2
        echo "   Install_prefix: e.g., '$HOME/.local' or '/usr/local'" >&2
        return 1
    fi

    local temp_download_base_dir="/tmp/smart_download_install"
    local download_dir="$temp_download_base_dir/$tool_name/download"
    local extracted_base_dir="$temp_download_base_dir/$tool_name/extracted"
    
    # Clean up previous temp dirs for this tool if they exist
    rm -rf "$temp_download_base_dir/$tool_name"
    mkdir -p "$download_dir"
    mkdir -p "$extracted_base_dir"

    echo "🚀 智能下载并安装 $tool_name, 版本参数: $version_arg 到 $final_install_prefix ..." >&2

    local tag_for_url=""
    local version_for_pattern_substitution=""

    if [[ "${version_arg}" == "latest" ]]; then
        echo "🔄 正在为 $repo 获取最新的 release tag..." >&2
        local actual_release_tag
        if command -v GetLatestRelease >/dev/null 2>&1; then
            actual_release_tag=$(GetLatestRelease "$repo" 2>/dev/null)
        elif command -v GetLatestReleaseProxy >/dev/null 2>&1; then # Fallback to proxy if main one not found
            actual_release_tag=$(GetLatestReleaseProxy "$repo" 2>/dev/null)
        else
            echo "⚠️  GetLatestRelease 和 GetLatestReleaseProxy 命令均未找到。" >&2
            actual_release_tag=""
        fi

        if [[ -n "$actual_release_tag" ]]; then
            echo "✅ 获取到最新 tag: $actual_release_tag" >&2
            tag_for_url="$actual_release_tag" 
            # version_for_pattern_substitution is usually the tag without 'v', but let's refine
            if [[ -n "$example_tag_for_guidance" ]]; then
                # If example tag starts with 'v' and actual_release_tag doesn't, prepend 'v' to tag_for_url
                if [[ "$example_tag_for_guidance" == v* && "$actual_release_tag" != v* ]]; then
                    tag_for_url="v$actual_release_tag"
                # If example tag does NOT start with 'v' and actual_release_tag does, remove 'v' from tag_for_url
                elif [[ "$example_tag_for_guidance" != v* && "$actual_release_tag" == v* ]]; then
                     tag_for_url="${actual_release_tag#v}"
                fi
                echo "ℹ️ 根据示例 URL 的标签 ('$example_tag_for_guidance') 调整 tag_for_url 为: $tag_for_url" >&2
            fi
            version_for_pattern_substitution="${actual_release_tag#v}" # For pattern, consistently use no 'v'
        else
            echo "⚠️  无法获取 $repo 的最新 release tag。将直接使用 'latest' 作为 tag。" >&2
            echo "   文件名中的 {VERSION} 也将替换为 'latest'。" >&2
            tag_for_url="latest"
            version_for_pattern_substitution="latest"
        fi
    else
        # version_arg is a specific version like "v1.2.3" or "1.2.3"
        tag_for_url="$version_arg"
        # If example_tag_for_guidance is provided, use its v-prefixing as a guide for tag_for_url
        if [[ -n "$example_tag_for_guidance" ]]; then
            if [[ "$example_tag_for_guidance" == v* && "$tag_for_url" != v* ]]; then
                tag_for_url="v$tag_for_url"
            elif [[ "$example_tag_for_guidance" != v* && "$tag_for_url" == v* ]]; then
                tag_for_url="${tag_for_url#v}"
            fi
            echo "ℹ️ 根据示例 URL 的标签 ('$example_tag_for_guidance') 调整提供的版本 $version_arg 为 tag_for_url: $tag_for_url" >&2
        fi
        version_for_pattern_substitution="${version_arg#v}"
    fi

    echo "ℹ️ URL 将使用 Tag: $tag_for_url" >&2
    echo "ℹ️ 文件名模板中的 {VERSION} 将替换为: $version_for_pattern_substitution" >&2

    local filename_template_with_arch="${asset_pattern_arg//\{VERSION\}/$version_for_pattern_substitution}"
    local base_download_url="https://github.com/$repo/releases/download/$tag_for_url"
    local full_url_template_with_arch="$base_download_url/$filename_template_with_arch"
    
    echo "📝 URL 模板: $full_url_template_with_arch" >&2
    echo "📝 文件名模板: $filename_template_with_arch" >&2

    local actual_downloaded_file_path
    local download_rc=1

    # Attempt 1: Direct download
    actual_downloaded_file_path=$(download_with_arch_fallback "$full_url_template_with_arch" "$download_dir" "$filename_template_with_arch" "$tool_name")
    download_rc=$?

    # Attempt 2: GitHub Proxy, if direct download failed
    if [[ $download_rc -ne 0 ]]; then
        echo "🔄 直接下载失败，尝试GitHub代理下载..." >&2
        local proxy_url_template_with_arch="https://ghproxy.dengqi.org/$full_url_template_with_arch"
        actual_downloaded_file_path=$(download_with_arch_fallback "$proxy_url_template_with_arch" "$download_dir" "$filename_template_with_arch" "$tool_name")
        download_rc=$?
    fi
    
    if [[ $download_rc -eq 0 && -n "$actual_downloaded_file_path" && -f "$actual_downloaded_file_path" ]]; then
        echo "✅ $tool_name 下载成功到 $actual_downloaded_file_path" >&2
        
        local archive_basename
        archive_basename=$(basename "$actual_downloaded_file_path")
        
        local extracted_content_dirname=${archive_basename%.tar.gz}
        extracted_content_dirname=${extracted_content_dirname%.tgz}
        extracted_content_dirname=${extracted_content_dirname%.tar.bz2}
        extracted_content_dirname=${extracted_content_dirname%.tbz2}
        extracted_content_dirname=${extracted_content_dirname%.tar.xz}
        extracted_content_dirname=${extracted_content_dirname%.txz}
        extracted_content_dirname=${extracted_content_dirname%.zip}
        extracted_content_dirname=${extracted_content_dirname%.tar}
        
        local specific_extracted_dir="$extracted_base_dir/$extracted_content_dirname"
        mkdir -p "$specific_extracted_dir"

        if smart_decompress "$actual_downloaded_file_path" "$specific_extracted_dir"; then
            echo "✅ $tool_name 解压成功到 $specific_extracted_dir" >&2
            
            local dir_to_install_from="$specific_extracted_dir"
            local sub_items_in_extracted_dir=("$specific_extracted_dir"/*(N))
            if [[ ${#sub_items_in_extracted_dir[@]} -eq 1 && -d "${sub_items_in_extracted_dir[1]}" ]]; then
                echo "ℹ️ 解压后发现单个子目录: ${sub_items_in_extracted_dir[1]}. 将从此目录安装." >&2
                dir_to_install_from="${sub_items_in_extracted_dir[1]}"
            else
                echo "ℹ️ 将从解压根目录 '$specific_extracted_dir' 尝试安装." >&2
            fi
            
            if smart_install_downloaded "$dir_to_install_from" "$final_install_prefix"; then
                 echo "✅ $tool_name 成功安装到 $final_install_prefix." >&2
                 # rm -rf "$temp_download_base_dir/$tool_name" # Clean up temporary files for this tool
                 return 0
            else
                echo "❌ $tool_name 安装到 $final_install_prefix 失败." >&2
            fi
        else
            echo "❌ $tool_name 解压 $actual_downloaded_file_path 失败." >&2
        fi
    else
        echo "❌ $tool_name 下载失败 (已尝试直接下载和通过代理)." >&2
    fi
    
    # rm -rf "$temp_download_base_dir/$tool_name" # Clean up temporary files for this tool even on failure
    echo "❌ $tool_name 处理流程未成功完成." >&2
    return 1
}

# Helper function for extract_download_pattern
# Gathers a comprehensive list of known architecture strings, sorted by length descending.
_get_all_known_arch_strings() {
    local all_archs_list=()
    # Common base architectures for which to generate variants from get_arch_variants
    local base_arch_types=("aarch64" "x86_64" "armv7" "i386" "amd64" "arm64")

    for base_arch_type in "${base_arch_types[@]}"; do
        if command -v get_arch_variants >/dev/null 2>&1; then
            local variants_for_base_type=($(get_arch_variants "$base_arch_type"))
            all_archs_list+=("${variants_for_base_type[@]}")
        fi
    done

    # Add other commonly observed architecture strings.
    # This list can be curated from 'show_arch_patterns' and common release file names.
    all_archs_list+=(
        "x86_64-unknown-linux-gnu" "x86_64-unknown-linux-musl"
        "aarch64-unknown-linux-gnu" "aarch64-unknown-linux-musl"
        "armv7-unknown-linux-gnueabihf"
        "i686-unknown-linux-gnu" "i686-unknown-linux-musl"
        "x86_64-apple-darwin" "aarch64-apple-darwin"
        "windows-x64" "win64" "windows-x86" "win32" "pc-windows-msvc" "pc-windows-gnu"
        "unknown-linux-gnu" "unknown-linux-musl" "apple-darwin"
        "amd64" "x64" 
        "arm64" 
        "x86"   
        "musl" "gnu"
        # Add shorter/generic terms last if sorting isn't perfect or for broader fallback.
        # However, the sort step below should handle prioritization.
    )

    # Deduplicate
    all_archs_list=(${(u)all_archs_list})

    # Sort by length descending to prioritize longer, more specific matches.
    # Then sort alphabetically for stable order among same-length strings.
    local sorted_archs_temp=()
    local item
    if [[ ${#all_archs_list[@]} -gt 0 ]]; then
        for item in "${all_archs_list[@]}"; do
            if [[ -n "$item" ]]; then # Ensure no empty strings
                printf "%s\n" "$item"
            fi
        done | awk '{ print length, $0 }' | sort -rnb -k1,1 -k2,2b | cut -d' ' -f2- | while IFS= read -r line; do
            sorted_archs_temp+=("$line")
        done
    fi
    
    # Return as a space-separated string
    echo "${sorted_archs_temp[*]}"
}

# @brief Extract download pattern from actual download URL using a Python script
# @param $1 Actual download URL
# @return Download pattern (e.g., tool-{VERSION}-{ARCH}.tar.gz)
# @example extract_download_pattern "https://github.com/ajeetdsouza/zoxide/releases/download/v0.9.8/zoxide-0.9.8-i686-unknown-linux-musl.tar.gz"
# @category utils
extract_download_pattern() {
    local actual_download_url="$1"
    if [[ -z "$actual_download_url" ]]; then
        echo "Usage: extract_download_pattern <actual_download_url>" >&2
        return 1
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: python3 command not found, required by extract_download_pattern." >&2
        return 1
    fi

    local python_script_path="${ZDOTDIR:-$HOME/.config}/zsh/python/extract_pattern.py"
    if [[ ! -f "$python_script_path" ]]; then
        echo "Error: Python script not found at $python_script_path" >&2
        return 1
    fi

    local filename_asset
    filename_asset=$(basename "$actual_download_url")
    if [[ -z "$filename_asset" ]]; then
        echo "Error: Could not extract filename from URL: $actual_download_url" >&2
        return 1
    fi

    local dir_name
    dir_name=$(dirname "$actual_download_url")
    if [[ "$dir_name" == "." || "$dir_name" == "/" || "$dir_name" != *"/releases/download/"* ]]; then
         echo "Error: URL does not appear to be a standard GitHub release download URL or tag is missing: $actual_download_url" >&2
         return 1
    fi
    local tag_in_url
    tag_in_url=$(basename "$dir_name")

    if [[ -z "$tag_in_url" ]]; then
        echo "Error: Could not extract tag from URL: $actual_download_url" >&2
        return 1 # Or perhaps allow to proceed without a version?
    fi

    local version_bare="${tag_in_url#v}"
    # Pass empty string to python if version_bare is empty or just "v"
    if [[ -z "$version_bare" || "$version_bare" == "v" ]]; then
        version_bare=""
    fi
    
    local all_known_archs_str=$(_get_all_known_arch_strings)
    if [[ -z "$all_known_archs_str" ]]; then
        echo "Warning: List of known architecture strings is empty. This might affect pattern extraction." >&2
        # Proceeding with an empty list for the python script
    fi
    
    # Convert space-separated arch strings to a JSON array string for Python
    local known_arch_array=(${(ps: :)all_known_archs_str})
    local arch_json_parts=()
    local arch_item
    for arch_item in "${known_arch_array[@]}"; do
        # Escape double quotes within the item itself, then quote the item
        arch_json_parts+=("\"$(echo "$arch_item" | sed 's/"/\\"/g')\"") 
    done
    local known_arch_strings_json="[$(IFS=,; echo "${arch_json_parts[*]}")]"

    # echo "Debug Zsh: Filename: '$filename_asset'" >&2
    # echo "Debug Zsh: Version bare: '$version_bare'" >&2
    # echo "Debug Zsh: Arch JSON: '$known_arch_strings_json'" >&2

    local extracted_pattern
    extracted_pattern=$(python3 "$python_script_path" "$filename_asset" "$known_arch_strings_json" "$version_bare" 2>/tmp/extract_pattern_py_stderr.log)
    local python_rc=$?

    # Check if python script produced any output
    if [[ $python_rc -ne 0 || -z "$extracted_pattern" ]]; then
        echo "Error: Python script for pattern extraction failed or produced no output. RC: $python_rc" >&2
        echo "Python stderr log can be found in /tmp/extract_pattern_py_stderr.log" >&2
        # Fallback to a very basic or original name if python fails
        if [[ -n "$version_bare" ]] && [[ "$filename_asset" == *"$version_bare"* ]]; then 
            echo "${filename_asset/$version_bare/{VERSION}}" # very basic fallback
        else
            echo "$filename_asset"
        fi
        return 1
    fi

    # Further sanity check on the pattern from python to ensure it looks reasonable
    if [[ "$extracted_pattern" != *"{ARCH}"* && "$extracted_pattern" == *"{VERSION}"* && ${#known_arch_array[@]} -gt 0 ]] || \
       [[ "$extracted_pattern" != *"{VERSION}"* && "$extracted_pattern" == *"{ARCH}"* && -n "$version_bare" ]] || \
       (( $(echo "$extracted_pattern" | grep -o "{" | wc -l) != $(echo "$extracted_pattern" | grep -o "}" | wc -l) )) || \
       [[ "$extracted_pattern" == "$filename_asset" && (-n "$version_bare" || ${#known_arch_array[@]} -gt 0) ]] ; then # No change made
        echo "Warning: Pattern from Python script '$extracted_pattern' seems suspicious or unchanged. Original: '$filename_asset'" >&2
        # Potentially return a fallback or the script's result anyway if we trust it.
    fi

    echo "$extracted_pattern"
    return 0
}

# @brief Smart decompress with multiple fallback strategies
# @param $1 Compressed file path
# @param $2 Output directory
# @return 0 on success, 1 on failure
# @example smart_decompress "/tmp/tool.tar.gz" "/opt/tools"
# @category utils
smart_decompress(){
    local compressed_file_path="$1"
    local output_dir="$2"
    local func_name="smart_decompress" # For messages

    # Validate input
    if [[ -z "$compressed_file_path" ]]; then
        echo "❌ $func_name: Compressed file path not provided." >&2
        return 1
    fi
    if [[ ! -f "$compressed_file_path" ]]; then
        echo "❌ $func_name: Compressed file '$compressed_file_path' not found or is not a regular file." >&2
        return 1
    fi
    if [[ -z "$output_dir" ]]; then
        echo "❌ $func_name: Output directory not provided." >&2
        return 1
    fi

    # Ensure output directory exists
    if ! mkdir -p "$output_dir"; then
        echo "❌ $func_name: Failed to create output directory '$output_dir'." >&2
        return 1
    fi

    local filename
    filename=$(basename "$compressed_file_path")
    echo "⚙️  $func_name: Attempting to decompress '$filename' to '$output_dir'..."

    # Helper to check for command availability
    _is_tool_available() {
        command -v "$1" >/dev/null 2>&1
    }

    local op_status=1 # Default to failure

    case "$filename" in
        *.tar.gz|*.tgz)
            if _is_tool_available "tar"; then
                tar -xzf "$compressed_file_path" -C "$output_dir"
                op_status=$?
            else
                echo "❌ $func_name: 'tar' command not found, required for .$filename extension." >&2
            fi
            ;;
        *.tar.bz2|*.tbz2|*.tbz)
            if _is_tool_available "tar"; then
                tar -xjf "$compressed_file_path" -C "$output_dir"
                op_status=$?
            else
                echo "❌ $func_name: 'tar' command not found, required for .$filename extension." >&2
            fi
            ;;
        *.tar.xz|*.txz)
            if ! _is_tool_available "xz"; then
                echo "❌ $func_name: 'xz' command not found, required for .$filename extension." >&2
            elif ! _is_tool_available "tar"; then
                echo "❌ $func_name: 'tar' command not found, required for .$filename extension." >&2
            else
                xz -dc "$compressed_file_path" | tar -xf - -C "$output_dir"
                local pipe_rcs=("${pipestatus[@]}") # Zsh specific
                if [[ ${pipe_rcs[1]} -eq 0 && ${pipe_rcs[2]} -eq 0 ]]; then
                    op_status=0
                else
                    echo "❌ $func_name: Decompression failed (xz status: ${pipe_rcs[1]}, tar status: ${pipe_rcs[2]})." >&2
                    op_status=1
                fi
            fi
            ;;
        *.tar)
            if _is_tool_available "tar"; then
                tar -xf "$compressed_file_path" -C "$output_dir"
                op_status=$?
            else
                echo "❌ $func_name: 'tar' command not found, required for .$filename extension." >&2
            fi
            ;;
        *.zip)
            if _is_tool_available "unzip"; then
                unzip -qo "$compressed_file_path" -d "$output_dir"
                op_status=$?
            else
                echo "❌ $func_name: 'unzip' command not found, required for .$filename extension." >&2
            fi
            ;;
        *.gz)
            local out_fname="$output_dir/$(basename "$filename" .gz)"
            if [[ -d "$out_fname" ]]; then
                echo "❌ $func_name: Output file '$out_fname' would overwrite an existing directory." >&2
            elif _is_tool_available "gunzip"; then
                gunzip -kc "$compressed_file_path" > "$out_fname"
                op_status=$?
            elif _is_tool_available "gzip"; then # Fallback to gzip -dc
                gzip -dc "$compressed_file_path" > "$out_fname"
                op_status=$?
            else
                echo "❌ $func_name: 'gunzip' or 'gzip' not found, required for .gz files." >&2
            fi
            ;;
        *.bz2)
            local out_fname="$output_dir/$(basename "$filename" .bz2)"
            if [[ -d "$out_fname" ]]; then
                echo "❌ $func_name: Output file '$out_fname' would overwrite an existing directory." >&2
            elif _is_tool_available "bunzip2"; then
                bunzip2 -kc "$compressed_file_path" > "$out_fname"
                op_status=$?
            elif _is_tool_available "bzip2"; then # Fallback to bzip2 -dc
                bzip2 -dc "$compressed_file_path" > "$out_fname"
                op_status=$?
            else
                echo "❌ $func_name: 'bunzip2' or 'bzip2' not found, required for .bz2 files." >&2
            fi
            ;;
        *.xz) # Single .xz file, not .tar.xz
            local out_fname="$output_dir/$(basename "$filename" .xz)"
            if [[ -d "$out_fname" ]]; then
                echo "❌ $func_name: Output file '$out_fname' would overwrite an existing directory." >&2
            elif _is_tool_available "xz"; then
                xz -dkc "$compressed_file_path" > "$out_fname"
                op_status=$?
            else
                echo "❌ $func_name: 'xz' command not found, required for .xz files." >&2
            fi
            ;;
        *)
            echo "❌ $func_name: Unsupported file type for '$filename'." >&2
            op_status=1 # Already default, but explicit
            ;;
    esac

    if [[ $op_status -eq 0 ]]; then
        echo "✅ $func_name: Successfully decompressed '$filename' to '$output_dir'."
        return 0
    else
        # Specific error messages are usually printed by the case block or the tool itself.
        # This final message confirms the overall failure.
        echo "❌ $func_name: Failed to decompress '$filename'."
        return $op_status # Return the specific non-zero status if set by a tool, or 1.
    fi
}


# @brief Smart install downloaded tool
# @param $1 extracted directory (source of files)
# @param $2 install_prefix (e.g., /usr/local, $HOME/.local)
# @return 0 on success, 1 on failure
# @example smart_install_downloaded "/tmp/zoxide_extracted" "$HOME/.local"
# @category utils
smart_install_downloaded() {
    if [[ $# -ne 2 ]]; then
        echo "❌ Usage: smart_install_downloaded <extracted_dir> <install_prefix>" >&2
        return 1
    fi

    local extracted_dir="$1"
    local install_prefix="$2"
    local func_name="smart_install_downloaded"

    if [[ ! -d "$extracted_dir" ]]; then
        echo "❌ $func_name: Extracted directory '$extracted_dir' not found." >&2
        return 1
    fi

    # Infer tool name from extracted_dir, fallback to 'unknown_tool'
    local tool_name
    tool_name=$(basename "$extracted_dir")
    tool_name=${tool_name%_extracted} # Remove common suffix if present
    tool_name=${tool_name:-unknown_tool}
    
    echo "⚙️  $func_name: Preparing to install '$tool_name' from '$extracted_dir' to '$install_prefix'..."

    # Determine if sudo is needed
    local sudo_cmd=""
    if [[ ! -w "$install_prefix" ]]; then
        if command -v sudo >/dev/null 2>&1; then
            echo "ℹ️ $func_name: Install prefix '$install_prefix' is not writable. Will attempt to use sudo."
            sudo_cmd="sudo"
        else
            echo "❌ $func_name: Install prefix '$install_prefix' is not writable and sudo command not found. Cannot proceed." >&2
            return 1
        fi
    fi

    # Helper functions that prepend sudo if needed
    _mkdir_p() { $sudo_cmd mkdir -p "$@" || { echo "❌ $func_name: Failed to create directory '$@'." >&2; return 1; } }
    _mv() { $sudo_cmd mv "$@" || { echo "❌ $func_name: Failed to move '$1' to '$2'." >&2; return 1; } }
    _cp() { $sudo_cmd cp "$@" || { echo "❌ $func_name: Failed to copy '$1' to '$2'." >&2; return 1; } }
    _cp_r() { $sudo_cmd cp -r "$@" || { echo "❌ $func_name: Failed to copy recursively '$1' to '$2'." >&2; return 1; } }
    _rm_rf() { $sudo_cmd rm -rf "$@" || { echo "❌ $func_name: Failed to remove '$@'." >&2; return 1; } }


    # --- Define Target Directories ---
    local target_bin_dir="$install_prefix/bin"
    local target_lib_dir="$install_prefix/lib" # Common, could also have lib64
    local target_include_dir="$install_prefix/include"
    local target_share_dir="$install_prefix/share"
    local target_man_dir="$target_share_dir/man"
    local target_doc_dir="$target_share_dir/doc/$tool_name"
    local target_bash_completion_dir="$target_share_dir/bash-completion/completions"
    local target_zsh_completion_dir="$target_share_dir/zsh/site-functions"
    local target_fish_completion_dir="$target_share_dir/fish/vendor_completions.d"
    # Generic completion dir if specific shell type is not identified
    local target_generic_completions_dir="$target_share_dir/$tool_name/completions"


    # --- Create Target Directories ---
    echo "创建目标目录..."
    _mkdir_p "$target_bin_dir" || return 1
    _mkdir_p "$target_lib_dir" || return 1
    _mkdir_p "$target_include_dir" || return 1
    _mkdir_p "$target_share_dir" || return 1
    _mkdir_p "$target_man_dir" || return 1
    _mkdir_p "$target_doc_dir" || return 1
    _mkdir_p "$target_bash_completion_dir" || return 1
    _mkdir_p "$target_zsh_completion_dir" || return 1
    _mkdir_p "$target_fish_completion_dir" || return 1
    _mkdir_p "$target_generic_completions_dir" || return 1


    # --- Process and Install Files ---
    echo "处理并安装文件从 '$extracted_dir'..."

    # Change to extracted directory to simplify find commands and globs
    # but ensure we return to original PWD
    local original_pwd=$PWD
    cd "$extracted_dir" || { echo "❌ $func_name: Failed to cd to '$extracted_dir'." >&2; return 1; }

    # 1. Executables
    # Files directly in extracted_dir that are executable
    find . -maxdepth 1 -type f -executable -print0 | while IFS= read -r -d $'\0' file; do
        local fname=$(basename "$file")
        echo "  -> Installing executable '$fname' to '$target_bin_dir/'"
        _mv "$file" "$target_bin_dir/" || { cd "$original_pwd"; return 1; }
    done
    # Files in extracted_dir/bin
    if [[ -d "bin" ]]; then
        find bin -type f -executable -print0 | while IFS= read -r -d $'\0' file; do
            local fname=$(basename "$file")
            echo "  -> Installing executable 'bin/$fname' to '$target_bin_dir/'"
            _mv "$file" "$target_bin_dir/" || { cd "$original_pwd"; return 1; }
        done
        # Attempt to remove bin dir if empty after moving files
        rmdir bin 2>/dev/null
    fi

    # 2. Libraries (lib and lib64)
    for lib_subdir in lib lib64; do
        if [[ -d "$lib_subdir" ]]; then
            local current_target_lib_dir="$install_prefix/$lib_subdir" # e.g. /usr/local/lib64
             _mkdir_p "$current_target_lib_dir" || { cd "$original_pwd"; return 1; }
            echo "  -> Installing contents of '$lib_subdir/' to '$current_target_lib_dir/'"
            # Move all files and subdirectories from lib_subdir/* to target_lib_dir/
            # Using find to handle cases where there might be many files or complex names
            find "$lib_subdir" -mindepth 1 -maxdepth 1 -print0 | while IFS= read -r -d $'\0' item; do
                _mv "$item" "$current_target_lib_dir/" || { cd "$original_pwd"; return 1; }
            done
            rmdir "$lib_subdir" 2>/dev/null
        fi
    done

    # 3. Include files
    if [[ -d "include" ]]; then
        echo "  -> Installing contents of 'include/' to '$target_include_dir/'"
        find "include" -mindepth 1 -maxdepth 1 -print0 | while IFS= read -r -d $'\0' item; do
            _mv "$item" "$target_include_dir/" || { cd "$original_pwd"; return 1; }
        done
        rmdir "include" 2>/dev/null
    fi

    # 4. Man pages
    if [[ -d "man" ]]; then
        find man -type d -name "man[0-9n]" -print0 | while IFS= read -r -d $'\0' man_section_dir; do
            local section=$(basename "$man_section_dir") # e.g., man1
            local target_man_section_dir="$target_man_dir/$section"
            _mkdir_p "$target_man_section_dir" || { cd "$original_pwd"; return 1; }
            find "$man_section_dir" -type f -name "*.[0-9n]*" -print0 | while IFS= read -r -d $'\0' man_file; do
                local man_fname=$(basename "$man_file")
                echo "  -> Installing man page '$man_fname' from '$man_section_dir/' to '$target_man_section_dir/'"
                _mv "$man_file" "$target_man_section_dir/" || { cd "$original_pwd"; return 1; }
            done
            rmdir "$man_section_dir" 2>/dev/null
        done
        # Attempt to remove man dir if empty
        rmdir man 2>/dev/null
    fi

    # 5. Completion scripts
    if [[ -d "completions" ]]; then
        find completions -type f -print0 | while IFS= read -r -d $'\0' comp_file; do
            local comp_fname=$(basename "$comp_file")
            local installed_completion=0
            # Zsh
            if [[ "$comp_fname" == "_$tool_name" || "$comp_fname" == "$tool_name.zsh" ]]; then
                echo "  -> Installing Zsh completion '$comp_fname' to '$target_zsh_completion_dir/_$tool_name'"
                _mv "$comp_file" "$target_zsh_completion_dir/_$tool_name" && installed_completion=1
            # Bash
            elif [[ "$comp_fname" == "$tool_name.bash" || "$comp_fname" == "$tool_name" && $(file -b --mime-type "$comp_file") == "text/x-shellscript" && $(head -n 1 "$comp_file" | grep -q "bash") ]]; then
                echo "  -> Installing Bash completion '$comp_fname' to '$target_bash_completion_dir/$tool_name'"
                _mv "$comp_file" "$target_bash_completion_dir/$tool_name" && installed_completion=1
            # Fish
            elif [[ "$comp_fname" == "$tool_name.fish" ]]; then
                echo "  -> Installing Fish completion '$comp_fname' to '$target_fish_completion_dir/$comp_fname'"
                _mv "$comp_file" "$target_fish_completion_dir/$comp_fname" && installed_completion=1
            fi
            
            if [[ $installed_completion -eq 0 ]]; then
                 # Try to install to generic dir if not matched or move failed
                echo "  -> Installing generic completion '$comp_fname' to '$target_generic_completions_dir/'"
                _mv "$comp_file" "$target_generic_completions_dir/"  # No error check for cd back here for now
            fi
        done
         # Attempt to remove completions dir if empty
        rmdir completions 2>/dev/null
    fi

    # 6. Documentation files (LICENSE, README, etc.)
    find . -maxdepth 1 -type f \( \
        -iname "LICENSE*" -o \
        -iname "README*" -o \
        -iname "CHANGELOG*" -o \
        -iname "COPYING*" -o \
        -iname "NOTICE*" \
        \) -print0 | while IFS= read -r -d $'\0' doc_file; do
        local doc_fname=$(basename "$doc_file")
        echo "  -> Installing documentation file '$doc_fname' to '$target_doc_dir/'"
        _cp "$doc_file" "$target_doc_dir/" || { cd "$original_pwd"; return 1; } # Use cp for docs, don't remove from source
    done

    # 7. Share directory (generic catch-all for other shared data)
    # This is more complex as 'share' can contain many things.
    # A simple strategy: if extracted_dir/share exists, move its contents into target_share_dir
    # This might need refinement based on common patterns (e.g., share/icons, share/applications)
    if [[ -d "share" ]]; then
        echo "  -> Processing 'share/' directory..."
        find "share" -mindepth 1 -maxdepth 1 -print0 | while IFS= read -r -d $'\0' share_item; do
            local item_name=$(basename "$share_item")
            # Avoid clobbering existing man, doc, completions dirs if they were also in share/
            if [[ "$item_name" == "man" && -d "$target_man_dir" ]] || \
               [[ "$item_name" == "doc" && -d "$target_doc_dir" ]] || \
               [[ "$item_name" == "bash-completion" && -d "$target_bash_completion_dir" ]] || \
               [[ "$item_name" == "zsh" && -d "$target_zsh_completion_dir" ]] || \
               [[ "$item_name" == "fish" && -d "$target_fish_completion_dir" ]]; then
                echo "    -> Merging contents of 'share/$item_name' into '$target_share_dir/$item_name' (if applicable)"
                # More sophisticated merging might be needed here if collision is a concern.
                # For now, just copy contents over.
                if [[ -d "$share_item" ]]; then
                    _cp_r "$share_item/." "$target_share_dir/$item_name/" || { cd "$original_pwd"; return 1; }
                else # it's a file
                    _cp "$share_item" "$target_share_dir/$item_name" || { cd "$original_pwd"; return 1; }
                fi
            else
                echo "  -> Moving 'share/$item_name' to '$target_share_dir/'"
                _mv "$share_item" "$target_share_dir/" || { cd "$original_pwd"; return 1; }
            fi
        done
        rmdir share 2>/dev/null # Attempt to remove if empty
    fi

    # 8. Remaining files/directories (move to doc as a fallback, or notify user)
    local remaining_items=()
    find . -mindepth 1 -print0 | while IFS= read -r -d $'\0' item; do
        remaining_items+=("$item")
    done

    if [[ ${#remaining_items[@]} -gt 0 ]]; then
        echo "⚠️ $func_name: The following items remain in '$extracted_dir' and were not automatically installed:"
        for item in "${remaining_items[@]}"; do
            echo "  - $item"
        done
        echo "  Consider moving them manually or adding specific handling to $func_name."
        # Optionally, move all remaining to a subdirectory in docs
        # local fallback_doc_dir="$target_doc_dir/unhandled_files"
        # _mkdir_p "$fallback_doc_dir"
        # for item in "${remaining_items[@]}"; do
        #    _mv "$item" "$fallback_doc_dir/"
        # done
        # echo "  They have been moved to '$fallback_doc_dir/' for review."
    fi

    cd "$original_pwd" || { echo "❌ $func_name: Failed to cd back to '$original_pwd'." >&2; return 1; }
    
    # Optional: Remove the (now hopefully empty) extracted_dir
    # if [[ -z "$(ls -A "$extracted_dir")" ]]; then
    # echo "ℹ️ $func_name: Removing empty extracted directory '$extracted_dir'."
    #     _rm_rf "$extracted_dir"
    # else
    #     echo "ℹ️ $func_name: Extracted directory '$extracted_dir' is not empty after installation. Please review its contents."
    # fi


    echo "✅ $func_name: Installation of '$tool_name' to '$install_prefix' completed."
    echo "   Please ensure '$target_bin_dir' is in your PATH."
    echo "   Man pages might require 'mandb' or 'makewhatis' to be run if not updated automatically."
    echo "   For shell completions to work, you might need to restart your shell or source relevant config files."
    return 0
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

# @brief Batch download and install tools using smart_download_tool from a list of example URLs
# @param $1 Array of example GitHub Release download URLs
# @param $2 Optional target installation prefix (e.g., /usr/local, $HOME/.local). Defaults to $HOME/.local.
# @return 0 if all tools processed successfully, 1 otherwise.
# @example batch_smart_download_tools "(url1 url2 url3)" "$HOME/.local"
# @category utils
batch_smart_download_tools() {
    # Due to how Zsh handles array arguments, they are passed as separate arguments.
    # So, $1 is the first URL, $2 is the second, and so on, until the install prefix.
    # We need to reconstruct the URL array and identify the install prefix.
    
    local -a urls_to_process
    local requested_install_prefix="${HOME}/.local" # Default
    local last_arg_index=$#

    if [[ $# -eq 0 ]]; then
        echo "❌ batch_smart_download_tools: No URLs provided." >&2
        return 1
    fi

    # Check if the last argument looks like a path (potential install_prefix)
    # This is a heuristic. A more robust way might be a dedicated option or fixed position.
    if [[ "${(P)last_arg_index}" == "/"* || "${(P)last_arg_index}" == "~"* || "${(P)last_arg_index}" == "$"* ]]; then
        if [[ $# -gt 1 ]]; then # We have at least one URL and a prefix
            requested_install_prefix="${(P)last_arg_index}"
            urls_to_process=("${(@)@[1,last_arg_index-1]}")
        else # Only one argument, and it looks like a path - assume it's a prefix, no URLs
             echo "❌ batch_smart_download_tools: Install prefix provided, but no URLs." >&2
             return 1
        fi
    else # Last argument doesn't look like a path, so all arguments are URLs
        urls_to_process=("${(@)@[1,last_arg_index]}")
        # requested_install_prefix remains $HOME/.local (default)
    fi

    if [[ ${#urls_to_process[@]} -eq 0 ]]; then
        echo "❌ batch_smart_download_tools: No URLs to process after parsing arguments." >&2
        return 1
    fi
    
    echo "ℹ️ batch_smart_download_tools: Processing ${#urls_to_process[@]} URLs. Install prefix: $requested_install_prefix" >&2

    local success_count=0
    local total_count=${#urls_to_process[@]}
    local func_name="batch_smart_download_tools"
    local -a failed_tools_list=() 

    # Check for helper commands and python scripts (paths need to be correct)
    local url_meta_extractor_script="${ZDOTDIR:-$HOME/.config}/zsh/python/url_meta_extractor.py"
    local extract_pattern_script="${ZDOTDIR:-$HOME/.config}/zsh/python/extract_pattern.py"

    if ! command -v smart_download_tool >/dev/null 2>&1 || \
       ! command -v GetLatestReleaseProxy >/dev/null 2>&1 || \
       ! command -v python3 >/dev/null 2>&1; then 
        echo "❌ $func_name: Critical commands (smart_download_tool, GetLatestReleaseProxy, python3) not found." >&2
        return 1
    fi
    if [[ ! -f "$url_meta_extractor_script" ]]; then
        echo "❌ $func_name: URL meta extractor script not found: $url_meta_extractor_script" >&2
        return 1
    fi
    if [[ ! -f "$extract_pattern_script" ]]; then
        echo "❌ $func_name: Asset pattern extractor script not found: $extract_pattern_script" >&2
        return 1
    fi
    # _get_all_known_arch_strings should be available from this file already

    for url in "${urls_to_process[@]}"; do
        echo "" >&2
        echo "($func_name) 🚀 处理 URL: $url" >&2
        
        local meta_json
        meta_json=$(python3 "$url_meta_extractor_script" "$url")
        local python_meta_rc=$?

        if [[ $python_meta_rc -ne 0 || -z "$meta_json" ]]; then
            echo "❌ ($func_name) 从 URL $url 提取元数据失败。" >&2
            failed_tools_list+=("URL (Meta Extraction Error): $url")
            continue
        fi
        
        echo "meta_json: $meta_json" >&2
        local repo="" example_tag="" asset_filename="" tool_name_to_use=""
        
        # 使用 Python 解析 JSON，更可靠
        if command -v python3 >/dev/null 2>&1; then
            # 使用 Python 解析 JSON
            local python_parse_result
            python_parse_result=$(python3 -c "
import json
import sys
try:
    data = json.loads('$meta_json')
    print(f\"repo:{data.get('repo', '')}\")
    print(f\"example_tag:{data.get('example_tag', '')}\")
    print(f\"asset_filename:{data.get('asset_filename', '')}\")
    print(f\"tool_name_guess:{data.get('tool_name_guess', '')}\")
except Exception as e:
    print(f\"ERROR:{e}\", file=sys.stderr)
    sys.exit(1)
" 2>/dev/null)
            local python_rc=$?
            
            if [[ $python_rc -eq 0 && -n "$python_parse_result" ]]; then
                # 解析 Python 输出
                while IFS= read -r line; do
                    case "$line" in
                        repo:*) repo="${line#repo:}" ;;
                        example_tag:*) example_tag="${line#example_tag:}" ;;
                        asset_filename:*) asset_filename="${line#asset_filename:}" ;;
                        tool_name_guess:*) tool_name_to_use="${line#tool_name_guess:}" ;;
                    esac
                done <<< "$python_parse_result"
            else
                # Python解析失败，回退到简单的字符串解析
                echo "⚠️  Python JSON解析失败，使用简单解析方法" >&2
                # 简化的解析方法，去除花括号和引号
                local cleaned_json="${meta_json//[\{\}\"]/}"
                local -a pairs; IFS=',' read -rA pairs <<< "$cleaned_json"
                for pair in "${pairs[@]}"; do
                    # 去除前后空格
                    pair="${pair## }"
                    pair="${pair%% }"
                    if [[ "$pair" == *:* ]]; then
                        local key="${pair%%:*}"
                        local val="${pair#*:}"
                        # 去除前后空格
                        key="${key## }"
                        key="${key%% }"
                        val="${val## }"
                        val="${val%% }"
                        case "$key" in
                            "repo") repo="$val" ;;
                            "example_tag") example_tag="$val" ;;
                            "asset_filename") asset_filename="$val" ;;
                            "tool_name_guess") tool_name_to_use="$val" ;;
                        esac
                    fi
                done
            fi
        else
            echo "❌ Python3 不可用，无法解析 JSON" >&2
            failed_tools_list+=("Python3不可用 (URL: $url)")
            continue
        fi

        if [[ -z "$repo" || "$repo" == "null" || -z "$tool_name_to_use" || "$tool_name_to_use" == "null" || -z "$asset_filename" || "$asset_filename" == "null" ]]; then
            echo "❌ ($func_name) URL $url: 关键元数据不完整/Zsh解析失败。JSON: $meta_json" >&2
            failed_tools_list+=("元数据解析失败 (URL: $url)")
            continue
        fi
        echo "ℹ️  ($func_name) 提取到 -> Tool: '$tool_name_to_use', Repo: '$repo', Tag (Ex): '$example_tag', Asset: '$asset_filename'" >&2

        local version_bare_from_example="${example_tag#v}"; [[ "$version_bare_from_example" == "v" ]] && version_bare_from_example=""
        
        local all_known_archs_str=$(_get_all_known_arch_strings)
        local known_arch_array=(${(ps: :)all_known_archs_str})
        local arch_json_parts=(); local arch_item
        for arch_item in "${known_arch_array[@]}"; do arch_json_parts+=("\"$(echo "$arch_item" | sed 's/"/\\"/g')\""); done
        local known_arch_strings_json="[$(IFS=,; echo "${arch_json_parts[*]}")]"

        local asset_pattern
        asset_pattern=$(python3 "$extract_pattern_script" "$asset_filename" "$known_arch_strings_json" "$version_bare_from_example" 2>/tmp/extract_pattern_py_stderr.log)
        local extract_rc=$?

        if [[ $extract_rc -ne 0 || -z "$asset_pattern" ]]; then
            echo "❌ ($func_name) '$asset_filename' ($tool_name_to_use): 无法提取下载模式。" >&2
            failed_tools_list+=("$tool_name_to_use (模式提取失败: $asset_filename)")
            continue
        fi
        echo "✅ ($func_name) 学习到的资源模式: $asset_pattern" >&2

        local latest_version
        echo "🔄 ($func_name) 正在为 $repo 获取最新 release tag..." >&2
        latest_version=$(GetLatestReleaseProxy "$repo" 2>/dev/null) # Using GetLatestReleaseProxy as per previous context
        
        if [[ -z "$latest_version" ]]; then
            echo "⚠️  ($func_name) $tool_name_to_use ($repo): 获取版本失败。" >&2
            failed_tools_list+=("$tool_name_to_use (版本获取失败)")
            continue
        fi
        echo "✅ ($func_name) 获取到最新版本: $latest_version" >&2
        
        if smart_download_tool "$tool_name_to_use" "$repo" "$latest_version" "$asset_pattern" "$requested_install_prefix" "$example_tag"; then
            echo "✅ ($func_name) $tool_name_to_use 成功处理。" >&2
            ((success_count++))
        else
            echo "❌ ($func_name) $tool_name_to_use 处理失败。" >&2
            failed_tools_list+=("$tool_name_to_use (下载/安装失败)")
        fi
    done
    
    echo "" >&2
    echo "📈 ($func_name) 安装总结: $success_count / $total_count 工具成功处理。" >&2
    if [[ ${#failed_tools_list[@]} -gt 0 ]]; then
        echo "❌ ($func_name) 以下工具未能成功处理：" >&2
        for failed_tool_name in "${failed_tools_list[@]}"; do echo "  - $failed_tool_name" >&2; done
        return 1
    fi
    return 0
}

# find-ssh-item: 给定 Host 别名，输出匹配 stanza 的 "Hostname Port"（每行一个，去重）
# - 同时检查 ~/.ssh/config 与 ~/.ssh/config.d 下的文件（普通文件或符号链接）
# - 支持 Host 的 glob 和 !negation
# - 默认端口为 22（当 stanza 没写 Port 时）
find-ssh-item() {
  emulate -L zsh
  local query=$1
  [[ -n $query ]] || return 2

  local cfg_dir="${HOME}/.ssh/config.d"
  local -a files
  [[ -f "${HOME}/.ssh/config" ]] && files+=("${HOME}/.ssh/config")
  if [[ -d $cfg_dir ]]; then
    for entry in "$cfg_dir"/*; do
      [[ -e $entry ]] || continue
      [[ -f $entry || -L $entry ]] || continue
      files+=("$entry")
    done
  fi

  (( ${#files[@]} )) || return 3

  local -A seen         # 去重键："<hostname> <port>"
  local file line key rest key_l
  local -a host_tokens
  local matched         # 1=匹配, -1=被否定, 0=未判定
  local curr_hostname curr_port

  for file in "${files[@]}"; do
    matched=0
    host_tokens=()
    curr_hostname=""
    curr_port=""
    while IFS= read -r line || [[ -n $line ]]; do
      line=${line%%$'\r'}                           # remove CR
      # trim 两端空白
      line="${line#"${line%%[![:space:]]*}"}"
      line="${line%"${line##*[![:space:]]}"}"
      [[ -z $line ]] && continue
      [[ ${line} == \#* ]] && continue
      # 简单去行内注释（常见场景）
      [[ $line == *'#'* ]] && line="${line%%\#*}" && line="${line%"${line##*[![:space:]]}"}" && [[ -z $line ]] && continue

      key=${line%%[[:space:]]*}
      rest=${line#${key}}
      rest="${rest#"${rest%%[![:space:]]*}"}"
      rest="${rest%"${rest##*[![:space:]]}"}"
      key_l=${(L)key}

      if [[ $key_l == host ]]; then
        # 若上一个 stanza 已匹配且有 hostname，则记录
        if [[ $matched -eq 1 && -n $curr_hostname ]]; then
          local port_out=${curr_port:-22}
          seen["$curr_hostname $port_out"]=1
        fi
        # 新的 Host stanza，重置状态
        host_tokens=()
        matched=0
        curr_hostname=""
        curr_port=""
        for tok in ${(z)rest}; do
          tok=${tok#\"}; tok=${tok%\"}
          tok=${tok#\'}; tok=${tok%\'}
          host_tokens+=("$tok")
        done
        # 立刻判定是否匹配 query（支持 glob 与 !negation）
        for tok in "${host_tokens[@]}"; do
          if [[ $tok == '!'* ]]; then
            local neg=${tok#'!'}
            if [[ $query == $neg ]]; then
              matched=-1
              break
            else
              continue
            fi
          fi
          if [[ $query == $tok ]]; then
            matched=1
            # 不 break：允许后续 token 继续检验是否存在否定等情况
          fi
        done
        continue
      fi

      # 若当前 stanza 已判定为匹配，则收集 HostName / Port
      if [[ $matched -eq 1 ]]; then
        if [[ $key_l == hostname ]]; then
          curr_hostname=${rest#\"}; curr_hostname=${curr_hostname%\"}
          curr_hostname=${curr_hostname#\'}; curr_hostname=${curr_hostname%\'}
          curr_hostname="${curr_hostname#"${curr_hostname%%[![:space:]]*}"}"
          curr_hostname="${curr_hostname%"${curr_hostname##*[![:space:]]}"}"
        elif [[ $key_l == port ]]; then
          curr_port=${rest#\"}; curr_port=${curr_port%\"}
          curr_port=${curr_port#\'}; curr_port=${curr_port%\'}
          curr_port="${curr_port#"${curr_port%%[![:space:]]*}"}"
          curr_port="${curr_port%"${curr_port##*[![:space:]]}"}"
        fi
      fi
    done < "$file"

    # 文件结束后收尾一次
    if [[ $matched -eq 1 && -n $curr_hostname ]]; then
      local port_out=${curr_port:-22}
      seen["$curr_hostname $port_out"]=1
    fi
  done

  # 输出结果（如果没有匹配，则不输出，返回码为 1）
  if (( ${#seen[@]} )); then
    for k in ${(k)seen}; do
    #   printf '%s\n' "$k"
    # remove leading and trailing "
        local clean=${k#\"}      # 去掉开头的 "
        clean=${clean%\"}  # 去掉结尾的 "
        echo "$clean"
    done
    return 0
  else
    return 1
  fi
}

find-ssh-host(){
    find-ssh-item $1 | cut -d ' ' -f 1
}

find-ssh-ip(){
    local host
    host=$(find-ssh-host $1)
    # if host is ip, return it
    [[ $host =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && echo $host && return
    nslookup $host | awk '/^Address: / {print $2}' | head -n 1
}

find-ssh-port(){
    find-ssh-item $1 | cut -d ' ' -f 2
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
