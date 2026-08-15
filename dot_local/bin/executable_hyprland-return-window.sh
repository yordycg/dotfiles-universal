#!/usr/bin/env bash

# Get active window JSON
ACTIVE_WIN=$(hyprctl activewindow -j)

# Extract address
ADDRESS=$(echo "$ACTIVE_WIN" | jq -r '.address')

# If no active window, exit
if [ "$ADDRESS" = "null" ] || [ -z "$ADDRESS" ]; then
    exit 0
fi

# Find the tag starting with from_ws_
ORIGINAL_WS=$(echo "$ACTIVE_WIN" | jq -r '.tags[] | select(startswith("from_ws_"))' | sed 's/from_ws_//' | head -n 1)

# Check if the window was tiled originally
WAS_TILED=$(echo "$ACTIVE_WIN" | jq -r '.tags[] | select(. == "was_tiled")' | head -n 1)

if [ -n "$ORIGINAL_WS" ]; then
    # If the window was originally tiled, restore its tiled layout state (unset floating)
    if [ "$WAS_TILED" = "was_tiled" ]; then
        hyprctl dispatch "hl.dsp.window.float({ action = 'unset', window = 'address:$ADDRESS' })"
        # Remove the tiling state tag
        hyprctl dispatch "hl.dsp.window.tag({ tag = '-was_tiled', window = 'address:$ADDRESS' })"
    fi
    
    # Move the window back to its original workspace silently
    hyprctl dispatch "hl.dsp.window.move({ workspace = '$ORIGINAL_WS', follow = false, window = 'address:$ADDRESS' })"
    # Remove the workspace tag
    hyprctl dispatch "hl.dsp.window.tag({ tag = '-from_ws_$ORIGINAL_WS', window = 'address:$ADDRESS' })"
else
    notify-send "Hyprland" "La ventana activa no tiene registrado un workspace de origen." -i dialog-information
fi
