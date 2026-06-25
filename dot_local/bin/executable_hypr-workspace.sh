#!/usr/bin/env bash
# Switch workspace on its assigned monitor, keeping focus on the original monitor,
# and doing nothing if the target workspace is already visible.

TARGET_WORKSPACE="$1"
if [ -z "$TARGET_WORKSPACE" ]; then
    echo "Usage: $0 <workspace_id>"
    exit 1
fi

# 1. Check if the target workspace is already active/visible on any monitor
if hyprctl monitors -j | jq -e ".[] | select(.activeWorkspace.id == ($TARGET_WORKSPACE | tonumber))" >/dev/null 2>&1; then
    # The workspace is already visible, no action needed!
    exit 0
fi

# 2. Get the currently active monitor
ORIGINAL_MONITOR=$(hyprctl activeworkspace | awk '{print $NF}' | tr -d ':')

# 3. Switch to the target workspace (this may shift focus to its monitor)
hyprctl dispatch workspace "$TARGET_WORKSPACE"

# 4. Return focus to the original monitor
hyprctl dispatch focusmonitor "$ORIGINAL_MONITOR"
