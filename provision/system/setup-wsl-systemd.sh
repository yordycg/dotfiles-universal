#!/usr/bin/env bash
# =============================================================================
# provision/system/setup-wsl-systemd.sh
# Habilita Systemd en WSL de forma no interactiva e idempotente (Sudo-Space)
# =============================================================================
set -euo pipefail

# Importar logger si se corre de forma independiente
if [ -f "$(dirname "$0")/../lib/logging.sh" ]; then
    source "$(dirname "$0")/../lib/logging.sh"
fi

# Detectar WSL
if [ "${NODE_IS_WSL:-}" = "true" ] || grep -qi microsoft /proc/version 2>/dev/null; then
    log_info "Entorno WSL detectado. Verificando configuración de Systemd..."
    
    WSL_CONF="/etc/wsl.conf"
    
    # 1. Asegurar la existencia de /etc/wsl.conf
    if [ ! -f "$WSL_CONF" ]; then
        log_info "Creando $WSL_CONF con systemd habilitado..."
        echo -e "[boot]\nsystemd=true" | sudo tee "$WSL_CONF" >/dev/null
        log_ok "Systemd habilitado en WSL. Nota: requiere reiniciar WSL (wsl --shutdown)."
    else
        # 2. Si existe, comprobar si systemd=true ya está configurado
        if grep -q "systemd=true" "$WSL_CONF"; then
            log_ok "Systemd ya está habilitado en $WSL_CONF."
        else
            log_info "Actualizando $WSL_CONF para habilitar Systemd..."
            # Comprobar si existe la sección [boot]
            if grep -q "^\[boot\]" "$WSL_CONF"; then
                # Insertar systemd=true justo debajo de [boot]
                sudo sed -i '/^\[boot\]/a systemd=true' "$WSL_CONF"
            else
                # Añadir la sección completa
                echo -e "\n[boot]\nsystemd=true" | sudo tee -a "$WSL_CONF" >/dev/null
            fi
            log_ok "Systemd habilitado en $WSL_CONF. Nota: requiere reiniciar WSL (wsl --shutdown)."
        fi
    fi
else
    log_info "No es un entorno WSL. Saltando configuración de /etc/wsl.conf."
fi
