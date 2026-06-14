#!/usr/bin/env bash

# --- Universal Shell Utilities ---

# Navigation
mkcd() { mkdir -p "$1" && cd "$1"; }

up() {
  local d=""
  limit=$1
  for ((i=1 ; i <= limit ; i++)); do d=$d"../"; done
  cd $d
}

# Universal Extractor
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       split -b "$1"    ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           log_err "'$1' cannot be extracted" ;;
    esac
  else
    log_err "'$1' is not a valid file"
  fi
}

# Visual Kill Process
fkill() {
    local pid
    if [[ "$UID" != "0" ]]; then
        pid=$(ps -u "$USER" -o pid,ppid,comm,pcpu,pmem --sort=-pcpu | fzf --header "Kill Process (User)" --header-lines=1 --multi | awk '{print $1}')
    else
        pid=$(ps -ef | fzf --header "Kill Process (System)" --header-lines=1 --multi | awk '{print $2}')
    fi

    if [[ -n "$pid" ]]; then
        echo "$pid" | xargs kill -9
        log_ok "Proceso(s) $pid terminado(s)."
    fi
}

# Inspect and copy Env Vars
fenv() {
    local var
    var=$(env | fzf --header "Environment Variables" | cut -d= -f1)
    
    if [[ -n "$var" ]]; then
        local val
        if [[ -n "$ZSH_VERSION" ]]; then
            val=${(P)var}
        else
            val=${!var}
        fi
        echo -e "\033[1;34m$var=\033[0m$val"
        if command -v wl-copy &>/dev/null; then
            echo -n "$val" | wl-copy
            log_ok "Valor copiado al portapapeles."
        elif command -v xclip &>/dev/null; then
            echo -n "$val" | xclip -selection clipboard
            log_ok "Valor copiado al portapapeles."
        fi
    fi
}

# Editar dotfiles rápido
dots() { cd $(chezmoi source-path) && nvim .; }

# Workflow de Notas en Tmux + Neovim
notes() {
    local notes_dir="$HOME/workspace/assets/obsidian-notes"
    if [ ! -d "$notes_dir" ]; then
        echo -e "\033[0;31m  ✗ El directorio de notas no existe: $notes_dir\033[0m"
        return 1
    fi
    
    if ! command -v tmux &>/dev/null; then
        (cd "$notes_dir" && git pull -q --rebase && lv)
        return 0
    fi

    if ! tmux has-session -t notes 2>/dev/null; then
        echo -e "\033[0;36m  → Sincronizando notas antes de abrir...\033[0m"
        (cd "$notes_dir" && git pull -q --rebase)
        tmux new-session -d -s notes -c "$notes_dir"
        tmux send-keys -t notes "lv" C-m
    fi
    
    if [ -n "$TMUX" ]; then
        tmux switch-client -t notes
    else
        tmux attach-session -t notes
    fi
}

# Gestor interactivo de servicios Systemd
fsvc() {
    local service
    service=$(systemctl list-unit-files --type=service --state=enabled,disabled | fzf --header "Systemd Services" --header-lines=1 | awk '{print $1}')
    
    [[ -z "$service" ]] && return 0

    local action
    action=$(echo -e "status\nstart\nstop\nrestart\nenable\ndisable" | fzf --header "Action for $service")

    [[ -z "$action" ]] && return 0

    sudo systemctl "$action" "$service"
}

# --- SSH Agent Management ---

# Iniciar ssh-agent y guardar variables de entorno
_ssh_agent_start() {
    local agent_env="$HOME/.ssh/agent_env"
    
    if [[ -f "$agent_env" ]]; then
        source "$agent_env" > /dev/null
    fi

    # Si no hay socket o el proceso no responde, reiniciar
    if [[ -z "$SSH_AUTH_SOCK" ]] || ! ps -p "$SSH_AGENT_PID" > /dev/null 2>&1; then
        log_info "Iniciando ssh-agent..." "󰒄"
        ssh-agent -s | sed 's/^echo/#echo/' > "$agent_env"
        chmod 600 "$agent_env"
        source "$agent_env" > /dev/null
    fi

    # Añadir llave por defecto si no hay llaves cargadas
    if ! ssh-add -l > /dev/null 2>&1; then
        if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
            ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null
        fi
    fi
}

# Solo ejecutar si no estamos en una sesión SSH (el agente ya debería venir forwarded)
# O si estamos en el servidor (opcional, pero recomendado para el Nodo 1)
if [[ -z "$SSH_CONNECTION" ]]; then
    _ssh_agent_start
fi

