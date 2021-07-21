# fix the nvm cost too much time for int

nvm() {
    if [ -d "$HOME/.config/nvm" ]; then
        export NVM_DIR="$HOME/.config/nvm"
        \. "$NVM_DIR/nvm.sh"
        nvm $@
    fi
}

if [ -d "$HOME/.config/nvm" ]; then
    export NVM_DIR="$HOME/.config/nvm"
    # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
    default_version=$(cat "$NVM_DIR/alias/default")
    export PATH="$NVM_DIR/versions/$default_version/bin:$PATH"
fi

# nvm use default
