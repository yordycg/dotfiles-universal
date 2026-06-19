#!/usr/bin/env bash
# =============================================================================
# provision/system/setup-tailscale.sh
# Automatización de Tailscale (VPN Mesh) - Versión Resiliente (Senior)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"

# Check silencioso — si tailscale ya está activo, salir sin output
if command -v tailscale &>/dev/null && tailscale status &>/dev/null 2>&1; then
    sudo tailscale set --accept-dns=true >/dev/null 2>&1 || true
    log_ok "Tailscale ya está activo y configurado."
    exit 0
fi

if ! command -v tailscale &>/dev/null; then
    log_warn "Tailscale no está instalado. Saltando configuración."
    exit 0
fi

log_info "Configurando Tailscale (Arquitectura de Confianza)..."

# 1. Asegurar que el daemon esté corriendo
if systemctl list-unit-files tailscaled.service &>/dev/null; then
    if ! systemctl is-active --quiet tailscaled; then
        log_info "Iniciando servicio tailscaled..."
        sudo systemctl enable --now tailscaled
    fi
fi

# 2. Gestión de estado de conexión
if tailscale status &>/dev/null; then
    log_ok "Tailscale ya está activo."
    
    # Aseguramos configuración óptima para Split DNS
    # 'accept-dns=true' es necesario para que MagicDNS y Split DNS funcionen
    sudo tailscale set --accept-dns=true >/dev/null 2>&1 || true
    log_ok "Configuración de red sincronizada con el Panel Web."
else
    log_warn "Tailscale no está autenticado."
    log_info "Por favor, ejecuta 'sudo tailscale up' para vincular este nodo."
fi
