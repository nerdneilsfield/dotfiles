export FNM_NODE_DIST_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/
# fix the nvm cost too much time for int

# disable nvm use fnm
# nvm() {
#     if [ -d "$HOME/.config/nvm" ]; then
#         export NVM_DIR="$HOME/.config/nvm"
#         \. "$NVM_DIR/nvm.sh"
#         nvm $@
#     fi
# }

# if [ -d "$HOME/.config/nvm" ]; then
#     export NVM_DIR="$HOME/.config/nvm"
#     # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#     [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
#     default_version=$(cat "$NVM_DIR/alias/default")
#     export PATH="$NVM_DIR/versions/$default_version/bin:$PATH"
# fi

# nvm use default

# @brief Install fnm (Fast Node Manager) intelligently
# @return 0 on success
# @example install_fnm
# @category node
install_fnm() {
    echo "🚀 智能安装 fnm (Fast Node Manager)..."
    
    # 使用智能安装系统
    if command -v install_smart_tool >/dev/null 2>&1; then
        install_smart_tool fnm
    else
        # 回退到传统方法
        echo "⚠️  智能安装系统未加载，使用传统方法..."
        local pm=$(get_package_manager 2>/dev/null || echo "unknown")
        
        case "$pm" in
            "brew")
                brew install fnm
                ;;
            "pacman")
                if command -v yay >/dev/null 2>&1; then
                    yay -S fnm-bin
                else
                    echo "建议安装 yay 来管理 AUR 包"
                    cargo install fnm
                fi
                ;;
            *)
                # Ubuntu/CentOS 等系统回退到 cargo
                if command -v lsb_release >/dev/null; then
                    local CODENAME=$(lsb_release -c | awk '{print $2}')
                    if [[ ${CODENAME} != "bionic" ]]; then 
                        cargo binstall -y fnm
                    else
                        echo "is bionic, build from source"
                        cargo install --force fnm
                    fi
                else 
                    cargo quickinstall fnm
                fi
                ;;
        esac
    fi
}

# @brief Install LTS Node.js version using fnm
# @return 0 on success
# @example install_node
# @category node
install_node() {
    fnm install --lts
    # mkdir -p $HOME/.config/zsh_generated
    # fnm env > $HOME/.config/zsh_generated/fnm.sh
    mkdir -p ~/.zsh_func
    fnm completions --shell zsh  > ~/.zsh_func/fnm_completions.zsh
}

# @brief Add NodeSource PPA for latest Node.js versions
# @param $1 Major Node.js version (default: 21)
# @return 0 on success
# @example add_nosource_ppa 20
# @category node
add_nosource_ppa(){
  # https://github.com/nodesource/distributions
  local MAJOR_VERSION=21

  # if $1 is not empty, use it as MAJOR_VERSION
  if [ ! -z "$1" ]; then
    MAJOR_VERSION=$1
  fi

  mkdir -p /tmp/install_ppa
  cd /tmp/install_ppa
  curl -SLO https://deb.nodesource.com/nsolid_setup_deb.sh 
  sudo bash nsolid_setup_deb.sh $MAJOR_VERSION

  echo "More info https://github.com/nodesource/distributions"
}

# @brief Install Node.js from NodeSource PPA
# @return 0 on success
# @example install_nosoource_ppa
# @category node
install_nosoource_ppa(){
  sudo apt install -y nodejs
}


# 优化的 fnm 初始化 - 避免重复检查和执行
if command -v fnm >/dev/null 2>&1 || [[ -f "$HOME/.cargo/bin/fnm" ]]; then
    echo "Have fnm init"
    
    # 安全的 eval - 验证命令输出
    local fnm_output=$(fnm env --shell zsh 2>/dev/null)
    
    # 验证输出是否安全
    if [[ -n "$fnm_output" && "$fnm_output" =~ ^[[:space:]]*export[[:space:]] ]]; then
        eval "$fnm_output"
    else
        echo "Warning: fnm env output validation failed" >&2
    fi
fi
 
# Created by mirror-config-china
export IOJS_ORG_MIRROR=https://npm.taobao.org/mirrors/iojs
export NODIST_IOJS_MIRROR=https://npm.taobao.org/mirrors/iojs
export NVM_IOJS_ORG_MIRROR=https://npm.taobao.org/mirrors/iojs
export NVMW_IOJS_ORG_MIRROR=https://npm.taobao.org/mirrors/iojs
export NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node
export NODIST_NODE_MIRROR=https://npm.taobao.org/mirrors/node
export NVM_NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node
export NVMW_NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node
export NVMW_NPM_MIRROR=https://npm.taobao.org/mirrors/npm
# End of mirror-config-china
