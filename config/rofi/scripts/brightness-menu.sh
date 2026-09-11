#!/usr/bin/env bash

rofi_dir="$HOME/.config/rofi"

current_pct=$(brightnessctl -m | awk -F, '{gsub(/%/, "", $4); print $4}')

options=(
    "  󰃠  Brightness: ${current_pct}%"
    "  󰃞  +10%"
    "  󰃟  -10%"
    "  󰃠  50%"
    "  󰃠  100%"
)

chosen=$(printf '%s\n' "${options[@]}" | rofi -dmenu -theme "$rofi_dir/brightness-menu.rasi" -p "Brightness")

case "$chosen" in
    *"+10%")  brightnessctl -e4 -n2 set 10%+ ;;
    *"-10%")  brightnessctl -e4 -n2 set 10%- ;;
    *"50%")   brightnessctl -e4 -n2 set 50% ;;
    *"100%")  brightnessctl -e4 -n2 set 100% ;;
esac
