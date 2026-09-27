#!/usr/bin/env bash

themes=("dark.conf" "light.conf")
index=0
indexfile="$HOME/.config/theme/index"
themefile="$HOME/.config/kitty/kitty.conf"

if [ -f $indexfile ]; then
	index=$(cat $indexfile)
fi

echo $(cp -f "$HOME/.config/kitty/"${themes[$index]} ${themefile})

