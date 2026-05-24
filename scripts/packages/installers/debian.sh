#!/usr/bin/env bash
# =============================================================================
# scripts/packages/installers/debian.sh
# Instalador de Paquetes para Debian/Ubuntu (APT)
# =============================================================================
set -euo pipefail

# Colores Homelab-Style
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log_ok()   { echo -e "${GREEN}  ✓ $1${RESET}"; }
log_info() { echo -e "${CYAN}  → $1${RESET}"; }
log_warn() { echo -e "${YELLOW}  ⚠ $1${RESET}"; }
log_err()  { echo -e "${RED}  ✗ $1${RESET}"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/../packages.yaml"

# ── 1. Preparación del Gestor de Paquetes ────────────────────────────────────
log_info "Actualizando índices de repositorios APT..."
sudo apt-get update -y -qq
log_ok "Índices actualizados."

# ── 2. Dependencias del Instalador ───────────────────────────────────────────
if ! command -v yq &>/dev/null; then
    log_info "Instalando yq (Procesador YAML) vía binario..."
    sudo wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
    sudo chmod +x /usr/bin/yq
    log_ok "yq instalado."
fi

# ── 3. Función de Instalación por Sección ────────────────────────────────────
install_section() {
    local section="$1"
    log_info "Instalando sección Debian: $section"
    
    local packages
    packages=$(yq e ".debian.${section}[]" "$PACKAGES_FILE" 2>/dev/null || echo "")
    
    if [ -z "$packages" ]; then
        log_info "Sección $section vacía, omitiendo."
        return
    fi

    sudo apt-get install -y -qq $packages
    log_ok "Paquetes de $section instalados."

    # Fix específico para Debian 12: Actualizar podman-compose via pip3
    # (Comentado temporalmente por Migración a Docker Oficial)
    # if command -v pip3 &> /dev/null; then
    #     log_info "Actualizando podman-compose para soporte de IPs estáticas..."
    #     sudo pip3 install --upgrade podman-compose --break-system-packages -q
    #     log_ok "podman-compose actualizado."
    # fi
}

# ── 4. Ejecución de Perfiles ─────────────────────────────────────────────────
# Perfil Core (Siempre)
install_section "core"

# Perfil Desktop (Opcional en Debian)
if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
    log_info "Entorno gráfico detectado. Buscando sección desktop..."
    # install_section "desktop" # Reservado para futuras ampliaciones
fi

log_ok "Bootstrap de Debian completado."
