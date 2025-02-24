

colors=("#FF0000" "#00FF00" "#0000FF")
index=0

while true; do
	echo "${colors[$index]}"
	index=$(( (index + 1) % ${#colors[@]} ))
	sleep 1
done


