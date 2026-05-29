if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload toph &
  done
else
  polybar --reload toph &
fi

# if type "xrandr"; then
#   MONITOR=DisplayPort-1 polybar --reload toph &
# else
#   polybar --reload toph &
# fi
# 
