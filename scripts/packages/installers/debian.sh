#!/usr/bin/env bash
# Instalador para Debian/Ubuntu (apt)
# No editar la lista de paquetes aqui... editar en packages.yaml

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/../packages.yaml"

# 1. Asegurar que el sistema esté actualizado
echo "== Actualizando repositorios..."
sudo apt-get update -y

# 2. Instalar yq si no existe (lo necesitamos para leer packages.yaml)
if ! command -v yq &>/dev/null; then
    echo "== Instalando yq (via wget)..."
    sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
    sudo chmod +x /usr/bin/yq
fi

install_section() {
    local section="$1"
    echo "== Instalando: $section"
    
    # Obtener paquetes y mapear nombres de Fedora -> Debian
    local packages
    packages=$(yq e ".packages.${section}[]" "$PACKAGES_FILE" 2>/dev/null || echo "")
    
    if [ -z "$packages" ]; then
        echo "  (vacio, omitiendo)"
        return
    fi

    # Mapeo de nombres específicos de Debian
    # - gcc-c++ -> g++
    # - sqlite-devel -> libsqlite3-dev
    local mapped_packages=""
    for pkg in $packages; do
        case "$pkg" in
            "chezmoi") continue ;; # Ya está instalado vía bootstrap
            "sqlite") mapped_packages="$mapped_packages sqlite3" ;;
            "gcc-c++") mapped_packages="$mapped_packages g++" ;;
            "sqlite-devel") mapped_packages="$mapped_packages libsqlite3-dev" ;;
            "readline-devel") mapped_packages="$mapped_packages libreadline-dev" ;;
            "ncurses-devel") mapped_packages="$mapped_packages libncurses-dev" ;;
            "llvm-devel") mapped_packages="$mapped_packages llvm-dev" ;;
            "zlib-devel") mapped_packages="$mapped_packages zlib1g-dev" ;;
            "openssl-devel") mapped_packages="$mapped_packages libssl-dev" ;;
            *) mapped_packages="$mapped_packages $pkg" ;;
        esac
    done

    sudo apt-get install -y $mapped_packages
}

# 3. Instalar secciones
install_section "core"

# Solo instalar desktop si no es un sistema headless (Nodo 1 es headless)
if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
    if [ -z "${WSL_DISTRO_NAME:-}" ]; then
        install_section "linux_desktop"
    fi
fi

echo "[OK] Debian Listo"
