#!/bin/zsh
set -eu
repo_root=${0:A:h:h}
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin" "$test_dir/home"
cat > "$test_dir/bin/eza" <<'EOF'
#!/bin/zsh
print -r -- "${EZA_CONFIG_DIR:t}|${LS_COLORS-unset}|${EZA_COLORS-unset}|$*"
EOF
cat > "$test_dir/bin/tmux" <<'EOF'
#!/bin/zsh
print -r -- "$TEST_THEME"
EOF
chmod +x "$test_dir/bin/eza" "$test_dir/bin/tmux"
export PATH="$test_dir/bin:/usr/bin:/bin" HOME="$test_dir/home" TMUX=test TMUX_PANE=%1
export LS_COLORS='di=31' EZA_COLORS='di=32'
for theme in light dark; do
  export TEST_THEME="$theme"
  actual=$(zsh "$repo_root/bin/eza-themed.sh" --tree)
  [[ "$actual" == "$theme|unset|unset|--tree" ]] || {
    print -u2 -- "테마 선택 실패: $actual"
    exit 1
  }
done
print -- 'PASS eza theme'
