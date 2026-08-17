#!/usr/bin/env bash
# =============================================================================
# provision/installers/arch.sh
# Instalador de Paquetes para Arch Linux (Pacman)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"
PACKAGES_FILE="${CHEZMOI_SOURCE_DIR:-$SCRIPT_DIR/../..}/.chezmoidata/packages.yaml"

# ── 0. Optimización de Pacman ────────────────────────────────────────────────
if ! grep -q "^ParallelDownloads" /etc/pacman.conf 2>/dev/null; then
    log_info "Configurando descargas en paralelo para Pacman..."
    sudo sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf || true
    log_ok "Pacman optimizado (ParallelDownloads=10)."
fi

# ── 1. Dependencias del Aprovisionador ────────────────────────────────────────
# No requiere herramientas de software externas (usa awk nativo para parsear packages.yaml).

# ── 2. Función de Instalación por Sección ────────────────────────────────────
install_section() {
    local section="$1"
    log_info "Instalando sección Arch: $section"
    
    local packages
    packages=$(awk "/^arch:/ {in_arch=1; next} /^[a-zA-Z]/ {if(in_arch) in_arch=0} in_arch && /^[ ]+${section}:/ {in_sec=1; next} in_arch && in_sec && /^[ ]+-[ ]+/ {print \$2; next} in_arch && in_sec && /^[ ]+[a-zA-Z]/ {in_sec=0}" "$PACKAGES_FILE" || echo "")
    
    if [ -z "$packages" ]; then
        log_info "Sección $section vacía, omitiendo."
        return
    fi
    
    run sudo pacman -S --noconfirm --needed $packages
    log_ok "Paquetes de $section instalados."
}

# ── 2.1. Instalación de Paquetes AUR (sección `aur`) ───────────────────────────
# Idempotente y tolerante: cada paquete se instala de forma independiente y un
# fallo de build no aborta el aprovisionamiento (se reporta como advertencia).
install_section_aur() {
    local section="$1"

    local helper=""
    for h in paru yay pikaur; do
        if command -v "$h" &>/dev/null; then
            helper="$h"
            break
        fi
    done

    if [ -z "$helper" ]; then
        log_info "Sin helper AUR detectado. Instalando paru (repo oficial)..."
        run sudo pacman -S --noconfirm --needed paru
        helper="paru"
    fi
    log_info "Helper AUR detectado: $helper"

    local packages
    packages=$(awk "/^arch:/ {in_arch=1; next} /^[a-zA-Z]/ {if(in_arch) in_arch=0} in_arch && /^[ ]+${section}:/ {in_sec=1; next} in_arch && in_sec && /^[ ]+-[ ]+/ {print \$2; next} in_arch && in_sec && /^[ ]+[a-zA-Z]/ {in_sec=0}" "$PACKAGES_FILE" || echo "")

    if [ -z "$packages" ]; then
        log_info "Sección $section vacía, omitiendo."
        return
    fi

    log_info "Instalando sección AUR: $section (tolerante a fallos de build)"
    for pkg in $packages; do
        if ! run "$helper" -S --noconfirm --needed "$pkg"; then
            log_warn "Paquete AUR $pkg falló; continúa la ejecución. Revísalo manualmente."
        fi
    done
    log_ok "Paquetes de $section procesados."
}

# ── 3. Ejecución de Perfiles ─────────────────────────────────────────────────
# Perfil Base
install_section "base"

# Perfil Terminal UX
install_section "terminal_ux"

# Perfil de Compilación (Desarrollo: WSL, Laptop, Desktop; u opt-in en servidores)
if [ "${NODE_IS_SERVER:-}" != "true" ] || [ "${NODE_NEEDS_DEV_TOOLCHAIN:-}" = "true" ]; then
    install_section "dev_headers"
fi

# Perfil Desktop & Hyprland
if [ "${NODE_HAS_GUI:-}" = "true" ]; then
    install_section "desktop_gui"
    
    if [ "${NODE_DESKTOP_ENV:-}" = "hyprland" ]; then
        log_info "Instalando Hyprland..."
        install_section "hyprland"
    fi

    # Sesión alternativa: Niri (scrollable-tiling)
    log_info "Instalando Niri (sesión alternativa)..."
    install_section "niri"

    # Paquetes AUR del escritorio (idempotente y tolerante)
    install_section_aur "aur"

    # Activar servicios instalados condicionalmente
    if systemctl list-unit-files bluetooth.service &>/dev/null; then
        log_info "Habilitando servicio de Bluetooth..."
        run sudo systemctl enable --now bluetooth &>/dev/null || true
    fi
fi

# Instalar distrobox
if [ "${NODE_IS_SERVER:-}" != "true" ]; then
    log_info "Instalando herramientas de desarrollo aislado (distrobox)..."
    run sudo pacman -S --noconfirm distrobox
fi

log_ok "Aprovisionamiento de paquetes Arch completado."
