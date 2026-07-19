#!/usr/bin/env bash
# =============================================================================
# apply-theme.sh — Gestor Dinámico de Temas en Caliente (Refresco de UI)
# Aplica los enlaces y notifica/recarga los entornos gráficos activos.
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
LINK_SCRIPT="$THEMES_DIR/link-theme.sh"
THEME_DIR="$THEMES_DIR/$THEME"

if [ -z "$THEME" ]; then
    echo -e "${YELLOW}Uso: $0 <nombre-del-tema>${NC}"
    exit 1
fi

if [ ! -d "$THEME_DIR" ]; then
    echo -e "${RED}Error: El tema '$THEME' no existe en $THEME_DIR${NC}"
    exit 1
fi

# 1. Ejecutar el enlazador estático
if [ -f "$LINK_SCRIPT" ]; then
    echo -e "${CYAN}→ Generando enlaces simbólicos del tema...${NC}"
    bash "$LINK_SCRIPT" "$THEME"
else
    echo -e "${RED}Error: Enlazador estático no encontrado en $LINK_SCRIPT${NC}"
    exit 1
fi

# Función segura para notificaciones visuales (solo si hay servidor gráfico activo)
notify() {
    if command -v notify-send &>/dev/null && ([ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]); then
        notify-send "Themes" "$1" -t 2000 || true
    else
        echo -e "${CYAN}[Notificación] $1${NC}"
    fi
}

notify "Aplicando tema: $THEME"

# 2. Recargar Hyprland
if command -v hyprctl &>/dev/null && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    echo -e "${CYAN}→ Recargando configuración de Hyprland...${NC}"
    hyprctl reload || echo -e "${YELLOW}Warning: Failed to reload Hyprland config${NC}"
fi

# 3. Recargar/Iniciar Waybar (solo si Hyprland está activo)
LAUNCH_SCRIPT="$HOME/.config/waybar/scripts/launch.sh"
if [ -f "$LAUNCH_SCRIPT" ] && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    echo -e "${CYAN}→ Refrescando Waybar...${NC}"
    if command -v hyprctl &>/dev/null; then
        hyprctl dispatch "hl.dsp.exec_cmd('$LAUNCH_SCRIPT')" || echo -e "${RED}Error: Failed to launch Waybar${NC}"
    else
        bash "$LAUNCH_SCRIPT" &>/dev/null &
    fi
fi

# 4. Recargar SwayNC
if [ -f "$THEME_DIR/swaync/colors.css" ] && pgrep -x "swaync" >/dev/null; then
    echo -e "${CYAN}→ Recargando SwayNC...${NC}"
    swaync-client -rs || echo -e "${YELLOW}Warning: Failed to reload SwayNC config${NC}"
fi

# 5. Recargar Kitty
if [ -f "$THEME_DIR/kitty/colors.conf" ] && pgrep -x "kitty" >/dev/null; then
    echo -e "${CYAN}→ Recargando instancias de Kitty...${NC}"
    kill -USR1 $(pgrep kitty) || echo -e "${YELLOW}Warning: Failed to reload Kitty instances${NC}"
fi

# 6. Recargar Tmux
if [ -f "$THEME_DIR/tmux/colors.conf" ] && (pgrep -x "tmux" >/dev/null || [ -n "${TMUX:-}" ]); then
    echo -e "${CYAN}→ Recargando Tmux...${NC}"
    tmux source-file "$HOME/.config/tmux/colors.conf" || echo -e "${YELLOW}Warning: Failed to source Tmux colors${NC}"
fi

# 7. Cambiar Wallpaper en Caliente (solo en Wayland)
WALLPAPER=$(find "$THEME_DIR/wallpapers" -type f \( -name "*.jpg" -o -name "*.png" \) 2>/dev/null | head -n 1 || echo "")
if [ -n "$WALLPAPER" ] && [ -n "${WAYLAND_DISPLAY:-}" ] && command -v swaybg &>/dev/null; then
    echo -e "${CYAN}→ Cambiando fondo de pantalla...${NC}"
    OLD_SWAYBG_PIDS=$(pgrep -x "swaybg" || echo "")
    swaybg -i "$WALLPAPER" -m fill >/dev/null 2>&1 &
    sleep 0.15
    if [ -n "$OLD_SWAYBG_PIDS" ]; then
        kill $OLD_SWAYBG_PIDS >/dev/null 2>&1 || true
    fi
fi

echo -e "${GREEN}✓ ¡Tema '$THEME' aplicado con éxito en caliente!${NC}"
