---
name: status-tracker
description: "Use at session start or end: read the active phase status.md (panel) and git log -1, then update status.md, session-log.md, and answer 'qué toca hoy' with the daily code-first contract."
---

# Skill: Operational Status Tracker (`status-tracker`)

## Purpose
Manages session synchronization and progress tracking across roadmaps.

## Instructions

### 1. Determinar el roadmap activo
Modelo estacional: semestre (sep–nov 2026) = `learning-path`; vacaciones (dic 2026–feb 2027) = `ai-learning-path`. El roadmap de IA está pausado durante el semestre. Consultar `learning-path/calendario.md` para el bloque actual.

### 2. Inicio de sesión
1. Leer `learning-c/status.md` — el **panel operativo** (semana actual, día de hoy, próxima sesión, blockers). No leer el `session-log.md` completo.
2. `git log -1` en el repo activo (learning-path o projects/mysh según contexto).
3. **NO escanear** todo el repositorio ni el vault de Obsidian. Leer notas/docs puntuales solo bajo demanda.

### 3. Responder "¿qué toca hoy?" (Contrato diario — obligatorio)
Al preguntar "¿qué toca hoy?", responder **siempre** con los 6 elementos:

1. **Árbol de contexto** (OS → Process → fork → mysh): dónde encaja el concepto de hoy en el mapa grande.
2. **Contexto breve de 2 min**: QUÉ hace el concepto, **sin el CÓMO**. Ej: "`fork()` crea un nuevo proceso. Tú decides cómo."
3. **Archivo `.c` a crear** con ruta exacta + comando gcc (`-Wall -Wextra -g`).
4. **Recurso just-in-time** (nombre + link): se abre SOLO si el código falla. No verlo antes.
5. **3 ejercicios progresivos opcionales** en `exercises/01-*.c`, `02-*.c`, `03-*.c` (básico → aplicado → integrado con el proyecto).
6. **Plantilla de comentarios** para el `.c` (`APRENDÍ` / `DUDA RESUELTA` / `CONECTA CON`).

> El Zettel de Obsidian lo genera la IA al cierre desde los comentarios del `.c`. No es tarea del usuario.

### 4. Cierre de sesión
1. Marcar `[ ]` → `[x]` en la fila del día de `status.md`.
2. Añadir una entrada al `session-log.md` (append-only, más reciente arriba) con lo aprendido: archivos, concepto, lecciones, commits.
3. Actualizar `status.md → Historial` con un resumen de 2 líneas de la sesión.
4. Dejar `status.md → Próxima sesión` actualizado para el día siguiente.

### 5. Cierre de semana (Dom)
- Archivar las filas completadas de la semana en el `session-log.md`.
- Abrir la semana siguiente en `status.md` usando el Backlog de conceptos previos (`README.md → Recovery Plan`).
- Dejar un resumen de 2 líneas de la semana pasada en `status.md → Historial`.
