# Dotfiles -- comandos principales

default:
	@just --list

# Aplicar todos los dotfiles
apply:
	chezmoi apply -v

# Ver cambios pendientes
diff:
	chezmoi diff

# Pull del repo + apply
update:
	chezmoi update

# Editar un dotfile y aplicar
edit FILE:
	chezmoi edit {{FILE}} --apply

# Instalar paquetes segun el distro actual
intall:
	@if [ -f /etc/fedora-release ]; then \
		bash scripts/packages/installers/fedora.sh; \
	elif [ -f /etc/arch-release ]; then \
		bash scripts/packages/installers/arch.sh; \
	elif [ -f /etc/debian_version ]; then \
		bash scripts/packages/installers/debian.sh; \
	fi

# Ver estructura del repo
tree:
	eza --tree --icons --level=3 $(chezmoi source-path)

# Commit rapido
save MSG="feat: update dotfiles":
	cd $(chezmoi source-path) && git add . && git commit -m "{{MSG}}" && git push
