#!/bin/zsh
set -eu
repo_root=${0:A:h:h}
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin" "$test_dir/home"
cat > "$test_dir/bin/tmux" <<'EOF'
#!/bin/zsh
print -r -- "$TEST_THEME"
EOF
cat > "$test_dir/bin/btm" <<'EOF'
#!/bin/zsh
[[ -z ${FAKE_BTM_ERROR:-} ]] || exit "$FAKE_BTM_ERROR"
if [[ -n ${CAPTURE_PATH:-} && "$1" == --config ]]; then
  print -r -- "$2"
  exit
fi
if [[ -n ${CAPTURE_CONFIG:-} && "$1" == --config ]]; then
  cat "$2"
  exit
fi
print -r -- "$*"
EOF
chmod +x "$test_dir/bin/tmux" "$test_dir/bin/btm"
ln -s "${commands[python3]}" "$test_dir/bin/python3"
export PATH="$test_dir/bin:/usr/bin:/bin" HOME="$test_dir/home" TMUX=test TMUX_PANE=%1
export TEST_THEME=light
[[ "$(zsh "$repo_root/bin/bottom-themed.sh" --basic)" == "--config $repo_root/themes/bottom-light.toml --basic" ]]
[[ "$(zsh "$repo_root/bin/bottom-themed.sh" --theme gruvbox)" == '--theme gruvbox' ]]
[[ "$(zsh "$repo_root/bin/bottom-themed.sh" --theme=gruvbox)" == '--theme=gruvbox' ]]
[[ "$(zsh "$repo_root/bin/bottom-themed.sh" --config custom.toml)" == '--config custom.toml' ]]
[[ "$(zsh "$repo_root/bin/bottom-themed.sh" --config_location custom.toml)" == '--config_location custom.toml' ]]
[[ "$(zsh "$repo_root/bin/bottom-themed.sh" --config_location=custom.toml)" == '--config_location=custom.toml' ]]
[[ "$(zsh "$repo_root/bin/bottom-themed.sh" -C custom.toml)" == '-C custom.toml' ]]
mkdir -p "$HOME/.config/bottom"
print '[flags]\nbasic = true' > "$HOME/.config/bottom/bottom.toml"
merged=$(CAPTURE_CONFIG=1 zsh "$repo_root/bin/bottom-themed.sh" --basic)
[[ "$merged" == *'basic = true'* && "$merged" == *'[styles.cpu]'* ]] || {
  print -u2 -- 'bottom 사용자 설정과 테마가 함께 적용되지 않았습니다'
  exit 1
}
MERGED_CONFIG="$merged" python3 -c 'import os, tomllib; c = tomllib.loads(os.environ["MERGED_CONFIG"]); assert c["flags"]["basic"] and "cpu" in c["styles"]'
temp_path=$(CAPTURE_PATH=1 zsh "$repo_root/bin/bottom-themed.sh" --basic)
[[ ! -e "$temp_path" ]] || {
  print -u2 -- 'bottom 임시 설정이 정리되지 않았습니다'
  exit 1
}
mkdir -p "$test_dir/temp"
if TMPDIR="$test_dir/temp" FAKE_BTM_ERROR=42 zsh "$repo_root/bin/bottom-themed.sh" --basic; then
  print -u2 -- 'bottom 실패 상태가 전달되지 않았습니다'
  exit 1
else
  [[ $? == 42 ]] || exit 1
fi
[[ -z "$(ls -A "$test_dir/temp")" ]] || {
  print -u2 -- 'bottom 실패 후 임시 설정이 정리되지 않았습니다'
  exit 1
}
print '[styles.widgets]\ntext = { color = "red" }' > "$HOME/.config/bottom/bottom.toml"
[[ "$(zsh "$repo_root/bin/bottom-themed.sh" --basic)" == '--basic' ]] || {
  print -u2 -- 'bottom 사용자 테마가 우선되지 않았습니다'
  exit 1
}
rm "$HOME/.config/bottom/bottom.toml"
export TEST_THEME=dark
[[ "$(zsh "$repo_root/bin/bottom-themed.sh" --basic)" == "--config $repo_root/themes/bottom-dark.toml --basic" ]]
print -- 'PASS bottom theme'
