#!/usr/bin/env bash
# =============================================================================
# provision/installers/debian.sh
# Instalador de Paquetes para Debian/Ubuntu (APT)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"
PACKAGES_FILE="$SCRIPT_DIR/../../.chezmoidata/packages.yaml"

# ── 1. Preparación del Gestor de Paquetes ────────────────────────────────────
log_info "Instalando dependencias de transporte y detección..."
run sudo apt-get update -y -qq
run sudo apt-get install -y -qq curl gpg wget lsb-release

CODENAME=$(lsb_release -cs)
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

# ── 2. Añadir Repositorios de Terceros (Tailscale, GitHub CLI) ───────────────
if ! command -v tailscale &>/dev/null; then
    log_info "Añadiendo repositorio de Tailscale para $DISTRO $CODENAME..."
    run curl -fsSL "https://pkgs.tailscale.com/stable/$DISTRO/$CODENAME.noarmor.gpg" | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    run curl -fsSL "https://pkgs.tailscale.com/stable/$DISTRO/$CODENAME.tailscale-keyring.list" | sudo tee /etc/apt/sources.list.d/tailscale.list
    log_ok "Repo Tailscale añadido."
fi

if ! command -v gh &>/dev/null; then
    log_info "Añadiendo repositorio de GitHub CLI..."
    run sudo mkdir -p -m 755 /etc/apt/keyrings
    run wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    run sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    run echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    log_ok "Repo GitHub CLI añadido."
fi

log_info "Actualizando índices con nuevos repositorios..."
run sudo apt-get update -y -qq
log_ok "Índices actualizados."

# ── 3. Dependencias del Instalador ───────────────────────────────────────────
if ! command -v yq &>/dev/null; then
    log_info "Instalando yq (Procesador YAML) vía binario..."
    run sudo wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
    run sudo chmod +x /usr/bin/yq
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

    run sudo apt-get install -y -qq $packages
    log_ok "Paquetes de $section instalados."
}

# ── 4. Ejecución de Perfiles ─────────────────────────────────────────────────
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

# Perfil Desktop (Opcional en Debian)
if [ "${NODE_HAS_GUI:-}" = "true" ]; then
    log_info "Capacidad GUI detectada. Buscando sección desktop..."
    # install_section "desktop_gui" # Reservado para futuras ampliaciones
fi

# Instalar distrobox en todos los sistemas (servidor y clientes)
log_info "Instalando herramientas de desarrollo aislado (distrobox)..."
run sudo apt-get install -y -qq distrobox

log_ok "Aprovisionamiento de paquetes Debian completado."
