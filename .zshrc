# Path to your oh-my-zsh installation.
export ZSH=/Users/iwaltgen/.oh-my-zsh

ZSH_THEME="iwaltgen"
DEFAULT_USER=iwaltgen

plugins=(
	osx
	xcode
	brew
	git
	zsh-completions
	zsh-syntax-highlighting
	zsh-autosuggestions
	fasd
	aws
	docker
	github
	gradle
	mvn
	npm
	yarn
)

export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin"
export MANPATH="/usr/local/man:/usr/local/opt/coreutils/libexec/gnuman"

export LANG=en_US.UTF-8
export CLICOLOR=1

# zsh
source $ZSH/oh-my-zsh.sh
autoload -U compinit && compinit
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'

# Java
export PATH="$HOME/.jenv/shims:/$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

export JAVA_HOME=`/usr/libexec/java_home`

# Node
alias loadnvm=". /usr/local/opt/nvm/nvm.sh"
# export NVM_DIR=~/.nvm
# . $(brew --prefix nvm)/nvm.sh

# GO
export PATH=$PATH:$GOROOT/bin:$HOME/go/bin

# Rust
export PATH=$PATH:$HOME/.cargo/bin

# Docker
alias docker_rm_all="docker rm \`docker ps -a -q\`"
alias docker_rmi_all="docker rmi \`docker images -q\`"

# Flutter
export PATH=$PATH:$HOME/flutter/bin

# Direnv
eval "$(direnv hook zsh)"

# iterm2 shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--layout=reverse --inline-info"

# exa
alias la="exa --all --long --git --group-directories-first --time-style=long-iso"
alias ll="exa --long --git --group-directories-first --time-style=long-iso"
alias l=la

# kubernetes
export PATH=$PATH:$HOME/.kube/plugin
source <(kubectl completion zsh)

# google cloud sdk
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'

# tailscale
alias tailscale=/Applications/Tailscale.app/Contents/MacOS/Tailscale

# draw.io
alias drawio=/Applications/draw.io.app/Contents/MacOS/draw.io

# etc
ulimit -n 4096

# Generated
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/mc mc
complete -o nospace -C /usr/local/bin/terraform terraform

