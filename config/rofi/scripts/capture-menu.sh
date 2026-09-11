#!/usr/bin/env bash

rofi_dir="$HOME/.config/rofi"

thought=$(rofi -dmenu -theme "$rofi_dir/clipboard-menu.rasi" -p "💡 Quick Insight")

if [ -n "$thought" ]; then
    /home/shaheer/.local/bin/capture "$thought"
fi
