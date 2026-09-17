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

Ambos se apoyan en un contrato escrito (`docs/specs.md`) y un plan (`docs/roadmap.md`) versionados en git,
de modo que el estado nunca vive en el contexto de un chat: sobrevive a cualquier agente.

## Fuentes de verdad

| Archivo | Qué es | Quién |
|---------|--------|-------|
| `docs/specs.md` | Comportamiento esperado, entradas/salidas, casos borde, criterios de aceptación | architect |
| `README.md` | Visión del producto terminado | architect |
| `.agents/codestyle.md` | Reglas de estilo + ejemplo real heredado | architect (Fase 0) |
| `docs/roadmap.md` | Tareas atómicas con IDs y dependencias | architect |
| `tasks.yaml` | Tracking de ejecución y grafo de dependencias (**SSOT único**) | worker + humano |
| `TASKS.md` | Vista humana y diagrama Mermaid generado automáticamente | automático (`render`) |

## Flujo de trabajo

1. **Ideación** — itera la idea en un chat (o con el architect en plan mode).
2. **Especificación** — el architect genera los documentos en `docs/` y `.agents/` + descompone el roadmap en `tasks.yaml`.
3. **Checkpoint humano** — apruebas specs y apruebas las primeras tareas con `just approve <ID>`.
4. **Fase 0/1** — el architect ejecuta el skeleton: tooling, linter, Justfile, estilo heredado.
5. **Ejecución** — workers consumen tareas atómicas:
   - `just ready` → elige la de mayor prioridad sin dependencias pendientes (WIP=1).
   - `just start <ID>` → pasa la tarea a `doing`.
   - TDD estricto (RED → GREEN → REFACTOR) y `just test` en verde.
   - `just lint` + `just test` (gates) → formatear → commit convencional.
   - `just finish <ID>` → marca en revisión (`review`) y regenera `TASKS.md`.
6. **Verificación humana** — tú ejecutas `just verify <ID>`; pasa a `done` y desbloquea en cascada las dependientes.
7. **Iterar** — se puede dejar "overnight": los workers continúan mientras el historial de git es el plan.

## SSOT (`tasks.yaml` y vistas derivadas)

`tasks.yaml` es la **única fuente de verdad** del estado y dependencias:

| Estado | Comando CLI | Quién lo controla |
|--------|-------------|-------------------|
| Propuesta | `just task propose ...` (🟣) | architect / humano |
| Aprobada / To Do | `just approve <ID>` (🔴) | humano |
| En curso | `just start <ID>` (🟠) | worker (WIP=1) |
| En revisión | `just finish <ID>` (🔵) | worker |
| Hecha | `just verify <ID>` (🟢) | **solo humano** |

`TASKS.md` y los diagramas Mermaid se regeneran automáticamente en cada transición.
`just gate` (o el hook pre-commit) valida la ausencia de ciclos y la integridad del grafo antes de cada commit.

## Agentes

| Rol | Modelo | Proveedor | Uso |
|-----|--------|-----------|-----|
| **Architect** | Claude Sonnet | OpenRouter | Spec, roadmap, Fase 0/1, review |
| **Worker** | DeepSeek v4-flash | DeepSeek directo | Implementación con TDD estricto |
| **Scout** | Gemini Flash | Google | Exploración/investigación |

- **opencode** — subagentes en `.agents/agents/`: `architect.md`, `worker.md` y `scout.md`.
  El comando `just setup` crea automáticamente el symlink `.opencode/agent -> ../.agents/agents`.
  Se cambian con `Tab`. El worker es el agente predeterminado.
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
