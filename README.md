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

[neovim](https://neovim.io/)

[vim-plug](https://github.com/junegunn/vim-plug)

```sh
# neovim
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt install neovim
# brew install neovim

# vim plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# neovim plug
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
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Regular/HackNerdFontMono-Regular.ttf
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Italic/HackNerdFont-Italic.ttf
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Italic/HackNerdFontMono-Italic.ttf
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Bold/HackNerdFont-Bold.ttf
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Bold/HackNerdFontMono-Bold.ttf
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/BoldItalic/HackNerdFont-BoldItalic.ttf
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/BoldItalic/HackNerdFontMono-BoldItalic.ttf

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
