# Flujo de Ejecución Zero-Touch: dotfiles-universal (Chezmoi)

Este documento detalla el proceso interno, script por script, desde que se inicializa Chezmoi hasta que el sistema queda completamente configurado (Zero-Touch), optimizado para una arquitectura **Sudo-less** en el día a día y un gestor de secretos basado en **Age/Passage**.

## 🛑 Requisitos Previos (Pre-condiciones del Cliente)

Para que el comando `chezmoi init --apply` se ejecute sin requerir intervención humana, el nodo cliente debe tener:

1.  **Sistema Base:** Linux (Fedora, Debian o Arch).
2.  **Paquetes:** `git` y `curl`.
3.  **Variables de Entorno (¡Crítico para Zero-Touch!):**
    *   `CHEZMOI_AGE_KEY`: Debe contener la llave privada de Age para descifrar secretos (como tokens de API de Bitwarden, Forgejo y GitHub).
    *   `GITHUB_TOKEN`: Un PAT de GitHub con permisos de `admin:public_key` para la autenticación automática de la CLI (`gh`).

**Comando de lanzamiento ideal:**
```bash
CHEZMOI_AGE_KEY="AGE-SECRET-KEY-1..." GITHUB_TOKEN="ghp_..." sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply yordycg
```

---

## 🔄 Flujo de Ejecución (Paso a Paso)

### Fase 0: Inicialización y Configuración Base
1.  **Clonación:** Chezmoi descarga el repositorio `dotfiles-universal`.
2.  **Plantilla (`.chezmoi.yaml.tmpl`):**
    *   Identifica la ruta de tu llave `age` (tolera `~/.config/age/key.txt` o `~/.config/chezmoi/key.txt`).
    *   Si la llave está presente, activa el motor de cifrado `age` por defecto y descifra `dot_config/homelab/private_secrets.yaml.age`.
    *   Detecta las capacidades de la máquina (WSL, Server, Laptop, Desktop, GUI vs Headless).
    *   Genera la configuración final en `~/.config/chezmoi/chezmoi.yaml`.

### Fase 1: Pre-Ejecución (`before_` - Espacio de Sistema)
*   **`run_once_before_00-provision-system.sh.tmpl`**:
    *   **Orquestación Sudo-less:** Agrupa y encapsula todas las tareas de sistema que requieren `sudo` (paquetes del sistema, Tailscale, certificados PKI locales y temas de pantalla de bloqueo).
    *   **Manejo de Caché:** Monitorea el hash de los scripts de instalación dentro del directorio `provision/`. Si no hay cambios, omite este paso por completo, logrando que el `apply` ordinario sea 100% sudo-less (sin prompt de contraseña).
    *   **Flujo Interno de Aprovisionamiento (Si hay cambios):**
        1. Ejecuta el script instalador correspondiente a la distro desde `provision/installers/`.
        2. Configura e inicializa la VPN con `provision/system/setup-tailscale.sh`.
        3. Añade la CA raíz interna del homelab con `provision/system/trust-homelab-ca.sh`.
        4. Si no es headless, configura el tema de SDDM con `provision/system/setup-sddm-theme.sh`.

### Fase 2: Aplicación del Estado (Archivos de Usuario)
*   Chezmoi procesa y copia todos los archivos regulares de usuario y plantillas (`dot_zshrc.tmpl`, `dot_gitconfig.tmpl`, `private_dot_ssh/config.tmpl`) al directorio `~/`.
*   Aplica el comando local `passage` (`dot_local/bin/executable_passage`), haciendo que el comando de secretos esté listo antes de correr scripts posteriores.

### Fase 3: Post-Ejecución (`after_` - Espacio de Usuario)
Estos scripts garantizan que las herramientas de usuario se configuren correctamente. Se ejecutan secuencialmente:

1.  **`run_once_after_10-install-fonts.sh.tmpl`**:
    *   Instala fuentes tipográficas (Nerd Fonts) para el shell y editores con sistema de caché.
2.  **`run_once_after_20-install-mise.sh.tmpl`**:
    *   Instala `mise` (gestor de entornos) y sincroniza herramientas de desarrollo (`node`, `python`, `usql`, `lazysql`, etc.).
    *   Extrae robustamente el `GITHUB_TOKEN` usando `passage` (o cae a `pass`) para evitar límites de API en las descargas.
3.  **`run_onchange_after_30-install-flatpaks.sh.tmpl`**:
    *   Asegura la instalación de paquetes flatpak del usuario en entornos de escritorio.
4.  **`run_once_after_35-setup-password-store.sh.tmpl`**:
    *   **Bootstrap de Secretos (Age/Passage):**
        1. Si la llave de `age` se encuentra en la ruta temporal de chezmoi (`~/.config/chezmoi/key.txt`), la estandariza copiándola a `~/.config/age/key.txt`.
        2. Crea el enlace simbólico de la identidad de `passage` a la llave de `age` (`~/.passage/identities` -> `~/.config/age/key.txt`).
        3. Genera el destinatario por defecto `~/.passage/store/.age-recipients` usando la llave pública de `age`.
        4. Clona tu repositorio de contraseñas privado (`passage-store.git` con fallback a `password-store.git`).
5.  **`run_onchange_after_40-apply-theme.sh.tmpl`**:
    *   Aplica temas y personalizaciones visuales del sistema del usuario (Kvantum, GTK, Qt).
6.  **`run_after_50-setup-ssh.sh.tmpl`**:
    *   Genera llaves SSH si faltan y las registra automáticamente en GitHub y Forgejo usando tokens desencriptados de manera robusta a través de `passage`.
7.  **`run_once_after_80-setup-backup.sh.tmpl`** (Solo servidores):
    *   Configura servicios systemd y timers para las copias de seguridad de Restic.
8.  **`run_once_after_84-sync-core-repos.sh.tmpl`**:
    *   Sincroniza proyectos centrales y repositorios clave en tu espacio local.
9.  **`run_after_85-sync-assets.sh.tmpl`**:
    *   Clona wallpapers y tus notas del segundo brain desde Forgejo (o GitHub como fallback).
10. **`run_once_after_99-change-shell.sh.tmpl`**:
    *   Establece de manera no interactiva a ZSH como tu shell por defecto (`chsh`).

---

## 🚀 Logrando el "Zero-Touch" Absoluto

Actualmente, el despliegue es **100% Zero-Touch** tras el primer apply. Para una máquina nueva virgen, el único requerimiento es la siembra de la llave privada de `age` mediante variables de entorno durante el `chezmoi init`. La elevación de privilegios (`sudo`) se encapsula y solo ocurre de forma controlada una sola vez al inicio del aprovisionamiento del nodo.
