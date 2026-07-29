#!/bin/zsh

set -eu

[[ "$(uname -s)" == Darwin ]] || exit 0

readonly docs_target="$HOME/syncthing/agents/superpowers/dotfiles"
readonly docs_link="$HOME/.dotfiles/docs/superpowers"

if [[ -L "$docs_link" ]]; then
  if [[ "$(readlink "$docs_link")" == "$docs_target" ]]; then
    exit 0
  fi

  print -u2 -- "Superpowers 문서 링크가 다른 곳을 가리킵니다: $docs_link"
  exit 1
fi

if [[ -e "$docs_link" ]]; then
  print -u2 -- "Superpowers 문서 경로가 링크가 아닌 파일로 존재합니다: $docs_link"
  exit 1
fi

if [[ ! -d "$docs_target" ]]; then
  print -u2 -- "Syncthing 대상이 준비되지 않아 문서 링크를 건너뜁니다: $docs_target"
  exit 0
fi

mkdir -p "${docs_link:h}"
ln -s "$docs_target" "$docs_link"
