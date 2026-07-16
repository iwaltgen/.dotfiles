#!/bin/zsh

if [[ $OSTYPE == darwin* ]]; then
  "$HOME/.dotfiles/bin/prelude.darwin.sh" || exit 1
elif [[ $OSTYPE == linux* ]]; then
  "$HOME/.dotfiles/bin/prelude.linux.sh" || exit 1
fi

# tmux plugin manager
git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# mise
if [[ ! -x "$HOME/.local/bin/mise" ]]; then
  curl --fail --show-error --silent --location https://mise.run | sh
fi
if [[ ! -x "$HOME/.local/bin/mise" ]]; then
  print -u2 "mise installation failed"
  exit 1
fi

# Eclipse Temurin 25 is the selected LTS release.
"$HOME/.local/bin/mise" use --global \
  bun \
  node@lts \
  python@3.13 \
  java@temurin-25 \
  go \
  rust \
  deno \
  sd \
  fd \
  bat \
  hyperfine \
  ripgrep \
  delta \
  gdu \
  duf \
  dust \
  gping \
  jq \
  fx \
  zoxide \
  ctop \
  bottom \
  lazygit \
  lazydocker \
  direnv \
  atuin \
  gh \
  neovim \
  fzf \
  starship \
  fastfetch \
  curlie \
  mc \
  tmux || exit 1

# The asdf eza plugin can reference missing cargo-quickinstall assets on macOS.
"$HOME/.local/bin/mise" use --global cargo:eza || exit 1

# macOS standalone CLI tools previously managed by Homebrew
if [[ $OSTYPE == darwin* ]]; then
  "$HOME/.local/bin/mise" use --global \
    act \
    cmake \
    dive \
    git-lfs \
    goreleaser \
    gradle \
    helm \
    maven \
    terraform || exit 1
fi
# mise use --global erlang@26
# mise use --global elixir@1.16

# dotfiles
mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/atuin
mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/ghostty
mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/gh-dash
mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/agents
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.claude
mkdir -p $HOME/.codex

ln -sf $HOME/.dotfiles/.zshrc $HOME
ln -sf $HOME/.dotfiles/.ideavimrc $HOME
ln -sf $HOME/.dotfiles/nvim ${XDG_CONFIG_HOME:-$HOME/.config}/nvim
ln -sf $HOME/.dotfiles/atuin/config.toml ${XDG_CONFIG_HOME:-$HOME/.config}/atuin/config.toml
ln -sf $HOME/.dotfiles/ghostty.conf ${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config
ln -sf $HOME/.dotfiles/gh-dash/config.yml ${XDG_CONFIG_HOME:-$HOME/.config}/gh-dash/config.yml
ln -sf $HOME/.dotfiles/.starship.toml $HOME

ln -sf $HOME/.dotfiles/AGENTS.md ${XDG_CONFIG_HOME:-$HOME/.config}/agents/
ln -sf $HOME/.dotfiles/AGENTS.md $HOME/.claude/CLAUDE.md
ln -sf $HOME/.dotfiles/AGENTS.md $HOME/.codex/

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

source $HOME/.zshrc
