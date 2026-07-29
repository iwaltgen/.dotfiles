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

[[ -n "$herdr_bin" ]] || fail "herdr 실행 파일을 찾을 수 없습니다"
[[ -x "$mise_bin" ]] || fail "mise 실행 파일을 찾을 수 없습니다"
[[ -n "$pane_id" ]] || fail "활성 Herdr pane 이 없습니다"
[[ -n "$pane_cwd" ]] || fail "활성 pane 디렉터리가 없습니다"

typeset -a jq_command
if [[ -n "${commands[jq]:-}" ]]; then
  jq_command=("${commands[jq]}")
else
  jq_command=("$mise_bin" exec -- jq)
fi

neighbor_json="$(
  "$herdr_bin" pane neighbor --direction left --pane "$pane_id" 2>/dev/null
)" || fail "왼쪽에 pane 이 없습니다"

agent_pane_id="$(
  print -rn -- "$neighbor_json" |
    "${jq_command[@]}" -r '.result.neighbor.neighbor_pane_id // empty'
)" || fail "옆 pane 정보를 읽지 못했습니다"
[[ -n "$agent_pane_id" ]] || fail "왼쪽에 pane 이 없습니다"

agent_json="$("$herdr_bin" pane get "$agent_pane_id" 2>/dev/null)" ||
  fail "$agent_pane_id 를 조회하지 못했습니다"
agent_name="$(
  print -rn -- "$agent_json" | "${jq_command[@]}" -r '.result.pane.agent // empty'
)" || fail "옆 pane 의 에이전트를 읽지 못했습니다"
agent_status="$(
  print -rn -- "$agent_json" | "${jq_command[@]}" -r '.result.pane.agent_status // empty'
)" || fail "옆 pane 의 에이전트 상태를 읽지 못했습니다"
agent_cwd="$(
  print -rn -- "$agent_json" |
    "${jq_command[@]}" -r '.result.pane.foreground_cwd // .result.pane.cwd // empty'
)" || fail "옆 pane 의 디렉터리를 읽지 못했습니다"

case "$agent_name" in
  codex | claude) ;;
  *) fail "왼쪽 pane 이 Codex 도 Claude 도 아닙니다"
esac

case "$agent_status" in
  idle | done) ;;
  *) fail "$agent_name 가 $agent_status 상태입니다. idle 이 될 때까지 기다리세요"
esac

git_root="$(git -C "$pane_cwd" rev-parse --show-toplevel 2>/dev/null)" ||
  fail "Git 저장소가 아닙니다: $pane_cwd"
agent_git_root="$(git -C "$agent_cwd" rev-parse --show-toplevel 2>/dev/null)" ||
  fail "에이전트 pane 이 Git 저장소 안에 있지 않습니다: $agent_cwd"
[[ "$agent_git_root" == "$git_root" ]] || fail "왼쪽 에이전트 pane 이 다른 저장소에 속해 있습니다"

skill_path="$("$mise_bin" exec -- hunk skill path 2>/dev/null)" ||
  fail "Hunk 스킬 경로를 가져오지 못했습니다"
[[ -r "$skill_path" ]] || fail "Hunk 스킬을 읽을 수 없습니다: $skill_path"

# 에이전트로 전달되는 지시문이라 원문을 유지한다.
prompt="Load the Hunk review skill from $skill_path and read it completely before acting. Use that skill to review the active Hunk session for $git_root. Review every current user note in the active Hunk session, apply each actionable change, and report any note you cannot apply. Verify the result and summarize what changed."

"$herdr_bin" pane run "$agent_pane_id" "$prompt" >/dev/null ||
  fail "$agent_name 에 Hunk 리뷰 프롬프트를 보내지 못했습니다"

print -- "herdr-hunk-prompt: $agent_pane_id 의 $agent_name 에 리뷰 요청을 보냈습니다"
