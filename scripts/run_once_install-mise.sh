#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Bootstrap Mise (Universal Tool Manager)
# ----------------------------------------------------------------------

set -euo pipefail

if ! command -v mise &>/dev/null; then
    echo "== Instalando mise..."
    curl https://mise.jdx.dev/install.sh | sh
    
    # Asegurar que el binario sea accesible para el resto del script
    export PATH="$HOME/.local/bin:$PATH"
fi

echo "== Verificando herramientas de mise..."
# Forzar la instalacion de las herramientas y runtimes (Node, Python, Lua)
~/.local/bin/mise install -y

# ----------------------------------------------------------------------
# Post-Install: Neovim Providers
# ----------------------------------------------------------------------
echo "== Configurando providers para Neovim..."

# Activar Mise para que npm y pip estén disponibles en el script
eval "$(~/.local/bin/mise activate bash)"

# Provider de Node.js
if command -v npm &>/dev/null; then
    echo "  - Instalando neovim npm package..."
    npm install -g neovim || echo "Advertencia: Fallo npm neovim"
fi

# Provider de Python
if command -v pip &>/dev/null; then
    echo "  - Instalando pynvim..."
    pip install pynvim || echo "Advertencia: Fallo pynvim"
fi

echo "[OK] Mise y entorno de Neovim configurados."
