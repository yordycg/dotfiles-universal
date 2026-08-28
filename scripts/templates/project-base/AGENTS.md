# AGENTS.md — Guía para agentes

Guía para que agentes de IA trabajen en este proyecto.

## Cómo trabajar aquí

- El proyecto sigue un ciclo de Fases 0-7 descritas en `TASKS.md`. Léelo antes de empezar a trabajar.
- Proceso recomendado: completar la documentación (Fases 0-4) **antes** de escribir código.

## Estructura del proyecto

- `docs/` → Documentación técnica (Fases 1-6 + ADR en `docs/05-decisiones.md`).
- `meta/` → Fases 0 y 7 (comercial/contexto). **Git-ignored: no commitear.**
- `src/` → Código fuente del proyecto.
- `tests/` → Pruebas del proyecto.

## Convenciones

- Commits: [Conventional Commits](https://www.conventionalcommits.org/) en inglés (`feat:`, `fix:`, `docs:`, `chore:`).
- Secretos: usar variables de entorno desde `.env` (copiar de `.env.example`). Nunca hardcodear claves en el código.

## Comandos

Cuando exista el `Justfile`, usar:
- `just dev` — arrancar en desarrollo
- `just test` — ejecutar pruebas
- `just up` — levantar servicios (compose)
