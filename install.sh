#!/usr/bin/env bash
# =============================================================================
# install.sh — Instalador Automatizado de Dotfiles en un Solo Comando
# =============================================================================
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${BLUE}▶ Iniciando bootstrapping de dotfiles...${RESET}"

# 1. Instalar dependencias esenciales de sistema (git y curl) si faltan
if [ -f /etc/arch-release ]; then
    echo -e "${BLUE}  → Arch Linux detectado. Asegurando git y curl...${RESET}"
    sudo pacman -S --needed --noconfirm git curl
elif [ -f /etc/fedora-release ]; then
    echo -e "${BLUE}  → Fedora detectado. Asegurando git y curl...${RESET}"
    sudo dnf install -y git curl
elif [ -f /etc/debian_version ]; then
    echo -e "${BLUE}  → Debian/Ubuntu detectado. Asegurando git y curl...${RESET}"
    sudo apt-get update
    sudo apt-get install -y git curl
fi

# 2. Descargar o asegurar Chezmoi en el espacio de usuario si no está en PATH
if ! command -v chezmoi &>/dev/null; then
    echo -e "${BLUE}  → Chezmoi no encontrado. Descargándolo localmente a ~/.local/bin...${RESET}"
    mkdir -p "$HOME/.local/bin"
    sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
fi

# 3. Inicializar Chezmoi usando este repositorio local (bootstrap del dotfiles)
echo -e "${BLUE}  → Inicializando y aplicando Chezmoi...${RESET}"
chezmoi init --apply yordycg/dotfiles-universal

echo -e "${GREEN}✓ Bootstrapping finalizado. Chezmoi ha tomado el control.${RESET}"
