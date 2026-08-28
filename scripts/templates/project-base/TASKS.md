# Hoja de Ruta y Tareas del Proyecto — [Nombre]

> **Regla de oro:** No pases a la siguiente fase sin completar los requerimientos de la fase actual.

---

## Cómo usar esta plantilla

1. **Define el tamaño del proyecto** (Chico / Mediano / Grande) con la tabla de la Guía de Escalamiento antes de llenar nada. Esto determina cuánto detalle le metes a las Fases 3, 4 y 6.

| Tamaño | Ejemplo | Duración típica | Fase 3 (Arquitectura) | Fase 4 (Pseudocódigo) | Fase 6 (Testing) |
|---|---|---|---|---|---|
| Chico | Script, scraper simple, automatización de Excel | < 20 hrs | Flowchart simple, nada de UML formal | Solo el flujo principal, 10-15 líneas | Camino feliz + 2-3 casos de error a mano |
| Mediano | Web app con DB, dashboard, integración 2-3 APIs | 20-80 hrs | DER básico + 1 diagrama de flujo. Casos de uso solo si > 2 tipos de usuario | Flujo principal + 2-3 funciones críticas | Camino feliz + destructivas + 3-5 unit tests |
| Grande | Sistema multi-modo, roles, integraciones complejas | +80 hrs | DER completo, casos de uso, secuencia si hay APIs | Todas las funciones no triviales | Suite de tests + rendimiento con datos reales |

> **Regla práctica:** Si dudas entre Chico y Mediano, trátalo como **Chico** y ajusta sobre la ejecución. Es más fácil agregar diseño después que recuperar horas perdidas.

2. **Llena los archivos en orden.** Cada doc tiene al inicio un campo `Tamaño del proyecto` — repítelo en todos para no perder contexto.
3. En `03-arquitectura`, `04-pseudocodigo` y `06-testing`, borra las secciones que no apliquen al tamaño elegido (evita el "documento a medio llenar").

### Mapeo Fase → Archivo

| Fase | Archivo | Objetivo en una línea |
|---|---|---|
| 0 | `meta/00-propuesta-cotizacion.md` | Conseguir el proyecto y protegerte antes de escribir código |
| 1 | `docs/01-discovery.md` | Entender el problema real de negocio |
| 2 | `docs/02-requerimientos.md` | Aterrizar el problema en funcionalidades y límites (scope) |
| 3 | `docs/03-arquitectura.md` | Dibujar el mapa del sistema antes de codear |
| 4 | `docs/04-pseudocodigo.md` | Resolver la lógica pesada en español antes de sintaxis |
| — | `docs/05-decisiones.md` | Registro de decisiones técnicas (ADR) |
| 5 | (construcción — ver Etapa 2/3 abajo) | Checklist de arranque de entorno y disciplina de código |
| 6 | `docs/06-testing.md` | Plan de pruebas según tamaño del proyecto |
| 7 | `meta/07-entrega-postventa.md` | Cierre profesional + README + condiciones post-entrega |

---

## Etapa 1: Análisis y Diseño (Fases 0 a 4) — ¡Hacer ANTES de programar!

- [ ] **Fase 0: Prospección y Propuesta** (`meta/00-propuesta-cotizacion.md`)
  - [ ] Definir contexto (freelance / personal / IPVG), tamaño y alcance.
  - [ ] Confirmar viabilidad, tiempos y (si aplica) condiciones de pago/entrega.
- [ ] **Fase 1: Descubrimiento** (`docs/01-discovery.md`)
  - [ ] Identificar el dolor principal del cliente/usuario.
  - [ ] Definir 2-3 criterios de éxito medibles.
- [ ] **Fase 2: Especificación de Requerimientos** (`docs/02-requerimientos.md`)
  - [ ] Definir Requerimientos Funcionales (RF-01, RF-02...) con criterios de aceptación.
  - [ ] Definir lo que queda **FUERA del alcance** (Out of Scope).
- [ ] **Fase 3: Arquitectura** (`docs/03-arquitectura.md`)
  - [ ] Crear diagrama de flujo (Mermaid / Excalidraw).
  - [ ] Definir modelo de datos o estructura de archivos (según tamaño).
- [ ] **Fase 4: Pseudocódigo y Lógica** (`docs/04-pseudocodigo.md`)
  - [ ] Escribir pseudocódigo del flujo principal.
  - [ ] Definir manejo de errores y casos borde.

---

## Etapa 2: Aprovisionamiento y DevOps — Preparar la cancha

> Aprende haciendo: cada archivo se crea a mano (no viene pre-generado, salvo los agnósticos). Revisa `docs/project-workflow.md` para el estándar arquitectónico completo.

- [ ] **Agnósticos (ya vienen en la plantilla)**
  - [ ] Verificar `.editorconfig` (estilo base) y `.env.example` (variables sin secretos).
- [ ] **Variables de Entorno y Secretos**
  - [ ] Copiar `.env.example` a `.env` y configurar valores reales (el `.env` ya está en `.gitignore`).
  - [ ] *(Opcional, proyectos con secretos críticos)* Cifrar con SOPS + age en `secrets.enc.env`.
- [ ] **Orquestación de Comandos — Justfile** *(Chico: opcional · Mediano/Grande: sí)*
  - [ ] Crear `Justfile` con al menos `just up`, `just dev`, `just test` — evita memorizar comandos complejos.
- [ ] **Infraestructura y Contenedores** *(solo Mediano/Grande)*
  - [ ] Crear `compose.yaml` si requiere BD/caché/broker (PostgreSQL, Redis, RabbitMQ).
  - [ ] Crear `Dockerfile` (y opcionalmente `Dockerfile.dev`) para el runtime del proyecto.
- [ ] **Git & Repositorio Remoto**
  - [ ] Confirmar `.gitignore` adecuado (incluye `meta/` y `.env`).
  - [ ] Commit inicial de estructura y push a GitHub.

---

## Etapa 3: Construcción (Fase 5) — Manos al código

- [ ] Crear estructura inicial dentro de `src/`.
- [ ] Implementar módulos principales según la Fase 4 (entrada → lógica → salida).
- [ ] Gestión segura de secretos: nunca hardcodear claves; usar `.env`.
- [ ] Disciplina de git: commits pequeños y descriptivos (Conventional Commits).
- [ ] Registros ADR en `docs/05-decisiones.md` para cada decisión técnica importante.

---

## Etapa 4: Pruebas y Calidad (Fase 6)

- [ ] Probar casos de camino feliz (`docs/06-testing.md`).
- [ ] Probar casos destructivos / errores de red / datos nulos.
- [ ] Escribir pruebas unitarias/integración si aplica (según tamaño).

---

## Etapa 5: Entrega y Cierre (Fase 7)

- [ ] Completar `README.md` con instrucciones reales de instalación y uso.
- [ ] Desplegar o generar artefactos finales.
- [ ] Demostración o validación final contra criterios de éxito.
- [ ] Cierre por contexto (`meta/07-entrega-postventa.md`): cobro / lecciones / rúbrica.
