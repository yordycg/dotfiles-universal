#!/usr/bin/env bash

# Script para instalar paquetes que no están en los repos oficiales de Fedora
# o que requieren configuración especial (COPR).

set -euo pipefail

if [ ! -f /etc/fedora-release ]; then
    exit 0 # Solo ejecutar en Fedora
fi

echo "== Verificando paquetes especiales..."

# 1. Lazygit (COPR)
if ! command -v lazygit &>/dev/null; then
    echo "== Instalando Lazygit via COPR..."
    sudo dnf copr enable -y atim/lazygit
    sudo dnf install -y lazygit
fi

# 2. Ghostty (COPR verificado)
if ! command -v ghostty &>/dev/null; then
    echo "== Instalando Ghostty via COPR (scottames)..."
    sudo dnf copr enable -y scottames/ghostty
    sudo dnf install -y ghostty
fi

# 3. Yazi (Binario directo desde GitHub)
if ! command -v yazi &>/dev/null; then
    echo "== Instalando Yazi (Binario desde GitHub)..."
    YAZI_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    curl -L -o /tmp/yazi.zip "https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-x86_64-unknown-linux-musl.zip"
    unzip -q /tmp/yazi.zip -d /tmp/yazi_extracted
    # Mover binarios a local bin
    mkdir -p "$HOME/.local/bin"
    mv /tmp/yazi_extracted/yazi-x86_64-unknown-linux-musl/yazi "$HOME/.local/bin/"
    mv /tmp/yazi_extracted/yazi-x86_64-unknown-linux-musl/ya "$HOME/.local/bin/"
    chmod +x "$HOME/.local/bin/yazi" "$HOME/.local/bin/ya"
    # Limpiar
    rm -rf /tmp/yazi.zip /tmp/yazi_extracted
    echo "  (Yazi instalado en ~/.local/bin)"
fi

echo "[OK] Paquetes especiales verificados"
