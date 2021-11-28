#!/bin/sh

ln -sf ~/.dotfiles/.zshrc ~
ln -sf ~/.dotfiles/.vimrc ~
ln -sf ~/.dotfiles/.ideavimrc ~
ln -sf ~/.dotfiles/.p10k.zsh ~
ln -sf ~/.dotfiles/.alacritty.yml ~

case "$OSTYPE" in
  darwin*)  ln -sf ~/.dotfiles/.zshrc.mac ~/.zshrc.os ;;
  linux*)   ln -sf ~/.dotfiles/.zshrc.linux ~/.zshrc.os ;;
  *)        echo "unknown ostype: $OSTYPE" ;;
esac
touch ~/.zshrc.local

ln -sf ~/.dotfiles/.tmux.conf ~
ln -sf ~/.dotfiles/.tmux.theme.conf ~
ln -sf ~/.dotfiles/.tmux.user.conf ~

# git
ln -sf ~/.dotfiles/.gitconfig ~

# gpg
mkdir -p ~/.gnupg
cp ~/.dotfiles/.gnupg/*.conf ~/.gnupg/
