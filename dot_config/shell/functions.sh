# -----------------------------------------------------------------------------
# SHELL FUNCTIONS LOADER
# -----------------------------------------------------------------------------

if [ -d "$HOME/.config/shell/functions" ]; then
    for func_file in "$HOME/.config/shell/functions"/*.sh; do
        if [ -f "$func_file" ]; then
            source "$func_file"
        fi
    done
fi
