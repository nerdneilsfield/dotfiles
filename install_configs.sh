#!/usr/bin/env bash

# first of all install stow

if ! type "stow" > /dev/null; then
  echo "stow is not installed, installing it"
  brew install stow
fi

