#!/usr/bin/env bash
# =============================================================================
# provision/system/setup-virtualization.sh
# Configuración automatizada de Virtualización (KVM/QEMU/libvirt)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"

log_info "Configurando Virtualización KVM/QEMU..."

# 1. Detectar distribución e instalar paquetes necesarios
if [ -f /etc/fedora-release ]; then
    log_info "→ Detectado Fedora. Instalando grupo @virtualization y virtio-win..."
    sudo dnf install -y --skip-unavailable @virtualization virtio-win
elif [ -f /etc/arch-release ]; then
    log_info "→ Detectado Arch Linux. Instalando QEMU, libvirt y virt-manager..."
    sudo pacman -S --noconfirm --needed qemu-desktop libvirt virt-manager dnsmasq iptables-nft
elif [ -f /etc/debian_version ]; then
    log_info "→ Detectado Debian/Ubuntu. Instalando QEMU, libvirt y virt-manager..."
    sudo apt-get update -y -q
    sudo apt-get install -y -q qemu-system-x86 libvirt-daemon-system libvirt-clients bridge-utils virt-manager
else
    log_warn "Distribución no soportada para instalación automática de virtualización."
    exit 0
fi

# 2. Habilitar y arrancar el servicio de libvirt
if systemctl list-unit-files libvirtd.service &>/dev/null; then
    log_info "→ Habilitando y arrancando servicio libvirtd..."
    sudo systemctl enable --now libvirtd
else
    log_warn "Servicio libvirtd no encontrado. Verifica tu instalación de libvirt."
fi

# 3. Agregar usuario al grupo libvirt
REAL_USER="${SUDO_USER:-$USER}"
# Validar si el grupo libvirt existe
if getent group libvirt >/dev/null; then
    log_info "→ Agregando usuario '$REAL_USER' al grupo libvirt..."
    sudo usermod -aG libvirt "$REAL_USER"
    log_ok "Virtualización configurada con éxito. (Cierra y vuelve a iniciar sesión para aplicar el grupo libvirt)."
else
    log_warn "El grupo 'libvirt' no existe en el sistema. Asegúrate de reiniciar el servicio o crearlo manualmente."
fi
