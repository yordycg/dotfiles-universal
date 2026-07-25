#!/usr/bin/env bash
# =============================================================================
# wlogout.sh — Dynamic Wlogout Launcher with Resolution Scaling
# Calculates resolution-dependent dimensions, expands style_template.css,
# and launches wlogout with proper layer-shell parameters.
# =============================================================================
set -euo pipefail

CONFIG_DIR="$HOME/.config/wlogout"
TEMPLATE_FILE="$CONFIG_DIR/style_template.css"
STYLE_FILE="$CONFIG_DIR/style.css"
LAYOUT_FILE="$CONFIG_DIR/layout"

# 1. Detect resolution scaling from Hyprland or fallback to default
if command -v hyprctl >/dev/null 2>&1 && hyprctl monitors -j >/dev/null 2>&1; then
    resolution=$(hyprctl monitors -j | jq -r '.[0].height // 1080')
    scale=$(hyprctl monitors -j | jq -r '.[0].scale // 1')
else
    resolution=1080
    scale=1
fi

effective_height=$(awk "BEGIN {print int($resolution / $scale)}")

# 2. Calculate dynamic parameters based on resolution
if [ "$effective_height" -ge 1440 ]; then
    export fntSize=16
    export active_rad=30
    export button_rad=20
    export x_mgn=400
    export y_mgn=250
    export x_hvr=410
    export y_hvr=260
elif [ "$effective_height" -ge 1080 ]; then
    export fntSize=14
    export active_rad=25
    export button_rad=18
    export x_mgn=300
    export y_mgn=180
    export x_hvr=310
    export y_hvr=190
else
    export fntSize=12
    export active_rad=20
    export button_rad=15
    export x_mgn=200
    export y_mgn=120
    export x_hvr=205
    export y_hvr=125
fi

# 3. Export HOME for envsubst
export HOME

# 4. Substitute variables into style.css
if [ -f "$TEMPLATE_FILE" ]; then
    envsubst < "$TEMPLATE_FILE" > "$STYLE_FILE"
fi

# 5. Launch wlogout
exec wlogout \
    -l "$LAYOUT_FILE" \
    -C "$STYLE_FILE" \
    -b 2 \
    -c 0 \
    -r 0 \
    -p layer-shell \
    -B 0 \
    -T 0
