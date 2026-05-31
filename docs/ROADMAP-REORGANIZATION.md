# Roadmap: Reorganización Estructural de Dotfiles (Arquitectura Ideal)

Este documento guarda la propuesta de Claude Code para la reorganización física del repositorio `chezmoi/`, diseñada para eliminar la dependencia de un `.chezmoignore` masivo y facilitar el aislamiento total por OS.

**Estado:** Pendiente (Post-Semana de Clases).

---

## 🏗 Estructura de Carpetas Propuesta

```text
chezmoi/
├── .chezmoi.yaml.tmpl
├── .chezmoignore          ← Mínimo, solo archivos generados dinámicamente
│
├── base/                  ← Común a TODOS los OS
│   ├── dot_gitconfig.tmpl
│   ├── dot_zshrc.tmpl
│   ├── private_dot_ssh/
│   └── dot_config/
│       ├── starship.toml
│       ├── tmux/
│       └── nvim/
│
├── os/
│   ├── linux/             ← Solo Linux nativo (isNativeLinux)
│   │   ├── dot_config/
│   │   │   ├── sway/
│   │   │   ├── waybar/
│   │   │   ├── mako/
│   │   │   ├── kitty/
│   │   │   └── rofi/
│   │   └── dot_mozilla/
│   │
│   ├── windows/           ← Solo Windows nativo
│   │   ├── AppData/
│   │   └── Documents/
│   │
│   └── wsl/               ← Solo WSL (headless)
│       └── dot_config/
│           └── wsl.conf
│
└── scripts/               ← Lógica de instalación (nunca van a $HOME)
    ├── linux/
    └── windows/
```

---

## ⚙️ Configuración Requerida

Para habilitar esta estructura, se debe configurar el `source-root` en el `.chezmoi.yaml.tmpl` (o en la configuración local) para que Chezmoi sepa qué subcarpeta aplicar según el sistema operativo detectado.

## 🚀 Beneficios
1. **Aislamiento Físico:** No hay riesgo de que un archivo de Linux se "filtre" a Windows porque están en ramas de carpetas distintas.
2. **Claridad:** Es obvio dónde poner cada configuración nueva.
3. **Escalabilidad:** Añadir un nuevo sistema (ej. MacOS) es tan simple como crear la carpeta `os/macos/`.

---
*Generado automáticamente como respaldo del plan de arquitectura Senior.*
