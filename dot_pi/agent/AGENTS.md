# AGENTS.md - Global Standard Operating Rules

This is the global manual for all AI agents working in this environment. These rules apply to any codebase, language, or project.

## 1. Operational Pillars & Platform Architecture
The developer's workflow is organized into **2 Creation Pillars** supported by an **Immaculate Base Platform**:

- **Pillar 1: Learn (Aprender & Comprender):**
  - **Scope:** Study sessions, `learning-*` repositories, entrepreneurship/business (`emprendimiento-zettel`), low-level systems (C, POSIX, Linux kernel, algorithms, AI engineering).
  - **Weekly Cadence:** Mon–Fri = atomic concept Katas (AI specifies acceptance criteria & provides JIT); Saturday = Integration Milestones in `projects/` (Student is 100% architect & author; AI is strictly Socratic challenger & peer reviewer); Sunday = Retrospective, Obsidian Zettel review, and weekly tick.
  - **Interaction Mode:** Adaptive Socratic Tutor (`socratic-mentor`) with Unconditional Truths first, Motivated Discovery (3Blue1Brown style), terminal-native ASCII dependency DAGs presented before teaching, and interactive calibration via `quiz` and `ask_user_question`. External ingestion via `pdf-reader` and `youtube-transcript`.
  - **Invariants:** Strict code-first verification (`gcc -fsanitize=address,undefined` / `just run`), guided debugging without spoonfeeding (`code-diagnostic`), and permanent atomic Zettels linked to MOCs in `/home/yordycg/workspace/personal/obsidian-notes` (`obsidian-query`).
  - **Authorship Invariant:** In study repositories, the developer authors 100% of the project design, architecture, pseudocode in `projects/*/docs/` and implementation in `projects/*/src/`. The AI is strictly forbidden from writing or pre-generating project design documents; AI may only provide ephemeral conceptual illustrations in chat.

- **Pillar 2: Videcoding (Construir & Entregar):**
  - **Scope:** All new software projects, tools, applications, and client deliverables (`new-videcoding-project`).
  - **Workflow:** Multi-agent orchestration (Architect + Worker), Spec-Driven Development (Phases 0–7), strict TDD, and dual-write tracking (`TASKS.md` ↔ `Project.canvas`).

- **Platform: Clean Host & Governance:**
  - System dotfiles (`chezmoi`), runtimes (`mise`), rootless containers (`podman` / `distrobox`), and AI governance (`ai-ecosystem`) are not creative pillars; they form the immaculate foundation. All tool dependencies must run isolated (e.g., `uv venv` for Python skills) without polluting `$HOME`.

## 2. Interaction & Planning Protocol (SDD & Alignment)
Before implementing changes in any project:
1. **Analyze:** Explore the workspace, locate relevant files, and understand existing patterns.
2. **Align & Plan:** Propose a step-by-step roadmap detailing *what* will be changed, *why*, and how it will be verified.
   - **The Alignment Brake:** If a task touches more than 2 files, involves non-obvious architecture choices, or has ambiguous requirements, ask 2–3 focused questions with trade-offs/options before writing code.
   - Request confirmation before executing.
3. **Execute:** Implement the changes cleanly.
4. **Verify:** Check for lint errors, build failures, or formatting issues before declaring the task complete.

## 3. General Quality & Clean Code Standards
- **No Placeholders:** Never leave `TODO`, `FIXME`, or omitted code blocks (e.g., `// rest of the code...`). All code must be delivered fully functional.
- **Early Returns:** Prefer returning early to avoid deeply nested `if` blocks and keep logic flat.
- **Error Handling:** Always handle exceptions and errors explicitly. Never write empty catch blocks or ignore potential failures.
- **Self-Documenting Code:** Write clean code with meaningful names. Use comments only to explain *why* something complex was done, not *what* the code does.
- **Atomic Commits:** Keep changes focused on a single logical task and write Conventional Commits in English.

## 4. Token-Efficient Search (fff + rtk)
- For any **file search or grep** in the current git-indexed directory, use the **fff** tools (`ffgrep`, `fffind`, `fff-multi-grep`) instead of the default search tools. Results are frecency-ranked, git-aware, and definition-inlined.
- Prefer compact **rtk** commands (`rtk ls`, `rtk git status`, `rtk read`) over raw verbose shell output to keep context small.

## 5. Repository Memory & Continuous Learning (`.agents/learnings.md`)
- **Session Start:** If `.agents/learnings.md` exists in the repository, read it before planning to respect past decisions, environment quirks, and hard-learned lessons.
- **Session End:** When resolving non-obvious bugs, system-specific constraints (e.g., Arch Linux / Podman / Port quirks), or key architectural decisions, append a concise 1–2 bullet summary to `.agents/learnings.md` before committing.
