#!/usr/bin/env bash
# provision_base.sh
# Instala el entorno de shell completo dentro de cualqueir caja Distrobox
# Compatible con: Debian/Ubuntu, Arch, Fedora

set -euo pipefail

echo "== Detectanto gestor de paquetes..."

install_packages() {
	if command -v apt &>/dev/null; then
		sudo apt update
		sudo apt install -y zsh fzf bat eza ripgrep fd-find curl git zoxide
	elif command -v pacman &>/dev/null; then
		sudo pacman -Sy --noconfirm zsh fzf bat eza ripgrep fd curl git zoxide
	elif command -v dnf &>/dev/null; then
		sudo dnf install -y zsh fzf bat eza ripgrep fd-find curl git zoxide
	else
		echo "[ERROR] Gestor de paquetes no reconocido"
		exit 1
	fi
}

echo "== Instalando paquetes base..."
install_packages

echo "== Instalando starship..."
curl -sS https://starship.rs/install.sh | sh -s -- --yes

echo "== Cambiando shell a zsh..."
chsh -s $(which zsh)

echo "[OK] Entorno base listo - abre una nueva terminal para aplicar"
