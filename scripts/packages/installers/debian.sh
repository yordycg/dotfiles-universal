#!/usr/bin/env bash
# Instalador para Debian/Ubuntu (apt)
# Lee la sección 'debian' de packages.yaml

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/../packages.yaml"

# 1. Asegurar que el sistema esté actualizado
echo "== Actualizando repositorios Debian..."
sudo apt-get update -y

# 2. Instalar yq si no existe
if ! command -v yq &>/dev/null; then
    echo "== Instalando yq (via wget)..."
    sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
    sudo chmod +x /usr/bin/yq
fi

install_section() {
    local section="$1"
    echo "== Instalando Debian: $section"
    local packages
    packages=$(yq e ".debian.${section}[]" "$PACKAGES_FILE" 2>/dev/null || echo "")
    
    if [ -z "$packages" ]; then
        echo "  (vacio, omitiendo)"
        return
    fi

    sudo apt-get install -y $packages
}

# 3. Instalar Base (El Nodo 1 solo necesita esto)
install_section "core"

# 4. Solo instalar desktop si se detecta entorno gráfico (Node 1 no tiene)
if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
    # Aquí podrías añadir secciones debian.desktop si fueran necesarias
    echo "  - Entorno gráfico detectado. (No hay sección desktop definida para Debian aún)"
fi

echo "[OK] Debian Bootstrap completado."
