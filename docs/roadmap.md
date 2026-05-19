# dotfiles-universal — Roadmap de implementación
> Estado: Fase 0 completada. SSH configurado. Chezmoi aplicando correctamente.

---

## ✅ Completado

- [x] Fedora actualizado y bootstrap mínimo instalado (git, curl, gh, chezmoi, zsh, just)
- [x] Shell cambiado a Zsh
- [x] GitHub autenticado via gh CLI
- [x] Repo `dotfiles-universal` creado en GitHub
- [x] Estructura de directorios base creada
- [x] `.chezmoi.yaml.tmpl` — detecta laptop/desktop/WSL
- [x] `.chezmoiignore` — aplica solo lo que corresponde por OS
- [x] `packages.yaml` — fuente de verdad de paquetes
- [x] `scripts/packages/installers/fedora.sh` — instalador Fedora
- [x] Stubs para arch.sh, debian.sh, windows.ps1
- [x] `dot_gitconfig.tmpl` — gitconfig con variables de Chezmoi
- [x] `dot_zshrc.tmpl` — zshrc base
- [x] `dot_config/shell/aliases.sh` — aliases modernos
- [x] `dot_config/shell/functions.sh` — funciones útiles
- [x] `dot_config/starship.toml` — prompt configurado
- [x] `Justfile` — comandos principales (apply, diff, update, save)
- [x] Starship instalado via script (no disponible en repos Fedora)
- [x] `run_once_install-starship.sh` — instala starship en máquinas nuevas
- [x] SSH key `id_ed25519_github` generada y agregada a GitHub
- [x] `~/.ssh/config` configurado (github.com + homelab)
- [x] Remote del repo cambiado de HTTPS a SSH
- [x] Paquetes core instalados via fedora.sh

---

## 🔧 Fase 1 — Dotfiles pendientes

### 1.1 Gestionar ~/.ssh/config con Chezmoi
El archivo existe pero Chezmoi no lo gestiona todavía.
```bash
chezmoi add ~/.ssh/config
chezmoi apply -v
```
> ⚠️  Las llaves privadas NUNCA van al repo. Solo el config.

### 1.2 Neovim
Migrar tu config Lua desde dotfiles-2024 o crear una nueva base:
```bash
# Opción A: clonar tu config vieja como base
git clone https://github.com/yordycg/dotfiles-2024 /tmp/dotfiles-old
cp -r /tmp/dotfiles-old/editors/nvim/* $(chezmoi source-path)/dot_config/nvim/

# Opción B: usar LazyVim como base limpia
# https://www.lazyvim.org/installation

chezmoi add ~/.config/nvim
chezmoi apply -v
```

### 1.3 Tmux
```bash
cat > $(chezmoi source-path)/dot_config/tmux/tmux.conf << 'CONF'
# Prefix: Ctrl+Space
unbind C-b
set -g prefix C-Space
bind C-Space send-prefix

# Indexar desde 1
set -g base-index 1
setw -g pane-base-index 1

# Mouse
set -g mouse on

# Colores
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"

# Splits intuitivos
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Reload config
bind r source-file ~/.config/tmux/tmux.conf \; display "Config recargada"

# Plugin manager (TPM)
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'catppuccin/tmux'

run '~/.tmux/plugins/tpm/tpm'
CONF

chezmoi add ~/.config/tmux/tmux.conf
```

### 1.4 Sway config base
```bash
# Copiar config base de Fedora Sway Spin y agregar a Chezmoi
cp ~/.config/sway/config $(chezmoi source-path)/home/profile_sway/dot_config/sway/config.tmpl
# Luego editar para agregar variables de host (font size, monitor, etc)
```

### 1.5 Waybar
```bash
chezmoi add ~/.config/waybar/config
chezmoi add ~/.config/waybar/style.css
```

---

## 🔧 Fase 2 — Instaladores pendientes

### 2.1 Completar arch.sh
Cuando migres a Arch, completar `scripts/packages/installers/arch.sh`:
- Usar `pacman` para paquetes base
- Usar `yay` o `paru` para AUR (starship, lazygit, etc)

### 2.2 Completar debian.sh
Para el Nodo 1 (Debian headless) o futura migración:
- Usar `apt`
- Agregar PPAs necesarios (neovim PPA, etc)

### 2.3 Completar windows.ps1
Para el Nodo 3 (Windows 11):
- `winget` para apps GUI (WezTerm, Git, VS Code)
- `scoop` para herramientas CLI (fzf, ripgrep, eza, etc)
- Configurar PowerShell profile con Starship

---

## 🔧 Fase 3 — Distrobox (host inmaculado)

### 3.1 Instalar Distrobox y Podman
```bash
sudo dnf install -y distrobox podman
```

