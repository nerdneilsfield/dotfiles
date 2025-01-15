# 获取所有安装的 Python 3 版本


# 初始化一个数组来存储找到的 Python 版本
python_versions=()
# 遍历 $PATH 中的所有目录
for dir in ${(s/:/)PATH}; do
  # 检查目录是否存在
  if [[ -d $dir ]]; then
    # 查找以 python3. 开头且只包含数字的可执行文件 <-> 代表匹配一个数字
    for file in $dir/python3.<->(N); do
      # 检查文件是否存在且可执行
      if [[ -x $file ]]; then
        python_versions+=($file:t)
      fi
    done
  fi
done 

# 如果没有找到任何 Python 3 版本，退出脚本
if [[ ${#python_versions[@]} -eq 0 ]]; then
  yellow_echo "没有找到任何 Python 3 版本。"
  exit 1
fi

# 找到最新的 Python 3 版本
local _python_latest_version=$(printf "%s\n" "${python_versions[@]}" | sort -V | tail -n 1)

green_echo "设置 Python3 版本为: $_python_latest_version"

# 创建别名
# alias python3=$_python_latest_version
alias python='python3'
alias pipgi='python3 -m pip install -U --user -i https://pypi.tuna.tsinghua.edu.cn/simple'
alias pipi='python3 -m pip install -U -i https://pypi.tuna.tsinghua.edu.cn/simple'
alias pipu="python3 -m pip install -U -i https://pypi.tuna.tsinghua.edu.cn/simple pip"
alias pipl="python3 -m pip list"
alias pipf="python3 -m pip freeze"
alias addpwd2pythonpah="export PYTHONPATH=${PWD}:$PYTHONPATH"
alias uvpi="uv pip install"
alias uvins="uv python install"
alias uvrun="uv run"
alias uvvenvt="uv venv -i https://pypi.tuna.tsinghua.edu.cn/simple"
alias uvvenv="uv venv"

install_pyenv() {
        rm -rf ${HOME}/.local/pyenv
        git clone https://github.com/pyenv/pyenv.git ~/.local/pyenv
        cd ~/.local/pyenv
        ./src/configure
        make -C src
}

# install_poetry() {
#         rm -rf ${HOME}/.local/poetry
#         curl -sS https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py -o /tmp/get-poetry.py
#         POETRY_HOME=${HOME}/.local/poetry python3 /tmp/get-poetry.py --no-modify-path -y -f
#         mkdir -p ${HOME}/.config/zfunc
#         poetry completions zsh > ~/.config/zfunc/_poetry
# }
# setup pyenv
# export PYENV_ROOT="$HOME/.local/pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

#setup poetry
# export POETRY_HOME="$HOME/.local/poetry"
# command -v poetry >/dev/null || export PATH="$POETRY_HOME/bin:$PATH"
# source ${HOME}/.local/poetry/env
# fpath+=${HOME}/.zfunc

install_python_tools() {
  local _python_tools=(
    "blue"
    "autopep8"
    "black"
    "isort"
    "pyright"
    "pydocstyle"
    # "flake8" // conflict with blue 
    "debugpy"
    "pylint"
    "sourcery"
    "vulture"
    "ruff"
    "pipx"
    "ptpython"
    "uv"
  )

  for _tool in $_python_tools; do
      echo "install $_tool"
      pipi  $_tool
    done
}

install_python_rust_tools(){
  local _python_tools=(
  "rye"
  )

  for _tool in $_python_tools; do
    echo "install $_tool"
    cargo install --git https://github.com/mitsuhiko/rye  $_tool
  done
}

add_python_ppa(){
  sudo add-apt-repository ppa:deadsnakes/ppa
}

install_latest_python_ppa() {
  # 使用 apt search 查找所有可用的 Python 版本
  available_versions=$(apt search python3 | grep -oP 'python3\.\d{2}-full' | sort -V | uniq)

  # 查找版本号最大的 Python 版本
  latest_version=$(echo "$available_versions" | tail -n 1)
  green_echo "version: $latest_version"

  # 如果找不到任何 Python 版本，输出错误信息并退出
  if [[ -z "$latest_version" ]]; then
    yellow_echo "未找到可用的 Python 版本。"
    return 1
  fi

  latest_version=$(echo "$latest_version" | grep -oP 'python3\.\d+' | head -n 1)

  green_echo "找到的最新 Python 版本: $latest_version"

  # 安装最新版本的 Python 及其相关包
  sudo apt update
  sudo apt install -y "${latest_version}-full" "${latest_version}-dev" "${latest_version}-venv"
  curl -sSL https://bootstrap.pypa.io/get-pip.py | sudo "${latest_version}"

  green_echo "已成功安装 $latest_version 及其相关包。"
}

install_pip(){
  curl -sSL https://bootstrap.pypa.io/get-pip.py | $1
}

install_pythontools_uv(){
  python3 -m pip install --user -i https://pypi.tuna.tsinghua.edu.cn/simple uv
}

install_pythontools_minimamba(){
  "${SHELL}" <(curl -L micro.mamba.pm/install.sh)
}


set_python_mirror_cn(){
  mkdir -p ~/.pip
  cat > ~/.pip/pip.conf <<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
EOF
}


init_mamba(){
  # >>> mamba initialize >>>
  # !! Contents within this block are managed by 'micromamba shell init' !!
  export MAMBA_EXE='${HOME}/.local/bin/micromamba';
  export MAMBA_ROOT_PREFIX='${HOME}/.local/micromamba';
  __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__mamba_setup"
  else
      alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
  fi
  unset __mamba_setup
  # <<< mamba initialize <<<
}


install_pixi(){
  VERSION="${PIXI_VERSION:-latest}"
  PIXI_HOME="${PIXI_HOME:-$HOME/.pixi}"
  PIXI_HOME="${PIXI_HOME/#\~/$HOME}"
  BIN_DIR="$PIXI_HOME/bin"

  REPO="prefix-dev/pixi"
  PLATFORM="$(uname -s)"
  ARCH="${PIXI_ARCH:-$(uname -m)}"

  if [[ $PLATFORM == "Darwin" ]]; then
    PLATFORM="apple-darwin"
  elif [[ $PLATFORM == "Linux" ]]; then
    PLATFORM="unknown-linux-musl"
  elif [[ $(uname -o) == "Msys" ]]; then
    PLATFORM="pc-windows-msvc"
  fi

  if [[ $ARCH == "arm64" ]] || [[ $ARCH == "aarch64" ]]; then
    ARCH="aarch64"
  fi



  BINARY="pixi-${ARCH}-${PLATFORM}"
  EXTENSION="tar.gz"
  if [[ $(uname -o) == "Msys" ]]; then
    EXTENSION="zip"
  fi

  if [[ $VERSION == "latest" ]]; then
    DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${BINARY}.${EXTENSION}"
  else
    DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${BINARY}.${EXTENSION}"
  fi

  printf "This script will automatically download and install Pixi (%s) for you.\nGetting it from this url: %s\n" "$VERSION" "$DOWNLOAD_URL"

  if ! hash curl 2> /dev/null && ! hash wget 2> /dev/null; then
    echo "error: you need either 'curl' or 'wget' installed for this script."
    exit 1
  fi

  if ! hash tar 2> /dev/null; then
    echo "error: you do not have 'tar' installed which is required for this script."
    exit 1
  fi

  TEMP_FILE="$(mktemp "${TMPDIR:-/tmp}/.pixi_install.XXXXXXXX")"

  cleanup() {
    rm -f "$TEMP_FILE"
  }

  trap cleanup EXIT

  # Test if stdout is a terminal before showing progress
  if [[ ! -t 1 ]]; then
    CURL_OPTIONS="--silent"  # --no-progress-meter is better, but only available in 7.67+
    WGET_OPTIONS="--no-verbose"
  else
    CURL_OPTIONS="--no-silent"
    WGET_OPTIONS="--show-progress"
  fi

  if hash curl 2> /dev/null; then
    # Check that the curl version is not 8.8.0, which is broken for --write-out
    # https://github.com/curl/curl/issues/13845
    if [[ "$(curl --version | head -n 1 | cut -d ' ' -f 2)" == "8.8.0" ]]; then
      echo "error: curl 8.8.0 is known to be broken, please use a different version"
      if [[ $(uname -o) == "Msys" ]]; then
        echo "A common way to get an updated version of curl is to upgrade Git for Windows:"
        echo "      https://gitforwindows.org/"
      fi
      exit 1
    fi
    HTTP_CODE="$(curl -SL $CURL_OPTIONS "$DOWNLOAD_URL" --output "$TEMP_FILE" --write-out "%{http_code}")"
    if [[ "${HTTP_CODE}" -lt 200 || "${HTTP_CODE}" -gt 299 ]]; then
      echo "error: '${DOWNLOAD_URL}' is not available"
      exit 1
    fi
  elif hash wget 2> /dev/null; then
    if ! wget $WGET_OPTIONS --output-document="$TEMP_FILE" "$DOWNLOAD_URL"; then
      echo "error: '${DOWNLOAD_URL}' is not available"
      exit 1
    fi
  fi

  # Check that file was correctly created (https://github.com/prefix-dev/pixi/issues/446)
  if [[ ! -s "$TEMP_FILE" ]]; then
    echo "error: temporary file ${TEMP_FILE} not correctly created."
    echo "       As a workaround, you can try set TMPDIR env variable to directory with write permissions."
    exit 1
  fi

  # Extract pixi from the downloaded file
  mkdir -p "$BIN_DIR"
  if [[ "$(uname -o)" == "Msys" ]]; then
    unzip "$TEMP_FILE" -d "$BIN_DIR"
  else
    # Extract to a temporary directory first
    TEMP_DIR=$(mktemp -d)
    tar -xzf "$TEMP_FILE" -C "$TEMP_DIR"

    # Find and move the `pixi` binary, making sure to handle the case where it's in a subdirectory
    if [[ -f "$TEMP_DIR/pixi" ]]; then
      mv "$TEMP_DIR/pixi" "$BIN_DIR/"
    else
      mv "$(find "$TEMP_DIR" -type f -name pixi)" "$BIN_DIR/"
    fi

    chmod +x "$BIN_DIR/pixi"
    rm -rf "$TEMP_DIR"
  fi

  echo "The 'pixi' binary is installed into '${BIN_DIR}'"
}


if [ -d "/home/dengqi/.pixi/bin" ]; then
    export PATH="/home/dengqi/.pixi/bin:$PATH"
fi
