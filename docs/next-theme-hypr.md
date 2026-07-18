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

# Wallpaper | NOTE: para el caso de cuando queramos integrar temas segun el wallpaper
echo -e "${CYAN}-> Setting wallpaper...${NC}"
WALLPAPER_DIR="$THEME_DIR/wallpapers"

# Create state file if it doesn't exist
touch "$WALLPAPER_STATE"
#...
```
