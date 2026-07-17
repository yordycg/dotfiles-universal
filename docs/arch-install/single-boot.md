# Guía de Instalación: Arch Linux (Single-Boot)

Esta guía describe el proceso paso a paso para instalar Arch Linux con KDE Plasma como el **único sistema operativo** de tu equipo, eliminando cualquier rastro de sistemas anteriores y aplicando el esquema de almacenamiento Btrfs recomendado.

---

## 🛠️ Fase 1: Preparativos en el Live USB

Una vez hayas arrancado la máquina con la ISO de Arch Linux, estarás ante un prompt de terminal. Sigue estos pasos previos:

1. **Configurar el idioma del teclado (si no es US):**
   ```bash
   loadkeys es
   ```
   *(Reemplaza `es` por `la-latin1` si usas teclado latinoamericano).*

2. **Verificar la conexión a Internet:**
   Si estás conectado por cable Ethernet, se autoconfigurará. Compruébalo con:
   ```bash
   ping -c 3 archlinux.org
   ```
   **Si estás por Wi-Fi:**
   ```bash
   iwctl
   # Dentro de la consola interactiva de iwctl:
   device list                          # Identifica tu dispositivo, usualmente wlan0
   station wlan0 scan
   station wlan0 get-networks
   station wlan0 connect "TU_SSID"      # Te pedirá la contraseña del Wi-Fi
   exit
   ```

3. **Sincronizar el reloj del sistema:**
   ```bash
   timedatectl set-ntp true
   ```

4. **Verificar el modo UEFI:**
   ```bash
   ls /sys/firmware/efi/efivars
   ```
   *Si este directorio existe y muestra variables, estás en modo UEFI correcto. Si da un error, revisa la configuración de la BIOS de tu placa base.*

---

## 📐 Fase 2: Particionado del Disco (Btrfs)

Aquí tienes dos caminos: la **Opción A (Automática)** o la **Opción B (Manual Avanzada)**. Se recomienda la Opción B si deseas control total sobre la estructura de subvolúmenes para backups instantáneos con Snapper.

> [!WARNING]
> Ambos métodos borrarán de forma irreversible todos los datos del disco seleccionado. Asegúrate de haber realizado copias de seguridad de tus archivos importantes.

### Opción A: Particionado Guiado Automático (Recomendado para simplicidad)
Puedes omitir este paso por completo y dejar que `archinstall` (en la Fase 3) formatee todo el disco de manera automática seleccionando "Btrfs" como sistema de archivos. Él se encargará de crear una partición EFI y una partición raíz Btrfs con subvolúmenes básicos (`@` y `@home`).

---

### Opción B: Particionado Manual Avanzado (Máximo Control y Soporte Snapper)
Este método crea una estructura de subvolúmenes personalizada compatible con dotfiles y herramientas de restauración.

#### 1. Identificar el Disco de Destino
```bash
lsblk
```
*(Identifica tu unidad, por ejemplo `/dev/nvme0n1` o `/dev/sda`).*

#### 2. Crear las Particiones
Usa `cfdisk` para limpiar el disco y crear dos particiones:
```bash
cfdisk /dev/nvme0n1
```
* Selecciona **label type: gpt**.
* Elimina cualquier partición existente si el disco no está vacío.
* **Partición 1 (EFI):** Crea una partición de **512 MB a 1 GB**, de tipo **EFI System**.
* **Partición 2 (Raíz):** Crea una partición con el resto del espacio disponible, de tipo **Linux filesystem**.
* Selecciona **Write** (escribe `yes`) y luego **Quit**.

#### 3. Formatear las Particiones
Asumiendo que tus particiones creadas son `/dev/nvme0n1p1` (EFI) y `/dev/nvme0n1p2` (Raíz):
```bash
# Formatear la partición EFI en FAT32
mkfs.fat -F 32 /dev/nvme0n1p1

# Formatear la partición principal en Btrfs
mkfs.btrfs -L arch_root /dev/nvme0n1p2
```

#### 4. Crear los Subvolúmenes Btrfs
Montamos temporalmente la partición para crear la estructura de subvolúmenes:
```bash
mount /dev/nvme0n1p2 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@swap

umount /mnt
```

