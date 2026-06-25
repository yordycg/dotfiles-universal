#!/usr/bin/env bash
# =============================================================================
# volume.sh — Control de Volumen con Notificaciones Visuales para Mako
# =============================================================================
set -euo pipefail

# 1. Ejecutar la acción de audio
case "${1:-}" in
    up)
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        ;;
    down)
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        ;;
    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;
    *)
        echo "Uso: $0 {up|down|mute}"
        exit 1
        ;;
esac

# 2. Obtener estado actual
MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]+(?=%)' | head -n 1 || echo "0")

# 3. Enviar notificación con barra de progreso
if [ "$MUTE" = "yes" ]; then
    notify-send -h string:x-canonical-private-synchronous:volume_notif \
                -h int:value:0 \
                -i audio-volume-muted \
                "Silenciado"
else
    # Seleccionar icono dinámico según nivel
    if [ "$VOLUME" -lt 30 ]; then
        ICON="audio-volume-low"
    elif [ "$VOLUME" -lt 70 ]; then
        ICON="audio-volume-medium"
    else
        ICON="audio-volume-high"
    fi
    
    notify-send -h string:x-canonical-private-synchronous:volume_notif \
                -h int:value:"$VOLUME" \
                -i "$ICON" \
                "Volumen: $VOLUME%"
fi
