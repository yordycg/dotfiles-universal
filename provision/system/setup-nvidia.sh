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

# 2. Gestión de Firmas Secure Boot (MOK) para NVIDIA en Fedora
if [ -f /etc/fedora-release ] && command -v mokutil &>/dev/null; then
    if mokutil --sb-state 2>/dev/null | grep -q "SecureBoot enabled"; then
        log_info "→ Secure Boot activo detectado. Comprobando llave MOK..."
        
        # Determinar la ruta de la llave pública MOK
        MOK_DER="/etc/pki/akmods/certs/public_key.der"
        if [ ! -f "$MOK_DER" ] && [ -f "/etc/pki/akmods/certs/akmods.der" ]; then
            MOK_DER="/etc/pki/akmods/certs/akmods.der"
        fi

        # Si no existe ninguna llave MOK, la generamos
        if [ ! -f "$MOK_DER" ]; then
            log_info "→ Llave MOK de akmods no encontrada. Generándola..."
            sudo kmodgenca --force
            
            # Buscar de nuevo
            MOK_DER="/etc/pki/akmods/certs/public_key.der"
            if [ ! -f "$MOK_DER" ] && [ -f "/etc/pki/akmods/certs/akmods.der" ]; then
                MOK_DER="/etc/pki/akmods/certs/akmods.der"
            fi
        fi

        # Comprobar si la llave ya está en la BIOS/UEFI (MOK)
        if ! mokutil --test-key "$MOK_DER" &>/dev/null; then
            log_warn "====================================================================="
            log_warn "🔑 LLAVE MOK DE AKMODS NO REGISTRADA EN LA BIOS"
            log_warn "Se te solicitará crear una contraseña temporal para importar la llave MOK."
            log_warn "RECUERDA esta contraseña, ya que la deberás escribir en el menú de la"
            log_warn "pantalla azul (MOKManager) en el próximo reinicio."
            log_warn "====================================================================="
            # Intentamos importar (si ya estaba en cola para el próximo reinicio, continuará sin errores)
            sudo mokutil --import "$MOK_DER" || log_info "→ La llave ya está encolada para el próximo reinicio."
        else
            log_ok "→ Llave MOK de akmods ya está registrada y autorizada en la BIOS."
        fi
    fi
fi

log_ok "Configuración de NVIDIA completada."
