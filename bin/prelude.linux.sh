#!/bin/zsh

# essential cli tools
sudo add-apt-repository ppa:git-core/ppa
sudo apt update
sudo apt-get install \
	zsh ca-certificates lsb-release gnupg \
	tree curl wget unzip htop git \
	build-essential make

git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh

chsh -s $(which zsh)

# zinit
sh -c "$(curl -fsSL https://git.io/zinit-install)"

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

# AppImage
sudo add-apt-repository universe
sudo apt install libfuse2

# curlie
curl -sS https://webi.sh/curlie | sh

# minio client
mkdir -p $HOME/.local/bin
curl -fLo $HOME/.local/bin/mc --create-dirs \
	https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x $HOME/.local/bin/mc
