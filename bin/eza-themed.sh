#!/bin/zsh

source "${0:A:h}/terminal-theme.zsh"

env -u LS_COLORS -u EZA_COLORS EZA_CONFIG_DIR="${0:A:h:h}/eza/$theme" eza "$@"
