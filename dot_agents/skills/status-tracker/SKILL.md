---
name: status-tracker
description: "Use at session start or end: read the active phase status.md (panel) and git log -1, then update status.md, session-log.md, and answer 'qué toca hoy' with the daily kata contract."
---

# Skill: Operational Status Tracker (`status-tracker`)

## Purpose
Manages session synchronization, daily challenge framing, and progress tracking across roadmaps.

## Instructions

### 1. Determinar el roadmap activo
Modelo estacional: semestre (sep–nov 2026) = `learning-path`; vacaciones (dic 2026–feb 2027) = `ai-learning-path`. El roadmap de IA está pausado durante el semestre. Consultar `learning-path/calendario.md` para el bloque actual.

### 2. Inicio de sesión
1. Leer el `status.md` de la **fase activa** (determinada desde `calendario.md`) — el **panel operativo** (semana actual, día de hoy, próxima sesión, blockers). No leer el `session-log.md` completo.
1b. Leer `.agents/knowledge-map.md` (nivel del concepto del día) y `.agents/teaching-contract.md` (contrato).
2. `git log -1` en el repo activo (learning-path o projects/mysh según contexto).
3. **NO escanear** todo el repositorio ni el vault de Obsidian. Leer notas/docs puntuales solo bajo demanda.

### 3. Responder "¿qué toca hoy?"
1. Determinar el día: Kata (Lun–Vie) · Milestone/Reto (Sáb) · Tick (Dom).
1b. Antes de delegar, revisar en `knowledge-map.md` si el tema raíz de hoy
    lleva ≥2 sesiones consecutivas en nivel 0 sin subconceptos en nivel ≥1.
    Si es así, aplicar el "Presupuesto Anti-Estancamiento en Nivel 0" de
    `teaching-contract.md` ANTES de continuar con el flujo normal.
1c. Si es domingo, antes de delegar el contrato, correr el algoritmo de
    selección de `teaching-contract.md` § Domingo y pasar el concepto elegido
    como contexto explícito (no dejar que el contrato re-decida distinto).
2. **Delegar el contrato completo a `<repo>/.agents/teaching-contract.md`** (single source: Paso 0 → escalera → pistas → cierre). Este skill NO duplica el contrato.
3. **Fallback:** si `<repo>/.agents/teaching-contract.md` NO existe en el repo activo, decirlo y preguntar al usuario. PROHIBIDO volver al Modo A/B antiguo en silencio.

### 4. Cierre de sesión
1. Marcar `[ ]` → `[x]` en la fila del día de `status.md`.
2. Añadir una entrada al `session-log.md` (append-only, más reciente arriba) con lo aprendido: archivos, concepto, lecciones, commits.
3. Actualizar `status.md → Historial` con un resumen de 2 líneas de la sesión.
4. Dejar `status.md → Próxima sesión` actualizado para el día siguiente.

### 5. Cierre de semana (Dom)
- Archivar las filas completadas de la semana en el `session-log.md`.
- Abrir la semana siguiente en `status.md` usando el Backlog de conceptos previos (`README.md → Recovery Plan`).
- Dejar un resumen de 2 líneas de la semana pasada en `status.md → Historial`.
