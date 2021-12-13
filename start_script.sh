#!/bin/bash

setxkbmap -option caps:escape
#xrandr --output HDMI-1 --primary
#xrandr --output eDP-1 --right-of HDMI-1 
#xrandr --output eDP-1 --brightness 0.85

xrandr --output eDP1 --mode 1366x768 --pos 1920x156 --rotate normal --output HDMI1 --mode 1920x1080 --pos 0x0 --rotate normal --output VIRTUAL1 --off

feh --bg-scale ~/Pictures/debian_wallpaper.jpg


picom &
#guake might not be installed 
guake &
