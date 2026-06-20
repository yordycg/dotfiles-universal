#!/usr/bin/env bash
# =============================================================================
# provision/system/cleanup-kde.sh
# Eliminación de paquetes predeterminados de KDE no deseados (Agnóstico)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"

# Solo limpiar si el entorno de escritorio configurado es KDE o both
if [ "${NODE_DESKTOP_ENV:-}" != "kde" ] && [ "${NODE_DESKTOP_ENV:-}" != "both" ]; then
    exit 0
fi

log_info "Verificando paquetes innecesarios de KDE para limpiar..."

# Lista de paquetes a limpiar (adaptada a nombres de diferentes distros)
unwanted_packages=(
    konsole
    kmail
    kontact
    kaddressbook
    akregator
    dragon
    dragonplayer
    elisa
)

to_remove=()

# 1. Detectar distro y verificar cuáles están instalados
if [ -f /etc/fedora-release ]; then
    for pkg in "${unwanted_packages[@]}"; do
        if rpm -q "$pkg" &>/dev/null; then
            to_remove+=("$pkg")
        fi
    done
    
    if [ ${#to_remove[@]} -gt 0 ]; then
        log_info "→ Fedora detectado. Eliminando aplicaciones de KDE: ${to_remove[*]}"
        sudo dnf remove -y "${to_remove[@]}"
        log_ok "Limpieza de KDE completada."
    fi
elif [ -f /etc/arch-release ]; then
    for pkg in "${unwanted_packages[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            to_remove+=("$pkg")
        fi
    done
    
    if [ ${#to_remove[@]} -gt 0 ]; then
        log_info "→ Arch Linux detectado. Eliminando aplicaciones de KDE: ${to_remove[*]}"
        sudo pacman -Rns --noconfirm "${to_remove[@]}"
        log_ok "Limpieza de KDE completada."
    fi
elif [ -f /etc/debian_version ]; then
    for pkg in "${unwanted_packages[@]}"; do
        if dpkg -s "$pkg" &>/dev/null; then
            to_remove+=("$pkg")
        fi
    done
    
    if [ ${#to_remove[@]} -gt 0 ]; then
        log_info "→ Debian/Ubuntu detectado. Eliminando aplicaciones de KDE: ${to_remove[*]}"
        sudo apt-get remove -y --purge "${to_remove[@]}"
        log_ok "Limpieza de KDE completada."
    fi
else
    log_warn "Distribución no soportada para limpieza automática de KDE."
fi
