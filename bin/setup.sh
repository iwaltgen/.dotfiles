#!/bin/zsh

if [[ $OSTYPE == darwin* ]]; then
  ./prelude.darwin.sh
elif [[ $OSTYPE == linux* ]]; then
  ./prelude.linux.sh
fi

# tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# asdf plugins
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin add golang https://github.com/asdf-community/asdf-golang.git
asdf plugin-add java https://github.com/halcyon/asdf-java.git
asdf plugin-add direnv
asdf direnv setup --shell zsh --version system

asdf install nodejs latest
asdf install golang latest
asdf install java latest:temurin-17

asdf global nodejs latest
asdf global golang latest
asdf global java latest:temurin-17

# dotfiles
mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/atuin
mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/gh-dash

ln -sf $HOME/.dotfiles/.zshrc $HOME
ln -sf $HOME/.dotfiles/.ideavimrc $HOME
ln -sf $HOME/.dotfiles/nvim ${XDG_CONFIG_HOME:-$HOME/.config}/nvim
ln -sf $HOME/.dotfiles/atuin/config.toml ${XDG_CONFIG_HOME:-$HOME/.config}/atuin/config.toml
ln -sf $HOME/.dotfiles/gh-dash/config.yml ${XDG_CONFIG_HOME:-$HOME/.config}/gh-dash/config.yml
ln -sf $HOME/.dotfiles/.alacritty.yml $HOME
ln -sf $HOME/.dotfiles/.starship.toml $HOME
ln -sf $HOME/.dotfiles/.asdfrc $HOME

if [[ $OSTYPE == darwin* ]]; then
  ln -sf $HOME/.dotfiles/.zshrc.darwin $HOME/.zshrc.os
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
cp $HOME/.dotfiles/.gnupg/*.conf $HOME/.gnupg/

# ntfs
mkdir $HOME/.ntfs

# alacritty theme
mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme ${XDG_CONFIG_HOME:-$HOME/.config}/alacritty/themes

source $HOME/.zshrc
