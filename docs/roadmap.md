# dotfiles-universal — Roadmap de implementación

---

## 🔧 Fase 1 — Dotfiles y Editor

### 1.1 Neovim (Estrategia Dual)

- [ ] **Workflow de Notas en Neovim**: Integrar y configurar Neovim (usando `obsidian.nvim` o similar) como editor principal para el Second Brain, reemplazando la aplicación gráfica de Obsidian.
- [ ] **Sesión de Tmux para Notas**: Crear una configuración y alias de Tmux dedicado para abrir el directorio de notas directamente en una sesión aislada y enfocada.

### 1.2 Tmux

- [x] **Preservar Atajos Estándar**: Evitar modificar excesivamente los atajos (keybindings) por defecto de Tmux para mantener la memoria muscular intacta al operar en servidores externos u otros equipos.
- [ ] **Investigación de LazyApps**: Evaluar la integración de otras herramientas TUI de la familia *Lazy* (como `lazydocker` para docker, `lazysql` para BDs u otras) en la configuración de la terminal y los atajos de Tmux.

---

## 🔧 Fase 2 — Contenedores y Proyectos (Host inmaculado)

### 2.1 Infraestructura de Código y CI/CD

- [ ] Implementar el primer flujo de CI/CD (ej. auto-deploy de `yordycg-portfolio`).

### 2.2 Gestión de Bases de Datos (Senior Terminal Workflow)

- [ ] **Database TUI & CLI**: Implementar `usql` (cliente universal) y `lazysql` (interfaz TUI) para gestión total desde terminal/tmux.
- [ ] **Configuración**: Añadir herramientas a `packages.yaml` y crear alias de acceso rápido.

---

## 🔧 Fase 3 — Seguridad y secrets

- [ ] **Investigar `pass` como Gestor Alternativo**: Evaluar `pass` (the standard unix password manager) y compararlo con el stack actual (Bitwarden/Vaultwarden) para determinar si vale la pena la migración hacia una solución más nativa de terminal y ligera en recursos.

## 🔧 Fase 4 — Advanced Homelab Workflow (Senior Implementation)

> El objetivo es lograr "Cero Contaminación" en el repo de infraestructura y "Aislamiento Total" en proyectos de estudio.

### 4.1 Hardening y Autodiscovery (homelab-infra)

- [ ] **Robustez de Respaldos (homelab-infra)**: Cargar `configs/backup.env` en `manage.sh` para garantizar que la copia de seguridad con Restic tenga acceso al entorno configurado.
- [ ] **Unificación SSH (chezmoi)**: Eliminar la inyección manual de `github.com` al final de `~/.ssh/config` en `run_after_50-setup-ssh.sh.tmpl` para centralizar la configuración en `private_dot_ssh/config.tmpl`.
- [ ] **Bot de Notificación de Backups (homelab-infra & chezmoi)**: Investigar e implementar un bot (Telegram, WhatsApp, o alternativas de notificaciones abiertas como NTFY/Apprise) para alertar sobre el estado de los backups automáticos del servidor, con potencial para reportar métricas del sistema, bloqueos de Fail2ban y alertas críticas de contenedores.

---

## 📋 Protocolo de Bootstrap (New Node)

Para cualquier máquina nueva, el proceso de identidad es manual para máxima seguridad:

1.  **Siembra de Identidad**: Copiar desde USB seguro:
    - `age` key -> `~/.config/chezmoi/key.txt` (o ruta configurada en `private_secrets.yaml.age`).
    - SSH key -> `~/.ssh/id_ed25519` y `~/.ssh/id_ed25519.pub`.
2.  **Chezmoi Init**:
    ```bash
    chezmoi init --apply yordycg
    ```

---

## 📋 Comandos útiles del día a día

```bash
just apply        # Aplicar cambios pendientes
just diff         # Ver qué va a cambiar
just update       # git pull + apply
just save         # commit + push rápido
bwu               # Desbloqueo automático de Bitwarden (Zero-Touch)
lab-open          # Port forward instantáneo del servidor
lps               # Ver estado de contenedores remotos
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
│   │   ├── backup.env      [OK] (Secretos)
│   │   └── private_secrets.yaml.age [OK] (Bitwarden API Keys)
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

> Actualizado: 5 de junio de 2026 — Estrategia Linux-Only y Mejoras Senior Phase 1.
