#!/usr/bin/env bash
# =============================================================================
# brightness.sh — Control de Brillo con Barra de Progreso para Mako
# =============================================================================
set -euo pipefail

# 1. Ejecutar acción de brillo
case "${1:-}" in
    up)
        brightnessctl set +5% >/dev/null
        ;;
    down)
        brightnessctl set 5%- >/dev/null
        ;;
    *)
        echo "Uso: $0 {up|down}"
        exit 1
        ;;
esac

# 2. Obtener porcentaje de brillo actual
MAX=$(brightnessctl max)
CURRENT=$(brightnessctl get)
PERCENT=$(( CURRENT * 100 / MAX ))

# 3. Enviar notificación con barra de progreso
notify-send -a brightness-hud \
            -h string:x-canonical-private-synchronous:brightness_notif \
            -h int:value:"$PERCENT" \
            -i display-brightness \
            "Brillo: $PERCENT%"
