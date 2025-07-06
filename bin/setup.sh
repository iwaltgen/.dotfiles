#!/bin/zsh

if [[ $OSTYPE == darwin* ]]; then
  /.dotfiles/bin/prelude.darwin.sh
elif [[ $OSTYPE == linux* ]]; then
  /.dotfiles/bin/prelude.linux.sh
fi

# tmux plugin manager
git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# asdf
git clone --depth 1 https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.14.0
. "$HOME/.asdf/asdf.sh"

# asdf plugins
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin add golang https://github.com/asdf-community/asdf-golang.git
asdf plugin-add java https://github.com/halcyon/asdf-java.git

asdf install nodejs latest
asdf install golang latest
asdf install java latest:temurin-21

asdf set -u nodejs latest
asdf set -u golang latest
asdf set -u java latest:temurin-21

# dotfiles
mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/atuin
mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/gh-dash
mkdir -p $HOME/.local/bin

ln -sf $HOME/.dotfiles/.zshrc $HOME
ln -sf $HOME/.dotfiles/.ideavimrc $HOME
ln -sf $HOME/.dotfiles/nvim ${XDG_CONFIG_HOME:-$HOME/.config}/nvim
ln -sf $HOME/.dotfiles/atuin/config.toml ${XDG_CONFIG_HOME:-$HOME/.config}/atuin/config.toml
ln -sf $HOME/.dotfiles/gh-dash/config.yml ${XDG_CONFIG_HOME:-$HOME/.config}/gh-dash/config.yml
ln -sf $HOME/.dotfiles/.alacritty.toml $HOME
ln -sf $HOME/.dotfiles/.starship.toml $HOME
ln -sf $HOME/.dotfiles/.asdfrc $HOME

if [[ $OSTYPE == darwin* ]]; then
  ln -sf $HOME/.dotfiles/.zshrc.darwin $HOME/.zshrc.os
  ln -sf $HOME/.dotfiles/bin/idea.darwin.sh $HOME/.local/bin/idea
elif [[ $OSTYPE == linux* ]]; then
  ln -sf $HOME/.dotfiles/.zshrc.linux $HOME/.zshrc.os
fi

ln -sf $HOME/.dotfiles/.tmux.conf $HOME
ln -sf $HOME/.dotfiles/.tmux.theme.conf $HOME
ln -sf $HOME/.dotfiles/.tmux.user.conf $HOME

# git
ln -sf $HOME/.dotfiles/.gitconfig $HOME

# gpg
mkdir -p $HOME/.gnupg
chmod 700 $HOME/.gnupg
ln -sf $HOME/.dotfiles/.gnupg/gpg.conf $HOME/.gnupg/gpg.conf
ln -sf $HOME/.dotfiles/.gnupg/gpg-agent.conf $HOME/.gnupg/gpg-agent.conf

# ntfs
mkdir $HOME/.ntfs

# alacritty theme
mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme ${XDG_CONFIG_HOME:-$HOME/.config}/alacritty/themes

source $HOME/.zshrc
