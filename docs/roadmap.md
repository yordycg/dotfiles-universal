# dotfiles-universal — Roadmap de implementación

---

## 🔧 Fase 1 — Dotfiles y Editor

### 1.1 Neovim (Estrategia Dual)

- [x] **Workflow de Notas en Neovim**: Integrar y configurar Neovim (usando `obsidian.nvim` o similar) como editor principal para el Second Brain, reemplazando la aplicación gráfica de Obsidian.
- [x] **Sesión de Tmux para Notas**: Crear una configuración y alias de Tmux dedicado para abrir el directorio de notas directamente en una sesión aislada y enfocada.

### 1.2 Tmux

- [x] **Preservar Atajos Estándar**: Evitar modificar excesivamente los atajos (keybindings) por defecto de Tmux para mantener la memoria muscular intacta al operar en servidores externos u otros equipos.
- [x] **Investigación de LazyApps**: Evaluar la integración de otras herramientas TUI de la familia *Lazy* (como `lazydocker` para docker, `lazysql` para BDs u otras) en la configuración de la terminal y los atajos de Tmux.

### 1.3 Limpieza de Shell (Zsh)

- [x] **Refactorización de `.zshrc`**: Analizar y limpiar `dot_zshrc.tmpl`. Mover variables de entorno (exports), aliases y funciones duplicadas de Mise hacia sus respectivos archivos dedicados en `dot_config/shell/` para mantener el archivo principal minimalista.

---

## 🔧 Fase 2 — Contenedores y Proyectos (Host inmaculado)

### 2.1 Infraestructura de Código y CI/CD

- [ ] Implementar el primer flujo de CI/CD (ej. auto-deploy de `yordycg-portfolio`).

### 2.2 Gestión de Bases de Datos (Senior Terminal Workflow)

- [x] **Database TUI & CLI**: Implementar `usql` (cliente universal) y `lazysql` (interfaz TUI) para gestión total desde terminal/tmux.
- [x] **Configuración**: Añadir herramientas a `packages.yaml` y crear alias de acceso rápido.

---

## 🔧 Fase 3 — Seguridad y secrets

- [x] **Investigar `pass` como Gestor Alternativo**: Evaluar `pass` (the standard unix password manager) y compararlo con el stack actual (Bitwarden/Vaultwarden) para determinar si vale la pena la migración hacia una solución más nativa de terminal y ligera en recursos.
- [ ] **Integración Móvil y Navegador (passage)**: Implementar y configurar `passage` en iOS (Password Store) y en el navegador Firefox (PassFF con passff-host o wrappers).

## 🔧 Fase 4 — Advanced Homelab Workflow (Senior Implementation)

> El objetivo es lograr "Cero Contaminación" en el repo de infraestructura y "Aislamiento Total" en proyectos de estudio.

### 4.1 Hardening y Autodiscovery (homelab-infra)

- [ ] **Robustez de Respaldos (homelab-infra)**: Cargar `configs/backup.env` en `manage.sh` para garantizar que la copia de seguridad con Restic tenga acceso al entorno configurado.
- [x] **Unificación SSH (chezmoi)**: Eliminar la inyección manual de `github.com` al final de `~/.ssh/config` en `run_after_50-setup-ssh.sh.tmpl` para centralizar la configuración en `private_dot_ssh/config.tmpl`.
- [ ] **Bot de Notificación de Backups (homelab-infra & chezmoi)**: Investigar e implementar un bot (Telegram, WhatsApp, o alternativas de notificaciones abiertas como NTFY/Apprise) para alertar sobre el estado de los backups automáticos del servidor, con potencial para reportar métricas del sistema, bloqueos de Fail2ban y alertas críticas de contenedores.

---

## 📋 Protocolo de Bootstrap (New Node)

Para cualquier máquina nueva, el proceso de identidad es manual para máxima seguridad:

1.  **Siembra de Identidad**: Copiar desde USB seguro:
    - `age` key -> `~/.config/age/key.txt` (o `~/.config/chezmoi/key.txt`, el script la estandarizará automáticamente).
    - SSH key -> `~/.ssh/id_ed25519` y `~/.ssh/id_ed25519.pub`.
    *(Ya no es necesario sembrar llaves GPG para la gestión de secretos).*
2.  **Chezmoi Init**:
    ```bash
    chezmoi init --apply yordycg
    ```

---

## 📋 Comandos útiles del día a día

```bash
just apply        # Aplicar cambios pendientes
just diff         # Ver qué va a cambiar
just update       # git pull + apply
just save         # commit + push rápido
lab-open          # Port forward instantáneo del servidor
lps               # Ver estado de contenedores remotos
```

---

## Estado del repo en GitHub

