langs=("us" "br" "ru")
index=0
file="keyboard_map_index.txt"

if [ -f $file ]; then
  index=$(cat $file)
fi

((index++))

if [ $index -ge ${#langs[@]} ]; then
  index=0
fi

echo $index > ${file}
echo ${langs[$index]}

setxkbmap ${langs[$index]}
