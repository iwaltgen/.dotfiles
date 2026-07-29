# 공통 명령줄 alias 와 래퍼.

# 독립 실행형 CLI 도구는 mise 로 설치한다
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

# xh는 argv[0]으로 HTTPie 호환 모드를 판별하므로 alias로는 켜지지 않는다.
if (( $+commands[xh] )); then
  alias http='XH_HTTPIE_COMPAT_MODE=1 xh'
  alias https='XH_HTTPIE_COMPAT_MODE=1 xh --https'

  # ifconfig.me 루트는 User-Agent로 평문/HTML을 가르므로 전용 엔드포인트를 쓴다.
  alias myip='xh --ignore-stdin --body https://ifconfig.me/ip'

  # 인자를 주면 그 IP를, 없으면 내 IP를 조회한다.
  # ip-api.com은 무료 티어가 HTTP 전용이라 제외했다.
  ipwho() {
    xh --ignore-stdin --body "https://ipwho.is/${1:-}"
  }
fi

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

# 에이전트 CLI 는 기본적으로 호스트 전체 접근으로 실행한다. --safe 를 주면 자체 보호 장치를 켠 채 실행한다.
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
    print -u2 -- 'mise 가 설치되어 있지 않습니다'
    return 127
  fi

  command mise self-update --yes || return
  command mise upgrade --interactive || return

  # prune 후에는 삭제된 버전을 조회할 수 없으므로 미리 목록을 확보한다.
  prunable_versions="$(command mise ls --prunable --no-header)" || return
  command mise prune --yes || return

  if [[ -n "$prunable_versions" ]]; then
    print -- '정리한 mise 버전:'
    print -r -- "$prunable_versions"
  else
    print -- '정리한 mise 버전이 없습니다.'
  fi
}
