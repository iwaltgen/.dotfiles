export LANG=en_US.UTF-8
export TERM=xterm-256color
export EDITOR=vim

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# customizations, e.g. theme, plugins, aliases, etc.
[ -f $HOME/.zshrc.os ] && source $HOME/.zshrc.os
[ -f $HOME/.zshrc.local ] && source $HOME/.zshrc.local

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
