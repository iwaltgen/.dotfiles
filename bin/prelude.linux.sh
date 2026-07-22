#!/bin/zsh

# essential cli tools
sudo add-apt-repository --yes ppa:git-core/ppa || exit 1
sudo apt-get update || exit 1
sudo apt-get install --yes \
	zsh ca-certificates lsb-release gnupg \
	fontconfig curl wget unzip htop git libnss3-tools \
	build-essential make || exit 1

oh_my_zsh_dir="$HOME/.oh-my-zsh"
if [[ ! -d "$oh_my_zsh_dir/.git" ]]; then
  if [[ -e "$oh_my_zsh_dir" || -L "$oh_my_zsh_dir" ]]; then
    print -u2 "Oh My Zsh path exists but is not a Git repository: $oh_my_zsh_dir"
    exit 1
  fi
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$oh_my_zsh_dir" || exit 1
fi

zsh_path="${commands[zsh]}"
current_shell="$(getent passwd "$USER" | cut -d: -f7)"
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

# fonts
fonts_dir="$HOME/.local/share/fonts"
mkdir -p "$fonts_dir" || exit 1
pushd "$fonts_dir" || exit 1

fonts_changed=false
if ! fc-list : family | grep -Fqi 'Hack Nerd Font'; then
  wget --output-document Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip || exit 1
  unzip -oq Hack.zip -d . || exit 1
  rm Hack.zip || exit 1
  fonts_changed=true
fi

if ! fc-list : family | grep -Eqi 'D2Coding.*Nerd Font'; then
  wget --output-document D2Coding.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/D2Coding.zip || exit 1
  unzip -oq D2Coding.zip -d . || exit 1
  rm D2Coding.zip || exit 1
  fonts_changed=true
fi

if [[ "$fonts_changed" == true ]]; then
  fc-cache -fv || exit 1
fi

popd || exit 1

# AppImage
sudo add-apt-repository --yes universe || exit 1
sudo apt-get install --yes libfuse2 || exit 1
