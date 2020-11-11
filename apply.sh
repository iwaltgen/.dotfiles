#!/bin/sh

ln -sf ~/.dotfiles/.zshrc ~
ln -sf ~/.dotfiles/.vimrc ~
ln -sf ~/.dotfiles/.p10k.zsh ~

# git
ln -sf ~/.dotfiles/.gitconfig ~

# gpg
mkdir -p ~/.gnupg
cp ~/.dotfiles/.gnupg/*.conf ~/.gnupg/
