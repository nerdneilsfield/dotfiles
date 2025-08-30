# @brief Install CSS language server for IDE support
# @return 0 on success
# @example install_css_lsp
# @category html
install_css_lsp() {
        npm i -g vscode-css-languageservice
}

# @brief Install HTML language server for IDE support
# @return 0 on success
# @example install_html_lsp
# @category html
install_html_lsp() {
        npm i -g vscode-html-languageservice
}

# @brief Install TypeScript/JavaScript language server
# @return 0 on success
# @example install_javascript_lsp
# @category html
install_javascript_lsp() {
        npm i -g typescript-language-server typescript
}

# @brief Install JSON language server for IDE support
# @return 0 on success
# @example install_json_lsp
# @category html
install_json_lsp() {
        npm i -g vscode-json-languageserver
}

# @brief Install ESLint language server for linting
# @return 0 on success
# @example install_eslint_lsp
# @category html
install_eslint_lsp(){
        npm i -g vscode-langservers-extracted
}

# @brief Install Prettier code formatter
# @return 0 on success
# @example install_prettier
# @category html
install_prettier(){
        npm i -g prettier
}

# @brief Install Volar language server for Vue.js
# @return 0 on success
# @example install_volar_lsp
# @category html
install_volar_lsp() {
  npm i -g @volar/server
}

# @brief Install pnpm package manager
# @return 0 on success
# @example install_pnpm
# @category html
install_pnpm(){
        pnpm i -g pnpm
}

# @brief Install JavaScript beautifier/formatter
# @return 0 on success
# @example install_js_beautify
# @category html
install_js_beautify() {
        pnpm i -g js-beautify
}

# @brief Install complete HTML/CSS/JS development toolchain
# @return 0 on success
# @example install_html_tools
# @category html
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

# bun
# bun completions
[ -s "${HOME}/.bun/_bun" ] && source "/home/dengqi/.bun/_bun"

# bun
if [ -d "${HOME}/.bun" ]; then
	export BUN_INSTALL="$HOME/.bun"
	export PATH="$BUN_INSTALL/bin:$PATH"
fi
