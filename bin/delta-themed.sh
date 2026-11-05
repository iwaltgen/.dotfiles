#!/bin/zsh
for arg in "$@"; do
  [[ "$arg" == -- ]] && break
  if [[ "$arg" == --features || "$arg" == --features=* ]]; then
    exec delta "$@"
  fi
done
source "${0:A:h}/terminal-theme.zsh"
flavour=mocha
[[ "$theme" == light ]] && flavour=latte
exec delta --features "side-by-side line-numbers decorations catppuccin-$flavour" "$@"
