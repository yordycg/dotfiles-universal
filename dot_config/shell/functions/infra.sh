#!/usr/bin/env bash

# --- Homelab & Remote Workflow ---

# Conexión principal al servidor (Nodo 1)
homelab() {
  log_info "Conectando al servidor Homelab..." "󰒄"
  ssh -t yordycg@192.168.18.99 "tmux attach -t dev || tmux new -s dev"
}

# Selector inteligente de sesiones Tmux
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
  ssh -t yordycg@192.168.18.99 "cd ~/.local/share/chezmoi && just update"
  
  log_ok "Sincronización finalizada en ambos nodos." "󰄲"
}

# Gestión de VPN (Tailscale) - Senior Workflow
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
    # Buscamos la IP del nodo de salida por su nombre
    local exit_node_ip=$(tailscale status | grep "$node" | awk '{print $1}')
    
    if [[ -z "$exit_node_ip" ]]; then
        log_err "No se encontró el nodo $node. ¿Está encendido?" "󰅙"
        return 1
    fi

    sudo tailscale up --exit-node="$exit_node_ip" --accept-dns=true
    log_ok "Todo el tráfico fluye ahora a través de $node." "󰄲"
}

# Desbloquear y gestionar Bitwarden de forma inteligente
bwu() {
    local vault_url="https://vault.home"
    local bw_status
    bw_status=$(bw status 2>/dev/null | jq -r '.status')

    # 1. Configurar servidor si es necesario
    if [[ "$(bw config server 2>/dev/null)" != "$vault_url" ]]; then
        bw config server "$vault_url" >/dev/null
    fi

    if [[ "$bw_status" == "unlocked" ]]; then
        log_ok "La bóveda ya está desbloqueada." "󰌾"
        return 0
    fi

    # 2. Obtener secretos
    local secrets_yaml
    secrets_yaml=$(chezmoi decrypt "$HOME/.local/share/chezmoi/dot_config/homelab/private_secrets.yaml.age" 2>/dev/null)
    
    local client_id=$(echo "$secrets_yaml" | grep 'bw_client_id:' | awk -F'"' '{print $2}')
    local client_secret=$(echo "$secrets_yaml" | grep 'bw_client_secret:' | awk -F'"' '{print $2}')
    local bw_password=$(echo "$secrets_yaml" | grep 'bw_password:' | awk -F'"' '{print $2}')

    # 3. Login automático si no hay sesión
    if [[ "$bw_status" == "unauthenticated" ]]; then
        log_info "Autenticando con nuevas API Keys..." "󰈀"
        export BW_CLIENTID="$client_id"
        export BW_CLIENTSECRET="$client_secret"
        bw login --apikey >/dev/null
    fi

    # 4. Desbloqueo
    log_info "Desbloqueando Bóveda..." "󰌿"
    export BW_SESSION=$(bw unlock "$bw_password" --raw)
    
    if [[ -n "$BW_SESSION" ]]; then
        log_ok "Bóveda desbloqueada." "󰌾"
        
        # --- MEJORA: Clipboard Sync ---
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v wl-copy &>/dev/null; then
                echo -n "$bw_password" | wl-copy
                log_ok "Contraseña copiada al portapapeles (Wayland)." "󰅌"
            elif command -v xclip &>/dev/null; then
                echo -n "$bw_password" | xclip -selection clipboard
                log_ok "Contraseña copiada al portapapeles (X11)." "󰅌"
            fi
        fi

        bw sync >/dev/null 2>&1 &
    else
        log_err "Error crítico al desbloquear Bitwarden." "󰅙"
    fi
}
