# @brief Install Zig Language Server (ZLS) from source
# @return 0 on success
# @example install_zls
# @category zig
install_zls() {
        # if directory zls not exists
        if [[ ! -d "$HOME/Source/app/zls" ]]; then
                git clone --recursive --depth 1 https://github.com/zigtools/zls $HOME/Source/app/zls
                cd $HOME/Source/app/zls
        else
                cd $HOME/Source/app/zls
                git pull
        fi
        zig build -Drelease-safe
        cp -r ./zig-out/bin/zls $HOME/.local/bin
        $HOME/.local/bin/zls --config
}

# @brief Install zigmod package manager for Zig
# @return 0 on success
# @example install_zigmod
# @category zig
install_zigmod() {
        if [[ ! -d "$HOME/Source/app/zigmod" ]]; then
                git clone --recursive --depth 1 https://github.com/nektro/zigmod $HOME/Source/app/zigmod
                cd $HOME/Source/app/zigmod
        else
                cd $HOME/Source/app/zigmod
                git pull
        fi
        zig build 
        cp -r ./zig-out/bin/zigmod $HOME/.local/bin
}

# @brief Install zigup Zig version manager
# @return 0 on success
# @example install_zigup
# @category zig
install_zigup() {
        ZIG_VER=$(GetLatestReleaseProxy "marler8997/zigup")
        mkdir -p $HOME/Source/app/zigup
        wget -O "$HOME/Source/app/zigup/zigup_${ZIG_VER}.tar.gz" "https://github.com/marler8997/zigup/releases/download/v${ZIG_VER}/zigup-x86_64-linux.tar.gz"
        cd $HOME/Source/app/zigup
        tar -xvf zigup_${ZIG_VER}.tar.gz
        rm -rf $HOME/.local/bin/zigup
        mv zigup $HOME/.local/bin/zigup
        chmod +x $HOME/.local/bin/zigup
        $HOME/.local/bin/zigup --help
}

# @brief Install zigup using GitHub proxy for faster downloads
# @return 0 on success
# @example install_zigup_proxy
# @category zig
install_zigup_proxy() {
        ZIG_VER=$(GetLatestReleaseProxy "marler8997/zigup")
        mkdir -p $HOME/Source/app/zigup
        wget -O "$HOME/Source/app/zigup/zigup_${ZIG_VER}.tar.gz" "https://ghproxy.dengqi.org/https://github.com/marler8997/zigup/releases/download/v${ZIG_VER}/zigup-x86_64-linux.tar.gz"
        cd $HOME/Source/app/zigup
        tar -xvf zigup_${ZIG_VER}.tar.gz
        rm -rf $HOME/.local/bin/zigup
        mv zigup $HOME/.local/bin/zigup
        chmod +x $HOME/.local/bin/zigup
        $HOME/.local/bin/zigup --help
}

# @brief Install latest Zig compiler using zigup
# @return 0 on success
# @example install_zig
# @category zig
install_zig() {
        # check if zigup exists
        if [[ ! -f "$HOME/.local/bin/zigup" ]]; then
                install_zigup
        fi

        # install zig
        $HOME/.local/bin/zigup master --install-dir $HOME/.cache/zig
}
