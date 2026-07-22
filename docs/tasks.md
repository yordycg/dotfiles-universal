# Roadmap de Reestructuración

## Fase 1: Documentación y Bases
- [x] Consolidar GEMINI.md y context.md en AGENTS.md
- [x] Mover tasks.md a docs/tasks.md
- [x] Eliminar archivos de documentación obsoletos de docs/

## Fase 2: Core de Chezmoi
- [x] Agregar variables a `.chezmoi.yaml.tmpl` (profile, distro - auto-detectadas sin prompts)
- [x] Validar generación de variables locales con `chezmoi execute-template`
- [x] Crear `.chezmoidata/packages.yaml` con la matriz de paquetes (Arch / Fedora)
- [x] Adaptar script `.chezmoiscripts/run_once_before_00-provision-system.sh.tmpl`
- [x] Validar aprovisionamiento silencioso en seco (`chezmoi apply --dry-run`)

## Fase 3: Modularización de Hyprland (Lua)
- [x] Crear plantilla `decorations.lua.tmpl` (Modo ECO vs FULL)
- [x] Crear plantilla `animations.lua.tmpl` (Desactivar animaciones en ECO)
- [x] Crear plantilla `autostarts.lua.tmpl` (Daemons condicionales por distro/perfil)
- [x] Crear plantilla `monitors.lua.tmpl` (Monitores por hostname)
- [x] Integrar atajos de capturas (`hyprshot`) y calc (`rofi-calc`) en `binds.lua`
- [x] Integrar atajos de Alt+Tab (`snappy`) en `binds.lua`

## Fase 4: Tareas Pendientes del Roadmap
- [ ] Integrar `passage` en iOS y extensión de Firefox (PassFF)
- [ ] Implementar patrón de errores tolerantes (Soft Fails) en scripts de aprovisionamiento
  - Crear un wrapper `run_tolerant` en `provision/lib/logging.sh` para pasos de instalación no críticos.
  - Adaptar scripts en `.chezmoiscripts/` y `provision/system/` para reportar advertencias y continuar la ejecución en lugar de abortar con exit status 1.
- [ ] Implementar sistema de Captura Rápida de Notas (Inbox) en Obsidian Vault y Sincronización con iOS
  - Crear script ejecutable para generar/abrir notas en `~/workspace/assets/obsidian/Inbox/` nombradas por fecha/hora (`YYYY-MM-DD_HHMMSS.md`).
  - Configurar regla de ventana flotante en Hyprland e integrar bind en Lua (`binds.lua`) para abrir Neovim en terminal flotante dedicada.
  - Configurar integración con iOS usando **Working Copy** + **Atajos de Apple (Shortcuts)** para enviar notas rápidas desde el iPhone al repositorio de Obsidian vía Git.
- [ ] Evaluar migración total de Tmux a `lazy-tmux`
  - Evaluar reemplazar la pila actual (`tmux-resurrect`, `tmux-continuum`, `tmux-sessionx`) por una suite única e integrada basada en `lazy-tmux` (daemon de autosave + TUI picker).
- [ ] Implementar herramienta `herdr`
  - Evaluar e integrar `herdr` en la matriz de herramientas para gestión de proyectos y flujos de trabajo en terminal.
- [ ] Implementar agente IA de código `opencode`
  - Configurar e integrar la CLI de `opencode` en el entorno de desarrollo y ajustar alias/keybindings en Zsh.
- [ ] Implementar agente IA `pi` (Agent IA / pi-acp)
  - Integrar la CLI del agente de inteligencia artificial `pi` para asistencia y automatización avanzada en terminal.


