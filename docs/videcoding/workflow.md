# Videcoding Workflow (Architect + Workers)

Este documento define el flujo de **videcoding** de la infraestructura: una alternativa al
[`project-workflow.md`](../project-workflow.md) para proyectos donde el objetivo es dejar que
los agentes construyan gran parte del código de forma autónoma y de larga duración, sin perder
el control del rumbo.

> **Guías operativas:** para poner esto en marcha ver [`setup.md`](./setup.md) (inicio),
> [`daily-flow.md`](./daily-flow.md) (día a día) y [`troubleshooting.md`](./troubleshooting.md)
> (errores).

## Filosofía

Un solo agente conversacional pierde foco en proyectos largos. La solución consensuada por la
comunidad (véase [recursos](#recursos)) es separar **quién piensa** del **quién ejecuta**:

- **Architect** (modelo potente): especificación, descomposición en tareas atómicas, scaffolding.
- **Worker** (modelo barato): implementa tarea a tarea con **TDD estricto** y gates.

Ambos se apoyan en un contrato escrito (`SPECS.md`) y un plan (`ROADMAP.md`) versionados en git,
de modo que el estado nunca vive en el contexto de un chat: sobrevive a cualquier agente.

## Los 5 documentos de verdad

| Archivo | Qué es | Quién |
|---------|--------|-------|
| `SPECS.md` | Comportamiento esperado, entradas/salidas, casos borde, criterios de aceptación | architect |
| `README.md` | Visión del producto terminado | architect |
| `CODESTYLE.md` | Reglas de estilo + ejemplo real heredado | architect (Fase 0) |
| `ROADMAP.md` | Tareas atómicas con IDs y dependencias | architect |
| `TASKS.md` + `Project.canvas` | Tracking de ejecución (siempre sincronizados) | worker + humano |

## Flujo de trabajo

1. **Ideación** — itera la idea en un chat (o con el architect en plan mode).
2. **Especificación** — el architect genera los 4 documentos + descompone el roadmap.
3. **Checkpoint humano** — apruebas specs y roadmap (y el tablero `Project.canvas`).
4. **Fase 0/1** — el architect ejecuta el skeleton: tooling, linter, Justfile, estilo heredado.
5. **Ejecución** — workers consumen tareas atómicas:
   - `just ready` → elige la de mayor prioridad sin dependencias pendientes (WIP=1).
   - `python3 canvas-tool.py "Project.canvas" start <ID>` + marca en `TASKS.md`.
   - TDD estricto (RED → GREEN → REFACTOR) y `just test` en verde.
   - `just lint` + `just test` (gates) → formatear → commit convencional.
   - `python3 canvas-tool.py "Project.canvas" finish <ID>` + marca en revisión en `TASKS.md`.
6. **Verificación humana** — tú pones el verde en el tablero; se desbloquean dependencias.
7. **Iterar** — se puede dejar "overnight": los workers continúan mientras el historial de git es el plan.

## Dual-write (TASKS.md ↔ Project.canvas)

Cada transición de tarea se refleja en **ambos** sitios en el mismo commit:

| Estado | `Project.canvas` | `TASKS.md` |
|--------|------------------|------------|
| Propuesta | 🟣 purple (`propose`) | `- [ ]` en "Propuestas" |
| Aprobada | 🔴 red (humano) | `- [ ]` en "Pendientes" |
| En curso | 🟠 orange (`start`) | `- [ ]` + `— ▶ en curso` |
| En revisión | 🔵 cyan (`finish`) | `- [ ]` + `— 🔵 en revisión` |
| Hecha | 🟢 green (**solo humano**) | `- [x]` |

`just sync-tracking` reconcilia desfases; `just gate` (o el hook pre-commit) lo verifica en cada commit.
Nunca editar `Project.canvas` a mano: siempre vía `canvas-tool.py`.

## Agentes

| Rol | Modelo | Proveedor | Uso |
|-----|--------|-----------|-----|
| **Architect** | Claude Sonnet | OpenRouter | Spec, roadmap, Fase 0/1, review |
| **Worker** | DeepSeek v4-flash | DeepSeek directo | Implementación con TDD estricto |
| **Scout** | Gemini Flash | Google | Exploración/investigación |

- **opencode** — subagentes en `.opencode/agent/`: `architect` (Claude vía OpenRouter),
  `worker` (DeepSeek directo) y `scout` (Gemini). Se cambian con `Tab`. El worker es el
  agente predeterminado. El built-in `explore` usa Gemini (capa barata). OpenRouter está
  restringido por whitelist a solo Claude (guardrail de coste).
- **pi** — el mismo `AGENTS.md` de la raíz es la fuente de verdad. Correr `/sdd-init` una vez;
  el flujo SDD del Gentleman se alinea (`apply` = worker con TDD, `verify` = gates). Asignar
  modelos por fase con `/gentle:models`: design=Claude (OpenRouter), implement=DeepSeek,
  explore=Gemini.

## Crear un proyecto

```bash
new-videcoding-project <nombre>
```

> **Sigue el checklist de [`setup.md`](./setup.md)**: instalar el hook pre-commit, verificar
> modelos, registrar el proyecto en pi y completar la Fase 0 (Justfile con lint/test reales).
>
> Nota: el tablero visual usa Obsidian. Si no lo abres, el flujo funciona igual vía `TASKS.md`
> y la CLI (`just status`, `just ready`).

## Recursos

- [sammwy — método SPECS.md/ROADMAP.md (vibe coding machine)](https://x.com/sammwy/status/2086480601201135641)
- [XMihura/Kanvas — tablero visual para humanos + agentes](https://github.com/XMihura/Kanvas)
- [FlorianBruniaux/claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide)
  (metodologías SDD/TDD/BDD, topologías multi-agente, "verification gap")
- [Gentleman-Programming/gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) y
  [gentle-pi](https://github.com/Gentleman-Programming/gentle-pi) (SDD/OpenSpec, model routing por fase)
