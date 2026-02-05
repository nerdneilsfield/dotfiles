function show-help() {
    if command -v glow &>/dev/null; then
        local file="$1"
        local help_dir="${ZSH_CONF_DIR}/help"

        if [[ -n "$file" ]]; then
            if [[ -f "${help_dir}/${file}.md" ]]; then
                glow "${help_dir}/${file}.md"
                return 0
            fi
            if [[ -f "${help_dir}/tools/${file}.md" ]]; then
                glow "${help_dir}/tools/${file}.md"
                return 0
            fi
            if [[ -f "${help_dir}/commands/${file}.md" ]]; then
                glow "${help_dir}/commands/${file}.md"
                return 0
            fi
        fi

        file=$(find "$help_dir" -name '*.md' -type f | sed "s|^${help_dir}/||;s|\\.md$||" | fzf --prompt="Select help file: " --preview="glow \"${help_dir}\"/{}.md")
        if [[ -n "$file" ]]; then
            glow "${help_dir}/${file}.md"
        fi
    else
        yellow_echo "glow is not installed. Installing glow."
        cins glow
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
