# 󰒄 Guía de Workflow Remoto: Nodo N ➔ Nodo 1
> **Estado:** Actualizado (Junio 2026) · **Arquitectura:** Remote-First (Senior Lean)

Esta guía detalla cómo trabajar en múltiples proyectos alojados en el **Servidor (Nodo 1)** desde tu **Laptop/Desktop (Nodo N)** de forma transparente, segura y eficiente.

---

## 1. Conexión Instantánea (El Comando Maestro: `hl`)

Olvida el comando `ssh` tradicional. Usamos un wrapper inteligente que gestiona sesiones de `tmux` automáticamente.

- **Comando:** `hl [sesion]`
- **Qué hace:**
    - Conecta al servidor.
    - Si existe la sesión de tmux, se acopla (`attach`).
    - Si no existe, la crea.
    - Por defecto usa la sesión `main`.
- **Otros comandos de sesión:**
    - `hls`: Lista sesiones de tmux activas en el servidor.
    - `hlk [sesion]`: Mata una sesión específica.

---

## 2. Desarrollo con Live Reload (Localhost en Remoto)

Para ver tu aplicación (web, API, etc.) en tu navegador local como si estuviera corriendo en tu laptop, tienes tres niveles de poder:

### Nivel 1: Puertos Automáticos (SSH Config)
Muchos puertos comunes (3000, 5173, 8080) ya se forwardean automáticamente al ejecutar `hl`.

### Nivel 2: Comando Rápido (`lab-open`)
Si necesitas abrir un puerto que no está en la config de SSH:
```bash
lab-open 8080        # Abre el 8080 del servidor en tu 8080 local
lab-open 8080 3000   # Abre el 8080 del servidor en tu 3000 local
```

### Nivel 3: Función de Shell (`sshfwd`)
Para un túnel silencioso en segundo plano:
```bash
sshfwd 5000          # Crea el túnel y se queda escuchando
```

- **Ver estado:** Usa `sshports` para listar todos los puertos que tienes redirigidos actualmente hacia tu laptop.

---

## 3. Gestión de Contenedores y Logs

No necesitas navegar por carpetas en el servidor para ver qué pasa con tus servicios.

| Comando | Acción |
| :--- | :--- |
| `lps` | (Lab Status) Lista qué contenedores están corriendo y sus puertos. |
| `dlogs <app>` | Ver los logs en tiempo real (follow) de un contenedor remoto. |
| `dexec <app> bash` | Entrar interactivamente a un contenedor en el servidor. |

---

## 4. Navegación Veloz (Workspace Aliases)

Hemos estandarizado los directorios de trabajo para que llegues en 1 segundo:

- `ws`: Ir a la raíz del workspace (`~/workspace`).
- `wk`: Proyectos de **Trabajo** (Work).
- `pr`: Proyectos **Personales**.
- `iv`: Proyectos de **IPVG**.
- `as`: Directorio de **Assets**.

---

## 5. El Flujo Diario Ideal

```bash
# 1. Conexión al servidor (Inicia el día)
hl                   # Entras a tu sesión principal de tmux

# 2. Ir al proyecto
wk                   # Vas a la carpeta de trabajo
cd mi-proyecto
v.                   # Abres Neovim en el directorio actual

# 3. Levantar servicio (dentro de Neovim o Tmux)
npm run dev          # Supongamos que corre en puerto 5173

# 4. Ver en el navegador (en tu laptop)
# Abrir http://localhost:5173

# 5. Si necesitas ver la DB (Beekeeper/DBeaver)
# Conectar a localhost:5432 (el túnel ya está activo por el SSH Config o lab-open)

# 6. Sincronizar cambios de configuración
dsync "chore: update aliases"
```

---

## 6. Secretos y Seguridad

- **Bitwarden:** Usa `bwu` (Bitwarden Unlock) para desbloquear tu bóveda y copiar la contraseña maestra al portapapeles automáticamente.
- **SSH Agent:** Tu llave privada nunca sale de tu laptop. Se reenvía al servidor mediante `ForwardAgent` para que puedas hacer `git push` de forma segura.
