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

install_eslint_lsp(){
        npm i -g vscode-langservers-extracted
}

install_prettier(){
        npm i -g prettier
}

install_volar_lsp() {
  npm i -g @volar/server
}

install_pnpm(){
        pnpm i -g pnpm
}

install_js_beautify() {
        pnpm i -g js-beautify
}

install_html_tools() {
        install_css_lsp
        install_html_lsp
        install_javascript_lsp
        install_json_lsp
        install_prettier
        install_eslint_lsp
        install_volar_lsp
        install_pnpm
}

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
