#!/bin/zsh

set -u

fail() {
  print -u2 -- "herdr-hunk-prompt: $1"
  exit 1
}

export PATH="${PATH:-}:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

herdr_bin="${HERDR_BIN_PATH:-${commands[herdr]:-}}"
readonly mise_bin="$HOME/.local/bin/mise"
pane_id="${HERDR_ACTIVE_PANE_ID:-${HERDR_PANE_ID:-}}"
pane_cwd="${HERDR_ACTIVE_PANE_CWD:-${PWD:-}}"

[[ -n "$herdr_bin" ]] || fail "herdr executable is unavailable"
[[ -x "$mise_bin" ]] || fail "mise executable is unavailable"
[[ -n "$pane_id" ]] || fail "no active Herdr pane"
[[ -n "$pane_cwd" ]] || fail "no active pane directory"

typeset -a jq_command
if [[ -n "${commands[jq]:-}" ]]; then
  jq_command=("${commands[jq]}")
else
  jq_command=("$mise_bin" exec -- jq)
fi

neighbor_json="$(
  "$herdr_bin" pane neighbor --direction left --pane "$pane_id" 2>/dev/null
)" || fail "no pane exists to the left"

agent_pane_id="$(
  print -rn -- "$neighbor_json" |
    "${jq_command[@]}" -r '.result.neighbor.neighbor_pane_id // empty'
)" || fail "could not read the neighboring pane"
[[ -n "$agent_pane_id" ]] || fail "no pane exists to the left"

agent_json="$("$herdr_bin" pane get "$agent_pane_id" 2>/dev/null)" ||
  fail "could not inspect $agent_pane_id"
agent_name="$(
  print -rn -- "$agent_json" | "${jq_command[@]}" -r '.result.pane.agent // empty'
)" || fail "could not read the neighboring agent"
agent_status="$(
  print -rn -- "$agent_json" | "${jq_command[@]}" -r '.result.pane.agent_status // empty'
)" || fail "could not read the neighboring agent status"
agent_cwd="$(
  print -rn -- "$agent_json" |
    "${jq_command[@]}" -r '.result.pane.foreground_cwd // .result.pane.cwd // empty'
)" || fail "could not read the neighboring pane directory"

case "$agent_name" in
  codex | claude) ;;
  *) fail "left pane is not Codex or Claude"
esac

case "$agent_status" in
  idle | done) ;;
  *) fail "$agent_name is $agent_status; wait until it is idle"
esac

git_root="$(git -C "$pane_cwd" rev-parse --show-toplevel 2>/dev/null)" ||
  fail "not a Git repository: $pane_cwd"
agent_git_root="$(git -C "$agent_cwd" rev-parse --show-toplevel 2>/dev/null)" ||
  fail "agent pane is not in a Git repository: $agent_cwd"
[[ "$agent_git_root" == "$git_root" ]] || fail "left agent pane belongs to another repository"

skill_path="$("$mise_bin" exec -- hunk skill path 2>/dev/null)" ||
  fail "could not get the Hunk skill path"
[[ -r "$skill_path" ]] || fail "Hunk skill is not readable: $skill_path"

prompt="Load the Hunk review skill from $skill_path and read it completely before acting. Use that skill to review the active Hunk session for $git_root. Review every current user note in the active Hunk session, apply each actionable change, and report any note you cannot apply. Verify the result and summarize what changed."

"$herdr_bin" pane run "$agent_pane_id" "$prompt" >/dev/null ||
  fail "could not send the Hunk review prompt to $agent_name"

print -- "herdr-hunk-prompt: sent review request to $agent_name in $agent_pane_id"
