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

## Keybinds — Acordes directos (`ctrl+alt`, seguros en kitty/Hyprland)

| Acción | Chord |
|---|---|
| Focus pane izquierda/abajo/arriba/derecha | `ctrl+alt+h/j/k/l` |
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
