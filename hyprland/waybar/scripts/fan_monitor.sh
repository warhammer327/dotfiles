#!/bin/bash

# Simple fan monitor script for Waybar
# Path: ~/.config/waybar/scripts/fan_monitor.sh

# install sensors first
# sudo dnf install sensors

# Get fan RPM values and check if any fan is running (non-zero RPM)
fan_rpms=$(sensors | grep -i fan | grep -o '[0-9]\+ RPM' | grep -o '[0-9]\+')

# Check if any fan has RPM > 0
fan_running=false
for rpm in $fan_rpms; do
  if [ "$rpm" -gt 0 ]; then
    fan_running=true
    break
  fi
done

# Output based on fan status
if [ "$fan_running" = true ]; then
  # Fan is running - show fan icon
  echo '{"text": "", "tooltip": "Fan running", "class": "fan-active"}'
else
  # No fans running - hide icon
  echo '{"text": "", "tooltip": "Fan idle", "class": "fan-idle"}'
fi
