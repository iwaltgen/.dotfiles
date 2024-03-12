#!/bin/zsh

# zsh
sudo apt-get install \
	zsh ca-certificates lsb-release gnupg \
	tree ncdu curl wget unzip htop git \
	build-essential make

git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh

chsh -s $(which zsh)

# zinit
sh -c "$(curl -fsSL https://git.io/zinit-install)"

# AppImage
sudo add-apt-repository universe
sudo apt install libfuse2

# neovim
mkdir -p $HOME/Downloads
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/app

pushd $HOME/Downloads
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
mv ./nvim.appimage $HOME/.local/app/
ln -s $HOME/.local/app/nvim.appimage $HOME/.local/bin/nvim
popd

# fonts hack
mkdir -p $HOME/.local/share/fonts

pushd $HOME/.local/share/fonts
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Regular/HackNerdFontMono-Regular.ttf
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Italic/HackNerdFont-Italic.ttf
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Italic/HackNerdFontMono-Italic.ttf
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Bold/HackNerdFont-Bold.ttf
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Bold/HackNerdFontMono-Bold.ttf
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/BoldItalic/HackNerdFont-BoldItalic.ttf
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/BoldItalic/HackNerdFontMono-BoldItalic.ttf
popd

# curlie
curl -sS https://webi.sh/curlie | sh

# gh
curl -sS https://webi.sh/gh | sh

# minio client
curl -fLo $HOME/.local/bin/mc --create-dirs \
	https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x $HOME/.local/bin/mc

# asdf
git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.12.0

# atuin
bash <(curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh)
