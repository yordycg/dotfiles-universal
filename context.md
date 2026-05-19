# dotfiles-universal — Contexto y Visión

## 🏗️ Arquitectura de Nodos
- **Nodo 1 (Debian 12 Headless):** Servidor principal de desarrollo. Aloja servicios y entorno pesado.
- **Nodo 2 (Fedora Sway Laptop):** Nodo principal de movilidad. "Ventana" al servidor.
- **Nodo 3 (Windows 11 + WSL2):** Estación de escritorio.

## 🚀 Flujo de Trabajo
El objetivo es centralizar el desarrollo en el **Nodo 1** para garantizar persistencia y potencia, usando la **Laptop** como interfaz.
- **Online:** `ssh` + `tmux` + `neovim` en el servidor (ver `docs/homelab-workflow.md`).
- **Plan B (Offline):** Desarrollo local aislado mediante **Distrobox** para mantener el host limpio.

## ⚙️ Estado Actual del Proyecto
- [x] **Bootstrap:** Chezmoi configurado y aplicando en Nodo 2.
- [x] **Shell:** Zsh con aliases modernos y funciones de búsqueda (fzf).
- [x] **Terminal:** Kitty configurado como terminal principal.
- [x] **Multiplexor:** Tmux unificado con tema `dotbar` y atajos Pro.
- [x] **Editor:** LazyVim instalado y optimizado para proyectos grandes.
- [x] **Seguridad:** 
    - `age` instalado en el sistema.
    - Llave pública generada: `age1w93unwnu802h9vkygj2d4dxmu23yghw9kd39thwgc0susmsu7spscwp0wa`.
    - `.chezmoi.yaml.tmpl` configurado para manejar encriptación automática.

## 📋 Próximos Pasos (Inmediatos)
1. **Blindaje Nodo 1:** Iniciar el hardening del servidor Debian (SSH, Firewall).
2. **Sincronización:** Ejecutar `dsync` para llevar la config actual al Nodo 1.
3. **Plan B:** Terminar de configurar los contenedores Distrobox locales.

---
*Última actualización: 18 de mayo de 2026*
