export LANG=en_US.UTF-8

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

# sharkdp/fd
zinit ice as"command" from"gh-r" mv"fd* -> fd" pick"fd/fd"
zinit light sharkdp/fd

# sharkdp/bat
zinit ice as"command" from"gh-r" mv"bat* -> bat" pick"bat/bat"
zinit light sharkdp/bat

# BurntSushi/ripgrep
zinit ice as"command" from"gh-r" mv"ripgrep* -> ripgrep" pick"ripgrep/rg"
zinit light BurntSushi/ripgrep

# dandavison/delta
zinit ice as"command" from"gh-r" mv"delta* -> delta" pick"delta/delta"
zinit light dandavison/delta

# ogham/exa, replacement for ls
zinit ice as"command" from"gh-r" mv"exa* -> exa" pick"exa/bin"
zinit light ogham/exa

# All of the above using the for-syntax and also z-a-bin-gem-node annex
zinit wait"1" lucid from"gh-r" as"null" for \
  sbin"**/fd"        @sharkdp/fd \
  sbin"**/bat"       @sharkdp/bat \
  sbin"**/rg"        BurntSushi/ripgrep \
  sbin"**/delta"     dandavison/delta \
  sbin"**/exa"       ogham/exa

setopt promptsubst

zinit wait lucid for \
  OMZP::git \
  OMZP::docker-compose \
  as"completion" \
    OMZP::docker/_docker

# nvm
# export NVM_LAZY_LOAD=true
zinit light lukechilds/zsh-nvm

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

alias ls=exa
alias la="exa --all --long --git --group-directories-first --time-style=long-iso"
alias ll="exa --long --git --group-directories-first --time-style=long-iso"
alias l=la
alias less=bat
alias more=bat

alias tailscale=/Applications/Tailscale.app/Contents/MacOS/Tailscale
alias drawio=/Applications/draw.io.app/Contents/MacOS/draw.io

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

# Flutter
export PATH=$PATH:$HOME/flutter/bin
