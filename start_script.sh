#!/bin/bash
xrandr --output HDMI-1 --primary
xrandr --output eDP-1 --right-of HDMI-1 
xrandr --output eDP-1 --brightness 0.85
feh --bg-scale ~/Pictures/debian_wallpaper.jpg
setxkbmap -option caps:escape
#swap underscore with minus
xmodmap -e "keycode 20 = underscore minus underscore minus"
#to get back to normal
#sudo xmodmap -e "keycode 20 = minus underscore minus underscore"
picom &
#guake might not be installed 
guake &
