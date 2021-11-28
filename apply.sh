#!/bin/sh

ln -sf ~/.dotfiles/.zshrc ~
ln -sf ~/.dotfiles/.vimrc ~
ln -sf ~/.dotfiles/.ideavimrc ~
ln -sf ~/.dotfiles/.p10k.zsh ~
ln -sf ~/.dotfiles/.alacritty.yml ~

touch ~/.zshrc.local
if [[ $OSTYPE == darwin* ]]; then
  ln -sf ~/.dotfiles/.zshrc.mac ~/.zshrc.os
elif [[ $OSTYPE == linux* ]]; then
  ln -sf ~/.dotfiles/.zshrc.linux ~/.zshrc.os
fi

ln -sf ~/.dotfiles/.tmux.conf ~
ln -sf ~/.dotfiles/.tmux.theme.conf ~
ln -sf ~/.dotfiles/.tmux.user.conf ~

# git
ln -sf ~/.dotfiles/.gitconfig ~

# gpg
mkdir -p ~/.gnupg
cp ~/.dotfiles/.gnupg/*.conf ~/.gnupg/
