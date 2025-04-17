
texts=(
	"computer" 
	"i3 btw" 
	"I use arch btw" 
	"I use vim btw" 
	"minecraft beta is superior" 
	"{◕ ◡ ◕}✿" 
	"play juice galaxy"
	"hearts of iron took half my life away somebody help"
	"isopod"
	"butterflies"
)	

echo ${texts[$RANDOM % ${#texts[@]}]}

