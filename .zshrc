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
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# zinit essential
zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-history-substring-search \
  atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions

# modern unix cli (https://github.com/ibraheemdev/modern-unix)

# sharkdp/fd, fast and user-friendly alternative to 'find'.
zinit ice as"program" from"gh-r" mv"fd* -> fd" pick"fd/fd"
zinit light sharkdp/fd

# sharkdp/bat, a cat clone with wings.
zinit ice as"program" from"gh-r" mv"bat* -> bat" pick"bat/bat" atload"alias cat=bat; alias less=bat"
zinit light sharkdp/bat

# BurntSushi/ripgrep, replacement for grep.
zinit ice as"program" from"gh-r" mv"ripgrep* -> ripgrep" pick"ripgrep/rg"
zinit light BurntSushi/ripgrep

# dandavison/delta, a viewer for git and diff output.
zinit ice as"program" from"gh-r" mv"delta* -> delta" pick"delta/delta" atload"alias diff=delta"
zinit light dandavison/delta

# ogham/exa, replacement for ls.
zinit ice as"program" from"gh-r" mv"exa* -> exa" pick"bin/exa" atload"alias ls=exa"
zinit light ogham/exa

# ogham/dog, cli DNS client.
zinit ice as"program" from"gh-r" mv"dog* -> dog" pick"bin/dog" atload"alias dig=dog"
zinit light ogham/dog

# ClementTsang/bottom, cross-platform graphical process/system monitor.
zinit ice as"program" from"gh-r" mv"bottom* -> bottom" pick"bottom/btm" atload"alias top=btm"
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
  OMZP::sudo \
  OMZP::docker-compose \
  as"completion" \
    OMZP::docker/_docker

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

# Go
export PATH=$PATH:$(go env GOPATH)/bin

# Rust
source "$HOME/.cargo/env"
if ! command -v rustup &> /dev/null
then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# Deno
source "$HOME/.deno/env"
if ! command -v deno &> /dev/null
then
  curl -fsSL https://deno.land/x/install/install.sh | sh

  echo '#!/bin/sh' >> $HOME/.deno/env
  echo '' >> $HOME/.deno/env
  echo '# affix colons on either side of $PATH to simplify matching' >>  $HOME/.deno/env
  echo 'case ":${PATH}:" in' >> $HOME/.deno/env
  echo '    *:"$HOME/.deno/bin":*)' >> $HOME/.deno/env
  echo '        ;;' >> $HOME/.deno/env
  echo '    *)' >> $HOME/.deno/env
  echo '        # Prepending path in case a system-installed rustc needs to be overridden' >> $HOME/.deno/env
  echo '        export PATH="$HOME/.deno/bin:$PATH"' >> $HOME/.deno/env
  echo '        ;;' >> $HOME/.deno/env
  echo 'esac' >> $HOME/.deno/env
  source "$HOME/.deno/env"
fi

# customizations, e.g. theme, plugins, aliases, etc.
[ -f $HOME/.zshrc.os ] && source $HOME/.zshrc.os
[ -f $HOME/.zshrc.local ] && source $HOME/.zshrc.local
