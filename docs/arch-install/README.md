# Guía de Instalación de Arch Linux — Punto de Entrada

Esta es la guía modular de referencia para la instalación de Arch Linux en limpio (Single-Boot) o en coexistencia con otros sistemas operativos (Dual-Boot), adaptada a la infraestructura personal y a la filosofía de **Host Inmaculado (Clean Host)**.

---

## 💡 Aclaración Importante: Arch Linux y KDE Plasma

A diferencia de otras distribuciones como Fedora o Ubuntu, **Arch Linux no proporciona una imagen ISO oficial con entorno de escritorio (KDE, GNOME, etc.) preinstalado**. 
* La ISO oficial de Arch Linux siempre arranca en una **consola de comandos de solo texto**.
* El entorno de escritorio **KDE Plasma 6** y el gestor de sesiones **SDDM** se descargan e instalan desde los repositorios oficiales *durante* el proceso de instalación (ya sea a través del instalador guiado `archinstall` o mediante comandos manuales).

---

## 🛠️ Fase -1: Preparación del Medio de Instalación (Live USB)

### 1. Descarga de la ISO Oficial
1. Visita la página oficial de descargas: [archlinux.org/download](https://archlinux.org/download/).
2. Descarga el archivo `.iso` mediante Torrent o HTTP desde algún mirror cercano.
3. *(Opcional pero recomendado)* Verifica la integridad de la ISO descargada comparando su firma SHA256:
   ```bash
   sha256sum archlinux-YYYY.MM.DD-x86_64.iso
   ```

### 2. Grabación de la ISO con Ventoy (Recomendado)
[Ventoy](https://www.ventoy.net/) es la herramienta ideal de administración multi-ISO. Te permite preparar un USB una sola vez y luego simplemente copiar y pegar archivos `.iso` sin formatear el dispositivo.

1. Descarga e instala Ventoy en tu pendrive (puedes hacerlo desde Windows o desde otra distribución de Linux).
2. Conecta el USB y abre la partición formateada por Ventoy.
3. Copia el archivo `.iso` de Arch Linux directamente al directorio raíz del USB.
4. Si necesitas tener instaladores de Windows, Fedora u otras distros, cópialas también en la misma partición. Ventoy generará un menú de arranque dinámico al iniciar.

> [!TIP]
> **Alternativa tradicional en consola (Linux/macOS):**
> Si prefieres no usar Ventoy y quieres grabar la imagen directamente al dispositivo USB, identifica tu pendrive (`lsblk`) y ejecuta:
> ```bash
> sudo dd bs=4M if=archlinux-YYYY.MM.DD-x86_64.iso of=/dev/sdX status=progress oflag=sync
> ```
> *⚠️ ATENCIÓN: Reemplaza `/dev/sdX` por el dispositivo correcto de tu USB. Apuntar al disco equivocado destruirá tus datos.*

---

## 🖥️ Fase 0: Configuración previa en la BIOS/UEFI

Antes de arrancar desde el USB, entra a la configuración de la BIOS de tu placa base (presionando `F2`, `F12`, `Del` o `Esc` al encender) y realiza los siguientes ajustes:

1. **Modo de Arranque:** Asegúrate de que está configurado en **UEFI Nativo**. Desactiva cualquier opción llamada *CSM (Compatibility Support Module)* o *Legacy Boot*.
2. **SATA Mode (si usas discos SATA/NVMe antiguos):** Asegúrate de que el controlador de almacenamiento está configurado en **AHCI** (no en RAID o RST, ya que Linux podría no detectar los discos).
3. **Secure Boot:** 
   * **Para Single-Boot:** Se recomienda desactivarlo temporalmente para facilitar la instalación inicial.
   * **Para Dual-Boot con Windows:** Es obligatorio revisar si Windows requiere que esté activo. La ISO oficial de Arch soporta arranque con Secure Boot activo en la mayoría de hardware moderno, pero es más fácil instalar con él desactivado y reactivarlo/firmar los cargadores después si es necesario.

---

## 📐 Fase 1: Elige tu Escenario de Instalación

Identifica en cuál de estos escenarios te encuentras y dirígete al documento correspondiente para continuar con la instalación:

| Escenario | Qué tienes | Qué quieres | Documentación |
|---|---|---|---|
| **Single-Boot** | Disco vacío o que deseas formatear por completo | Instalar únicamente **Arch Linux con KDE** en limpio. | 👉 [Instalación Single-Boot](single-boot.md) |
| **Dual-Boot** | Windows ya instalado o disco vacío para ambos | Instalar **Arch Linux y Windows en Dual Boot**, respetando ambos. | 👉 [Instalación Dual-Boot](dual-boot.md) |
| **Reemplazo** | Windows + otra distribución Linux (ej. Fedora, Ubuntu) | Reemplazar la distribución antigua por Arch Linux y conservar Windows. | 👉 [Instalación Dual-Boot](dual-boot.md#apéndice-b-reemplazar-una-distro-existente-por-arch) |

Si durante o después de la instalación experimentas problemas con el arranque (como pantallas en negro, GRUB roto, o problemas de BIOS), consulta la guía de resolución:
* 👉 [Resolución de Problemas e Instalación de Emergencia](troubleshooting.md)
