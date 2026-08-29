# Videcoding — Flujo de día a día

Cómo operar el proyecto en el día a día: la sesión humana de retomar, el ciclo de verificación y el protocolo de ejecución overnight.

## Sesión de mañana / retomar

1. **`just status`** → estado del tablero (`Project.canvas`) y `TASKS.md`.
2. **Revisa lo que dejó el worker overnight** (si corrió): `git log --oneline -20` para ver los commits.
3. **Marca verdes** (tu único poder exclusivo): en Obsidian, las tareas cian → verde. En markdown: `- [ ]` → `- [x]` en `TASKS.md`. Al marcar verdes se desbloquean dependencias.
4. **`just ready`** → tareas disponibles (rojas con dependencias cumplidas).
5. **Delega al worker**: en opencode, cambia a `worker` (Tab) y dale: *"Ejecuta la siguiente tarea ready de ROADMAP.md con TDD estricto y gates."*
6. **Revisa**: cuando el worker deja en cian (`finish`), revisa el commit/diff contra los criterios de aceptación de `SPECS.md`. KINO → verde. SLOP → reabrir (`pause` / nueva tarea).

> **No self-verify:** el worker nunca se marca verde. El verde lo pones tú. Si ves un `- [x]` en `TASKS.md` que el canvas no tiene en verde, es un error del worker: `just sync-tracking` lo revierte.

## Ciclo de verificación humana (loop)

```
worker hace tarea → cian → [tú] revisas → verde → se desbloquean dependencias → just ready → siguiente
                            └─> no → rework (pause / tarea nueva)
```

El gate pre-commit ya garantiza: lint OK + tests OK + TASKS↔canvas sincronizados. Tu revisión es de **contenido** (¿cumple los criterios de aceptación del spec?), no de sintaxis.

## Protocolo overnight

Ideal para videcoding "máquina de código" de larga duración:

**Antes de irte:**
1. `SPECS.md` y roadmap aprobados (checkpoint humano hecho).
2. Fase 0 completada (Justfile con `lint`/`test` reales — si no, el gate es vacío).
3. Al menos una tarea roja lista (`just ready`) para que el worker arranque solo.
4. Confirmar que el worker usa **DeepSeek** (barato) — nunca dejar Claude corriendo solo.

**Al día siguiente:**
1. `git log` para ver el progreso por commits (el historial es el plan).
2. `just status` + `just sync-tracking` (por si hubo desfases).
3. Revisa tareas cian → marca verdes → desbloquea el siguiente lote.
4. Si algo quedó a medias o con commits raros, revisa el diff y decide (rework/descarte).

## Reglas de oro

- **WIP=1**: el worker ejecuta una tarea a la vez. No le des varias tareas en paralelo en la misma sesión.
- **Un commit = un checkpoint** con su test. El historial de git es el registro del plan.
- **Dual-write**: cada transición se refleja en `TASKS.md` y en el canvas en el mismo commit. Si divergen → `just sync-tracking`.
- **Contexto fresco**: para tareas largas, abre una sesión nueva del worker por lote (evita la pudrición de contexto).
