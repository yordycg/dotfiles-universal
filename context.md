# dotfiles-universal

## Arquitectura
- Nodo 1: Servidor Debian 12 headless — repo separado (homelab-infra)
- Nodo 2: Laptop Fedora Sway — nodo principal
- Nodo 3: Desktop Windows 11 + WSL2

## Gestor de dotfiles
Chezmoi — source dir: ~/.local/share/chezmoi

## Reglas
- Nunca instalar lenguajes en el host → Distrobox
- Fuente de verdad de paquetes: scripts/packages/packages.yaml
- Separación por OS via .chezmoiignore

## Repo de referencia (dotfiles viejos)
https://github.com/yordycg/dotfiles-2024
Usar para comparar y migrar configs, no copiar ciegamente.

## Fases pendientes
Ver docs/roadmap.md