#!/usr/bin/env bash
# =============================================================================
# provision/lib/logging.sh
# Librería de logging y utilidades compartida para scripts de aprovisionamiento.
# =============================================================================

# Colores ANSI Homelab-Style
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Funciones de logs (Homelab-Style con iconos/flechas)
log_step()    { echo -e "\n${CYAN}${BOLD}▶ $*${RESET}"; }
log_ok()      { echo -e "${GREEN}  ✓ $*${RESET}"; }
log_info()    { echo -e "${CYAN}  → $*${RESET}"; }
log_warn()    { echo -e "${YELLOW}  ⚠ $*${RESET}"; }
log_error()   { echo -e "${RED}  ✗ $*${RESET}" >&2; }
log_err()     { log_error "$*"; exit 1; }

log_section() {
    echo -e "\n${BOLD}${CYAN}══════════════════════════════════════════════════════════════${RESET}"
    echo -e "  $*"
    echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════════════════${RESET}"
}

# Funciones de Utilidad
has_cmd() {
    command -v "$1" &>/dev/null
}

DRY_RUN="${DRY_RUN:-0}"

run() {
    if [ "$DRY_RUN" = "1" ]; then
        log_info "[DRY-RUN] $*"
    else
        "$@"
    fi
}
