# @description install openai/codex
install_codex() {
  if command -v npm &>/dev/null; then
    npm install -g @openai/codex
  else
    echo "npm is not installed"
  fi
}

install_kimi_cli(){
  if command -v uv &>/dev/null; then
    if command -v kimi &>/dev/null; then
      echo "kimi is already installed, upgrading"
       uv tool upgrade kimi-cli --no-cache 
    else
       uv tool install kimi-cli --no-cache 
    fi
  else
    echo "uv is not installed"
  fi
}

# @description install anthropic/codex
install_claude_code() {
  if command -v npm &>/dev/null; then
    npm install -g @anthropic-ai/claude-code
  else
    echo "npm is not installed"
  fi
}

install_gemini_cli(){
  if command -v npm &>/dev/null; then
    npm install -g @google/gemini-cli
  else
    echo "npm is not installed"
  fi
}

install_qwen_code(){
  if command -v npm &>/dev/null; then
    npm install -g @qwen-code/qwen-code
  else
    echo "npm is not installed"
  fi
}

update_ai_tools(){
  npm update -g @openai/codex
  npm update -g @anthropic-ai/claude-code
  npm update -g @google/gemini-cli
  npm update -g @qwen-code/qwen-code
}

reinstall_ai_tools(){
  npm uninstall -g @openai/codex @anthropic-ai/claude-code @google/gemini-cli @qwen-code/qwen-code
  update_ai_tools
}

# @description install aichat
# @param $1 install_prefix[optional, default: $HOME/.local]
# @return 0 on success
# @example install_aichat
# @category ai
install_aichat() {
  local install_prefix="$HOME/.local"
  # if have $1, use $1 as install_prefix
  if [ -n "$1" ]; then
    install_prefix="$1"
  fi
  local ai_chat_url="https://github.com/sigoden/aichat/releases/download/v0.29.0/aichat-v0.29.0-x86_64-unknown-linux-musl.tar.gz"

  if command -v batch_smart_download_tools >/dev/null 2>&1; then
    echo "🚀 智能安装 aichat..."
    mkdir -p "$install_prefix"
    batch_smart_download_tools "$ai_chat_url" "$install_prefix"
    return $?
  else
    echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
    echo "   尝试使用旧方法回退安装 aichat... (可能已移除)" >&2
    return 1
  fi
}
