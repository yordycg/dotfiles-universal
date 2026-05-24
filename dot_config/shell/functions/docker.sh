#!/usr/bin/env bash

# --- Docker Senior Workflow ---

# Core Aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}"'
alias dimg='docker images'
alias ld='lazydocker'

# Interactive Container Management (FZF)
# [docker] Select a running container to stop
function dstop() {
    local container=$(docker ps --format "{{.Names}}" | fzf --header "Stop: Select container" --height=40%)
    if [[ -n "$container" ]]; then
        docker stop "$container"
        log_ok "$container detenido." "󱑊"
    fi
}

# [docker] Select a container to enter (sh/bash)
function dsh() {
    local container=$(docker ps --format "{{.Names}}" | fzf --header "Shell: Enter container")
    if [[ -n "$container" ]]; then
        log_info "Entrando en $container..." "󰡨"
        docker exec -it "$container" bash 2>/dev/null || docker exec -it "$container" sh
    fi
}

# [docker] View logs of a container
function dl() {
    local container=$(docker ps -a --format "{{.Names}}" | fzf --header "Logs: View logs")
    if [[ -n "$container" ]]; then
        docker logs -f "$container"
    fi
}

# Deep Clean: Remove unused containers, images, volumes and networks
function dclean() {
    log_info "Iniciando limpieza profunda de Docker..." "󰃢"
    docker system prune -af --volumes
    log_ok "Sistema de Docker inmaculado." "󰈈"
}

# Fast DB Up: If docker-compose.yml exists, up it.
function dbup() {
    if [[ -f "docker-compose.yml" || -f "docker-compose.yaml" ]]; then
        log_info "Levantando servicios locales..." "󰆼"
        docker-compose up -d
    else
        log_err "No se encontró docker-compose.yml en el directorio actual." "󰚌"
    fi
}
