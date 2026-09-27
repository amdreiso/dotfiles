#!/usr/bin/env bash
themes=("dark", "light")
index=0
indexfile="$HOME/.config/theme/index"

if [ -f $indexfile ]; then
	index=$(cat $indexfile)
fi
((index++))
if [ $index -ge ${#themes[@]} ]; then
	index=0
fi

echo $index > $indexfile

sh -c "$HOME/.config/kitty/switch.sh $index"

