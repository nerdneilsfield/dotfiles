function show-help() {
    if command -v mdcat &> /dev/null; then
        local file
        file=$(find "${ZSH_CONF_DIR}/help" -name '*.md' -type f | sed 's|.*/||;s|\.md$||' | fzf --prompt="Select help file: ")
        if [[ -n "$file" ]]; then
            mdcat "${ZSH_CONF_DIR}/help/${file}.md"
        fi
    else
        yellow_echo "mdcat is not installed. Installing mdcat."
        cins mdcat
    fi
}

function create-help(){
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
