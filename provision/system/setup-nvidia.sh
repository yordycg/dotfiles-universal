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
        run sudo dnf install -y akmod-nvidia
        log_info "→ Compilando módulos de kernel con akmods..."
        run sudo akmods
    fi
elif [ -f /etc/arch-release ]; then
    log_info "→ Arch Linux detectado. Asegurando cabeceras del kernel (headers)..."
    if [[ "$(uname -r)" == *zen* ]]; then
        HEADERS="linux-zen-headers"
    elif [[ "$(uname -r)" == *lts* ]]; then
        HEADERS="linux-lts-headers"
    elif [[ "$(uname -r)" == *hardened* ]]; then
        HEADERS="linux-hardened-headers"
    else
        HEADERS="linux-headers"
    fi
    run sudo pacman -S --noconfirm --needed "$HEADERS"

    if ! pacman -Qi nvidia &>/dev/null && ! pacman -Qi nvidia-lts &>/dev/null && ! pacman -Qi nvidia-dkms &>/dev/null && ! pacman -Qi nvidia-open &>/dev/null && ! pacman -Qi nvidia-open-dkms &>/dev/null; then
        log_info "→ Instalando driver nvidia-dkms..."
        run sudo pacman -S --noconfirm --needed nvidia-dkms
    fi

    # Configurar KMS (Kernel Mode Setting) para NVIDIA
    if [ -f /etc/mkinitcpio.conf ]; then
        if ! grep -q "nvidia" /etc/mkinitcpio.conf; then
            log_info "→ Configurando KMS para NVIDIA en /etc/mkinitcpio.conf..."
            run sudo sed -i.bak 's/^MODULES=(\([^)]*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
        fi
    fi

    # Configurar nvidia-drm.modeset=1
    if [ ! -f /etc/modprobe.d/nvidia.conf ] || ! grep -q "options nvidia-drm modeset=1" /etc/modprobe.d/nvidia.conf; then
        log_info "→ Configurando nvidia-drm modeset en /etc/modprobe.d/nvidia.conf..."
        run sudo mkdir -p /etc/modprobe.d
        run sudo bash -c 'echo "options nvidia-drm modeset=1" >> /etc/modprobe.d/nvidia.conf'
    fi

    log_info "→ Regenerando initramfs con mkinitcpio..."
    run sudo mkinitcpio -P
elif [ -f /etc/debian_version ]; then
    if ! dpkg -s nvidia-driver &>/dev/null; then
        log_info "→ Debian/Ubuntu detectado. Instalando nvidia-driver..."
        run sudo apt-get update -y -q
        run sudo apt-get install -y -q nvidia-driver
    fi
else
    log_warn "Distribución no compatible con la auto-instalación del driver NVIDIA."
    exit 0
fi

# 2. Gestión de Firmas Secure Boot (MOK) para NVIDIA en Fedora
if [ -f /etc/fedora-release ] && command -v mokutil &>/dev/null; then
    if mokutil --sb-state 2>/dev/null | grep -q "SecureBoot enabled"; then
        log_info "→ Secure Boot activo detectado. Comprobando llave MOK..."
        
        # Determinar la ruta de la llave pública MOK (usando sudo para verificar existencia en directorio protegido)
        MOK_DER="/etc/pki/akmods/certs/public_key.der"
        if ! sudo test -f "$MOK_DER" && sudo test -f "/etc/pki/akmods/certs/akmods.der"; then
            MOK_DER="/etc/pki/akmods/certs/akmods.der"
        fi

        # Si no existe ninguna llave MOK, la generamos (sin --force para evitar sobrescritura accidental)
        if ! sudo test -f "$MOK_DER"; then
            log_info "→ Llave MOK de akmods no encontrada. Generándola..."
            run sudo kmodgenca -a
            
            # Buscar de nuevo la llave generada
            MOK_DER="/etc/pki/akmods/certs/public_key.der"
            if ! sudo test -f "$MOK_DER" && sudo test -f "/etc/pki/akmods/certs/akmods.der"; then
                MOK_DER="/etc/pki/akmods/certs/akmods.der"
            fi
        fi

        # Comprobar si la llave ya está en la BIOS/UEFI (MOK) usando sudo
        if ! sudo mokutil --test-key "$MOK_DER" &>/dev/null; then
            log_warn "╔═════════════════════════════════════════════════════════════════════╗"
            log_warn "║ 🔑 LLAVE MOK DE AKMODS NO REGISTRADA EN LA BIOS                     ║"
            log_warn "║ Se te solicitará crear una contraseña temporal para importar MOK.  ║"
            log_warn "║ RECUERDA esta contraseña, ya que la deberás escribir en el menú de  ║"
            log_warn "║ la pantalla azul (MOKManager) en el próximo reinicio.               ║"
            log_warn "╚═════════════════════════════════════════════════════════════════════╝"
            # mokutil --import es interactivo y no debe canalizarse por run
            sudo mokutil --import "$MOK_DER" || log_info "→ La llave ya está encolada para el próximo reinicio."
        else
            log_ok "→ Llave MOK de akmods ya está registrada y autorizada en la BIOS."
        fi
    fi
fi

log_ok "Configuración de NVIDIA completada."
