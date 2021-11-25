# My \*nix system configuration files

## Setup

[Homebrew](https://brew.sh/)

[Zinit](https://github.com/zdharma-continuum/zinit)

[Keybase](https://keybase.io/docs/the_app/install_macos)

[vim-plug](https://github.com/junegunn/vim-plug)

```sh
pushd brew
brew bundle
popd


./setup.sh

.gnupg/gpg-import-from-keybase.sh

source .zshrc

zinit self-update
zinit update

```
