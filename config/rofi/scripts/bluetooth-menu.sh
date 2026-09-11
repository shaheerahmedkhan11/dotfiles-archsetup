#!/usr/bin/env bash

rofi_dir="$HOME/.config/rofi"

bt_powered=$(bluetoothctl show 2>/dev/null | grep "Powered: yes" || true)

if [ -z "$bt_powered" ]; then
    toggle_opt="󰂯  Turn Bluetooth On"
    chosen=$(printf "%s\n" "$toggle_opt" | rofi -dmenu -theme "$rofi_dir/bluetooth-menu.rasi" -p "Bluetooth")
    if [ "$chosen" = "$toggle_opt" ]; then
        bluetoothctl power on && notify-send "Bluetooth" "Bluetooth Powered On"
    fi
    exit 0
fi

build_menu() {
    echo "󰂲  Turn Bluetooth Off"
    echo "󰂰  Scan / Discover Devices"
    
    bluetoothctl devices 2>/dev/null | while IFS= read -r line; do
        [ -z "$line" ] && continue
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d' ' -f3-)
        [ -z "$name" ] && name="$mac"
        
        if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
            echo "󰄲  󰂱  $name ($mac)"
        else
            echo "    󰂯  $name ($mac)"
        fi
    done
}

chosen=$(build_menu | rofi -dmenu -theme "$rofi_dir/bluetooth-menu.rasi" -p "Bluetooth")

[ -z "$chosen" ] && exit 0

case "$chosen" in
    *"Turn Bluetooth Off")
        bluetoothctl power off && notify-send "Bluetooth" "Bluetooth Powered Off"
        exit 0
        ;;
    *"Scan / Discover Devices")
        notify-send "Bluetooth" "Scanning for nearby devices (5s)..."
        bluetoothctl --timeout 5 scan on &>/dev/null
        exec "$0"
        exit 0
        ;;
esac

# Extract MAC address
mac=$(echo "$chosen" | grep -oE '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}')
name=$(echo "$chosen" | sed -E 's/^[ 󰄲󰂱󰂯]+//' | sed -E 's/\s*\([0-9A-Fa-f:]+\)$//')

if [ -n "$mac" ]; then
    if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
        bluetoothctl disconnect "$mac" && notify-send "Bluetooth" "Disconnected from $name"
    else
        notify-send "Bluetooth" "Connecting to $name..."
        bluetoothctl connect "$mac" && notify-send "Bluetooth" "Connected to $name" || notify-send "Bluetooth" "Failed to connect to $name"
    fi
fi
