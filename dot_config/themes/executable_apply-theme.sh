#!/usr/bin/env bash
# =============================================================================
# apply-theme.sh — Gestor General de Temas del Sistema (Robusto con Debug)
# =============================================================================
set -euo pipefail

# Colores de Terminal
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

THEME="${1:-}"
THEMES_DIR="$HOME/.config/themes"
THEME_DIR="$THEMES_DIR/$THEME"

if [ -z "$THEME" ]; then
    echo -e "${YELLOW}Uso: $0 <nombre-del-tema>${NC}"
    exit 1
fi

if [ ! -d "$THEME_DIR" ]; then
    echo -e "${RED}Error: El tema '$THEME' no existe en $THEME_DIR${NC}"
    exit 1
fi

# Guardar estado actual
mkdir -p "$THEMES_DIR"
echo "$THEME" > "$THEMES_DIR/.current-theme"
echo -e "${GREEN}Aplicando tema: $THEME...${NC}"

# Función segura para notificaciones sin GUI
notify() {
    if command -v notify-send &>/dev/null && ([ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]); then
        notify-send "Themes" "$1" -t 2000 || true
    else
        echo -e "${CYAN}[Notificación] $1${NC}"
    fi
}

notify "Aplicando tema: $THEME"

# Función segura para crear enlaces simbólicos asegurando directorios padres
safe_link() {
    local src="$1"
    local dest="$2"
    if [ -f "$src" ]; then
        mkdir -p "$(dirname "$dest")"
        ln -sf "$src" "$dest"
    else
        echo -e "${YELLOW}Warning: Source file '$src' not found. Skipping.${NC}"
    fi
}

# ── 1. Hyprland ──────────────────────────────────────────────────────────────
if [ -f "$THEME_DIR/hypr/colors.lua" ]; then
    echo -e "${CYAN}→ Aplicando colores a Hyprland...${NC}"
    safe_link "$THEME_DIR/hypr/colors.lua" "$HOME/.config/hypr/colors.lua"
    if command -v hyprctl &>/dev/null && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        hyprctl reload || echo -e "${YELLOW}Warning: Failed to reload Hyprland config${NC}"
    fi
fi

# ── 2. Waybar ────────────────────────────────────────────────────────────────
if [ -f "$THEME_DIR/waybar/colors.css" ]; then
    echo -e "${CYAN}→ Aplicando colores a Waybar...${NC}"
    safe_link "$THEME_DIR/waybar/colors.css" "$HOME/.config/waybar/colors/colors.css"
    LAUNCH_SCRIPT="$HOME/.config/waybar/scripts/launch.sh"
    if [ -f "$LAUNCH_SCRIPT" ]; then
        if command -v hyprctl &>/dev/null && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
            hyprctl dispatch "hl.dsp.exec_cmd('$LAUNCH_SCRIPT')" || echo -e "${RED}Error: Failed to launch Waybar${NC}"
        else
            bash "$LAUNCH_SCRIPT" &>/dev/null &
        fi
    fi
fi

# ── 3. SwayNC ────────────────────────────────────────────────────────────────
if [ -f "$THEME_DIR/swaync/colors.css" ]; then
    echo -e "${CYAN}→ Aplicando colores a SwayNC...${NC}"
    safe_link "$THEME_DIR/swaync/colors.css" "$HOME/.config/swaync/colors/colors.css"
    if pgrep -x "swaync" >/dev/null; then
        swaync-client -rs || echo -e "${YELLOW}Warning: Failed to reload SwayNC config${NC}"
    fi
fi

# ── 4. Kitty ─────────────────────────────────────────────────────────────────
if [ -f "$THEME_DIR/kitty/colors.conf" ]; then
    echo -e "${CYAN}→ Aplicando colores a Kitty...${NC}"
    safe_link "$THEME_DIR/kitty/colors.conf" "$HOME/.config/kitty/colors/colors.conf"
    if pgrep -x "kitty" >/dev/null; then
        kill -USR1 $(pgrep kitty) || echo -e "${YELLOW}Warning: Failed to reload Kitty instances${NC}"
    fi
fi

# ── 5. Rofi ──────────────────────────────────────────────────────────────────
if [ -f "$THEME_DIR/rofi/colors.rasi" ]; then
    echo -e "${CYAN}→ Aplicando colores a Rofi...${NC}"
    safe_link "$THEME_DIR/rofi/colors.rasi" "$HOME/.config/rofi/type-2/colors/colors.rasi"
fi

# ── 6. Wlogout ───────────────────────────────────────────────────────────────
if [ -f "$THEME_DIR/wlogout/colors.css" ]; then
    echo -e "${CYAN}→ Aplicando colores a Wlogout...${NC}"
    safe_link "$THEME_DIR/wlogout/colors.css" "$HOME/.config/wlogout/colors/colors.css"
fi

# ── 7. Tmux ──────────────────────────────────────────────────────────────────
if [ -f "$THEME_DIR/tmux/colors.conf" ]; then
    echo -e "${CYAN}→ Aplicando colores a Tmux...${NC}"
    safe_link "$THEME_DIR/tmux/colors.conf" "$HOME/.config/tmux/colors.conf"
    if pgrep -x "tmux" >/dev/null || [ -n "${TMUX:-}" ]; then
        tmux source-file "$HOME/.config/tmux/colors.conf" || echo -e "${YELLOW}Warning: Failed to source Tmux colors${NC}"
    fi
fi

# ── 8. Wallpaper ──────────────────────────────────────────────────────────────
WALLPAPER=$(find "$THEME_DIR/wallpapers" -type f \( -name "*.jpg" -o -name "*.png" \) 2>/dev/null | head -n 1 || echo "")
if [ -n "$WALLPAPER" ]; then
    echo -e "${CYAN}→ Cambiando fondo de pantalla...${NC}"
    safe_link "$WALLPAPER" "$HOME/.config/hypr/wallpaper"
    if command -v swaybg &>/dev/null && [ -n "${WAYLAND_DISPLAY:-}" ]; then
        OLD_SWAYBG_PIDS=$(pgrep -x "swaybg" || echo "")
        swaybg -i "$WALLPAPER" -m fill >/dev/null 2>&1 &
        sleep 0.15
        if [ -n "$OLD_SWAYBG_PIDS" ]; then
            kill $OLD_SWAYBG_PIDS >/dev/null 2>&1 || true
        fi
    fi
fi

echo -e "${GREEN}✓ ¡Tema '$THEME' aplicado con éxito!${NC}"
