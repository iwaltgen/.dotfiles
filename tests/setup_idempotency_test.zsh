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
    "$dotfiles/herdr" \
    "$dotfiles/hunk" \
    "$dotfiles/mise" \
    "$dotfiles/.gnupg" \
    "$home/.local/bin" \
    "$fake_bin"

  cp "$repo_root/bin/setup.sh" "$dotfiles/bin/setup.sh"
  cp "$repo_root/mise/config.toml" "$dotfiles/mise/config.toml"

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
    "$dotfiles/GLOBAL_AGENTS.md" \
    "$dotfiles/ghostty.conf" \
    "$dotfiles/atuin/config.toml" \
    "$dotfiles/herdr/config.toml" \
    "$dotfiles/hunk/config.toml" \
    "$dotfiles/.gnupg/gpg.conf" \
    "$dotfiles/.gnupg/gpg-agent.conf" \
    "$dotfiles/bin/idea.darwin.sh"

  write_executable "$dotfiles/bin/prelude.darwin.sh" '#!/bin/zsh
exit 0'
  write_executable "$dotfiles/bin/prelude.linux.sh" '#!/bin/zsh
exit 0'

  write_executable "$home/.local/bin/mise" '#!/bin/zsh
print -r -- "mise $*" >> "$CALLS_LOG"

if [[ "$1" == "-C" ]]; then
  print -r -- "mise install-context cd=$2 ceiling=${MISE_CEILING_PATHS:-}" >> "$CALLS_LOG"
  shift 2
fi

if [[ "$1 $2" == "latest elixir@1.20" ]]; then
  print -r -- "${MISE_FAKE_ELIXIR_LATEST:-1.20.2-otp-29}"
  exit 0
fi

if [[ "$1 $2" == "install --yes" ]]; then
  [[ "${MISE_FAKE_FAIL_INSTALL:-0}" != 1 ]]
  exit
fi'

  write_executable "$fake_bin/date" '#!/bin/zsh
print 20260716'

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
    MISE_FAKE_ELIXIR_LATEST="${MISE_FAKE_ELIXIR_LATEST:-1.20.2-otp-29}" \
    MISE_FAKE_FAIL_INSTALL="${MISE_FAKE_FAIL_INSTALL:-0}" \
    PATH="$test_sandbox/bin:/usr/bin:/bin" \
    /bin/zsh "$home/.dotfiles/bin/setup.sh"
}

test_setup_runs_twice() {
  prepare_setup_sandbox

  local home="$test_sandbox/home"
  local clone_count
  local elixir_check_line
  local install_line

  run_setup
  run_setup

  clone_count="$(grep -c '^git clone .*tmux-plugins/tpm' "$test_sandbox/calls.log")"
  elixir_check_line="$(grep -n -m1 '^mise latest elixir@1.20$' "$test_sandbox/calls.log" | cut -d: -f1 || true)"
  install_line="$(grep -n -m1 '^mise -C .*/home install --yes$' "$test_sandbox/calls.log" | cut -d: -f1 || true)"

  [[ "$clone_count" == 1 ]] || fail "TPM clone ran $clone_count times"
  [[ -n "$elixir_check_line" && -n "$install_line" ]] || \
    fail 'one or more required mise setup stages were not called'
  (( elixir_check_line < install_line )) || fail 'mise install ran before the Elixir compatibility check'
  assert_call_count '^mise latest elixir@1\.20$' 2
  assert_call_count '^mise -C .*/home install --yes$' 2
  assert_call_count '^mise use ' 0
  assert_call_count '^mise settings set ' 0
  grep -Fxq "mise install-context cd=$home ceiling=$home" "$test_sandbox/calls.log" || \
    fail 'mise install does not isolate global config discovery from the caller directory'
  assert_symlink "$home/.config/mise/config.toml" "$home/.dotfiles/mise/config.toml"
  [[ -d "$home/.ntfs" ]] || fail "$home/.ntfs was not created"
  assert_symlink "$home/.config/nvim" "$home/.dotfiles/nvim"
  assert_symlink "$home/.config/herdr/config.toml" "$home/.dotfiles/herdr/config.toml"
  assert_symlink "$home/.config/hunk/config.toml" "$home/.dotfiles/hunk/config.toml"
  assert_symlink "$home/.config/agents/AGENTS.md" "$home/.dotfiles/GLOBAL_AGENTS.md"
  assert_symlink "$home/.claude/CLAUDE.md" "$home/.dotfiles/GLOBAL_AGENTS.md"
  assert_symlink "$home/.codex/AGENTS.md" "$home/.dotfiles/GLOBAL_AGENTS.md"
  [[ ! -e "$home/.dotfiles/nvim/nvim" ]] || fail "nested nvim link was created"
}

