#!/bin/zsh

# essential cli tools
sudo add-apt-repository --yes ppa:git-core/ppa
sudo apt update
sudo apt-get install --yes \
	zsh ca-certificates lsb-release gnupg \
	fontconfig tree curl wget unzip htop git \
	build-essential make

git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh

chsh -s $(which zsh)

# zinit
zsh -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

# fonts hack
mkdir -p $HOME/.local/share/fonts
pushd $HOME/.local/share/fonts

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip
unzip Hack.zip -d .
rm Hack.zip
fc-cache -fv

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
