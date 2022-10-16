#!/bin/zsh

./apply.sh

if [[ "$OSTYPE" == "darwin"* ]]; then
	defaults write -g ApplePressAndHoldEnabled -bool false
	defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
	defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

	defaults write org.alacritty AppleFontSmoothing -int 0
	# defaults write -g AppleFontSmoothing -int 0
fi
