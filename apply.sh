#!/bin/sh

ln -sf ~/.dotfiles/.zshrc ~
ln -sf ~/.dotfiles/.vimrc ~
ln -sf ~/.dotfiles/.p10k.zsh ~
ln -sf ~/.dotfiles/.alacritty.yml ~

ln -sf ~/.dotfiles/.tmux.conf ~
ln -sf ~/.dotfiles/.tmux.theme.conf ~
ln -sf ~/.dotfiles/.tmux.user.conf ~

# git
ln -sf ~/.dotfiles/.gitconfig ~

# gpg
mkdir -p ~/.gnupg
cp ~/.dotfiles/.gnupg/*.conf ~/.gnupg/
