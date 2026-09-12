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

### 3. Responder "¿qué toca hoy?" (Bifurcación Obligatoria según el Día)
Al preguntar "¿qué toca hoy?", **NUNCA** responder con opciones difusas o una lista de 3 ejercicios opcionales. El agente DEBE evaluar si hoy corresponde a una **Kata de Concepto (Lunes a Viernes)** o a un **Milestone de Proyecto (Sábado / Días de Hito)**:

---

#### 🟢 Modo A: Kata Diaria de Concepto (Lunes a Viernes)
Diseñado para la asimilación atómica guiada de fundamentos. Estructurar la respuesta exactamente así:

1. **Árbol de Contexto + Milestone Bridge:** Dónde encaja hoy en el roadmap (ej. `OS → Processes → Signals → mysh v1.5`) + **Impacto en el Proyecto del Sábado** (1 oración precisa explicando por qué este concepto es indispensable para el feature o versión del fin de semana en `projects/`).
2. **La Kata del Día (Reto Principal):**
   - **Objetivo:** 1 oración precisa de lo que se va a demostrar hoy en código.
   - **Archivo:** Ruta exacta (ej. `3-expert/07-signals/3-fork-exec-disposition.c`).
   - **Compilación estricta:** `gcc -Wall -Wextra -Werror -pedantic -g -fsanitize=address,undefined <archivo>.c -o <bin>` o `just run <archivo>`.
3. **Especificación Técnica (Contrato de Aceptación):**
   - **Syscalls / APIs clave:** Lista explícita de funciones requeridas (ej. `sigaction`, `fork`, `execvp`).
   - **Flujo y comportamiento:** 2–3 pasos exactos de lo que debe ocurrir en ejecución.
   - **Salida esperada y Exit Code:** Lo que debe verse en terminal y el código de salida (`echo $?` o `WIFEXITED`).
   - **Prueba en 1 comando:** Cómo ejecutar y verificar (ej. `./bin && echo $?`).
4. **Recurso Just-in-Time (JIT):**
   - Nombre y enlace (man page, Beej, TLPI). Se abre **SOLO** si el código falla o no recuerdas la firma de la función.
5. **Plantilla de Comentarios Estructurada:**
   - Entregar el bloque de cabecera con anotaciones para el archivo de código (`/* @title ... */`).
6. *(Opcional)* **Stretch Goal (Romper el Código):**
   - Un único caso de borde en `exercises/` del concepto para experimentar solo tras superar el reto principal.

> **Regla de oro de Katas:** El Zettel de Obsidian lo genera la IA al cierre parseando `@title`, `@learn`, `@open_questions` (resolviéndolas) y `@connect_with`.

---

#### 🟡 Modo B: Milestone de Integración de Proyecto (Sábado / Días de Hito en `projects/`)
**Invariante de Cero Cucharas en Diseño:** En días de proyecto, la IA tiene **ESTRICTAMENTE PROHIBIDO** pre-diseñar la arquitectura, sugerir la solución, entregar especificaciones de código o redactar pseudocódigo. El alumno es el 100% autor y arquitecto.

Estructurar la respuesta como **Apertura de Diseño Socrático**:

1. **El Hito Objetivo:** Versión a alcanzar (ej. `mysh v1.5`) y ruta del proyecto (`projects/<proyecto>/`).
2. **Puente de Transferencia Semanal:** Inventario de los conceptos vistos de Lunes a Viernes y pregunta de impacto:
   - *"¿Cómo rompe o desafía lo que aprendiste esta semana sobre [X] la arquitectura actual de tu proyecto?"*
3. **Fase 1 — Encargo de Diseño al Alumno (`projects/<p>/docs/`):**
   - Indicar al alumno que cree o abra su archivo de diseño (ej. `projects/<p>/docs/pseudocode-vX.Y.md`).
   - Recordar la estructura que **él debe redactar**:
     - *Problema:* ¿Qué falla o qué limitación tiene la versión actual?
     - *Opciones y Trade-offs:* ¿Qué 2–3 alternativas de diseño existen y cuál elige?
     - *Pseudocódigo Propio:* Su modelo de ejecución paso a paso.
     - *Checklist de Pruebas:* Cómo verificará que funciona.
4. **Pausa para Peer Review Socrático:**
   - La IA se detiene y espera a que el alumno comparta su propuesta de diseño.
   - La IA desafía el diseño con preguntas sobre casos de borde (carreras, señales, memoria, timeouts) **antes** de que el alumno implemente en `src/`.
5. **Fase 2 — Implementación, Verificación y Tag:**
   - El alumno codifica 100% en `src/`, verifica con herramientas runtime (`code-diagnostic`) y etiqueta (`git tag -a vX.Y`).

### 4. Cierre de sesión
1. Marcar `[ ]` → `[x]` en la fila del día de `status.md`.
2. Añadir una entrada al `session-log.md` (append-only, más reciente arriba) con lo aprendido: archivos, concepto, lecciones, commits.
3. Actualizar `status.md → Historial` con un resumen de 2 líneas de la sesión.
4. Dejar `status.md → Próxima sesión` actualizado para el día siguiente.

### 5. Cierre de semana (Dom)
- Archivar las filas completadas de la semana en el `session-log.md`.
- Abrir la semana siguiente en `status.md` usando el Backlog de conceptos previos (`README.md → Recovery Plan`).
- Dejar un resumen de 2 líneas de la semana pasada en `status.md → Historial`.
