#!/bin/zsh
set -eu

repo_root=${0:A:h:h}
test_dir=$(mktemp -d)
socket="dotfiles-theme-$$"
tmux_bin=${commands[tmux]}
cleanup() {
  "$tmux_bin" -L "$socket" kill-server 2>/dev/null || true
  rm -rf "$test_dir"
}
trap cleanup EXIT

mkdir -p "$test_dir/home"
ln -s "$repo_root/.tmux.conf" "$test_dir/home/.tmux.conf"
ln -s "$repo_root/.tmux.theme.conf" "$test_dir/home/.tmux.theme.conf"
touch "$test_dir/home/.tmux.user.conf"
export HOME="$test_dir/home"
unset TMUX

"$tmux_bin" -L "$socket" new-session -d -s test
"$tmux_bin" -L "$socket" set-hook -R client-light-theme
light_style=$("$tmux_bin" -L "$socket" show -gv status-style)
light_left=$("$tmux_bin" -L "$socket" show -gv status-left)
[[ "$light_style" == *'#eff1f5'* && "$light_left" == *'#eff1f5'* ]] || {
  print -u2 -- "밝은 테마가 상태 표시줄에 적용되지 않았습니다: $light_style"
  exit 1
}
"$tmux_bin" -L "$socket" set-hook -R client-dark-theme
dark_style=$("$tmux_bin" -L "$socket" show -gv status-style)
dark_left=$("$tmux_bin" -L "$socket" show -gv status-left)
[[ "$dark_style" == *'#1e1e2e'* && "$dark_left" == *'#1e1e2e'* ]] || {
  print -u2 -- "어두운 테마가 상태 표시줄에 적용되지 않았습니다: $dark_style"
  exit 1
}
[[ "$light_left" == *'#S'* && "$dark_left" == *'#S'* ]] || {
  print -u2 -- '상태 표시줄의 세션 표시가 사라졌습니다'
  exit 1
}
print -- 'PASS tmux theme'
