# Crear directorio y entrar
mkcd() { mkdir -p "$1" && cd "$1"; }

# Extraer cualquier archivo comprimido
extract() {
	case "$1" in
		*.tar.bz2) tar xjf "$1" ;;
		*.tar.gz) tar xzf "$1" ;;
		*.tar.xz) tar xJf "$1" ;;
		*.zip) unzip "$1" ;;
		*.7z) 7z x "$1" ;;
		*.rar) unrar x "$1" ;;
		*) echo "No se extraer '$1'" ;;
	esac
}

# Ver el contenido de un directorio al entrar
cd() { builtin cd "$@" && eza --icons; }

# Buscar en historial con fzf
fh() {
	local cmd
	cmd=$(fc -l 1 | fzf --tac --query="$*" | sed 's/^ *[0-9]* *//')
	[ -n "$cmd" ] && eval "$cmd"
}

# Editar dotfiles rapido
dots() { cd $(chezmoi source-path) && nvim .; }
