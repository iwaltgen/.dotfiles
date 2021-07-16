export LANG=en_US.UTF-8
export TERM=xterm-256color
export EDITOR=vim

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
  print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
  command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
  command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
  zinit-zsh/z-a-rust \
  zinit-zsh/z-a-as-monitor \
  zinit-zsh/z-a-patch-dl \
  zinit-zsh/z-a-bin-gem-node

### End of Zinit's installer chunk

# zinit essential
zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" \
    zdharma/fast-syntax-highlighting \
    zsh-users/zsh-history-substring-search \
  atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions

# sharkdp/fd, fast and user-friendly alternative to 'find'.
zinit ice as"program" from"gh-r" mv"fd* -> fd" pick"fd/fd"
zinit light sharkdp/fd

# sharkdp/bat, a cat clone with wings.
zinit ice as"program" from"gh-r" mv"bat* -> bat" pick"bat/bat" atload"alias cat=bat;alias less=bat"
zinit light sharkdp/bat

# BurntSushi/ripgrep, replacement for grep.
zinit ice as"program" from"gh-r" mv"ripgrep* -> ripgrep" pick"ripgrep/rg"
zinit light BurntSushi/ripgrep

# dandavison/delta, a viewer for git and diff output.
zinit ice as"program" from"gh-r" mv"delta* -> delta" pick"delta/delta"
zinit light dandavison/delta

# ogham/exa, replacement for ls.
zinit ice as"program" from"gh-r" mv"exa* -> exa" pick"bin/exa" atload"alias ls=exa"
zinit light ogham/exa

# ogham/dog, cli DNS client.
zinit ice as"program" from"gh-r" mv"dog* -> dog" pick"bin/dog"
zinit light ogham/dog

# ClementTsang/bottom, cross-platform graphical process/system monitor.
zinit ice as"program" from"gh-r" mv"bottom* -> bottom" pick"bottom/btm"
zinit light ClementTsang/bottom

# ducaale/xh, friendly and fast tool for sending HTTP requests. (httpie)
zinit ice as"program" from"gh-r" mv"xh* -> xh" pick"xh/xh"
zinit light ducaale/xh

# muesli/duf, a better 'df' alternative.
zinit ice as"program" from"gh-r" mv"duf* -> duf" pick"duf/duf"
zinit light muesli/duf

# bootandy/dust, a more intuitive version of du in rust.
zinit ice as"program" from"gh-r" mv"dust* -> dust" pick"dust/dust"
zinit light bootandy/dust

setopt promptsubst

zinit wait lucid for \
  OMZP::git \
  OMZP::docker-compose \
  as"completion" \
    OMZP::docker/_docker

# nvm
# export NVM_LAZY_LOAD=true
# zinit light lukechilds/zsh-nvm

# ls_colors
zinit pack for ls_colors

# direnv
zinit from"gh-r" as"program" mv"direnv* -> direnv" \
  atclone'./direnv hook zsh > zhook.zsh' atpull'%atclone' \
  pick"direnv" src="zhook.zsh" for \
    direnv/direnv

# fzf
# zplugin pack"default+keys" for fzf
zinit pack"bgn-binary+keys" for fzf
zinit light Aloxaf/fzf-tab

zstyle ':completion:complete:*:options' sort false
zstyle ":completion:*:git-checkout:*" sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'

# romkatv/powerlevel10k theme
zinit ice depth=1; zinit light romkatv/powerlevel10k

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx'

# misc
HISTSIZE=99999
SAVEHIST=99999
HISTFILE=~/.zsh_history

ulimit -n 16384

alias la="ls --all --long --git --group-directories-first --time-style=long-iso"
alias ll="ls --long --git --group-directories-first --time-style=long-iso"
alias l=la

alias tailscale=/Applications/Tailscale.app/Contents/MacOS/Tailscale

# Homebrew
export PATH=$PATH:/usr/local/sbin

# Java
export PATH="$HOME/.jenv/shims:/$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

export JAVA_HOME=`/usr/libexec/java_home`

# Go
export PATH=$PATH:$(go env GOPATH)/bin

# Rust
source "$HOME/.cargo/env"
if ! command -v rustup &> /dev/null
then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# Flutter
export PATH=$PATH:$HOME/flutter/bin
