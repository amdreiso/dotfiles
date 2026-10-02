#!/usr/bin/env bash
cp ../.tmux.conf ./
cp ../.bashrc ./
cp ../.vimrc ./
folders=("kitty" "nvim" "i3" "i3status" "rofi" "upload_dotfiles.sh" ".bashrc" ".vimrc" ".tmux.conf" "theme" "alacritty")
for folder in "${folders[@]}";
do 
	git add "$folder" 
done
git commit -m "push"
git push -u origin main
rm .tmux.conf .vimrc .bashrc
