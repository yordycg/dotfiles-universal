#!/usr/bin/env bash

# --- Homelab & Remote Workflow ---

# Variable interna para el PATH remoto (asegura encontrar mise, just, tmux, etc.)
REMOTE_PATH="export PATH=\$HOME/.local/share/mise/shims:\$HOME/.local/bin:\$PATH:/usr/local/bin:/usr/bin:/bin"

# Conexión principal al servidor (Nodo 1)
homelab() {
  log_info "Conectando al servidor Homelab..." "󰒄"
  # Simplemente entramos. El s_manager en el .zshrc del servidor se encargará
  # de darnos el selector de sesiones de forma interactiva y con el PATH correcto.
  ssh -t homelab
}

# Selector inteligente de sesiones Tmux (Local)
ts() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | \
    fzf --height=40% --reverse --header="Jump to session" --prompt="Sessions: ")
  
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
  
  log_step "1. Guardando cambios locales y subiendo a GitHub..." "󰊢"
  (cd $(chezmoi source-path) && just save "$msg")
  
  log_step "2. Conectando al Servidor (Homelab) para actualizar..." "󰒄"
  ssh -t homelab "$REMOTE_PATH; cd ~/.local/share/chezmoi && just update"
  
  log_ok "Sincronización finalizada en ambos nodos." "󰄲"
}

# Gestión de VPN (Tailscale)
vpn-up() {
    log_info "Levantando VPN (Modo Estándar)..." "󰒄"
    sudo tailscale up --accept-dns=true
    log_ok "VPN Activa. Split DNS habilitado para *.home" "󰄲"
}

vpn-down() {
    log_info "Desconectando VPN..." "󱊚"
    sudo tailscale down
    log_ok "VPN Desconectada." "󰄲"
}

vpn-exit() {
    local node=${1:-"homelab"}
    log_info "Activando Nodo de Salida: $node..." "󰒄"
    local exit_node_ip=$(tailscale status | grep "$node" | awk '{print $1}')
    if [[ -n "$exit_node_ip" ]]; then
        sudo tailscale up --exit-node="$exit_node_ip" --accept-dns=true
        log_ok "Tráfico redirigido a través de $node." "󰒄"
    else
        log_err "No se encontró el nodo $node." "󰅙"
    fi
}

# --- Remote Docker & Forwarding Helpers ---

# Ver logs de un contenedor remoto
dlogs() {
    local host="${1:-homelab}"
    local container="$2"
    log_info "Obteniendo logs de $container en $host..." "󰒄"
    ssh "$host" "$REMOTE_PATH; docker logs -f --tail=100 '$container'"
}

# Ejecutar comando en contenedor remoto
dexec() {
    local host="$1"; shift
    log_info "Ejecutando en contenedor remoto en $host..." "󰒄"
    ssh -t "$host" "$REMOTE_PATH; docker exec -it $*"
}

# Ver estado rápido del Homelab
homestat() {
    local host="${1:-homelab}"
    log_info "Estado del Homelab: $host" "󰒄"
    echo -e "\n\e[1;34m=== Contenedores Activos ===\e[0m"
    
    # Lógica Senior para limpiar puertos duplicados e interfaces
    ssh "$host" "docker ps --format '{{.Names}}\t{{.Status}}\t{{.Ports}}'" | \
        awk -F'\t' '{
            names=$1; status=$2; ports=$3;
            # Limpiar comas y IPs
            gsub(/0.0.0.0:/, "", ports);
            gsub(/\[::\]:/, "", ports);
            gsub(/,/, " ", ports);
            
            # Deduplicar
            n=split(ports, a, " ");
            delete seen;
            res="";
            for (i=1; i<=n; i++) {
                if (a[i] != "" && !(a[i] in seen)) {
                    res = res (res==""?"":" ") a[i];
                    seen[a[i]]=1;
                }
            }
            printf "%-16s %-20s %s\n", names, status, res
        }' | sort
        
    echo -e "\n\e[1;34m=== Uso de Disco ===\e[0m"
    ssh "$host" "$REMOTE_PATH; df -h | grep -v tmpfs | grep -E 'Filesystem|/dev/'"
}

# Forward de un puerto ad-hoc
sshfwd() {
    local host="${1:-homelab}"
    local port="$2"
    log_info "Creando túnel para puerto $port -> $host..." "󰒄"
    ssh -N -L "${port}:localhost:${port}" "$host"
}

# Ver puertos forwarded activos
sshports() {
    log_info "Puertos forwarded (Local -> Remote) activos:" "󰒄"
    ss -tlnp | grep "127.0.0.1" | awk '{print $4}' | cut -d':' -f2 | sort -u
}

# Desbloquear Bitwarden
bwu() {
    local vault_url="https://vault.home"
    local bw_status
    bw_status=$(bw status 2>/dev/null | jq -r '.status')

    if [[ "$(bw config server 2>/dev/null)" != "$vault_url" ]]; then
        bw config server "$vault_url" >/dev/null
    fi

    if [[ "$bw_status" == "unlocked" ]]; then
        log_ok "La bóveda ya está desbloqueada." "󰌾"
        return 0
    fi

    local secrets_yaml
    secrets_yaml=$(chezmoi decrypt "$HOME/.local/share/chezmoi/dot_config/homelab/private_secrets.yaml.age" 2>/dev/null)
    
    local client_id=$(echo "$secrets_yaml" | grep 'bw_client_id:' | awk -F'"' '{print $2}')
    local client_secret=$(echo "$secrets_yaml" | grep 'bw_client_secret:' | awk -F'"' '{print $2}')
    local bw_password=$(echo "$secrets_yaml" | grep 'bw_password:' | awk -F'"' '{print $2}')

    if [[ "$bw_status" == "unauthenticated" ]]; then
        log_info "Autenticando con nuevas API Keys..." "󰈀"
        export BW_CLIENTID="$client_id"
        export BW_CLIENTSECRET="$client_secret"
        bw login --apikey >/dev/null
    fi

    log_info "Desbloqueando Bóveda..." "󰌿"
    export BW_SESSION=$(bw unlock "$bw_password" --raw)
    
    if [[ -n "$BW_SESSION" ]]; then
        log_ok "Bóveda desbloqueada." "󰌾"
        if command -v wl-copy &>/dev/null; then
            echo -n "$bw_password" | wl-copy
        elif command -v xclip &>/dev/null; then
            echo -n "$bw_password" | xclip -selection clipboard
        fi
        bw sync >/dev/null 2>&1 &
    else
        log_err "Error crítico al desbloquear Bitwarden." "󰅙"
    fi
}
