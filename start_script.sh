#!/bin/bash
xrandr --output HDMI-1 --primary
xrandr --output eDP-1 --right-of HDMI-1 
xrandr --output eDP-1 --brightness 0.85
feh --bg-scale ~/Pictures/debian_wallpaper.jpg
setxkbmap -option caps:escape
picom &
