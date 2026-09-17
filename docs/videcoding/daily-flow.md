# Videcoding — Flujo de día a día

Cómo operar el proyecto en el día a día: la sesión humana de retomar, el ciclo de verificación y el protocolo de ejecución overnight.

## Sesión de mañana / retomar

1. **`just status`** → estado del tablero en terminal y métricas.
2. **Revisa lo que dejó el worker overnight** (si corrió): `git log --oneline -20` para ver los commits.
3. **Verifica tareas terminadas** (tu poder exclusivo): `just verify <ID>`. Al verificar, las tareas dependientes se desbloquean automáticamente hacia `to_do`.
4. **`just ready`** → tareas disponibles listas para tomar (con dependencias cumplidas).
5. **Delega al worker**: en opencode, cambia a `worker` (Tab) y dale: *"Ejecuta la siguiente tarea ready con TDD estricto y gates."*
6. **Revisa**: cuando el worker deja en revisión (`just finish <ID>`), revisa el commit/diff contra los criterios de aceptación de `docs/specs.md`. KINO → `just verify <ID>`. SLOP → reabrir (`just pause <ID>` / nueva tarea).

> **No self-verify:** el worker nunca se marca verde. El verde lo pones tú con `just verify <ID>`. `tasks.yaml` es la única fuente de verdad.

## Ciclo de verificación humana (loop)

```
worker hace tarea → review → [tú] revisas → verify (done) → se desbloquean dependencias → just ready → siguiente
                                └─> no → rework (pause / tarea nueva)
```

El gate pre-commit ya garantiza: lint OK + tests OK + integridad del grafo en `tasks.yaml`. Tu revisión es de **contenido** (¿cumple los criterios de aceptación del spec?), no de sintaxis.

## Protocolo overnight

Ideal para videcoding "máquina de código" de larga duración:

**Antes de irte:**
1. `docs/specs.md` y roadmap aprobados (checkpoint humano hecho).
2. Fase 0 completada (Justfile con `lint`/`test` reales — si no, el gate es vacío).
3. Al menos una tarea aprobada y lista (`just ready`) para que el worker arranque solo.
4. Confirmar que el worker usa **DeepSeek** (barato) — nunca dejar Claude corriendo solo.

**Al día siguiente:**
1. `git log` para ver el progreso por commits (el historial es el plan).
2. `just status` para ver tareas terminadas y en revisión.
3. Revisa tareas en revisión → `just verify <ID>` → desbloquea automáticamente el siguiente lote.
4. Si algo quedó a medias o con commits raros, revisa el diff y decide (rework/descarte).

## Reglas de oro

- **WIP=1**: el worker ejecuta una tarea a la vez. No le des varias tareas en paralelo en la misma sesión.
- **Un commit = un checkpoint** con su test. El historial de git es el registro del plan.
- **SSOT**: `tasks.yaml` es la única fuente de verdad; `TASKS.md` se regenera automáticamente con cada comando o con `just render`.
- **Contexto fresco**: para tareas largas, abre una sesión nueva del worker por lote (evita la pudrición de contexto).
