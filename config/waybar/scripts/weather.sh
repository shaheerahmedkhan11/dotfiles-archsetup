#!/usr/bin/env bash
trap '' PIPE

CACHE_FILE="/tmp/waybar_weather_cache.json"
CACHE_TIME=900 # 15 minutes

if [ -f "$CACHE_FILE" ]; then
    FILE_TIME=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
    CUR_TIME=$(date +%s)
    AGE=$((CUR_TIME - FILE_TIME))
    if [ $AGE -lt $CACHE_TIME ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Fetch from wttr.in
WEATHER_JSON=$(curl -s --connect-timeout 3 "https://wttr.in/?format=j1" 2>/dev/null)

if [ -n "$WEATHER_JSON" ] && echo "$WEATHER_JSON" | grep -q '"current_condition"'; then
    TEMP_C=$(echo "$WEATHER_JSON" | grep -oP '"temp_C":\s*"\K[^"]+' | head -n 1)
    FEELS_C=$(echo "$WEATHER_JSON" | grep -oP '"FeelsLikeC":\s*"\K[^"]+' | head -n 1)
    WEATHER_DESC=$(echo "$WEATHER_JSON" | grep -oP '"value":\s*"\K[^"]+' | head -n 1)
    HUMIDITY=$(echo "$WEATHER_JSON" | grep -oP '"humidity":\s*"\K[^"]+' | head -n 1)
    WIND_KMPH=$(echo "$WEATHER_JSON" | grep -oP '"windspeedKmph":\s*"\K[^"]+' | head -n 1)
    
    ICON="󰖐"
    case "$WEATHER_DESC" in
        *Sunny*|*Clear*) ICON="󰖙" ;;
        *Partly*cloudy*|*Cloudy*) ICON="󰖕" ;;
        *Overcast*) ICON="󰖐" ;;
        *Rain*|*Drizzle*|*Shower*) ICON="󰖖" ;;
        *Thunderstorm*|*Storm*) ICON="󰙾" ;;
        *Snow*|*Blizzard*) ICON="󰖘" ;;
        *Fog*|*Mist*|*Haze*) ICON="󰖑" ;;
    esac

    OUT="{\"text\": \"$ICON ${TEMP_C}°C\", \"tooltip\": \"Condition: $WEATHER_DESC\\nFeels like: ${FEELS_C}°C\\nHumidity: ${HUMIDITY}%\\nWind: ${WIND_KMPH} km/h\", \"class\": \"weather\"}"
    echo "$OUT" > "$CACHE_FILE"
    printf '%s\n' "$OUT" 2>/dev/null
else
    if [ -f "$CACHE_FILE" ]; then
        cat "$CACHE_FILE"
    else
        echo "{\"text\": \"󰖐 --°C\", \"tooltip\": \"Weather unavailable\", \"class\": \"weather\"}"
    fi
fi
