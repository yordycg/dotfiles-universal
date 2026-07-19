#!/usr/bin/env bash
# =============================================================================
# install.sh — Instalador Automatizado de Dotfiles en un Solo Comando
# =============================================================================
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${BLUE}▶ Iniciando bootstrapping de dotfiles...${RESET}"

# 1. Validación informativa de llaves previas
SSH_KEY="$HOME/.ssh/id_ed25519"
AGE_KEY="$HOME/.config/age/key.txt"

if [ ! -f "$SSH_KEY" ] || [ ! -f "$AGE_KEY" ]; then
    echo -e "${YELLOW}⚠ Advertencia: No se detectaron las llaves necesarias en el host:${RESET}"
    [ ! -f "$SSH_KEY" ] && echo -e "${YELLOW}  - Llave SSH ausente: $SSH_KEY${RESET}"
    [ ! -f "$AGE_KEY" ] && echo -e "${YELLOW}  - Llave Age ausente: $AGE_KEY${RESET}"
    echo -e "${YELLOW}Asegúrate de sembrarlas manualmente para que el aprovisionamiento de secretos funcione.${RESET}\n"
fi

# 2. Instalar dependencias esenciales de sistema (git y curl) si faltan
if [ -f /etc/arch-release ]; then
    echo -e "${BLUE}  → Arch Linux detectado. Sincronizando bases de datos de Pacman...${RESET}"
    sudo pacman -Sy --noconfirm
    echo -e "${BLUE}  → Asegurando git y curl...${RESET}"
    sudo pacman -S --needed --noconfirm git curl
elif [ -f /etc/fedora-release ]; then
    echo -e "${BLUE}  → Fedora detectado. Sincronizando bases de datos de DNF...${RESET}"
    sudo dnf check-update || true
    echo -e "${BLUE}  → Asegurando git y curl...${RESET}"
    sudo dnf install -y git curl
elif [ -f /etc/debian_version ]; then
    echo -e "${BLUE}  → Debian/Ubuntu detectado. Sincronizando bases de datos de APT...${RESET}"
    sudo apt-get update
    echo -e "${BLUE}  → Asegurando git y curl...${RESET}"
    sudo apt-get install -y git curl
fi

# 3. Descargar o asegurar Chezmoi en el espacio de usuario si no está en PATH
if ! command -v chezmoi &>/dev/null; then
    echo -e "${BLUE}  → Chezmoi no encontrado. Descargándolo localmente a ~/.local/bin...${RESET}"
    mkdir -p "$HOME/.local/bin"
    sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
fi

# 4. Inicializar Chezmoi usando este repositorio local (bootstrap de los dotfiles)
echo -e "${BLUE}  → Inicializando y aplicando Chezmoi...${RESET}"
chezmoi init --apply yordycg/dotfiles-universal

# 5. Configurar el origen de chezmoi para usar SSH automáticamente
if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
    echo -e "${BLUE}  → Cambiando origen de Git a SSH para evitar peticiones de credenciales...${RESET}"
    cd "$HOME/.local/share/chezmoi"
    git remote set-url origin git@github.com:yordycg/dotfiles-universal.git
fi

echo -e "${GREEN}✓ Bootstrapping finalizado. Chezmoi ha tomado el control.${RESET}"
