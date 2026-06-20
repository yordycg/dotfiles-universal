#!/usr/bin/env bash
# =============================================================================
# provision/system/setup-nvidia.sh
# Configuración automatizada de Controladores NVIDIA
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"

if [ ! -f /etc/fedora-release ]; then
    exit 0
fi

# Detectar si hay tarjeta gráfica NVIDIA
if ! lspci | grep -i -q "nvidia"; then
    log_info "No se detectó GPU NVIDIA en este equipo. Saltando configuración de controladores NVIDIA."
    exit 0
fi

log_info "GPU NVIDIA detectada. Configurando controladores..."

# Verificar si el controlador ya está instalado
if ! rpm -q akmod-nvidia &>/dev/null; then
    log_info "→ Instalando akmod-nvidia..."
    sudo dnf install -y akmod-nvidia
else
    log_info "→ akmod-nvidia ya está instalado."
fi

# Forzar compilación de módulos si es necesario
log_info "→ Compilando/Verificando módulos de kernel con akmods..."
sudo akmods --force

# Verificar estado de Secure Boot
if command -v mokutil &>/dev/null; then
    if mokutil --sb-state 2>/dev/null | grep -q "SecureBoot enabled"; then
        log_warn "====================================================================="
        log_warn "⚠️ SECURE BOOT ACTIVO DETECTADO"
        log_warn "En el próximo reinicio aparecerá una pantalla azul de MOKManager."
        log_warn "Debes seleccionar 'Enroll MOK' -> 'Continue' -> 'Yes' y"
        log_warn "usar la contraseña que dnf/akmods configuró para firmar los drivers."
        log_warn "Si no realizas este paso, los controladores de NVIDIA no cargarán."
        log_warn "====================================================================="
    fi
fi

log_ok "Configuración de NVIDIA completada."