test_setup_does_not_source_shell_config() {
  prepare_setup_sandbox

  local home="$test_sandbox/home"
  local output
  print 'return 42' > "$home/.dotfiles/.zshrc"

  if ! output="$(run_setup)"; then
    fail 'setup sourced the interactive shell config'
  fi
  [[ "$output" == *'Setup complete. Open a new terminal to load the updated shell configuration.'* ]] || \
    fail 'setup does not tell the user to open a new terminal'
}

test_setup_rejects_missing_link_source() {
  prepare_setup_sandbox

  local home="$test_sandbox/home"
  rm "$home/.dotfiles/mise/config.toml"

  if run_setup 2>/dev/null; then
    fail 'setup succeeded with a missing mise config source'
  fi
  [[ ! -L "$home/.config/mise/config.toml" ]] || \
    fail 'setup created a dangling mise config link'
  assert_call_count '^mise latest elixir@1\.20$' 0
  assert_call_count '^mise -C .*/home install --yes$' 0
}

test_setup_stops_after_mise_install_failure() {
  prepare_setup_sandbox

  if MISE_FAKE_FAIL_INSTALL=1 run_setup; then
    fail 'setup succeeded after mise install failed'
  fi
  assert_call_count '^mise latest elixir@1\.20$' 1
  assert_call_count '^mise -C .*/home install --yes$' 1
}

test_setup_rejects_incompatible_elixir_build() {
  prepare_setup_sandbox

  if MISE_FAKE_ELIXIR_LATEST=1.20.2-otp-28 run_setup 2>/dev/null; then
    fail 'setup accepted an Elixir build that was not compiled for OTP 29'
  fi

  assert_call_count '^mise latest elixir@1\.20$' 1
  assert_call_count '^mise -C .*/home install --yes$' 0
}

test_setup_backs_up_existing_mise_config() {
  prepare_setup_sandbox

  local home="$test_sandbox/home"
  mkdir -p "$home/.config/mise"
  print 'personal mise config' > "$home/.config/mise/config.toml"

  run_setup
  run_setup

  [[ "$(< "$home/.config/mise/config.toml.bak-20260716")" == 'personal mise config' ]] || \
    fail 'existing mise config content was not backed up'
  assert_symlink "$home/.config/mise/config.toml" "$home/.dotfiles/mise/config.toml"
  [[ ! -e "$home/.config/mise/config.toml.bak-20260716-1" ]] || \
    fail 're-running setup created an extra mise config backup'
}

