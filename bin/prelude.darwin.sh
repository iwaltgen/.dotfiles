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

# jetendard font (JetBrainsMono Nerd Font Mono + Pretendard Korean glyphs; no Homebrew cask upstream)
jetendard_fonts_dir="$HOME/Library/Fonts"
mkdir -p "$jetendard_fonts_dir" || exit 1
if [[ ! -f "$jetendard_fonts_dir/Jetendard-Regular.ttf" ]]; then
  pushd "$jetendard_fonts_dir" || exit 1
  wget --output-document Jetendard.zip https://github.com/kuskhan/jetendard/releases/download/v0.1.0/Jetendard-TTF.zip || exit 1
  unzip -oqj Jetendard.zip 'ttf/*' -d . || exit 1
  rm Jetendard.zip || exit 1
  popd || exit 1
fi

# yeomil mono nerd font (Geist Mono + Pretendard, Nerd Fonts patched; no Homebrew cask upstream)
yeomil_fonts_dir="$HOME/Library/Fonts"
mkdir -p "$yeomil_fonts_dir" || exit 1
if [[ ! -f "$yeomil_fonts_dir/YeomilMonoNerdFont-Regular.ttf" ]]; then
  pushd "$yeomil_fonts_dir" || exit 1
  wget --output-document YeomilMono.zip https://github.com/taevel02/yeomil-mono/releases/download/v1.1.2/YeomilMono-NerdFont-TTF.zip || exit 1
  unzip -oq YeomilMono.zip -d . || exit 1
  rm YeomilMono.zip || exit 1
  popd || exit 1
fi

# key repeat
defaults write -g ApplePressAndHoldEnabled -bool false || exit 1
defaults write -g InitialKeyRepeat -int 10 || exit 1 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1 || exit 1 # normal minimum is 2 (30 ms)
