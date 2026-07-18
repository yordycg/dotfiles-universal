## Estructura

```
dot_config/themes/
├── apply-theme.sh
├── decoration-switcher.sh
├── font-switcher.sh
├── main-menu.sh
├── rofi-launcher.sh
├── rofi-theme.rasi
├── wallpaper-selector.sh
├─── ariadne/
├─── catppucin/
├─── everforest/
├─── gruvbox-material/
├─── horizon/
├─── kanagawa-dragon/
├─── nord/
├─── rose-pine/
├─── onedark/
└─── tokyo-night/
```

## apply-theme script

```bash
#!/bin/bash
# Color codes
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # no color

THEME="$1"
THEME_DIR="$HOME/.config/themes/$THEME"
WALLPAPER_STATE="$HOME/.config/themes/.wallpaper-state"

if [ -z "$THEME" ]; then
    echo -e "${YELLOW}Usage: $0 <theme-name>${NC}"
    exit 1
fi

if [ ! -d "$THEME_DIR" ]; then
    echo -e "${YELLOW}Theme '$THEME' does not exist at $THEME_DIR${NC}"
    notify-send "Theme Error" "Theme '$THEME' not found" -u critical
    exit 1
fi

# Track current theme
CURRENT_THEME_FILE="$HOME/.config/themes/.current-theme"
echo "$THEME" > "$CURRENT_THEME_FILE"

echo -e "${GREEN}Applying theme: $THEME${NC}\n"
notify-send "Theme Switching" "Applying theme: $THEME" -t 3000

if [[ $THEME == "material-you" ]]; then
    bash ~/.config/matugen/scripts/gtk-4.sh &
fi

# Hyprland config
echo -e "${CYAN}-> Updating Hyprland configuration...${NC}"
cp "$THEME_DIR/hypr/colors.conf" "$HOME/.config/hypr/colors/colors.conf" > /dev/null 2>&1
hyprctl reload & diwon
echo ""

# Waybar style
echo -e "${CYAN}-> Applying Waybar CSS...${NC}"
cp "$THEME_DIR/waybar/colors.css" "$HOME/.config/waybar/colors/colors.css" > /dev/null 2>&1
echo -e "${CYAN}-> Restarting Waybar...${NC}"
pkill waybar > /dev/null 2>&1 && ~/.config/waybar/scripts/launch.sh > /dev/null 2>&1 & disown
echo ""

# Kitty theme
# Tmux theme
# Starship theme
# Rofi theme
# Swaync theme
# GTK/Qt theme
if [ -f "$THEME_DIR/gtk-theme" ]; then
    GTK_THEME_NAME=$(cat "$THEME_DIR/gtk-theme")
    echo -e "${CYAN}-> Setting GKT theme to '$GTK_THEME_NAME'...${NC}"
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME_NAME" > /dev/null 2>&1
else
    echo -e "${YELLOW}-> GTK theme file not found. Skipping.${NC}"
fi
echo ""

GTK4_SRC="$THEME_DIR/gtk-4.0"
GTK4_DST="$HOME/.config/gtk-4.0"

if [[ -d "$GTK4_SRC" ]]; then
    echo -e "${CYAN}-> Linking GTK4 theme files...${NC}"
    mkdir -p "$GTK4_DST"
    ln -sf "$GTK4_SRC/gtk.css" "$GTK4_DST/gtk.css"
    ln -sf "$GTK4_SRC/gtk-dark.css" "$GTK4_DST/gtk-dark.css"
    ln -sf "$GTK4_SRC/assets" "$GTK4_DST/assets"
else
    echo -e "${YELLOW}->No GTK4 theme file not found in $GTK4_SRC. Skipping.${NC}"
fi
echo ""

# Wallpaper | NOTE: para el caso de cuando queramos integrar temas segun el wallpaper
echo -e "${CYAN}-> Setting wallpaper...${NC}"
WALLPAPER_DIR="$THEME_DIR/wallpapers"

# Create state file if it doesn't exist
touch "$WALLPAPER_STATE"
#...
```

## Recomendaciones para la Futura Integración de GTK

Cuando decidamos activar la sección de temas GTK en `apply-theme.sh`, se sugieren las siguientes optimizaciones sobre el borrador propuesto:

1. **Esquema de Color Oscuro para Libadwaita:**
   Además de definir `gtk-theme`, se debe configurar el esquema de color preferido de la interfaz para forzar la compatibilidad con aplicaciones de Libadwaita modernas (como los diálogos del sistema):
   ```bash
   gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
   ```

2. **Evitar enlaces anidados en Assets (GTK4):**
   Al enlazar la carpeta `assets` a `~/.config/gtk-4.0/assets`, es recomendable utilizar la bandera `-n` de `ln` (`ln -sfn`) para evitar que se cree un enlace simbólico recursivo dentro de la carpeta si esta ya existía de una ejecución anterior:
   ```bash
   ln -sfn "$GTK4_SRC/assets" "$GTK4_DST/assets"
   ```

