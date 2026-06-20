#!/usr/bin/env bash
# =============================================================================
# setup-vm-storage.sh
# Script interactivo para preparar el SSD dedicado a la VM de Windows 11
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
echo -e "         Configurador de Almacenamiento Dedicado para VM"
echo -e "=====================================================================${RESET}"

# 1. Mostrar discos actuales
log_info "Discos actuales detectados:"
lsblk -o NAME,MODEL,SIZE,FSTYPE,MOUNTPOINT
echo ""

# 2. Intentar sugerir el disco BX500
suggested_disk=""
bx500_dev=$(lsblk -d -o NAME,MODEL | grep -i "BX500" | awk '{print $1}' | head -n 1 || true)
if [ -n "$bx500_dev" ]; then
    suggested_disk="/dev/$bx500_dev"
    log_info "Sugerencia: Se detectó el disco Crucial BX500 en ${suggested_disk}."
fi

# 3. Solicitar confirmación de la ruta del disco
read -p "Ingresa la ruta del disco SSD para la VM (ej. /dev/sdb) [${suggested_disk}]: " target_disk
target_disk="${target_disk:-$suggested_disk}"

if [ -z "$target_disk" ]; then
    log_err "No se especificó ningún disco. Abortando."
fi

if [ ! -b "$target_disk" ]; then
    log_err "El dispositivo '$target_disk' no existe o no es un bloque."
fi

# Confirmación de destrucción de datos
log_warn "ATENCIÓN: Se formateará COMPLETAMENTE el disco '$target_disk'."
log_warn "Esto eliminará todos los datos existentes en el disco de manera IRREVERSIBLE."
read -p "Escribe 'CONFIRMAR' para proceder: " confirmation

if [ "$confirmation" != "CONFIRMAR" ]; then
    log_err "Confirmación incorrecta. Abortando operación."
fi

# 4. Formatear y preparar el disco
log_info "Limpiando firmas previas en el disco..."
sudo wipefs -a "$target_disk"

log_info "Creando tabla de particiones GPT..."
sudo parted -s "$target_disk" mklabel gpt

log_info "Creando partición primaria ext4..."
sudo parted -s "$target_disk" mkpart primary ext4 0% 100%

# Esperar un segundo a que el kernel actualice la tabla de particiones
sleep 2

# Identificar la partición recién creada
partition=""
if [ -b "${target_disk}1" ]; then
    partition="${target_disk}1"
elif [ -b "${target_disk}p1" ]; then
    partition="${target_disk}p1"
else
    log_err "No se pudo identificar la partición creada en $target_disk."
fi

log_info "Formateando la partición $partition como ext4..."
sudo mkfs.ext4 -F "$partition"

# 5. Configurar punto de montaje y montar
mount_point="/var/lib/libvirt/images"
log_info "Creando punto de montaje en $mount_point..."
sudo mkdir -p "$mount_point"

log_info "Montando $partition en $mount_point..."
sudo mount "$partition" "$mount_point"

# 6. Agregar a fstab usando el UUID
uuid=$(sudo blkid -o value -s UUID "$partition")
if [ -z "$uuid" ]; then
    log_err "No se pudo obtener el UUID de la partición $partition."
fi

log_info "UUID detectado: $uuid"

# Verificar si ya está en fstab
if grep -q "$mount_point" /etc/fstab; then
    log_warn "Ya existe una regla en /etc/fstab para $mount_point. Por favor, revísala manualmente."
else
    log_info "Agregando entrada permanente a /etc/fstab..."
    echo "UUID=$uuid $mount_point ext4 defaults,noatime,nofail 0 2" | sudo tee -a /etc/fstab
    log_ok "Entrada agregada a /etc/fstab."
fi

log_ok "El almacenamiento para VM en '$target_disk' ha sido configurado y montado en $mount_point."
