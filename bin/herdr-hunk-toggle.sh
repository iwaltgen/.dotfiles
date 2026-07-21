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

[[ -n "$herdr_bin" ]] || fail "herdr executable is unavailable"
[[ -n "$workspace_id" ]] || fail "no active Herdr workspace"
[[ -n "$tab_id" ]] || fail "no active Herdr tab"

typeset -a jq_command
if [[ -n "${commands[jq]:-}" ]]; then
  jq_command=("${commands[jq]}")
elif [[ -x "$mise_bin" ]]; then
  jq_command=("$mise_bin" exec -- jq)
else
  fail "jq is unavailable"
fi

panes_json="$("$herdr_bin" pane list --workspace "$workspace_id" 2>/dev/null)" ||
  fail "could not list panes in $workspace_id"
[[ -n "$panes_json" ]] || fail "empty pane list for $workspace_id"

existing_panes="$(
  print -rn -- "$panes_json" |
    "${jq_command[@]}" -r --arg label "$pane_label" --arg tab "$tab_id" \
      '.result.panes[]? | select(.label == $label and .tab_id == $tab) | .pane_id'
)" || fail "could not read the pane list"

if [[ -n "$existing_panes" ]]; then
  close_failed=false
  while IFS= read -r existing_pane; do
    [[ -n "$existing_pane" ]] || continue
    "$herdr_bin" pane close "$existing_pane" >/dev/null 2>&1 || close_failed=true
  done <<< "$existing_panes"
  [[ "$close_failed" == false ]] || fail "could not close every $pane_label pane"
  print -- "herdr-hunk: closed $pane_label in $tab_id"
  exit 0
fi

[[ -n "$pane_id" ]] || fail "no active Herdr pane"
[[ -n "$pane_cwd" ]] || fail "no active pane directory"
[[ -x "$mise_bin" ]] || fail "mise is unavailable at $mise_bin"
"$mise_bin" which hunk >/dev/null 2>&1 || fail "hunk is not installed through mise"

git_root="$(git -C "$pane_cwd" rev-parse --show-toplevel 2>/dev/null)" ||
  fail "not a Git repository: $pane_cwd"

split_json="$(
  "$herdr_bin" pane split "$pane_id" \
    --direction right \
    --ratio 0.5 \
    --cwd "$git_root" \
    --no-focus 2>/dev/null
)" || fail "could not open the Hunk pane"

new_pane_id="$(
  print -rn -- "$split_json" |
    "${jq_command[@]}" -r '.result.pane.pane_id // empty'
)" || fail "could not read the new pane id"
[[ -n "$new_pane_id" ]] || fail "Herdr returned no new pane id"

cleanup_new_pane() {
  "$herdr_bin" pane close "$new_pane_id" >/dev/null 2>&1 || true
}

if ! "$herdr_bin" pane rename "$new_pane_id" "$pane_label" >/dev/null 2>&1; then
  cleanup_new_pane
  fail "could not label the Hunk pane"
fi

mise_quoted="${(q)mise_bin}"
hunk_command="exec $mise_quoted exec -- hunk diff --watch"
if ! "$herdr_bin" pane run "$new_pane_id" "$hunk_command" >/dev/null 2>&1; then
  cleanup_new_pane
  fail "could not start Hunk"
fi

print -- "herdr-hunk: opened $new_pane_id in $workspace_id"
