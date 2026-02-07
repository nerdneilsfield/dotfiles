function show-help() {
    local file="$1"
    local help_dir="${ZSH_CONF_DIR}/help"
    local install_alias_note=0
    if [[ "$file" == "install" ]]; then
        file="installer"
        install_alias_note=1
    fi

    if [[ -n "$file" ]]; then
        if [[ -f "${help_dir}/${file}.md" ]]; then
            if [[ "$install_alias_note" -eq 1 ]]; then
                echo "note: \`install\` is mapped to \`installer\`."
                echo
            fi
            if command -v glow &>/dev/null; then
                glow "${help_dir}/${file}.md"
            else
                cat "${help_dir}/${file}.md"
            fi
            return 0
        fi
        if [[ -f "${help_dir}/tools/${file}.md" ]]; then
            if command -v glow &>/dev/null; then
                glow "${help_dir}/tools/${file}.md"
            else
                cat "${help_dir}/tools/${file}.md"
            fi
            return 0
        fi
        if [[ -f "${help_dir}/commands/${file}.md" ]]; then
            if command -v glow &>/dev/null; then
                glow "${help_dir}/commands/${file}.md"
            else
                cat "${help_dir}/commands/${file}.md"
            fi
            return 0
        fi
    fi

    if command -v glow &>/dev/null; then
        file=$(find "$help_dir" -name '*.md' -type f | sed "s|^${help_dir}/||;s|\\.md$||" | fzf --prompt="Select help file: " --preview="glow \"${help_dir}\"/{}.md")
        if [[ -n "$file" ]]; then
            glow "${help_dir}/${file}.md"
        fi
    else
        if [[ -n "$file" ]]; then
            echo "help topic not found: $file" >&2
            echo "tip: run \`show-help\` to list available docs" >&2
            return 1
        fi
        echo "glow is not installed, falling back to plain text list:" >&2
        find "$help_dir" -name '*.md' -type f | sed "s|^${help_dir}/||;s|\\.md$||" | sort
    fi
}

function create-help() {
    if [ -z "$1" ]; then
        red_echo "Please provide a help file name."
        return 1
    fi
    touch "${ZSH_CONF_DIR}/help/${1}.md"
    nv "${ZSH_CONF_DIR}/help/${1}.md"
}

function edit-help() {
    local file
    file=$(find "${ZSH_CONF_DIR}/help" -name '*.md' -type f | sed 's|.*/||;s|\.md$||' | fzf --prompt="Select help file: ")
    if [[ -n "$file" ]]; then
        nv "${ZSH_CONF_DIR}/help/${file}.md"
    fi
}
