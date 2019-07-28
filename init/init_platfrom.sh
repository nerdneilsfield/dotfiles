#!/bin/bash

echo "Personal Init Bash Scripts"

have_git = `where git`
have_zsh = `where zsh`
have_tmux = `where tmux`

if [ "$have_zsh" == "" ]; do
  echo "Please install zsh"
  exit 1
done

if [ "$have_git" == "" ]; do
  echo "Please install git"
  exit 1
done

if [ "$have_tmux" == "" ]; do

  echo "Please install tmux"
  exit 1
done


echo "Install oh-my-zsh....."
