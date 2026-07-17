# Guía Completa de Instalación Arch Linux & Dual Boot (Senior SRE Edition) — 2026

> Guía definitiva paso a paso. Cubre: instalación base con Btrfs+Snapper, dual boot con Windows en sus 3 escenarios posibles, migración desde otra distro, eliminación de Windows manteniendo Linux, y recuperación de emergencia.

---

## ⚠️ Regla de oro (léela antes de todo)

Antes de cualquier comando destructivo (`mkfs`, `wipefs`, `parted rm`), verifica siempre qué dispositivo es cuál:

```bash
lsblk -f
```

Confirma por **tamaño** y **label**, nunca asumas que `/dev/nvme0n1pX` es "tu" partición sin mirarlo. Este es el error más caro y más común de toda instalación dual boot.

---

## 📋 Fase 0: Elige tu escenario

Antes de tocar nada, identifica en cuál de estos 3 casos estás — el resto de la guía te remite al apéndice correspondiente cuando aplique.

| Escenario | Qué tienes | Qué quieres | Ir a |
|---|---|---|---|
| **A** | Disco vacío, nada instalado | Windows + Arch dual boot | Fases 1→6 en orden, **Windows primero** |
| **B** | Windows + otra distro Linux ya instalados | Reemplazar la distro por Arch, conservar Windows | Fases 1→6 + [Apéndice B](#apéndice-b-reemplazar-una-distro-existente-por-arch) |
| **C** | Windows + Arch (o cualquier Linux) ya instalados | Eliminar Windows, quedarte solo con Linux | [Apéndice C](#apéndice-c-eliminar-windows-y-quedarte-solo-con-linux) directamente |

### ¿Por qué Windows siempre debe ir antes que Arch en una instalación nueva?

El instalador de Windows no tiene equivalente a `os-prober`: no detecta Linux, no lo respeta, y se pone a sí mismo como entrada de arranque por defecto en el NVRAM UEFI. `os-prober` de Arch **sí** detecta Windows automáticamente. Si instalas en el orden correcto (Windows → Arch), todo se resuelve en un solo `grub-mkconfig`. Si lo haces al revés, terminas arrancando directo a Windows sin menú y hay que reparar el orden de arranque manualmente (ver [Apéndice A](#apéndice-a-arreglar-el-orden-si-instalaste-arch-antes-que-windows-por-error)).

---

## 🛠️ Fase 1: Preparativos en el Host

### Opción A — El host es Windows

1. **Desactivar BitLocker:**
   ```powershell
   manage-bde -off C:
   manage-bde -status C:   # repite hasta ver "Percentage Encrypted: 0%"
   ```
   *Edge case*: el descifrado es progresivo. Si reinicias antes de que llegue a 0%, Linux seguirá sin poder leer la partición correctamente.

2. **Desactivar Fast Startup / hibernación** (más confiable por CLI que por GUI):
   ```powershell
   powercfg /h off
   ```
   *Edge case*: esto elimina hibernación por completo, no solo el "inicio rápido". Si dependes de hibernación real, usa el toggle de GUI en vez de este comando.

3. **Liberar espacio:**
   ```powershell
   Get-Volume
   Get-Partition -DriveLetter C | Get-Disk
   Resize-Partition -DriveLetter C -Size (Get-PartitionSupportedSize -DriveLetter C).SizeMin
   ```
   *Edge case*: si te ofrece mucho menos espacio del esperado, hay archivos inamovibles (hibernación, restauración del sistema, paginación) bloqueando la reducción. Corre `defrag C: /U /V` y asegúrate de haber hecho el paso 2 primero.

4. **Secure Boot:** entra a BIOS/UEFI y desactívalo o ponlo en modo "Other OS"/"Setup Mode".
   *Edge case*: si tu firmware no permite desactivarlo, puedes instalar GRUB firmado con `sbctl` más adelante en vez de desactivarlo (opcional, más avanzado).

### Opción B — El host es otra distro Linux

1. No aplica BitLocker ni Fast Startup. El único cuidado es no tocar por accidente la ESP existente ni el bootloader de la otra distro — se gestiona en la Fase 2 y el [Apéndice B](#apéndice-b-reemplazar-una-distro-existente-por-arch).

2. **Verificar espacio y tabla de particiones:**
   ```bash
   sudo parted -l
   sudo lsblk -f
   ```

3. **Reducir el filesystem existente** (ejemplo ext4, hazlo desde un Live USB, nunca sobre la partición raíz montada activa):
   ```bash
   sudo e2fsck -f /dev/sdXn
   sudo resize2fs /dev/sdXn <nuevo_tamaño>G
   sudo parted /dev/sdX resizepart <N> <nuevo_final>
   ```
   *Edge case*: si es Btrfs en vez de ext4, la sintaxis cambia: `btrfs filesystem resize` en vez de `resize2fs`.

4. **Verificar Secure Boot** (útil en ambas opciones):
   ```bash
   mokutil --sb-state
   ```

---

## 📐 Fase 2: Particionado Avanzado Btrfs (Live USB de Arch)

### 2.0 Preparativos del entorno Live

```bash
loadkeys es                          # si tu teclado no es US
ping -c 3 archlinux.org              # verificar conexión a internet

# Si no hay ethernet:
iwctl
[iwd]# device list
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
[iwd]# station wlan0 connect "TU_SSID"
[iwd]# exit

timedatectl set-ntp true             # necesario para validar certificados HTTPS de los mirrors
```

### 2.1 Comprobar modo UEFI

```bash
ls /sys/firmware/efi/efivars
```

*Edge case*: si el directorio no existe → estás en modo Legacy/CSM. Reinicia, entra a BIOS y desactiva "CSM"/"Legacy Boot Support". Sin UEFI puro, `grub-install --target=x86_64-efi` fallará más adelante.

### 2.2 Identificar y crear la partición

```bash
lsblk -f                     # confirma cuál disco es cuál ANTES de tocar nada
cfdisk /dev/nvme0n1          # crea la partición nueva en el espacio libre, tipo "Linux filesystem"
```

Dentro de `cfdisk`: selecciona el espacio libre → New → confirma tamaño → **Write** (escribe `yes`) → **Quit**.

*Edge case*: si la partición tuvo datos de un intento previo, límpiala antes de formatear:
```bash
wipefs -a /dev/nvme0n1p6
```

### 2.3 Formatear y crear subvolúmenes

```bash
mkfs.btrfs -L arch_root /dev/nvme0n1p6
mount /dev/nvme0n1p6 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@swap

umount /mnt
```

*Edge case*: si `btrfs subvolume create` falla, verifica que `/mnt` esté realmente montado con `findmnt /mnt`.

### 2.4 Montar los subvolúmenes con opciones SSD

```bash
OPTS="noatime,compress=zstd:3,ssd,discard=async,space_cache=v2"

mount -o subvol=@,$OPTS /dev/nvme0n1p6 /mnt

mkdir -p /mnt/{home,.snapshots,var/log,boot,swap}

mount -o subvol=@home,$OPTS /dev/nvme0n1p6 /mnt/home
mount -o subvol=@snapshots,$OPTS /dev/nvme0n1p6 /mnt/.snapshots
mount -o subvol=@var_log,$OPTS /dev/nvme0n1p6 /mnt/var/log
mount -o subvol=@swap /dev/nvme0n1p6 /mnt/swap

# ESP existente de Windows, o la que creaste en 2.2 si vas dedicada
mount /dev/nvme0n1p1 /mnt/boot
```

> Nota: el `subvol=` requiere el **nombre del subvolumen** (`@`), nunca la variable de opciones directamente — es un error común confundir `subvol=$OPTS` con `subvol=@,$OPTS`.

*Edge case*: si compartes la ESP de Windows y es menor a 260MB, puede quedarse corta con varios kernels de Arch instalados (linux + linux-zen + fallback). Si `pacman` se queja de espacio en `/boot`, crea una ESP secundaria dedicada de 512MB-1GB en vez de compartir.

### 2.5 Swap con zram o swapfile Btrfs

Con Btrfs, un swapfile normal falla porque el filesystem usa copy-on-write. Dos opciones:

**Opción recomendada — zram (swap comprimido en RAM, sin tocar disco):** se instala como paquete en Fase 3 (`zram-generator`), no requiere nada aquí.

**Opción swapfile en disco:**
```bash
chattr +C /mnt/swap                     # desactiva CoW, obligatorio
truncate -s 0 /mnt/swap/swapfile
fallocate -l 8G /mnt/swap/swapfile      # ajusta a tu RAM
chmod 600 /mnt/swap/swapfile
mkswap /mnt/swap/swapfile
```

---

## 🚀 Fase 3: Instalación con `archinstall`

```bash
pacman -Sy archlinux-keyring --noconfirm   # evita fallos de keyring si el ISO es viejo
archinstall
```

* **Disk Configuration** → "Use a pre-mounted configuration" → `/mnt`.
* **Bootloader**: GRUB (algunas builds recientes ya traen toggle de os-prober integrado aquí mismo — si lo ves, actívalo).
* **Profile**: `Desktop` → `KDE` (Plasma 6).
* **Display Manager**: `SDDM`.
* **Audio**: `Pipewire`.
* **Network Configuration**: `NetworkManager`.
* **Kernel**: `linux` o `linux-zen`.
* **Graphics Driver**: según hardware.
* **Additional Packages**: `git`, `neovim`, `sudo`, `zram-generator` (si usaste esa opción de swap).
* **Create User**: tu usuario + "Sudo privileges".

Al terminar, `archinstall` pregunta si quieres entrar en chroot antes de reiniciar. **Sí.**

---

## 🖥️ Fase 4: Dual Boot (GRUB)

```bash
pacman -S --noconfirm grub efibootmgr os-prober ntfs-3g
```

`ntfs-3g` es obligatorio: `os-prober` necesita leer el NTFS de Windows para encontrar `bootmgfw.efi`.

```bash
nano /etc/default/grub
```
Descomenta/agrega:
```ini
GRUB_DISABLE_OS_PROBER=false
```

```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

Verifica en la salida que aparezca "Found Windows Boot Manager".

*Edge case #1 — no lo encuentra:*
```bash
chmod +x /etc/grub.d/30_os-prober   # a veces pierde el permiso de ejecución
os-prober                            # pruébalo solo, sin grub-mkconfig, para aislar el problema
```
Si `os-prober` no devuelve nada, la partición de Windows no es visible desde el chroot — móntala manualmente en una ruta temporal y repite.

*Edge case #2 — Secure Boot activo:* `grub-install` instalará el binario pero el firmware se negará a arrancarlo. Firma con `sbctl` o desactívalo como en Fase 1.

```bash
exit
reboot
```

---

## ⏰ Fase 5: RTC (Reloj)

```bash
timedatectl set-local-rtc 1 --adjust-system-clock
```

**Alternativa (más "correcta" para un contexto SRE):** deja Linux en UTC (el estándar) y ajusta Windows para que también use UTC, vía registro en PowerShell/cmd como admin:
```powershell
reg add "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_DWORD /d 1 /f
```

---

## 🚀 Fase 6: Dotfiles (Chezmoi)

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply yordycg
```

Esto asume un repo llamado literalmente `dotfiles` (`github.com/yordycg/dotfiles`).

**Si tu repo tiene otro nombre:**
```bash
# Opción 1: usuario/repo explícito
chezmoi init --apply yordycg/mi-repo-custom

# Opción 2: URL completa (obligatorio si no es GitHub, ej. GitLab propio, Codeberg)
chezmoi init --apply https://gitlab.com/yordycg/mi-repo-custom.git
```

*Edge case*: si el repo es privado, `init` puede fallar silenciosamente por autenticación. Usa la variante SSH:
```bash
chezmoi init --apply git@github.com:yordycg/mi-repo-custom.git
```

---

## Apéndice A: Arreglar el orden si instalaste Arch antes que Windows por error

Si terminaste arrancando directo a Windows sin menú de GRUB:

```bash
# Desde un Live USB de Arch:
arch-chroot /mnt
grub-mkconfig -o /boot/grub/grub.cfg     # ahora detecta Windows, que ya existe
efibootmgr -v                             # anota el bootnum de GRUB, ej: Boot0002
efibootmgr -o 0002,0000                   # fuerza a GRUB primero en el orden de arranque
exit
reboot
```

---

## Apéndice B: Reemplazar una distro existente por Arch

Tienes Windows + otra distro (Ubuntu, Fedora, etc.) y quieres reemplazar solo la distro, conservando Windows intacto.

1. **Identifica qué es qué — nunca toques la partición de Windows ni asumas cuál es la ESP:**
   ```bash
   lsblk -f
   efibootmgr -v          # anota el bootnum de la entrada de la distro vieja
   ```

2. **Borra solo la(s) partición(es) raíz de la distro vieja** (no la ESP, no Windows):
   ```bash
   wipefs -a /dev/nvme0n1pX
   ```

3. Continúa con la Fase 2 normal, reutilizando la ESP compartida montándola en `/mnt/boot`.

4. **Después de instalar Arch, limpia la entrada NVRAM vieja:**
   ```bash
   efibootmgr -b <bootnum_viejo> -B
   ```

*Edge case*: si la distro vieja usaba `systemd-boot` en vez de GRUB, la ESP tiene carpeta `/loader/entries/` en vez de `/EFI/<distro>/`. No estorba — GRUB crea su propia carpeta `/EFI/GRUB/` — pero si quieres limpieza total, monta la ESP y borra los archivos sobrantes de la distro anterior a mano.

---

## Apéndice C: Eliminar Windows y quedarte solo con Linux

Windows normalmente ocupa **3 particiones**, no una: la NTFS grande (C:), una "Microsoft Reserved (MSR)" y a veces una "Windows Recovery Environment". Hay que identificar y borrar las tres para limpieza total.

```bash
sudo parted /dev/nvme0n1 print          # identifica los números de partición de Windows
sudo parted /dev/nvme0n1 rm <num_C>
sudo parted /dev/nvme0n1 rm <num_MSR>
sudo parted /dev/nvme0n1 rm <num_recovery>

efibootmgr -v
efibootmgr -b <bootnum_windows> -B      # limpia la entrada NVRAM de Windows

grub-mkconfig -o /boot/grub/grub.cfg    # Windows ya no existe, desaparece del menú solo
```

**Expandir tu partición Linux hacia el espacio liberado:**
```bash
sudo parted /dev/nvme0n1 resizepart <num_arch> 100%
sudo btrfs filesystem resize max /       # resize en caliente, sin desmontar
```

*Edge case crítico*: solo puedes expandir si el espacio liberado queda **físicamente contiguo** a tu partición de Arch. Si Windows estaba *antes* de Arch en el disco (LBA menor), el espacio libre queda "detrás" de tu partición y un resize simple no lo alcanza — tocaría mover la partición completa con una herramienta tipo GParted "move" (riesgo alto, backup antes). Si Windows estaba *después*, el resize de arriba funciona directo.

---

## Apéndice D: Recuperación de emergencia — GRUB roto

Si tras cualquiera de los escenarios anteriores el sistema no arranca:

```bash
# Boot desde Live USB de Arch
lsblk -f                                  # identifica tu partición raíz y tu ESP
mount -o subvol=@ /dev/nvme0n1p6 /mnt
mount -o subvol=@home /dev/nvme0n1p6 /mnt/home
mount /dev/nvme0n1p1 /mnt/boot

arch-chroot /mnt

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg

efibootmgr -v                             # confirma que la entrada GRUB existe y está primera
exit
reboot
```

*Edge case*: si `efibootmgr` no muestra ninguna entrada de GRUB pese a la instalación exitosa, créala manualmente:
```bash
efibootmgr --create --disk /dev/nvme0n1 --part 1 --loader '\EFI\GRUB\grubx64.efi' --label "GRUB"
```
