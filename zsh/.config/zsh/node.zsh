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

install_fnm() {
    if command -v lsb_release>>/dev/null; then
      local CODENAME=$(lsb_release -c | awk '{print $2}')
      echo $CODENAME
      if [[ ${CODENAME}!="bionic" ]];then 
        cargo binstall -y fnm
      else
        echo "is bionic, build from souce"
        cargo install --force fnm
      fi
    else 
      cargo quickinstall fnm
    fi
}

install_node() {
    fnm install --lts
    # mkdir -p $HOME/.config/zsh_generated
    # fnm env > $HOME/.config/zsh_generated/fnm.sh
    mkdir -p ~/.zsh_func
    fnm completions --shell zsh  > ~/.zsh_func/fnm_completions.zsh
}

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

install_nosoource_ppa(){
  sudo apt install -y nodejs
}


if [ -f $HOME/.cargo/bin/fnm ]; then
    #  source $HOME/.config/zsh_generated/fnm.sh
    eval "$(fnm env --use-on-cd)"
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
