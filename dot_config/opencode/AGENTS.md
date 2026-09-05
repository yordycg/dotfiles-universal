# AGENTS.md - Global Standard Operating Rules

This is the global manual for all AI agents working in this environment. These rules apply to any codebase, language, or project.

## 1. Interaction & Planning Protocol (SDD & Alignment)
Before implementing changes in any project:
1. **Analyze:** Explore the workspace, locate relevant files, and understand existing patterns.
2. **Align & Plan:** Propose a step-by-step roadmap detailing *what* will be changed, *why*, and how it will be verified.
   - **The Alignment Brake:** If a task touches more than 2 files, involves non-obvious architecture choices, or has ambiguous requirements, ask 2–3 focused questions with trade-offs/options before writing code.
   - Request confirmation before executing.
3. **Execute:** Implement the changes cleanly.
4. **Verify:** Check for lint errors, build failures, or formatting issues before declaring the task complete.

## 2. General Quality & Clean Code Standards
- **No Placeholders:** Never leave `TODO`, `FIXME`, or omitted code blocks (e.g., `// rest of the code...`). All code must be delivered fully functional.
- **Early Returns:** Prefer returning early to avoid deeply nested `if` blocks and keep logic flat.
- **Error Handling:** Always handle exceptions and errors explicitly. Never write empty catch blocks or ignore potential failures.
- **Self-Documenting Code:** Write clean code with meaningful names. Use comments only to explain *why* something complex was done, not *what* the code does.
- **Atomic Commits:** Keep changes focused on a single logical task and write Conventional Commits in English.

## 3. Token-Efficient Search (fff + rtk)
- For any **file search or grep** in the current git-indexed directory, use the **fff** tools (`ffgrep`, `fffind`, `fff-multi-grep`) instead of the default search tools. Results are frecency-ranked, git-aware, and definition-inlined.
- Prefer compact **rtk** commands (`rtk ls`, `rtk git status`, `rtk read`) over raw verbose shell output to keep context small.

## 4. Repository Memory & Continuous Learning (`.agents/learnings.md`)
- **Session Start:** If `.agents/learnings.md` exists in the repository, read it before planning to respect past decisions, environment quirks, and hard-learned lessons.
- **Session End:** When resolving non-obvious bugs, system-specific constraints (e.g., Arch Linux / Podman / Port quirks), or key architectural decisions, append a concise 1–2 bullet summary to `.agents/learnings.md` before committing.
