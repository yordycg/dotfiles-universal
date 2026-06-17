#!/usr/bin/env bash
# =============================================================================
# provision/installers/fedora.sh
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
PACKAGES_FILE="$SCRIPT_DIR/../../scripts/packages/packages.yaml"

# ── 1. Dependencias del Aprovisionador ────────────────────────────────────────
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
    # Habilitar RPM Fusion si no está activo (necesario para codecs multimedia)
    if ! dnf repolist 2>/dev/null | grep -q "rpmfusion-free"; then
        log_info "Habilitando repositorio de RPM Fusion..."
        sudo dnf install -y -q \
            "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
            "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    fi

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
    
    # Perfil de Entorno Gráfico Específico (Sway, KDE o Ambos)
    if [ "${NODE_DESKTOP_ENV:-}" = "sway" ]; then
        install_section "sway"
    elif [ "${NODE_DESKTOP_ENV:-}" = "kde" ]; then
        install_section "kde"
    elif [ "${NODE_DESKTOP_ENV:-}" = "both" ]; then
        install_section "sway"
        install_section "kde"
    fi

    # Activar servicios instalados condicionalmente
    if systemctl list-unit-files cups.service &>/dev/null; then
        log_info "Habilitando servicio de impresión (CUPS)..."
        sudo systemctl enable --now cups &>/dev/null || true
    fi
    if systemctl list-unit-files bluetooth.service &>/dev/null; then
        log_info "Habilitando servicio de Bluetooth..."
        sudo systemctl enable --now bluetooth &>/dev/null || true
    fi
fi

# Instalar distrobox en clientes (WSL, PC, Laptop)
if [ "${NODE_IS_SERVER:-}" != "true" ]; then
    log_info "Instalando herramientas de desarrollo aislado (distrobox)..."
    sudo dnf install -y -q --skip-unavailable distrobox
fi

log_ok "Aprovisionamiento de paquetes Fedora completado."
