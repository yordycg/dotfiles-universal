# =============================================================================
# WORKFLOWS Y FUNCIONES DE TMUX (MONO-MÁQUINA)
# =============================================================================

# Selector de sesiones de Tmux con restauración perezosa.
# - Si no hay servidor de tmux, lo inicia, espera dinámicamente a que
#   continuum/resurrect restauren el estado, y elimina la sesión de boot.
# - Sin argumentos: muestra selector fzf de sesiones activas.
# - Con argumento: entra a la sesión especificada, o la crea si no existe.
ta() {
    # 1. Levantar servidor y restaurar si no está corriendo
    if ! tmux list-sessions &>/dev/null; then
        echo -e "\033[0;36m  → Iniciando servidor de tmux y restaurando sesiones...\033[0m"
        
        # Iniciar sesión de arranque temporal en background
        tmux new-session -d -s _boot
        
        # Forzar la restauración de tmux-resurrect de forma manual
        local restore_script="$HOME/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh"
        if [[ -f "$restore_script" ]]; then
            tmux run-shell "$restore_script" &>/dev/null
        fi
        
        # Espera dinámica muy corta a que termine de procesar las sesiones
        local count=0
        while [[ $count -lt 10 ]]; do
            if [[ $(tmux list-sessions -F '#{session_name}' 2>/dev/null | grep -v "^_boot$" | wc -l) -gt 0 ]]; then
                break
            fi
            sleep 0.1
            ((count++))
        done
        
        # Limpieza de la sesión de arranque
        if [[ $(tmux list-sessions -F '#{session_name}' 2>/dev/null | grep -v "^_boot$" | wc -l) -gt 0 ]]; then
            # Si hay sesiones restauradas, matamos _boot de forma segura
            tmux kill-session -t _boot 2>/dev/null
        else
            # Si no se restauró nada, renombramos _boot a main para mantener el servidor vivo
            tmux rename-session -t _boot main 2>/dev/null
        fi
    fi

    # 2. Si se pasa un argumento, acoplar o crear
    if [[ -n "$1" ]]; then
        tmux attach -t "$1" 2>/dev/null || tmux new -s "$1"
        return
    fi

    # 3. Fallback si fzf no está instalado
    if ! command -v fzf &>/dev/null; then
        local sessions=($(tmux list-sessions -F "#{session_name}" 2>/dev/null))
        if [[ ${#sessions[@]} -eq 0 ]]; then
            tmux attach
            return
        fi
        echo "Sesiones activas de tmux:"
        select session in "${sessions[@]}"; do
            if [[ -n "$session" ]]; then
                tmux attach -t "$session"
                break
            else
                echo "Selección inválida."
            fi
        done
        return
    fi

    # 4. Flujo normal con fzf
    local session
    session=$(tmux list-sessions -F "#{session_name}: #{session_windows} windows" 2>/dev/null | \
        fzf --height 40% --reverse --prompt="Sesión tmux > " | cut -d: -f1)

    [[ -n "$session" ]] && tmux attach -t "$session"
}

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

# Workflow de Estudio (Learning Path) en Tmux + Neovim
learn() {
    local path_dir="$HOME/workspace/personal/learning-path"
    
    if [ ! -d "$path_dir" ]; then
        echo -e "\033[0;31m  ✗ El repositorio de aprendizaje no existe en: $path_dir\033[0m"
        echo -e "\033[0;36m  → Por favor ejecuta 'chezmoi apply' o clónalo manualmente.\033[0m"
        return 1
    fi
    
    if ! command -v tmux &>/dev/null; then
        (cd "$path_dir" && git pull -q --rebase && nv)
        return 0
    fi

    # Si la sesión "learn" no existe, la creamos con dos ventanas
    if ! tmux has-session -t learn 2>/dev/null; then
        echo -e "\033[0;36m  → Sincronizando repositorio antes de abrir...\033[0m"
        (cd "$path_dir" && git pull -q --rebase)
        
        # Ventana 1: Editor con tu Neovim personal (nv)
        tmux new-session -d -s learn -n "editor" -c "$path_dir"
        tmux send-keys -t learn:editor "nv" C-m
        
        # Ventana 2: Terminal de soporte
        tmux new-window -t learn -n "terminal" -c "$path_dir"
    fi
    
    # Cambiar o adjuntar a la sesión learn
    if [ -n "$TMUX" ]; then
        tmux switch-client -t learn
    else
        tmux attach-session -t learn
    fi
}

# Workflow de Dotfiles en Tmux + Neovim
dotfiles() {
    # Obtener dinámicamente la ruta fuente de chezmoi
    local source_dir
    source_dir=$(chezmoi source-path 2>/dev/null || echo "$HOME/.local/share/chezmoi")
    
    if [ ! -d "$source_dir" ]; then
        echo -e "\033[0;31m  ✗ El directorio de chezmoi no existe: $source_dir\033[0m"
        return 1
    fi

    # Si no hay tmux instalado, abrir el editor directamente
    if ! command -v tmux &>/dev/null; then
        (cd "$source_dir" && lv)
        return 0
    fi

    # Si la sesión "dotfiles" no existe, la creamos
    if ! tmux has-session -t dotfiles 2>/dev/null; then
        # 1. Crear la sesión en background
        tmux new-session -d -s dotfiles -c "$source_dir"
        
        # 2. Iniciar el editor en el panel izquierdo (Panel 1)
        tmux send-keys -t dotfiles "lv" C-m
        
        # 3. Dividir a la mitad (50/50) horizontalmente, creando el panel derecho (Panel 2)
        tmux split-window -h -p 50 -c "$source_dir"
        
        # 4. Asegurar que el foco inicie en el panel del editor (Panel 1)
        tmux select-pane -t dotfiles:1.1
    fi

    # Redirigir al usuario a la sesión (dentro o fuera de tmux)
    if [ -n "$TMUX" ]; then
        tmux switch-client -t dotfiles
    else
        tmux attach-session -t dotfiles
    fi
}

# Workflow de Proyectos General (Universal con 3 paneles de "omarchy")
work() {
    # 1. Determinar el directorio del proyecto (argumento o $PWD)
    local proj_dir="${1:-$PWD}"
    
    # Resolver ruta absoluta de forma segura
    proj_dir=$(cd "$proj_dir" 2>/dev/null && pwd || echo "")
    if [ -z "$proj_dir" ] || [ ! -d "$proj_dir" ]; then
        echo -e "\033[0;31m  ✗ Directorio no válido: $proj_dir\033[0m"
        return 1
    fi

    # Nombre de la sesión basado en la carpeta (reemplazando puntos por guiones)
    local proj_name
    proj_name=$(basename "$proj_dir" | tr '.' '-')

    # Si no hay tmux, abrir el editor de forma normal
    if ! command -v tmux &>/dev/null; then
        (cd "$proj_dir" && lv)
        return 0
    fi

    # 2. Si la sesión no existe, la creamos con la estructura de 3 paneles
    if ! tmux has-session -t "$proj_name" 2>/dev/null; then
        echo -e "\033[0;36m  → Creando espacio de trabajo para '$proj_name' (3 paneles)...\033[0m"
        
        # Panel 1: Crear sesión y abrir editor arriba a la izquierda
        tmux new-session -d -s "$proj_name" -c "$proj_dir"
        tmux send-keys -t "$proj_name" "lv" C-m
        
        # Panel 2: Dividir a la derecha (50/50)
        tmux split-window -h -p 50 -c "$proj_dir"
        
        # Panel 3: Dividir verticalmente abajo a todo lo ancho (30% alto para logs/server)
        tmux split-window -f -v -p 30 -c "$proj_dir"
        
        # Volver a enfocar el panel del editor arriba a la izquierda
        tmux select-pane -t "$proj_name:1.1"
    fi

    # 3. Adjuntar/cambiar a la sesión
    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$proj_name"
    else
        tmux attach-session -t "$proj_name"
    fi
}
