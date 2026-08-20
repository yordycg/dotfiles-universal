# Hoja de Ruta y Tareas del Proyecto — [Nombre]

> **Regla de oro:** No pases a la siguiente fase sin completar los requerimientos de la fase actual.

---

## Etapa 1: Análisis y Diseño (Fases 0 a 4) — ¡Hacer ANTES de programar!

- [ ] **Fase 0: Prospección y Propuesta** (`docs/00-propuesta-cotizacion.md`)
  - [ ] Definir alcance, restricciones y presupuesto/meta.
  - [ ] Confirmar viabilidad y tiempos.
- [ ] **Fase 1: Descubrimiento** (`docs/01-discovery.md`)
  - [ ] Identificar el dolor principal del cliente/usuario.
  - [ ] Definir 2-3 criterios de éxito medibles.
- [ ] **Fase 2: Especificación de Requerimientos** (`docs/02-requerimientos.md`)
  - [ ] Definir Requerimientos Funcionales (RF-01, RF-02...).
  - [ ] Definir lo que queda **FUERA del alcance** (Out of Scope).
- [ ] **Fase 3: Arquitectura** (`docs/03-arquitectura.md`)
  - [ ] Crear diagrama de flujo (Mermaid / Excalidraw).
  - [ ] Definir modelo de datos o estructura de archivos.
- [ ] **Fase 4: Pseudocódigo y Lógica** (`docs/04-pseudocodigo.md`)
  - [ ] Escribir pseudocódigo del flujo principal.
  - [ ] Definir manejo de errores y casos borde.

---

## Etapa 2: Aprovisionamiento y DevOps — Preparar la cancha

- [ ] **Configuración de Entorno Local**
  - [ ] Configurar `.env.example` y crear `.env` local.
  - [ ] Configurar `.envrc` y autorizar con `direnv allow .`
- [ ] **Infraestructura y Contenedores**
  - [ ] Crear `Dockerfile` adaptado al runtime del proyecto.
  - [ ] Crear `compose.yaml` (si requiere BD o servicios auxiliares).
- [ ] **Orquestación de Comandos**
  - [ ] Configurar `Justfile` (`just up`, `just dev`, `just test`).
- [ ] **Git & Repositorio Remoto**
  - [ ] Confirmar `.gitignore` adecuado.
  - [ ] Commit inicial de estructura y push a GitHub.

---

## Etapa 3: Construcción (Fase 5) — Manos al código

- [ ] Crear estructura inicial dentro de `src/`.
- [ ] Implementar módulos principales según la Fase 4.
- [ ] Registros ADR en `docs/05-decisiones.md` para cada decisión técnica importante.

---

## Etapa 4: Pruebas y Calidad (Fase 6)

- [ ] Probar casos de camino feliz (`docs/06-testing.md`).
- [ ] Probar casos destructivos / errores de red / datos nulos.
- [ ] Escribir pruebas unitarias/integración si aplica.

---

## Etapa 5: Entrega y Cierre (Fase 7)

- [ ] Completar `README.md` con instrucciones reales de instalación y uso.
- [ ] Desplegar o generar artefactos finales.
- [ ] Demostración o validación final.
