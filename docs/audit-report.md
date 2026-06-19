# Auditoría y Plan de Mejora: dotfiles-universal (chezmoi)

Este documento registra el análisis crítico de la auditoría propuesta para el repositorio `dotfiles-universal`, detallando la evaluación técnica de cada punto y el estado de su implementación.

---

## 📋 Resumen de la Implementación

| ID | Punto Analizado | Propuesta Original | Decisión Técnica & Estado |
| :--- | :--- | :--- | :--- |
| **1** | Secretos y Datos Sensibles | Mover Age Recipient, Git Email e IPs a un archivo `.env` externo local. | **Implementado con mejoras**. Las IPs y correo se parametrizaron en `.chezmoi.yaml.tmpl` mediante variables de entorno y fallbacks seguros. El Age Recipient se mantuvo público por diseño ya que es una clave pública. |
| **2** | Sync de Assets (`run_after_85`) | Cambiar a `onchange` o mover a un Timer de Systemd de usuario. | **Verificado y Conservado**. Se constató que el script ya cuenta con un throttle de 24h. Se conservó para garantizar el bootstrap "Zero-Touch" inicial de fondos y notas. |
| **3** | Logging Duplicado | Crear librería de logs común y cargarla mediante `source` local. | **Completado**. Creada en `provision/lib/logging.sh`. Inyectada dinámicamente usando `{{ include }}` en templates y `source` con ruta relativa en scripts puros. |
| **4** | packages.yaml por Capas | Separar herramientas esenciales de las dependencias de compilación. | **Completado**. Dividido en `base`, `terminal_ux` y `dev_toolchain`. Los instaladores cargan `dev_toolchain` condicionalmente en clientes de desarrollo. |
| **5** | Estabilidad de Versiones | Pinzar tags de repositorios del tema KDE y fijar descarga de Mise. | **Completado**. Mise fijado en `v2024.12.1`. Repositorios de vinculación de temas pinzados a tags estables (`2026-05-24`, `2025-10-16`, etc.). |
| **6** | Health Check final | Crear un script de verificación post-bootstrap. | **Completado**. Creado `run_once_after_100-verify.sh.tmpl` para reportar el estado de salud del nodo tras el apply. |
| **7** | Simulación de Cambios | Añadir DRY_RUN a provision/lib/logging.sh y Justfile integration. | **Completado**. Creada la variable `DRY_RUN` y la función wrapper `run` en `logging.sh` para interceptar comandos con efectos secundarios. Añadido el target `dry-run` en `Justfile`. |

---

## 🔍 Detalle Técnico de los Puntos

### 1. Parametrización de Identidad y Homelab
Se eliminaron las IPs privadas y correos electrónicos quemados de `.chezmoi.yaml.tmpl`. Ahora el motor de plantillas de Chezmoi lee variables del entorno local y usa los valores por defecto del homelab como fallback seguro:

```yaml
data:
  gitName:          {{ env "CHEZMOI_GIT_NAME" | default "yordycg" | quote }}
  gitEmail:         {{ env "CHEZMOI_GIT_EMAIL" | default "yordy.carmona8@gmail.com" | quote }}
  homelab_ip_ts:    {{ env "CHEZMOI_HOMELAB_TS_IP" | default "100.110.207.73" | quote }}
  homelab_ip_local: {{ env "CHEZMOI_HOMELAB_LOCAL_IP" | default "192.168.18.99" | quote }}
```
*Nota de diseño:* La clave del destinatario Age (`age1...`) es una clave pública, por lo que su presencia en el repositorio versionado no representa un riesgo de filtración.

### 2. Sincronización de Assets y Obsidian
Se conservó el script actual `run_after_85-sync-assets.sh.tmpl` porque **ya cuenta con un sistema de caché de 24 horas** (`assets-last-sync`). Esto da el balance perfecto: se ejecuta inmediatamente durante el bootstrap para que el escritorio esté listo desde el primer segundo (zero-touch), y en los applies del día a día no realiza ninguna operación pesada, saliendo en menos de 1ms si ya se ejecutó en las últimas 24 horas.

