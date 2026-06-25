#!/usr/bin/env bash
# =============================================================================
# media-control.sh — Control de Reproductor y Notificación de Metadatos
# =============================================================================
set -euo pipefail

# 1. Ejecutar la acción del reproductor
playerctl "${1:-play-pause}"

# Pequeña espera para que el reproductor actualice sus metadatos internos
sleep 0.15

# 2. Extraer metadatos de la canción activa
STATUS=$(playerctl status 2>/dev/null || echo "Detenido")
TITLE=$(playerctl metadata title 2>/dev/null || echo "")
ARTIST=$(playerctl metadata artist 2>/dev/null || echo "")

# 3. Enviar notificación de estado
if [ "$STATUS" = "Playing" ] && [ -n "$TITLE" ]; then
    notify-send -h string:x-canonical-private-synchronous:media_notif \
                -i audio-x-generic \
                "Now Playing" \
                "<b>$TITLE</b>\n<i>$ARTIST</i>"
elif [ "$STATUS" = "Paused" ]; then
    notify-send -h string:x-canonical-private-synchronous:media_notif \
                -i audio-x-generic \
                "Pausado" \
                "<b>$TITLE</b>"
fi
