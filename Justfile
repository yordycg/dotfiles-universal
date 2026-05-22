# Dotfiles -- comandos principales

default:
	@just --list

# Aplicar todos los dotfiles
apply:
	@sudo -v
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
install:
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

# Desplegar dotfiles en un servidor remoto inyectando secretos desde Bitwarden
deploy-remote host:
    #!/usr/bin/env bash
    echo "🚀 Iniciando despliegue remoto en {{host}}..."
    if ! bw status | jq -e '.status == "unlocked"' >/dev/null; then
        echo "🔐 Bitwarden bloqueado. Por favor, usa 'bwu' primero."
        exit 1
    fi
    AGE_KEY=$(bw get item Dotfiles | jq -r .login.password)
    GH_TOKEN=$(bw get item Dotfiles | jq -r '.fields[] | select(.name=="token") | .value')
    if [ "$AGE_KEY" = "null" ] || [ "$GH_TOKEN" = "null" ]; then
        echo "❌ Error: No se pudieron obtener los secretos de Bitwarden. Verifica el item 'Dotfiles'."
        exit 1
    fi
    ssh {{host}} "CHEZMOI_AGE_KEY='$AGE_KEY' GITHUB_TOKEN='$GH_TOKEN' sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- init --apply yordycg"
    echo "✅ Despliegue en {{host}} finalizado."