test_mise_config_declares_approved_tools() {
  local config="$repo_root/mise/config.toml"
  [[ -f "$config" ]] || fail 'tracked mise config does not exist'

  local actual_tools
  local expected_tools
  actual_tools="$(awk '
    /^\[tools\]$/ { in_tools = 1; next }
    /^\[/ { in_tools = 0 }
    in_tools && /^[A-Za-z0-9_".:@\/-]+[[:space:]]*=/ {
      key = $0
      sub(/[[:space:]]*=.*$/, "", key)
      gsub(/^"|"$/, "", key)
      print key
    }
  ' "$config" | LC_ALL=C sort)"
  expected_tools="$(print -l \
    act atuin bat bottom buf bun caddy claude clang-format cmake codex conda:eza ctop curlie \
    delta deno direnv dive duf dust elixir erlang fastfetch fd fx fzf gdu gh git-lfs go goreleaser \
    gping gradle helm herdr hunk hyperfine java jq lazydocker lazygit maven mc mkcert neovim node \
    npm:agent-browser pipx:httpie pipx:mercurial pnpm python ripgrep rust sd starship terraform tmux \
    uv wrangler zoxide | LC_ALL=C sort)"

  [[ "$actual_tools" == "$expected_tools" ]] || \
    fail "mise tools differ from the approved set:\n$actual_tools"
  grep -Fxq 'java = "temurin-25"' "$config" || fail 'mise config does not select Temurin 25'
  grep -Fxq '"conda:eza" = "latest"' "$config" || fail 'mise config does not use conda eza'
  grep -Fxq 'buf = "latest"' "$config" || fail 'mise config does not use the Buf shorthand'
  grep -Fxq '"pipx:httpie" = { version = "latest", depends = ["uv"] }' "$config" || \
    fail 'HTTPie does not depend on uv'
  grep -Fxq '"pipx:mercurial" = { version = "latest", depends = ["uv"] }' "$config" || \
    fail 'Mercurial does not depend on uv'
  grep -Fxq 'minimum_release_age = "0s"' "$config" || fail 'mise minimum release age is not 0s'
  grep -Fxq 'package_manager = "bun"' "$config" || fail 'npm package manager is not Bun'
  ! grep -Eq '^"(aqua:caddyserver/caddy|conda:clang-format|aqua:FiloSottile/mkcert|aqua:bufbuild/buf)"[[:space:]]*=' \
    "$config" || fail 'mise config pins a backend already selected by the default registry'
  ! grep -Fq '# CLI tools migrated from Homebrew or another mise backend' "$config" || \
    fail 'mise config keeps a migration-only tool category'
}

test_brewfile_contains_only_approved_formulae() {
  local brewfile="$repo_root/brew/Brewfile"
  local actual_formulae
  local expected_formulae
  actual_formulae="$(sed -n 's/^brew "\([^"]*\)".*/\1/p' "$brewfile" | LC_ALL=C sort)"
  expected_formulae="$(print -l \
    cocoapods efl ffmpeg git gnupg htop ideviceinstaller ios-deploy mas mingw-w64 pinentry-mac \
    sqlite ssh-copy-id syncthing telnet wget wxwidgets | LC_ALL=C sort)"

  [[ "$actual_formulae" == "$expected_formulae" ]] || \
    fail "Brewfile formulae differ from the approved set:\n$actual_formulae"
  [[ "$(grep -c '^cask ' "$brewfile")" == 17 ]] || fail 'Brewfile cask count changed'
  [[ "$(grep -c '^mas ' "$brewfile")" == 3 ]] || fail 'Brewfile Mac App Store count changed'
  grep -Fxq 'brew "syncthing", restart_service: :changed' "$brewfile" || \
    fail 'Syncthing service restart policy changed'
}

test_setup_backs_up_existing_file() {
  prepare_setup_sandbox

  local home="$test_sandbox/home"
  print 'personal config' > "$home/.gitconfig"

  run_setup
  run_setup

  [[ "$(< "$home/.gitconfig.bak-20260716")" == 'personal config' ]] || \
    fail 'existing file content was not backed up'
  assert_symlink "$home/.gitconfig" "$home/.dotfiles/.gitconfig"
  [[ ! -e "$home/.gitconfig.bak-20260716-1" ]] || \
    fail 're-running setup created an extra backup'
}

test_setup_numbers_conflicting_backup() {
  prepare_setup_sandbox

  local home="$test_sandbox/home"
  print 'personal config' > "$home/.gitconfig"
  print 'older backup' > "$home/.gitconfig.bak-20260716"

  run_setup

  [[ "$(< "$home/.gitconfig.bak-20260716")" == 'older backup' ]] || \
    fail 'existing backup content changed'
  [[ "$(< "$home/.gitconfig.bak-20260716-1")" == 'personal config' ]] || \
    fail 'numbered backup did not preserve existing content'
  assert_symlink "$home/.gitconfig" "$home/.dotfiles/.gitconfig"
}

test_setup_restores_existing_file_when_link_fails() {
  prepare_setup_sandbox

  local home="$test_sandbox/home"
  print 'personal config' > "$home/.gitconfig"
  write_executable "$test_sandbox/bin/ln" '#!/bin/zsh
if [[ "${argv[-1]}" == "$HOME/.gitconfig" ]]; then
  exit 19
fi
/bin/ln "$@"'

  if run_setup; then
    fail 'setup succeeded after link creation failed'
  fi

  [[ -f "$home/.gitconfig" && ! -L "$home/.gitconfig" ]] || \
    fail 'existing file was not restored'
  [[ "$(< "$home/.gitconfig")" == 'personal config' ]] || \
    fail 'restored file content changed'
  [[ ! -e "$home/.gitconfig.bak-20260716" ]] || \
    fail 'backup remained after successful restore'
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
  assert_call_count '^brew install git$' 2
  assert_call_count '^brew install --cask font-' 0
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
  local apt_install_call
  apt_install_call="$(grep -m1 '^sudo apt-get install --yes ' "$test_sandbox/calls.log" || true)"
  [[ " $apt_install_call " == *' libnss3-tools '* ]] || fail 'Ubuntu does not install libnss3-tools'
  [[ " $apt_install_call " != *' tree '* ]] || fail 'Ubuntu still installs tree'
  assert_call_count '^sudo apt-get update$' 2
  assert_call_count '^sudo apt-get install --yes libfuse2$' 2
  assert_call_count '^sudo apt ' 0
}

prepare_brew_cleanup_sandbox() {
  test_sandbox="$(mktemp -d)"

  local home="$test_sandbox/home"
  local dotfiles="$home/.dotfiles"
  local fake_bin="$test_sandbox/bin"
  local state="$test_sandbox/state"

  [[ -x "$repo_root/bin/cleanup-homebrew.darwin.sh" ]] || \
    fail 'Homebrew cleanup script does not exist or is not executable'

  mkdir -p "$dotfiles/bin" "$dotfiles/brew" "$fake_bin" "$state"
  cp "$repo_root/bin/cleanup-homebrew.darwin.sh" "$dotfiles/bin/cleanup-homebrew.darwin.sh"
  print 'brew "sqlite"' > "$dotfiles/brew/Brewfile"
  print -l opencode node ripgrep sqlite shared-lib personal-dep eza > "$state/formulae"
  print -l codex claude-code claude-code@latest > "$state/casks"
  print -l opencode eza sqlite personal-dep > "$state/leaves"
  print -l cameroncooke/axe charmbracelet/tap rs/tap steipete/tap > "$state/taps"
  touch "$test_sandbox/calls.log"

  write_executable "$fake_bin/brew" '#!/bin/zsh
print -r -- "brew $*" >> "$CALLS_LOG"

state_file() {
  print -r -- "$BREW_STATE_DIR/$1"
}

contains() {
  grep -Fxq -- "$2" "$(state_file "$1")"
}

remove_item() {
  local kind="$1"
  local item="$2"
  local file="$(state_file "$kind")"
  grep -Fxv -- "$item" "$file" > "$file.next" || true
  mv "$file.next" "$file"
}

case "$1" in
  list)
    if [[ "$2" == "--formula" && "$3" == "--versions" ]]; then
      contains formulae "$4" && print -r -- "$4 1.0.0"
    elif [[ "$2" == "--cask" && "$3" == "--versions" ]]; then
      contains casks "$4" && print -r -- "$4 1.0.0"
    elif [[ "$2" == "--formula" ]]; then
      cat "$(state_file formulae)"
    elif [[ "$2" == "--cask" ]]; then
      cat "$(state_file casks)"
    fi
    ;;
  leaves)
    cat "$(state_file leaves)"
    ;;
  deps)
    package="${argv[-1]}"
    case "$package" in
      codex) print -l ripgrep shared-lib ;;
      claude-code | claude-code@latest) print shared-lib ;;
      opencode) print -l node ripgrep sqlite personal-dep ;;
    esac
    ;;
  uses)
    package="${argv[-1]}"
    case "$package" in
      node)
        contains formulae opencode && print opencode
        ;;
      ripgrep)
        contains casks codex && print codex
        contains formulae opencode && print opencode
        ;;
      shared-lib)
        print retained-tool
        ;;
    esac
    ;;
  uninstall)
    if [[ "$2" == "--formula" ]]; then
      remove_item formulae "$3"
    elif [[ "$2" == "--cask" ]]; then
      remove_item casks "$3"
    fi
    ;;
  tap)
    cat "$(state_file taps)"
    ;;
  untap)
    remove_item taps "$2"
    ;;
  autoremove)
    [[ "$2" == "--dry-run" ]]
    ;;
  *)
    exit 1
    ;;
