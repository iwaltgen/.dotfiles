#!/bin/sh

ln -sf ~/.dotfiles/.zshrc ~
ln -sf ~/.dotfiles/.vimrc ~
ln -sf ~/.dotfiles/.p10k.zsh ~
ln -sf ~/.dotfiles/.tmux.conf ~
ln -sf ~/.dotfiles/.alacritty.yml ~

# git
ln -sf ~/.dotfiles/.gitconfig ~

# gpg
mkdir -p ~/.gnupg
cp ~/.dotfiles/.gnupg/*.conf ~/.gnupg/
