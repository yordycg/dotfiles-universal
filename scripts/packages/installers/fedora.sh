#!/usr/bin/env bash
# =============================================================================
# scripts/packages/installers/fedora.sh
# Instalador de Paquetes para Fedora (DNF)
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

# ── 1. Dependencias del Instalador ───────────────────────────────────────────
if ! command -v yq &>/dev/null; then
    log_info "Instalando yq (Procesador YAML)..."
    sudo dnf install -y -q yq
    log_ok "yq instalado."
fi

# ── 2. Función de Instalación por Sección ────────────────────────────────────
install_section() {
    local section="$1"
    log_info "Instalando sección Fedora: $section"
    
    local packages
    packages=$(yq e ".fedora.${section}[]" "$PACKAGES_FILE" 2>/dev/null || echo "")
    
    if [ -z "$packages" ]; then
        log_info "Sección $section vacía, omitiendo."
        return
    fi
    
    sudo dnf install -y -q --skip-unavailable $packages
    log_ok "Paquetes de $section instalados."
}

# ── 3. Ejecución de Perfiles ─────────────────────────────────────────────────
# Perfil Core (Siempre)
install_section "core"

# Perfil Server (Si aplica)
if [ "${NODE_IS_SERVER:-}" = "true" ]; then
    install_section "server"
fi

# Perfil Desktop (Si aplica)
if [ "${NODE_HAS_GUI:-}" = "true" ]; then
    # Habilitar repositorio de Google Chrome (Standard Fedora)
    if ! dnf repolist | grep -q "google-chrome"; then
        log_info "Configurando repositorio de Google Chrome..."
        sudo dnf install -y -q fedora-workstation-repositories
        # Compatibilidad con DNF5 (Fedora 41+)
        sudo dnf config-manager setopt google-chrome.enabled=1
    fi

    # Habilitar repositorio de VS Code (Microsoft)
    if ! dnf repolist | grep -q "code"; then
        log_info "Configurando repositorio de VS Code..."
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    fi

    # Habilitar COPR para nwg-look y herramientas de Sway modernas
    if ! dnf copr list | grep -q "tofik/nwg-shell"; then
        log_info "Habilitando COPR tofik/nwg-shell (para nwg-look)..."
        sudo dnf copr enable -y tofik/nwg-shell
    fi

    # Habilitar COPR solopasha/hyprland para swww y waypaper
    if ! dnf copr list | grep -q "solopasha/hyprland"; then
        log_info "Habilitando COPR solopasha/hyprland (swww + waypaper)..."
        sudo dnf copr enable -y solopasha/hyprland
    fi

    install_section "desktop"
    
    # Perfil Sway (Instalar si es desktop para asegurar disponibilidad)
    install_section "sway"
fi

log_ok "Bootstrap de Fedora completado."
