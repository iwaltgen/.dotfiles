#!/bin/zsh

# homebrew
brew_bin="${commands[brew]:-/opt/homebrew/bin/brew}"
if [[ ! -x "$brew_bin" ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit 1
  brew_bin=/opt/homebrew/bin/brew
fi
if [[ ! -x "$brew_bin" ]]; then
  print -u2 "Homebrew installation failed"
  exit 1
fi
eval "$("$brew_bin" shellenv)"

brew install git || exit 1

# zsh
oh_my_zsh_dir="$HOME/.oh-my-zsh"
if [[ ! -d "$oh_my_zsh_dir/.git" ]]; then
  if [[ -e "$oh_my_zsh_dir" || -L "$oh_my_zsh_dir" ]]; then
    print -u2 "Oh My Zsh path exists but is not a Git repository: $oh_my_zsh_dir"
    exit 1
  fi
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$oh_my_zsh_dir" || exit 1
fi

zsh_path=/bin/zsh
current_shell="$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}')"
if [[ -z "$current_shell" ]]; then
  print -u2 "Unable to determine the current login shell"
  exit 1
fi
if [[ "$current_shell" != "$zsh_path" ]]; then
  chsh -s "$zsh_path" || exit 1
fi

# zinit
zinit_script="$HOME/.local/share/zinit/zinit.git/zinit.zsh"
if [[ ! -f "$zinit_script" ]]; then
  zsh -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)" || exit 1
  if [[ ! -f "$zinit_script" ]]; then
    print -u2 "Zinit installation failed"
    exit 1
  fi
fi

# homebrew bundle
pushd "$HOME/.dotfiles/brew" || exit 1
brew bundle || exit 1
popd || exit 1

# key repeat
defaults write -g ApplePressAndHoldEnabled -bool false || exit 1
defaults write -g InitialKeyRepeat -int 10 || exit 1 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1 || exit 1 # normal minimum is 2 (30 ms)
