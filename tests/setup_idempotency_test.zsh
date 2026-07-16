#!/bin/zsh

set -eu

readonly repo_root="${0:A:h:h}"
typeset -g test_sandbox=""

cleanup() {
  [[ -z "$test_sandbox" ]] || rm -rf "$test_sandbox"
}
trap cleanup EXIT

fail() {
  print -u2 -- "FAIL: $1"
  return 1
}

write_executable() {
  local file_path="$1"
  local content="$2"

  mkdir -p "${file_path:h}"
  print -r -- "$content" > "$file_path"
  chmod +x "$file_path"
}

assert_symlink() {
  local link_path="$1"
  local expected="$2"

  [[ -L "$link_path" ]] || fail "$link_path is not a symbolic link"
  [[ "$(readlink "$link_path")" == "$expected" ]] || \
    fail "$link_path does not point to $expected"
}

assert_call_count() {
  local pattern="$1"
  local expected="$2"
  local actual

  actual="$(grep -Ec "$pattern" "$test_sandbox/calls.log" || true)"
  [[ "$actual" == "$expected" ]] || \
    fail "call count for '$pattern': expected $expected, got $actual"
}

prepare_setup_sandbox() {
  test_sandbox="$(mktemp -d)"

  local home="$test_sandbox/home"
  local dotfiles="$home/.dotfiles"
  local fake_bin="$test_sandbox/bin"

  mkdir -p \
    "$dotfiles/bin" \
    "$dotfiles/nvim" \
    "$dotfiles/atuin" \
    "$dotfiles/gh-dash" \
    "$dotfiles/.gnupg" \
    "$home/.local/bin" \
    "$fake_bin"

  cp "$repo_root/bin/setup.sh" "$dotfiles/bin/setup.sh"

  touch \
    "$dotfiles/.zshrc" \
    "$dotfiles/.zshrc.darwin" \
    "$dotfiles/.zshrc.linux" \
    "$dotfiles/.ideavimrc" \
    "$dotfiles/.starship.toml" \
    "$dotfiles/.tmux.conf" \
    "$dotfiles/.tmux.theme.conf" \
    "$dotfiles/.tmux.user.conf" \
    "$dotfiles/.gitconfig" \
    "$dotfiles/AGENTS.md" \
    "$dotfiles/ghostty.conf" \
    "$dotfiles/atuin/config.toml" \
    "$dotfiles/gh-dash/config.yml" \
    "$dotfiles/.gnupg/gpg.conf" \
    "$dotfiles/.gnupg/gpg-agent.conf" \
    "$dotfiles/bin/idea.darwin.sh"

  write_executable "$dotfiles/bin/prelude.darwin.sh" '#!/bin/zsh
exit 0'
  write_executable "$dotfiles/bin/prelude.linux.sh" '#!/bin/zsh
exit 0'

  write_executable "$home/.local/bin/mise" '#!/bin/zsh
print -r -- "mise $*" >> "$CALLS_LOG"'

  write_executable "$fake_bin/git" '#!/bin/zsh
print -r -- "git $*" >> "$CALLS_LOG"
if [[ "$1" == clone ]]; then
  target="${argv[-1]}"
  [[ ! -e "$target" ]] || exit 17
  mkdir -p "$target/.git"
fi'
}

run_setup() {
  local home="$test_sandbox/home"

  HOME="$home" \
    XDG_CONFIG_HOME="$home/.config" \
    CALLS_LOG="$test_sandbox/calls.log" \
    PATH="$test_sandbox/bin:/usr/bin:/bin" \
    /bin/zsh "$home/.dotfiles/bin/setup.sh"
}

test_setup_runs_twice() {
  prepare_setup_sandbox

  run_setup
  run_setup

  local home="$test_sandbox/home"
  local clone_count
  clone_count="$(grep -c '^git clone .*tmux-plugins/tpm' "$test_sandbox/calls.log")"

  [[ "$clone_count" == 1 ]] || fail "TPM clone ran $clone_count times"
  [[ -d "$home/.ntfs" ]] || fail "$home/.ntfs was not created"
  assert_symlink "$home/.config/nvim" "$home/.dotfiles/nvim"
  [[ ! -e "$home/.dotfiles/nvim/nvim" ]] || fail "nested nvim link was created"
}

test_setup_preserves_existing_file() {
  prepare_setup_sandbox

  print 'personal config' > "$test_sandbox/home/.gitconfig"

  if run_setup > "$test_sandbox/conflict.log" 2>&1; then
    fail 'setup replaced an existing regular file'
  fi
  grep -Fq 'Refusing to replace existing path:' "$test_sandbox/conflict.log" || \
    fail 'setup did not report the conflicting path'
  [[ "$(< "$test_sandbox/home/.gitconfig")" == 'personal config' ]] || \
    fail 'existing regular file content changed'
}

