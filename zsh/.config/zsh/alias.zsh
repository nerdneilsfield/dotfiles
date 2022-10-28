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
alias e="emacs -nw "
alias ec="emacsclient"

alias startapollo="bash docker/scripts/dev_start.sh && bash docker/scripts/dev_into.sh"

# ci
alias trigger='git amend && git push -f'

# dir
#alias .='cd .'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ll='ls -al'
alias mkdirp='mkdir -p'
alias to='j'
alias jf='j -I'
alias jb='j -b'

# docker
alias d='docker'
alias dc='docker compose'
alias dcup='docker compose up'
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
alias jb='jabba'

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

function startVim() {
	if ! [ -x "$(command -v npm)" ]; then
	  echo 'Error: nvm is not invoked.' >&2
	  nvm >> /dev/null
	fi
	nvim $@
}

# vim
alias vi='nvim'
alias v='nvim'

# others
alias now='date +%s'
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

