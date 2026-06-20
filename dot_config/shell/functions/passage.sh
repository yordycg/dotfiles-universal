# =============================================================================
# functions/passage.sh
# Sincronización automática e inteligente para Passage (Age-based Password Store)
# =============================================================================

passage() {
    local cmd="${1:-}"
    local store_path="$HOME/.passage/store"
    
    # 1. Ejecutar pull silencioso en segundo plano al leer datos
    if [ -d "$store_path/.git" ]; then
        (cd "$store_path" && git pull --rebase -q &>/dev/null &)
    fi
    
    # 2. Ejecutar el comando original de passage
    command passage "$@"
    local exit_code=$?
    
    # 3. Si el comando fue exitoso y modificó la bóveda, sincronizar al instante
    if [ $exit_code -eq 0 ] && [ -d "$store_path/.git" ]; then
        case "$cmd" in
            insert|generate|rm|edit|add|mv|cp|import)
                log_info "Sincronizando cambios de passage con el servidor..."
                (
                    cd "$store_path"
                    git add .
                    # Evitar commits vacíos si no hubo cambios reales
                    if ! git diff --cached --quiet; then
                        git commit -m "sync: auto-update passwords $(date '+%Y-%m-%d %H:%M:%S')"
                        git push -q || log_warn "No se pudo hacer push. Sincronización remota pendiente."
                    fi
                )
                ;;
        esac
    fi
    
    return $exit_code
}
