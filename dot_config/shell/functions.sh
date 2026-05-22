# -----------------------------------------------------------------------------
# SHELL FUNCTIONS - Universal Dotfiles
# -----------------------------------------------------------------------------

# --- Navegación ---

# Crear directorio y entrar
mkcd() { mkdir -p "$1" && cd "$1"; }

# Subir N directorios (ej: up 3)
up() {
  local d=""
  limit=$1
  for ((i=1 ; i <= limit ; i++))
  do
    d=$d"../"
  done
  cd $d
}

# --- Homelab & Remote Workflow ---

# Conexión principal al servidor (Nodo 1)
# Se conecta via SSH y entra directo a la sesión 'dev' de Tmux
homelab() {
  ssh -t yordycg@192.168.18.99 "tmux attach -t dev || tmux new -s dev"
}

# Selector inteligente de sesiones Tmux
# Si estás fuera de tmux: hace attach. Si estás dentro: hace switch.
ts() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | \
    fzf --height=40% --reverse --header="Jump to session" --prompt=" Sessions: ")
  
  if [[ -n "$session" ]]; then
    if [[ -z "$TMUX" ]]; then
      tmux attach -t "$session"
    else
      tmux switch-client -t "$session"
    fi
  fi
}

# Sincronización total de dotfiles (Laptop -> GitHub -> Servidor)
dsync() {
  local msg="${1:-feat: sync dotfiles from $(hostname)}"
  
  echo "== 1. Guardando cambios locales y subiendo a GitHub..."
  (cd $(chezmoi source-path) && just save "$msg")
  
  echo "== 2. Conectando al Servidor (Homelab) para actualizar..."
  ssh -t yordycg@192.168.18.99 "cd ~/.local/share/chezmoi && just update"
  
  echo "Sincronización finalizada en ambos nodos."
}

# --- Búsqueda e Interactividad (FZF) ---

# Desbloquear y gestionar Bitwarden de forma inteligente
bwu() {
    local vault_url="https://vault.home"
    local status=$(bw status 2>/dev/null | jq -r '.status')

    # 1. Configurar servidor si es necesario
    if [[ "$(bw config list | grep url)" != *"$vault_url"* ]]; then
        echo "→ Configurando servidor a $vault_url..."
        bw config server "$vault_url"
    fi

    # 2. Gestionar estado según el reporte de BW
    case "$status" in
        "unauthenticated")
            echo "→ No autenticado. Iniciando login..."
            bw login
            bwu # Re-ejecutar para desbloquear tras el login
            ;;
        "locked")
            echo "🔐 Desbloqueando Bóveda..."
            export BW_SESSION=$(bw unlock --raw)
            if [ -n "$BW_SESSION" ]; then
                echo "✓ Bóveda desbloqueada y sesión exportada."
                bw sync
            fi
            ;;
        "unlocked")
            echo "✓ La bóveda ya está desbloqueada."
            ;;
        *)
            echo "✗ Error: Estado de Bitwarden desconocido ($status)."
            return 1
            ;;
    esac
}

# Buscar texto con ripgrep y abrir en nvim en la línea exacta
findedit() {
  local file=$(
    rg --line-number --no-heading --color=always --smart-case "$*" |
      fzf --ansi --preview "bat --color=always {1} --highlight-line {2}"
  )
  if [[ -n $file ]]; then
    nvim "$(echo "$file" | cut -d':' -f1)" "+$(echo "$file" | cut -d':' -f2)"
  fi
}

# Matar procesos de forma visual
fkill() {
    local pid
    if [[ "$UID" != "0" ]]; then
        pid=$(ps -u "$USER" -o pid,ppid,comm,pcpu,pmem --sort=-pcpu | fzf --header "󰆙 Kill Process (User)" --header-lines=1 --multi | awk '{print $1}')
    else
        pid=$(ps -ef | fzf --header "󰆙 Kill Process (System)" --header-lines=1 --multi | awk '{print $2}')
    fi

    if [[ -n "$pid" ]]; then
        echo "$pid" | xargs kill -9
        echo "Proceso(s) $pid terminado(s)."
    fi
}

# Gestor interactivo de servicios Systemd
fsvc() {
    local service
    service=$(systemctl list-unit-files --type=service --state=enabled,disabled | fzf --header "Systemd Services" --header-lines=1 | awk '{print $1}')
    
    [[ -z "$service" ]] && return 0

    local action
    action=$(echo -e "status\nstart\nstop\nrestart\nenable\ndisable" | fzf --header "󰑮 Action for $service")

    [[ -z "$action" ]] && return 0

    sudo systemctl "$action" "$service"
}

# Inspeccionar y copiar variables de entorno
fenv() {
    local var
    var=$(env | fzf --header "󰈔 Environment Variables" | cut -d= -f1)
    
    if [[ -n "$var" ]]; then
        local val=${(P)var}
        echo -e "\033[1;34m$var=\033[0m$val"
        echo -n "$val" | wl-copy
        echo "📋 Valor copiado al portapapeles."
    fi
}

# --- Utilidades ---

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

# Editar dotfiles rápido
dots() { cd $(chezmoi source-path) && nvim .; }
