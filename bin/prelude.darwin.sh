#!/bin/zsh

# homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  print -u2 "Homebrew installation failed"
  exit 1
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

brew install zsh wget git tree htop

# zsh
git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh

chsh -s $(which zsh)

# zinit
zsh -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

# homebrew bundle
pushd $HOME/.dotfiles/brew
brew bundle
popd

# fonts
brew install --cask font-hack-nerd-font
brew install --cask font-d2coding-nerd-font

# key repeat
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)
