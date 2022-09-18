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

install_fnm() {
    if command -v lsb_release>>/dev/null; then
      CODENAME=$(lsb_release -c | awk '{print $2}')
      echo $CODENAME
      if [[ $CODENAME=="bionic" ]];then 
        cargo install --force fnm
      fi
    else 
      cargo quickinstall fnm
    fi
    fnm install --lts
    # mkdir -p $HOME/.config/zsh_generated
    # fnm env > $HOME/.config/zsh_generated/fnm.sh
    mkdir -p ~/.zsh_func
    fnm completions --shell zsh  > ~/.zsh_func/fnm_completions.zsh
}

if [ -f $HOME/.cargo/bin/fnm ]; then
    #  source $HOME/.config/zsh_generated/fnm.sh
    eval "$(fnm env --use-on-cd)"
 fi
