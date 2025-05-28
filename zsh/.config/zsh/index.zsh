# 核心模块 - 总是加载
source "$ZSH_CONF_DIR/alias.zsh"
source "$ZSH_CONF_DIR/function.zsh"
source "$ZSH_CONF_DIR/starship.zsh"
source "$ZSH_CONF_DIR/config.zsh"
source "$ZSH_CONF_DIR/completion.zsh"
source "$ZSH_CONF_DIR/shell.zsh"
source "$ZSH_CONF_DIR/help.zsh"

# 智能条件加载 - 只在需要时加载
_conditional_source() {
  local file="$1"
  local condition="$2"
  
  if [[ -f "$ZSH_CONF_DIR/$file" ]] && eval "$condition"; then
    source "$ZSH_CONF_DIR/$file"
  fi
}

# 基于工具存在性的条件加载
_conditional_source "docker.zsh" "command -v docker >/dev/null 2>&1"
_conditional_source "golang.zsh" "command -v go >/dev/null 2>&1 || [[ -d /usr/local/go ]]"
_conditional_source "rust.zsh" "command -v cargo >/dev/null 2>&1 || [[ -d ~/.cargo ]]"
_conditional_source "python.zsh" "command -v python3 >/dev/null 2>&1"
_conditional_source "node.zsh" "command -v node >/dev/null 2>&1 || command -v fnm >/dev/null 2>&1 || [[ -f ~/.cargo/bin/fnm ]]"
_conditional_source "java.zsh" "command -v java >/dev/null 2>&1 || [[ -n $JAVA_HOME ]]"
_conditional_source "nix.zsh" "command -v nix >/dev/null 2>&1 || [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]"

# 专业开发环境 - 按需加载
_conditional_source "cc.zsh" "command -v gcc >/dev/null 2>&1 || command -v clang >/dev/null 2>&1"
_conditional_source "cuda.zsh" "command -v nvcc >/dev/null 2>&1 || [[ -d /usr/local/cuda ]]"
_conditional_source "wasm.zsh" "command -v wasmtime >/dev/null 2>&1 || command -v wasmer >/dev/null 2>&1"
_conditional_source "zig.zsh" "command -v zig >/dev/null 2>&1"

# 平台特定配置 - 基于系统类型加载
case "$(uname -s)" in
  "Darwin")
    _conditional_source "config.macos.zsh" "true"
    ;;
  "Linux")
    _conditional_source "config.linux.zsh" "true"
    ;;
  *)
    # 检查是否为 MSYS2/Cygwin
    if [[ "$(uname -o 2>/dev/null)" == "Msys" ]]; then
      _conditional_source "config.msys2.zsh" "true"
    elif [[ "$(uname -o 2>/dev/null)" == "Cygwin" ]]; then
      _conditional_source "config.msys2.zsh" "true"  # MSYS2 配置也适用于 Cygwin
    fi
    ;;
esac

# 特殊硬件/系统相关 - 只在特定环境加载
_conditional_source "hdl.zsh" "[[ -d /opt/xilinx ]] || [[ -d /opt/intel/quartus ]]"
_conditional_source "xilinx.zsh" "[[ -d /opt/xilinx ]]"
_conditional_source "ros.zsh" "[[ -d /opt/ros ]] || command -v roscore >/dev/null 2>&1"
_conditional_source "robotics.zsh" "[[ -d /opt/ros ]]"

# Web 开发 - 轻量级，总是加载
source "$ZSH_CONF_DIR/html.zsh"

# 性能工具 - 总是加载
source "$ZSH_CONF_DIR/utils.zsh"

# 安全工具 - 总是加载
source "$ZSH_CONF_DIR/security.zsh"

# 智能包管理器 - 总是加载
source "$ZSH_CONF_DIR/package_manager.zsh"

# 帮助系统 - 总是加载
source "$ZSH_CONF_DIR/help_system.zsh"

# 清理临时函数
unset -f _conditional_source
