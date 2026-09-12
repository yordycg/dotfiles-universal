---
name: obsidian-query
description: "Use when checking conceptual notes or Obsidian: search and read exclusively inside /home/yordycg/workspace/personal/obsidian-notes, never outside. Also use to WRITE/generate Zettels at session close from code comments (.c), following the technical template and linking to the matching MOC."
---

# Skill: Obsidian Zettelkasten Query & Write (`obsidian-query`)

## Purpose
Enables the AI agent to (1) search and read conceptual notes from the user's Obsidian Zettelkasten vault (`/home/yordycg/workspace/personal/obsidian-notes`) and (2) generate new Zettels at session close from the developer's code comments.

## Strict Rules & Execution Guardrails
1. **NO UNBOUNDED SEARCHES:** You are strictly **FORBIDDEN** from running `find` or `grep` on `/home/yordycg`, `/home/yordycg/workspace`, or any parent directory.
2. **STRICT SCOPE:** All search and read operations must be scoped **exclusively** to `/home/yordycg/workspace/personal/obsidian-notes`.
3. **Efficient Commands (Templates):**
   - To find files: `find /home/yordycg/workspace/personal/obsidian-notes -name "*.md"`
   - To search text: `grep -rn "term" /home/yordycg/workspace/personal/obsidian-notes`

## Mode 1 — READ (consultar/leer notas)

Use when the developer asks about conceptual notes or you need Obsidian context for a topic.

1. Search exclusively inside the vault (commands above). Never outside.
2. Read the relevant note(s) to answer the question.
3. Cross-reference via `[[links]]` and backlinks when connecting concepts.

## Mode 2 — WRITE (generar Zettel al cierre de sesión)

Use at session close, in the **code-first** flow: the developer writes comments in the `.c` (APRENDÍ / DUDA RESUELTA / CONECTA CON), and the AI generates the Obsidian note from them.

1. **Source of truth = the `.c` comments.** Read the exercise file and extract:
   - What the developer actually learned (APRENDÍ)
   - Doubts resolved (DUDA RESUELTA)
   - Connections to the project / other concepts (CONECTA CON)
2. **Follow the template** `600 Templates/Template__Technical-Zettel.md`:
   - Frontmatter: `Date`, `Time`, `Tags` (`learning/roadmap`, `theory`).
   - `# Título` — atomic note title (`<Tema> - <Ámbito>.md`). Una nota = una idea.
   - `## Concepto` — explain as if teaching a junior, in the developer's words/voice.
   - `## Código Atómico` — max 1-2 minimal blocks that illustrate the idea.
   - `## Código completo` — link to the real `.c` file in learning-path (`file:///...`).
   - `## Relaciones` — links to the matching MOC + related notes.
3. **Connect to the hierarchy (MOC):**
   - Link the new note to its `MOC - <Tema>.md` (e.g., `[[MOC - Processes]]`).
   - Link to the parent concept hub when relevant (e.g., `[[OS Processes]]`).
4. **Respect atomicity:** if the content answers more than one question, split into 2 notes and link them. Never append unrelated content to an existing note.
5. **The developer reviews/approves** the generated note; they do not write it from scratch.
