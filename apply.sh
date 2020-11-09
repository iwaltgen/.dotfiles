#!/bin/sh

# zinit         https://github.com/zdharma/zinit
# vim-plug      https://github.com/junegunn/vim-plug

ln -sf ~/.dotfiles/.zshrc ~
ln -sf ~/.dotfiles/.vimrc ~

# git
ln -sf ~/.dotfiles/.gitconfig ~

# gpg
mkdir -p ~/.gnupg
cp ~/.dotfiles/.gnupg/* ~/.gnupg/
