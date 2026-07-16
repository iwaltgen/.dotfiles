#!/bin/zsh

if [[ $OSTYPE == darwin* ]]; then
  "$HOME/.dotfiles/bin/prelude.darwin.sh" || exit 1
elif [[ $OSTYPE == linux* ]]; then
  "$HOME/.dotfiles/bin/prelude.linux.sh" || exit 1
fi

# tmux plugin manager
tpm_dir="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$tpm_dir/.git" ]]; then
  if [[ -e "$tpm_dir" || -L "$tpm_dir" ]]; then
    print -u2 "TPM path exists but is not a Git repository: $tpm_dir"
    exit 1
  fi
  mkdir -p "${tpm_dir:h}" || exit 1
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir" || exit 1
fi

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
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p \
  "$config_home/atuin" \
  "$config_home/ghostty" \
  "$config_home/gh-dash" \
  "$config_home/herdr" \
  "$config_home/agents" \
  "$HOME/.local/bin" \
  "$HOME/.claude" \
  "$HOME/.codex" || exit 1

link_dotfile() {
  local source_path="$1"
  local target_path="$2"

  if [[ -e "$target_path" && ! -L "$target_path" ]]; then
    print -u2 "Refusing to replace existing path: $target_path"
    return 1
  fi
  ln -sfn "$source_path" "$target_path"
}

link_dotfile "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc" || exit 1
link_dotfile "$HOME/.dotfiles/.ideavimrc" "$HOME/.ideavimrc" || exit 1
link_dotfile "$HOME/.dotfiles/nvim" "$config_home/nvim" || exit 1
link_dotfile "$HOME/.dotfiles/atuin/config.toml" "$config_home/atuin/config.toml" || exit 1
link_dotfile "$HOME/.dotfiles/ghostty.conf" "$config_home/ghostty/config" || exit 1
link_dotfile "$HOME/.dotfiles/gh-dash/config.yml" "$config_home/gh-dash/config.yml" || exit 1
link_dotfile "$HOME/.dotfiles/herdr/config.toml" "$config_home/herdr/config.toml" || exit 1
link_dotfile "$HOME/.dotfiles/.starship.toml" "$HOME/.starship.toml" || exit 1

link_dotfile "$HOME/.dotfiles/AGENTS.md" "$config_home/agents/AGENTS.md" || exit 1
link_dotfile "$HOME/.dotfiles/AGENTS.md" "$HOME/.claude/CLAUDE.md" || exit 1
link_dotfile "$HOME/.dotfiles/AGENTS.md" "$HOME/.codex/AGENTS.md" || exit 1

if [[ $OSTYPE == darwin* ]]; then
  link_dotfile "$HOME/.dotfiles/.zshrc.darwin" "$HOME/.zshrc.os" || exit 1
  link_dotfile "$HOME/.dotfiles/bin/idea.darwin.sh" "$HOME/.local/bin/idea" || exit 1
elif [[ $OSTYPE == linux* ]]; then
  link_dotfile "$HOME/.dotfiles/.zshrc.linux" "$HOME/.zshrc.os" || exit 1
fi

link_dotfile "$HOME/.dotfiles/.tmux.conf" "$HOME/.tmux.conf" || exit 1
link_dotfile "$HOME/.dotfiles/.tmux.theme.conf" "$HOME/.tmux.theme.conf" || exit 1
link_dotfile "$HOME/.dotfiles/.tmux.user.conf" "$HOME/.tmux.user.conf" || exit 1

# git
link_dotfile "$HOME/.dotfiles/.gitconfig" "$HOME/.gitconfig" || exit 1

# gpg
mkdir -p "$HOME/.gnupg" || exit 1
chmod 700 "$HOME/.gnupg" || exit 1
link_dotfile "$HOME/.dotfiles/.gnupg/gpg.conf" "$HOME/.gnupg/gpg.conf" || exit 1
link_dotfile "$HOME/.dotfiles/.gnupg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf" || exit 1

# ntfs
mkdir -p "$HOME/.ntfs" || exit 1

source "$HOME/.zshrc"
