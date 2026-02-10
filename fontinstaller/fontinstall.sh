
sudo mv *.ttf /usr/share/fonts
fc-cache

folder=$1
search=$2
replace=$3

find "$folder" -type f -exec sed -i "s/$search/$replace/g" {} +

