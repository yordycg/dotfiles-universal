# Flujo de Trabajo y Arquitectura de Proyectos

Este documento define el estándar arquitectónico para cualquier proyecto desarrollado bajo esta infraestructura. El objetivo principal es garantizar la reproducibilidad total, permitir la colaboración sin fricciones y mantener el sistema anfitrión aislado de dependencias.

El ciclo de vida y la estructura de un proyecto se dividen en las siguientes capas:

## 1. Capa de Estilo e Inteligencia (Análisis Estático)
Esta capa define *cómo* se escribe el código. Debe vivir en la raíz del repositorio para que editores (Neovim, VS Code, etc.) puedan leer las reglas y aplicarlas en tiempo real (autocompletado, formateo al guardar).

- **.editorconfig**: Define reglas básicas y agnósticas (2 espacios, tabulaciones, fin de línea). Es el estándar base.
- **Formateadores y Linters**: Reglas estrictas específicas del lenguaje (ej. `.prettierrc`, `ruff.toml`, `.eslintrc.json`).
- **Dependencias Locales**: Las herramientas de análisis estático se instalan exclusivamente como dependencias de desarrollo del proyecto (`package.json`, `requirements-dev.txt`), **nunca globales**.

## 2. Capa de Infraestructura de Servicios (Dependencias Externas)
Define los servicios que la aplicación necesita consumir para funcionar correctamente en un entorno local.

- **Herramienta:** Podman Compose / Docker Compose.
- **Archivo:** `compose.yaml` (Ubicado en la raíz del proyecto).
- **Alcance:** Bases de datos (PostgreSQL), Cachés (Redis), Brokers de mensajes (RabbitMQ).
- **Ventaja:** Cualquier desarrollador puede levantar la topología de red y persistencia con un solo comando, de forma idéntica a producción.

## 3. Capa de Entorno de Ejecución (Aplicación)
Define *dónde* y *cómo* compila y corre el código de la aplicación, aislando completamente las dependencias a nivel de sistema operativo.

- **Herramienta:** Dockerfiles.
- **Archivos:** `Dockerfile` (producción) y opcionalmente `Dockerfile.dev` (desarrollo local).
- **Ventaja:** Si la aplicación requiere librerías específicas de C o versiones antiguas de un lenguaje, estas viven y mueren exclusivamente dentro del contenedor. El host permanece inmaculado.

## 4. Capa de Orquestación y Configuración (Developer Experience)
Para que las tres capas anteriores funcionen en armonía sin que el desarrollador deba memorizar comandos complejos, se estandariza el uso de dos elementos clave:

### Gestion de Variables de Entorno
- **.env.example**: Plantilla documentada que se comitea al repositorio. Muestra todas las variables necesarias sin revelar secretos.
- **.env**: Archivo ignorado por Git (debe estar en el `.gitignore`) que contiene los secretos reales para uso del `compose.yaml` o el framework de turno.

### Gestion de Secretos con SOPS
Para proyectos que requieren maxima seguridad y reproducibilidad de secretos:
1. Usar **SOPS** con **age** para cifrar archivos de entorno.
2. El archivo cifrado se guarda como `secrets.enc.env` y se sube al repositorio.
3. El archivo original `.env` se añade al `.gitignore`.
4. El Task Runner (`Justfile`) debe incluir una tarea para descifrar el archivo al vuelo.

### Task Runner (Simplificacion de Comandos)
Se debe utilizar un orquestador de tareas para documentar y estandarizar los comandos del proyecto.
- **Herramienta Preferida:** `Just` (mediante un archivo `Justfile`).
- **Alternativa Tradicional:** `Make` (mediante un `Makefile`).
- **Uso:** En lugar de recordar comandos como `podman compose -f compose.yaml up --build -d`, el desarrollador solo ejecuta `just up` o `make dev`. Esto crea un punto de entrada uniforme (entrypoint) para cualquier persona que toque el proyecto.

---

## Ejemplo: Inicialización de Proyecto Estándar

Una estructura base sana para un nuevo proyecto debería verse así:

```text
proyecto/
  ├── .env.example
  ├── .gitignore
  ├── .editorconfig
  ├── .prettierrc         # (O el linter/formateador correspondiente)
  ├── compose.yaml        # (Bases de datos / Caché)
  ├── Dockerfile          # (Entorno de la app)
  ├── Justfile            # (Ej. comandos: up, down, lint, test)
  └── src/                # (Código fuente)
```
