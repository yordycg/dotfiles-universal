#!/usr/bin/env bash
# =============================================================================
# wallpaper-switch.sh — Rofi Wallpaper Selector
# Selects wallpapers from ~/Pictures/Wallpapers (repo real fuera del workspace)
# and applies them using swww, awww, or swaybg.
# =============================================================================
set -euo pipefail

# Directory locations
WALL_DIR="$HOME/Pictures/Wallpapers"

CACHE_DIR="$HOME/.cache/wall-thumbs"
TARGET_WALLPAPER="$HOME/.config/hypr/wallpaper"
ROFI_THEME="$HOME/.config/rofi/wallpaper_switcher.rasi"

if [ ! -d "$WALL_DIR" ]; then
    notify-send "Wallpaper Error" "No se encontró el directorio de fondos en $WALL_DIR" -u critical || true
    exit 1
fi

mkdir -p "$CACHE_DIR"
mkdir -p "$(dirname "$TARGET_WALLPAPER")"

# Collect wallpapers
shopt -s nullglob
wallpapers=(
    "$WALL_DIR"/*.jpg
    "$WALL_DIR"/*.jpeg
    "$WALL_DIR"/*.png
    "$WALL_DIR"/*.webp
    "$WALL_DIR"/*.gif
)
shopt -u nullglob

if [ ${#wallpapers[@]} -eq 0 ]; then
    notify-send "Wallpaper Error" "No se encontraron imágenes en $WALL_DIR" -u critical || true
    exit 1
fi

# Build Rofi list with Rofi icon protocol: filename\0icon\x1f/path/to/img
rofi_input=""
for img in "${wallpapers[@]}"; do
    filename=$(basename "$img")
    rofi_input+="${filename}\0icon\x1f${img}\n"
done

# Show Rofi selector
if [ -f "$ROFI_THEME" ]; then
    selected_name=$(printf "%b" "$rofi_input" | rofi -dmenu -i -show-icons -theme "$ROFI_THEME" -p "Wallpapers" || true)
else
    selected_name=$(printf "%b" "$rofi_input" | rofi -dmenu -i -show-icons -p "Wallpapers" || true)
fi

if [ -z "$selected_name" ]; then
    exit 0
fi

SELECTED_WALLPAPER="$WALL_DIR/$selected_name"

if [ ! -f "$SELECTED_WALLPAPER" ]; then
    exit 1
fi

# Update static symlink to active wallpaper
ln -sf "$SELECTED_WALLPAPER" "$TARGET_WALLPAPER"

# -----------------------------------------------------------------------------
# 1. Wallpaper Daemon Switching (swww > awww > swaybg)
# -----------------------------------------------------------------------------
if command -v swww >/dev/null 2>&1; then
    if ! swww query >/dev/null 2>&1; then
        swww-daemon >/dev/null 2>&1 &
        sleep 0.5
    fi
    swww img "$SELECTED_WALLPAPER" --transition-type wipe --transition-angle 225 --transition-fps 60 --transition-duration 0.8
elif command -v awww >/dev/null 2>&1; then
    if ! awww query >/dev/null 2>&1; then
        awww-daemon >/dev/null 2>&1 &
        sleep 0.5
    fi
    awww img "$SELECTED_WALLPAPER" --transition-type wipe --transition-angle 225 --transition-fps 60 --transition-duration 0.8
elif command -v swaybg >/dev/null 2>&1; then
    OLD_PIDS=$(pgrep -x "swaybg" || echo "")
    swaybg -i "$SELECTED_WALLPAPER" -m fill >/dev/null 2>&1 &
    sleep 0.15
    if [ -n "$OLD_PIDS" ]; then
        kill $OLD_PIDS >/dev/null 2>&1 || true
    fi
fi

# -----------------------------------------------------------------------------
# 2. Pywal / Color Theme Integration (DESACTIVADO TEMPORALMENTE)
# Descomentar las siguientes líneas en el futuro si se desea recalcular la
# paleta de colores del sistema según el wallpaper seleccionado.
# -----------------------------------------------------------------------------
# if command -v wal >/dev/null 2>&1; then
#     notify-send "Pywal" "Generando paleta de colores desde $selected_name..." -t 1500 || true
#     wal -i "$SELECTED_WALLPAPER" -n -q
# fi
#
# # Recargar SwayNC / Waybar si aplica:
# if pgrep -x swaync >/dev/null 2>&1; then
#     swaync-client -rs || true
# fi

notify-send "Wallpaper" "Fondo cambiado a $selected_name" -t 2000 || true
