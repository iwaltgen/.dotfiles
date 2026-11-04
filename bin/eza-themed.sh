#!/bin/zsh

theme=dark
detected=""
if [[ -n ${TMUX:-} && -n ${TMUX_PANE:-} ]] && (( $+commands[tmux] )); then
  detected=$(command tmux display-message -p -t "$TMUX_PANE" '#{client_theme}' 2>/dev/null)
fi

if [[ "$detected" != light && "$detected" != dark ]]; then
  if [[ $OSTYPE == darwin* ]] && (( $+commands[defaults] )); then
    if [[ "$(command defaults read -g AppleInterfaceStyle 2>/dev/null)" == Dark ]]; then
      detected=dark
    else
      detected=light
    fi
  elif [[ $OSTYPE == linux* ]] && (( $+commands[gsettings] )); then
    detected=$(command gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)
    [[ "$detected" == "'prefer-light'" ]] && detected=light
  fi
fi
[[ "$detected" == light ]] && theme=light

env -u LS_COLORS -u EZA_COLORS EZA_CONFIG_DIR="${0:A:h:h}/eza/$theme" eza "$@"
