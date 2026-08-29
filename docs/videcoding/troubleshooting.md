# Videcoding — Troubleshooting

Errores comunes, su causa y la solución. Si el problema no está aquí, revisa el estado del proyecto y ejecuta `just sync-tracking` antes de nada.

## Errores del flujo

| Síntoma | Causa | Solución |
|---------|-------|----------|
| Commit **bloqueado** por el gate (hook pre-commit) | `TASKS.md` y `Project.canvas` divergen | `just sync-tracking` y vuelve a commitear |
| `sync-tracking` **revierte** un `- [x]` a `- [ ]` | Alguien (o el worker) marcó TASKS.md como hecha sin que el canvas esté en verde | Solo el **humano** pone el verde en el canvas; luego `just sync-tracking` actualiza TASKS.md |
| `python3 canvas-tool.py ... start <ID>` rechazado | Tarea no está roja (propuesta/bloqueada) o tiene dependencias sin cumplir | `just ready` (solo rojas listas) y `just blocked` para ver qué bloquea |
| El gate **pasa sin verificar nada** | Los targets `lint`/`test` del Justfile siguen siendo placeholders de Fase 0 | El architect debe llenarlos en Fase 0 (ver `setup.md` §7) |
| `canvas-tool.py` no encuentra `Project.canvas` | Se ejecuta desde fuera de la raíz del proyecto | Corre los comandos desde la raíz del proyecto (`Project.canvas` está ahí) |
| `just` no encontrado | Herramienta no instalada | Instalar `just` (ver matriz de paquetes de la infraestructura) |
| `python3` no encontrado | Entorno sin Python 3.7+ | `canvas-tool.py` requiere Python 3.7+; instalar python3 |
| Los estados de Obsidian no se actualizan solos | Plugin **canvas-watcher** no instalado | Es opcional: instálalo (ver `RULES.md` §Watcher) o usa la CLI (`just status`) |

## Errores de modelos / proveedores

| Síntoma | Causa | Solución |
|---------|-------|----------|
| `anthropic/claude-sonnet-4.6` **no aparece** en `/models` | Slug cambiado (nueva versión de Claude) o auth de OpenRouter ausente | `opencode auth login` → OpenRouter; luego `/models` y ajusta `.opencode/agent/architect.md` |
| OpenRouter responde **402** | Sin crédito | Recargar en el dashboard de OpenRouter (solo se usa para Claude) |
| OpenRouter responde **429** | Rate limit | Esperar y reintentar; revisa el dashboard |
| Modelo del architect no disponible en pi | `models.json` sin el override de OpenRouter o sin auth en pi | Registrar OpenRouter en pi (`/connect` o auth) y correr `/gentle:models` |
| El picker de OpenRouter muestra muchos modelos | Whitelist no aplicada | La whitelist (`opencode.jsonc` → `provider.openrouter.whitelist`) debería limitar a solo Claude; revisa `~/.config/opencode/opencode.jsonc` |

## Errores de instalación / chezmoi

| Síntoma | Causa | Solución |
|---------|-------|----------|
| `new-videcoding-project` no existe | No aplicado al home | `chezmoi apply .local/bin/new-videcoding-project` |
| `.opencode/agent/` no aparece en `~/scripts/templates/videcoding-base` | chezmoi no gestiona directorios con `.` literal | **Normal**: el comando copia la plantilla desde `sourceDir` (el repo git), no desde `~/scripts`. No afecta al crear proyectos |
| La plantilla no actualiza un proyecto ya creado | La plantilla se copia solo al crear | Los proyectos ya creados se actualizan a mano (o se recrea el proyecto) |

## Regla general

1. `just sync-tracking` → reconcilia el estado.
2. `just status` → mira el tablero.
3. Revisa si es un problema de **flujo** (estados) o de **proveedor** (modelos/credito).
4. Si el worker "dice" que terminó pero no hay commit o el gate falló: desconfía del relato, mira el diff real.
