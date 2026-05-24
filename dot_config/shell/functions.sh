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

# Desbloquear y gestionar Bitwarden de forma inteligente (Zero-Touch)
bwu() {
    local vault_url="https://vault.home"
    local bw_status
    bw_status=$(bw status 2>/dev/null | jq -r '.status')

    # 1. Configurar servidor si es necesario
    if [[ "$(bw config server 2>/dev/null)" != "$vault_url" ]]; then
        echo "→ Configurando servidor a $vault_url..."
        bw config server "$vault_url" >/dev/null
    fi

    # Si ya está desbloqueado, salimos rápido
    if [[ "$bw_status" == "unlocked" ]]; then
        echo "✓ La bóveda ya está desbloqueada."
        return 0
    fi

    echo "🔐 Inicializando cadena de confianza (Root of Trust)..."
    
    # Extraer credenciales seguras desencriptando el archivo .age directamente
    local secrets_yaml
    secrets_yaml=$(chezmoi decrypt "$HOME/.local/share/chezmoi/dot_config/homelab/private_secrets.yaml.age" 2>/dev/null)
    
    if [[ -z "$secrets_yaml" ]]; then
        # Reintento ignorando SSL si chezmoi está configurado para ello
        secrets_yaml=$(chezmoi decrypt --no-check-certificate "$HOME/.local/share/chezmoi/dot_config/homelab/private_secrets.yaml.age" 2>/dev/null)
    fi

    if [[ -z "$secrets_yaml" ]]; then
        echo "✗ Error: No se pudo desencriptar private_secrets.yaml.age"
        return 1
    fi

    # Parsear YAML en Bash (extracción rudimentaria pero efectiva para variables clave-valor simples)
    local bw_client_id=$(echo "$secrets_yaml" | grep 'bw_client_id:' | awk -F'"' '{print $2}')
    local bw_client_secret=$(echo "$secrets_yaml" | grep 'bw_client_secret:' | awk -F'"' '{print $2}')
    local bw_password=$(echo "$secrets_yaml" | grep 'bw_password:' | awk -F'"' '{print $2}')

    if [[ -z "$bw_client_id" || -z "$bw_password" ]]; then
        echo "✗ Error: Credenciales incompletas en secrets.yaml"
        return 1
    fi

    # Configurar Node para que confíe en nuestra CA
    export NODE_EXTRA_CA_CERTS="/usr/local/share/ca-certificates/homelab-caddy-ca.crt"

    # 2. Login Zero-Touch (si no está autenticado)
    if [[ "$bw_status" == "unauthenticated" ]]; then
        echo "→ Autenticando vía API Keys..."
        export BW_CLIENTID="$bw_client_id"
        export BW_CLIENTSECRET="$bw_client_secret"
        bw login --apikey >/dev/null 2>&1
        bw_status="locked" # Avanzamos el estado manualmente
    fi

    # 3. Unlock Zero-Touch
    if [[ "$bw_status" == "locked" ]]; then
        echo "→ Desbloqueando Bóveda en memoria..."
        export BW_SESSION=$(bw unlock "$bw_password" --raw)
        if [[ -n "$BW_SESSION" ]]; then
            echo "✓ Bóveda desbloqueada."
            # Sincronizar en background para no bloquear la terminal
            bw sync >/dev/null 2>&1 &
        else
            echo "✗ Error: Falló el desbloqueo automático."
            return 1
        fi
    fi
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
