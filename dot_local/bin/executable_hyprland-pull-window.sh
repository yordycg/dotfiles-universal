#!/usr/bin/env bash

# Get active workspace ID
ACTIVE_WS=$(hyprctl activeworkspace -j | jq -r '.id')

# Get list of clients, exclude those on the active workspace, and format them for rofi
# We match only windows that have a valid address and are not on the active workspace.
# Special workspaces (like special:magic) are kept so they can be pulled too.
CLIENTS=$(hyprctl clients -j | jq -r '.[] | select(.workspace.id != '"$ACTIVE_WS"' and .address != "") | "[\(.workspace.name)] \(.class) | \(.title) \t(\(.address))"')

if [ -z "$CLIENTS" ]; then
    notify-send "Hyprland" "No hay ventanas en otros workspaces para traer." -i dialog-information
    exit 0
fi

SELECTED=$(echo "$CLIENTS" | rofi -dmenu -i -p "Traer ventana al Workspace $ACTIVE_WS" -theme-str 'window {width: 40%;}')

if [ -n "$SELECTED" ]; then
    # Extract the address (the last hex string starting with 0x)
    ADDRESS=$(echo "$SELECTED" | grep -oE '0x[0-9a-fA-F]+' | tail -n 1)
    # Extract the original workspace name
    FROM_WS=$(echo "$SELECTED" | cut -d ']' -f 1 | tr -d '[')
    
    if [ -n "$ADDRESS" ] && [ -n "$FROM_WS" ]; then
        # Check if the window was tiled before pulling
        WAS_TILED=$(hyprctl clients -j | jq -r '.[] | select(.address == "'$ADDRESS'") | .floating == false')
        
        # Tag the window with its original workspace
        hyprctl dispatch "hl.dsp.window.tag({ tag = '+from_ws_$FROM_WS', window = 'address:$ADDRESS' })"
        
        # If it was tiled, tag it so we can tile it back on return
        if [ "$WAS_TILED" = "true" ]; then
            hyprctl dispatch "hl.dsp.window.tag({ tag = '+was_tiled', window = 'address:$ADDRESS' })"
        fi
        
        # Move the window to the active workspace
        hyprctl dispatch "hl.dsp.window.move({ workspace = $ACTIVE_WS, window = 'address:$ADDRESS' })"
        # Make it float
        hyprctl dispatch "hl.dsp.window.float({ action = 'set', window = 'address:$ADDRESS' })"
        # Resize to comfort default float size (1200x800)
        hyprctl dispatch "hl.dsp.window.resize({ x = 1200, y = 800, window = 'address:$ADDRESS' })"
        # Center it on the screen
        hyprctl dispatch "hl.dsp.window.center({ window = 'address:$ADDRESS' })"
    fi
fi
