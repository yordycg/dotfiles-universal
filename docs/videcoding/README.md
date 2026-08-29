# Videcoding — Flujo Architect + Workers

**Videcoding** es el flujo de desarrollo de esta infraestructura donde un **architect** (modelo potente) define las especificaciones y descompone el trabajo en tareas atómicas, y los **workers** (modelo barato) las ejecutan una a una con **TDD estricto**. Diseñado para sesiones de larga duración (incluso overnight), manteniendo el control humano del rumbo.

## Índice

| Doc | Contenido |
|-----|-----------|
| [`workflow.md`](./workflow.md) | Concepto: filosofía, 5 docs de verdad, dual-write, agentes, recursos |
| [`setup.md`](./setup.md) | **Checklist de inicio**: pasos manuales al crear/arrancar un proyecto |
| [`daily-flow.md`](./daily-flow.md) | **Flujo de día a día**: sesión humana, verificación, protocolo overnight |
| [`troubleshooting.md`](./troubleshooting.md) | **Errores comunes**: síntoma → causa → solución |

## Stack de agentes y modelos

| Rol | Modelo | Proveedor | Uso |
|-----|--------|-----------|-----|
| **Architect** | Claude Sonnet | OpenRouter | Spec, roadmap, Fase 0/1, review |
| **Worker** | DeepSeek v4-flash | DeepSeek directo | Implementación con TDD estricto |
| **Scout** | Gemini Flash | Google | Exploración/investigación |

## Quick links

- **Crear proyecto:** `new-videcoding-project <nombre>` (ver [`setup.md`](./setup.md))
- **Estado del tablero:** `just status` · `just ready`
- **Sincronizar TASKS↔canvas:** `just sync-tracking`
- **Gate pre-commit:** `just gate` (o `just install-hooks` para el hook automático)
- **Plantilla fuente:** `scripts/templates/videcoding-base/`
