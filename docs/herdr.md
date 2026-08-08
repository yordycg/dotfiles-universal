# Herdr — Cheat Sheet (Workspace Manager Agent-Native)

> Herdr es un gestor de workspaces en terminal, agent-native. Server de fondo +
> clientes TUI. `herdr` desde cualquier terminal adjunta/abre tu sesión default.

## Arranque y vida

| Acción | Comando |
|---|---|
| Abrir/adjuntar sesión default | `herdr` |
| Detachar (deja todo corriendo) | `ctrl+b q` |
| Re-adjuntar | `herdr` |
| Listar workspaces | `herdr workspace list` |
| Enfocar workspace | `herdr workspace focus <id>` |
| Parar servidor (mata panes) | `herdr server stop` |
| Recargar config en caliente | `herdr server reload-config` |
| Ayuda de keybinds en vivo | `prefix+?` |

## Keybinds — Prefix (`ctrl+b`)

| Acción | Key |
|---|---|
| Settings (reubicado) | `prefix+shift+s` |
| Nueva pestaña | `prefix+c` |
| Split vertical / horizontal | `prefix+v` / `prefix+minus` |
| Moverse entre panes | `prefix+h/j/k/l` |
| Zoom pane | `prefix+z` |
| Workspace picker | `prefix+w` |
| Goto / session navigator | `prefix+g` |
| Nueva / renombrar workspace | `prefix+shift+n` / `prefix+shift+w` |
| Tab anterior / siguiente | `prefix+p` / `prefix+n` |
| Cerrar pane / tab / workspace | `prefix+x` / `prefix+shift+x` / `prefix+shift+d` |
| Copy mode | `prefix+[` |
| Toggle sidebar | `prefix+b` |
| Detach | `prefix+q` |

## Keybinds — Plugin actions

| Acción | Key |
|---|---|
| Navegar vim<->panes | `ctrl+h/j/k/l` |
| Sessionizer: abrir proyecto | `prefix+s` |
| Sessionizer: abrir worktree | `prefix+f` |
| Reviewr: abrir pane | `prefix+alt+r` |

## Keybinds — Acordes directos (`ctrl+alt`, seguros en kitty/Hyprland)

| Acción | Chord |
|---|---|
| Focus pane izquierda/abajo/arriba/derecha | `-h/j/k/l` (lo absorbe el plugin) |
| Tab anterior / siguiente | `ctrl+alt+[` / `ctrl+alt+]` |
| Nueva pestaña | `ctrl+alt+c` |
| Split vertical / horizontal | `ctrl+alt+d` / `ctrl+alt+shift+d` |
| Zoom | `ctrl+alt+z` |
| Ciclar pane | `ctrl+alt+tab` |
| Workspace picker / goto | `ctrl+alt+w` / `ctrl+alt+g` |

## Popups (custom commands)

| Acción | Key |
|---|---|
| lazygit | `prefix+alt+g` |
| Scratch terminal | `prefix+alt+t` |
| opencode | `prefix+alt+o` |
| lazydocker (pane) | `prefix+alt+d` |

## Integración con agentes

- **Instalar integración** (estado de vida + resume): `herdr integration install opencode`
- Estado se muestra en el sidebar: `working` / `blocked` / `idle` / `done`.
- Notificaciones del sistema (SwayNC) cuando un agente termina o pide input.

## Plugins instalados (Tier 1 — mercado herdr.dev)

Instalación declarativa en `.chezmoiscripts/run_once_after_22-setup-herdr-plugins.sh.tmpl`.

| Plugin | Qué hace | Key(s) |
|---|---|---|
| `vim-herdr-navigation` | `Ctrl+h/j/k/l` cruza splits de vim y panes de herdr; fuera de herdr cae a tmux | chords directos |
| `herdr-sessionizer` | pickers fzf de proyectos (`~/workspace`) y worktrees | `prefix+s` / `prefix+f` |
| `persiyanov.reviewr` | pane de revisión de diffs de agentes + comentarios en línea | `prefix+alt+r` |

- Editor side vendored: `~/.config/herdr/editor/herdr_nav.lua`, cargado por LazyVim y
  nvim-personal tras cargar plugins.
- TUIs que internamente usan `Ctrl+h/j/k/l` (lazygit, lazydocker, yazi) pasan por
  `HERDR_NAV_PASSTHROUGH_RE` (definido en `exports.sh`) — salir de ellos con `prefix+h/j/k/l`.

## Workspaces & Sessionizer (índice de proyectos)

El picker `prefix+s` no escanea `~/workspace/` directo: usa un **índice de symlinks**
en `~/workspace/sessions/` (oculta `wallpapers` e incluye `dotfiles` → `~/.local/share/chezmoi`).
Generado idempotentemente por `run_once_after_23-sync-sessionizer-index`.

```text
~/workspace/sessions/
├── dotfiles            -> ~/.local/share/chezmoi
├── learning-path       -> ~/workspace/personal/learning-path
├── obsidian-notes      -> ~/workspace/assets/obsidian-notes
├── sistemaVeterinario  -> ~/workspace/personal/sistemaVeterinario
├── web-scrapping-basic -> ~/workspace/work/web-scrapping-basic
└── yordycg-portfolio   -> ~/workspace/personal/yordycg-portfolio
```

- **Layout por-repo**: cada repo declara `.sessionizer/config.toml` (solo
  `[layout].focus` + `[tabs.*]`); el resto hereda el layout genérico `tabs.dev`
  (editor 65% + opencode 35% + lazygit abajo). Commiteado, viaja con el repo.
- Overrides activos: `obsidian-notes` (1 pane LazyVim), `learning-path` (nv + terminal),
  `dotfiles` (LazyVim + shell 50/50; ignorado por chezmoi vía `.chezmoiignore`).

### Nuevo proyecto (workflow)

```bash
# 1. Clonar/crear el repo en un grupo existente
git clone git@github.com:yordycg/mi-proyecto.git ~/workspace/personal/mi-proyecto

# 2. Regenerar el índice → aparece en prefix+s (sin tocar config)
chezmoi apply   # corre run_once_after_23 → actualiza ~/workspace/sessions

# 3. (opcional) Layout propio del repo
mkdir ~/workspace/personal/mi-proyecto/.sessionizer
# editar .sessionizer/config.toml (ver formato arriba)
```
El índice apunta a `roots`, así que al correr el script los futuros repos entran solos.

## Comandos útiles (automatización)

```bash
herdr workspace create --cwd ~/project --label api --focus
herdr agent start reviewer --kind codex --pane "$pane_id" -- -m gpt-5.4
herdr agent wait reviewer --until blocked --timeout 120000
herdr agent read reviewer --source recent-unwrapped --lines 80
```

## Aliases en zsh

```sh
hd='herdr'                 hdl='herdr workspace list'
hdw='herdr workspace focus' hdstop='herdr server stop'
```

## Hyprland

`SUPER+O` abre herdr en kitty (definido en `modules/binds.lua`).

## Notas sobre el tema

El config usa `[theme] name = "terminal"` → herdr hereda la paleta ANSI de kitty,
que es tematizada externamente por el sistema `~/.config/themes` + `link-theme`.
Cambiar de theme visual actualiza herdr automáticamente (vía kitty) sin tocar config de herdr.
