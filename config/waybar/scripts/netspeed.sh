#!/usr/bin/env bash

INTERFACE=$(ip route show default 2>/dev/null | awk '/dev/{print $5}' | head -1)
[ -z "$INTERFACE" ] && INTERFACE="wlp2s0"

get_bytes() {
    awk -v iface="$1" '$1 == iface ":" {print $2, $10}' /proc/net/dev
}

format_speed() {
    local bytes=$1
    if [ "$bytes" -ge 1073741824 ]; then
        echo "$(awk "BEGIN {printf \"%.1f\", $bytes/1073741824}")GB"
    elif [ "$bytes" -ge 1048576 ]; then
        echo "$(awk "BEGIN {printf \"%.1f\", $bytes/1048576}")MB"
    elif [ "$bytes" -ge 1024 ]; then
        echo "$(awk "BEGIN {printf \"%.1f\", $bytes/1024}")KB"
    else
        echo "${bytes}B"
    fi
}

read -r RX1 TX1 <<< $(get_bytes "$INTERFACE")
sleep 1
read -r RX2 TX2 <<< $(get_bytes "$INTERFACE")

RX_RATE=$(( (RX2 - RX1) ))
TX_RATE=$(( (TX2 - TX1) ))

RX_STR=$(format_speed "$RX_RATE")
TX_STR=$(format_speed "$TX_RATE")

OUT="{\"text\": \"󰈀 ${RX_STR} 󰈂 ${TX_STR}\", \"tooltip\": \"Interface: $INTERFACE\\nDown: ${RX_STR}/s\\nUp: ${TX_STR}/s\\n\\nTotal RX: $(format_speed $RX2)\\nTotal TX: $(format_speed $TX2)\"}"
echo "$OUT"