esac'
}

run_brew_cleanup() {
  HOME="$test_sandbox/home" \
    CALLS_LOG="$test_sandbox/calls.log" \
    BREW_STATE_DIR="$test_sandbox/state" \
    PATH="$test_sandbox/bin:/usr/bin:/bin" \
    /bin/zsh "$test_sandbox/home/.dotfiles/bin/cleanup-homebrew.darwin.sh"
}

test_brew_cleanup_removes_targets_and_only_their_orphaned_dependencies() {
  prepare_brew_cleanup_sandbox

  run_brew_cleanup
  run_brew_cleanup

  local state="$test_sandbox/state"
  for package in opencode node ripgrep eza; do
    ! grep -Fxq "$package" "$state/formulae" || fail "$package formula was not removed"
  done
  for package in codex claude-code claude-code@latest; do
    ! grep -Fxq "$package" "$state/casks" || fail "$package cask was not removed"
  done
  for package in sqlite shared-lib personal-dep; do
    grep -Fxq "$package" "$state/formulae" || fail "$package formula should have been preserved"
  done
  [[ ! -s "$state/taps" ]] || fail 'unused cleanup taps were not removed'
  assert_call_count '^brew autoremove --dry-run$' 2
  assert_call_count '^brew autoremove$' 0
}

test_herdr_config_supports_cjk_prefix() {
  local config="$repo_root/herdr/config.toml"

  [[ -f "$config" ]] || fail 'Herdr config does not exist'
  grep -Fxq 'prefix = "ctrl+b"' "$config" || fail 'Herdr prefix is not ctrl+b'
  grep -Fxq 'switch_ascii_input_source_in_prefix = true' "$config" || \
    fail 'Herdr does not switch to an ASCII input source in prefix mode'
}

test_herdr_config_focuses_agents_by_number() {
  local config="$repo_root/herdr/config.toml"

  grep -Fxq 'focus_agent = "cmd+ctrl+1..9"' "$config" || \
    fail 'Herdr does not bind Cmd-Ctrl-1..9 to agent focus'
  ! grep -Fxq 'switch_tab = "cmd+ctrl+1..9"' "$config" || \
    fail 'Herdr still binds Cmd-Ctrl-1..9 to tab switching'
}

