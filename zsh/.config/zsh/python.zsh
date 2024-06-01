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
alias python3=$_python_latest_version
alias python='python3'
alias pipgi='python3 -m pip install -U --user -i https://pypi.tuna.tsinghua.edu.cn/simple'
alias pipi='python3 -m pip install -U -i https://pypi.tuna.tsinghua.edu.cn/simple'
alias pipu="python3 -m pip install -U -i https://pypi.tuna.tsinghua.edu.cn/simple pip"
alias pipl="python3 -m pip list"
alias pipf="python3 -m pip freeze"
alias addpwd2pythonpah="export PYTHONPATH=${PWD}:$PYTHONPATH"

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
  available_versions=$(apt search python3 | grep -oP 'python3\.\d{2}{?=\s|/}' | sort -V | uniq)

  # 查找版本号最大的 Python 版本
  latest_version=$(echo "$available_versions" | tail -n 1)

  # 如果找不到任何 Python 版本，输出错误信息并退出
  if [[ -z "$latest_version" ]]; then
    yellow_echo "未找到可用的 Python 版本。"
    return 1
  fi

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


set_python_mirror_cn(){
  mkdir -p ~/.pip
  cat > ~/.pip/pip.conf <<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
EOF
}
