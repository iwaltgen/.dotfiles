#!/bin/zsh

if [[ $OSTYPE != darwin* ]]; then
  print -u2 "This cleanup script only supports macOS."
  exit 1
fi

brew_bin="${commands[brew]:-/opt/homebrew/bin/brew}"
if [[ ! -x "$brew_bin" ]]; then
  print -u2 "Homebrew is not installed."
  exit 1
fi

repo_root="${0:A:h:h}"
brewfile="$repo_root/brew/Brewfile"

formula_candidates=(
  act caddy clang-format cmake dive git-lfs goreleaser gradle helm httpie
  maven mercurial mkcert protobuf scc terraform eza fastfetch gh git-delta
  minio-mc openjdk@17 python@3.10 tmux aha asciinema autoconf certbot
  coreutils ctags diffutils fop graphviz libev libpcap libpq libxslt m-cli
  msgpack rename tree unixodbc wrk axe crush curlie codexbar codex
  claude-code claude-code@latest opencode jmeter beads duckdb grpcurl jqp
  subfinder the_platinum_searcher witr node openjdk openjdk@21 ripgrep
)

cask_candidates=(
  axe crush curlie codexbar codex claude-code claude-code@latest
)

tap_candidates=(
  cameroncooke/axe charmbracelet/tap rs/tap steipete/tap
)

typeset -A cleanup_formulae
typeset -A dependency_formulae
typeset -A brewfile_formulae
typeset -A protected_dependency_formulae

for formula in $formula_candidates; do
  cleanup_formulae[$formula]=1
done

if [[ -f "$brewfile" ]]; then
  while IFS= read -r formula; do
    [[ -n "$formula" ]] && brewfile_formulae[$formula]=1
  done < <(sed -n 's/^brew "\([^"]*\)".*/\1/p' "$brewfile")
fi

while IFS= read -r formula; do
  if [[ -n "$formula" && -z "${cleanup_formulae[$formula]-}" ]]; then
    protected_dependency_formulae[$formula]=1
  fi
done < <("$brew_bin" leaves)

formula_installed() {
  [[ -n "$("$brew_bin" list --formula --versions "$1" 2>/dev/null)" ]]
}

cask_installed() {
  [[ -n "$("$brew_bin" list --cask --versions "$1" 2>/dev/null)" ]]
}

capture_dependencies() {
  local kind="$1"
  local package="$2"
  local dependencies
  local dependency

  dependencies="$("$brew_bin" deps "--$kind" --installed "$package" 2>/dev/null)" || dependencies=""
  for dependency in ${(f)dependencies}; do
    [[ -n "$dependency" ]] && dependency_formulae[$dependency]=1
  done
}

for package in $formula_candidates; do
  formula_installed "$package" && capture_dependencies formula "$package"
done
for package in $cask_candidates; do
  cask_installed "$package" && capture_dependencies cask "$package"
done

for package in $cask_candidates; do
  if cask_installed "$package"; then
    print "Uninstalling Homebrew cask: $package"
    "$brew_bin" uninstall --cask "$package" || exit 1
  fi
done

remove_formulae_until_stable() {
  local only_dependencies="$1"
  local progress=true
  local package
  local users
  local -a packages

  while [[ "$progress" == true ]]; do
    progress=false

    if [[ "$only_dependencies" == true ]]; then
      packages=("${(k)dependency_formulae[@]}")
    else
      packages=("${formula_candidates[@]}")
    fi

    for package in $packages; do
      formula_installed "$package" || continue

      if [[ -n "${brewfile_formulae[$package]-}" ]]; then
        continue
      fi
      if [[ "$only_dependencies" == true && -n "${protected_dependency_formulae[$package]-}" ]]; then
        continue
      fi

      users="$("$brew_bin" uses --installed "$package" 2>/dev/null || true)"
      [[ -z "$users" ]] || continue

      print "Uninstalling Homebrew formula: $package"
      "$brew_bin" uninstall --formula "$package" || exit 1
      progress=true
    done
  done
}

remove_formulae_until_stable false
remove_formulae_until_stable true

for package in ${(k)dependency_formulae}; do
  if formula_installed "$package" && \
    [[ -z "${brewfile_formulae[$package]-}" && -z "${protected_dependency_formulae[$package]-}" ]]; then
    users="$("$brew_bin" uses --installed "$package" 2>/dev/null || true)"
    if [[ -n "$users" ]]; then
      print "Keeping Homebrew dependency $package; required by:"
      print -r -- "$users"
    fi
  fi
done

for tap in $tap_candidates; do
  if "$brew_bin" tap | grep -Fxq "$tap"; then
    if ! "$brew_bin" untap "$tap"; then
      print "Keeping Homebrew tap: $tap"
    fi
  fi
done

print "Homebrew autoremove preview:"
"$brew_bin" autoremove --dry-run