```
dotfiles-universal/
├── .chezmoi.yaml.tmpl      [OK]
├── .chezmoignore          [OK]
├── .gitignore              [OK]
├── Justfile                [OK]
├── dot_gitconfig.tmpl      [OK]
├── dot_zshrc.tmpl          [OK]
├── dot_config/
│   ├── shell/
│   │   ├── aliases.sh      [OK]
│   │   └── functions.sh    [OK]
│   ├── homelab/
│   │   ├── backup.env      [OK] (Secretos)
│   │   └── private_secrets.yaml.age [OK] (Bitwarden API Keys)
│   ├── systemd/user/
│   │   ├── homelab-backup.service [OK]
│   │   └── homelab-backup.timer   [OK]
│   ├── starship.toml       [OK]
│   ├── nvim/               [OK] Fase 1
│   └── tmux/               [OK] Fase 1
├── home/                   (Estructura OK)
├── hosts/                  (Estructura OK)
└── scripts/
    ├── run_onchange_before_00-install-packages.sh   [OK]
    ├── run_onchange_after_10-install-fonts.sh      [OK]
    ├── run_onchange_after_20-install-mise.sh       [OK]
    ├── run_once_after_90-setup-ssh.sh              [OK]
    ├── run_after_95-trust-homelab-ca.sh            [OK]
    └── run_once_after_99-change-shell.sh           [OK]
```

---

## 🔧 Fase 5 — Desacoplamiento de Sudo y Unificación de Secretos

> El objetivo es lograr que Chezmoi corra 100% en espacio de usuario ($HOME) sin requerir `sudo` en su día a día, y unificar el llavero de seguridad bajo una única llave de Age.

### 5.1 Desacoplamiento de Sudo (Espacio de Sistema)
- [x] **Extraer scripts de sistema:** Modularizamos y extrajimos las tareas que requieren `sudo` (paquetes del sistema, VPN Tailscale, PKI Homelab, y SDDM theme) al directorio `provision/` y creamos un orquestador único `run_once_before_00-provision-system.sh.tmpl` que se ejecuta de forma controlada basándose en hashes, logrando que el día a día sea 100% sudo-less.
- [ ] **Asegurar fallback de Wallpaper en Sway:** Añadir un fondo de pantalla básico y ligero dentro del repo de Chezmoi para que Sway no inicie en blanco si la carpeta de assets externa no se ha sincronizado.

### 5.2 Unificación de Secretos (Age)
- [x] **Migración a `passage` (Age-based):** Reemplazamos el uso de `pass` (GPG) por `passage` (Age) local en `$HOME/.local/bin/passage`. El llavero ahora usa la llave única de `age` para el descifrado y un script de migración movió exitosamente los 13 secretos `.gpg` a `.age`. Todos los scripts consumidores fueron adaptados con detección robusta.

---

## 🔧 Fase 6 — Soporte KDE Plasma 6 y Personalización (Próximamente)

> El objetivo es implementar soporte para entornos de escritorio gráficos modernos de manera condicional y ligera en los Nodos N (Fedora KDE Spin), manteniendo el host limpio y el repositorio de Chezmoi libre de archivos binarios pesados.

### 6.1 Lógica y Condicionales de Entorno
- [x] **Variable `desktopEnv`:** Incorporar en `.chezmoi.yaml.tmpl` la variable `desktopEnv` (con opciones: `gnome`, `kde`, `sway`, `none`) para independizar el hardware/virtualización de la interfaz de usuario.
- [x] **Aislamiento en `.chezmoignore`:** Configurar exclusiones dinámicas basadas en `desktopEnv` para evitar copiar configuraciones cruzadas de entornos gráficos (ej. ignorar carpetas de KDE si se usa GNOME).

### 6.2 Automatización e Instalación del Tema (Opción B)
- [x] **Script de compilación y descarga:** Crear un script de Chezmoi `.chezmoiscripts/run_once_after_45-install-theme.sh.tmpl` que realice un clonado temporal de los temas (`MacSequoia-kde` / `WhiteSur-kde` de vinceliuice), ejecute sus instaladores `./install.sh` y limpie los archivos descargados.
- [x] **Modularización de Paquetes:** Reorganizar `scripts/packages/packages.yaml` para clasificar las dependencias por entorno (ej. paquetes específicos de KDE vs dependencias generales de GUI).

### 6.3 Persistencia de Preferencias
- [x] **Seguimiento de configuración de KDE:** Implementado: Añadidos atajos personalizados (`kglobalshortcutsrc`) a Chezmoi y automatizada la aplicación de preferencias estéticas (como el tema global) usando scripts CLI (`lookandfeeltool`/`kwriteconfig`) en lugar de archivos `.rc` enteros inestables.

### 6.4 Tipografías y Consistencia Visual (Apple SF Pro Font)
- [x] **Instalación y Configuración de San Francisco Font:** Automatizar la descarga e instalación de las tipografías de macOS (SF Pro Display, SF Pro Text, SF Mono) de manera limpia (ej. en `.chezmoiscripts/run_once_after_10-install-fonts.sh.tmpl`).
- [x] **Predeterminación en el Sistema (Sway & Navegadores):** Configurar Fontconfig (`~/.config/fontconfig/fonts.conf`) para establecer SF Pro como la tipografía sans-serif/system-ui por defecto. Asegurar que la UI de Sway, navegadores (Firefox, Chromium) y otras aplicaciones GTK/Qt la usen de forma consistente y automática.

---

> Actualizado: 22 de junio de 2026 — Plan de Soporte KDE Plasma 6 y Tipografías.
