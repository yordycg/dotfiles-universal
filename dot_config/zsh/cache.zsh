# =============================================================================
# Motor de Rendimiento (Caching Engine)
# =============================================================================
ZSH_CACHE_DIR="$HOME/.cache/zsh"
[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"

run_cached() {
    local name="${1:?run_cached requiere un nombre}"
    local cmd="${2:?run_cached requiere un comando}"
    local friendly_name="${3:-$name}"
    local cache_file="$ZSH_CACHE_DIR/${name}.zsh"
    
    if [[ ! -f "$cache_file" ]] || [[ -n "$(command find "$cache_file" -mmin +1440 2>/dev/null)" ]]; then
        log_info "Regenerando caché: $friendly_name..."
        ( eval "$cmd" ) > "$cache_file" 2>/dev/null || {
            rm -f "$cache_file"
            return 1
        }
        log_ok "$friendly_name sincronizado."
    fi
    [[ -f "$cache_file" ]] && builtin source "$cache_file"
}
