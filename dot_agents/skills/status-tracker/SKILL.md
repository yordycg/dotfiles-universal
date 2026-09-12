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
1. Leer `learning-c/status.md` — el **panel operativo** (semana actual, día de hoy, próxima sesión, blockers). No leer el `session-log.md` completo.
2. `git log -1` en el repo activo (learning-path o projects/mysh según contexto).
3. **NO escanear** todo el repositorio ni el vault de Obsidian. Leer notas/docs puntuales solo bajo demanda.

### 3. Responder "¿qué toca hoy?" (El Contrato de la Kata Diaria — Obligatorio)
Al preguntar "¿qué toca hoy?", **NUNCA** responder con opciones difusas o una lista de 3 ejercicios opcionales. Responder con **La Kata del Día (Un único reto ejecutable)** estructurado exactamente así:

1. **Árbol de Contexto + Milestone Bridge:** Dónde encaja hoy en el roadmap (ej. `OS → Processes → Signals → mysh v1.5`) + **Impacto en el Proyecto del Sábado** (1 oración precisa explicando por qué este concepto es indispensable para el feature o versión del fin de semana en `projects/`).
2. **La Kata del Día (Reto Principal):**
   - **Objetivo:** 1 oración precisa de lo que se va a demostrar hoy en código.
   - **Archivo:** Ruta exacta (ej. `3-expert/07-signals/3-fork-exec-disposition.c`).
   - **Compilación estricta:** `gcc -Wall -Wextra -Werror -pedantic -g -fsanitize=address,undefined <archivo>.c -o <bin>`.
3. **Especificación Técnica (Contrato de Aceptación):**
   - **Syscalls / APIs clave:** Lista explícita de funciones requeridas (ej. `sigaction`, `fork`, `execvp`).
   - **Flujo y comportamiento:** 2–3 pasos exactos de lo que debe ocurrir en ejecución.
   - **Salida esperada y Exit Code:** Lo que debe verse en terminal y el código de salida (`echo $?` o `WIFEXITED`).
   - **Prueba en 1 comando:** Cómo ejecutar y verificar (ej. `./bin && echo $?`).
4. **Recurso Just-in-Time (JIT):**
   - Nombre y enlace (man page, Beej, TLPI). Se abre **SOLO** si el código falla o no recuerdas la firma de la función.
5. **Plantilla de Comentarios Estructurada:**
   - Entregar el bloque de cabecera con anotaciones para el archivo de código:
     ```c
     /*
      * @title: [Título de la lección / Zettel]
      * @phase: [Fase / semana / día]
      * -------------------------------------------------------------------------
      * @learn:
      * 1- [Lo que descubriste y aprendiste con tus palabras]
      *
      * @open_questions:
      * - [Dudas o preguntas abiertas para que el mentor las resuelva]
      *
      * @connect_with:
      * - [Concepto o MOC con el que conecta]
      */
     ```
6. *(Opcional)* **Stretch Goal (Romper el Código):**
   - Un único caso de borde o experimento destructivo adicional para probar una vez superado el reto principal.

> **Regla de oro:** El Zettel de Obsidian lo genera la IA al cierre parseando `@title`, `@learn`, `@open_questions` (resolviéndolas) y `@connect_with`. No es tarea del usuario.

### 4. Cierre de sesión
1. Marcar `[ ]` → `[x]` en la fila del día de `status.md`.
2. Añadir una entrada al `session-log.md` (append-only, más reciente arriba) con lo aprendido: archivos, concepto, lecciones, commits.
3. Actualizar `status.md → Historial` con un resumen de 2 líneas de la sesión.
4. Dejar `status.md → Próxima sesión` actualizado para el día siguiente.

### 5. Cierre de semana (Dom)
- Archivar las filas completadas de la semana en el `session-log.md`.
- Abrir la semana siguiente en `status.md` usando el Backlog de conceptos previos (`README.md → Recovery Plan`).
- Dejar un resumen de 2 líneas de la semana pasada en `status.md → Historial`.
