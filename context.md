# dotfiles-universal — Contexto y Visión

## 🏗️ Arquitectura de Nodos
- **Nodo 1 (Servidor Central):** Cuartel general (Debian). Aloja servicios, código y contenedores.
- **Nodo 2 (Estación de Fuerza / Desktop):** El músculo. TBD (Linux/Windows). Para tareas de alto rendimiento.
- **Nodo N (Clientes Ligeros):** Las interfaces de movilidad (ej. Fedora Sway Laptop).

## 🚀 Flujo de Trabajo
El objetivo es centralizar el desarrollo en el **Nodo 1** para garantizar persistencia y potencia, usando los **Nodos N** como interfaces ligeras.
- **Online:** `ssh` + `tmux` + `neovim` en el servidor (ver `docs/homelab-workflow.md`).
- **Plan B (Desconectado):** Desarrollo local aislado mediante **Dockerfiles y Podman Compose** para mantener el host limpio.

## ⚙️ Estado Actual del Proyecto
- [x] **Bootstrap:** Chezmoi configurado y aplicando en Nodo N (Laptop).
- [x] **Shell:** Zsh con aliases modernos y funciones de búsqueda (fzf).
- [x] **Terminal:** Kitty configurado como terminal principal.
- [x] **Multiplexor:** Tmux unificado y atajos Pro.
- [x] **Seguridad:** 
    - `age` instalado en el sistema.
    - Llave pública generada para encriptación de secretos.
    - Automatización SSH configurada con registro automático en GitHub.
    - **SOPS** configurado e integrado con `age` para gestión de secretos.
- [x] **Blindaje (Hardening):** Gestionado vía `homelab-infra` (SSH, Firewall, Podman).

## 📋 Próximos Pasos (Inmediatos)
1. **Sincronización:** Ejecutar `chezmoi init` en el Nodo 1 para compartir entorno.

---
*Última actualización: 21 de mayo de 2026*
