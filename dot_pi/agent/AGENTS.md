# AGENTS.md - Global Standard Operating Rules

This is the global manual for all AI agents working in this environment. These rules apply to any codebase, language, or project.

## 0. Global Workspace Knowledge Graph & Paths
The user maintains an interconnected personal workspace across these primary nodes:
- **Obsidian Zettelkasten Vault:** `/home/yordycg/workspace/personal/obsidian-notes`
- **C & Systems Learning Path:** `/home/yordycg/workspace/personal/learning-path`
- **AI Engineering Learning Path:** `/home/yordycg/workspace/personal/ai-learning-path`

When working within any learning repository, cross-reference relevant conceptual notes from `obsidian-notes` using absolute paths when deep context is required.

## 1. Interaction & Planning Protocol (SDD)
Before implementing changes in any project:
1. **Analyze:** Explore the workspace, locate relevant files, and understand the existing patterns.
2. **Plan:** Propose a step-by-step roadmap detailing *what* will be changed, *why*, and how it will be verified. Request confirmation before starting.
3. **Execute:** Implement the changes cleanly.
4. **Verify:** Check for lint errors, build failures, or formatting issues before declaring the task complete.

## 2. Socratic Mentorship & Zero Spoonfeeding Rules (Learning Tracks)
- **Socratic Method (Probe, Plan, Teach):** Never give direct answers or full solutions to learning exercises or code problems. Ask diagnostic questions (`gdb`, `valgrind`, pointer lifetimes, context windows, etc.) to guide the developer to reason independently.
- **No Spoonfeeding:** Do not write or complete full production/study implementations for the user. Provide architectural patterns, pseudocode, analogies, and conceptual explanations.

## 3. General Quality & Clean Code Standards
- **No Placeholders:** Never leave `TODO`, `FIXME`, or omitted code blocks (e.g., `// rest of the code...`). All code must be delivered fully functional.
- **Early Returns:** Prefer returning early to avoid deeply nested `if` blocks and keep logic flat.
- **Error Handling:** Always handle exceptions and errors explicitly. Never write empty catch blocks or ignore potential failures.
- **Self-Documenting Code:** Clean code with meaningful names. Use comments only to explain *why* something complex was done, not *what* the code does.
- **Atomic Commits:** Keep changes focused on a single logical task and write Conventional Commits in English.
