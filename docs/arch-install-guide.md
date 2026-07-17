# Guía de Instalación Avanzada de Arch Linux & Dual Boot (Senior SRE Edition)

Esta guía detalla el procedimiento profesional para realizar una instalación limpia de **Arch Linux** compartiendo hardware en un esquema de **Dual Boot con Windows**, aplicando la filosofía "KDE primero" como entorno de respaldo antes de desplegar Hyprland.

---

## 🛠️ Fase 1: Preparativos en Windows (Host)

Para evitar que Windows bloquee el disco o interfiera con el arranque de Linux:

1. **Desactivar el Cifrado BitLocker / Dispositivo:**
   * Abre Configuración de Windows -> Privacidad y Seguridad -> Cifrado de dispositivo -> **Desactivar**.
   * *Razón SRE*: Si BitLocker está activo, Linux no podrá leer la tabla de particiones ni el espacio libre del disco para instalarse.
2. **Desactivar Fast Startup (Inicio Rápido):**
   * Panel de Control -> Opciones de Energía -> "Elegir el comportamiento de los botones de inicio/apagado".
   * Haz clic en "Cambiar la configuración actualmente no disponible" -> Desmarca **"Activar inicio rápido"**.
   * *Razón SRE*: Windows no se apaga realmente con esta opción activa, sino que hiberna el núcleo y monta las particiones en modo de "solo lectura", lo que bloquea el disco para Linux.
3. **Liberar Espacio en Disco:**
   * Abre *Administración de Discos*, haz clic derecho en tu partición de Windows (normalmente `C:`) -> **Reducir Volumen**.
   * Libera al menos **60 GB - 100 GB** de espacio no asignado para Arch Linux.
4. **UEFI Settings:**
   * Reinicia la PC e ingresa a la BIOS/UEFI.
   * Asegúrate de que **Secure Boot** esté desactivado (o configurado en modo compatible / "Other OS").

---

## 📐 Fase 2: Particionado Avanzado Btrfs (Para Snapper)

Arranca la PC usando el Live USB oficial de Arch Linux.

### 1. Comprobar Modo UEFI
```bash
cat /sys/firmware/efi/fwsubsystem/systab
```
*Si el archivo existe, estás en modo UEFI correcto.*

### 2. Estructura de Particionado Recomendada
Usaremos **Btrfs** para permitir copias de seguridad atómicas y rollbacks rápidos con Snapper.
*   **Partición EFI (`/boot` o `/efi`):** Compartiremos la partición EFI existente de Windows (usualmente de 100MB a 260MB, formateada en FAT32) o crearemos una secundaria de 1GB en el espacio libre si la de Windows es muy pequeña.
*   **Partición Root (`/`):** Todo el espacio libre formateado en Btrfs.

### 3. Configuración Manual de Subvolúmenes Btrfs (Para Snapper)
Para que Snapper pueda realizar copias de seguridad de `/` sin incluir los archivos temporales de logs ni tu carpeta `/home`, estructuramos los subvolúmenes de la siguiente forma:

Supongamos que tu partición de Arch es `/dev/nvme0n1p6`:
```bash
# Formatear la partición de Arch
mkfs.btrfs -L arch_root /dev/nvme0n1p6

# Montar temporalmente para crear subvolúmenes
mount /dev/nvme0n1p6 /mnt
cd /mnt

# Crear la estructura de subvolúmenes estándar
btrfs subvolume create @             # Raíz del sistema (/)
btrfs subvolume create @home         # Datos de usuario (/home)
btrfs subvolume create @snapshots    # Instantáneas del sistema (/.snapshots)
btrfs subvolume create @var_log      # Registro del sistema (/var/log)

# Desmontar la partición temporal
cd /
umount /mnt
```

### 4. Montar los Subvolúmenes con Opciones de Rendimiento SSD
Montamos los subvolúmenes en sus rutas finales dentro de `/mnt` aplicando optimizaciones para SSD:
```bash
# Opciones de montaje recomendadas para SSD
OPTS="noatime,compress=zstd:3,ssd,discard=async,space_cache=v2"

# Montar subvolumen raíz
mount -o subvol=$OPTS /dev/nvme0n1p6 /mnt

# Crear los puntos de montaje para los subvolúmenes hijos
mkdir -p /mnt/{home,.snapshots,var/log,boot}

# Montar el resto de subvolúmenes
mount -o subvol=@home,$OPTS /dev/nvme0n1p6 /mnt/home
mount -o subvol=@snapshots,$OPTS /dev/nvme0n1p6 /mnt/.snapshots
mount -o subvol=@var_log,$OPTS /dev/nvme0n1p6 /mnt/var/log

# Montar la partición EFI existente de Windows (ej: /dev/nvme0n1p1)
mount /dev/nvme0n1p1 /mnt/boot
```

