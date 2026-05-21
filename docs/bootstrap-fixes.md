# Post-Mortem: Errores y Mejoras de Automatización (Mayo 2026)

Este documento registra los obstáculos encontrados durante la configuración del **Nodo 1 (Servidor Debian)** y las soluciones propuestas para lograr una instalación "zero-touch".

## 1. GitHub API Rate Limit (Mise)
- **Problema:** `mise` fallaba al consultar versiones de herramientas debido al límite de tasa de la API de GitHub en instalaciones headless.
- **Solución temporal:** Inyección de `githubToken` en `chezmoi.yaml.tmpl` y exportación en el script de `mise`.
- **Mejora futura:** 
    - [ ] Implementar un chequeo en el bootstrap para detectar si existe un token en el entorno.
    - [ ] Documentar la necesidad de un token para despliegues masivos.

## 2. Dependencias de Compilación (Lua/Python)
- **Problema:** `mise` fallaba al compilar Lua 5.1 y Python por falta de librerías (`libreadline-dev`, `libssl-dev`, `build-essential`).
- **Solución aplicada:** Se añadieron explícitamente a `packages.yaml` y se mejoró el mapeo en `debian.sh`.
- **Mejora futura:** 
    - [ ] Crear un grupo de paquetes `build-tools` universal en `packages.yaml` que se instale por defecto en sistemas Linux.

## 3. Orden de Ejecución en Chezmoi
- **Problema:** `mise` intentaba instalarse antes de que los paquetes del sistema (librerías de compilación) estuvieran presentes.
- **Solución aplicada:** Creación de `run_once_before_00-install-packages.sh.tmpl` para forzar la instalación de sistema antes que cualquier otra herramienta.
- **Mejora futura:** 
    - [ ] Estandarizar el sistema de prefijos (`before_`, `after_`) para todos los scripts de inicialización.

## 4. Gestión de Llaves SSH y Assets
- **Problema:** Fallo al clonar repositorios privados (wallpapers, obsidian) por falta de llave SSH y errores de tipografía en enlaces simbólicos.
- **Solución aplicada:** Uso de `gh auth refresh` para obtener permisos de `admin:public_key` y creación manual de llaves.
- **Mejora futura:** 
    - [ ] Automatizar la generación de llaves SSH en el bootstrap si no existen.
    - [ ] Usar `gh` para subir la llave pública automáticamente como parte del script de sincronización.
    - [ ] Eliminar la dependencia de nombres de archivo específicos (`id_ed25519_github`) usando la identidad por defecto de SSH.

## 5. Conflictos de Configuración (Git)
- **Problema:** `gh auth login` modificaba `.gitconfig` fuera del control de `chezmoi`, causando conflictos.
- **Solución aplicada:** `force-apply` de chezmoi.
- **Mejora futura:** 
    - [ ] Integrar las líneas del `credential-helper` de GitHub en la plantilla `dot_gitconfig.tmpl` de forma condicional si `gh` está instalado.

---
**Objetivo Final:** Que el comando `curl ... | sh` sea suficiente para dejar el sistema 100% operativo sin intervención manual.
