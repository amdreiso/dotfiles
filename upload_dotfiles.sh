#!/usr/bin/env bash
folders=("kitty" "nvim" "i3" "i3status" "rofi" "upload_dotfiles.sh" "../.tmux.conf")
for folder in "${folders[@]}";
do 
	git add "$folder" 
done
git commit -m "push"
git push -u origin main
