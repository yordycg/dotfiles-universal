# Guía de Instalación y Aprovisionamiento: Fedora KDE vs. Fedora Sway

Esta guía detalla los pasos para realizar una instalación limpia de **Fedora KDE** o **Fedora Sway** en tu equipo Desktop MSI (Ryzen 5 2400G, GTX 1660 SUPER), integrando el flujo automatizado mediante tus `dotfiles-universales` y Chezmoi.

---

## Fase 0: Preparación en Windows (Antes de Formatear)

Antes de apagar Windows para comenzar la instalación, realiza estas tareas críticas:

1.  **Desactivar Inicio Rápido (Fast Startup):**
    *   *Por qué:* Si no lo haces, Windows bloqueará las particiones NTFS (Respaldo y Estudio) al apagarse, lo que provocará que Linux las monte en modo de solo lectura o falle el automontaje.
    *   *Cómo:* Abre una consola en Windows (CMD o PowerShell) como Administrador y ejecuta:
        ```cmd
        powercfg /h off
        ```
2.  **Respaldar Credenciales y Licencia:** Ejecuta tu script de respaldo unificado para guardar tu clave de Age (`key.txt`), llaves SSH y el archivo de texto con tu licencia RETAIL de Windows en un pendrive externo.

---

## Fase 1: Preparación de Medios e Instalación del SO (Anaconda)

El proceso en el instalador de Fedora es prácticamente idéntico para ambos entornos, solo cambia la imagen ISO que grabas en tu USB.

### 1. Iniciar el instalador
1. Conecta el USB booteable en tu PC de escritorio.
2. Enciende el equipo y presiona repetidamente **F11** para abrir el menú de arranque de la placa MSI.
3. Selecciona la opción UEFI correspondiente a tu memoria USB.

### 2. Particionado Manual del Disco 1 (ADATA 953 GB)
> [!IMPORTANT]
> En la pantalla de selección de discos del instalador Anaconda, marca **únicamente** el disco **ADATA SU650 (953 GB)**. Deja desmarcados los otros tres discos (Crucial BX500 y los dos HDDs) para evitar cualquier pérdida de datos.

Configura el esquema de particiones para el disco ADATA:

| Partición | Tamaño | Tipo de archivos | Punto de montaje | Notas |
| :--- | :--- | :--- | :--- | :--- |
| **ESP** | 600 MB | FAT32 | `/boot/efi` | Partición del sistema EFI |
| **Boot** | 1 GB | ext4 | `/boot` | Archivos de arranque del Kernel |
| **Sistema** | Resto (~951 GB) | **Btrfs** | `/` y `/home` | Se crean automáticamente como subvolúmenes |

*   *Swap:* No crees partición de intercambio. Fedora habilita **zram** automáticamente al iniciar.
*   *Cifrado:* Deja desactivado LUKS ya que es una PC fija de escritorio y evitará demoras en el arranque.

---

## Fase 2: Actualización Inicial y Preparación de Credenciales (Primer Inicio)

Una vez completada la instalación básica y tras iniciar sesión en el nuevo escritorio por primera vez:

### 1. Abrir la terminal
*   **En Fedora KDE:** Abre **Konsole** (es temporal, el script la eliminará más tarde).
*   **En Fedora Sway:** Presiona `$mod + Enter` (normalmente `Super + Enter`) para abrir la terminal por defecto (`foot` o `kitty`).

### 2. Actualizar el Sistema Completamente (Crítico)
Antes de configurar cualquier herramienta o driver, realiza una actualización completa de todos los paquetes y del Kernel de Fedora. Esto evita que los drivers de NVIDIA se compilen para un kernel obsoleto que será reemplazado inmediatamente:
```bash
sudo dnf upgrade --refresh -y
```
**Una vez terminada la actualización, REINICIA el equipo (`reboot`)** para arrancar en el kernel actualizado antes de continuar.

### 3. Restaurar Credenciales y Llaves de Respaldo desde el USB
Conecta tu pendrive USB con los respaldos y restaura tus llaves SSH y la clave de Age necesarias para que Chezmoi pueda autenticar y descifrar los archivos secretos:
```bash
# Crear directorios con permisos correctos
mkdir -p -m 700 ~/.ssh
mkdir -p -m 700 ~/.config/age

# Copiar llaves SSH (reemplaza /run/media/$USER/*/ con la ruta real de tu pendrive)
cp /run/media/$USER/*/id_ed25519* ~/.ssh/
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Copiar la clave de cifrado Age (key.txt)
cp /run/media/$USER/*/key.txt ~/.config/age/key.txt
chmod 600 ~/.config/age/key.txt
```

