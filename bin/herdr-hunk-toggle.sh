#!/bin/zsh

set -u

readonly pane_label="hunk-watch"
readonly mise_bin="$HOME/.local/bin/mise"

fail() {
  print -u2 -- "herdr-hunk: $1"
  exit 1
}

export PATH="${PATH:-}:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

herdr_bin="${HERDR_BIN_PATH:-${commands[herdr]:-}}"
workspace_id="${HERDR_ACTIVE_WORKSPACE_ID:-${HERDR_WORKSPACE_ID:-}}"
tab_id="${HERDR_ACTIVE_TAB_ID:-${HERDR_TAB_ID:-}}"
pane_id="${HERDR_ACTIVE_PANE_ID:-${HERDR_PANE_ID:-}}"
pane_cwd="${HERDR_ACTIVE_PANE_CWD:-${PWD:-}}"

[[ -n "$herdr_bin" ]] || fail "herdr 실행 파일을 찾을 수 없습니다"
[[ -n "$workspace_id" ]] || fail "활성 Herdr 워크스페이스가 없습니다"
[[ -n "$tab_id" ]] || fail "활성 Herdr 탭이 없습니다"

typeset -a jq_command
if [[ -n "${commands[jq]:-}" ]]; then
  jq_command=("${commands[jq]}")
elif [[ -x "$mise_bin" ]]; then
  jq_command=("$mise_bin" exec -- jq)
else
  fail "jq 를 찾을 수 없습니다"
fi

panes_json="$("$herdr_bin" pane list --workspace "$workspace_id" 2>/dev/null)" ||
  fail "$workspace_id 의 pane 목록을 가져오지 못했습니다"
[[ -n "$panes_json" ]] || fail "$workspace_id 의 pane 목록이 비어 있습니다"

existing_panes="$(
  print -rn -- "$panes_json" |
    "${jq_command[@]}" -r --arg label "$pane_label" --arg tab "$tab_id" \
      '.result.panes[]? | select(.label == $label and .tab_id == $tab) | .pane_id'
)" || fail "pane 목록을 읽지 못했습니다"

if [[ -n "$existing_panes" ]]; then
  close_failed=false
  while IFS= read -r existing_pane; do
    [[ -n "$existing_pane" ]] || continue
    "$herdr_bin" pane close "$existing_pane" >/dev/null 2>&1 || close_failed=true
  done <<< "$existing_panes"
  [[ "$close_failed" == false ]] || fail "$pane_label pane 을 모두 닫지 못했습니다"
  print -- "herdr-hunk: $tab_id 의 $pane_label 을 닫았습니다"
  exit 0
fi

[[ -n "$pane_id" ]] || fail "활성 Herdr pane 이 없습니다"
[[ -n "$pane_cwd" ]] || fail "활성 pane 디렉터리가 없습니다"
[[ -x "$mise_bin" ]] || fail "$mise_bin 에서 mise 를 찾을 수 없습니다"
hunk_bin="$("$mise_bin" which hunk 2>/dev/null)" ||
  fail "mise 에 hunk 가 설치되어 있지 않습니다"
[[ -n "$hunk_bin" ]] || fail "mise 에 hunk 가 설치되어 있지 않습니다"

git_root="$(git -C "$pane_cwd" rev-parse --show-toplevel 2>/dev/null)" ||
  fail "Git 저장소가 아닙니다: $pane_cwd"

split_json="$(
  "$herdr_bin" pane split "$pane_id" \
    --direction right \
    --ratio 0.5 \
    --cwd "$git_root" \
    --env "HERDR_EXEC=$hunk_bin diff --watch" \
    --no-focus 2>/dev/null
)" || fail "Hunk pane 을 열지 못했습니다"

new_pane_id="$(
  print -rn -- "$split_json" |
    "${jq_command[@]}" -r '.result.pane.pane_id // empty'
)" || fail "새 pane id 를 읽지 못했습니다"
[[ -n "$new_pane_id" ]] || fail "Herdr 가 새 pane id 를 반환하지 않았습니다"

cleanup_new_pane() {
  "$herdr_bin" pane close "$new_pane_id" >/dev/null 2>&1 || true
}

if ! "$herdr_bin" pane rename "$new_pane_id" "$pane_label" >/dev/null 2>&1; then
  cleanup_new_pane
  fail "Hunk pane 에 이름을 붙이지 못했습니다"
fi

# Hunk 는 ~/.zshrc 의 HERDR_EXEC 빠른 경로로 시작한다. 새 pane 의 셸이
# `hunk diff --watch` 를 직접 exec 해 대화형 초기화(~325ms)를 건너뛴다.
print -- "herdr-hunk: $workspace_id 에 $new_pane_id 를 열었습니다"
