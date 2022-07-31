# My \*nix system configuration files

## Prerequisites

[Zsh](https://zsh.sourceforge.io/)

```sh
sudo apt-get install zsh unzip
# brew install zsh

git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

chsh -s $(which zsh)
```

[Homebrew](https://brew.sh/)

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zprofile
```

[Zinit](https://github.com/zdharma-continuum/zinit)

```sh
sh -c "$(curl -fsSL https://git.io/zinit-install)"
```

[vim-plug](https://github.com/junegunn/vim-plug)

```sh
# vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# neovim
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

[Keybase](https://keybase.io/docs/the_app/install_macos)

## Setup

```sh
# fonts (https://www.nerdfonts.com/)
#
# macOS
# brew tap homebrew/cask-fonts
# brew install --cask font-hack-nerd-font
#
# linux
# mkdir -p ~/.local/share/fonts
# cd ~/.local/share/fonts
# curl -fsSLo "Hack Regular Nerd Font Complete.ttf" \
#   https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf
# curl -fsSLo "Hack Regular Nerd Font Complete Mono.ttf" \
#   https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete%20Mono.ttf
# curl -fsSLo "Hack Italic Nerd Font Complete.ttf" \
#   https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Italic/complete/Hack%20Italic%20Nerd%20Font%20Complete.ttf
# curl -fsSLo "Hack Italic Nerd Font Complete Mono.ttf" \
#   https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Italic/complete/Hack%20Italic%20Nerd%20Font%20Complete%20Mono.ttf
# curl -fsSLo "Hack Bold Nerd Font Complete.ttf" \
#   https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Bold/complete/Hack%20Bold%20Nerd%20Font%20Complete.ttf
# curl -fsSLo "Hack Bold Nerd Font Complete Mono.ttf" \
#   https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Bold/complete/Hack%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
# curl -fsSLo "Hack Bold Italic Nerd Font Complete.ttf" \
#   https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/BoldItalic/complete/Hack%20Bold%20Italic%20Nerd%20Font%20Complete.ttf
# curl -fsSLo "Hack Bold Italic Nerd Font Complete Mono.ttf" \
#   https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/BoldItalic/complete/Hack%20Bold%20Italic%20Nerd%20Font%20Complete%20Mono.ttf

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
