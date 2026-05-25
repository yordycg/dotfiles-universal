# Flujo de Ejecución Zero-Touch: dotfiles-universal (Chezmoi)

Este documento detalla el proceso interno, línea por línea y script por script, desde que se inicializa Chezmoi hasta que el sistema queda completamente configurado (Zero-Touch).

## 🛑 Requisitos Previos (Pre-condiciones del Cliente)

Para que el comando `chezmoi init --apply` se ejecute sin requerir intervención humana, el nodo cliente debe tener:

1.  **Sistema Base:** Linux (Probado en Fedora y Debian).
2.  **Paquetes:** `git` y `curl`.
3.  **Variables de Entorno (¡Crítico para Zero-Touch!):**
    *   `CHEZMOI_AGE_KEY`: Debe contener la llave privada de Age para descifrar secretos (como tokens de API y contraseñas de Bitwarden).
    *   `GITHUB_TOKEN`: Un PAT de GitHub con permisos de `admin:public_key` para la autenticación automática de la CLI (`gh`).

**Comando de lanzamiento ideal:**
```bash
CHEZMOI_AGE_KEY="AGE-SECRET-KEY-1..." GITHUB_TOKEN="ghp_..." sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply yordycg
```

## 🔄 Flujo de Ejecución (Paso a Paso)

### Fase 0: Inicialización y Configuración Base
1.  **Clonación:** Chezmoi descarga el repositorio `dotfiles-universal`.
2.  **Plantilla (`.chezmoi.yaml.tmpl`):**
    *   Valida si existe `GITHUB_TOKEN` en el entorno; si no, lo pide interactivamente (rompiendo el Zero-Touch).
    *   Verifica si la llave privada de Age existe en el disco (`~/.config/chezmoi/key.txt`). *Nota: En este punto, si no existe y dependemos del script `00`, Chezmoi podría fallar al descifrar `private_secrets.yaml.age`. (Esto es un caso borde manejado por inyección manual o el script before).*
    *   Descifra `dot_config/homelab/private_secrets.yaml.age` usando Age para obtener el `forgejoToken`.
    *   Evalúa el tipo de nodo (Server, Laptop, Desktop, WSL).
    *   Genera `~/.config/chezmoi/chezmoi.yaml`.

### Fase 1: Pre-Ejecución (`before_`)
*   **`run_before_00-install-packages.sh.tmpl`:**
    *   **Caché:** Calcula un hash de `packages.yaml` y los scripts de instalación. Si no hay cambios, omite este paso rápido.
    *   **Secretos:** Verifica si existe `$CHEZMOI_AGE_KEY`. Si existe, inyecta la llave privada en `~/.config/chezmoi/key.txt`.
    *   **Instalación:** Ejecuta `fedora.sh` o `debian.sh` (leyendo `packages.yaml` vía `yq` o `python`) para instalar dependencias pesadas (`git`, `curl`, build-tools, etc.).

### Fase 2: Aplicación del Estado (Archivos)
*   Chezmoi procesa y copia todos los archivos regulares y plantillas (`dot_zshrc.tmpl`, `dot_gitconfig.tmpl`, `dot_private_dot_ssh/config.tmpl`) al directorio `~/`.
*   Aplica la configuración de SSH que incluye el bloque para `forgejo.home` con el puerto `2222`.

### Fase 3: Post-Ejecución (`after_`)
Estos scripts garantizan que las herramientas instaladas se configuren correctamente. Se ejecutan en orden numérico.

1.  **`run_after_10-install-fonts.sh.tmpl`:**
    *   Instala fuentes tipográficas (JetBrains, FiraCode) para la terminal. Usa sistema de caché para no repetir.
2.  **`run_after_20-install-mise.sh.tmpl`:**
    *   Instala `mise` (gestor de entornos).
    *   Instala `node`, `python` y herramientas CLI globales definidas en el repositorio.
3.  **`run_after_50-setup-backup.sh.tmpl` (Solo Servidor):**
    *   Configura servicios de systemd para ejecutar backups con Restic automáticamente.
4.  **`run_after_80-sync-assets.sh.tmpl` (Solo Clientes):**
    *   Intenta clonar `wallpapers` y `obsidian-notes` desde `forgejo.home` (conexión local rápida). Si Forgejo no es alcanzable, usa GitHub como fallback.
5.  **`run_after_90-setup-ssh.sh.tmpl`:**
    *   Verifica instalación de `gh`.
    *   Autentica `gh` usando el `$GITHUB_TOKEN` de la configuración.
    *   Genera llave SSH `id_ed25519` si no existe.
    *   Usa `gh` para subir la llave pública a GitHub.
    *   **Integración Homelab:** Usa el `$FORGEJO_TOKEN` (descifrado de Age) y la API REST de Forgejo local para registrar la misma llave pública en el servidor homelab, permitiendo clonar repositorios de inmediato.
6.  **`run_after_92-setup-tailscale.sh.tmpl` (Solo Linux):**
    *   Activa el servicio `tailscaled`.
    *   ⚠️ **Límite Zero-Touch:** Si no está autenticado, ejecuta `sudo tailscale up`. Esto detendrá el proceso pidiendo al usuario que abra un enlace en su navegador para unirse a la VPN Mesh.
7.  **`run_after_95-trust-homelab-ca.sh.tmpl`:**
    *   Descarga el certificado raíz (`root.crt`) de `vault.home` (o lo copia directamente si es el servidor).
    *   Lo inyecta en el almacén de confianza del sistema (`/etc/pki/ca-trust` o `/usr/local/share/ca-certificates`) para que no haya advertencias SSL en servicios internos.
8.  **`run_after_99-change-shell.sh.tmpl`:**
    *   Cambia la terminal por defecto a ZSH de manera no interactiva usando `chsh`.

## 🚀 Logrando el "Zero-Touch" Absoluto

Actualmente, el despliegue es ~95% Zero-Touch. Para llegar al 100%, se deben resolver los siguientes puntos interactivos:

1.  **Contraseña de Sudo:** Scripts como paquetes, CA trust, shell change y tailscale requieren permisos elevados. Chezmoi los pide durante la ejecución (o asume un NOPASSWD configurado previamente en el host).
2.  **Autenticación Tailscale (`run_after_92`):** Cambiar el script para que acepte una Auth Key de Tailscale por variable de entorno: `sudo tailscale up --authkey=$TAILSCALE_AUTH_KEY`.
3.  **Bootstrapping Inicial de Chezmoi:** El cifrado de `.chezmoi.yaml.tmpl` falla en el *primer* `chezmoi init` de un equipo virgen si la llave `key.txt` de Age no está previamente creada en el disco antes de procesar el YAML. El workaround es inyectarla vía Bash *antes* del init, no en el script `before_`.
