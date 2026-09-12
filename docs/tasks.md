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
- [x] Automatización y optimización de Google Drive (Rclone VFS Full + ONLYOFFICE + GTK Bookmarks)
  - Mejorar unidad systemd `rclone-mount.service.tmpl` con `--vfs-cache-mode full`, límites de caché (15G) y exportación de formatos Google Docs (`docx,xlsx,pptx,pdf`).
  - Declarar `rclone` y `fuse3` en `.chezmoidata/packages.yaml` para provisión desatendida en Desktop y Laptop.
  - Crear hook onchange `.chezmoiscripts/run_onchange_after_35-setup-rclone-mount.sh.tmpl` para recarga y reinicio automático.
  - Crear symlink `~/Drive` y marcadores GTK (`~/.config/gtk-3.0/bookmarks.tmpl`) para acceso instantáneo desde ONLYOFFICE, Dolphin y terminal.
- [ ] Integrar `passage` en iOS y extensión de Firefox (PassFF)
- [ ] Implementar patrón de errores tolerantes (Soft Fails) en scripts de aprovisionamiento
  - Crear un wrapper `run_tolerant` en `provision/lib/logging.sh` para pasos de instalación no críticos.
  - Adaptar scripts en `.chezmoiscripts/` y `provision/system/` para reportar advertencias y continuar la ejecución en lugar de abortar con exit status 1.
- [ ] Implementar sistema de Captura Rápida de Notas (Inbox) en Obsidian Vault y Sincronización con iOS
  - Crear script ejecutable para generar/abrir notas en `~/workspace/assets/obsidian/Inbox/` nombradas por fecha/hora (`YYYY-MM-DD_HHMMSS.md`).
  - Configurar regla de ventana flotante en Hyprland e integrar bind en Lua (`binds.lua`) para abrir Neovim en terminal flotante dedicada.
  - Configurar integración con iOS usando **Working Copy** + **Atajos de Apple (Shortcuts)** para enviar notas rápidas desde el iPhone al repositorio de Obsidian vía Git.
- [x] Evaluar migración total de Tmux a `lazy-tmux`
  - Reemplazar la pila anterior (`tmux-resurrect`, `tmux-continuum`, `tmux-sessionx`) por `lazy-tmux` en `tmux.conf.tmpl` y la matriz `packages.yaml`.
- [x] Implementar herramienta `herdr`
  - Integrar `herdr` en la matriz de Mise (`config.toml.tmpl`) con instalador oficial como fallback.
  - Config completa en `dot_config/herdr/config.toml.tmpl` (tema ANSI, keybinds, popups, notificaciones, ECO mode).
  - Integración nativa con `opencode` (`herdr integration install`) vía `run_once_after_21`.
  - Bind `SUPER+O` en Hyprland y aliases `hd`/`hdl`/`hdw`/`hdstop` en zsh.
- [x] Plugins herdr Tier 1 (vim-herdr-navigation, sessionizer, reviewr)
  - Setup declarativo e idempotente en `run_once_after_22-setup-herdr-plugins.sh.tmpl`.
  - Keybinds: `Ctrl+h/j/k/l` navegan vim<->herdr; `prefix+s`/`prefix+f` sessionizer; `prefix+alt+r` reviewr.
  - Editor side vendored en `~/.config/herdr/editor/herdr_nav.lua`, dofile desde LazyVim y nvim-personal.
  - Layout sessionizer replicando `tdl` (nvim 65% + opencode 35% + lazygit abajo).
  - `HERDR_NAV_PASSTHROUGH_RE` en `exports.sh` para lazygit/lazydocker/yazi.
- [x] Proyectos para Sessionizer (escaneo en vivo, sin índice)
  - `roots = ["~/workspace"]` + `git_only` + `depth=2`: nuevos repos aparecen solos.
  - `wallpapers` migrado fuera del workspace a `~/Pictures` (no es un proyecto);
    `sync-assets` clona ahí y crea el symlink `assets/dotfiles`→chezmoi.
  - Overrides `.sessionizer/config.toml` por-repo (notes/learning/dotfiles) +
    doc del workflow "Nuevo proyecto".
- [x] Implementar agente IA de código `opencode`
  - Configurar e integrar la CLI de `opencode` en el entorno de desarrollo y ajustar alias/keybindings en Zsh, además del layout Tmux (`tdl`).
- [x] Implementar agente IA `pi` (Agent IA / pi-acp)
  - Integrar la CLI del agente de inteligencia artificial `pi` para asistencia y automatización avanzada en terminal. Con extensiones personalizadas, headers limpios y paridad total con OpenCode y Antigravity.

## Fase 5: Videcoding Workflow (Architect + Workers)
- [x] Investigar recursos de la comunidad (sammwy SPECS/ROADMAP, Kanvas, claude-code-ultimate-guide, gentle-ai/pi)
- [x] Crear plantilla `scripts/templates/videcoding-base/`:
  - Documentos sammwy: `SPECS.md`, `README.md`, `CODESTYLE.md`, `ROADMAP.md`
  - Orquestación dual agnóstica: `AGENTS.md` (roles architect/worker, TDD estricto, gates, no self-verify, curse of instructions)
  - Dual-write obligatorio `TASKS.md` ↔ `Project.canvas` + `bin/sync-tracking.py` + target `just sync-tracking`
  - Kanvas vendered (MIT): `canvas-tool.py`, `Project.canvas`, `RULES.md` adaptado
  - `Justfile` (setup/status/ready/lint/test/gate/install-hooks) + `bin/gate.sh` + hook `bin/pre-commit`
  - Subagentes opencode: `.opencode/agent/architect.md` (Claude vía OpenRouter), `worker.md` (deepseek-v4-flash) y `scout.md` (Gemini)
  - Reutiliza `.editorconfig`, `.env.example` de `project-base`
