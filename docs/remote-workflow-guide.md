# 󰒄 Guía de Workflow Remoto: Nodo N ➔ Nodo 1
> **Estado:** Implementado (Mayo 2026) · **Arquitectura:** Remote-First

Esta guía detalla cómo trabajar en múltiples proyectos alojados en el **Servidor (Nodo 1)** desde tu **Laptop/Desktop (Nodo N)** de forma transparente, segura y con latencia cero.

---

## 1. Conexión Instantánea e Inteligente

Gracias al **SSH Multiplexing** y al **Session Manager**, la conexión es el centro de todo.

- **Comando principal:** `homelab`
- **Qué sucede tras bambalinas:**
    1. Se abre un socket persistente (`ControlMaster`). Las siguientes terminales conectarán en <50ms.
    2. Se activan automáticamente los túneles para puertos web (3000, 5173, 8080, etc.).
    3. Se lanza el **Smart Session Manager**:
        - Listará tus sesiones de Tmux activas.
        - Escaneará `~/workspace` en el servidor buscando proyectos reales (`.git`).
        - Puedes filtrar con `fzf` y saltar directo al código.

---

## 2. Desarrollo con Live Reload (Port Forwarding)

No necesitas configurar nada. El archivo `~/.ssh/config` gestiona los puertos por ti.

1. **En el Servidor:** Inicias tu app (ej. `npm run dev` en el puerto 5173).
2. **En tu Laptop:** Abre el navegador en `http://localhost:5173`.
3. **Resultado:** Verás la aplicación corriendo en el servidor como si fuera local.

**Puertos pre-configurados:**
- `3000`: Node/React
- `5173`: Vite/Frontend
- `8000`: Python/FastAPI
- `8080`: APIs/Admin
- `4321`: Astro
- `5432`: PostgreSQL (Acceso directo desde DBeaver local)

---

## 3. Gestión de Contenedores desde Local

Hemos inyectado funciones en tu shell para que no tengas que entrar al servidor para tareas rutinarias de Docker:

| Comando | Acción |
| :--- | :--- |
| `homestat` | Reporte rápido de qué contenedores están vivos y cuánto disco queda. |
| `dlogs <app>` | Ver los logs en tiempo real (follow) de un contenedor remoto. |
| `dexec <app> bash` | Entrar interactivamente a un contenedor en el servidor. |
| `sshports` | Listar qué puertos están actualmente redirigidos a tu laptop. |
| `sshfwd <port>` | ¿Necesitas un puerto extra? Mapealo al instante sin reiniciar SSH. |

---

## 4. Bases de Datos: El patrón de Seguridad

Por seguridad, nuestras bases de datos en el servidor solo escuchan en `127.0.0.1` (loopback).

### Para conectar con DBeaver/Beekeeper:
1. Crea una conexión a `localhost` puerto `5432`.
2. **Importante:** Asegúrate de tener una sesión SSH abierta con el servidor (`homelab`).
3. El túnel SSH automático se encargará de conectar tu herramienta local con el contenedor "oculto" en el servidor.

---

## 5. Gestión de Secretos y SSH-Agent

El flujo de llaves es automático:
- Al abrir tu terminal local, el `ssh-agent` se inicia y carga tu identidad.
- Al conectar al servidor, tu identidad se **reenvía (ForwardAgent)**.
- **Resultado:** Puedes hacer `git push/pull` dentro del servidor usando las llaves de tu laptop, sin necesidad de copiar llaves privadas al servidor.

---

## 6. Sincronización de Entorno

Si haces un cambio en tus alias o configuración de Neovim:
1. En tu laptop: `dots` (alias para entrar a la carpeta de chezmoi) -> Editas -> `just save`.
2. El comando `dsync` se encarga de:
    - Guardar y subir tus cambios a GitHub.
    - Conectar al servidor y ejecutar `just update` automáticamente.
3. **Tu entorno es idéntico en todas las máquinas al instante.**

---

## Resumen del Flujo Diario

```bash
# 1. Empieza el día
homelab              # Eliges tu proyecto -> Entras a Tmux+Nvim

# 2. Lanzas el entorno (dentro de Tmux)
npm run dev          # App corriendo en puerto 5173

# 3. Trabajas desde local
# Navegador en localhost:5173
# DBeaver conectado a localhost:5432

# 4. Revisas logs desde otra terminal en tu Laptop
dlogs mi-app-web

# 5. Guardas todo
dsync "feat: mejoras en el workflow"
```
