#!/usr/bin/env bash
# =============================================================================
# provision/system/setup-dualboot-fixes.sh
# Soluciones automáticas para problemas comunes de Dual-Boot (Hora y GRUB)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"

if [ ! -f /etc/fedora-release ]; then
    exit 0
fi

log_info "Configurando optimizaciones y correcciones para Dual-Boot..."

# 1. Corregir desincronización de Hora (RTC Local vs UTC)
log_info "→ Ajustando reloj de hardware (RTC) a hora local..."
sudo timedatectl set-local-rtc 1 --adjust-system-clock
log_ok "Reloj ajustado a hora local (sincronizado con Windows)."

# 2. Habilitar detección de Windows en GRUB (os-prober)
if [ -f /etc/default/grub ]; then
    if ! grep -q "GRUB_DISABLE_OS_PROBER=false" /etc/default/grub; then
        log_info "→ Habilitando os-prober en GRUB para detectar Windows..."
        if grep -q "GRUB_DISABLE_OS_PROBER" /etc/default/grub; then
            sudo sed -i 's/^.*GRUB_DISABLE_OS_PROBER.*/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
        else
            echo "GRUB_DISABLE_OS_PROBER=false" | sudo tee -a /etc/default/grub >/dev/null
        fi
        
        # Regenerar GRUB (Fedora usa ubicación unificada)
        log_info "→ Regenerando configuración de GRUB..."
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null || true
        log_ok "GRUB configurado para detectar Windows."
    else
        log_ok "GRUB ya tiene os-prober habilitado."
    fi
fi
