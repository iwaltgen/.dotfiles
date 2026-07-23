# Common command-line aliases and wrappers.

# standalone CLI tools are installed by mise
(( $+commands[bat] && $+aliases[less] )) && unalias less

if (( $+commands[bat] )); then
  alias cat=bat

  less() {
    command bat --paging=always --pager='less -R +G' "$@"
  }
fi
(( $+commands[delta] )) && alias diff=delta
(( $+commands[dust] )) && alias du=dust
(( $+commands[gping] )) && alias ping=gping
(( $+commands[lazygit] )) && alias lg=lazygit
(( $+commands[lazydocker] )) && alias ld=lazydocker

if (( $+commands[herdr] )); then
  herdr() {
    local -a args=("$@")

    if (( ${args[(I)--remote]} && ! ${args[(I)--remote-keybindings]} )); then
      args+=(--remote-keybindings server)
    fi

    command herdr "${args[@]}"
  }
fi

if (( $+commands[eza] )); then
  eza_params=('--git' '--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale=all')

  alias ls='eza ${eza_params}'
  alias ll='eza --header --long ${eza_params}'
  alias l='eza --all --header --long ${eza_params}'
  alias lm='eza --all --header --long --sort=modified ${eza_params}'
  alias la='eza -lbhHigUmuSa'
  alias lt='eza --tree --level=2'
  alias tree='eza --tree --level=2'
fi

(( $+commands[nvim] )) && alias vi=nvim

# Agent CLIs run with full host access by default; pass --safe to keep their safeguards enabled.
if (( $+commands[claude] )); then
  claude() {
    local -a args=()
    local arg
    local safe=0
    local parse_options=1

    for arg in "$@"; do
      if (( parse_options )) && [[ "$arg" == --safe ]]; then
        safe=1
        continue
      fi
      args+=("$arg")
      [[ "$arg" == -- ]] && parse_options=0
    done

    if (( safe )); then
      CLAUDE_CODE_NO_FLICKER=1 command claude "${args[@]}"
    else
      CLAUDE_CODE_NO_FLICKER=1 command claude --dangerously-skip-permissions "${args[@]}"
    fi
  }
fi

if (( $+commands[codex] )); then
  codex() {
    local -a args=()
    local arg
    local safe=0
    local parse_options=1

    for arg in "$@"; do
      if (( parse_options )) && [[ "$arg" == --safe ]]; then
        safe=1
        continue
      fi
      args+=("$arg")
      [[ "$arg" == -- ]] && parse_options=0
    done

    if (( safe )); then
      command codex "${args[@]}"
    else
      command codex --dangerously-bypass-approvals-and-sandbox "${args[@]}"
    fi
  }
fi

update-cli-tools() {
  local prunable_versions

  if (( $+commands[brew] )); then
    command brew upgrade -y || return
    command brew cleanup --prune=all || return
  fi

  if (( ! $+commands[mise] )); then
    print -u2 -- 'mise is not installed'
    return 127
  fi

  command mise self-update || return
  command mise upgrade --interactive || return

  # Capture candidates before pruning because deleted versions cannot be queried afterwards.
  prunable_versions="$(command mise ls --prunable --no-header)" || return
  command mise prune --yes || return

  if [[ -n "$prunable_versions" ]]; then
    print -- 'Pruned mise versions:'
    print -r -- "$prunable_versions"
  else
    print -- 'No mise versions were pruned.'
  fi
}
