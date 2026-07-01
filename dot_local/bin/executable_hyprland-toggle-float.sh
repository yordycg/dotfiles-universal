#!/usr/bin/env bash

# Toggle floating state for active window and apply a comfortable default size + center it.

width=${1:-1000}
height=${2:-700}

active=$(hyprctl activewindow -j)
floating=$(echo "$active" | jq ".floating")
addr=$(echo "$active" | jq -r ".address")
window="address:$addr"

if [[ "$floating" == "true" ]]; then
    hyprctl dispatch togglefloating "$window" >/dev/null
elif [[ -n "$addr" ]]; then
    hyprctl dispatch togglefloating "$window" >/dev/null
    hyprctl dispatch resizeactive exact "$width" "$height" "$window" >/dev/null
    hyprctl dispatch centerwindow "$window" >/dev/null
fi
