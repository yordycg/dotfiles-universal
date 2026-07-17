# Resolución de Problemas e Instalación de Emergencia

En esta guía se documentan los procedimientos de emergencia más comunes para reparar el cargador de arranque (GRUB), reconfigurar el orden de arranque de la UEFI, acceder al sistema mediante chroot desde el Live USB, y resolver problemas de detección de sistemas operativos.

---

## 🛠️ Acceder al sistema instalado (Chroot de Emergencia)

Si tu sistema no arranca, puedes acceder a él usando el Live USB oficial de Arch Linux para reparar la configuración.

1. **Arranca con el Live USB de Arch.**
2. **Identificar la partición raíz y la partición EFI:**
   ```bash
   lsblk -f
   ```
3. **Montar la estructura Btrfs (asumiendo que tu raíz es `/dev/nvme0n1p6` y la EFI es `/dev/nvme0n1p1`):**
   ```bash
   # Opciones de montaje estándar para SSD
   OPTS="noatime,compress=zstd:3,ssd,discard=async,space_cache=v2"

   # Montar el subvolumen raíz @ en /mnt
   mount -o subvol=@,$OPTS /dev/nvme0n1p6 /mnt

   # Montar el resto de subvolúmenes necesarios
   mount -o subvol=@home,$OPTS /dev/nvme0n1p6 /mnt/home
   mount -o subvol=@var_log,$OPTS /dev/nvme0n1p6 /mnt/var/log
   
   # Montar la partición EFI (ESP)
   mount /dev/nvme0n1p1 /mnt/boot
   ```
4. **Acceder al entorno Chroot:**
   ```bash
   arch-chroot /mnt
   ```
   *Una vez dentro de la terminal chroot, estarás ejecutando comandos directamente dentro de tu sistema instalado.*

---

## 🚀 Reparar GRUB o reinstalar el cargador de arranque

Si una actualización del firmware (BIOS) o de Windows sobrescribió o eliminó el cargador de arranque de Arch Linux:

1. **Accede mediante Chroot de Emergencia** (pasos descritos arriba).
2. **Reinstalar GRUB en la partición EFI:**
   ```bash
   grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
   ```
3. **Regenerar el archivo de configuración:**
   ```bash
   grub-mkconfig -o /boot/grub/grub.cfg
   ```
4. **Salir de chroot y reiniciar:**
   ```bash
   exit
   reboot
   ```

---

## ⚙️ Corregir el Orden de Arranque UEFI con `efibootmgr`

A veces, aunque GRUB esté instalado correctamente, la UEFI del equipo prioriza automáticamente a Windows Boot Manager, impidiendo ver el menú de selección.

1. **Desde el Live USB o desde el Chroot, lista las entradas de arranque:**
   ```bash
   efibootmgr -v
   ```
   *Esto devolverá una salida similar a esta:*
   ```text
   BootCurrent: 0001
   BootOrder: 0000,0002
   Boot0000* Windows Boot Manager  HD(1,GPT,...)\EFI\Microsoft\Boot\bootmgfw.efi
   Boot0002* GRUB                  HD(1,GPT,...)\EFI\GRUB\grubx64.efi
   ```
2. **Fuerza a GRUB como primera opción de arranque:**
   Si la entrada de GRUB es `0002` y la de Windows es `0000`, ejecuta:
   ```bash
   efibootmgr -o 0002,0000
   ```
3. **Crear una entrada manual si GRUB desapareció por completo de la NVRAM:**
   Si la entrada "GRUB" no aparece listada en absoluto en la salida anterior, puedes volver a registrarla manualmente:
   ```bash
   efibootmgr --create --disk /dev/nvme0n1 --part 1 --loader '\EFI\GRUB\grubx64.efi' --label "GRUB"
   ```
   *(Asegúrate de ajustar `--disk` y `--part` a los valores de tu partición EFI).*

---

## 🔍 `os-prober` no detecta a Windows

Si al ejecutar `grub-mkconfig` no aparece la línea que indica que se encontró Windows Boot Manager, verifica lo siguiente:

1. **Verificar el montaje de la partición de Windows:**
   `os-prober` no puede leer particiones NTFS si Windows se encuentra en hibernación o si el disco está bloqueado.
   * Ejecuta `powercfg /h off` en Windows (Fase 1 de la guía Dual-Boot) antes de intentar detectarlo.
2. **Montar manualmente la partición de Windows temporalmente:**
   A veces, `os-prober` requiere que la partición esté montada para analizarla.
   ```bash
   # Crear un directorio temporal e intentar montar la partición NTFS de Windows
   mkdir -p /mnt/win_temp
   mount -t ntfs-3g -o ro /dev/nvme0n1pX /mnt/win_temp  # Reemplaza X por el número de tu partición Windows
   
   # Reejecutar el script de grub
   grub-mkconfig -o /boot/grub/grub.cfg
   
   # Una vez detectado, desmonta la partición temporal
   umount /mnt/win_temp
   rmdir /mnt/win_temp
   ```
3. **Permisos de ejecución en los scripts de GRUB:**
   Asegúrate de que el script encargado de lanzar `os-prober` tenga permisos correctos:
   ```bash
   chmod +x /etc/grub.d/30_os-prober
   ```

---

## 🔑 Errores de Keyring (Firmas de pacman desactualizadas)

Si estás instalando desde una ISO antigua de Arch Linux, es común que al ejecutar `pacman -Sy` o `archinstall` se produzcan fallos en las llaves GPG de los paquetes.

**Solución:** Actualiza el llavero de firmas antes de proceder con cualquier instalación de paquetes:
```bash
pacman -Sy archlinux-keyring --noconfirm
```
Esto descargará las claves públicas más recientes y resolverá los errores de verificación de firmas.
