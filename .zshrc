# Docs: https://zsh.sourceforge.io/Doc/Release/

export LANG=en_US.UTF-8
export TERM=xterm-256color
export EDITOR=vim

# mise
if [[ -x "$HOME/.local/bin/mise" ]]; then
  eval "$("$HOME/.local/bin/mise" activate zsh)"
fi

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
  command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
  command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
    print -P "%F{33} %F{34}Installation successful.%f%b" || \
    print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-readurl \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# zinit essential (https://zdharma-continuum.github.io/zinit/wiki/Example-Minimal-Setup/)
zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-history-substring-search \
  atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf atpull"zinit creinstall -q ." \
    zsh-users/zsh-completions

# @github/git-sizer, Compute various size metrics for a Git repository, flagging those that might cause problems.
zi for from"gh-r" \
    sbin"git-sizer" \
  @github/git-sizer

setopt promptsubst

zinit wait lucid for \
  OMZL::git.zsh \
  atload"unalias grv" \
    OMZP::git

# OS bundles
if [[ $OSTYPE == darwin* ]]; then
  zinit snippet PZTM::osx
elif [[ $OSTYPE == linux* ]]; then
  if (( $+commands[apt-get] )); then
    zinit snippet OMZP::ubuntu
  elif (( $+commands[pacman] )); then
    zinit snippet OMZP::archlinux
  fi
fi

# ls_colors (https://github.com/zdharma-continuum/zinit-packages/tree/main/ls_colors)
zinit pack for ls_colors

# fzf is installed by mise; fzf-tab remains a Zinit plugin
(( $+commands[fzf] )) && source <(fzf --zsh)
zinit light Aloxaf/fzf-tab

zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:descriptions' format '-- %d --'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:complete:*:options' sort false
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,cmd -w -w"
zstyle ':fzf-tab:complete:kill:argument-rest' extra-opts --preview=$extract'ps --pid=$in[(w)1] -o cmd --no-headers -w -w' --preview-window=down:3:wrap
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
zstyle ':fzf-tab:complete:(cd|z|vi):*' fzf-preview \
  'if [ -d $realpath ]; then
    eza -1 --color=always $realpath
  else
    bat --color=always $realpath
  fi'
zstyle ':fzf-tab:*' switch-group ',' '.'

export STARSHIP_CONFIG=~/.starship.toml

# Process
ulimit -n 16384

# History
HISTFILE=~/.zsh_history
HISTSIZE=99999999
SAVEHIST=99999999

# shell integrations for CLI tools installed by mise
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow)"
(( $+commands[starship] )) && eval "$(starship init zsh)"

# fastfetch
if [[ -o interactive ]] && (( $+commands[fastfetch] )); then
  fastfetch
fi

# local
export PATH="$PATH:$HOME/.local/bin"

# common command-line aliases and wrappers
[ -f $HOME/.zshrc.cli ] && source $HOME/.zshrc.cli

# customizations, e.g. theme, plugins, aliases, etc.
[ -f $HOME/.zshrc.os ] && source $HOME/.zshrc.os
[ -f $HOME/.zshrc.local ] && source $HOME/.zshrc.local
