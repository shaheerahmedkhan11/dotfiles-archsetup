#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CURRENT_LINK="$WALLPAPER_DIR/current.jpg"
SELECTED=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) -not -name "current.jpg" -printf '%f\n' | sort | rofi -dmenu -p "Mocha Wallpaper" -i -theme-str 'window {width: 360px; border-radius: 14px;}')

if [ -n "$SELECTED" ]; then
    WALLPAPER_PATH="$WALLPAPER_DIR/$SELECTED"
    # Keep Hyprlock and Hyprpaper on the same visual identity.
    ln -sfn "$SELECTED" "$CURRENT_LINK"

    cat << CONF > "$HOME/.config/hypr/hyprpaper.conf"
wallpaper {
    monitor = eDP-1
    path = $CURRENT_LINK
    fit_mode = cover
}

splash = false
CONF

    pkill hyprpaper 2>/dev/null
    setsid hyprpaper >/dev/null 2>&1 &

    notify-send -a "Hyprpaper" "Mocha wallpaper applied" "$SELECTED" -i "$WALLPAPER_PATH"
fi
