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
