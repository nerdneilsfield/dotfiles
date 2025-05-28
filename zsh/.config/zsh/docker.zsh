# @brief Install Docker GPG key for package verification
# @return 0 on success
# @example install_docker_gpg_key
# @category docker
install_docker_gpg_key(){
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    if check_is_ubuntu; then
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    elif check_is_debian; then
        sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    fi
    sudo chmod a+r /etc/apt/keyrings/docker.asc
}

# @brief Add official Docker APT repository
# @return 0 on success
# @example install_docker_apt_source
# @category docker
install_docker_apt_source() {
    install_docker_gpg_key
    if check_is_ubuntu; then
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    elif check_is_debian; then
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi
    sudo apt-get update
}

# @brief Add Docker APT repository using Tsinghua mirror
# @return 0 on success
# @example install_docker_apt_source_tuna
# @category docker
install_docker_apt_source_tuna() {
    install_docker_gpg_key
    if check_is_ubuntu; then
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    elif check_is_debian; then
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi
    sudo apt-get update
}



# @brief Install Docker intelligently using best package manager
# @return 0 on success
# @example install_docker_smart
# @category docker
install_docker_smart(){
    echo "🐳 智能安装 Docker..."
    
    # 使用智能安装系统
    if command -v install_smart_tool >/dev/null 2>&1; then
        install_smart_tool docker
    else
        # 回退到传统方法
        echo "⚠️  智能安装系统未加载，使用传统方法..."
        local pm=$(get_package_manager 2>/dev/null || echo "unknown")
        
        case "$pm" in
            "brew")
                echo "📦 通过 Homebrew 安装 Docker Desktop..."
                brew install --cask docker
                ;;
            "pacman")
                echo "📦 通过 Pacman 安装 Docker..."
                sudo pacman -S docker docker-compose docker-buildx
                sudo systemctl enable --now docker.service
                echo "💡 建议将用户添加到 docker 组: sudo usermod -aG docker \$USER"
                ;;
            *)
                # Ubuntu/Debian 等系统使用传统方法
                install_docker_apt
                ;;
        esac
    fi
}

# @brief Install Docker via APT package manager
# @return 0 on success
# @example install_docker_apt
# @category docker
install_docker_apt(){
    sudo apt-get update
    if !command -v docker &>/dev/null; then
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    else
        green "docker is already installed"
        sudo apt-get upgrade -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi
}

# @brief Install Docker and container language servers for IDE support
# @return 0 on success, 1 if node/npm missing
# @example install_docker_lsp
# @category docker
install_docker_lsp(){
    if !command -v node &>/dev/null; then
        red "node is not installed"
        return 1
    fi

    if !command -v npm &>/dev/null; then
        red "npm is not installed"
        return 1
    fi

    npm install -g @microsoft/compose-language-service yaml-language-server dockerfile-language-server-nodejs
}
