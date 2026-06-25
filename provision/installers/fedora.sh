#!/usr/bin/env bash
# =============================================================================
# provision/installers/fedora.sh
# Instalador de Paquetes para Fedora (DNF)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"
PACKAGES_FILE="$SCRIPT_DIR/../../scripts/packages/packages.yaml"

# ── 0. Optimización de DNF ────────────────────────────────────────────────────
if ! grep -q "max_parallel_downloads" /etc/dnf/dnf.conf 2>/dev/null; then
    log_info "Configurando descargas en paralelo para DNF..."
    echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
    log_ok "DNF optimizado (max_parallel_downloads=10)."
fi

# ── 1. Dependencias del Aprovisionador ────────────────────────────────────────
if ! command -v yq &>/dev/null; then
    log_info "Instalando yq (Procesador YAML)..."
    run sudo dnf install -y -q yq
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
    
    run sudo dnf install -y -q --skip-unavailable --allowerasing $packages
    log_ok "Paquetes de $section instalados."
}

# ── 3. Ejecución de Perfiles ─────────────────────────────────────────────────
# Perfil Base (Siempre)
install_section "base"

# Perfil Terminal UX (Siempre, mejora la experiencia CLI)
install_section "terminal_ux"

# Perfil de Compilación (Desarrollo: WSL, Laptop, Desktop; u opt-in en servidores)
if [ "${NODE_IS_SERVER:-}" != "true" ] || [ "${NODE_NEEDS_DEV_TOOLCHAIN:-}" = "true" ]; then
    install_section "dev_toolchain"
fi

# Perfil Server (Si aplica)
if [ "${NODE_IS_SERVER:-}" = "true" ]; then
    install_section "server"
fi

# Perfil Desktop (Si aplica)
if [ "${NODE_HAS_GUI:-}" = "true" ]; then
    # Habilitar RPM Fusion si no está activo (necesario para codecs multimedia)
    if ! dnf repolist 2>/dev/null | grep -q "rpmfusion-free"; then
        log_info "Habilitando repositorio de RPM Fusion..."
        run sudo dnf install -y -q \
            "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
            "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    fi

    # Habilitar repositorio de Google Chrome (Standard Fedora)
    if ! dnf repolist | grep -q "google-chrome"; then
        log_info "Configurando repositorio de Google Chrome..."
        run sudo dnf install -y -q fedora-workstation-repositories
        # Compatibilidad con DNF5 (Fedora 41+)
        run sudo dnf config-manager setopt google-chrome.enabled=1
    fi

    # Habilitar repositorio de VS Code (Microsoft)
    if ! dnf repolist | grep -q "code"; then
        log_info "Configurando repositorio de VS Code..."
        run sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        run sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    fi

    # Habilitar COPR para nwg-look y herramientas de Sway modernas
    if ! dnf copr list | grep -q "tofik/nwg-shell"; then
        log_info "Habilitando COPR tofik/nwg-shell (para nwg-look)..."
        run sudo dnf copr enable -y tofik/nwg-shell
    fi

    # Habilitar COPR solopasha/hyprland para swww y waypaper
    if ! dnf copr list | grep -q "solopasha/hyprland"; then
        log_info "Habilitando COPR solopasha/hyprland (swww + waypaper)..."
        run sudo dnf copr enable -y solopasha/hyprland
    fi

    # Habilitar COPR atim/xpadneo para driver de controles Xbox One
    if ! dnf copr list | grep -q "atim/xpadneo"; then
        log_info "Habilitando COPR atim/xpadneo (driver Xbox)..."
        run sudo dnf copr enable -y atim/xpadneo
    fi

    install_section "desktop"
    
    # Perfil de Entorno Gráfico Específico (Sway, KDE o Ambos)
    if [ "${NODE_DESKTOP_ENV:-}" = "sway" ]; then
        install_section "sway"
    elif [ "${NODE_DESKTOP_ENV:-}" = "hyprland" ]; then
        if [ "${NODE_IS_DESKTOP:-}" = "true" ]; then
            log_info "Instalando Hyprland (nodo Desktop detectado)..."
            install_section "hyprland"
        else
            log_warn "Hyprland seleccionado pero este nodo no es Desktop (sin GPU dedicada)."
            log_warn "Instalando Sway como fallback para este nodo..."
            install_section "sway"
        fi
    elif [ "${NODE_DESKTOP_ENV:-}" = "kde" ]; then
        install_section "kde"
    elif [ "${NODE_DESKTOP_ENV:-}" = "both" ]; then
        if [ "${NODE_IS_DESKTOP:-}" = "true" ]; then
            # Desktop: Sway + Hyprland (para poder comparar/alternar)
            log_info "Modo 'both' en Desktop: instalando Sway + Hyprland..."
            install_section "sway"
            install_section "hyprland"
        else
            # Laptop: Sway + KDE (comportamiento original)
            log_info "Modo 'both' en Laptop: instalando Sway + KDE..."
            install_section "sway"
            install_section "kde"
        fi
    fi

    # Activar servicios instalados condicionalmente
    if systemctl list-unit-files cups.service &>/dev/null; then
        log_info "Habilitando servicio de impresión (CUPS)..."
        run sudo systemctl enable --now cups &>/dev/null || true
    fi
    if systemctl list-unit-files bluetooth.service &>/dev/null; then
        log_info "Habilitando servicio de Bluetooth..."
        run sudo systemctl enable --now bluetooth &>/dev/null || true
    fi
fi

# Instalar distrobox en clientes (WSL, PC, Laptop)
if [ "${NODE_IS_SERVER:-}" != "true" ]; then
    log_info "Instalando herramientas de desarrollo aislado (distrobox)..."
    run sudo dnf install -y -q --skip-unavailable distrobox
fi

log_ok "Aprovisionamiento de paquetes Fedora completado."
