# 터미널 클라이언트의 모드를 우선하고 확인할 수 없으면 운영체제 설정을 사용합니다.
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
