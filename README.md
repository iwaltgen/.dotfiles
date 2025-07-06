# My \*nix system configuration files

## Prerequisites

- [Zsh](https://zsh.sourceforge.io/): Z shell
- [Git](https://git-scm.com/): Distributed version control system
- [Homebrew](https://brew.sh/): The Missing Package Manager for macOS
- [Keybase](https://keybase.io/docs/the_app/install_macos): End-to-end encryption for things that matter for macOS.

## Setup

```sh
bin/setup.sh
```

### GPG

support for GPG keys stored on Keybase

```sh
.gnupg/gpg-import-from-keybase.sh
```

### Zinit

reintall zinit plugins

```sh
zinit delete --all --yes && exec zsh
```

### Atuin

login and sync

```sh
# atuin register -u iwaltgen -e iwaltgen@gmail.com

atuin login -u iwaltgen
atuin sync
```

## References

- [Zinit](https://github.com/zdharma-continuum/zinit): 🌻 Flexible and fast ZSH plugin manager
- [Neovim](https://neovim.io/): hyper extensible Vim-based text editor
- [AstroNvim](https://github.com/AstroNvim/AstroNvim): An aesthetic and feature-rich neovim config that is extensible and easy to use with a great set of plugins
- [vim-plug](https://github.com/junegunn/vim-plug): 🌺 Minimalist Vim Plugin Manager