---

## 🚀 Fase 3: Instalación de Arch (La Vía del SRE)

Para ahorrar tiempo y garantizar una instalación base estándar, utilizamos la utilidad oficial e interactiva de Arch:

1. Ejecuta el instalador:
   ```bash
   archinstall
   ```
2. Configura los parámetros clave en el menú:
   * **Disk Configuration:** Elige "Use pre-mounted disk configuration" (para usar el esquema de subvolúmenes Btrfs que montamos en la Fase 2 en `/mnt`).
   * **Profile:** `Desktop` -> `KDE` (Plasma 6).
   * **Display Manager:** `SDDM`.
   * **Audio:** `Pipewire`.
   * **Network Configuration:** `NetworkManager` (necesario para gestionar Wi-Fi/Ethernet).
   * **Kernel:** `linux` (estable) o `linux-zen` (optimizado para rendimiento en desktop).
   * **Graphics Driver:** Elige según tu hardware (Nvidia Proprietary, AMD open-source o Intel).
   * **Additional Packages:** Añade `git`, `neovim` y `sudo`.
   * **Create User:** Crea tu usuario `yordycg` y activa la casilla **"Sudo privileges"**.
3. Haz clic en **Install** y espera a que termine.

---

## 🖥️ Fase 4: Configuración Avanzada de Dual Boot (GRUB)

Una vez finalizada la instalación de `archinstall`, el instalador te preguntará si quieres entrar en un entorno `chroot` antes de reiniciar. **Elige que SÍ (Yes).**

Dentro del chroot, instalaremos y configuraremos GRUB para que detecte Windows automáticamente:

1. **Instalar paquetes de arranque:**
   ```bash
   pacman -S --noconfirm grub efibootmgr os-prober
   ```
2. **Habilitar la detección de otros sistemas (os-prober):**
   Edita el archivo de configuración de GRUB:
   ```bash
   nano /etc/default/grub
   ```
   Busca la siguiente línea al final del archivo, descoméntala (o agrégala si no existe) y configúrala en `false`:
   ```ini
   GRUB_DISABLE_OS_PROBER=false
   ```
   Guarda y cierra (`Ctrl+O`, `Enter`, `Ctrl+X`).
3. **Instalar GRUB en la partición EFI:**
   ```bash
   grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
   ```
4. **Generar el archivo de configuración de GRUB:**
   ```bash
   grub-mkconfig -o /boot/grub/grub.cfg
   ```
   *Verifica en la salida de la terminal que aparezca la línea indicando que se ha encontrado "Windows Boot Manager".*
5. **Salir del chroot y reiniciar:**
   ```bash
   exit
   reboot
   ```

---

## ⏰ Fase 5: Estabilización del Reloj del Sistema (RTC Fix)

Por defecto, Windows guarda la hora local del país en el reloj físico de la placa madre (RTC), mientras que Linux guarda la hora en formato universal UTC (lo que provoca que al cambiar de sistema operativo, la hora se desfase por varias horas).

Para solucionar esto de forma permanente y limpia, abre una terminal en tu nuevo escritorio de Arch Linux y ejecuta:

```bash
timedatectl set-local-rtc 1 --adjust-system-clock
```
*Este comando le dice a Arch Linux que mantenga el reloj físico en hora local sincronizado con Windows. Es el método más estable para evitar problemas de sincronización de hora en configuraciones Dual-Boot.*

---

## 🚀 Fase 6: Despliegue de los Dotfiles (Chezmoi)

Una vez que estás en tu nuevo escritorio de KDE en Arch Linux con acceso a internet:

1. **Clona y aplica tus dotfiles:**
   Sigue las instrucciones de la [Guía de Aprovisionamiento](bootstrap-guide.md):
   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply yordycg
   ```
2. **Iniciar en Hyprland:**
   Cierra sesión en KDE, selecciona "Hyprland" en la pantalla de SDDM e ingresa a tu entorno productivo.
