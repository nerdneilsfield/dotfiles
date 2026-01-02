function show-help() {
    if command -v glow &>/dev/null; then
        local file
        file=$(find "${ZSH_CONF_DIR}/help" -name '*.md' -type f | sed 's|.*/||;s|\.md$||' | fzf --prompt="Select help file: " --preview='glow "${ZSH_CONF_DIR}"/help/{}.md')
        if [[ -n "$file" ]]; then
            glow "${ZSH_CONF_DIR}/help/${file}.md"
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
