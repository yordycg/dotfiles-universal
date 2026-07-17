# Guía de Instalación: Arch Linux & Windows (Dual-Boot)

Esta guía detalla el procedimiento para configurar un sistema de arranque dual (Dual-Boot) entre Windows y Arch Linux en el mismo equipo, usando Btrfs en la partición Linux, y respetando las configuraciones de ambos sistemas.

---

## 📋 Fase 0: Elige tu Punto de Partida

Antes de empezar, identifica tu caso para aplicar los pasos correspondientes:

* **Caso A (Instalación Nueva):** Disco vacío. **Instala Windows primero**, deja espacio libre sin asignar al final del disco y luego continúa con esta guía.
* **Caso B (Windows ya instalado):** Conservarás el Windows activo e instalarás Arch en el espacio libre del disco.
* **Caso C (Windows + otra distro Linux instalada):** Deseas reemplazar la distribución Linux antigua por Arch, manteniendo Windows intacto. Ve directo al [Apéndice B: Reemplazar una distro existente](#apéndice-b-reemplazar-una-distro-existente-por-arch).

> [!IMPORTANT]
> **¿Por qué instalar Windows primero?**
> El instalador de Windows no respeta a otros sistemas operativos ni detecta Linux. Sobrescribe la prioridad de arranque en la UEFI poniéndose a sí mismo en primer lugar. `os-prober` en Arch Linux sí detecta a Windows de forma nativa. Si instalas en orden (Windows → Arch), configurar la convivencia es mucho más sencillo y limpio.

---

## 🛠️ Fase 1: Preparativos en Windows

Si ya tienes Windows corriendo o acabas de instalarlo, debes preparar el sistema antes de iniciar la instalación de Linux:

### 1. Desactivar BitLocker (Cifrado de Unidad)
Si tu unidad principal está cifrada con BitLocker, Linux no podrá leer ni redimensionar las particiones. Debes desactivarlo:
1. Abre **PowerShell** como Administrador.
2. Ejecuta:
   ```powershell
   manage-bde -off C:
   ```
3. Verifica el progreso con:
   ```powershell
   manage-bde -status C:
   ```
   *⚠️ IMPORTANTE: No apagues ni reinicies el equipo hasta que el estado muestre "Percentage Encrypted: 0%". El descifrado puede tomar unos minutos.*

### 2. Desactivar Fast Startup (Inicio Rápido) e Hibernación
Windows bloquea el disco duro en un estado de semi-hibernación cuando se apaga con el Inicio Rápido activo, impidiendo que Linux monte las particiones de forma segura.
1. En PowerShell como Administrador, ejecuta:
   ```powershell
   powercfg /h off
   ```
   *(Esto desactiva tanto la hibernación como el Inicio Rápido, liberando espacio equivalente a tu memoria RAM).*

### 3. Reducir la Partición de Windows (Liberar Espacio)
Si no dejaste espacio libre sin asignar durante la instalación de Windows, reduce la partición actual:
1. Presiona `Win + X` y selecciona **Administración de discos**.
2. Haz clic derecho sobre tu unidad `C:` y selecciona **Reducir volumen...**
3. Especifica el espacio que deseas liberar para Arch Linux (se recomienda un mínimo de 100 GB para un entorno de desarrollo cómodo) y confirma.
4. El espacio liberado debe quedar como **"No asignado"** (Unallocated).

---

## 📐 Fase 2: Particionado Btrfs (Live USB de Arch)

Arranca tu Live USB de Arch Linux con Ventoy, configura el teclado e internet (ver pasos iniciales en [single-boot.md](single-boot.md#-fase-1-preparativos-en-el-live-usb)) y realiza el particionado:

### 1. Identificar Particiones Existentes
```bash
lsblk -f
```
Debes localizar:
* Tu partición principal de Windows (NTFS).
* La partición EFI existente (ESP) creada por Windows. Suele medir entre 100 y 260 MB, está formateada en FAT32 y tiene la bandera EFI. *(Ejemplo: `/dev/nvme0n1p1`)*.

### 2. Crear la Partición de Arch Linux
Abre la herramienta de particionado apuntando a tu unidad de almacenamiento:
```bash
cfdisk /dev/nvme0n1
```
1. Busca la sección que dice **Free Space** (Espacio Libre).
2. Selecciona **New**, asigna todo el tamaño disponible (o lo que desees para Linux) y créala.
3. Asegúrate de que el tipo de partición quede como **Linux filesystem**.
4. Selecciona **Write** (escribe `yes`) y **Quit**.

### 3. Formatear y Crear Subvolúmenes Btrfs
Asumiendo que tu nueva partición Linux es `/dev/nvme0n1p6`:
```bash
# Limpiar firmas previas por seguridad
wipefs -a /dev/nvme0n1p6

# Formatear
mkfs.btrfs -L arch_root /dev/nvme0n1p6

# Montar y crear subvolúmenes para separar sistema de datos
mount /dev/nvme0n1p6 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@swap
umount /mnt
```

### 4. Montar los Subvolúmenes en /mnt
```bash
OPTS="noatime,compress=zstd:3,ssd,discard=async,space_cache=v2"

# Montar raíz
mount -o subvol=@,$OPTS /dev/nvme0n1p6 /mnt

# Crear puntos de montaje
mkdir -p /mnt/{home,.snapshots,var/log,boot,swap}

# Montar subvolúmenes secundarios
mount -o subvol=@home,$OPTS /dev/nvme0n1p6 /mnt/home
mount -o subvol=@snapshots,$OPTS /dev/nvme0n1p6 /mnt/.snapshots
mount -o subvol=@var_log,$OPTS /dev/nvme0n1p6 /mnt/var/log
mount -o subvol=@swap /dev/nvme0n1p6 /mnt/swap

# MONTAJE CRÍTICO: Montar la partición EFI existente de Windows en /boot
# Asegúrate de usar la partición FAT32 correcta de Windows (ej. nvme0n1p1)
mount /dev/nvme0n1p1 /mnt/boot
```

> [!WARNING]
> Si la partición EFI original de Windows es menor a 250 MB y vas a instalar múltiples kernels en Arch (ej. `linux`, `linux-zen` y sus fallback), el espacio podría quedarse muy ajustado. Si tienes menos de 150 MB libres en la EFI, se recomienda crear una EFI secundaria dedicada en el espacio de Linux (de 512 MB) en lugar de compartir la de Windows.

---

## 🚀 Fase 3: Instalación con `archinstall`

Ejecuta el instalador interactivo:
```bash
pacman -Sy archlinux-keyring --noconfirm
archinstall
```

Configura las opciones con cuidado:
1. **Disk Configuration:** Selecciona **"Use a pre-mounted configuration"** apuntando a `/mnt`. Esto le dice al instalador que instale en las particiones y subvolúmenes que ya montaste a mano.
2. **Bootloader:** Elige **GRUB** (necesario para gestionar de forma nativa el Dual Boot con Windows).
3. **Profile:** `Desktop` → `KDE`.
4. **Display Manager:** `SDDM`.
5. **Audio:** `Pipewire`.
6. **Network Configuration:** `NetworkManager`.
7. **Kernel:** `linux` o `linux-zen`.
8. **Additional Packages:** `git`, `neovim`, `sudo`, `ntfs-3g` *(obligatorio para leer la partición Windows)*, `zram-generator` (opcional).
9. **Create User:** Crea tu usuario con privilegios de Sudo.

Al finalizar la instalación, selecciona **Sí** cuando pregunte si quieres entrar en el entorno chroot.

---

## 🖥️ Fase 4: Configuración de GRUB y Dual Boot (Chroot)

Dentro del chroot, debemos configurar GRUB para que detecte Windows y nos muestre el menú de selección al encender la máquina.

1. **Instalar paquetes necesarios:**
   ```bash
   pacman -S --noconfirm efibootmgr os-prober ntfs-3g
   ```

2. **Habilitar la detección de otros sistemas operativos:**
   Edita el archivo de configuración de GRUB:
   ```bash
   nano /etc/default/grub
   ```
   Busca la siguiente línea (o agrégala al final si no existe) y asegúrate de que esté configurada en `false` (descomentada):
   ```ini
   GRUB_DISABLE_OS_PROBER=false
   ```
   Guarda los cambios (`Ctrl + O`, `Enter`) y sal (`Ctrl + X`).

3. **Verificar permisos y ejecutar GRUB:**
   Asegúrate de que el script de detección tenga permisos de ejecución:
   ```bash
   chmod +x /etc/grub.d/30_os-prober
   ```

4. **Instalar y generar el menú de arranque:**
   ```bash
   # Instalar GRUB en la partición EFI compartida
   grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck

   # Generar el archivo de configuración
   grub-mkconfig -o /boot/grub/grub.cfg
   ```
   *En la salida del último comando, deberías ver una línea que indica: `Found Windows Boot Manager on /dev/nvme0n1p1@/EFI/Microsoft/Boot/bootmgfw.efi`.*

5. **Salir y reiniciar:**
   ```bash
   exit
   reboot
   ```
   Retira el Live USB. Deberías ver la interfaz de GRUB permitiéndote seleccionar entre Arch Linux y Windows Boot Manager.

---

## ⏰ Fase 5: Sincronización horaria (RTC)

Por defecto, Linux asume que la hora de la placa base (RTC) se almacena en **UTC**, mientras que Windows asume que está en **hora local**. Esto causa que cada vez que cambies de sistema operativo, la hora del reloj se desfase unas horas.

### Solución Recomendada: Configurar Windows para usar UTC
Es el método más limpio ya que mantiene el estándar del hardware en UTC.
1. Arranca en Windows.
2. Abre **PowerShell** como Administrador.
3. Ejecuta el siguiente comando para agregar la entrada al Registro de Windows:
   ```powershell
   reg add "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_DWORD /d 1 /f
   ```
4. Sincroniza la hora una vez desde los Ajustes de Windows. A partir de ahora, ambos sistemas coincidirán perfectamente.

---

## Apéndice B: Reemplazar una distro existente por Arch

Si ya tenías Windows y otra distro Linux (ej. Fedora o Ubuntu) instalados, y quieres reemplazar la distro Linux vieja por Arch:

1. **Arranca con el Live USB de Arch Linux.**
2. **Identificar las particiones antiguas:**
   ```bash
   lsblk -f
   efibootmgr -v          # Anota el identificador numérico de la distro vieja (ej. Boot0004 de Fedora)
   ```
3. **Limpiar la partición raíz antigua:**
   *⚠️ ATENCIÓN: Asegúrate de no tocar las particiones NTFS de Windows ni la partición FAT32 (EFI).*
   Si la partición de la distro vieja es `/dev/nvme0n1p4`:
   ```bash
   wipefs -a /dev/nvme0n1p4
   ```
4. **Proceder con el flujo normal de la Fase 2 (desde el paso 3 en adelante):** Formatea esa misma partición en Btrfs, crea los subvolúmenes y móntala en `/mnt`. Monta la partición EFI existente en `/mnt/boot`.
5. **Instalar con `archinstall` (Fase 3) y configurar GRUB (Fase 4).**
6. **Limpia la entrada de arranque antigua de la UEFI** para evitar basura en el menú de la placa base:
   ```bash
   # Dentro del chroot (o en el Live USB antes de reiniciar):
   efibootmgr -b <bootnum_viejo> -B
   # Ejemplo: efibootmgr -b 0004 -B
   ```
