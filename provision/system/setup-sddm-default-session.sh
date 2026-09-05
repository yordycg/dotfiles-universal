#!/usr/bin/env bash
# =============================================================================
# provision/system/setup-sddm-default-session.sh
# Define niri como sesión por defecto en SDDM y deja KDE Plasma disponible
# como alternativa (respaldo). Idempotente: sobrescribe el drop-in 10-*.
# Uso: NODE_HAS_GUI=true sudo bash setup-sddm-default-session.sh
# =============================================================================
set -euo pipefail

# Guard: solo nodos GUI (Arch/Fedora/Debian con escritorio)
if [ "${NODE_HAS_GUI:-}" != "true" ] || [ "${NODE_IS_SERVER:-}" = "true" ] || [ "${NODE_IS_WSL:-}" = "true" ]; then
    exit 0
fi

if [ ! -f /usr/share/wayland-sessions/niri.desktop ]; then
    echo "niri.desktop no encontrado; omitiendo." >&2
    exit 0
fi

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RESET='\033[0m'
log_info() { echo -e "${CYAN}  → $1${RESET}"; }
log_ok()   { echo -e "${GREEN}  ✓ $1${RESET}"; }

SDDM_CONF_DIR="/etc/sddm.conf.d"
CONF_FILE="$SDDM_CONF_DIR/10-default-session.conf"

log_info "Configurando niri como sesión por defecto en SDDM (KDE queda como alternativa)..."
sudo mkdir -p "$SDDM_CONF_DIR"
sudo tee "$CONF_FILE" > /dev/null <<EOF
[General]
Session=niri.desktop
EOF

# Asegurar que sddm está habilitado y ningún otro DM lo pisa
if ! systemctl is-enabled sddm &>/dev/null; then
    log_info "Habilitando SDDM..."
    sudo systemctl enable sddm --force &>/dev/null || true
fi

log_ok "SDDM: sesión por defecto = niri (alternativa: KDE Plasma)."
