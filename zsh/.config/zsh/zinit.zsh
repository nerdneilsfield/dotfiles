export ZINIT_PATH="$HOME/.zinit/bin"

# 避免与 zoxide 的 zi 命令冲突
# 这里我们保持 zinit 的 zi 命令，因为我们已经将 zoxide 的交互式命令改为 zx
# 如果需要完全禁用 zinit 别名，可以设置: export ZINIT[NO_ALIASES]=1

# ==================================================================
# Install zinit if not exist
# ==================================================================
if [ ! -f "$ZINIT_PATH/zinit.zsh" ]; then
	echo "Installing zinit ..."
	[ ! -d "$ZINIT_PATH" ] && mkdir -p "$ZINIT" 2>/dev/null
	if [ -x "$(which git)" ]; then
		#setpx
		git clone --depth 1 https://ghproxy.dengqi.org/https://github.com/zdharma-continuum/zinit.git $ZINIT_PATH
	else
		echo "ERROR: please install git before installation !!"
		exit 1
	fi
	if [ ! $? -eq 0 ]; then
		echo ""
		echo "ERROR: downloading zinit failed !!"
		exit 1
	fi
	# zplug install
fi

# ==================================================================
# source zplug
# ==================================================================
source "$ZINIT_PATH/zinit.zsh"

# ==================================================================
# claim plugins
# ==================================================================
zinit light jocelynmallon/zshmarks
zinit light mafredri/zsh-async
# zinit light zdharma/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

# If completion is needed, de-comment lines below.
# this will add 200ms loading time.
zinit ice wait lucid atload"zicompinit"
zinit light zsh-users/zsh-completions

# ==================================================================
# update zinit, only run update or first install
# ==================================================================
# zinit self-update

# Convenient update functions
function zinit-update-all() {
	echo "🔄 Updating zinit itself..."
	zinit self-update
	echo "🔄 Updating all plugins..."
	zinit update --all
	echo "✅ All updates completed!"
}

alias zup='zinit-update-all'

# ==================================================================
# plugin config
# ==================================================================

# ZSH_AUTOSUGGEST
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_HIGHLIGHT_STYLES[comment]=fg=245
