---
name: videcoding-framework
description: Use when starting a videcoding project, creating a new project with new-videcoding-project, or when the user mentions architect/worker, TDD estricto, dual-write, ROADMAP.md, Project.canvas, Kanvas, SPECS.md, CODESTYLE.md, or the videcoding/vibe-coding workflow. Instructs the agent to read the videcoding AGENTS.md and follow the architect+workers flow (spec first, strict TDD, gates, TASKS+canvas sync).
---

# Framework de Videcoding (Architect + Workers)

Flujo para proyectos donde un **architect** (modelo potente) define specs y descompone en tareas atómicas, y los **workers** (modelo barato) las ejecutan con TDD estricto. Diseñado para videcoding de larga duración (overnight runs).

## 1. Leer la fuente de verdad

Al iniciar, el agente DEBE leer primero el framework del proyecto:

- `AGENTS.md` de la raíz del proyecto (orquestación: roles, TDD estricto, gates, dual-write). Es agnóstico a la herramienta (opencode / pi).
- Si el proyecto se creó con `new-videcoding-project`, la estructura ya existe: `SPECS.md`, `README.md`, `CODESTYLE.md`, `ROADMAP.md`, `TASKS.md`, `Project.canvas` + `canvas-tool.py`, `Justfile`, `.opencode/agent/`.

## 2. Roles

| Rol | Modelo | Hace | NO hace |
|-----|--------|------|---------|
| **Architect** | potente (Claude Sonnet/Opus) | genera/refina los 4 docs, descompone roadmap, Fase 0/1 (scaffolding), revisa workers | implementar features |
| **Worker** | barato (deepseek-v4-flash) | UNA tarea atómica a la vez (WIP=1), TDD estricto, gates, dual-write, commits | diseñar, expandir scope, auto-verificarse |

## 3. Reglas de ejecución (obligatorias)

- **SDD primero**: sin código hasta que `SPECS.md` y el roadmap estén aprobados por el humano.
- **TDD estricto**: RED (test que falla) → GREEN (mínimo) → REFACTOR. `just test` en verde.
- **Gates**: `just lint` y `just test` antes de cada commit; formatear antes de commitear.
- **No self-verify**: el worker deja en cian (`finish`); el humano pone el verde.
- **Dual-write**: cada cambio de estado se refleja en `TASKS.md` Y `Project.canvas` (vía `canvas-tool.py`, NUNCA editar el JSON a mano) en el mismo commit. Si divergen → `just sync-tracking`.
- **Curse of instructions**: el worker lee SOLO la sección relevante de `SPECS.md` por tarea.
- **Commits**: Conventional Commits en inglés, un checkpoint = un commit.

## 4. Notas por agente

- **opencode**: subagentes en `.opencode/agent/` (`architect` = Claude, `worker` = barato). Switch con Tab.
- **pi**: `/sdd-init` una vez; el flujo SDD del Gentleman se alinea con este workflow.

## 5. Verificación

- [ ] `AGENTS.md` leído (fuente de verdad)
- [ ] Specs aprobadas antes de codear (checkpoint humano)
- [ ] TDD estricto aplicado en cada tarea
- [ ] Gates pasados y dual-write verificado antes de cada commit
