#!/bin/bash
monitors=("eDP-1" "HDMI-A-2")
for monitor in "${monitors[@]}"; do
  out="/tmp/lock-$monitor.png"
  grim -o "$monitor" - |
    magick - -scale 10% -scale 1000% "$out" &
done
wait
hyprlock
