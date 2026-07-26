# [Nombre del Proyecto]

Breve descripción de una línea: qué hace este proyecto y para quién.

## ¿Qué hace?

Explicación de 2-3 líneas del problema que resuelve.

## Guía de Desarrollo y Tareas

Consulta el archivo [TASKS.md](TASKS.md) para ver la hoja de ruta del proyecto y la lista de tareas por fase.

---

## Requisitos e Instalación

### Requisitos Previos
- `direnv` (para variables de entorno automáticas)
- `just` (orquestador de comandos)
- `podman` o `docker` (opcional si usa contenedores)

### Inicialización Local

```bash
# 1. Autorizar entorno con direnv
direnv allow .

# 2. Configurar variables de entorno
cp .env.example .env

# 3. Iniciar entorno con just
just up
```

## Estructura del Proyecto

```
├── TASKS.md     → Hoja de ruta y checklist de tareas por fase
├── docs/        → Documentación detallada por fase (Fases 0 a 7)
├── src/         → Código fuente del proyecto
├── tests/       → Pruebas automatizadas
├── Justfile     → Recetas de comandos del proyecto
└── compose.yaml → Definición de servicios (Podman/Docker)
```

## Licencia / Autor

[Tu Nombre] — [Contacto]
