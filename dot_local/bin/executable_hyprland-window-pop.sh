#!/usr/bin/env bash

# omarchy:summary=Toggle to pop-out a tile to stay fixed on a display basis.
# omarchy:args=[width height]

width=${1:-1300}
height=${2:-900}

active=$(hyprctl activewindow -j)
pinned=$(echo "$active" | jq ".pinned")
addr=$(echo "$active" | jq -r ".address")
window="address:$addr"

if [[ "$pinned" == "true" ]]; then
    hyprctl dispatch pin "$window" >/dev/null
    hyprctl dispatch togglefloating "$window" >/dev/null
elif [[ -n "$addr" ]]; then
    hyprctl dispatch togglefloating "$window" >/dev/null
    hyprctl dispatch resizeactive exact "$width" "$height" "$window" >/dev/null
    hyprctl dispatch centerwindow "$window" >/dev/null
    hyprctl dispatch pin "$window" >/dev/null
    hyprctl dispatch alterzorder top "$window" >/dev/null
fi
