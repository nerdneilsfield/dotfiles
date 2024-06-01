# web server
alias httpserver="python3 -m http.server "

# download tool
alias pgit="proxychains4 git"
alias phub="proxychains4 hub"
alias pget="proxychains4 wget"
alias ar2cx="aria2c -x 16 -c"
alias ar2cxp="aria2c -x 16 -c --all-proxy ${https_proxy}"

# alias emacsw="emacs -nw"
alias lsa='/bin/ls -lah'
alias matlabnw='/usr/local/bin/matlab -nodesktop -nosplash'
alias ls="/bin/ls"

# matlab
alias matrun=matlabnw

# format
alias yamlcheck="python -c 'import yaml, sys; print(yaml.safe_load(sys.stdin))'"
alias prettyjson='python -m json.tool'

#editor
# alias e="emacs -nw "
# alias ec="emacsclient"

alias startapollo="bash docker/scripts/dev_start.sh && bash docker/scripts/dev_into.sh"

# ci
alias trigger='git amend && git push -f'

# dir
#alias .='cd .'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

if hash eza 2>/dev/null; then
    alias ls='eza'
    alias l='eza -l --all --group-directories-first --git'
    alias ll='eza -l --all --all --group-directories-first --git'
    alias lt='eza -T --git-ignore --level=2 --group-directories-first'
    alias llt='eza -lT --git-ignore --level=2 --group-directories-first'
    alias lT='eza -T --git-ignore --level=4 --group-directories-first'
elif hash exa 2>/dev/null; then
    alias ls='exa'
    alias l='exa -l --all --group-directories-first --git'
    alias ll='exa -l --all --all --group-directories-first --git'
    alias lt='exa -T --git-ignore --level=2 --group-directories-first'
    alias llt='exa -lT --git-ignore --level=2 --group-directories-first'
    alias lT='exa -T --git-ignore --level=4 --group-directories-first'
else
    alias l='ls -lah'
    alias ll='ls -alF'
    alias la='ls -A'
fi

alias mkdirp='mkdir -p'
alias to='j'
alias jf='j -I'
alias jb='j -b'

# docker
alias d='docker'
alias dc='docker compose'
alias dcup='docker compose up -d --remove-orphans'
alias dcdown='docker compose down'
alias dcr='docker compose restart'
alias dce='docker compose exec'
alias da='docker exec -it'

# git
alias gd='git dif'
alias ga='git add .'
alias gc='git commit -m'
alias g='lazygit'
# alias gl='pc invoke'
# alias glp='pc invoke -p'
# alias glm='pc invoke -m'
# alias glb='pc invoke -b'
alias lgit="lazygit"
alias gitcrd="git clone --recursive --depth 1 "

#jabba
# alias jb='jabba'

# script
# alias z='zerotier-cli'
# alias y='yarn'

# tmux
alias tmux='tmux'
alias t='tmux'
alias ta='tmux attach-session -t'
alias tn='tmux new -s'
alias tka='tmux kill-session -a'
alias tk='tmux kill-session -t'

# function startVim() {
# 	if ! [ -x "$(command -v npm)" ]; then
# 	  echo 'Error: nvm is not invoked.' >&2
# 	  nvm >> /dev/null
# 	fi
# 	nvim $@
# }

# vim
# alias vi='nvim'
# alias v='nvim'

# others
alias now='date +%s'
alias dateunix='date +%s'
alias sz="source $HOME/.zshrc"
alias j='z'
# alias rg='rg --column --line-number --hidden --sort path --no-heading --color=always --smart-case -- '

# macos only
alias refresh-dns='sudo killall -HUP mDNSResponder'

alias setpx="setproxy"
alias unsetpx="unsetproxy"

# trans
alias trans_zh="trans -to \"zh-CN\" -text"
alias trans_en="trans -to \"en\" -text"
alias trans_ja="trans -to \"ja\" -text"

function git_proxy() {
    # 替换 URL
    local args=("$@")
    for i in "${!args[@]}"; do
        args[$i]="${args[$i]//https:\/\/github.com/https:\/\/ghproxy.dengqi.org\/https:\/\/github.com}"
    done
    # 执行 git 命令
    command git "${args[@]}"
}

# 别名替换 git 命令
alias git-gh='git_proxy'

function wget-gh() {
    # 替换 URL
    local args=("$@")
    for i in "${!args[@]}"; do
        args[$i]="${args[$i]//https:\/\/github.com/https:\/\/ghproxy.dengqi.org\/https:\/\/github.com}"
    done
    # 执行 wget 命令
    command wget "${args[@]}"
}

