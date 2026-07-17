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
- [ ] Crear plantilla `decorations.lua.tmpl` (Modo ECO vs FULL)
- [ ] Crear plantilla `animations.lua.tmpl` (Desactivar animaciones en ECO)
- [ ] Crear plantilla `autostarts.lua.tmpl` (Daemons condicionales por distro/perfil)
- [ ] Crear plantilla `monitors.lua.tmpl` (Monitores por hostname)
- [ ] Integrar atajos de capturas (`hyprshot`) y calc (`rofi-calc`) en `binds.lua`
- [ ] Integrar atajos de Alt+Tab (`snappy`) en `binds.lua`

## Fase 4: Entornos Declarativos (Distrobox)
- [ ] Crear plantilla `distrobox.ini.tmpl` (Declaración de contenedores base)
- [ ] Crear script `.chezmoiscripts/run_onchange_after_30-distrobox-assemble.sh`
- [ ] Validar creación automática de contenedores con `distrobox assemble`

## Fase 5: Tareas Pendientes del Roadmap
- [ ] Integrar `passage` en iOS y extensión de Firefox (PassFF)
- [ ] Centralizar temas GTK/Qt y cursor en variables de `.chezmoi.yaml.tmpl`
- [ ] Adaptar plantillas de estilo (`settings.ini.tmpl`, `index.theme.tmpl`) al tematizado centralizado