---

## Fase 3: Inicialización y Aprovisionamiento Automático (Chezmoi)

### 1. Instalar Chezmoi mediante Curl
Instala la última versión de Chezmoi en tu carpeta local de binarios (`~/.local/bin`), evitando paquetes obsoletos de `dnf`:
```bash
# Crear directorio de binarios de usuario si no existe
mkdir -p ~/.local/bin

# Descargar chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
```

### 2. Clonar y aplicar tus dotfiles
Ejecuta la inicialización de Chezmoi apuntando a tu repositorio correcto (`dotfiles-universal.git`):
```bash
~/.local/bin/chezmoi init --apply https://github.com/yordycg/dotfiles-universal.git
```

### 3. Responder al Asistente de Chezmoi
Durante la inicialización, la plantilla `.chezmoi.yaml.tmpl` te preguntará de forma interactiva qué tipo de entorno deseas configurar:
```text
Entorno de escritorio (kde, sway, both, gnome, none) [sway]:
```
*   **Si instalaste Fedora KDE:** Escribe `kde`.
*   **Si instalaste Fedora Sway:** Escribe `sway`.
*   **Si quieres tener ambos a la vez:** Escribe `both`.

### 4. Aprovisionamiento Automático (Sudo-Space)
Chezmoi solicitará tu contraseña de administrador (`sudo`) para lanzar los instaladores automáticos:
*   Habilita RPM Fusion, repositorios de Chrome y códecs multimedia.
*   Instala la última versión de **Mise** de forma automática vía script (`curl https://mise.run | sh`) para evitar la versión obsoleta del empaquetado nativo.
*   Instala herramientas de sistema y desarrollo (`snapper`, `podman`, `kitty`, etc.).
*   Instala aplicaciones Flatpak de usuario (incluyendo Bruno, DBeaver, Discord, ZapZap, etc.).
*   Descarga el driver propietario de NVIDIA (`akmod-nvidia`).

### 5. Esperar la Compilación de NVIDIA (Crítico)
**¡NO REINICIES EL EQUIPO INMEDIATAMENTE!** Cuando finaliza la ejecución de Chezmoi, el instalador de NVIDIA se ejecuta en segundo plano mediante `akmods`. Si reinicias antes de que termine, arrancarás en pantalla negra.
Puedes comprobar si el driver terminó de compilarse ejecutando:
```bash
# Si el comando no devuelve ningún proceso ejecutándose, significa que ha terminado
pgrep -a akmods
```
Espera unos 3 a 5 minutos a que finalice la compilación.

### 6. Reinicio e inscripción de firma MOK
Una vez terminada la compilación de los drivers NVIDIA, reinicia el equipo:
```bash
reboot
```
Si Secure Boot está habilitado en tu BIOS, al reiniciar verás una pantalla azul de **MOKManager**:
1. Selecciona **Enroll MOK**.
2. Elige **View key** o **Continue**.
3. Selecciona **Yes**.
4. Escribe la contraseña que te pida (la que definiste al aprovisionar o tu password de root).
5. Selecciona **Reboot**.

### 7. Resolución de Problemas: Pantalla Negra o Firma MOK Fallida
Si el sistema inicia en pantalla negra o no aparece la pantalla azul de MOKManager tras reiniciar:
1. **Entrar al escritorio de emergencia:**
   - En el GRUB, presiona **`e`**.
   - Busca la línea que inicia con `linux` y añade `nomodeset` al final de la línea.
   - Presiona **`Ctrl + X`** para arrancar en modo gráfico básico.
2. **Generar y firmar MOK manualmente:**
   - Si no existían las llaves de firma de akmods en `/etc/pki/akmods/certs/`, créalas:
     ```bash
     sudo kmodgenca --force
     ```
   - Importa la llave pública a la BIOS (usa la ruta del enlace simbólico creado, usualmente `public_key.der` o `akmods.der`):
     ```bash
     sudo mokutil --import /etc/pki/akmods/certs/public_key.der
     ```
     *(Define una contraseña temporal que deberás escribir en el reinicio).*
   - Reconstruye y firma los módulos del driver de NVIDIA:
     ```bash
     sudo akmods --force --rebuild
     ```
   - Reinicia con `reboot` y completa el registro en la pantalla azul del **MOKManager**.

---

## Fase 4: Post-Aprovisionamiento (Puntos manuales y Discos)

