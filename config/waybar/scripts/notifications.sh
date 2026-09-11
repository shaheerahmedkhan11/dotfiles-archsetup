#!/usr/bin/env bash

PAUSED=$(dunstctl is-paused 2>/dev/null || echo "false")
WAITING=$(dunstctl count waiting 2>/dev/null || echo "0")
HISTORY=$(dunstctl count history 2>/dev/null || echo "0")

if [ "$PAUSED" = "true" ]; then
    echo "{\"text\": \"󰂛\", \"tooltip\": \"Notifications: Paused (DND)\\nHistory: $HISTORY\", \"class\": \"dnd\"}"
elif [ "$WAITING" -gt 0 ]; then
    echo "{\"text\": \"󰂚 $WAITING\", \"tooltip\": \"Notifications: $WAITING unread\\nHistory: $HISTORY\\n\\nLeft-Click: Pop History\\nMiddle-Click: Toggle DND\\nRight-Click: Clear All\", \"class\": \"unread\"}"
else
    echo "{\"text\": \"󰂚\", \"tooltip\": \"Notifications: Active\\nHistory: $HISTORY\\n\\nLeft-Click: Pop History\\nMiddle-Click: Toggle DND\\nRight-Click: Clear All\", \"class\": \"none\"}"
fi
