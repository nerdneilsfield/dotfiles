alias python='python3'
alias pipi='python3 -m pip install -U --user -i https://pypi.tuna.tsinghua.edu.cn/simple'
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

install_python_ppa(){
   sudo apt install python3.11-full python3.11-dev 
   curl -sSL https://bootstrap.pypa.io/get-pip.py | sudo python3.11
}

install_pip(){
  curl -sSL https://bootstrap.pypa.io/get-pip.py | $1
}
