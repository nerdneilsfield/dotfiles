# ZSH 安全工具库

# 输入验证函数
validate_url() {
    local url="$1"
    
    # 检查URL是否为空
    if [[ -z "$url" ]]; then
        echo "Error: URL cannot be empty" >&2
        return 1
    fi
    
    # 检查URL格式 - 只允许HTTPS
    if [[ ! "$url" =~ ^https://[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9](/.*)?$ ]]; then
        echo "Error: Invalid HTTPS URL format" >&2
        return 1
    fi
    
    # 检查是否包含危险字符
    if [[ "$url" =~ [\;\|\&\$\`\(\)\{\}] ]]; then
        echo "Error: URL contains dangerous characters" >&2
        return 1
    fi
    
    return 0
}

validate_proxy() {
    local proxy="$1"
    
    if [[ -z "$proxy" ]]; then
        echo "Error: Proxy cannot be empty" >&2
        return 1
    fi
    
    # 验证代理格式: protocol://[user:pass@]host:port
    if [[ ! "$proxy" =~ ^(http|https|socks5)://([a-zA-Z0-9_-]+:[a-zA-Z0-9_-]+@)?[a-zA-Z0-9][a-zA-Z0-9.-]*:[0-9]+/?$ ]]; then
        echo "Error: Invalid proxy format" >&2
        return 1
    fi
    
    return 0
}

validate_domain() {
    local domain="$1"
    
    if [[ -z "$domain" ]]; then
        echo "Error: Domain cannot be empty" >&2
        return 1
    fi
    
    # 验证域名格式
    if [[ ! "$domain" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$ ]]; then
        echo "Error: Invalid domain format" >&2
        return 1
    fi
    
    # 检查域名长度
    if [[ ${#domain} -gt 253 ]]; then
        echo "Error: Domain name too long" >&2
        return 1
    fi
    
    return 0
}

validate_path() {
    local path="$1"
    
    if [[ -z "$path" ]]; then
        echo "Error: Path cannot be empty" >&2
        return 1
    fi
    
    # 检查路径遍历攻击
    if [[ "$path" =~ \.\. ]]; then
        echo "Error: Path traversal detected" >&2
        return 1
    fi
    
    # 检查危险字符
    if [[ "$path" =~ [\;\|\&\$\`\(\)\{\}] ]]; then
        echo "Error: Path contains dangerous characters" >&2
        return 1
    fi
    
    return 0
}

# 安全的命令执行
safe_curl() {
    local url="$1"
    shift
    local extra_args=("$@")
    
    # 验证URL
    if ! validate_url "$url"; then
        return 1
    fi
    
    # 执行安全的curl请求
    curl \
        --silent \
        --fail \
        --location \
        --proto '=https' \
        --tlsv1.2 \
        --connect-timeout 10 \
        --max-time 30 \
        --user-agent "zsh-config/1.0 (security-enhanced)" \
        --max-redirs 3 \
        "${extra_args[@]}" \
        "$url"
}

safe_wget() {
    local url="$1"
    shift
    local extra_args=("$@")
    
    # 验证URL
    if ! validate_url "$url"; then
        return 1
    fi
    
    # 执行安全的wget请求
    wget \
        --quiet \
        --timeout=30 \
        --tries=2 \
        --user-agent="zsh-config/1.0 (security-enhanced)" \
        --secure-protocol=TLSv1_2 \
        --https-only \
        "${extra_args[@]}" \
        "$url"
}

# 安全的文件操作
safe_rm() {
    local target="$1"
    
    # 验证路径
    if ! validate_path "$target"; then
        return 1
    fi
    
    # 防止删除重要系统目录
    case "$target" in
        /|/bin|/usr|/etc|/var|/home|/root|/sys|/proc|/dev)
            echo "Error: Cannot remove system directory: $target" >&2
            return 1
            ;;
        *)
            # 确保路径在用户目录下或临时目录
            if [[ "$target" =~ ^($HOME|/tmp|/var/tmp) ]]; then
                rm -rf "$target"
            else
                echo "Error: Path outside allowed directories: $target" >&2
                return 1
            fi
            ;;
    esac
}

# 环境变量安全检查
check_env_security() {
    echo "🔒 检查环境变量安全性..."
    
    local issues=0
    
    # 检查是否有敏感信息泄露
    local sensitive_vars=("PASSWORD" "SECRET" "TOKEN" "KEY" "API_KEY")
    
    for var in "${sensitive_vars[@]}"; do
        if printenv | grep -i "$var" >/dev/null 2>&1; then
            echo "⚠️  Warning: Found potential sensitive variable containing '$var'" >&2
            ((issues++))
        fi
    done
    
    # 检查PATH安全性
    if [[ ":$PATH:" == *":.:"* ]]; then
        echo "⚠️  Warning: Current directory (.) in PATH - security risk" >&2
        ((issues++))
    fi
    
    # 检查权限
    if [[ -w "/" ]]; then
        echo "🚨 Critical: Root filesystem is writable!" >&2
        ((issues++))
    fi
    
    if [[ $issues -eq 0 ]]; then
        echo "✅ Environment security check passed"
    else
        echo "🚨 Found $issues security issues"
    fi
    
    return $issues
}

# 文件权限检查
check_file_permissions() {
    local config_dir="${ZSH_CONF_DIR:-$HOME/.config/zsh}"
    
    echo "🔒 检查配置文件权限..."
    
    local issues=0
    
    # 检查配置目录权限
    if [[ -d "$config_dir" ]]; then
        local dir_perms=$(stat -f %Mp%Lp "$config_dir" 2>/dev/null || stat -c %a "$config_dir" 2>/dev/null)
        
        if [[ "$dir_perms" -gt 755 ]]; then
            echo "⚠️  Warning: $config_dir has overly permissive permissions: $dir_perms" >&2
            ((issues++))
        fi
        
        # 检查配置文件权限
        for file in "$config_dir"/*.zsh; do
            if [[ -f "$file" ]]; then
                local file_perms=$(stat -f %Mp%Lp "$file" 2>/dev/null || stat -c %a "$file" 2>/dev/null)
                
                if [[ "$file_perms" -gt 644 ]]; then
                    echo "⚠️  Warning: $file has overly permissive permissions: $file_perms" >&2
                    ((issues++))
                fi
            fi
        done
    fi
    
    if [[ $issues -eq 0 ]]; then
        echo "✅ File permissions check passed"
    else
        echo "🚨 Found $issues permission issues"
        echo "💡 Run: chmod 755 $config_dir && chmod 644 $config_dir/*.zsh"
    fi
    
    return $issues
}

# 网络安全检查
check_network_security() {
    echo "🔒 检查网络安全配置..."
    
    local issues=0
    
    # 检查代理配置
    if [[ -n "$http_proxy" || -n "$https_proxy" ]]; then
        echo "ℹ️  Proxy configured: ${https_proxy:-$http_proxy}"
        
        # 检查代理是否使用HTTP（不安全）
        if [[ "$https_proxy" =~ ^http:// || "$http_proxy" =~ ^http:// ]]; then
            echo "⚠️  Warning: Using HTTP proxy (unencrypted)" >&2
            ((issues++))
        fi
    fi
    
    # 检查DNS设置
    if [[ -n "$DNS_SERVER" ]]; then
        echo "ℹ️  Custom DNS server: $DNS_SERVER"
    fi
    
    if [[ $issues -eq 0 ]]; then
        echo "✅ Network security check passed"
    else
        echo "🚨 Found $issues network security issues"
    fi
    
    return $issues
}

# 综合安全检查
security_audit() {
    echo "🛡️  开始 ZSH 配置安全审计..."
    echo "================================================"
    
    local total_issues=0
    
    check_env_security
    ((total_issues += $?))
    
    echo
    check_file_permissions
    ((total_issues += $?))
    
    echo
    check_network_security
    ((total_issues += $?))
    
    echo
    echo "================================================"
    if [[ $total_issues -eq 0 ]]; then
        echo "🎉 安全审计通过！未发现安全问题。"
    else
        echo "🚨 发现 $total_issues 个安全问题，请及时修复。"
    fi
    
    return $total_issues
}

# 修复文件权限
fix_permissions() {
    local config_dir="${ZSH_CONF_DIR:-$HOME/.config/zsh}"
    
    echo "🔧 修复配置文件权限..."
    
    if [[ -d "$config_dir" ]]; then
        chmod 755 "$config_dir"
        chmod 644 "$config_dir"/*.zsh 2>/dev/null
        echo "✅ 权限修复完成"
    else
        echo "❌ 配置目录不存在: $config_dir"
        return 1
    fi
}

# 别名
alias sec-audit="security_audit"
alias sec-check="check_env_security"
alias sec-fix="fix_permissions"