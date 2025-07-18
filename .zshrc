export LANG=en_US.UTF-8
export TERM=xterm-256color
export EDITOR=vim

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

# modern unix cli (https://github.com/ibraheemdev/modern-unix)

# chmln/sd, intuitive find & replace CLI (sed alternative).
zinit ice as"program" from"gh-r" mv"sd* -> sd" sbin"**/sd"
zinit light chmln/sd

# sharkdp/fd, fast and user-friendly alternative to 'find'.
zinit ice as"program" from"gh-r" sbin"**/fd"
zinit light sharkdp/fd

# sharkdp/bat, a cat clone with wings.
zinit ice as"program" from"gh-r" sbin"**/bat" \
  atload"alias cat=bat; alias less=bat" \
  mv"**/bat.zsh -> completions/_bat"
zinit light sharkdp/bat

# sharkdp/hyperfine, a command-line benchmarking tool.
zinit ice as"program" from"gh-r" sbin"**/hyperfine"
zinit light sharkdp/hyperfine

# BurntSushi/ripgrep, replacement for grep.
zinit ice as"program" from"gh-r" sbin"**/rg"
zinit light BurntSushi/ripgrep

# dandavison/delta, a viewer for git and diff output.
zinit ice as"program" from"gh-r" sbin"**/delta" atload"alias diff=delta"
zinit light dandavison/delta

# ogham/exa, replacement for ls.
zinit ice as"program" from"gh-r" sbin"**/exa" \
  atload"alias ls=exa" \
  mv"**/exa.zsh -> completions/_exa"
zinit light ogham/exa

# ogham/dog, cli DNS client.
zinit ice as"program" from"gh-r" sbin"**/dog" \
  atload"alias dig=dog" \
  mv"**/dog.zsh -> completions/_dog"
zinit light ogham/dog

# dundee/gdu, Fast disk usage analyzer with console interface written in Go.
zinit ice as"program" from"gh-r" mv"gdu* -> gdu" sbin"**/gdu"
zinit light dundee/gdu

# muesli/duf, a better 'df' alternative.
zinit ice as"program" from"gh-r" sbin"**/duf" bpick"*.tar.gz"
zinit light muesli/duf

# bootandy/dust, a more intuitive version of du in rust.
zinit ice as"program" from"gh-r" sbin"**/dust" atload"alias du=dust"
zinit light bootandy/dust

# orf/gping, ping, but with a graph.
zinit ice as"program" from"gh-r" sbin"**/gping" atload"alias ping=gping"
zinit light orf/gping

# jqlang/jq, command-line JSON processor.
zinit ice as"program" from"gh-r" mv"jq* -> jq" sbin"**/jq"
zinit light jqlang/jq

# @antonmedv/fx, Terminal JSON viewer & processor
zi for from"gh-r" \
    sbin"**/fx* -> fx" \
  @antonmedv/fx

# @github/git-sizer, Compute various size metrics for a Git repository, flagging those that might cause problems.
zi for from"gh-r" \
    sbin"git-sizer" \
  @github/git-sizer

# ajeetdsouza/zoxide, a smarter cd command.
zinit ice as"program" from"gh-r" sbin"**/zoxide" \
  atclone"./zoxide init zsh > init.zsh" \
  atpull"%atclone" src"init.zsh" nocompile"!"
zinit light ajeetdsouza/zoxide

# bcicen/ctop, Top-like interface for container metrics.
zinit ice as"program" from"gh-r" mv"ctop* -> ctop" sbin"**/ctop"
zinit light bcicen/ctop

# ClementTsang/bottom, Yet another cross-platform graphical process/system monitor.
zinit ice as"program" from"gh-r" sbin"**/btm" \
  mv"**/_btm -> completions/_btm"
zinit light ClementTsang/bottom

# jesseduffield/lazygit, simple terminal UI for git commands.
zi for from"gh-r" \
    sbin"**/lazygit" \
    atload"alias lg=lazygit" \
  jesseduffield/lazygit

# direnv/direnv, unclutter your .profile
zinit ice as"program" from"gh-r" mv"direnv* -> direnv" sbin"**/direnv" \
  atclone"./direnv hook zsh > zhook.zsh" \
  atpull"%atclone" src="zhook.zsh"
zinit light direnv/direnv

# atuinsh/atuin, Making your shell magical
zinit ice as"command" from"gh-r" bpick"atuin-*.tar.gz" mv"atuin*/atuin -> atuin" \
    atclone"./atuin init zsh --disable-up-arrow > init.zsh; ./atuin gen-completions --shell zsh > _atuin" \
    atpull"%atclone" src"init.zsh"
zinit light atuinsh/atuin

# cli/cli, GitHub’s official command line tool.
zi for from"gh-r" \
    sbin"**/gh" \
  cli/cli

# derailed/k9s, Kubernetes CLI To Manage Your Clusters In Style!
zi for from"gh-r" sbin"**/k9s" \
  derailed/k9s

# neovim/neovim, Vim-fork focused on extensibility and usability.
zi for from"gh-r" bpick"nvim-*.tar.gz" sbin"**/nvim -> nvim" \
  neovim/neovim

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

# fzf (https://github.com/zdharma-continuum/zinit-packages/tree/main/fzf)
# https://github.com/zdharma-continuum/zinit/wiki/Recipes-for-popular-programs#fzf
zi for from"gh-r" sbin"fzf" junegunn/fzf
zi for https://github.com/junegunn/fzf/raw/master/shell/{'completion','key-bindings'}.zsh
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
    exa -1 --color=always $realpath
  else
    bat --color=always $realpath
  fi'
zstyle ':fzf-tab:*' switch-group ',' '.'

# starship
zinit ice as"program" from"gh-r" sbin"**/starship" bpick"*.tar.gz" \
  atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
  atpull"%atclone" src"init.zsh"
zinit light starship/starship

export STARSHIP_CONFIG=~/.starship.toml

# Process
ulimit -n 16384

# History
HISTFILE=~/.zsh_history
HISTSIZE=99999999
SAVEHIST=99999999

# Exa
alias la="ls --all --long --git --group-directories-first --time-style=long-iso"
alias ll="ls --long --git --group-directories-first --time-style=long-iso"
alias l=la

# asdf-vm
export ASDF_DATA_DIR="$HOME/.asdf"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
autoload -Uz compinit && compinit

# asdf-plugins
. $HOME/.asdf/plugins/java/set-java-home.zsh

# Neovim
alias vi="nvim"

# Rust
source "$HOME/.cargo/env"
if ! command -v rustup &> /dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# Deno
source "$HOME/.deno/env"
if ! command -v deno &> /dev/null; then
  curl -fsSL https://deno.land/x/install/install.sh | sh

  echo '#!/bin/zsh' >> $HOME/.deno/env
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

# local
export PATH="$PATH:$HOME/.local/bin"

# customizations, e.g. theme, plugins, aliases, etc.
[ -f $HOME/.zshrc.os ] && source $HOME/.zshrc.os
[ -f $HOME/.zshrc.local ] && source $HOME/.zshrc.local