### 3.2 Crear boxes.yaml
```bash
cat > $(chezmoi source-path)/scripts/distrobox/boxes.yaml << 'YAML'
boxes:
  - name: dev-node
    image: docker.io/library/node:22-bookworm
    provision: scripts/distrobox/provision_node.sh

  - name: dev-python
    image: docker.io/library/python:3.12-slim
    provision: scripts/distrobox/provision_python.sh

  - name: dev-dotnet
    image: mcr.microsoft.com/dotnet/sdk:8.0
    provision: scripts/distrobox/provision_dotnet.sh
YAML
```

### 3.3 Scripts de provisión
Crear `scripts/distrobox/provision_node.sh`, `provision_python.sh`, `provision_dotnet.sh`
con las herramientas específicas de cada entorno.

### 3.4 Script run_onchange_ para Chezmoi
```bash
# scripts/run_onchange_setup-distrobox.sh.tmpl
# Se ejecuta automáticamente cuando boxes.yaml cambia
```

---

## 🔧 Fase 4 — Seguridad y secrets

### 4.1 Encriptar secrets con age
```bash
# Instalar age
sudo dnf install -y age

# Generar llave de encriptación
age-keygen -o ~/.config/chezmoi/key.txt

# Configurar Chezmoi para usar age
# En .chezmoi.yaml.tmpl agregar:
# encryption: age
# age:
#   identity: ~/.config/chezmoi/key.txt
#   recipient: <tu-public-key>
```

### 4.2 Agregar secrets encriptados
Archivos sensibles que pueden ir al repo encriptados:
- Variables de entorno privadas
- Tokens de API
- Config de servicios internos

---

## 🔧 Fase 5 — Windows (Nodo 3)

### 5.1 Chezmoi en Windows
```powershell
# Instalar Chezmoi via winget
winget install twpayne.chezmoi

# Clonar el repo
chezmoi init git@github.com:yordycg/dotfiles-universal.git
chezmoi apply
```

### 5.2 WSL2
```bash
# Dentro de WSL2, mismo proceso que Linux
# Chezmoi detectará isWSL=true automáticamente
chezmoi init git@github.com:yordycg/dotfiles-universal.git
chezmoi apply
```

---

## 🔧 Fase 6 — Flujo SSH Senior (Homelab)
> Objetivo: Trabajar en el servidor como si fuera local, con persistencia y seguridad.

### 6.1 SSH Agent Forwarding
Permite usar las llaves de la laptop en el servidor sin copiarlas.
- [ ] Configurar `AllowAgentForwarding yes` en el servidor.
- [ ] Configurar `ForwardAgent yes` en el `~/.ssh/config` gestionado por Chezmoi.

### 6.2 Forgejo Mirroring
- [ ] Configurar Forgejo para sincronizar repositorios desde GitHub.
- [ ] Configurar remotos adicionales (`git remote add homelab ...`) para push local.

### 6.3 Personalización del Nodo 1 (Servidor)
- [ ] Ejecutar `chezmoi init` en el servidor.
- [ ] Adaptar `debian.sh` (o el instalador que corresponda) para paquetes headless (sin GUI).
- [ ] Configurar **Tmux** como shell por defecto o sesión persistente al entrar.

---

## 📋 Comandos útiles del día a día

```bash
just apply        # Aplicar cambios pendientes
just diff         # Ver qué va a cambiar
just update       # git pull + apply
just save         # commit + push rápido
just install      # instalar paquetes según distro

chezmoi edit ~/.zshrc          # editar un dotfile
chezmoi add ~/.config/algo     # agregar nuevo archivo al repo
chezmoi diff                   # ver diferencias
chezmoi status                 # estado general
```

---

## 🗂️ Estado del repo en GitHub

```
dotfiles-universal/
├── .chezmoi.yaml.tmpl      ✅
├── .chezmoiignore          ✅
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
├── home/
│   ├── profile_sway/       ⏳ Fase 1
│   ├── profile_wsl/        ⏳ Fase 5
│   └── os_windows/         ⏳ Fase 5
├── hosts/
│   ├── laptop/             ⏳ Fase 1
│   └── desktop/            ⏳ Fase 5
└── scripts/
    ├── run_once_install-starship.sh  ✅
    ├── run_onchange_setup-distrobox  ⏳ Fase 3
    ├── distrobox/                    ⏳ Fase 3
    └── packages/
        ├── packages.yaml             ✅
        └── installers/
            ├── fedora.sh             ✅
            ├── arch.sh               ⏳ Fase 2
            ├── debian.sh             ⏳ Fase 2
            └── windows.ps1           ⏳ Fase 5
```

---

> Generado el 17 May 2026 — dotfiles-universal session
