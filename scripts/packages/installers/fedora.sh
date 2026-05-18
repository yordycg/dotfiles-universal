#!/usr/bin/env bash
# Instalador para Fedora (dnf)
# No editar la lista de paquetes aqui... editar en packages.yaml

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/../packages.yaml"

if ! command -v yq &>/dev/null; then
	echo "== Instalando yq..."
	sudo dnf install -y yq
fi

install_section() {
	local section="$1"
	echo "== Instalando: $section"
	local packages
	packages=$(yq e ".packages.${section}[]" "$PACKAGES_FILE" 2>/dev/null || echo "")
	if [ -z "$packages" ]; then
		echo "  (vacio, omitiendo)"
		return
	fi
	sudo dnf install -y --skip-unavailable $packages
}

# Instalar secciones
install_section "core"

if [ -z "${WSL_DISTRO_NAME:-}" ]; then
	install_section "linux_desktop"
fi

if [ "$XDG_CURRENT_DESKTOP" = "sway" ] || [ -n "${SWAYSOCK:-}" ]; then
	install_section "sway_desktop"
	install_section "terminals"
fi

echo "[OK] Fedora Listo"
