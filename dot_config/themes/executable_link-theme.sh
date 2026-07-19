#!/usr/bin/env bash
# =============================================================================
# link-theme.sh — Enlazador Estático de Archivos de Tema (Silencioso)
# Crea los symlinks correspondientes al tema en disco sin efectos secundarios.
# =============================================================================
set -euo pipefail

THEME="${1:-}"
THEMES_DIR="$HOME/.config/themes"
THEME_DIR="$THEMES_DIR/$THEME"

if [ -z "$THEME" ]; then
    echo "Uso: $0 <nombre-del-tema>"
    exit 1
fi

if [ ! -d "$THEME_DIR" ]; then
    echo "Error: El tema '$THEME' no existe en $THEME_DIR"
    exit 1
fi

# Guardar estado actual de forma silenciosa
mkdir -p "$THEMES_DIR"
echo "$THEME" > "$THEMES_DIR/.current-theme"

# Función segura para crear enlaces simbólicos asegurando directorios padres
safe_link() {
    local src="$1"
    local dest="$2"
    if [ -f "$src" ]; then
        mkdir -p "$(dirname "$dest")"
        ln -sf "$src" "$dest"
    fi
}

# 1. Hyprland
if [ -f "$THEME_DIR/hypr/colors.lua" ]; then
    safe_link "$THEME_DIR/hypr/colors.lua" "$HOME/.config/hypr/colors.lua"
fi

# 2. Waybar
if [ -f "$THEME_DIR/waybar/colors.css" ]; then
    safe_link "$THEME_DIR/waybar/colors.css" "$HOME/.config/waybar/colors/colors.css"
fi

# 3. SwayNC
if [ -f "$THEME_DIR/swaync/colors.css" ]; then
    safe_link "$THEME_DIR/swaync/colors.css" "$HOME/.config/swaync/colors/colors.css"
fi

# 4. Kitty
if [ -f "$THEME_DIR/kitty/colors.conf" ]; then
    safe_link "$THEME_DIR/kitty/colors.conf" "$HOME/.config/kitty/colors/colors.conf"
fi

# 5. Rofi
if [ -f "$THEME_DIR/rofi/colors.rasi" ]; then
    safe_link "$THEME_DIR/rofi/colors.rasi" "$HOME/.config/rofi/type-2/colors/colors.rasi"
fi

# 6. Wlogout
if [ -f "$THEME_DIR/wlogout/colors.css" ]; then
    safe_link "$THEME_DIR/wlogout/colors.css" "$HOME/.config/wlogout/colors/colors.css"
fi

# 7. Tmux
if [ -f "$THEME_DIR/tmux/colors.conf" ]; then
    safe_link "$THEME_DIR/tmux/colors.conf" "$HOME/.config/tmux/colors.conf"
fi

# 8. Wallpaper
WALLPAPER=$(find "$THEME_DIR/wallpapers" -type f \( -name "*.jpg" -o -name "*.png" \) 2>/dev/null | head -n 1 || echo "")
if [ -n "$WALLPAPER" ]; then
    safe_link "$WALLPAPER" "$HOME/.config/hypr/wallpaper"
fi
