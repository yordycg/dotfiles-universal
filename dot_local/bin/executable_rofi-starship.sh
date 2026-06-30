#!/usr/bin/env bash

# Asegurar rutas de mise, cargo y locales
export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# Directorios de configuración
THEME_DIR="$HOME/.config/starship"
PREVIEW_DIR="$THEME_DIR/previews"
ROFI_THEME="$HOME/.config/rofi/wallpaper.rasi"

# Asegurar que los directorios existen
mkdir -p "$THEME_DIR"
mkdir -p "$PREVIEW_DIR"

# Obtener todos los temas (.toml)
shopt -s nullglob
themes=("$THEME_DIR"/*.toml)
shopt -u nullglob

# Filtrar "active.toml" si existe como enlace
themes_filtered=()
for t in "${themes[@]}"; do
    if [[ "$(basename "$t")" != "active.toml" ]]; then
        themes_filtered+=("$t")
    fi
done

if [ ${#themes_filtered[@]} -eq 0 ]; then
    echo "No starship themes found. Backing up current config..."
    if [ -f "$HOME/.config/starship.toml" ]; then
        cp "$HOME/.config/starship.toml" "$THEME_DIR/default.toml"
        themes_filtered+=("$THEME_DIR/default.toml")
    else
        exit 1
    fi
fi

# Obtener tema actual
current_theme="default"
if [ -L "$THEME_DIR/active.toml" ]; then
    current_theme=$(basename "$(readlink "$THEME_DIR/active.toml")" .toml)
fi

# Generar lista de temas para Rofi (Formato: Nombre\0icon\x1fRutaIcono)
# Añade un indicador de checkmark (󰄲) al tema que esté activo
list_themes() {
    for t in "${themes_filtered[@]}"; do
        local name=$(basename "$t" .toml)
        local display_name="$name"
        if [[ "$name" == "$current_theme" ]]; then
            display_name="$name 󰄲"
        fi
        
        local thumb="$PREVIEW_DIR/${name}.png"
        if [ ! -f "$thumb" ]; then
            thumb=""
        fi
        echo -en "${display_name}\0icon\x1f${thumb}\n"
    done
}

# Calcular columnas y márgenes dinámicamente para centrar tarjetas (estilo HyDE)
num_themes=${#themes_filtered[@]}
if [ $num_themes -lt 9 ]; then
    r_cols=$num_themes
    r_margin=$(( (100 - (num_themes * 10)) / 2 ))
    [ $r_margin -lt 0 ] && r_margin=0
else
    r_cols=9
    r_margin=0
fi

# El elemento a pre-seleccionar debe coincidir con el nombre de la lista (con el checkmark si está activo)
select_item="$current_theme"
if [[ -n "$current_theme" ]]; then
    select_item="$current_theme 󰄲"
fi

# Lanzar Rofi usando el tema de wallpaper.rasi (ancho completo)
selection=$(list_themes | rofi -dmenu -i -p " " \
    -theme "$ROFI_THEME" \
    -theme-str "window { width: 100%; } listview { columns: ${r_cols}; margin: 0px ${r_margin}% 0px ${r_margin}%; }" \
    -select "$select_item")

if [ -n "$selection" ]; then
    # Limpiar el checkmark del nombre seleccionado para obtener el nombre real del archivo
    clean_selection=$(echo "$selection" | sed 's/ 󰄲//g')
    
    echo "Cambiando tema de Starship a: $clean_selection"
    
    # Crear/Actualizar el enlace simbólico para actualización instantánea
    ln -sf "$THEME_DIR/${clean_selection}.toml" "$THEME_DIR/active.toml"
    
    # Guardar en archivo de estado
    echo "$clean_selection" > "$THEME_DIR/current_theme"
    
    # Opcional: Notificación visual
    if command -v notify-send &>/dev/null; then
        notify-send -i preferences-desktop-theme "Starship Theme" "Cambiado a: $clean_selection"
    fi
fi