prepare_prelude_sandbox() {
  test_sandbox="$(mktemp -d)"

  local home="$test_sandbox/home"
  local dotfiles="$home/.dotfiles"
  local fake_bin="$test_sandbox/bin"
  local zdotdir="$test_sandbox/zdot"

  mkdir -p "$dotfiles/bin" "$dotfiles/brew" "$fake_bin" "$zdotdir"
  cp "$repo_root/bin/prelude.darwin.sh" "$dotfiles/bin/prelude.darwin.sh"
  cp "$repo_root/bin/prelude.linux.sh" "$dotfiles/bin/prelude.linux.sh"
  touch "$test_sandbox/calls.log" "$test_sandbox/fonts.list"

  write_executable "$fake_bin/brew" '#!/bin/zsh
print -r -- "brew-bin $*" >> "$CALLS_LOG"'
  write_executable "$fake_bin/zsh" '#!/bin/zsh
exit 0'

  print -r -- 'brew() {
  print -r -- "brew $*" >> "$CALLS_LOG"
}

curl() {
  print ':'
}

git() {
  print -r -- "git $*" >> "$CALLS_LOG"
  if [[ "$1" == clone ]]; then
    local target="${argv[-1]}"
    [[ ! -e "$target" ]] || return 17
    mkdir -p "$target/.git"
  fi
}

zsh() {
  print -r -- "zinit install" >> "$CALLS_LOG"
  mkdir -p "$HOME/.local/share/zinit/zinit.git"
  touch "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
}

chsh() {
  print -r -- "chsh $*" >> "$CALLS_LOG"
}

dscl() {
  print -r -- "UserShell: /bin/zsh"
}

getent() {
  print -r -- "$USER:x:501:20::${HOME}:${commands[zsh]}"
}

defaults() {
  print -r -- "defaults $*" >> "$CALLS_LOG"
}

sudo() {
  print -r -- "sudo $*" >> "$CALLS_LOG"
}

wget() {
  print -r -- "wget $*" >> "$CALLS_LOG"
  if [[ "$*" == *Hack.zip* ]]; then
    touch Hack.zip
  elif [[ "$*" == *D2Coding.zip* ]]; then
    touch D2Coding.zip
  fi
}

unzip() {
  print -r -- "unzip $*" >> "$CALLS_LOG"
  if [[ "$*" == *Hack.zip* ]]; then
    print "Hack Nerd Font" >> "$FONTS_LIST"
  elif [[ "$*" == *D2Coding.zip* ]]; then
    print "D2CodingLigature Nerd Font" >> "$FONTS_LIST"
  fi
}

fc-list() {
  command cat "$FONTS_LIST"
}

fc-cache() {
  print -r -- "fc-cache $*" >> "$CALLS_LOG"
}' > "$zdotdir/.zshenv"
}

run_prelude() {
  local platform="$1"
  local home="$test_sandbox/home"

  HOME="$home" \
    USER=tester \
    CALLS_LOG="$test_sandbox/calls.log" \
    FONTS_LIST="$test_sandbox/fonts.list" \
    ZDOTDIR="$test_sandbox/zdot" \
    PATH="$test_sandbox/bin:/usr/bin:/bin" \
    /bin/zsh "$home/.dotfiles/bin/prelude.$platform.sh"
}

test_darwin_prelude_runs_twice() {
  prepare_prelude_sandbox

  run_prelude darwin
  run_prelude darwin

  assert_call_count '^git clone .*ohmyzsh' 1
  assert_call_count '^zinit install$' 1
  assert_call_count '^chsh ' 0
  assert_call_count '^brew install wget git tree htop$' 2
  assert_call_count '^brew install zsh ' 0
  assert_call_count '^defaults write ' 6
}

test_linux_prelude_runs_twice() {
  prepare_prelude_sandbox

  run_prelude linux
  run_prelude linux

  assert_call_count '^git clone .*ohmyzsh' 1
  assert_call_count '^zinit install$' 1
  assert_call_count '^chsh ' 0
  assert_call_count '^wget .*Hack.zip' 1
  assert_call_count '^wget .*D2Coding.zip' 1
  assert_call_count '^sudo add-apt-repository --yes ppa:git-core/ppa$' 2
}

run_test() {
  local name="$1"

  case "$name" in
    setup)
      test_setup_runs_twice
      cleanup
      test_sandbox=""
      test_setup_preserves_existing_file
      ;;
    darwin)
      test_darwin_prelude_runs_twice
      ;;
    linux)
      test_linux_prelude_runs_twice
      ;;
    *)
      fail "unknown test: $name"
      ;;
  esac
  print "PASS $name"
}

case "${1:-all}" in
  all)
    for test_name in setup darwin linux; do
      run_test "$test_name"
      cleanup
      test_sandbox=""
    done
    ;;
  setup | darwin | linux)
    run_test "$1"
    ;;
  *)
    fail "unknown test: $1"
    ;;
esac
