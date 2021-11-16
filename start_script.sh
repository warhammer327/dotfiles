#!/bin/bash

setxkbmap -option caps:escape
#xrandr --output HDMI-1 --primary
#xrandr --output eDP-1 --right-of HDMI-1 
#xrandr --output eDP-1 --brightness 0.85

xrandr --output eDP1 --mode 1366x768 --pos 1920x156 --rotate normal --output HDMI1 --mode 1920x1080 --pos 0x0 --rotate normal --output VIRTUAL1 --off

feh --bg-scale ~/Pictures/debian_wallpaper.jpg
#swap underscore with minus
xmodmap -e "keycode 20 = underscore minus underscore minus"
#to get back to normal
#sudo xmodmap -e "keycode 20 = minus underscore minus underscore"
picom &
#guake might not be installed 
guake &
