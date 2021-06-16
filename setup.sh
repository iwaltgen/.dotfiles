#!/bin/bash

mkdir -p ~/workspace
pushd ~/workspace
git clone https://github.com/powerline/fonts.git --depth=1

pushd fonts
./install.sh
popd

rm -rf fonts
popd

./apply.sh

if [[ "$OSTYPE" == "darwin"* ]]; then
	defaults write -g ApplePressAndHoldEnabled -bool false
	defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
	defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)
fi
