# Project Rules & Interaction Protocol

## Interaction Protocol
- **Communication First:** Always respond directly to comments or questions before suggesting or performing any technical action.
- **Explicit Confirmation:** Before executing any file modification or system-altering command, explain exactly which files will be affected and why. Wait for user approval (e.g., "go ahead", "confirmed") before proceeding.
- **Conventional Commits:** All commit messages must follow the [Conventional Commits](https://www.conventionalcommits.org/) standard and be written in **English** (e.g., `feat:`, `fix:`, `chore:`).

## Engineering Standards
- **Chezmoi Validation:** Ensure changes in the source directory do not break templates. Use `chezmoi diff` when possible to verify impact before application.
- **Atomic Changes:** Keep modifications focused. Do not mix changes for different tools (e.g., `zsh` and `nvim`) in the same step.
- **Template Integrity:** Exercise extreme care with `.tmpl` files to preserve logic related to `os`, `hostname`, or variables defined in `.chezmoi.yaml.tmpl`.

## Project Context
See `context.md` for architecture and roadmap details.

## Roadmap
`
$HOME/.local/share/chezmoi/docs/roadmap.md
`

## Repos

`
$HOME/.local/share/chezmoi
$HOME/.local/share/dotfiles-2024
`
