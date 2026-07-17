# Blueprint de Arquitectura: dotfiles-universal (Chezmoi)

Este documento detalla la arquitectura técnica, filosofía de diseño, topología de nodos y el árbol de directorios de la configuración de **chezmoi** en el repositorio `dotfiles-universal`.

---

## 1. Contexto de Diseño y Filosofía de Operación

### 1.1 Objetivos de Diseño
1. **Zero-Touch absoluto:** La inicialización en un equipo nuevo (`chezmoi init --apply`) debe ejecutarse de forma desatendida, sin prompts interactivos de contraseñas o datos, cargando automáticamente las configuraciones a partir de variables de entorno.
2. **Sudo-less en el día a día:** Las tareas del sistema que requieren privilegios de administrador (`sudo`) se agrupan por separado. Las ejecuciones diarias (`chezmoi apply` o `just apply`) corren al 100% en espacio de usuario ($HOME) sin pedir contraseñas.
3. **Uso de Secretos Basado en Age/Passage:** Migración completa de llaves GPG hacia un sistema ligero basado en `age`. `passage` se emplea como bóveda local de contraseñas.
4. **Enfoque de Sistemas Operativos:** Exclusivo para entornos **Linux** y **WSL** (con bloqueo explícito para Windows nativo).

### 1.2 Topología de Nodos y Roles
* **Nodo 1 (Servidor Central - Headless):** Headless Debian (TBD / En pausa).
* **Nodo 2 (Estación de Fuerza - Desktop):** Estación de alto rendimiento. Ejecuta **Arch Linux + Hyprland (FULL)**.
* **Nodo N (Laptops - Clientes Ligeros):** Interfaces de movilidad ejecutan **Arch o Fedora + Hyprland (ECO Mode)** (sin animaciones ni blur para ahorrar batería).

---

## 2. Estructura de Directorios del Repositorio (`chezmoi/`)

A continuación se detalla la estructura física del repositorio:

```text
/home/yordycg/.local/share/chezmoi/
├── .chezmoi.yaml.tmpl              # Genera dinámicamente la configuración local de chezmoi
├── .chezmoignore                  # Exclusiones dinámicas según variables (ej: sin GUI)
├── .gitignore                      # Exclusiones de Git
├── Justfile                        # Task runner con comandos (apply, diff, update, save)
├── AGENTS.md                       # Instrucciones internas y reglas para asistentes de IA
│
├── docs/                           # Documentación de arquitectura interna
│   ├── tasks.md                    # Tablero Kanban y roadmap de tareas activas
│   ├── chezmoi_repository_architecture.md # Este plano de arquitectura
│   ├── bootstrap-execution-flow.md # Flujo de inicialización detallado paso a paso
│   ├── project-workflow.md         # Estándar de desarrollo de proyectos (Compose + Just)
│   └── remote-workflow-guide.md    # Guía de conexión ssh y live-reload a puertos locales
│
├── dot_config/                     # Configuraciones de usuario (~/.config/*)
│   ├── shell/                      # Scripts de inicialización modulares de Zsh
│   │   ├── aliases.sh
│   │   ├── functions.sh
│   │   ├── exports.sh.tmpl
│   │   └── functions/              # Funciones modulares (git, docker, infra, etc.)
│   ├── kitty/                      # Terminal emulator
│   ├── hypr/                       # Configuración de Hyprland modular (Lua)
│   │   ├── hyprland.lua            # Entrada principal de Lua
│   │   └── modules/                # Módulos de configuración (decorations, binds, etc.)
│   ├── waybar/                     # Barra de estado de Hyprland
│   ├── mise/                       # Gestor de entornos de desarrollo (Node, Go, Python, etc.)
│   ├── starship.toml.tmpl          # Prompt de terminal moderno
│   ├── wallust/                    # Generador de paletas de colores dinámicas
│   ├── gtk-3.0/ & gtk-4.0/         # Configuraciones de estilos GTK heredados
│   ├── rofi/                       # Menú lanzador de aplicaciones (Rofi type-2)
│   ├── swaync/                     # Sway Notification Center
│   ├── systemd/user/               # Timers y servicios systemd de usuario (Resty backups)
│   └── homelab/                    # Secretos cifrados del entorno (backup.env, etc.)
│
├── dot_local/                      # Archivos de usuario local (~/.local/*)
│   └── bin/
│       └── executable_theme-switch.tmpl  # Script interactivo de cambio de colores
├── private_dot_ssh/                # Llaves y hosts configurados de forma segura
│
├── provision/                      # Aprovisionamiento del sistema (Sudo Space)
│   ├── installers/
│   │   ├── fedora.sh               # Registro e instalación de paquetes RPM de Fedora
│   │   └── debian.sh               # Registro e instalación de paquetes APT de Debian
│   └── system/
│       ├── setup-sddm-theme.sh     # Script para cambiar la pantalla de inicio (SDDM)
│       ├── setup-tailscale.sh      # Inicialización y autorización de VPN
│       └── trust-homelab-ca.sh     # Instalación de certificados raíz en el almacén de confianza
│
└── .chezmoiscripts/                 # Scripts automáticos ejecutados por chezmoi
    ├── run_once_before_00-provision-system.sh.tmpl  # Orquestador del espacio de administración (sudo)
    ├── run_once_after_10-install-fonts.sh.tmpl       # Descarga e instalación de tipografías
    ├── run_once_after_15-setup-password-store.sh.tmpl # Clonado y vinculación de passage/age
    ├── run_once_after_20-install-mise.sh.tmpl        # Descarga de mise y SDKs de desarrollo
    ├── run_onchange_after_30-install-flatpaks.sh.tmpl# Automatización de aplicaciones Flatpak
    ├── run_onchange_after_40-apply-theme.sh.tmpl     # Aplicación del tema gráfico del usuario
    ├── run_after_50-setup-ssh.sh.tmpl                # Generación e inyección automática de llaves SSH
    ├── run_once_after_80-setup-backup.sh.tmpl        # Carga del demonio de respaldos del Homelab
    ├── run_once_after_84-sync-core-repos.sh.tmpl     # Clonación de repositorios de desarrollo
    ├── run_after_85-sync-assets.sh.tmpl              # Sincronización del Second Brain (Obsidian)
    └── run_once_after_99-change-shell.sh.tmpl        # Cambio de shell por defecto a Zsh
```

---

## 3. Enlaces a los Componentes Clave

Para consultar el código fuente de los componentes más críticos de la inicialización de forma directa y actualizada (evitando duplicidades de código), utiliza los siguientes enlaces:

*   **Template de Configuración de Chezmoi:** [.chezmoi.yaml.tmpl](../.chezmoi.yaml.tmpl)
*   **Orquestador de Aprovisionamiento (Sudo):** [.chezmoiscripts/run_once_before_00-provision-system.sh.tmpl](../.chezmoiscripts/run_once_before_00-provision-system.sh.tmpl)
*   **Lista de Tareas y Roadmap de Reestructuración:** [docs/tasks.md](tasks.md)
*   **Guía e Inducción para IAs:** [AGENTS.md](../AGENTS.md)
