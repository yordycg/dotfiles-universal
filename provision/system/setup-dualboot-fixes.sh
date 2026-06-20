#!/usr/bin/env bash
# =============================================================================
# provision/system/setup-dualboot-fixes.sh
# Soluciones automáticas para problemas comunes de Dual-Boot (Hora y GRUB)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"

log_info "Configurando optimizaciones y correcciones para Dual-Boot..."

# 1. Corregir desincronización de Hora (RTC Local vs UTC)
if command -v timedatectl &>/dev/null; then
    log_info "→ Ajustando reloj de hardware (RTC) a hora local..."
    sudo timedatectl set-local-rtc 1 --adjust-system-clock
    log_ok "Reloj ajustado a hora local (sincronizado con Windows)."
else
    log_warn "timedatectl no disponible. Saltando ajuste de hora."
fi

# 2. Habilitar detección de Windows en GRUB (os-prober)
if [ -f /etc/default/grub ]; then
    if ! grep -q "GRUB_DISABLE_OS_PROBER=false" /etc/default/grub; then
        log_info "→ Habilitando os-prober en GRUB para detectar Windows..."
        if grep -q "GRUB_DISABLE_OS_PROBER" /etc/default/grub; then
            sudo sed -i 's/^.*GRUB_DISABLE_OS_PROBER.*/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
        else
            echo "GRUB_DISABLE_OS_PROBER=false" | sudo tee -a /etc/default/grub >/dev/null
        fi
        
        # Determinar comando y ruta de configuración de GRUB según distro
        if command -v update-grub &>/dev/null; then
            log_info "→ Regenerando configuración de GRUB vía update-grub..."
            sudo update-grub
            log_ok "GRUB configurado para detectar Windows."
        else
            # Determinar la ruta de salida correcta
            grub_cfg="/boot/grub/grub.cfg"
            if [ -f /etc/fedora-release ]; then
                grub_cfg="/boot/grub2/grub.cfg"
            fi
            
            # Ejecutar mkconfig
            if command -v grub2-mkconfig &>/dev/null; then
                log_info "→ Regenerando configuración de GRUB en $grub_cfg..."
                sudo grub2-mkconfig -o "$grub_cfg"
                log_ok "GRUB configurado para detectar Windows."
            elif command -v grub-mkconfig &>/dev/null; then
                log_info "→ Regenerando configuración de GRUB en $grub_cfg..."
                sudo grub-mkconfig -o "$grub_cfg"
                log_ok "GRUB configurado para detectar Windows."
            else
                log_warn "No se encontró comando para regenerar GRUB (grub-mkconfig). Por favor, hazlo manualmente."
            fi
        fi
    else
        log_ok "GRUB ya tiene os-prober habilitado."
    fi
fi
