#!/bin/zsh

set -eu

[[ "$(uname -s)" == Darwin ]] || exit 0

readonly docs_target="$HOME/syncthing/agents/superpowers/dotfiles"
readonly docs_link="$HOME/.dotfiles/docs/superpowers"

if [[ -L "$docs_link" ]]; then
  if [[ "$(readlink "$docs_link")" == "$docs_target" ]]; then
    exit 0
  fi

  print -u2 -- "Superpowers docs link points elsewhere: $docs_link"
  exit 1
fi

if [[ -e "$docs_link" ]]; then
  print -u2 -- "Superpowers docs path already exists and is not a link: $docs_link"
  exit 1
fi

if [[ ! -d "$docs_target" ]]; then
  print -u2 -- "Syncthing target is not ready; skipping docs link: $docs_target"
  exit 0
fi

mkdir -p "${docs_link:h}"
ln -s "$docs_target" "$docs_link"
