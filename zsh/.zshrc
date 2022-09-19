export ZSH_CONF_DIR="$HOME/.config/zsh"
export ZSH_PRIVATE_CONF_DIR="$HOME/.config/zsh_private"

source "$ZSH_PRIVATE_CONF_DIR/variables.zsh"

source "$ZSH_CONF_DIR/alias.zsh"
source "$ZSH_CONF_DIR/function.zsh"
source "$ZSH_CONF_DIR/starship.zsh"
source "$ZSH_CONF_DIR/config.zsh"

source "$ZSH_CONF_DIR/cc.zsh"
source "$ZSH_CONF_DIR/golang.zsh"
source "$ZSH_CONF_DIR/rust.zsh"
source "$ZSH_CONF_DIR/python.zsh"
source "$ZSH_CONF_DIR/java.zsh"
source "$ZSH_CONF_DIR/node.zsh"
source "$ZSH_CONF_DIR/ros.zsh"
source "$ZSH_CONF_DIR/zig.zsh"


## # import z.lua
## eval "$(lua $ZSH_CONF_DIR/z.lua  --init zsh)"    # ZSH 初始化

## install plugins
# source "$ZSH_CONF_DIR/zplug.zsh"
source "$ZSH_CONF_DIR/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
## wtf? auto completion need this guy
autoload -U compinit && compinit


## set keybinding after plugins
source "$ZSH_CONF_DIR/keymap.zsh"

# system specified configuration
if [ "$(uname 2> /dev/null)" = "Linux" ]; then
	source "$ZSH_CONF_DIR/config.linux.zsh"
	if [ $"uname -r | grep -q 'Microsoft'" ]; # if in wsl 
	then
		source "$ZSH_CONF_DIR/config.wsl.zsh"
	fi
fi

if [ "$(uname 2> /dev/null)" = "Darwin" ]; then
	source "$ZSH_CONF_DIR/config.macos.zsh"
fi

## fzf
# export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
# export FZF_COMPLETION_TRIGGER='ll'
# export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude .clang-cache --exclude .ccls-cache'
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

## z.lua
export _ZL_MATCH_MODE=1
export _ZL_CMD=z
export _ZL_ADD_ONCE=1
eval "$(lua $ZSH_CONF_DIR/z.lua  --init zsh)" #  once enhanced)"
##eval "$(lua $ZSH_CONF_DIR/z.lua  --init zsh  once enhanced)"


## check tools
source "$ZSH_CONF_DIR/tools.zsh"
## Set Spaceship ZSH as a prompt
autoload -U promptinit; promptinit
# prompt -p spaceship