test_herdr_config_opens_lazygit_popup() {
  local config="$repo_root/herdr/config.toml"

  grep -Fxq 'key = "cmd+ctrl+g"' "$config" || fail 'Herdr does not bind Cmd-Ctrl-G'
  grep -Fxq 'type = "popup"' "$config" || fail 'Herdr does not open lazygit in a popup'
  grep -Fxq 'command = "lazygit"' "$config" || fail 'Herdr does not run lazygit'
  grep -Fxq 'width = "80%"' "$config" || fail 'Herdr lazygit popup width is not 80%'
  grep -Fxq 'height = "80%"' "$config" || fail 'Herdr lazygit popup height is not 80%'
}

prepare_herdr_hunk_sandbox() {
  test_sandbox="$(mktemp -d)"

  local home="$test_sandbox/home"
  local fake_bin="$test_sandbox/bin"
  local repo="$test_sandbox/repo"
  local real_mise="${commands[mise]:-$HOME/.local/bin/mise}"
  local jq_install_path
  local jq_bin

  mkdir -p "$home/.local/bin" "$fake_bin" "$repo"
  touch "$test_sandbox/calls.log" "$test_sandbox/hunk-review-skill.md"

  jq_install_path="$(MISE_NO_CONFIG=1 "$real_mise" ls --installed --json jq | \
    sed -n 's/.*"install_path": "\([^"]*\)".*/\1/p' | head -n 1)"
  jq_bin="$jq_install_path/jq"
  [[ -x "$jq_bin" ]] || fail 'jq is not available for Herdr-Hunk tests'
  ln -s "$jq_bin" "$fake_bin/jq"

  write_executable "$home/.local/bin/mise" '#!/bin/zsh
if [[ "$1" == which && "$2" == hunk && "${HUNK_MISSING:-0}" != 1 ]]; then
  print -r -- "$HOME/.local/share/mise/installs/hunk/bin/hunk"
  exit 0
fi
if [[ "$1 $2 $3 $4 $5" == "exec -- hunk skill path" ]]; then
  print -r -- "$HUNK_SKILL_PATH"
  exit 0
fi
exit 1'

  write_executable "$fake_bin/git" '#!/bin/zsh
if [[ "$1" == -C && "$3" == rev-parse && "$4" == --show-toplevel && "${HERDR_FAKE_NOT_GIT:-0}" != 1 ]]; then
  print -r -- "$HERDR_FAKE_GIT_ROOT"
  exit 0
fi
exit 128'

  write_executable "$fake_bin/herdr" '#!/bin/zsh
print -r -- "$*" >> "$CALLS_LOG"

if [[ "$1 $2" == "pane list" ]]; then
  [[ "${HERDR_FAKE_LIST_FAIL:-0}" != 1 ]] || exit 1
  if [[ "${HERDR_FAKE_EXISTING:-0}" == 1 ]]; then
    print '\''{"result":{"panes":[{"pane_id":"w1:p9","tab_id":"w1:t1","label":"hunk-watch"},{"pane_id":"w1:p8","tab_id":"w1:t2","label":"hunk-watch"}]}}'\''
  else
    print '\''{"result":{"panes":[{"pane_id":"w1:p1","tab_id":"w1:t1","label":null}]}}'\''
  fi
  exit 0
fi

if [[ "$1 $2" == "pane split" ]]; then
  print '\''{"result":{"pane":{"pane_id":"w1:p2"}}}'\''
  exit 0
fi

if [[ "$1 $2" == "pane neighbor" ]]; then
  [[ "${HERDR_FAKE_NEIGHBOR_MISSING:-0}" != 1 ]] || exit 1
  print '\''{"result":{"neighbor":{"neighbor_pane_id":"w1:p1"}}}'\''
  exit 0
fi

if [[ "$1 $2" == "pane get" ]]; then
  print -r -- "{\"result\":{\"pane\":{\"agent\":\"${HERDR_FAKE_AGENT:-codex}\",\"agent_status\":\"${HERDR_FAKE_AGENT_STATUS:-idle}\",\"cwd\":\"$HERDR_FAKE_GIT_ROOT\"}}}"
  exit 0
fi

if [[ "$1 $2" == "pane rename" ]]; then
  [[ "${HERDR_FAKE_RENAME_FAIL:-0}" != 1 ]]
  exit
fi

if [[ "$1 $2" == "pane run" ]]; then
  [[ "${HERDR_FAKE_RUN_FAIL:-0}" != 1 ]]
  exit
fi

if [[ "$1 $2" == "pane close" ]]; then
  exit 0
fi

exit 1'
}

run_herdr_hunk() {
  local home="$test_sandbox/home"
  local fake_bin="$test_sandbox/bin"

  HOME="$home" \
    PATH="$fake_bin:/usr/bin:/bin" \
    CALLS_LOG="$test_sandbox/calls.log" \
    HERDR_BIN_PATH="$fake_bin/herdr" \
    HERDR_ACTIVE_WORKSPACE_ID=w1 \
    HERDR_ACTIVE_TAB_ID=w1:t1 \
    HERDR_ACTIVE_PANE_ID=w1:p1 \
    HERDR_ACTIVE_PANE_CWD="$test_sandbox/repo" \
    HERDR_FAKE_GIT_ROOT="$test_sandbox/repo" \
    HERDR_FAKE_EXISTING="${HERDR_FAKE_EXISTING:-0}" \
    HERDR_FAKE_LIST_FAIL="${HERDR_FAKE_LIST_FAIL:-0}" \
    HERDR_FAKE_NOT_GIT="${HERDR_FAKE_NOT_GIT:-0}" \
    HERDR_FAKE_RENAME_FAIL="${HERDR_FAKE_RENAME_FAIL:-0}" \
    HERDR_FAKE_RUN_FAIL="${HERDR_FAKE_RUN_FAIL:-0}" \
    HUNK_MISSING="${HUNK_MISSING:-0}" \
    /bin/zsh "$repo_root/bin/herdr-hunk-toggle.sh"
}

test_herdr_config_toggles_hunk() {
  local config="$repo_root/herdr/config.toml"

  grep -Fxq 'key = "cmd+ctrl+r"' "$config" || fail 'Herdr does not bind Cmd-Ctrl-R'
  grep -Fxq 'type = "shell"' "$config" || fail 'Herdr does not run the Hunk toggle as a shell command'
  grep -Fxq 'command = "$HOME/.dotfiles/bin/herdr-hunk-toggle.sh"' "$config" || \
    fail 'Herdr does not run the Hunk toggle script'
  ! grep -Fq 'persiyanov.reviewr' "$config" || fail 'Herdr still binds the Reviewr plugin'
  [[ -x "$repo_root/bin/herdr-hunk-toggle.sh" ]] || fail 'Herdr-Hunk toggle script is not executable'
}

test_herdr_config_uses_hunk_default_save_shortcut() {
  local config="$repo_root/herdr/config.toml"

  ! grep -Fq 'key = "cmd+s"' "$config" || fail 'Herdr still overrides the Hunk save shortcut'
  [[ ! -e "$repo_root/bin/herdr-hunk-save-note.sh" ]] || \
    fail 'Obsolete Herdr-Hunk note save helper still exists'
}

test_hunk_config_starts_with_hidden_menu_bar() {
  local config="$repo_root/hunk/config.toml"

  [[ -f "$config" ]] || fail 'Hunk config does not exist'
  [[ "$(grep -Fxc 'menu_bar = false' "$config" || true)" == 1 ]] || \
    fail 'Hunk menu bar is not disabled exactly once'
  grep -Fxq 'mode = "auto"' "$config" || fail 'Hunk mode is not auto'
}

test_herdr_config_sends_hunk_review_prompt() {
  local config="$repo_root/herdr/config.toml"

  grep -Fxq 'key = "cmd+ctrl+a"' "$config" || fail 'Herdr does not bind Cmd-Ctrl-A'
  grep -Fxq 'command = "$HOME/.dotfiles/bin/herdr-hunk-prompt.sh"' "$config" || \
    fail 'Herdr does not run the Hunk prompt helper'
  [[ -x "$repo_root/bin/herdr-hunk-prompt.sh" ]] || fail 'Herdr-Hunk prompt helper is not executable'
}

run_herdr_hunk_prompt() {
  local home="$test_sandbox/home"
  local fake_bin="$test_sandbox/bin"

  HOME="$home" \
    PATH="$fake_bin:/usr/bin:/bin" \
    CALLS_LOG="$test_sandbox/calls.log" \
    HUNK_SKILL_PATH="$test_sandbox/hunk-review-skill.md" \
    HERDR_BIN_PATH="$fake_bin/herdr" \
    HERDR_ACTIVE_PANE_ID=w1:p2 \
    HERDR_ACTIVE_PANE_CWD="$test_sandbox/repo" \
    HERDR_FAKE_GIT_ROOT="$test_sandbox/repo" \
    HERDR_FAKE_AGENT="${HERDR_FAKE_AGENT:-codex}" \
    HERDR_FAKE_AGENT_STATUS="${HERDR_FAKE_AGENT_STATUS:-idle}" \
    HERDR_FAKE_NEIGHBOR_MISSING="${HERDR_FAKE_NEIGHBOR_MISSING:-0}" \
    /bin/zsh "$repo_root/bin/herdr-hunk-prompt.sh"
}

test_herdr_hunk_prompt_targets_idle_codex_with_current_skill_path() {
  prepare_herdr_hunk_sandbox

  run_herdr_hunk_prompt

  grep -Fxq 'pane neighbor --direction left --pane w1:p2' "$test_sandbox/calls.log" || \
    fail 'Herdr-Hunk prompt does not target the left neighbor'
  grep -Fxq 'pane get w1:p1' "$test_sandbox/calls.log" || \
    fail 'Herdr-Hunk prompt does not inspect the neighboring pane'
  grep -Fq "pane run w1:p1 Load the Hunk review skill from $test_sandbox/hunk-review-skill.md" \
    "$test_sandbox/calls.log" || fail 'Herdr-Hunk prompt does not use the current Hunk skill path'
  grep -Fq 'Review every current user note in the active Hunk session' "$test_sandbox/calls.log" || \
    fail 'Herdr-Hunk prompt does not explicitly request current user-note review'
}

test_herdr_hunk_prompt_supports_claude() {
  prepare_herdr_hunk_sandbox

  HERDR_FAKE_AGENT=claude HERDR_FAKE_AGENT_STATUS=done run_herdr_hunk_prompt

  grep -Fq 'pane run w1:p1 Load the Hunk review skill' "$test_sandbox/calls.log" || \
    fail 'Herdr-Hunk prompt does not support a completed Claude pane'
}

test_herdr_hunk_prompt_refuses_working_agent() {
  prepare_herdr_hunk_sandbox

  if HERDR_FAKE_AGENT_STATUS=working run_herdr_hunk_prompt 2>/dev/null; then
    fail 'Herdr-Hunk prompt sent a new task to a working agent'
  fi

  assert_call_count '^pane run ' 0
}

test_herdr_hunk_opens_right_split_without_focus() {
  prepare_herdr_hunk_sandbox

  run_herdr_hunk

  grep -Fxq 'pane list --workspace w1' "$test_sandbox/calls.log" || \
    fail 'Herdr-Hunk does not list panes in the active workspace'
  grep -Fxq "pane split w1:p1 --direction right --ratio 0.5 --cwd $test_sandbox/repo --no-focus" \
    "$test_sandbox/calls.log" || fail 'Herdr-Hunk does not open a right split without focus'
  grep -Fxq 'pane rename w1:p2 hunk-watch' "$test_sandbox/calls.log" || \
    fail 'Herdr-Hunk does not label the new pane'
  grep -Fxq "pane run w1:p2 exec $test_sandbox/home/.local/bin/mise exec -- hunk diff --watch" \
    "$test_sandbox/calls.log" || fail 'Herdr-Hunk does not start Hunk watch mode'
}

test_herdr_hunk_closes_existing_pane_in_active_tab() {
  prepare_herdr_hunk_sandbox
  HERDR_FAKE_EXISTING=1 run_herdr_hunk

  grep -Fxq 'pane close w1:p9' "$test_sandbox/calls.log" || \
    fail 'Herdr-Hunk does not close the existing Hunk pane'
  ! grep -Fxq 'pane close w1:p8' "$test_sandbox/calls.log" || \
    fail 'Herdr-Hunk closes a Hunk pane from another tab'
  assert_call_count '^pane split ' 0
}

test_herdr_hunk_refuses_non_git_directory() {
  prepare_herdr_hunk_sandbox

  if HERDR_FAKE_NOT_GIT=1 run_herdr_hunk 2>/dev/null; then
    fail 'Herdr-Hunk opened outside a Git repository'
  fi

  assert_call_count '^pane split ' 0
}

test_herdr_hunk_closes_new_pane_when_run_fails() {
  prepare_herdr_hunk_sandbox

  if HERDR_FAKE_RUN_FAIL=1 run_herdr_hunk 2>/dev/null; then
    fail 'Herdr-Hunk succeeded after Hunk launch failed'
  fi

  grep -Fxq 'pane close w1:p2' "$test_sandbox/calls.log" || \
    fail 'Herdr-Hunk did not clean up the pane after launch failure'
}

test_ghostty_maps_physical_herdr_keys() {
  local config="$repo_root/ghostty.conf"
  local ghostty_bin=/Applications/Ghostty.app/Contents/MacOS/ghostty

  grep -Fxq 'keybind = ctrl+KeyB=text:\x02' "$config" || \
    fail 'Ghostty does not map the physical B key to Ctrl-B'
  grep -Fxq 'keybind = ctrl+KeyS=text:\x13' "$config" || \
    fail 'Ghostty does not map the physical S key to Ctrl-S'
  grep -Fxq 'keybind = cmd+ctrl+KeyA=csi:97;13u' "$config" || \
    fail 'Ghostty does not map the physical A key to Cmd-Ctrl-A'
  grep -Fxq 'keybind = cmd+ctrl+KeyR=csi:114;13u' "$config" || \
    fail 'Ghostty does not map the physical R key to Cmd-Ctrl-R'
  grep -Fxq 'keybind = cmd+ctrl+KeyG=csi:103;13u' "$config" || \
    fail 'Ghostty does not map the physical G key to Cmd-Ctrl-G'
  if [[ -x "$ghostty_bin" ]]; then
    "$ghostty_bin" +validate-config --config-file="$config"
  fi
}

prepare_zshrc_herdr_sandbox() {
  test_sandbox="$(mktemp -d)"

  local home="$test_sandbox/home"
  local fake_bin="$test_sandbox/bin"

  mkdir -p "$home/.local/share/zinit/zinit.git" "$fake_bin"

  write_executable "$home/.local/share/zinit/zinit.git/zinit.zsh" '#!/bin/zsh
zinit() { :; }
zi() { :; }'

  write_executable "$fake_bin/herdr" '#!/bin/zsh
print -r -- "$*" >> "$CALLS_LOG"'
}

assert_zshrc_herdr_invocation() {
  local expected="$1"
  shift

  prepare_zshrc_herdr_sandbox

  HOME="$test_sandbox/home" \
    CALLS_LOG="$test_sandbox/calls.log" \
    PATH="$test_sandbox/bin:/usr/bin:/bin" \
    ZSHRC_UNDER_TEST="$repo_root/.zshrc" \
    /bin/zsh -c 'source "$ZSHRC_UNDER_TEST"; herdr "$@"' zsh "$@"

  local actual="$(<"$test_sandbox/calls.log")"
  [[ "$actual" == "$expected" ]] || \
    fail "Herdr invocation: expected '$expected', got '$actual'"

  cleanup
  test_sandbox=""
}

test_zshrc_defaults_remote_herdr_to_server_keybindings() {
  assert_zshrc_herdr_invocation \
    '--remote workbox --remote-keybindings server' \
    --remote workbox
}

test_zshrc_preserves_explicit_remote_keybindings() {
  assert_zshrc_herdr_invocation \
    '--remote workbox --remote-keybindings local' \
    --remote workbox --remote-keybindings local
}

test_zshrc_leaves_non_remote_herdr_commands_unchanged() {
  assert_zshrc_herdr_invocation 'status client' status client
}

run_test() {
  local name="$1"

  case "$name" in
    setup)
      test_setup_runs_twice
      cleanup
      test_sandbox=""
      test_setup_does_not_source_shell_config
      cleanup
      test_sandbox=""
      test_setup_rejects_missing_link_source
      cleanup
      test_sandbox=""
      test_setup_stops_after_mise_install_failure
      cleanup
      test_sandbox=""
      test_setup_rejects_incompatible_elixir_build
      cleanup
      test_sandbox=""
      test_setup_backs_up_existing_mise_config
      cleanup
      test_sandbox=""
      test_setup_backs_up_existing_file
      cleanup
      test_sandbox=""
      test_setup_numbers_conflicting_backup
      cleanup
      test_sandbox=""
      test_setup_restores_existing_file_when_link_fails
      test_mise_config_declares_approved_tools
      test_brewfile_contains_only_approved_formulae
      ;;
    darwin)
      test_darwin_prelude_runs_twice
      ;;
    linux)
      test_linux_prelude_runs_twice
      ;;
    brew-cleanup)
      test_brew_cleanup_removes_targets_and_only_their_orphaned_dependencies
      ;;
    herdr)
      test_zshrc_defaults_remote_herdr_to_server_keybindings
      test_zshrc_preserves_explicit_remote_keybindings
      test_zshrc_leaves_non_remote_herdr_commands_unchanged
      test_herdr_config_supports_cjk_prefix
      test_herdr_config_focuses_agents_by_number
      test_herdr_config_opens_lazygit_popup
      test_herdr_config_toggles_hunk
      test_herdr_config_uses_hunk_default_save_shortcut
      test_hunk_config_starts_with_hidden_menu_bar
      test_herdr_config_sends_hunk_review_prompt
      test_herdr_hunk_opens_right_split_without_focus
      cleanup
      test_sandbox=""
      test_herdr_hunk_closes_existing_pane_in_active_tab
      cleanup
      test_sandbox=""
      test_herdr_hunk_refuses_non_git_directory
      cleanup
      test_sandbox=""
      test_herdr_hunk_closes_new_pane_when_run_fails
      cleanup
      test_sandbox=""
      test_herdr_hunk_prompt_targets_idle_codex_with_current_skill_path
      cleanup
      test_sandbox=""
      test_herdr_hunk_prompt_supports_claude
      cleanup
      test_sandbox=""
      test_herdr_hunk_prompt_refuses_working_agent
      ;;
    ghostty)
      test_ghostty_maps_physical_herdr_keys
      ;;
    *)
      fail "unknown test: $name"
      ;;
  esac
  print "PASS $name"
}

case "${1:-all}" in
  all)
    for test_name in setup darwin linux brew-cleanup herdr ghostty; do
      run_test "$test_name"
      cleanup
      test_sandbox=""
    done
    ;;
  setup | darwin | linux | brew-cleanup | herdr | ghostty)
    run_test "$1"
    ;;
  *)
    fail "unknown test: $1"
    ;;
esac
