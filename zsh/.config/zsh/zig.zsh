install_zls() {
        git clone --recurse-submodules --depth 1 https://github.com/zigtools/zls $HOME/Source/app/zls
        cd $HOME/Source/app/zls
        zig build -Drelease-safe
        cp -r ./zig-out/bin/zls $HOME/.local/bin
        $HOME/.local/bin/zls --config
}

install_zigmod() {
        git clone --recurse-submodules --depth 1 https://github.com/zigtools/zigmod $HOME/Source/app/zigmod
        cd $HOME/Source/app/zigmod
        zig build -Drelease-safe
        cp -r ./zig-out/bin/zigmod $HOME/.local/bin
}