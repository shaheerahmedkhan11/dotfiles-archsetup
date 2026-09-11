#!/usr/bin/env bash

rofi_dir="$HOME/.config/rofi"

options=(
    "  󰐥  Shutdown"
    "  󰜉  Reboot"
    "  󰍃  Logout"
    "  󰤄  Suspend"
    "  󰤃  Hibernate"
)

chosen=$(printf '%s\n' "${options[@]}" | rofi -dmenu -theme "$rofi_dir/power-menu.rasi" -p "Power")

case "$chosen" in
    *"Shutdown")  systemctl poweroff ;;
    *"Reboot")    systemctl reboot ;;
    *"Logout")    hyprctl dispatch exit ;;
    *"Suspend")   systemctl suspend ;;
    *"Hibernate") systemctl hibernate ;;
esac
