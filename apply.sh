#!/bin/zsh

ln -sf ~/.dotfiles/.zshrc ~
ln -sf ~/.dotfiles/.vimrc ~
ln -sf ~/.dotfiles/.ideavimrc ~
ln -sf ~/.dotfiles/nvim ~/.config/nvim
ln -sf ~/.dotfiles/atuin/config.toml ~/.config/atuin/config.toml
ln -sf ~/.dotfiles/gh-dash/config.yml ~/.config/gh-dash/config.yml
ln -sf ~/.dotfiles/.alacritty.yml ~
ln -sf ~/.dotfiles/.starship.toml ~
ln -sf ~/.dotfiles/.asdfrc ~

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
chmod 700 ~/.gnupg
cp ~/.dotfiles/.gnupg/*.conf ~/.gnupg/

# ntfs
mkdir ~/.ntfs

# alacritty theme
mkdir -p ~/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
