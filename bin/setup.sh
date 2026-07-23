#!/bin/zsh

if [[ $OSTYPE == darwin* ]]; then
  "$HOME/.dotfiles/bin/prelude.darwin.sh" || exit 1
elif [[ $OSTYPE == linux* ]]; then
  "$HOME/.dotfiles/bin/prelude.linux.sh" || exit 1
fi

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

link_dotfile() {
  local source_path="$1"
  local target_path="$2"

  if [[ ! -e "$source_path" ]]; then
    print -u2 "Link source does not exist: $source_path"
    return 1
  fi

  if [[ -e "$target_path" && ! -L "$target_path" ]]; then
    local backup_date
    local backup_path
    local backup_number=0

    backup_date="$(date +%Y%m%d)" || return 1
    backup_path="${target_path}.bak-${backup_date}"
    while [[ -e "$backup_path" || -L "$backup_path" ]]; do
      (( backup_number += 1 ))
      backup_path="${target_path}.bak-${backup_date}-${backup_number}"
    done

    mv "$target_path" "$backup_path" || return 1
    if ! ln -sfn "$source_path" "$target_path"; then
      if ! mv "$backup_path" "$target_path"; then
        print -u2 "Failed to restore existing path: $target_path"
      fi
      return 1
    fi
    print "Backed up existing path: $target_path -> $backup_path"
    return 0
  fi

  ln -sfn "$source_path" "$target_path"
}

remove_managed_legacy_link() {
  local target_path="$1"
  shift

  [[ -L "$target_path" ]] || return 0

  local current_source
  current_source="$(readlink "$target_path")" || return 1

  local managed_source
  for managed_source in "$@"; do
    if [[ "$current_source" == "$managed_source" ]]; then
      rm "$target_path"
      return
    fi
  done

  return 0
}

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

mkdir -p "$config_home/mise" || exit 1
link_dotfile "$HOME/.dotfiles/mise/config.toml" "$config_home/mise/config.toml" || exit 1

elixir_version="$("$HOME/.local/bin/mise" latest elixir@1.20)" || exit 1
case "$elixir_version" in
  1.20.<->-otp-29) ;;
  *)
    print -u2 "Expected Elixir 1.20.x built for OTP 29, got: $elixir_version"
    exit 1
    ;;
esac

MISE_CEILING_PATHS="$HOME" \
  "$HOME/.local/bin/mise" -C "$HOME" install --yes || exit 1

# dotfiles
mkdir -p \
  "$config_home/atuin" \
  "$config_home/ghostty" \
  "$config_home/herdr" \
  "$config_home/hunk" \
  "$config_home/agents" \
  "$HOME/.local/bin" \
  "$HOME/.claude" \
  "$HOME/.codex" || exit 1

link_dotfile "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc" || exit 1
remove_managed_legacy_link \
  "$HOME/.zshrc.cli" \
  "$HOME/.dotfiles/.zshrc.cli" || exit 1
remove_managed_legacy_link \
  "$HOME/.zshrc.os" \
  "$HOME/.dotfiles/.zshrc.darwin" \
  "$HOME/.dotfiles/.zshrc.linux" || exit 1
link_dotfile "$HOME/.dotfiles/.ideavimrc" "$HOME/.ideavimrc" || exit 1
link_dotfile "$HOME/.dotfiles/nvim" "$config_home/nvim" || exit 1
link_dotfile "$HOME/.dotfiles/atuin/config.toml" "$config_home/atuin/config.toml" || exit 1
link_dotfile "$HOME/.dotfiles/ghostty.conf" "$config_home/ghostty/config" || exit 1
link_dotfile "$HOME/.dotfiles/herdr/config.toml" "$config_home/herdr/config.toml" || exit 1
link_dotfile "$HOME/.dotfiles/hunk/config.toml" "$config_home/hunk/config.toml" || exit 1
link_dotfile "$HOME/.dotfiles/.starship.toml" "$HOME/.starship.toml" || exit 1

link_dotfile "$HOME/.dotfiles/GLOBAL_AGENTS.md" "$config_home/agents/AGENTS.md" || exit 1
link_dotfile "$HOME/.dotfiles/GLOBAL_AGENTS.md" "$HOME/.claude/CLAUDE.md" || exit 1
link_dotfile "$HOME/.dotfiles/GLOBAL_AGENTS.md" "$HOME/.codex/AGENTS.md" || exit 1

if [[ $OSTYPE == darwin* ]]; then
  link_dotfile "$HOME/.dotfiles/bin/idea.darwin.sh" "$HOME/.local/bin/idea" || exit 1
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

print "Setup complete. Open a new terminal to load the updated shell configuration."
