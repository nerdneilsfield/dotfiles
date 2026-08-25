# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("/Users/dengqi/.zsh/completions" $fpath)
autoload -Uz compinit
# compinit will be called later with -C to use cache
# OPENSPEC:END

# Performance optimizations: deduplicate PATH, remove echos, precompile regex, cache path_case_insensitive

export ZSH_CONF_DIR="$HOME/.config/zsh"
export ZSH_PRIVATE_CONF_DIR="$HOME/.config/zsh_private"

set -o vi

set +e

# Load helpers before private variables; variables.zsh calls green_echo.
source "$ZSH_CONF_DIR/utils.zsh"
source "$ZSH_CONF_DIR/function.zsh"

# if ZSH_PRIVATE_CONF_DIR exists, source it
if [ -d "$ZSH_PRIVATE_CONF_DIR" ]; then
	source "$ZSH_PRIVATE_CONF_DIR/variables.zsh"
fi

source "$ZSH_CONF_DIR/index.zsh"

## # import z.lua
## eval "$(lua $ZSH_CONF_DIR/z.lua  --init zsh)"    # ZSH 初始化

## install plugins
# source "$ZSH_CONF_DIR/zplug.zsh"
source "$ZSH_CONF_DIR/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
## wtf? auto completion need this guy
source "$ZSH_CONF_DIR/tools.zsh"
autoload -U compinit && compinit -C



# system specified configuration
# if [ "$(uname 2> /dev/null)" = "Linux" ]; then
# 	source "$ZSH_CONF_DIR/config.linux.zsh"
# 	if [ $"uname -r | grep -q 'Microsoft'" ]; # if in wsl
# 	then
# 		source "$ZSH_CONF_DIR/config.wsl.zsh"
# 	fi
# fi

# if [ "$(uname 2> /dev/null)" = "Darwin" ]; then
# 	source "$ZSH_CONF_DIR/config.macos.zsh"
# fi

## fzf
# export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
# export FZF_COMPLETION_TRIGGER='ll'
# export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude .clang-cache --exclude .ccls-cache'
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

## z.lua
# export _ZL_MATCH_MODE=1
# export _ZL_CMD=z
# export _ZL_ADD_ONCE=1
# eval "$(lua $ZSH_CONF_DIR/z.lua --init zsh fzf)" #  once enhanced)"
##eval "$(lua $ZSH_CONF_DIR/z.lua  --init zsh  once enhanced)"


## check tools
source "$ZSH_CONF_DIR/editor.zsh"
## Set Spaceship ZSH as a prompt
autoload -U promptinit; promptinit
# prompt -p spaceship


# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# if ~/.zsh_self exists, source it
[ -f "$HOME/.zsh_self" ] && source "$HOME/.zsh_self"
[ -f "$HOME/.zsh_local" ] && source "$HOME/.zsh_local"

## set keybinding after plugins
source "$ZSH_CONF_DIR/keymap.zsh"
print -r -- "💡 命令行编辑：Ctrl-X Ctrl-E（或 Esc-v）→ ${EDITOR:-vi}"

# kimi-code
export PATH="/Users/dengqi/.kimi-code/bin:$PATH"

# mimocode
export PATH=/Users/dengqi/.mimocode/bin:$PATH

# bun completions
[ -s "/Users/dengqi/.bun/_bun" ] && source "/Users/dengqi/.bun/_bun"

# Remove broken completion links before compinit scans fpath.
zsh_fix_completions

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Deduplicate PATH entries
typeset -U path

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/dengqi/.lmstudio/bin"
# End of LM Studio CLI section


# opencodex claude-env hook
[ -f ~/.opencodex/claude-env.sh ] && source ~/.opencodex/claude-env.sh