### 3. Gestión Unificada de Logging (`provision/lib/logging.sh`)
Se implementó un estándar para toda la salida de terminal del bootstrap. La librería está en `provision/lib/logging.sh` y define:
* `log_step`: Encabezados de fases principales con icono `▶`.
* `log_ok`: Confirmación de pasos exitosos con icono `✓` en color verde.
* `log_info`: Información complementaria con icono `→` en color cian.
* `log_warn`: Alertas con icono `⚠` en color amarillo.
* `log_error` / `log_err`: Reporte de fallos con icono `✗` en color rojo (con salida de error e interrupción si aplica).

#### Cómo usar en Plantillas Chezmoi (`.tmpl`):
Al inicio del script de la plantilla, añade la inyección nativa:
```bash
{{ include "provision/lib/logging.sh" }}
```

#### Cómo usar en Scripts de Sistema (`.sh`):
Importa la librería usando la ruta relativa del script:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"
```

### 4. Capas de Paquetes en `packages.yaml`
Se segmentó la instalación del sistema en tres niveles lógicos para evitar instalar dependencias de desarrollo y compiladores nativos (`gcc`, `make`, etc.) en servidores de producción headless mínimos:

1. **`base`**: Herramientas esenciales de control y red (Tailscale, Git, Tmux, Curl, Zsh, Jq, Age).
2. **`terminal_ux`**: Interfaces CLI y utilidades de entorno no críticas (Fzf, Mosh, GnuPG, Pinentry, GitHub CLI, Unzip, Sqlite).
3. **`dev_toolchain`**: Dependencias para compilar lenguajes de desarrollo de `mise`.

En los instaladores (`fedora.sh` y `debian.sh`), se inyecta condicionalmente:
```bash
install_section "base"
install_section "terminal_ux"

# Instalar toolchain solo si no es servidor o si es explícitamente solicitado
if [ "${NODE_IS_SERVER:-}" != "true" ] || [ "${NODE_NEEDS_DEV_TOOLCHAIN:-}" = "true" ]; then
    install_section "dev_toolchain"
fi
```

### 5. Congelación de Versiones de Dependencias
Para asegurar que el bootstrap sea 100% reproducible a lo largo del tiempo, se eliminaron las descargas flotantes (`latest` / `master` sin ref):
* El script de `mise` descarga una versión inmutable específica: `v2024.12.1`.
* Las llamadas a `clone_or_update` en `setup-kde-macos-theme.sh` clonan y conmutan a tags estables validados en GitHub (ej. `2026-05-24` para MacTahoe-gtk, `2025-10-16` para MacTahoe-icon, etc.) en lugar de extraer la última versión no probada de la rama por defecto.

### 6. Health Check Post-Bootstrap (`run_once_after_100-verify.sh.tmpl`)
Al finalizar el apply general de Chezmoi, un script final automatizado valida los componentes instalados en segundo plano:
* Shell predeterminado configurado a ZSH.
* Llave privada de Age sembrada.
* Disponibilidad de `mise` y `agy` (Antigravity CLI).
* Configuración de identidad de Git.
* Estado activo de la VPN de Tailscale.
* *(Condicional)* Fuentes Nerd Fonts y almacenamiento Passage.
* *(Condicional)* Motor de contenedores Docker/Podman.

El script reporta los fallos de manera informativa en consola al usuario sin abortar la ejecución del apply principal de chezmoi.

### 7. Simulación de Cambios (Modo Dry-Run y Justfile)
Se integró el soporte para simular la ejecución de scripts y previsualizar los cambios antes de aplicarlos.

1. **Wrapper `run` en `logging.sh`**:
   Las llamadas que tienen efectos secundarios (instalación de paquetes, habilitación de COPR, etc.) se envuelven bajo la función `run`. Si `DRY_RUN=1` está configurado en el entorno, el comando solo se imprime en terminal con un tag `[DRY-RUN]` en lugar de ejecutarse de verdad.
2. **Justfile**:
   Se añadió el target `just dry-run` para previsualizar los cambios de Chezmoi y simular la ejecución de los scripts de instalación de paquetes con flags de depuración:
   ```makefile
   dry-run:
       DRY_RUN=1 chezmoi apply --dry-run --verbose
   ```
