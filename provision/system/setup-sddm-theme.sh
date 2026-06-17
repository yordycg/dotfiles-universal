#!/usr/bin/env bash
# =============================================================================
# provision/system/setup-sddm-theme.sh
# Instalación y configuración del tema Pixie para SDDM
# =============================================================================
set -euo pipefail

# Solo aplica en Fedora Desktop nativo
if [ ! -f /etc/fedora-release ] || [ "${NODE_HAS_GUI:-}" != "true" ] || [ "${NODE_IS_SERVER:-}" = "true" ] || [ "${NODE_IS_WSL:-}" = "true" ]; then
    exit 0
fi

# Colores Homelab-Style
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log_ok()   { echo -e "${GREEN}  ✓ $1${RESET}"; }
log_info() { echo -e "${CYAN}  → $1${RESET}"; }
log_err()  { echo -e "${RED}  ✗ $1${RESET}"; exit 1; }

THEME_DIR="/usr/share/sddm/themes/pixie"
REPO_URL="https://github.com/xCaptaiN09/pixie-sddm.git"

if [ ! -f "$THEME_DIR/main.qml" ]; then
    log_info "Instalando pixie-sddm en $THEME_DIR..."
    TMP_DIR=$(mktemp -d)
    
    if git clone --depth 1 "$REPO_URL" "$TMP_DIR"; then
        if [ -f "$TMP_DIR/Main.qml" ]; then
            mv "$TMP_DIR/Main.qml" "$TMP_DIR/main.qml"
            sed -i 's/MainScript=Main.qml/MainScript=main.qml/' "$TMP_DIR/metadata.desktop"
        fi

        if [ -f "$TMP_DIR/main.qml" ]; then
            sudo mkdir -p "$THEME_DIR"
            sudo cp -ra "$TMP_DIR"/. "$THEME_DIR/"
            sudo chown -R root:root "$THEME_DIR"
            sudo find "$THEME_DIR" -type d -exec chmod 755 {} +
            sudo find "$THEME_DIR" -type f -exec chmod 644 {} +
            log_ok "Archivos del tema SDDM Pixie copiados."
        fi
        rm -rf "$TMP_DIR"
    fi
fi

SDDM_CONF_DIR="/etc/sddm.conf.d"
CONF_FILE="$SDDM_CONF_DIR/zz-pixie.conf"

sudo mkdir -p "$SDDM_CONF_DIR"
sudo tee "$CONF_FILE" > /dev/null <<EOF
[Theme]
Current=pixie
EOF

log_ok "Configuración de SDDM Pixie aplicada."

# ── 5. Habilitar SDDM y Desactivar otros Display Managers ────────────────────
log_info "Configurando SDDM como gestor de pantalla predeterminado..."
if systemctl is-active greetd &>/dev/null || systemctl is-enabled greetd &>/dev/null; then
    log_info "Deshabilitando greetd y habilitando SDDM..."
    sudo systemctl disable greetd &>/dev/null || true
    sudo systemctl enable sddm --force &>/dev/null || true
elif ! systemctl is-enabled sddm &>/dev/null; then
    log_info "Habilitando SDDM..."
    sudo systemctl enable sddm --force &>/dev/null || true
fi

# ── 6. Desactivar Autologin en SDDM (Idempotente) ─────────────────────────────
log_info "Desactivando autologin en configuraciones de SDDM..."
if [ -f /etc/sddm.conf ]; then
    sudo sed -i 's/^\s*User=/#User=/g' /etc/sddm.conf
    sudo sed -i 's/^\s*Session=/#Session=/g' /etc/sddm.conf
fi

if [ -d /etc/sddm.conf.d ]; then
    # Evitar errores si el directorio no contiene archivos o está vacío
    sudo sed -i 's/^\s*User=/#User=/g' /etc/sddm.conf.d/* 2>/dev/null || true
    sudo sed -i 's/^\s*Session=/#Session=/g' /etc/sddm.conf.d/* 2>/dev/null || true
fi
log_ok "Autologin desactivado en SDDM."
