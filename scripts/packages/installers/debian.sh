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
log_info "Instalando dependencias de transporte y detección..."
sudo apt-get update -y -qq
sudo apt-get install -y -qq curl gpg wget lsb-release

CODENAME=$(lsb_release -cs)
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

# ── 2. Añadir Repositorios de Terceros (Tailscale, GitHub CLI) ───────────────
if ! command -v tailscale &>/dev/null; then
    log_info "Añadiendo repositorio de Tailscale para $DISTRO $CODENAME..."
    curl -fsSL "https://pkgs.tailscale.com/stable/$DISTRO/$CODENAME.noarmor.gpg" | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    curl -fsSL "https://pkgs.tailscale.com/stable/$DISTRO/$CODENAME.tailscale-keyring.list" | sudo tee /etc/apt/sources.list.d/tailscale.list
    log_ok "Repo Tailscale añadido."
fi

if ! command -v gh &>/dev/null; then
    log_info "Añadiendo repositorio de GitHub CLI..."
    sudo mkdir -p -m 755 /etc/apt/keyrings
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    log_ok "Repo GitHub CLI añadido."
fi

log_info "Actualizando índices con nuevos repositorios..."
sudo apt-get update -y -qq
log_ok "Índices actualizados."

# ── 3. Dependencias del Instalador ───────────────────────────────────────────
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

# Perfil Server (Si aplica)
if [ "${NODE_IS_SERVER:-}" = "true" ]; then
    install_section "server"
fi

# Perfil Desktop (Opcional en Debian)
if [ "${NODE_HAS_GUI:-}" = "true" ]; then
    log_info "Capacidad GUI detectada. Buscando sección desktop..."
    # install_section "desktop" # Reservado para futuras ampliaciones
fi


log_ok "Bootstrap de Debian completado."
