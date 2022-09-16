alias python='python3'
alias pip='python3 -m pip'
alias pipu="python3 -m pip -U pip"
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
export PYENV_ROOT="$HOME/.local/pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

#setup poetry
# export POETRY_HOME="$HOME/.local/poetry"
# command -v poetry >/dev/null || export PATH="$POETRY_HOME/bin:$PATH"
# source ${HOME}/.local/poetry/env
# fpath+=${HOME}/.zfunc

install_python_tools() {
  local _python_tools=(
    "blue"
    "autopep8"
    "isort"
    "pyright"
    "pydocstyle"
    "flake8"
    "debugpy"
    "pylint"
    "sourcery"
    "vulture"
  )

  for _tool in $_python_tools; do
      echo "install $_tool"
      python3 -m pip install --user -U $_tool
    done
}
