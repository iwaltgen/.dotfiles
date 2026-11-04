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
cat > "$test_dir/bin/btm" <<'EOF'
#!/bin/zsh
print -r -- "$*"
EOF
chmod +x "$test_dir/bin/tmux" "$test_dir/bin/btm"
export PATH="$test_dir/bin:/usr/bin:/bin" TMUX=test TMUX_PANE=%1
export TEST_THEME=light
[[ "$(zsh "$repo_root/bin/bottom-themed.sh" --basic)" == '--theme default-light --basic' ]]
[[ "$(zsh "$repo_root/bin/bottom-themed.sh" --theme gruvbox)" == '--theme gruvbox' ]]
[[ "$(zsh "$repo_root/bin/bottom-themed.sh" --theme=gruvbox)" == '--theme=gruvbox' ]]
export TEST_THEME=dark
[[ "$(zsh "$repo_root/bin/bottom-themed.sh" --basic)" == '--theme default --basic' ]]
print -- 'PASS bottom theme'
