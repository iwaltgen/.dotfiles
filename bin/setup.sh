#!/bin/zsh

if [[ $OSTYPE == darwin* ]]; then
  ./prelude.darwin.sh
elif [[ $OSTYPE == linux* ]]; then
  ./prelude.linux.sh
fi

mkdir -p $HOME/.config/atuin
mkdir -p $HOME/.config/gh-dash

ln -sf $HOME/.dotfiles/.zshrc $HOME
ln -sf $HOME/.dotfiles/.ideavimrc $HOME
ln -sf $HOME/.dotfiles/nvim $HOME/.config/nvim
ln -sf $HOME/.dotfiles/atuin/config.toml $HOME/.config/atuin/config.toml
ln -sf $HOME/.dotfiles/gh-dash/config.yml $HOME/.config/gh-dash/config.yml
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
mkdir -p $HOME/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme $HOME/.config/alacritty/themes

source $HOME/.zshrc
