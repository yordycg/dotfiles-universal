#!/usr/bin/env bash
# =============================================================================
# provision/system/cleanup-kde.sh
# Eliminación de paquetes predeterminados de KDE no deseados
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"

if [ ! -f /etc/fedora-release ]; then
    exit 0
fi

# Solo limpiar si el entorno de escritorio configurado es KDE o both
if [ "${NODE_DESKTOP_ENV:-}" != "kde" ] && [ "${NODE_DESKTOP_ENV:-}" != "both" ]; then
    exit 0
fi

log_info "Verificando paquetes innecesarios de KDE para limpiar..."

# Lista de paquetes a limpiar
unwanted_packages=(
    konsole
    kmail
    kontact
    kaddressbook
    akregator
    dragon
    elisa
)

to_remove=()
for pkg in "${unwanted_packages[@]}"; do
    if rpm -q "$pkg" &>/dev/null; then
        to_remove+=("$pkg")
    fi
done

if [ ${#to_remove[@]} -gt 0 ]; then
    log_info "→ Eliminando aplicaciones de KDE no deseadas: ${to_remove[*]}"
    sudo dnf remove -y "${to_remove[@]}"
    log_ok "Limpieza de KDE completada."
else
    log_ok "No se encontraron paquetes de KDE redundantes para limpiar."
fi
