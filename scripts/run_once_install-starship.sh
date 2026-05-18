#!/usr/bin/env bash
# Instalar starship si no esta disponible en los repositorios
if ! command -v starship &>/dev/null; then
	echo "== Instalando starship..."
	curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi
