#!/usr/bin/env bash
# =============================================================================
# provision/system/setup-snapper.sh
# Configuración automatizada de Snapper para Btrfs
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"

if ! command -v snapper &>/dev/null; then
    log_warn "Snapper no está instalado. Saltando configuración."
    exit 0
fi

# Verificar si el sistema de archivos de / es Btrfs
fs_type=$(findmnt -n -o FSTYPE /)
if [ "$fs_type" != "btrfs" ]; then
    log_info "El sistema de archivos raíz no es Btrfs ($fs_type). Saltando configuración de Snapper."
    exit 0
fi

log_info "Configurando Snapper para Btrfs..."

# Configurar root (/)
if [ ! -f "/etc/snapper/configs/root" ]; then
    log_info "→ Creando configuración Snapper para root (/)..."
    sudo snapper -c root create-config /
    log_ok "Configuración root creada."
else
    log_info "→ Configuración Snapper para root ya existe."
fi

# Configurar home (/home)
home_fs_type=$(findmnt -n -o FSTYPE /home || echo "none")
if [ "$home_fs_type" = "btrfs" ]; then
    if [ ! -f "/etc/snapper/configs/home" ]; then
        log_info "→ Creando configuración Snapper para /home..."
        sudo snapper -c home create-config /home
        log_ok "Configuración /home creada."
    else
        log_info "→ Configuración Snapper para /home ya existe."
    fi
else
    log_info "→ /home no está montado como subvolumen Btrfs independiente. Saltando config para /home."
fi

log_ok "Configuración de Snapper completada."
