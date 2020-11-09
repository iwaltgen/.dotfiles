#!/bin/sh

# brew          https://brew.sh/
# zinit         https://github.com/zdharma/zinit
# vim-plug      https://github.com/junegunn/vim-plug
# keybase       https://keybase.io/docs/the_app/install_macos

apply.sh

mkdir -p workspace
pushd ~/workspace
git clone https://github.com/powerline/fonts.git --depth=1

pushd fonts
./install.sh
popd

rm -rf fonts
popd

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

pushd brew
bundle.sh &
popd
