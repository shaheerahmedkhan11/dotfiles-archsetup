#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
STATE_FILE="$WALLPAPER_DIR/.wallpaper-index"
MONITOR="eDP-1"
CURRENT_LINK="$WALLPAPER_DIR/current.jpg"

# Get all wallpapers (exclude symlinks and hidden files)
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) -not -name ".*" -exec basename {} \; | sort)

COUNT=${#WALLPAPERS[@]}
[ "$COUNT" -eq 0 ] && notify-send "No wallpapers found" && exit 1

# Read current index
if [ -f "$STATE_FILE" ]; then
    INDEX=$(<"$STATE_FILE")
else
    INDEX=0
fi

# Get current wallpaper name from config
CURRENT=$(grep "path = " "$HOME/.config/hypr/hyprpaper.conf" | sed 's/.*\///' | tr -d ' ')

# Find next wallpaper (skip the current one)
for ((i = 0; i < COUNT; i++)); do
    NEXT_INDEX=$(( (INDEX + i) % COUNT ))
    if [ "${WALLPAPERS[$NEXT_INDEX]}" != "$CURRENT" ]; then
        break
    fi
done

SELECTED="${WALLPAPERS[$NEXT_INDEX]}"
WALLPAPER_PATH="$WALLPAPER_DIR/$SELECTED"
ln -sfn "$SELECTED" "$CURRENT_LINK"

# Update config
cat << CONF > "$HOME/.config/hypr/hyprpaper.conf"
wallpaper {
    monitor = $MONITOR
    path = $CURRENT_LINK
    fit_mode = cover
}

splash = false
CONF

# Save new index
echo "$(( (NEXT_INDEX + 1) % COUNT ))" > "$STATE_FILE"

# Restart hyprpaper
pkill hyprpaper 2>/dev/null
sleep 0.3
setsid hyprpaper >/dev/null 2>&1 &

notify-send -a "Hyprpaper" "Mocha wallpaper applied" "$SELECTED" -i "$WALLPAPER_PATH"
