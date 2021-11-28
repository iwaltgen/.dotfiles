# My \*nix system configuration files

## Prerequisites

[Zsh](https://zsh.sourceforge.io/)

```sh
sudo apt-get install zsh
# brew install zsh

chsh -s $(which zsh)
```

[Homebrew](https://brew.sh/)

```sh
sh -c "curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
```

[Zinit](https://github.com/zdharma-continuum/zinit)

```sh
sh -c "$(curl -fsSL https://git.io/zinit-install)"
```

[vim-plug](https://github.com/junegunn/vim-plug)

```sh
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

[Keybase](https://keybase.io/docs/the_app/install_macos)

## Setup

```sh
# brew
pushd brew
brew bundle
popd

# setup
./setup.sh

# gpg
.gnupg/gpg-import-from-keybase.sh

source .zshrc

# zinit
zinit self-update
zinit update

# zinit module change
zinit delete --clean

# zinit module all change
zinit delete --all
source .zshrc
zinit update
```
