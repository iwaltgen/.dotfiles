#!/bin/zsh

for arg in "$@"; do
  [[ "$arg" == -- ]] && break
  if [[ "$arg" == --theme || "$arg" == --theme=* || "$arg" == --config || "$arg" == --config=* || "$arg" == --config_location || "$arg" == --config_location=* || "$arg" == -C || "$arg" == -C?* ]]; then
    exec btm "$@"
  fi
done

source "${0:A:h}/terminal-theme.zsh"
theme_file="${0:A:h:h}/themes/bottom-$theme.toml"
config_file="$HOME/.config/bottom/bottom.toml"
if [[ ! -f "$config_file" ]]; then
  if [[ $OSTYPE == darwin* && -f "$HOME/Library/Application Support/bottom/bottom.toml" ]]; then
    config_file="$HOME/Library/Application Support/bottom/bottom.toml"
  else
    config_file="${XDG_CONFIG_HOME:-$HOME/.config}/bottom/bottom.toml"
  fi
fi

[[ -f "$config_file" ]] || exec btm --config "$theme_file" "$@"

# 사용자 테마 또는 해석할 수 없는 설정은 bottom이 그대로 처리합니다.
if (( ! $+commands[python3] )) || ! command python3 - "$config_file" <<'PY'
import sys
try:
    import tomllib
    with open(sys.argv[1], "rb") as config_file:
        config = tomllib.load(config_file)
    if "styles" in config or "colors" in config:
        sys.exit(1)
except (ImportError, OSError, ValueError):
    sys.exit(1)
PY
then
  exec btm "$@"
fi

merged_config=$(mktemp "${TMPDIR:-/tmp}/dotfiles-btm.XXXXXXXX") || exit 1
trap 'rm -f -- "$merged_config"' EXIT
cat -- "$config_file" > "$merged_config" || exit 1
print >> "$merged_config" || exit 1
cat -- "$theme_file" >> "$merged_config" || exit 1
btm --config "$merged_config" "$@"
