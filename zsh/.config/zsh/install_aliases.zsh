# Compatibility aliases for renamed installer functions

install_nosoource_ppa() {
    echo "[DEPRECATED] use install_nodesource_ppa"
    install_nodesource_ppa "$@"
}

add_nosource_ppa() {
    echo "[DEPRECATED] use add_nodesource_ppa"
    add_nodesource_ppa "$@"
}

install_ubuntu_netwrok_packages() {
    echo "[DEPRECATED] use install_ubuntu_network_packages"
    install_ubuntu_network_packages "$@"
}
