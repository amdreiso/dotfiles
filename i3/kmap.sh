#!/usr/bin/env bash

langs=("us" "br")
index=0
file="keyboard_map_index.txt"

setk() {
	if [ -f $file ]; then
		index=$(cat $file)
	fi

	((index++))

	if [ $index -ge ${#langs[@]} ]; then
		index=0
	fi

	echo $index > ${file}

	setxkbmap ${langs[$index]}
}

getk() {
	echo ${langs[$index]}
}

case "$1" in
  set) setk ;;
  get) getk ;;
  *) echo "usage: $0 {set|get}" ;;
esac

