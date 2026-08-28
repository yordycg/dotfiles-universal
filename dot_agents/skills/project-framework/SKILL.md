---
name: project-framework
description: Use when starting a new project, generating initial project documentation, or scaffolding a new repository. Also use when the user mentions phases (Fase 0-7), Escalamiento, TASKS.md, project template, or framework-project. Instructs the agent to read the user's personal framework note, determine project size (Chico/Mediano/Grande), and complete documentation BEFORE writing code.
---

# Framework de Proyectos (Framework Project)

Guía para arrancar cualquier proyecto siguiendo el framework personal del usuario: documentación primero, código después.

## 1. Leer la fuente de verdad

Al iniciar un proyecto nuevo, el agente DEBE leer primero el framework:

**Fuente principal (nota de Obsidian):**
`~/workspace/personal/obsidian-notes/000 Zettelkasten/Framework Project.md`

Si esa ruta no existe, buscar por nombre con fallback:
- `~/workspace/personal/obsidian-notes/**/Framework Project.md`
- `~/workspace/personal/obsidian-notes/**/Framework Freelance.md` (nombre antiguo)

**Fallback (plantilla embebida en chezmoi):**
`~/.local/share/chezmoi/scripts/templates/project-base/` (TASKS.md + docs + meta)

## 2. Determinar el tamaño del proyecto

Usar la **Guía de Escalamiento** del framework:

| Tamaño | Duración | Qué implica |
|---|---|---|
| Chico | < 20 hrs | Mínima documentación: flowchart simple, flujo principal 10-15 líneas, camino feliz + 2-3 errores |
| Mediano | 20-80 hrs | DER básico, 2-3 funciones críticas, destructivas + 3-5 unit tests |
| Grande | +80 hrs | DER completo, casos de uso, secuencia, suite de tests + rendimiento |

> **Regla de oro:** ante la duda, tratar como **Chico**. Es más fácil agregar diseño después que recuperar horas perdidas.

## 3. Proceso (SDD: Spec-Driven Development)

El primer paso de cualquier proyecto es la documentación, NO el código. Seguir las fases en orden:

1. **Fase 0** — `meta/00-propuesta-cotizacion.md`: contexto (freelance/personal/IPVG), tamaño, viabilidad, objetivos. (Comercial, no versionado en repo público.)
2. **Fase 1** — `docs/01-discovery.md`: dolor principal, restricciones, criterios de éxito.
3. **Fase 2** — `docs/02-requerimientos.md`: MVP, RF/RNF, historias de usuario, Out of Scope.
4. **Fase 3** — `docs/03-arquitectura.md`: diagrama de flujo, DER (según tamaño).
5. **Fase 4** — `docs/04-pseudocodigo.md`: pseudocódigo del flujo + casos de borde.
6. **Etapa 2 (DevOps)** — Justfile/Dockerfile/compose por tamaño; `.editorconfig` y `.env.example` ya vienen en la plantilla.
7. **Fase 5 (construcción)** — código según el pseudocódigo, ADR en `docs/05-decisiones.md`.
8. **Fase 6** — `docs/06-testing.md`: pruebas según tamaño.
9. **Fase 7** — `meta/07-entrega-postventa.md`: cierre según contexto.

## 4. Reglas al asistir

- NO escribir código hasta que las Fases 0-4 estén documentadas (o el usuario lo pida explícitamente).
- Rellenar los campos `[placeholder]` de cada doc, no dejarlos vacíos.
- No crear `Dockerfile`/`compose.yaml`/`Justfile` pre-generados: son tarea de aprendizaje del usuario (Etapa 2 de TASKS.md), solo se crean cuando él lo pida.
- Los archivos de `meta/` no se versionan (están en `.gitignore`): no sugerir commitearlos.
- Si el usuario crea el proyecto con `new-project` o `just new-project`, la estructura ya existe; el trabajo es completar los documentos en orden.

## 5. Verificación

- [ ] Framework leído (fuente de verdad o fallback)
- [ ] Tamaño del proyecto definido y comunicado
- [ ] Fase 0 completada (contexto + objetivos)
- [ ] Documentación de Fases 1-4 lista antes de cualquier código
