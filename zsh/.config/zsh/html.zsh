install_css_lsp() {
        npm i -g vscode-css-languageservice
}

install_html_lsp() {
        npm i -g vscode-html-languageservice
}

install_javascript_lsp() {
        npm i -g typescript-language-server typescript
}

install_json_lsp() {
        npm i -g vscode-json-languageserver
}

install_prettier(){
        npm i -g prettier
}

install_html_tools() {
        install_css_lsp
        install_html_lsp
        install_javascript_lsp
        install_json_lsp
        install_prettier
}