#!/usr/bin/env bash
# =============================================================================
# hypridle-audio-inhibit.sh — Evita el bloqueo de pantalla si hay reproducción de audio
# =============================================================================

IDLE_DAEMON="hypridle"
PAUSED=false

# Asegurar que hypridle sea reanudado si el script termina
cleanup() {
    if [ "$PAUSED" = true ]; then
        killall -CONT "$IDLE_DAEMON" 2>/dev/null
    fi
}
trap cleanup EXIT INT TERM

while true; do
    if pactl list sinks | grep -q "State: RUNNING"; then
        if [ "$PAUSED" = false ]; then
            killall -STOP "$IDLE_DAEMON" 2>/dev/null && PAUSED=true
        fi
    else
        if [ "$PAUSED" = true ]; then
            killall -CONT "$IDLE_DAEMON" 2>/dev/null && PAUSED=false
        fi
    fi
    sleep 5
done
