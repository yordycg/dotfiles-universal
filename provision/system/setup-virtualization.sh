#!/usr/bin/env bash
# =============================================================================
# provision/system/setup-virtualization.sh
# Configuración automatizada de Virtualización (KVM/QEMU/libvirt)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"

if [ ! -f /etc/fedora-release ]; then
    log_info "No estás en Fedora. Saltando instalación de virtualización de Fedora."
    exit 0
fi

log_info "Configurando Virtualización KVM/QEMU..."

# 1. Instalar paquetes de virtualización
log_info "→ Instalando grupo @virtualization y virtio-win..."
sudo dnf install -y --skip-unavailable @virtualization virtio-win

# 2. Habilitar y arrancar el servicio de libvirt
log_info "→ Habilitando y arrancando servicio libvirtd..."
sudo systemctl enable --now libvirtd

# 3. Agregar usuario al grupo libvirt
REAL_USER="${SUDO_USER:-$USER}"
log_info "→ Agregando usuario '$REAL_USER' al grupo libvirt..."
sudo usermod -aG libvirt "$REAL_USER"

log_ok "Virtualización configurada con éxito. (Cierra y vuelve a iniciar sesión para aplicar el grupo libvirt)."
