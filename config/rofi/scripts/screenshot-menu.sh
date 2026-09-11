#!/usr/bin/env bash

rofi_dir="$HOME/.config/rofi"
save_dir="$HOME/Pictures/Screenshots"
mkdir -p "$save_dir"

options=(
    "  󰆞  Area Screenshot"
    "  󰹑  Full Screenshot"
    "  󰥔  Area (Copy Only)"
    "  󰈐  Full (Copy Only)"
)

chosen=$(printf '%s\n' "${options[@]}" | rofi -dmenu -theme "$rofi_dir/screenshot-menu.rasi" -p "Screenshot")

timestamp=$(date +%Y%m%d_%H%M%S)

case "$chosen" in
    *"Area Screenshot")
        geom=$(slurp)
        if [ -n "$geom" ]; then
            grim -g "$geom" "$save_dir/screenshot_$timestamp.png" && notify-send -i "$save_dir/screenshot_$timestamp.png" "Screenshot Saved" "$save_dir/screenshot_$timestamp.png"
        fi
        ;;
    *"Full Screenshot")
        grim "$save_dir/screenshot_$timestamp.png" && notify-send -i "$save_dir/screenshot_$timestamp.png" "Screenshot Saved" "$save_dir/screenshot_$timestamp.png"
        ;;
    *"Area (Copy Only)")
        geom=$(slurp)
        if [ -n "$geom" ]; then
            grim -g "$geom" - | wl-copy && notify-send "Screenshot" "Region copied to clipboard"
        fi
        ;;
    *"Full (Copy Only)")
        grim - | wl-copy && notify-send "Screenshot" "Full screen copied to clipboard"
        ;;
esac
