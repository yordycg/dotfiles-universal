# Estado del Proyecto y Problemática de Bootstrap (2026-05-30)

## Resumen del Estado Actual
Estamos migrando el **Nodo 2 (Desktop Windows 11 + WSL Ubuntu 24.04)** a la arquitectura universal de dotfiles gestionada por `chezmoi`. 

- **Windows**: Identidad "sembrada" manualmente en `.config/age/key.txt` y `.ssh/id_ed25519`. Chezmoi está inicializado pero con errores de ejecución.
- **WSL (Ubuntu 24.04)**: Instalado y con `chezmoi` binario disponible, pero sin configuración aplicada debido a fallos en la inyección de identidad y ejecución de scripts cruzados.

---

## ❌ Problemática Crítica: El error de "Win32 Application"

### Síntoma
Al ejecutar `chezmoi apply` en Windows PowerShell, el proceso falla inmediatamente al intentar procesar scripts de Linux:
```text
chezmoi: run_after_92-setup-tailscale.sh: fork/exec C:/Users/yordycg/AppData/Local/Temp/...92-setup-tailscale.sh: %1 is not a valid Win32 application
```

### Diagnóstico Técnico
1. **Ciclo de Vida de Chezmoi**: Chezmoi extrae todos los archivos que empiezan por `run_` a una carpeta temporal de Windows (`AppData/Local/Temp`) **antes** de evaluar completamente las reglas de exclusión de `.chezmoignore` o los condicionales internos del template.
2. **Conflicto de Ejecución**: Windows intenta ejecutar el archivo `.sh` como si fuera un ejecutable nativo de Windows (PE format), lo cual es imposible, disparando el error fatal.
3. **Falla de Aislamiento**: Mantener scripts de Bash y PowerShell en la misma raíz de ejecución (`scripts/`) es inestable para el motor de Chezmoi en entornos cross-platform.

---

## 🛠 Soluciones Intentadas (Sin Éxito Total)
- Envolver el contenido de los scripts en `{{ if eq .os "linux" }}`.
- Usar `.chezmoignore` con patrones como `scripts/*.sh`.
- Renombrar archivos para quitar el prefijo `run_` (esto soluciona Windows pero rompe la automatización en Linux).

---

## 🚀 Próximos Pasos (Estrategia Senior para Mañana)

### 1. Refactor de Arquitectura (Source Root)
Migrar a una estructura de directorios segregada físicamente. Posiblemente usando una carpeta `os/linux` y `os/windows` y configurando el `source-root` de Chezmoi para que cada sistema operativo solo "vea" lo que le pertenece.

### 2. Sincronización de Identidad "Zero-Touch"
Perfeccionar el script `bootstrap-wsl.ps1` para que la transferencia de la llave de Age sea transparente usando rutas de red nativas (`\\wsl.localhost\Ubuntu-24.04\home\...`) una vez que el problema de los scripts esté resuelto.

### 3. Limpieza de Clutter
Asegurar que los prefijos `dot_` en el `.chezmoignore` eliminen las carpetas vacías de Linux en el perfil de Windows.

---
**Nota:** El objetivo final es que un solo comando en Windows configure el host y provisione la distro de WSL con toda la identidad (identidad portada, configuración automatizada).
