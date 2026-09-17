# Videcoding — Troubleshooting

Errores comunes, su causa y la solución. Si el problema no está aquí, revisa el estado del proyecto con `just status`.

## Errores del flujo

| Síntoma | Causa | Solución |
|---------|-------|----------|
| Commit **bloqueado** por el gate (hook pre-commit) | `tasks.yaml` tiene ciclos o tareas `to_do`/`doing` con dependencias incompletas | Corre `python3 bin/task.py check` para ver el error exacto y ajusta `tasks.yaml` |
| `just start <ID>` rechazado por **WIP=1** | Ya existe otra tarea en curso (`doing`) | Finaliza (`just finish <ID>`) o pausa (`just task pause <ID>`) la tarea previa |
| `just start <ID>` rechazado por **dependencias** | La tarea tiene dependencias que no están en `done` | Corre `just show <ID>` para ver qué tareas la bloquean y complétalas primero |
| El gate **pasa sin verificar nada** | Los targets `lint`/`test` del Justfile siguen siendo placeholders de Fase 0 | El architect debe llenarlos en Fase 0 (ver `setup.md` §7) |
| `bin/task.py` no encuentra `tasks.yaml` | Se ejecuta desde fuera de la raíz del proyecto | Corre los comandos desde la raíz del proyecto (`tasks.yaml` está ahí) |
| `just` no encontrado | Herramienta no instalada | Instalar `just` (ver matriz de paquetes de la infraestructura) |
| `python3` no encontrado | Entorno sin Python 3 | `bin/task.py` corre con Python 3 stdlib; instalar python3 |

## Errores de modelos / proveedores

| Síntoma | Causa | Solución |
|---------|-------|----------|
| `anthropic/claude-sonnet-4.6` **no aparece** en `/models` | Slug cambiado (nueva versión de Claude) o auth de OpenRouter ausente | `opencode auth login` → OpenRouter; luego `/models` y ajusta `.agents/agents/architect.md` |
| OpenRouter responde **402** | Sin crédito | Recargar en el dashboard de OpenRouter (solo se usa para Claude) |
| OpenRouter responde **429** | Rate limit | Esperar y reintentar; revisa el dashboard |
| Modelo del architect no disponible en pi | `models.json` sin el override de OpenRouter o sin auth en pi | Registrar OpenRouter en pi (`/connect` o auth) y correr `/gentle:models` |
| El picker de OpenRouter muestra muchos modelos | Whitelist no aplicada | La whitelist (`opencode.jsonc` → `provider.openrouter.whitelist`) debería limitar a solo Claude; revisa `~/.config/opencode/opencode.jsonc` |

## Errores de instalación / chezmoi

| Síntoma | Causa | Solución |
|---------|-------|----------|
| `new-videcoding-project` no existe | No aplicado al home | `chezmoi apply .local/bin/new-videcoding-project` |
| `.agents/` en proyectos nuevos | Template oficial en GitHub | **Normal**: el comando clona directamente el repo template `yordycg/template-videcoding` con su estructura limpia `.agents/` |
| La plantilla no actualiza un proyecto ya creado | La plantilla se copia solo al crear | Los proyectos ya creados se actualizan a mano (o se recrea el proyecto) |

## Regla general

1. `just status` → mira el estado del tablero en terminal.
2. `python3 bin/task.py check` → valida el grafo y detecta posibles ciclos o dependencias rotas.
3. Revisa si es un problema de **flujo** (estados) o de **proveedor** (modelos/crédito).
4. Si el worker "dice" que terminó pero no hay commit o el gate falló: desconfía del relato, mira el diff real.
