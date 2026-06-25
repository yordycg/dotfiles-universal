#!/usr/bin/env bash
# Switch workspace on its assigned monitor, keeping focus on the original monitor,
# and doing nothing if the target workspace is already visible.

TARGET_WORKSPACE="$1"
if [ -z "$TARGET_WORKSPACE" ]; then
    echo "Usage: $0 <workspace_id>"
    exit 1
fi

# 1. Get the currently active monitor
ORIGINAL_MONITOR=$(hyprctl activeworkspace | head -n 1 | awk '{print $NF}' | tr -d ':')

# 2. Check if the target workspace is already active/visible on any monitor
TARGET_MONITOR=$(hyprctl monitors -j | jq -r ".[] | select(.activeWorkspace.id == ($TARGET_WORKSPACE | tonumber)) | .name")

if [ -n "$TARGET_MONITOR" ] && [ "$TARGET_MONITOR" != "null" ]; then
    # The workspace is already visible on some monitor.
    # Just focus that monitor!
    hyprctl dispatch focusmonitor "$TARGET_MONITOR"
    exit 0
fi

# 3. Switch to the target workspace (this may shift focus to its monitor)
hyprctl dispatch workspace "$TARGET_WORKSPACE"

# 4. Return focus to the original monitor
hyprctl dispatch focusmonitor "$ORIGINAL_MONITOR"
