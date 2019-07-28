#!/bin/sh


set -e

_green() {
  printf '\033[1;31;32m%b\033[0m\n' "$1"
}

_red() {
  printf '\033[1;31;40m%b\033[0m\n' "$1"
}

_exists() {
  cmd="$1"
  if [ -z "$cmd" ]; then
    _red "Usage: _exists cmd"
    return 1
  fi

  if eval type type >/dev/null 2>&1; then
    eval type "$cmd" >/dev/null 2>&1
  elif command >/dev/null 2>&1; then
    command -v "$cmd" >/dev/null 2>&1
  else
    which "$cmd" >/dev/null 2>&1
  fi
  return "$?"
}

main() {
  if [ "$(uname -s)" != "Darwin" ]  && [ "$(uname -s)" != "Linux" ]; then
    _red "Unsupported operating system, Darwin or Liunux? If you are using Windows, you need use install.ps1";
    return 1;
  fi
  if _exists "vim"; then
    if [ -f ~/.vimrc ]; then
      mv ~/.vimrc ~/.vimrc.bak;
    fi
    echo "source ${PWD}/init.vim" > ~/.vimrc
  else
    _red "Not found vim, [brew|apt|yum] install tmux or pacman -S vim?"
    return 1;
  fi
  _green "Vim config is installed to ~/.vimrc."
  _green "Open vim and use :PluginInstall to install plugins"
  _green "You may need to install YouCompleteMe handly!"
  cp .ycm_extra_conf.py ~/.config/.ycm_extra_conf.py
}

main "$@"