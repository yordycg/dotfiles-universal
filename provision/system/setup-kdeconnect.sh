#!/usr/bin/env bash
# =============================================================================
# provision/system/setup-kdeconnect.sh
# Automatización de KDE Connect y reglas de UFW
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"

log_info "Configurando KDE Connect y reglas de firewall..."

# 1. Configurar reglas UFW si ufw está instalado y activo
if command -v ufw &>/dev/null; then
    log_info "Configurando UFW para KDE Connect (puertos 1714:1764)..."
    
    # Verificar si ya existe regla TCP para 1714:1764
    if ! sudo ufw status | grep -q "1714:1764/tcp"; then
        sudo ufw allow 1714:1764/tcp >/dev/null
        log_ok "Regla UFW TCP 1714:1764 añadida."
    else
        log_info "Regla UFW TCP 1714:1764 ya existe."
    fi

    # Verificar si ya existe regla UDP para 1714:1764
    if ! sudo ufw status | grep -q "1714:1764/udp"; then
        sudo ufw allow 1714:1764/udp >/dev/null
        log_ok "Regla UFW UDP 1714:1764 añadida."
    else
        log_info "Regla UFW UDP 1714:1764 ya existe."
    fi

    # Recargar ufw si está activo
    if sudo ufw status | grep -q "Status: active"; then
        sudo ufw reload >/dev/null
        log_ok "UFW recargado."
    fi
else
    log_info "UFW no está instalado o activo. Omitiendo configuración de firewall."
fi

log_ok "KDE Connect configurado correctamente."
