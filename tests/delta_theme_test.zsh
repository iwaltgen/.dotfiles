#!/bin/zsh
set -eu
repo_root=${0:A:h:h}
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin"
cat > "$test_dir/bin/tmux" <<'EOF'
#!/bin/zsh
print -r -- "$TEST_THEME"
EOF
cat > "$test_dir/bin/delta" <<'EOF'
#!/bin/zsh
print -r -- "$*"
EOF
chmod +x "$test_dir/bin/tmux" "$test_dir/bin/delta"
export PATH="$test_dir/bin:/usr/bin:/bin" TMUX=test TMUX_PANE=%1
export TEST_THEME=light
[[ "$(zsh "$repo_root/bin/delta-themed.sh" --paging=never)" == '--features side-by-side line-numbers decorations catppuccin-latte --paging=never' ]]
export TEST_THEME=dark
[[ "$(zsh "$repo_root/bin/delta-themed.sh" --paging=never)" == '--features side-by-side line-numbers decorations catppuccin-mocha --paging=never' ]]
[[ "$(zsh "$repo_root/bin/delta-themed.sh" --features custom)" == '--features custom' ]]
[[ "$(zsh "$repo_root/bin/delta-themed.sh" --features=custom)" == '--features=custom' ]]
print -- 'PASS delta theme'
