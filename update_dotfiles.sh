#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <message>"
    echo "Please state the changes."
    exit 1
fi

message="$1"

# Copy Hyprland configuration files
cp ~/.config/hypr/* ~/dotfiles/hyprland/hyperland/

# Copy Waybar configuration files
cp ~/.config/waybar/* ~/dotfiles/hyprland/waybar/

cp ~/.config/wofi/* ~/dotfiles/hyprland/wofi/

git add .

git commit -m "$message"

git push origin main

echo "Configuration files have been updated."
