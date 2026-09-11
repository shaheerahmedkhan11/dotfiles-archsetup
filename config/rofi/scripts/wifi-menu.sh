#!/usr/bin/env bash

rofi_dir="$HOME/.config/rofi"

wifi_status=$(nmcli -fields WIFI g 2>/dev/null | tail -n 1 | tr -d '[:space:]')

if [ "$wifi_status" = "disabled" ]; then
    toggle_opt="󰤮  Turn Wi-Fi On"
    chosen=$(printf "%s\n" "$toggle_opt" | rofi -dmenu -theme "$rofi_dir/wifi-menu.rasi" -p "Wi-Fi")
    if [ "$chosen" = "$toggle_opt" ]; then
        nmcli radio wifi on && notify-send "Wi-Fi" "Wi-Fi Enabled"
    fi
    exit 0
fi

# Build Wi-Fi list
get_wifi_entries() {
    echo "󰤮  Turn Wi-Fi Off"
    echo "󰑐  Rescan Networks"
    
    nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan no 2>/dev/null | awk -F: '
    BEGIN { OFS="" }
    $2 != "" && !seen[$2]++ {
        in_use = ($1 == "*") ? "󰄲 " : "  "
        lock = ($4 != "" && $4 != "--") ? " " : ""
        sig = $3 + 0
        if (sig >= 75) icon = "󰤨 "
        else if (sig >= 50) icon = "󰤥 "
        else if (sig >= 25) icon = "󰤢 "
        else icon = "󰤟 "
        
        printf "%s%s %-20s %3d%%%s\n", in_use, icon, $2, sig, lock
    }'
}

chosen=$(get_wifi_entries | rofi -dmenu -theme "$rofi_dir/wifi-menu.rasi" -p "Wi-Fi")

[ -z "$chosen" ] && exit 0

case "$chosen" in
    *"Turn Wi-Fi Off")
        nmcli radio wifi off && notify-send "Wi-Fi" "Wi-Fi Disabled"
        exit 0
        ;;
    *"Rescan Networks")
        nmcli device wifi rescan 2>/dev/null
        notify-send "Wi-Fi" "Scanning for networks..."
        sleep 1
        exec "$0"
        exit 0
        ;;
esac

# Extract selected SSID (remove checkmark / icon / signal)
ssid=$(echo "$chosen" | sed -E 's/^[ 󰄲󰤨󰤥󰤢󰤟]+//' | awk '{print $1}')

if [ -z "$ssid" ]; then
    exit 0
fi

# Check if currently connected
if echo "$chosen" | grep -q "󰄲"; then
    opt=$(printf "Disconnect\nCancel" | rofi -dmenu -theme "$rofi_dir/wifi-menu.rasi" -p "Disconnect from $ssid?")
    if [ "$opt" = "Disconnect" ]; then
        nmcli connection down id "$ssid" 2>/dev/null || nmcli device disconnect wlp2s0 2>/dev/null
        notify-send "Wi-Fi" "Disconnected from $ssid"
    fi
    exit 0
fi

# Check if connection is already saved
saved_con=$(nmcli -t -f NAME connection show | grep -Fx "$ssid" || true)

if [ -n "$saved_con" ]; then
    nmcli connection up id "$ssid" && notify-send "Wi-Fi" "Connected to $ssid" || notify-send "Wi-Fi" "Failed to connect to $ssid"
else
    # Check if network requires password
    if echo "$chosen" | grep -q ""; then
        pass=$(rofi -dmenu -password -theme "$rofi_dir/wifi-menu.rasi" -p "Password for $ssid")
        [ -z "$pass" ] && exit 0
        nmcli device wifi connect "$ssid" password "$pass" && notify-send "Wi-Fi" "Connected to $ssid" || notify-send "Wi-Fi" "Failed to connect to $ssid"
    else
        nmcli device wifi connect "$ssid" && notify-send "Wi-Fi" "Connected to $ssid" || notify-send "Wi-Fi" "Failed to connect to $ssid"
    fi
fi
