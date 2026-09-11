#!/usr/bin/env bash

rofi_dir="$HOME/.config/rofi"

selected=$(cliphist list | rofi -dmenu -theme "$rofi_dir/clipboard-menu.rasi" -p "Clipboard")

if [ -n "$selected" ]; then
    echo "$selected" | cliphist decode | wl-copy
fi
