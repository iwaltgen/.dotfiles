# macOS Apple Silicon and Ubuntu Dotfiles

Personal configuration and bootstrap scripts for macOS on Apple Silicon and Ubuntu Linux.

## Supported Systems

- macOS on Apple Silicon
- Ubuntu Linux

The macOS bootstrap assumes Homebrew is installed under `/opt/homebrew`. The Linux bootstrap uses Ubuntu-specific `apt` repositories and packages.

## Before You Start

The scripts assume this repository is checked out at `$HOME/.dotfiles`. Cloning it elsewhere will break the fixed paths used by the setup and symlink steps.

- Install [Zsh](https://zsh.sourceforge.io/) before running the setup entrypoint.
- Install [Git](https://git-scm.com/) before cloning this repository.
- On Ubuntu, install both prerequisites with `sudo apt install zsh git` if needed.

Homebrew and mise are installed by the setup script and are not prerequisites.

## Setup

```sh
git clone git@github.com:iwaltgen/.dotfiles.git "$HOME/.dotfiles"
cd "$HOME/.dotfiles"
./bin/setup.sh
```

The setup may request administrator access, change the login shell, and download tools from external services. It is intended for initial machine setup; rerunning it can encounter existing clone directories or files.

Most standalone command-line tools are installed with mise. Homebrew remains responsible for macOS system integrations, services, and graphical applications. The mise `cargo:eza` backend can compile eza from source when a compatible prebuilt binary is unavailable.

### GPG

The optional GPG import requires [Keybase](https://keybase.io/docs/the_app/install_macos) and GnuPG:

```sh
.gnupg/gpg-import-from-keybase.sh
```

The script imports keys from the active Keybase account and opens an interactive GPG trust editor for a hardcoded personal key ID. Review the script before using it with another account.

### Zinit

Reinstall all Zinit plugins:

```sh
zinit delete --all --yes && exec zsh
```

### Atuin

Log in and sync shell history:

```sh
# atuin register -u iwaltgen -e iwaltgen@gmail.com

atuin login -u iwaltgen
atuin sync
```

## References

- [mise](https://mise.jdx.dev/): development environment and tool version manager
- [Homebrew](https://brew.sh/): package manager for macOS
- [Zinit](https://github.com/zdharma-continuum/zinit): Zsh plugin manager
- [Neovim](https://neovim.io/): extensible Vim-based text editor
- [AstroNvim](https://github.com/AstroNvim/AstroNvim): Neovim configuration framework
