#!/bin/zsh

# homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install zsh wget git tree ncdu htop neovim cmake

# zsh
git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh

chsh -s $(which zsh)

# zinit
sh -c "$(curl -fsSL https://git.io/zinit-install)"

# neovim plug
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# homebrew bundle
pushd $HOME/.dotfiles/brew
brew bundle
popd

# key repeat
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

# alacritty
defaults write org.alacritty AppleFontSmoothing -int 0
