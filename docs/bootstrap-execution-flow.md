# Simulación del Bootstrap y Flujo de Ejecución (Zero-Touch)

Este documento describe paso a paso qué ocurre bajo el capó desde el momento en que se clona el repositorio de dotfiles hasta que el comando `chezmoi apply` finaliza. Comprender este flujo es clave para depurar la automatización y lograr un despliegue "zero-touch".

## Fase 0: Inicialización

El proceso comienza normalmente con un comando de una sola línea (ej. `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply yordycg`) o clonando manualmente y ejecutando `chezmoi init yordycg`.

1. **Clonación del Repositorio:** Chezmoi clona el repo `dotfiles-universal` en `~/.local/share/chezmoi`.
2. **Evaluación de Variables (`.chezmoi.yaml.tmpl`):**
   - Chezmoi lee el archivo de configuración base.
   - **Prompt Interactivo:** Pide el `githubToken` (vital para evitar el API Rate Limit en descargas de mise/gh).
   - **Detección de Entorno:** Evalúa si es Linux, si tiene batería (Laptop), si es WSL o Desktop, y guarda estas variables.
   - Se genera la configuración estática en `~/.config/chezmoi/chezmoi.toml`.

## Fase 1: Pre-Ejecución (Scripts `before_`)

Antes de modificar o crear cualquier archivo en el sistema de destino (`~`), Chezmoi ejecuta los scripts marcados con el prefijo `before_`.

*   **`run_before_00-install-packages.sh.tmpl`**
    *   **Propósito:** Asegurar que las dependencias base del sistema estén instaladas antes de compilar o configurar nada.
    *   **Acción:** Detecta la distribución (Fedora, Debian, Arch), lee la estructura del archivo `packages.yaml` y ejecuta el gestor de paquetes (`dnf`, `apt`, `pacman`) para instalar git, curl, zsh, dependencias de compilación (build-tools), etc.

## 📂 Fase 2: Aplicación del Estado (Archivos y Plantillas)

Una vez garantizadas las dependencias, Chezmoi calcula el "diff" y procede a copiar o evaluar plantillas en el `~` del usuario.

1.  **Creación de Directorios:** Se crean estructuras como `~/.config/shell`, `~/.config/nvim`, etc.
2.  **Evaluación de Plantillas (`.tmpl`):**
    *   `dot_zshrc.tmpl` -> `~/.zshrc`
    *   `dot_gitconfig.tmpl` -> `~/.gitconfig`
    *   Se inyectan las variables calculadas en la Fase 0 (ej. tamaño de fuente de la terminal, configuraciones específicas del SO).

## Fase 3: Ejecución Estándar (Scripts en paralelo o alfabéticos)

Estos scripts se ejecutan durante la fase principal de aplicación (después de crear los archivos que no dependen de ellos).

*   **`run_10-install-fonts.sh.tmpl`**
    *   **Acción:** Descarga e instala fuentes de desarrollo (ej. Nerd Fonts).
*   **`run_20-install-mise.sh.tmpl`**
    *   **Acción:** Instala `mise` (gestor de entornos) y procede a instalar Node, Python, u otras herramientas definidas globalmente. Usa el `githubToken` exportado temporalmente para no fallar.

## 🏁 Fase 4: Post-Ejecución (Scripts `after_`)

Estos scripts se ejecutan al final, asegurando que todos los binarios, archivos de configuración y dependencias ya están en su lugar. Chezmoi los ordena alfabéticamente/numéricamente.

1.  **`run_after_80-sync-assets.sh.tmpl`**
    *   **Acción:** Sincroniza wallpapers o recursos gráficos.
2.  **`run_after_90-setup-ssh.sh.tmpl`**
    *   **Acción:** Flujo Zero-Touch SSH. Valida o genera las llaves (`id_ed25519`), arranca el agente SSH, y se comunica con GitHub CLI (`gh`) para inyectar la llave pública automáticamente en la cuenta, dejando el equipo listo para empujar código.
3.  **`run_after_99-change-shell.sh.tmpl`**
    *   **Acción:** Usa `chsh` para cambiar el shell por defecto del usuario a `zsh`. Al ejecutarse al final, garantiza que `zsh` fue instalado correctamente en la Fase 1.

---

## Análisis y Posibles Puntos de Mejora (Discusión)

Al observar este flujo, se aprecian algunos detalles importantes para estabilizar el proceso:

1. **Orden Alfabético en `after_`:** El script `99-change-shell` se ejecutará *antes* que `setup-ssh` (por orden ASCII). Si deseamos un orden más estricto, deberíamos enumerar todos los scripts (ej. `01-install-fonts`, `02-install-mise`, `90-setup-ssh`, `99-change-shell`).
2. **Dependencia Implícita:** `setup-ssh` asume que `gh` fue instalado en la **Fase 1**. Esto es correcto gracias al script `00-install-packages`.
3. **Mise y Compilaciones:** Si `mise` necesita dependencias del sistema (como `libssl-dev`), el hecho de que se instale en la Fase 3, después de la Fase 1, es la decisión correcta.