#!/usr/bin/env bash

CACHE_FILE="/tmp/waybar_updates_cache.json"
CACHE_TIME=1800

if [ -f "$CACHE_FILE" ]; then
    FILE_TIME=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
    CUR_TIME=$(date +%s)
    AGE=$((CUR_TIME - FILE_TIME))
    if [ "$AGE" -lt "$CACHE_TIME" ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

export UPDATES_RAW=$(timeout 8 checkupdates 2>/dev/null || true)
export AUR_RAW=$(timeout 15 yay -Qua 2>/dev/null || true)

python3 - <<'PYEOF'
import json, os

updates_raw = os.environ.get("UPDATES_RAW", "").strip()
aur_raw = os.environ.get("AUR_RAW", "").strip()

official_pkgs = [line.split()[0] for line in updates_raw.splitlines() if line.strip()]
aur_pkgs = [line.split()[0] for line in aur_raw.splitlines() if line.strip()]

official_count = len(official_pkgs)
aur_count = len(aur_pkgs)
total = official_count + aur_count

cache_file = "/tmp/waybar_updates_cache.json"

if total > 0:
    tooltip_lines = ["󰏗 Pending Updates: {0}".format(total)]
    if official_count > 0:
        sample_off = ", ".join(official_pkgs[:8])
        if official_count > 8:
            sample_off += f" (+{official_count - 8} more)"
        tooltip_lines.append(f"Official ({official_count}): {sample_off}")
    if aur_count > 0:
        sample_aur = ", ".join(aur_pkgs[:8])
        if aur_count > 8:
            sample_aur += f" (+{aur_count - 8} more)"
        tooltip_lines.append(f"AUR ({aur_count}): {sample_aur}")
    tooltip_lines.append("")
    tooltip_lines.append("Left-Click: Update system (yay -Syu)")

    out = {
        "text": "󰏗 {0}".format(total),
        "tooltip": "\\n".join(tooltip_lines),
        "class": "updates"
    }
else:
    out = {
        "text": "󰅕 0",
        "tooltip": "System is up to date\\n\\nLeft-Click: Check for updates",
        "class": "updated"
    }

json_str = json.dumps(out, ensure_ascii=False)
with open(cache_file, "w") as f:
    f.write(json_str + "\n")
print(json_str)
PYEOF

