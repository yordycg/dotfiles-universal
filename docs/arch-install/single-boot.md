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
Usa `cfdisk` para limpiar el disco y definir la tabla de particiones:
```bash
cfdisk /dev/nvme0n1
```
* **Tipo de tabla:** Si te pregunta por el tipo de tabla de particiones (*Select label type*), selecciona **`gpt`**. Si detecta una tabla previa, entrará directamente.
* **Limpiar el disco:** Selecciona cada una de las particiones existentes y muévete al menú inferior para elegir **`Delete`** hasta que solo quede una línea de **`Free space`**.
* **Partición 1 (EFI):** Selecciona el `Free space` -> **`New`** -> Escribe **`1G`** (recomendado para dar holgura a múltiples kernels) -> Presiona Enter. Luego, muévete a **`Type`** y selecciona **`EFI System`**.
* **Partición 2 (Raíz):** Selecciona el `Free space` restante -> **`New`** -> Deja el tamaño por defecto (el resto de tu disco) -> Presiona Enter. (El tipo por defecto será *Linux filesystem*, lo cual es correcto).
* **Guardar y Salir:** Muévete a **`Write`** -> Escribe la palabra **`yes`** completa y presiona Enter. Luego selecciona **`Quit`** y sal.

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
Si prefieres un archivo swap en disco bajo Btrfs (necesario si quieres una red de seguridad contra desbordamientos de memoria):
```bash
chattr +C /mnt/swap                     # Desactiva Copy-on-Write para el directorio swap, obligatorio
truncate -s 0 /mnt/swap/swapfile
fallocate -l 8G /mnt/swap/swapfile      # 8G es ideal para paginación de seguridad (cámbialo al tamaño de tu RAM si vas a usar Hibernación)
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
3. **Profile:** Selecciona `Desktop` → `KDE` (Plasma 6). Selecciona **`plasma-meta`** como paquete de Plasma.
4. **Display Manager:** Selecciona `SDDM`.
5. **Audio:** Selecciona `Pipewire` (estándar moderno).
6. **Network Configuration:** Selecciona `NetworkManager` (el default backend basado en `wpa_supplicant`, necesario para gestionar conexiones de red).
7. **Kernel:** Selecciona `linux` (estable) o `linux-zen` (optimizado para escritorio).
8. **Graphics Driver:** Elige `Intel` para la gráfica integrada de tu ThinkPad (o `All open-source`).
9. **Additional Packages:** Añade **`konsole dolphin git neovim sudo`**. 
   > [!IMPORTANT]
   > Dado que `plasma-meta` es minimalista, no instala por defecto aplicaciones adicionales. Si no agregas `konsole` (terminal) y `dolphin` (administrador de archivos) aquí, el sistema gráfico inicial no tendrá forma de abrir la consola.
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

# Apagar el swapfile para liberar el montaje (evita el error 'target is busy')
swapoff -a

# Desmontar todo y reiniciar
umount -R /mnt
reboot
```

Retira el USB de Ventoy. Tu máquina arrancará directamente a la pantalla de inicio de sesión de SDDM, donde podrás introducir tu contraseña y acceder al escritorio de KDE Plasma.

---

## ⏰ Fase 5: Post-instalación y Dotfiles

Una vez dentro de tu sesión gráfica de KDE, abre la terminal (`konsole`) y ejecuta el aprovisionamiento automático mediante Chezmoi para aplicar todas tus configuraciones, atajos y perfiles:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply yordycg
```

Si todo finaliza correctamente, cierra sesión y cámbiate de "Plasma" a **"Hyprland"** en el selector de la esquina de tu pantalla de inicio de sesión de SDDM.

> [!TIP]
> **Troubleshooting: ¿Entraste a KDE y no tienes terminal (Konsole) instalada?**
> 1. Presiona la combinación física de teclas: **`Ctrl + Alt + Fn + F3`** para abrir la consola de texto TTY.
> 2. Inicia sesión con tu usuario y contraseña.
> 3. Instálalas manualmente corriendo: `sudo pacman -S konsole dolphin`.
> 4. Vuelve al entorno gráfico presionando **`Ctrl + Alt + Fn + F1`** (o `F2`).
