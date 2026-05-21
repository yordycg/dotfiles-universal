# dotfiles-universal — Roadmap de implementación
> Estado: Fase 1 en curso. Identidad SSH y Arquitectura base completadas.

---

## ✅ Completado

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

### 1.2 Neovim (Estrategia Dual) ✅
Configuración dual para máxima versatilidad:
- **LazyVim (`lv`)**: Para proyectos grandes/gigantes.
- **Personal (`nv`)**: Para modificaciones rápidas y experimentación.

### 1.3 Tmux ✅
- Prefijo `Ctrl+Space` configurado.
- Navegación Vim-style y soporte para Popups (lazygit, yazi).
- Gestión automática de plugins con TPM.

---

## 🔧 Fase 2 — Instaladores y Nodos

### 2.1 Nodo 1 (Servidor Central)
- [ ] Aplicar `chezmoi init` en Debian
- [ ] Configurar Tmux persistente y entorno de shell idéntico

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
- [ ] **Configurar Chezmoi**: Usar `encryption: age` en `.chezmoi.yaml.tmpl`.

---

## 📋 Comandos útiles del día a día

```bash
just apply        # Aplicar cambios pendientes
just diff         # Ver qué va a cambiar
just update       # git pull + apply
just save         # commit + push rápido
```

---

## 🗂️ Estado del repo en GitHub

```
dotfiles-universal/
├── .chezmoi.yaml.tmpl      ✅
├── .chezmoignore          ✅
├── .gitignore              ✅
├── Justfile                ✅
├── dot_gitconfig.tmpl      ✅
├── dot_zshrc.tmpl          ✅
├── dot_config/
│   ├── shell/
│   │   ├── aliases.sh      ✅
│   │   └── functions.sh    ✅
│   ├── starship.toml       ✅
│   ├── nvim/               ⏳ Fase 1
│   └── tmux/               ⏳ Fase 1
├── home/                   ✅ (Estructura)
├── hosts/                  ✅ (Estructura)
└── scripts/
    ├── run_once_after_setup-ssh.sh   ✅
    ├── run_once_install-mise.sh      ✅
    └── packages/
        ├── packages.yaml             ✅
        └── installers/               ✅
```

---

> Actualizado: 21 de mayo de 2026 — Arquitectura de 3 capas consolidada
