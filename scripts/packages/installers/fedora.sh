#!/usr/bin/env bash
# Instalador para Fedora (dnf)
# Lee la sección 'fedora' de packages.yaml

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/../packages.yaml"

if ! command -v yq &>/dev/null; then
    echo "== Instalando yq..."
    sudo dnf install -y yq
fi

install_section() {
    local section="$1"
    echo "== Instalando Fedora: $section"
    local packages
    packages=$(yq e ".fedora.${section}[]" "$PACKAGES_FILE" 2>/dev/null || echo "")
    if [ -z "$packages" ]; then
        echo "  (vacio, omitiendo)"
        return
    fi
    sudo dnf install -y --skip-unavailable $packages
}

# 1. Paquetes Base
install_section "core"

# 2. Solo instalar Desktop si no es WSL y tiene entorno gráfico
if [ -z "${WSL_DISTRO_NAME:-}" ]; then
    install_section "desktop"
    
    # Solo instalar Sway si estamos en ese entorno
    if [ "$XDG_CURRENT_DESKTOP" = "sway" ] || [ -n "${SWAYSOCK:-}" ]; then
        install_section "sway"
    fi
fi

echo "[OK] Fedora Bootstrap completado."
