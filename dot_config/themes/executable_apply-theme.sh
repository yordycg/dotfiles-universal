#!/usr/bin/env bash
# =============================================================================
# apply-theme.sh — Gestor General de Temas del Sistema (Robusto con Debug)
# Aplica esquemas de 16 colores base y dispara recargas en caliente.
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
    notify-send "Theme Error" "Tema '$THEME' no encontrado" -u critical
    exit 1
fi

# Guardar estado actual
echo "$THEME" > "$THEMES_DIR/.current-theme"
echo -e "${GREEN}Aplicando tema: $THEME...${NC}"
notify-send "Themes" "Aplicando tema: $THEME" -t 2000

# ── 1. Hyprland ──────────────────────────────────────────────────────────────
if [ -f "$THEME_DIR/hypr/colors.lua" ]; then
    echo -e "${CYAN}→ Aplicando colores a Hyprland...${NC}"
    ln -sf "$THEME_DIR/hypr/colors.lua" "$HOME/.config/hypr/colors.lua"
    if command -v hyprctl &>/dev/null; then
        hyprctl reload || echo -e "${YELLOW}Warning: Failed to reload Hyprland config via hyprctl${NC}"
    fi
fi

# ── 2. Waybar ────────────────────────────────────────────────────────────────
if [ -f "$THEME_DIR/waybar/colors.css" ]; then
    echo -e "${CYAN}→ Aplicando colores a Waybar...${NC}"
    ln -sf "$THEME_DIR/waybar/colors.css" "$HOME/.config/waybar/colors/colors.css"
    LAUNCH_SCRIPT="$HOME/.config/waybar/scripts/launch.sh"
    if [ -f "$LAUNCH_SCRIPT" ]; then
        if command -v hyprctl &>/dev/null; then
            hyprctl dispatch "hl.dsp.exec_cmd('$LAUNCH_SCRIPT')" || echo -e "${RED}Error: Failed to launch Waybar via hyprctl${NC}"
        else
            bash "$LAUNCH_SCRIPT" &
        fi
    else
        echo -e "${YELLOW}Warning: Waybar launch script not found at $LAUNCH_SCRIPT${NC}"
    fi
fi

# ── 3. SwayNC ────────────────────────────────────────────────────────────────
if [ -f "$THEME_DIR/swaync/colors.css" ]; then
    echo -e "${CYAN}→ Aplicando colores a SwayNC...${NC}"
    ln -sf "$THEME_DIR/swaync/colors.css" "$HOME/.config/swaync/colors/colors.css"
    if pgrep -x "swaync" >/dev/null; then
        swaync-client -rs || echo -e "${YELLOW}Warning: Failed to reload SwayNC config${NC}"
    else
        echo -e "${YELLOW}Warning: SwayNC daemon is not running. Skipping client reload.${NC}"
    fi
fi

# ── 4. Kitty ─────────────────────────────────────────────────────────────────
if [ -f "$THEME_DIR/kitty/colors.conf" ]; then
    echo -e "${CYAN}→ Aplicando colores a Kitty...${NC}"
    ln -sf "$THEME_DIR/kitty/colors.conf" "$HOME/.config/kitty/colors/colors.conf"
    if pgrep -x "kitty" >/dev/null; then
        kill -USR1 $(pgrep kitty) || echo -e "${YELLOW}Warning: Failed to send SIGUSR1 to Kitty instances${NC}"
    fi
fi

# ── 5. Rofi ──────────────────────────────────────────────────────────────────
if [ -f "$THEME_DIR/rofi/colors.rasi" ]; then
    echo -e "${CYAN}→ Aplicando colores a Rofi...${NC}"
    ln -sf "$THEME_DIR/rofi/colors.rasi" "$HOME/.config/rofi/type-2/colors/colors.rasi"
fi

# ── 6. Wlogout ───────────────────────────────────────────────────────────────
if [ -f "$THEME_DIR/wlogout/colors.css" ]; then
    echo -e "${CYAN}→ Aplicando colores a Wlogout...${NC}"
    ln -sf "$THEME_DIR/wlogout/colors.css" "$HOME/.config/wlogout/colors/colors.css"
fi

# ── 7. Tmux ──────────────────────────────────────────────────────────────────
if [ -f "$THEME_DIR/tmux/colors.conf" ]; then
    echo -e "${CYAN}→ Aplicando colores a Tmux...${NC}"
    ln -sf "$THEME_DIR/tmux/colors.conf" "$HOME/.config/tmux/active_palette.conf"
    if pgrep -x "tmux" >/dev/null || [ -n "${TMUX:-}" ]; then
        tmux source-file "$HOME/.config/tmux/tmux.conf" || echo -e "${YELLOW}Warning: Failed to source Tmux configuration${NC}"
    fi
fi

# ── 8. Wallpaper ──────────────────────────────────────────────────────────────
WALLPAPER=$(find "$THEME_DIR/wallpapers" -type f \( -name "*.jpg" -o -name "*.png" \) 2>/dev/null | head -n 1 || echo "")
if [ -n "$WALLPAPER" ]; then
    echo -e "${CYAN}→ Cambiando fondo de pantalla...${NC}"
    ln -sf "$WALLPAPER" "$HOME/.config/hypr/wallpaper"
    if pgrep -x "hyprpaper" >/dev/null; then
        hyprctl hyprpaper preload "$WALLPAPER" >/dev/null 2>&1 || true
        hyprctl hyprpaper wallpaper ",$WALLPAPER" >/dev/null 2>&1 || true
        hyprctl hyprpaper unload all >/dev/null 2>&1 || true
    fi
fi

echo -e "${GREEN}✓ ¡Tema '$THEME' aplicado con éxito!${NC}"
