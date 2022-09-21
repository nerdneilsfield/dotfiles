
install_shfmt() {
        # shfmt
        go install mvdan.cc/sh/v3/cmd/shfmt@latest
}

install_bash_lsp() {
        npm i -g bash-language-server
}

install_shell_check(){
        pki shellcheck
}

install_shell_tools() {
        install_shfmt
        install_bash_lsp
        install_shell_check
}