### 2. Configurar el montaje de discos NTFS
Una vez dentro del escritorio con los drivers NVIDIA cargados, abre una terminal (`kitty`) y ejecuta tu script interactivo personalizado:
```bash
setup-data-mounts.sh
```
El script buscará los UUIDs de tu disco de Respaldo (`WD10EZEX`) y Estudio (`HDWD110`), creará los directorios en `/mnt/`, configurará el driver nativo `ntfs3` de alta velocidad con permisos de lectura/escritura para tu usuario y los agregará con seguridad (`nofail`) en `/etc/fstab`.

### 3. Formatear y montar el SSD de la Máquina Virtual (Crucial BX500)
Para habilitar el almacenamiento dedicado a Windows 11:
```bash
setup-vm-storage.sh
```
1. El script buscará tu SSD BX500 de 240 GB.
2. Escribe `CONFIRMAR` cuando te lo solicite.
3. El script formateará el disco a `ext4`, lo montará en `/var/lib/libvirt/images` y lo dejará configurado permanentemente en `/etc/fstab`.

### 4. Iniciar la VM de Windows 11 en virt-manager
1. Abre **Virtual Machine Manager** (`virt-manager`).
2. Crea una nueva máquina virtual seleccionando la ISO de Windows 11 (que estará accesible desde tu disco NTFS montado en `/mnt/Respaldo/ISOs/`).
3. Asigna recursos (ej. 6 GB de RAM, 4 vCPUs).
4. Elige crear un disco de almacenamiento personalizado en `/var/lib/libvirt/images/win11.qcow2`.
5. Antes de iniciar la instalación, marca la casilla **"Personalizar configuración antes de instalar"**.
6. Agrega un segundo CD-ROM virtual de tipo SATA y apúntalo a la ISO de controladores de Windows VirtIO: `/usr/share/virtio-win/virtio-win.iso`.
7. Instala Windows 11, cargando los controladores de red y disco VirtIO cuando te lo solicite el asistente, e instala las herramientas **SPICE Guest Tools** para el portapapeles compartido y resolución automática.

---

## Resumen de Diferencias: KDE vs. Sway

| Característica | Fedora KDE Spin | Fedora Sway Spin |
| :--- | :--- | :--- |
| **Consumo Inicial** | Medio (~1.2 - 1.5 GB RAM en reposo) | Muy bajo (~600 - 800 MB RAM en reposo) |
| **Limpieza Post-Instalación** | Requiere script `cleanup-kde.sh` para quitar suites de correo pesadas (Akonadi) y reproductores redundantes. | No requiere limpieza; es un entorno minimalista por defecto. |
| **Comportamiento Visual** | Flujo de ventanas tradicional (flotantes), efectos visuales ricos, personalización mediante menús de Kvantum y KDE Store. | Mosaico dinámico (tiling window manager). Las ventanas se acomodan automáticamente sin solaparse. Atajos de teclado en lugar de ratón. |
| **Temas y Estilo** | Gestionado a través del script de Chezmoi `setup-kde-theme.sh` y temas GTK/Qt integrados. | Configurado a mano mediante archivos de configuración de Sway (`~/.config/sway/config`), Waybar y Waypaper. |

---

## Estrategia de Dual-Boot Futuro (Plan de Contingencia)

Si en el futuro requieres ejecutar Windows de forma nativa en lugar de una máquina virtual (por ejemplo, para exprimir el 100% del rendimiento físico de la GPU en AutoCAD o software pesado), la estrategia establecida es la **Opción B (Discos físicos separados)**:

*   **Configuración Inicial:** El SSD ADATA (953 GB) se mantiene al 100% para Fedora KDE, y el SSD Crucial BX500 (240 GB) se monta en `/var/lib/libvirt/images` para el disco virtual `.qcow2` de la VM.
*   **Proceso de Transición a Dual-Boot Nativo:**
    1. Respalda tus archivos y licencias de la VM de Windows.
    2. Arranca el PC con el USB instalador de Windows 10/11 (F11 en placa MSI).
    3. Selecciona y formatea únicamente el **SSD Crucial BX500 (240 GB)** para instalar Windows de forma nativa.
*   **Ventajas de este enfoque:**
    *   **Seguridad:** Cada disco tiene su propia partición de arranque (EFI) independiente. Windows no alterará el arranque (GRUB) del SSD de Fedora.
    *   **Sencillez de Arranque:** El PC arrancará en Fedora por defecto. Para iniciar Windows nativo, solo pulsas **F11** al encender y seleccionas el disco Crucial.
    *   **Sin tocar Fedora:** No hay necesidad de redimensionar particiones Btrfs ni arriesgar los datos de tu SSD de desarrollo principal.

