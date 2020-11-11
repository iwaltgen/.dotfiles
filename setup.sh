#!/bin/sh

mkdir -p ~/workspace
pushd ~/workspace
git clone https://github.com/powerline/fonts.git --depth=1

pushd fonts
./install.sh
popd

rm -rf fonts
popd

apply.sh
