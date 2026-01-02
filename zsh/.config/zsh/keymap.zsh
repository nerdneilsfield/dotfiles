# # 强制使用 vi 模式，防止意外进入 emacs 模式
bindkey -e

# 设置 vi 模式的键超时
# export KEYTIMEOUT=1

# edit in vim
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line
bindkey '\ev' edit-command-line



# 在 vi 模式下重新绑定常用键，防止意外进入 emacs 模式
# Home 和 End 键安全绑定
# bindkey '^[[H' beginning-of-line    # Home
# bindkey '^[[F' end-of-line          # End
# bindkey '^[OH' beginning-of-line    # Home (alternative)
# bindkey '^[OF' end-of-line          # End (alternative)

# 方向键和修饰键组合
# bindkey '^[[1;5D' backward-word     # Ctrl+Left
# bindkey '^[[1;5C' forward-word      # Ctrl+Right
# bindkey '^[[5~' up-line-or-history  # Page Up
# bindkey '^[[6~' down-line-or-history # Page Down

# 保留自定义移动键 (使用 vi 模式兼容)
# bindkey -M viins '\eh' backward-word
# bindkey -M viins '\el' forward-word
# bindkey -M viins '\ej' beginning-of-line
# bindkey -M viins '\ek' end-of-line



# shortcuts
# bindkey -s '\ee' 'nvim .\n'
# bindkey -s '\eo' 'cd ..\n'
# bindkey -s '\e;' 'll\n'



# auto suggestion
autoload -U autosuggest-execute
bindkey '^\' autosuggest-execute
bindkey '^n' autosuggest-accept

export EDITOR=vim
# bindkey '\ev' deer
# bindkey -s '\eu' 'ranger_cd\n'
# bindkey -s '\eOS' 'vim '
