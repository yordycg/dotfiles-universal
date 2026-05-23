# dotfiles-universal — Roadmap de implementación
> Estado: Fase 1 en curso. Identidad SSH y Arquitectura base completadas.

---

##  Completado

- [x] Fedora actualizado y bootstrap mínimo (git, curl, gh, chezmoi, zsh, just)
- [x] Shell cambiado a Zsh automáticamente
- [x] GitHub autenticado y scopes de seguridad configurados
- [x] Repo `dotfiles-universal` creado y sincronizado
- [x] Estructura de directorios base modular
- [x] `.chezmoi.yaml.tmpl` — detecta laptop/desktop/WSL
- [x] `packages.yaml` — organizado por distros (Fedora/Debian/Arch)
- [x] `scripts/packages/installers/` — instaladores limpios por distro
- [x] `run_once_after_setup-ssh.sh.tmpl` — automatización total de identidad SSH
- [x] `dot_config/shell/` — aliases y funciones modernas
- [x] `dot_config/starship.toml` — prompt gestionado por mise
- [x] `Justfile` — comandos principales (apply, diff, update, save)
- [x] `docs/project-workflow.md` — estándar de arquitectura de 3 capas

---

## 🔧 Fase 1 — Dotfiles y Editor

### 1.1 Gestionar ~/.ssh/config con Chezmoi
- [x] Unificar identidad en `id_ed25519`
- [x] Configurar SSH Agent Forwarding para Nodo 1
- [x] Automatización total de identidad SSH (Zero-Touch) 

### 1.2 Neovim (Estrategia Dual) 
Configuración dual para máxima versatilidad:
- **LazyVim (`lv`)**: Para proyectos grandes/gigantes.
- **Personal (`nv`)**: Para modificaciones rápidas y experimentación.

### 1.3 Tmux 
- [x] Prefijo `Ctrl+Space` configurado.
- [x] Navegación Vim-style y soporte para Popups (lazygit, yazi).
- [x] Gestión automática de plugins con TPM.

### 1.4 Refinamiento de Shell y Prompt
- [x] **Mejorar Starship**: Investigar preset `starship-cockpit`, eliminar la hora final, añadir hostname para diferenciar Nodos (Server vs Nodo N) y personalizar colores.
- [x] **Optimizar Zshrc**: Análisis comparativo y unificación de 3 configuraciones (`chezmoi/`, `dotfiles-2024/` y `radleylewis/zsh`).
- [ ] **Auditoría de Scripts**: Analizar funciones y scripts de `dotfiles-2024` y otras fuentes para reutilizarlos en el Dotfile Universal.

---


## 🔧 Fase 2 — Instaladores y Nodos

### 2.1 Nodo 1 (Servidor Central)
- [ ] Aplicar `chezmoi init` en Debian
- [ ] **Tmux Persistente**: Configurar el flujo de auto-attach al hacer SSH para un workflow senior.
- [ ] **Configurar Forgejo**: Completar el asistente web y vincular con Postgres (resolver bucle de ping).

### 2.2 Nodo 2 (Estación de Fuerza / Desktop)
- [ ] Configurar `windows.ps1` o instalador Linux correspondiente
- [ ] Asegurar que Podman esté listo para heavy-lifting

### 2.3 Nodo N (Clientes Ligeros)
- [x] Fedora Sway (Laptop) configurado
- [ ] Refinar ahorro de energía y gestión de red

---

## 🔧 Fase 3 — Contenedores y Proyectos (Host inmaculado)

### 3.1 Entornos de Proyecto
- [ ] Implementar `Dockerfile` y `compose.yaml` en todos los proyectos personales.
- [ ] Estandarizar el uso de `Justfile` por proyecto para orquestación.

---

## 🔧 Fase 4 — Seguridad y secrets
- [x] **age**: Instalar y generar llave de encriptación (`~/.config/chezmoi/key.txt`).
- [x] **SOPS**: Implementado y configurado en `dot_zshrc.tmpl` para cifrado de secretos.
- [x] **Vaultwarden**: Desplegado en Nodo 1 como gestor de secretos principal. 
- [x] **Integración Chezmoi**: Uso nativo de la función `bitwarden` en plantillas. 
- [x] **Estandarización de Scripts**: Refactorizar scripts de Chezmoi usando la estructura de `homelab-infra` (funciones `ok`, `info`, `warn`, `err`).
- [x] **Limpieza Visual**: Eliminar iconos y emojis de todos los scripts para un look más minimalista y profesional.
- [x] **Optimización de Ejecución (Cache)**: Implementar `run_onchange_` con hashes para evitar ejecuciones redundantes (paquetes, fuentes, mise).
- [x] **Gestor de Secretos (Senior)**: Integrar Bitwarden CLI (`bw`) nativamente y autenticación silenciosa de `gh`.
- [x] **Detección de Nodos Inteligente**: Identificación automática del Nodo 1 (Notebook-Servidor) en plantillas.
- [x] **Automatización SSL (Bundle)**: Mejorar script `run_after_95` para descargar el Root+Intermediate bundle automáticamente.

- [x] **Backup de Secretos**: Implementar script de respaldo automático para el volumen de Vaultwarden.

## 🔧 Fase 5 — Red y DNS (Completado)
- [x] **Preparar Infraestructura**: Creado `containers/adguard/compose.yaml` y script de provisión `03-dns-setup.sh`.
- [x] **DNS Interno (Configuración UI)**: AdGuard configurado con rewrites para `*.home` y upstream a Podman.
- [x] **Estrategia Anti-Desastres**: Implementado script `restore.sh` y backups automáticos de volúmenes con Restic.
- [x] **VPN Mesh (Tailscale Global)**: Nodo 1 configurado como Nameserver Global y automatización en Chezmoi.

---

## 📋 Comandos útiles del día a día

```bash
just apply        # Aplicar cambios pendientes
just diff         # Ver qué va a cambiar
just update       # git pull + apply
just save         # commit + push rápido
```

---

## Estado del repo en GitHub

```
dotfiles-universal/
├── .chezmoi.yaml.tmpl      [OK]
├── .chezmoignore          [OK]
├── .gitignore              [OK]
├── Justfile                [OK]
├── dot_gitconfig.tmpl      [OK]
├── dot_zshrc.tmpl          [OK]
├── dot_config/
│   ├── shell/
│   │   ├── aliases.sh      [OK]
│   │   └── functions.sh    [OK]
│   ├── homelab/
│   │   └── backup.env      [OK] (Secretos)
│   ├── systemd/user/
│   │   ├── homelab-backup.service [OK]
│   │   └── homelab-backup.timer   [OK]
│   ├── starship.toml       [OK]
│   ├── nvim/               [OK] Fase 1
│   └── tmux/               [OK] Fase 1
├── home/                   (Estructura OK)
├── hosts/                  (Estructura OK)
└── scripts/
    ├── run_onchange_before_00-install-packages.sh   [OK]
    ├── run_onchange_after_10-install-fonts.sh      [OK]
    ├── run_onchange_after_20-install-mise.sh       [OK]
    ├── run_once_after_90-setup-ssh.sh              [OK]
    ├── run_after_95-trust-homelab-ca.sh            [OK]
    └── run_once_after_99-change-shell.sh           [OK]
```

---

> Actualizado: 22 de mayo de 2026 — Optimización de Caché y Zero-Touch consolidado
