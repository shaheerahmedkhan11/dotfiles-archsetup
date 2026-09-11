#!/usr/bin/env bash

HEALTH=$(curl -s --connect-timeout 1 http://127.0.0.1:7777/api/health 2>/dev/null)

if [ -n "$HEALTH" ] && echo "$HEALTH" | grep -q '"status":"ok"'; then
    UPTIME=$(echo "$HEALTH" | grep -oP '"uptime":\K[0-9]+' 2>/dev/null || echo "0")
    UPTIME_MIN=$((UPTIME / 60))
    echo "{\"text\": \"󰚩 AI\", \"tooltip\": \"󰚩 Cyber-Hub: Online\\n󱔗 History Vault: Connected\\n󱔗 AI-OS Vault: Connected\\n⏱ Uptime: ${UPTIME_MIN}m\\n\\nLeft-Click: Open Dashboard\\nRight-Click: Open Obsidian\", \"class\": \"online\"}"
else
    echo "{\"text\": \"󰚩 AI\", \"tooltip\": \"󰚩 Cyber-Hub: Offline\\nLeft-Click: Start service\\nRight-Click: Open Obsidian\", \"class\": \"offline\"}"
fi
