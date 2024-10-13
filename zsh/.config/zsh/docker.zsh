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



install_docker_apt(){
    sudo apt-get update
    if !command -v docker &>/dev/null; then
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    else
        green "docker is already installed"
        sudo apt-get upgrade -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi
}

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
