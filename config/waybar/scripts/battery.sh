#!/usr/bin/env bash

BAT="/sys/class/power_supply/BAT0"
if [ ! -d "$BAT" ]; then
    echo '{"text": "󰍹 AC", "tooltip": "Desktop — No battery", "class": ""}'
    exit 0
fi

STATUS=$(cat "$BAT/status" 2>/dev/null || echo "Unknown")
CAPACITY=$(cat "$BAT/capacity" 2>/dev/null || echo "0")

if [ "$STATUS" = "Charging" ]; then
    ICON="󰂄"
    CLASS="charging"
elif [ "$STATUS" = "Full" ]; then
    ICON="󰁹"
    CLASS="full"
elif [ "$CAPACITY" -le 15 ]; then
    ICON="󰂃"
    CLASS="critical"
elif [ "$CAPACITY" -le 30 ]; then
    ICON="󰁾"
    CLASS="warning"
else
    case "$CAPACITY" in
        [0-2])  ICON="󰁺" ;;
        [3-4])  ICON="󰁻" ;;
        [5-6])  ICON="󰁼" ;;
        [7])    ICON="󰁽" ;;
        [8])    ICON="󰁾" ;;
        [9])    ICON="󰁿" ;;
        1[0-9]) ICON="󰂀" ;;
        2[0-9]) ICON="󰂁" ;;
        *)      ICON="󰂂" ;;
    esac
    CLASS=""
fi

echo "{\"text\": \"$ICON ${CAPACITY}%\", \"tooltip\": \"Battery: ${CAPACITY}%\\nStatus: ${STATUS}\\nCapacity: ${CAPACITY}%\", \"class\": \"$CLASS\"}"
