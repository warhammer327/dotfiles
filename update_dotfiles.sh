#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <message>"
    echo "Please state the changes."
    exit 1
fi

message="$1"

# Copy Hyprland configuration files
cp -r ~/.config/hypr/* ~/dotfiles/hyprland/hyperland/

# Copy Waybar configuration files
cp -r ~/.config/waybar/* ~/dotfiles/hyprland/waybar/

cp -r ~/.config/wofi/* ~/dotfiles/hyprland/wofi/

cp -r ~/.config/nvim/* ~/dotfiles/nvim/

cp -r ~/.config/swaync/* ~/dotfiles/hyprland/swaync/

git add .

git commit -m "$message"

git push origin main

echo "Configuration files have been updated."