- [x] Crear comando `new-videcoding-project` (`dot_local/bin/executable_new-videcoding-project.tmpl`)
- [x] Crear skill opencode `dot_agents/skills/videcoding-framework/SKILL.md`
- [x] Renombrar stack completo de "videocoding" a **videcoding** (nombre correcto del concepto)
- [x] Documentación en `docs/videcoding/`:
  - [x] `README.md` (índice) + `workflow.md` (migrado de `docs/videocoding-workflow.md`)
  - [x] `setup.md` (checklist de inicio: install-hooks, /models, /gentle:models, Fase 0 crítica)
  - [x] `daily-flow.md` (sesión humana, verificación, protocolo overnight)
  - [x] `troubleshooting.md` (errores comunes: gate, sync-tracking, modelos, proveedores)
- [ ] Configurar proveedores en opencode/pi: OpenRouter (Claude, whitelist + $5-10), DeepSeek directo (worker), Gemini (scout)
- [ ] Probar en seco `new-videcoding-project` y validar el ciclo TDD + dual-write con un proyecto real

## Fase 6: Auditoría Clean Host y Redirección XDG (2026-09-04)
- [x] Auditar `$HOME`: mise funcionaba (92 shims), pero los runtimes ensuciaban `$HOME` (`.npm` 2.1G, `.rustup` 1.5G, `.nuget` 1.1G) por falta de redirección XDG.
- [x] XDG Base + redirección de runtimes en `dot_config/shell/exports.sh.tmpl` (CARGO/RUSTUP/GOPATH/NPM/DOTNET/NUGET/CUDA/WGET/GTK2) + `environment.d` para sesión/GUI.
- [x] Historial zsh → `$XDG_STATE_HOME/zsh/history`; compdump → `$XDG_CACHE_HOME/zsh/zcompdump` (`history.zsh`, `completion.zsh.tmpl`).
- [x] `mise` como fuente canónica de CLI (cross-distro); cabecera de filosofía en `dot_config/mise/config.toml.tmpl`.
- [x] Dedupe pacman↔mise: `tmux`/`fzf`/`fastfetch` → solo mise; `age`/`jq`/`gh` quedan en base (usados en scripts de apply previos a mise).
- [x] Hyprland descontinuado: secciones comentadas en `packages.yaml` como respaldo; utilidades Wayland genéricas reubicadas a `desktop_gui`.
- [x] `clean-dotfiles` (caches yay/npm/pip/uv/go-build/playwright/Trash/flatpak-unused) + receta `just clean`.
- [x] Migración one-shot `run_once_after_98-xdg-migration.sh` (`.cargo/.rustup/go/.npm/.nuget/.dotnet/.bun` → XDG) con re-enlace del backend rust de mise.
- [ ] **Pendiente root (manual):** desinstalar stack hyprland y DMS (`dms-shell-niri quickshell-git dsearch-bin`), `paccache -rk1`, sddm drop-in, y re-login para validar XDG.
- [ ] Verificar que al desinstalar el stack muere el `swaync` huérfano (redundante bajo Noctalia).

## Fase 7: Consolidación Niri + Noctalia (2026-09-07)
- [x] Purgar DMS (DankMaterialShell), Quickshell, dsearch y matugen del repositorio.
- [x] Configurar Noctalia v5 como único shell permanente para Niri (Desktop y Laptop).
- [x] Definir Modo ECO Visual en Laptop (render plano: sin animaciones, sin blur, sin sombras; sin estrangular CPU/RAM para desarrollo).
- [x] Migrar binds multimedia, launcher, portapapeles y session lock a Noctalia IPC (`noctalia msg`).
- [x] Reemplazar lista de procesos de DMS por `btop` en Ghostty (`Super+M`).
- [x] Migrar asociaciones de imágenes de `dms-open` a `imv.desktop` en `mimeapps.list`.
- [x] Migrar notificaciones de `passage-launcher` a `notify-send`.

## Fase 8: Consolidación de Pilares y Templates Oficiales GitHub (2026-09-12)
- [x] Paridad de la Tríada de IA (Pi, OpenCode, Antigravity) usando `.agents/` como fuente única de verdad.
- [x] Optimizar tiempo de arranque de Pi en `$HOME` (de 19.3s a 2.5s) reduciendo timeout de FFF.
- [x] Pilar 1 (Learn): DAGs en ASCII/Unicode en terminal, Single-Focus Invariant, Code-as-Answer, y estándar `@annotations` en comentarios.
- [x] Pilar 2 (Videcoding): Unificación de documentación SDD freelance (Fases 0 a 7) con el motor de Videcoding (Kanvas, `Project.canvas`, dual-write, subagentes en `.agents/agents/`).
- [x] Migración a repositorios template oficiales en GitHub: `yordycg/template-learn` y `yordycg/template-videcoding`.
- [x] Purga de templates locales en Chezmoi (`scripts/templates/`) y creación de generadores ligeros `new-learn` y `new-code`.

## Backlog / Futuro: Orquestación Multi-Agente (Firstmate)
- [ ] Evaluar Firstmate (`kunchenguid/firstmate`) como orquestador asíncrono sobre Herdr:
  - Analizar integración de `treehouse` para worktrees efímeros en proyectos de desarrollo (`~/workspace/work/`, `~/workspace/personal/`).
  - Probar tareas tipo `scout` (auditorías e investigación en read-only) sin alterar repositorios principales.
  - Mantener `learning-path` aislado en modo estudio interactivo (Socratic Mentor).
