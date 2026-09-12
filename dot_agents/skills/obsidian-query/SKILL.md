---
name: obsidian-query
description: "Use when checking conceptual notes or Obsidian: search and read exclusively inside /home/yordycg/workspace/personal/obsidian-notes, never outside. Also use to WRITE/generate Zettels at session close from structured code comments (@title, @learn, @open_questions, @connect_with), following the technical template and linking to the matching MOC."
---

# Skill: Obsidian Zettelkasten Query & Write (`obsidian-query`)

## Purpose
Enables the AI agent to:
1. **READ:** Search and read conceptual notes from the user's Obsidian Zettelkasten vault (`/home/yordycg/workspace/personal/obsidian-notes`).
2. **WRITE:** Generate new atomic Zettels at session close by parsing the developer's structured code annotations (`@title`, `@phase`, `@learn`, `@open_questions`, `@connect_with`).

## Strict Rules & Execution Guardrails
1. **NO UNBOUNDED SEARCHES:** You are strictly **FORBIDDEN** from running `find` or `grep` on `/home/yordycg`, `/home/yordycg/workspace`, or any parent directory.
2. **STRICT SCOPE:** All search and read operations must be scoped **exclusively** to `/home/yordycg/workspace/personal/obsidian-notes`.
3. **Efficient Commands (Templates):**
   - To find files: `find /home/yordycg/workspace/personal/obsidian-notes -name "*.md"`
   - To search text: `grep -rn "term" /home/yordycg/workspace/personal/obsidian-notes`

---

## Mode 1 — READ (Consultar / Leer Notas)

Use when the developer asks about conceptual notes or you need Obsidian context for a topic.
1. Search exclusively inside the vault (commands above). Never outside.
2. Read the relevant note(s) to answer the question.
3. Cross-reference via `[[links]]` and backlinks when connecting concepts.

---

## Mode 2 — WRITE (Generar Zettel al Cierre de Sesión)

Use at session close in the **code-first** flow. The developer documents their findings directly in the code using structured annotations (`/* ... */` in C/Go, `#` in Python, `--` in SQL).

### 1. Source of Truth: Structured Code Header Block
Read the exercise file and parse the tags:
```c
/*
 * @title: [Título Atómico de la Nota / Idea]
 * @phase: learning-c - week 4, day 4
 * -------------------------------------------------------------------------
 * @learn:
 * 1- [Explicaciones y modelos mentales en las propias palabras del usuario]
 * 2- ...
 *
 * @open_questions:
 * - [Dudas o preguntas abiertas dejadas por el usuario para que la IA resuelva]
 *
 * @connect_with:
 * - [Concepto o MOC A]
 * - [Concepto o MOC B]
 */
```

### 2. Parseo y Mapeo al Template
Sigue estrictamente `600 Templates/Template__Technical-Zettel.md`:
1. **Frontmatter:** `Date`, `Time`, `Tags` (`learning/roadmap`, `theory`, etiqueta de `@phase`).
2. `# Título` — Tomado de `@title` (`<Tema> - <Ámbito>.md`). **Una nota = una idea atómica**.
3. `## Concepto` — Extraído de `@learn`. Explicado en la voz del desarrollador, conservando su modelo mental y terminología.
4. `## Dudas Resueltas` — Extraído de `@open_questions`. **La IA debe resolver las preguntas abiertas durante la sesión** y documentar aquí la respuesta clara y concisa.
5. `## Código Atómico` — Máximo 1–2 bloques mínimos (5–15 líneas) del código real que ilustren el mecanismo exacto.
6. `## Diagrama Conceptual (Mermaid)` — Si el concepto involucra flujo, estados o memoria, incluir el diagrama formal en ` ```mermaid ` (Obsidian lo renderiza nativamente).
7. `## Código Completo` — Enlace al archivo real del repositorio (ej. `file:///home/yordycg/workspace/personal/learning-path/...`).
8. `## Relaciones` — Generado a partir de `@connect_with`:
   - Enlace al MOC temático correspondiente (ej. `[[MOC - Processes]]`, `[[MOC - Signals]]`).
   - Enlaces cruzados a notas atómicas relacionadas (`[[Linux - Fork and Exec]]`).

### 3. Reglas de Calidad
- **Atomicity:** Si el bloque `@learn` cubre dos conceptos independientes que no dependen uno del otro, divide en 2 notas separadas y enlázalas. Nunca mezclar conceptos no relacionados en un solo Zettel.
- **Validación:** El desarrollador aprueba el Zettel generado; no lo escribe desde cero.
