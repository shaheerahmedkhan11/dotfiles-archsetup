#!/usr/bin/env bash

rofi_dir="$HOME/.config/rofi"

player=$(playerctl -l 2>/dev/null | head -1)

if [ -z "$player" ]; then
    notify-send "Player" "No active player found"
    exit 0
fi

status=$(playerctl -p "$player" status 2>/dev/null)
title=$(playerctl -p "$player" metadata title 2>/dev/null || echo "Unknown")
artist=$(playerctl -p "$player" metadata artist 2>/dev/null)

if [ "$status" = "Playing" ]; then
    play_icon="  󰏤  Pause"
else
    play_icon="  󰐊  Play"
fi

options=(
    "$play_icon"
    "  󰒮  Previous"
    "  󰒭  Next"
    "  󰝟  Stop"
    "  $title - $artist"
)

chosen=$(printf '%s\n' "${options[@]}" | rofi -dmenu -theme "$rofi_dir/player-menu.rasi" -p "Player")

case "$chosen" in
    *"Play")     playerctl -p "$player" play-pause ;;
    *"Pause")    playerctl -p "$player" play-pause ;;
    *"Previous") playerctl -p "$player" previous ;;
    *"Next")     playerctl -p "$player" next ;;
    *"Stop")     playerctl -p "$player" stop ;;
esac
