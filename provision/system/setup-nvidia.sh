#!/usr/bin/env bash
# =============================================================================
# provision/system/setup-nvidia.sh
# Configuración automatizada de Controladores NVIDIA (Agnóstico)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"

# Detectar si hay tarjeta gráfica NVIDIA
if ! lspci | grep -i -q "nvidia"; then
    log_info "No se detectó GPU NVIDIA en este equipo. Saltando configuración de controladores."
    exit 0
fi

log_info "GPU NVIDIA detectada. Configurando controladores propietarios..."

# 1. Instalar el driver adecuado según la distro
if [ -f /etc/fedora-release ]; then
    if ! rpm -q akmod-nvidia &>/dev/null; then
        log_info "→ Fedora detectado. Instalando akmod-nvidia..."
        sudo dnf install -y akmod-nvidia
    fi
    log_info "→ Compilando módulos de kernel con akmods..."
    sudo akmods --force
elif [ -f /etc/arch-release ]; then
    if ! pacman -Qi nvidia &>/dev/null && ! pacman -Qi nvidia-lts &>/dev/null; then
        log_info "→ Arch Linux detectado. Instalando driver nvidia..."
        sudo pacman -S --noconfirm --needed nvidia
        log_info "→ Regenerando initramfs con mkinitcpio..."
        sudo mkinitcpio -P
    fi
elif [ -f /etc/debian_version ]; then
    if ! dpkg -s nvidia-driver &>/dev/null; then
        log_info "→ Debian/Ubuntu detectado. Instalando nvidia-driver..."
        sudo apt-get update -y -q
        sudo apt-get install -y -q nvidia-driver
    fi
else
    log_warn "Distribución no compatible con la auto-instalación del driver NVIDIA."
    exit 0
fi

# 2. Verificar estado de Secure Boot para advertencia de firmas MOK
if command -v mokutil &>/dev/null; then
    if mokutil --sb-state 2>/dev/null | grep -q "SecureBoot enabled"; then
        log_warn "====================================================================="
        log_warn "⚠️ SECURE BOOT ACTIVO DETECTADO"
        log_warn "En el próximo reinicio, el sistema podría pedir registrar la firma MOK"
        log_warn "(pantalla azul de MOKManager). Elige 'Enroll MOK' para autorizar el"
        log_warn "driver de NVIDIA, de lo contrario no cargará."
        log_warn "====================================================================="
    fi
fi

log_ok "Configuración de NVIDIA completada."
