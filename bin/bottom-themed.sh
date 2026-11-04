#!/bin/zsh

for arg in "$@"; do
  [[ "$arg" == -- ]] && break
  if [[ "$arg" == --theme || "$arg" == --theme=* ]]; then
    exec btm "$@"
  fi
done

source "${0:A:h}/terminal-theme.zsh"
[[ "$theme" == light ]] && theme=default-light || theme=default
exec btm --theme "$theme" "$@"