#### 5. Montar los Subvolúmenes con Opciones de Optimización SSD
Montamos los subvolúmenes en sus respectivos directorios del sistema de archivos final `/mnt`:
```bash
# Opciones de optimización para SSD (compresión, descarte asíncrono, etc.)
OPTS="noatime,compress=zstd:3,ssd,discard=async,space_cache=v2"

# Montar subvolumen raíz
mount -o subvol=@,$OPTS /dev/nvme0n1p2 /mnt

# Crear la estructura de directorios
mkdir -p /mnt/{home,.snapshots,var/log,boot,swap}

# Montar el resto de subvolúmenes
mount -o subvol=@home,$OPTS /dev/nvme0n1p2 /mnt/home
mount -o subvol=@snapshots,$OPTS /dev/nvme0n1p2 /mnt/.snapshots
mount -o subvol=@var_log,$OPTS /dev/nvme0n1p2 /mnt/var/log
mount -o subvol=@swap /dev/nvme0n1p2 /mnt/swap

# Montar la partición EFI en /boot
mount /dev/nvme0n1p1 /mnt/boot
```

#### 6. Configurar el Swapfile (Opcional si usas zram más adelante)
Si prefieres un archivo swap en disco bajo Btrfs:
```bash
chattr +C /mnt/swap                     # Desactiva Copy-on-Write para el directorio swap, obligatorio
truncate -s 0 /mnt/swap/swapfile
fallocate -l 8G /mnt/swap/swapfile      # Reemplaza 8G por el tamaño que necesites (ej. igual a tu RAM)
chmod 600 /mnt/swap/swapfile
mkswap /mnt/swap/swapfile
swapon /mnt/swap/swapfile
```

---

## 🚀 Fase 3: Instalación con `archinstall`

Para simplificar la instalación de paquetes y configuración base, utilizaremos el instalador oficial interactivo de Arch Linux:

```bash
# Actualizar el llavero de firmas para evitar problemas de mirrors antiguos
pacman -Sy archlinux-keyring --noconfirm

# Lanzar el instalador
archinstall
```

### Configuración del menú de `archinstall`:

1. **Disk Configuration:**
   * **Si usaste la Opción A (Automática):** Selecciona tu disco → "Erase all selected drives" → Selecciona **Btrfs** como filesystem.
   * **Si usaste la Opción B (Manual Avanzada):** Selecciona **"Use a pre-mounted configuration"** apuntando a `/mnt`. El instalador respetará tu estructura de subvolúmenes montada.
2. **Bootloader:** Selecciona **GRUB** (la opción predeterminada y más robusta).
3. **Profile:** Selecciona `Desktop` → `KDE` (Plasma 6).
4. **Display Manager:** Selecciona `SDDM`.
5. **Audio:** Selecciona `Pipewire` (estándar moderno).
6. **Network Configuration:** Selecciona `NetworkManager` (necesario para gestionar conexiones desde el entorno gráfico).
7. **Kernel:** Selecciona `linux` (estable) o `linux-zen` (optimizado para escritorio).
8. **Graphics Driver:** Elige según tu hardware (NVIDIA, AMD u Open Source).
9. **Additional Packages:** Añade `git`, `neovim`, `sudo` y `zram-generator` (si prefieres swap comprimido en RAM en lugar de swapfile en disco).
10. **Create User:** Crea tu usuario principal (ej: `yordycg`), asígnale una contraseña segura y actívale la opción **"Sudo privileges"**.

Al finalizar la instalación, `archinstall` te preguntará si quieres acceder al entorno chroot para realizar configuraciones adicionales. **Selecciona Sí.**

---

## 🖥️ Fase 4: Ajustes Finales en Chroot

Dentro del entorno chroot (que simula estar dentro del sistema instalado), realiza estos ajustes rápidos:

```bash
# Instalar utilidades del gestor de arranque UEFI
pacman -S --noconfirm efibootmgr

# Instalar y configurar GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Salir de chroot
exit

# Desmontar todo y reiniciar
umount -R /mnt
reboot
```

Retira el USB de Ventoy. Tu máquina arrancará directamente a la pantalla de inicio de sesión de SDDM, donde podrás introducir tu contraseña y acceder al escritorio de KDE Plasma.

---

## ⏰ Fase 5: Post-instalación y Dotfiles

Una vez dentro de tu sesión gráfica de KDE, abre la terminal (`kitty` o `konsole`) y ejecuta el aprovisionamiento automático mediante Chezmoi para aplicar todas tus configuraciones, atajos y perfiles:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply yordycg
```

Si todo finaliza correctamente, cierra sesión y cámbiate de "Plasma" a **"Hyprland"** en el selector de la esquina de tu pantalla de inicio de sesión de SDDM.
