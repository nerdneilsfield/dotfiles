install_wasmtime_proxy() {
    green_echo "======================================"
    green_echo "=========Install wasmtime Proxy========"
    green_echo "======================================"
    local _WASMTIME_VERSION=$(GetLatestReleaseProxy "bytecodealliance/wasmtime")
    local _arch=$(uname -m)
    #   if [[ $_arch == "x86_64" ]]; then
    #     _arch="amd64"
    #   fi
    local _wasmtime_url="https://ghproxy.dengqi.org/https://github.com/bytecodealliance/wasmtime/releases/download/v${_WASMTIME_VERSION}/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux.tar.xz"
    local _wasmtime_c_api_url="https://ghproxy.dengqi.org/https://github.com/bytecodealliance/wasmtime/releases/download/v${_WASMTIME_VERSION}/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux-c-api.tar.xz"
    mkdir -p /tmp/install
    cd /tmp/install
    wget -O wasmtime.tar.xz $_wasmtime_url
    wget -O wasmtime-c-api.tar.xz $_wasmtime_c_api_url
    tar -xvf wasmtime.tar.xz
    tar -xvf wasmtime-c-api.tar.xz
    rm -rf "${HOME}/.local/share/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux" "${HOME}/.local/share/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux-c-api"
    mv "wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux" $HOME/.local/share/
    mv "wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux-c-api" $HOME/.local/share/
    rm -rf "${HOME}/.local/bin/wasmtime" "${HOME}/.local/bin/wasmtime-min"
    ln -sf "${HOME}/.local/share/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux/wasmtime" "${HOME}/.local/bin/"
    ln -sf "${HOME}/.local/share/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux/wasmtime-min" "${HOME}/.local/bin/"
    ln -sf "${HOME}/.local/share/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux-c-api/lib/*" "${HOME}/.local/lib/*"
    ln -sf "${HOME}/.local/share/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux-c-api/include/*" "${HOME}/.local/include/*"
}

install_wasmtime() {
    green_echo "======================================"
    green_echo "=========Install wasmtime========"
    green_echo "======================================"
    local _WASM_VERSION=$(GetLatestRelease "bytecodealliance/wasmtime")
    local _arch=$(uname -m)
    #   if [[ $_arch == "x86_64" ]]; then
    #     _arch="amd64"
    #   fi
    local _wasmtime_url="https://github.com/bytecodealliance/wasmtime/releases/download/v${_WASMTIME_VERSION}/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux.tar.xz"
    local _wasmtime_c_api_url="https://github.com/bytecodealliance/wasmtime/releases/download/v${_WASMTIME_VERSION}/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux-c-api.tar.xz"
    mkdir -p /tmp/install
    cd /tmp/install
    wget -O wasmtime.tar.xz $_wasmtime_url
    wget -O wasmtime-c-api.tar.xz $_wasmtime_c_api_url
    tar -xvf wasmtime.tar.xz
    tar -xvf wasmtime-c-api.tar.xz
    rm -rf "${HOME}/.local/share/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux" "${HOME}/.local/share/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux-c-api"
    mv "wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux" $HOME/.local/share/
    mv "wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux-c-api" $HOME/.local/share/
    rm -rf "${HOME}/.local/bin/wasmtime" "${HOME}/.local/bin/wasmtime-min"
    ln -sf "${HOME}/.local/share/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux/wasmtime" "${HOME}/.local/bin/"
    ln -sf "${HOME}/.local/share/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux/wasmtime-min" "${HOME}/.local/bin/"
    ln -sf "${HOME}/.local/share/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux-c-api/lib/*" "${HOME}/.local/lib/*"
    ln -sf "${HOME}/.local/share/wasmtime-v${_WASMTIME_VERSION}-${_arch}-linux-c-api/include/*" "${HOME}/.local/include/*"
}
