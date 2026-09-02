# =============================================================================
# WORKFLOWS Y FUNCIONES DE TMUX (MONO-MÁQUINA)
# =============================================================================

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
