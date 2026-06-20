#!/usr/bin/env bash
# =============================================================================
# setup-data-mounts.sh
# Script interactivo para configurar el montaje automático de los discos de datos (Respaldo y Estudio)
# =============================================================================
set -euo pipefail

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

log_info() { echo -e "${CYAN}→ $1${RESET}"; }
log_warn() { echo -e "${YELLOW}⚠️  $1${RESET}"; }
log_err()  { echo -e "${RED}❌ $1${RESET}"; exit 1; }
log_ok()   { echo -e "${GREEN}✓ $1${RESET}"; }

echo -e "${CYAN}====================================================================="
echo -e "       Configurador de Montaje para Discos de Datos (NTFS)"
echo -e "=====================================================================${RESET}"

# 1. Mostrar particiones NTFS
log_info "Particiones NTFS detectadas:"
lsblk -o NAME,MODEL,SIZE,FSTYPE,UUID,MOUNTPOINT | grep -E "FSTYPE|ntfs" || true
echo ""

# 2. Configurar Disco Respaldo (WD10EZEX)
suggested_respaldo_uuid=""
respaldo_dev=$(lsblk -o NAME,MODEL,FSTYPE,UUID | grep -i "WD10EZEX" | grep -i "ntfs" | awk '{print $NF}' | head -n 1 || true)
if [ -n "$respaldo_dev" ]; then
    suggested_respaldo_uuid="$respaldo_dev"
    log_info "Sugerencia: Se detectó el disco WD10EZEX (Respaldo) con UUID: $suggested_respaldo_uuid"
fi

read -p "Ingresa el UUID de la partición de Respaldo [$suggested_respaldo_uuid]: " respaldo_uuid
respaldo_uuid="${respaldo_uuid:-$suggested_respaldo_uuid}"

# 3. Configurar Disco Estudio (HDWD110)
suggested_estudio_uuid=""
estudio_dev=$(lsblk -o NAME,MODEL,FSTYPE,UUID | grep -i "HDWD110" | grep -i "ntfs" | awk '{print $NF}' | head -n 1 || true)
if [ -n "$estudio_dev" ]; then
    suggested_estudio_uuid="$estudio_dev"
    log_info "Sugerencia: Se detectó el disco HDWD110 (Estudio) con UUID: $suggested_estudio_uuid"
fi

read -p "Ingresa el UUID de la partición de Estudio [$suggested_estudio_uuid]: " estudio_uuid
estudio_uuid="${estudio_uuid:-$suggested_estudio_uuid}"

# 4. Crear puntos de montaje
mount_respaldo="/mnt/Respaldo"
mount_estudio="/mnt/Estudio"

log_info "Creando puntos de montaje..."
sudo mkdir -p "$mount_respaldo" "$mount_estudio"

# 5. Agregar a /etc/fstab de forma segura con nofail y uid/gid para control total en Linux
ntfs_driver="ntfs3"
if ! grep -q "ntfs3" /proc/filesystems 2>/dev/null && command -v mount.ntfs-3g &>/dev/null; then
    ntfs_driver="ntfs-3g"
fi
log_info "Usando driver NTFS: $ntfs_driver"

mount_options="defaults,noatime,nofail,uid=1000,gid=1000,dmask=022,fmask=133"

# Respaldo
if [ -n "$respaldo_uuid" ]; then
    if grep -q "$mount_respaldo" /etc/fstab; then
        log_warn "Ya existe una regla en /etc/fstab para $mount_respaldo. Saltando."
    else
        log_info "Agregando entrada para Respaldo en /etc/fstab..."
        echo "UUID=$respaldo_uuid $mount_respaldo $ntfs_driver $mount_options 0 0" | sudo tee -a /etc/fstab
        log_ok "Entrada para Respaldo agregada."
    fi
fi

# Estudio
if [ -n "$estudio_uuid" ]; then
    if grep -q "$mount_estudio" /etc/fstab; then
        log_warn "Ya existe una regla en /etc/fstab para $mount_estudio. Saltando."
    else
        log_info "Agregando entrada para Estudio en /etc/fstab..."
        echo "UUID=$estudio_uuid $mount_estudio $ntfs_driver $mount_options 0 0" | sudo tee -a /etc/fstab
        log_ok "Entrada para Estudio agregada."
    fi
fi

# 6. Montar todo
log_info "Montando particiones..."
sudo mount -a || true

log_ok "Discos de datos configurados y montados."
