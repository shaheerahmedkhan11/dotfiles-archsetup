#!/usr/bin/env bash

OPTIONS="󰌾  Lock\n󰍃  Logout\n󰒲  Suspend\n󰑓  Reboot\n󰐥  Shutdown"

CHOSEN=$(echo -e "$OPTIONS" | rofi -dmenu -p "Power Menu" -i -theme-str 'window {width: 250px; border-radius: 12px;} listview {lines: 5;}')

case "$CHOSEN" in
    *"Lock"*)
        if which hyprlock &>/dev/null; then
            ( hyprlock & )
        elif which swaylock &>/dev/null; then
            ( swaylock & )
        else
            loginctl lock-session
        fi
        ;;
    *"Logout"*)
        hyprctl dispatch exit
        ;;
    *"Suspend"*)
        ( systemctl suspend & )
        ;;
    *"Reboot"*)
        ( systemctl reboot & )
        ;;
    *"Shutdown"*)
        ( systemctl poweroff & )
        ;;
esac
