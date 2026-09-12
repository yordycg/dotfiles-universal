---
name: emprendimiento-zettel
description: Use when running founder/entrepreneurship/business study sessions or writing Obsidian notes about startup topics. Reads the vault before generating to avoid duplicate and ghost links, then persists atomic Zettels at session close. Scope is exclusively /home/yordycg/workspace/personal/obsidian-notes. Do NOT use for technical/code learning sessions (use obsidian-query).
---

# Skill: Zettel de Emprendimiento (`emprendimiento-zettel`)

Complementa a `obsidian-query` (técnico) para el eje **fundador desde cero**. El
conocimiento vive en el vault; la cadencia/estado vive en el repo
`~/workspace/personal/emprendimiento` (`AGENTS.md`, `operating.md`, `status.md`).

## Guardrails estrictos

1. **SCOPE ESTRICTO:** búsquedas y lecturas SOLO dentro de
   `/home/yordycg/workspace/personal/obsidian-notes`. Prohibido `find`/`grep` en
   `/home/yordycg`, `/home/yordycg/workspace` o cualquier directorio padre.
2. **Comandos permitidos:** `find /home/yordycg/workspace/personal/obsidian-notes -name "*.md"`
   y `grep -rn "term" /home/yordycg/workspace/personal/obsidian-notes`.

## Modo READ — antes de generar contenido (SIEMPRE)

Antes de responder a una sesión de emprendimiento o de generar una nota:

1. Leer `000 Zettelkasten/MOC - Emprendimiento.md` (hub del dominio).
2. Buscar duplicados del concepto: `grep -rn "<concepto>" <vault>` y revisar notas
   existentes relevantes (`Startup.md`, `Ideas.md`, y atómicas del eje).
3. Si un `[[Concepto]]` a mencionar NO existe como nota real → es link fantasma:
   o materializarlo como nota atómica, o no linkearlo. Nunca dejar `[[algo]]` sin respaldo.
4. Anclar la sesión al contexto: preguntar qué ya sabe, qué lo confunde y qué **decisión
   concreta** necesita tomar con este tema (evita contenido genérico duplicado).

## Modo WRITE — persistir Zettel al cierre de sesión

1. **Destilar del diálogo**, no transcribir. La conversación es *inbox*; solo lo que
   sobrevive se vuelve nota atómica permanente.
2. **Template:** `600 Templates/Template__Emprendimiento-Zettel.md`. Respetar su estructura:
   frontmatter (`Date`, `Time`, `Tags: learning/roadmap, emprendimiento`), `Concepto`,
   `Capa Negocio`, `Capa Fundador`, `Compromiso` (UNA acción con fecha — campo obligatorio),
   `Relaciones`. Cero código, cero secciones técnicas.
3. **Atomicidad:** una nota = una idea. Si el contenido responde a más de una pregunta,
   partir en 2 notas y enlazarlas. La exploración multi-tema de un día NO es una nota:
   se destila.
4. **Persistir:** escribir la nota en `000 Zettelkasten/` con nombre `<Concepto> - <Ámbito>.md`
   (estilo del vault). Actualizar el `MOC - Emprendimiento.md` (agregar link en el eje que
   corresponda: Negocio o Fundador). Verificar que el frontmatter de la nota use tags `emprendimiento`.
5. **Backfill de semilla:** si el tema ya existía como esbozo (ej. `Startup.md`), enlazar en
   lugar de duplicar; integrar y limpiar cuando corresponda.
6. **Commit (opcional, con aprobación del usuario):** commitear en el repo del vault con el
   estilo del log (`feat(vault): ...` / `feat(zettelkasten): ...`).

## Cierre de sesión

- Registrar en `~/workspace/personal/emprendimiento/status.md`: fecha, tema, compromiso y
  la **pregunta abierta** (semilla del tema de mañana).
- Recordar que el usuario revisa/aprueba la nota generada; él no la escribe desde cero.
