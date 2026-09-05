#!/usr/bin/env bash
# =============================================================================
# provision/system/setup-sddm.sh
# SDDM cross-distro: tema Pixie (MD3) + greeter solo en monitor primario.
# Reemplaza a setup-sddm-theme.sh (antes Fedora-only).
# Idempotente. Uso: NODE_HAS_GUI=true NODE_PRIMARY_MONITOR=DP-2 sudo bash setup-sddm.sh
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"

# Guard: solo nodos GUI (Arch/Fedora/Debian con escritorio)
if [ "${NODE_HAS_GUI:-}" != "true" ] || [ "${NODE_IS_SERVER:-}" = "true" ] || [ "${NODE_IS_WSL:-}" = "true" ]; then
    exit 0
fi

THEME_NAME="pixie"
THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"
REPO_URL="https://github.com/xCaptaiN09/pixie-sddm.git"
SDDM_CONF_DIR="/etc/sddm.conf.d"

# ── 0. Resolver el monitor primario del greeter ───────────────────────────────
# Fuente de verdad: NODE_PRIMARY_MONITOR (exportado por el orquestador desde
# .chezmoidata/sddm.yaml). Fallback por perfil si el script corre standalone.
if [ -z "${NODE_PRIMARY_MONITOR:-}" ]; then
    if [ "${NODE_IS_DESKTOP:-}" = "true" ]; then
        NODE_PRIMARY_MONITOR="DP-2"
    else
        NODE_PRIMARY_MONITOR="eDP-1"
    fi
fi
log_step "Configurando SDDM (tema: $THEME_NAME, greeter en: $NODE_PRIMARY_MONITOR)"

# ── 1. Instalación del tema Pixie ─────────────────────────────────────────────
if [ ! -f "$THEME_DIR/Main.qml" ]; then
    log_info "Instalando pixie-sddm en $THEME_DIR..."
    if [ -f /etc/arch-release ] && { command -v paru &>/dev/null || command -v yay &>/dev/null || command -v pikaur &>/dev/null; }; then
        helper="$(command -v paru || command -v yay || command -v pikaur)"
        if run "$helper" -S --noconfirm --needed pixie-sddm-git; then
            log_ok "Pixie instalado desde AUR ($(basename "$helper"))."
        else
            log_warn "Fallo la instalación AUR de pixie-sddm-git; se reintenta por git clone."
        fi
    fi

    if [ ! -f "$THEME_DIR/Main.qml" ]; then
        TMP_DIR="$(mktemp -d)"
        if git clone --depth 1 "$REPO_URL" "$TMP_DIR/pixie"; then
            sudo mkdir -p "$THEME_DIR"
            sudo cp -a "$TMP_DIR/pixie"/. "$THEME_DIR/"
            sudo rm -rf "$THEME_DIR/.git"
            sudo chown -R root:root "$THEME_DIR"
            sudo find "$THEME_DIR" -type d -exec chmod 755 {} +
            sudo find "$THEME_DIR" -type f -exec chmod 644 {} +
            log_ok "Pixie instalado por git clone."
        else
            log_err "No se pudo clonar pixie-sddm desde $REPO_URL."
        fi
        rm -rf "$TMP_DIR"
    fi
else
    log_ok "Tema $THEME_NAME ya instalado."
fi

# Limpiar el conf heredado del script Fedora-only (mismo tema, nombre distinto)
if [ -f "$SDDM_CONF_DIR/zz-pixie.conf" ]; then
    sudo rm -f "$SDDM_CONF_DIR/zz-pixie.conf"
    log_info "Conf heredado zz-pixie.conf eliminado."
fi

# ── 2. Configuración base de SDDM ─────────────────────────────────────────────
sudo mkdir -p "$SDDM_CONF_DIR"
sudo tee "$SDDM_CONF_DIR/20-theme.conf" > /dev/null <<EOF
[Theme]
Current=$THEME_NAME
CursorTheme=breeze_cursors
EOF
log_ok "SDDM tema: $THEME_NAME aplicado (20-theme.conf)."

# ── 3. Greeter solo en monitor primario (Xsetup) ──────────────────────────────
# Xsetup vive en /usr/share/sddm/scripts (pertenece al paquete sddm): una
# actualización puede sobrescribirlo; re-ejecutar este provision lo restaura.
sudo mkdir -p /etc/sddm /usr/share/sddm/scripts
sudo tee /etc/sddm/primary-monitor > /dev/null <<EOF
$NODE_PRIMARY_MONITOR
EOF

sudo tee /usr/share/sddm/scripts/Xsetup > /dev/null <<'XSETUP'
#!/bin/sh
# Xsetup - gestionado por chezmoi (provision/system/setup-sddm.sh).
# Muestra el greeter SOLO en el monitor primario definido en /etc/sddm/primary-monitor;
# el resto de salidas se apagan hasta que se inicie sesión.
PRIMARY="$(cat /etc/sddm/primary-monitor 2>/dev/null || true)"
if [ -n "$PRIMARY" ] && command -v xrandr >/dev/null 2>&1; then
    xrandr --output "$PRIMARY" --auto --primary >/dev/null 2>&1 || true
    for out in $(xrandr --query 2>/dev/null | awk '/ connected /{print $1}'); do
        if [ "$out" != "$PRIMARY" ]; then
            xrandr --output "$out" --off >/dev/null 2>&1 || true
        fi
    done
fi
XSETUP
sudo chmod 755 /usr/share/sddm/scripts/Xsetup
log_ok "Xsetup: greeter solo en $NODE_PRIMARY_MONITOR."

# ── 4. Habilitar SDDM y desactivar otros Display Managers ─────────────────────
if systemctl is-active greetd &>/dev/null || systemctl is-enabled greetd &>/dev/null; then
    log_info "Deshabilitando greetd y habilitando SDDM..."
    sudo systemctl disable greetd &>/dev/null || true
    sudo systemctl enable sddm --force &>/dev/null || true
elif ! systemctl is-enabled sddm &>/dev/null; then
    log_info "Habilitando SDDM..."
    sudo systemctl enable sddm --force &>/dev/null || true
fi

# ── 5. Desactivar Autologin en SDDM (idempotente) ─────────────────────────────
if [ -f /etc/sddm.conf ]; then
    sudo sed -i 's/^\s*User=/#User=/g' /etc/sddm.conf
    sudo sed -i 's/^\s*Session=/#Session=/g' /etc/sddm.conf
fi
if [ -d "$SDDM_CONF_DIR" ]; then
    sudo sed -i 's/^\s*User=/#User=/g' "$SDDM_CONF_DIR"/* 2>/dev/null || true
    sudo sed -i 's/^\s*Session=/#Session=/g' "$SDDM_CONF_DIR"/* 2>/dev/null || true
fi
log_ok "Autologin desactivado en SDDM."

log_ok "SDDM configurado correctamente."
