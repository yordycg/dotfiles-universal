#!/usr/bin/env bash
# =============================================================================
# provision/system/setup-kde-macos-theme.sh
#
# Instala y configura el stack completo de theming macOS para KDE Plasma 6.
# Diseñado para integrarse con el orquestador run_once_before_00-provision-system.sh.tmpl
#
# Idempotente: puede ejecutarse N veces con el mismo resultado final.
# Sudo-less: todo se instala en directorios de usuario (~/.local/share/*)
#
# Uso directo (fuera de chezmoi):
#   bash provision/system/setup-kde-macos-theme.sh [mactahoe|whitesur|mojave]
#   bash provision/system/setup-kde-macos-theme.sh mactahoe --force     # reinstala
#   bash provision/system/setup-kde-macos-theme.sh mactahoe --uninstall # desinstala
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuración de Argumentos y Mapeo de Temas
# -----------------------------------------------------------------------------

THEME_NAME="${1:-mactahoe}"
FORCE_REINSTALL="${2:-}"  # pasar --force para reinstalar todo

# Normalizar nombre a minúsculas
THEME_LOWER=$(echo "$THEME_NAME" | tr '[:upper:]' '[:lower:]')

# Valores por defecto (mactahoe)
GTK_REPO_NAME="MacTahoe-gtk-theme"
GTK_REPO_URL="https://github.com/vinceliuice/MacTahoe-gtk-theme.git"
ICON_REPO_NAME="MacTahoe-icon-theme"
ICON_REPO_URL="https://github.com/vinceliuice/MacTahoe-icon-theme.git"
GTK_THEME_APPLY="MacTahoe-Dark"
ICON_THEME_APPLY="MacTahoe"

# Mapear otros temas soportados
if [[ "$THEME_LOWER" == "whitesur" ]]; then
    GTK_REPO_NAME="WhiteSur-gtk-theme"
    GTK_REPO_URL="https://github.com/vinceliuice/WhiteSur-gtk-theme.git"
    ICON_REPO_NAME="WhiteSur-icon-theme"
    ICON_REPO_URL="https://github.com/vinceliuice/WhiteSur-icon-theme.git"
    GTK_THEME_APPLY="WhiteSur-Dark"
    ICON_THEME_APPLY="WhiteSur"
elif [[ "$THEME_LOWER" == "mojave" ]]; then
    GTK_REPO_NAME="Mojave-gtk-theme"
    GTK_REPO_URL="https://github.com/vinceliuice/Mojave-gtk-theme.git"
    ICON_REPO_NAME="Mojave-CT-icon-theme"
    ICON_REPO_URL="https://github.com/vinceliuice/Mojave-CT-icon-theme.git"
    GTK_THEME_APPLY="Mojave-Dark"
    ICON_THEME_APPLY="Mojave-CT"
fi

THEME_REPOS_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/kde-macos-themes"
THEMES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/themes"
ICONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons"
FONTS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"

# Repos auxiliares constantes (Cursores, KDE y Fuentes)
declare -A REPOS=(
    ["WhiteSur-kde"]="https://github.com/vinceliuice/WhiteSur-kde.git"
    ["WhiteSur-cursors"]="https://github.com/vinceliuice/WhiteSur-cursors.git"
    ["San-Francisco-Pro-Fonts"]="https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts.git"
)

# Señales de instalación completada (para idempotencia rápida sin re-clonar)
INSTALL_STAMPS_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/kde-macos-themes/.stamps"

# -----------------------------------------------------------------------------
# Colores y logging
# -----------------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${RESET}  $*"; }
log_ok()      { echo -e "${GREEN}[OK]${RESET}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
log_error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
log_section() { echo -e "\n${BOLD}${CYAN}══════════════════════════════════════${RESET}"; \
                echo -e "${BOLD}${CYAN}  $*${RESET}"; \
                echo -e "${BOLD}${CYAN}══════════════════════════════════════${RESET}"; }

# -----------------------------------------------------------------------------
# Utilidades
# -----------------------------------------------------------------------------

has_cmd() { command -v "$1" &>/dev/null; }

stamp_done() {
    mkdir -p "$INSTALL_STAMPS_DIR"
    touch "$INSTALL_STAMPS_DIR/$1"
}

is_done() {
    [[ "$FORCE_REINSTALL" == "--force" ]] && return 1
    [[ -f "$INSTALL_STAMPS_DIR/$1" ]]
}

clone_or_update() {
    local name="$1"
    local url="$2"
    local dest="$THEME_REPOS_DIR/$name"

    if [[ -d "$dest/.git" ]]; then
        log_info "$name ya clonado — actualizando..."
        git -C "$dest" pull --ff-only --quiet || {
            log_warn "git pull falló en $name (puede haber cambios locales), continuando..."
        }
    else
        log_info "Clonando $name..."
        git clone --depth=1 "$url" "$dest" --quiet
        log_ok "$name clonado en $dest"
    fi
}

check_deps() {
    local missing=()
    for dep in git sassc glib-compile-schemas; do
        has_cmd "$dep" || missing+=("$dep")
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Dependencias faltantes: ${missing[*]}"
        log_error "Ejecuta primero: sudo dnf install -y sassc glib2-devel git"
        exit 1
    fi
    log_ok "Dependencias verificadas"
}

# -----------------------------------------------------------------------------
# Funciones de instalación
# -----------------------------------------------------------------------------

install_gtk_theme() {
    log_section "GTK Theme: $GTK_REPO_NAME"

    is_done "gtk-theme-$THEME_LOWER" && { log_ok "GTK Theme $THEME_LOWER ya instalado (stamp). Usa --force para reinstalar."; return 0; }

    clone_or_update "$GTK_REPO_NAME" "$GTK_REPO_URL"

    local repo="$THEME_REPOS_DIR/$GTK_REPO_NAME"

    log_info "Instalando variantes dark + light con soporte libadwaita..."
    bash "$repo/install.sh" \
        --dest "$THEMES_DIR" \
        --color dark \
        --color light \
        --libadwaita \
        --round \
        --silent-mode \
        2>&1 | sed 's/^/  /'

    log_ok "GTK Theme instalado en $THEMES_DIR"
    stamp_done "gtk-theme-$THEME_LOWER"
}

install_icon_theme() {
    log_section "Icon Theme: $ICON_REPO_NAME"

    is_done "icon-theme-$THEME_LOWER" && { log_ok "Icon Theme $THEME_LOWER ya instalado (stamp). Usa --force para reinstalar."; return 0; }

    clone_or_update "$ICON_REPO_NAME" "$ICON_REPO_URL"

    local repo="$THEME_REPOS_DIR/$ICON_REPO_NAME"

    log_info "Instalando iconos..."
    bash "$repo/install.sh" \
        --dest "$ICONS_DIR" \
        2>&1 | sed 's/^/  /'

    log_ok "Icon Theme instalado en $ICONS_DIR"
    stamp_done "icon-theme-$THEME_LOWER"
}

install_whitesur_kde() {
    log_section "WhiteSur KDE / Kvantum Theme"

    is_done "whitesur-kde" && { log_ok "WhiteSur KDE ya instalado (stamp). Usa --force para reinstalar."; return 0; }

    clone_or_update "WhiteSur-kde" "${REPOS[WhiteSur-kde]}"

    local repo="$THEME_REPOS_DIR/WhiteSur-kde"

    log_info "Instalando tema Kvantum y Plasma..."
    bash "$repo/install.sh" \
        2>&1 | sed 's/^/  /'

    log_ok "WhiteSur KDE instalado"
    stamp_done "whitesur-kde"
}

install_whitesur_cursors() {
    log_section "WhiteSur Cursors"

    is_done "whitesur-cursors" && { log_ok "WhiteSur Cursors ya instalado (stamp). Usa --force para reinstalar."; return 0; }

    clone_or_update "WhiteSur-cursors" "${REPOS[WhiteSur-cursors]}"

    local repo="$THEME_REPOS_DIR/WhiteSur-cursors"

    log_info "Instalando cursores..."
    bash "$repo/install.sh" \
        --dest "$ICONS_DIR" \
        2>&1 | sed 's/^/  /'

    log_ok "WhiteSur Cursors instalado en $ICONS_DIR"
    stamp_done "whitesur-cursors"
}

install_sf_fonts() {
    log_section "Fuentes San Francisco Pro (macOS)"

    is_done "sf-fonts" && { log_ok "Fuentes SF Pro ya instaladas (stamp). Usa --force para reinstalar."; return 0; }

    clone_or_update "San-Francisco-Pro-Fonts" "${REPOS[San-Francisco-Pro-Fonts]}"

    local repo="$THEME_REPOS_DIR/San-Francisco-Pro-Fonts"
    local font_dest="$FONTS_DIR/SanFranciscoPro"

    log_info "Instalando fuentes SF Pro..."
    mkdir -p "$font_dest"
    cp "$repo"/*.otf "$font_dest/" 2>/dev/null || true
    cp "$repo"/*.ttf "$font_dest/" 2>/dev/null || true

    fc-cache -f "$font_dest" 2>/dev/null || fc-cache -fv &>/dev/null
    log_ok "Fuentes SF Pro instaladas en $font_dest"
    stamp_done "sf-fonts"
}

fix_flatpak_themes() {
    log_section "Fix Flatpak → $GTK_REPO_NAME"

    is_done "flatpak-fix-$THEME_LOWER" && { log_ok "Fix Flatpak ya aplicado (stamp). Usa --force para reinstalar."; return 0; }

    if has_cmd flatpak; then
        local repo="$THEME_REPOS_DIR/$GTK_REPO_NAME"

        if [[ -d "$repo" ]]; then
            log_info "Conectando $GTK_REPO_NAME a apps Flatpak..."
            bash "$repo/tweaks.sh" \
                --flatpak \
                --color dark \
                --silent-mode \
                2>&1 | sed 's/^/  /' || {
                log_warn "tweaks.sh -F retornó error, puede que no haya Flatpaks instalados aún"
            }
            log_ok "Tema conectado a Flatpak"
        else
            log_warn "Repo $GTK_REPO_NAME no encontrado, omitiendo fix Flatpak"
        fi
    else
        log_warn "flatpak no encontrado, omitiendo fix"
    fi

    stamp_done "flatpak-fix-$THEME_LOWER"
}

install_firefox_theme() {
    log_section "Tema Firefox ($GTK_REPO_NAME)"

    is_done "firefox-theme-$THEME_LOWER" && { log_ok "Tema Firefox ya instalado (stamp). Usa --force para reinstalar."; return 0; }

    local repo="$THEME_REPOS_DIR/$GTK_REPO_NAME"

    if [[ ! -d "$repo" ]]; then
        log_warn "Repo $GTK_REPO_NAME no encontrado, omitiendo tema Firefox"
        return 0
    fi

    if ! has_cmd firefox && ! flatpak list 2>/dev/null | grep -q "firefox"; then
        log_warn "Firefox no encontrado, omitiendo tema"
        return 0
    fi

    log_info "Instalando y conectando tema Firefox..."
    bash "$repo/tweaks.sh" \
        --firefox \
        --edit-firefox \
        --silent-mode \
        2>&1 | sed 's/^/  /' || {
        log_warn "tweaks.sh -f retornó error. Firefox debe estar cerrado al instalar el tema."
    }

    log_ok "Tema Firefox instalado"
    stamp_done "firefox-theme-$THEME_LOWER"
}

apply_kde_settings() {
    log_section "Aplicar configuración KDE via gsettings / kwriteconfig"

    is_done "kde-settings-$THEME_LOWER" && { log_ok "Configuración KDE ya aplicada (stamp). Usa --force para reinstalar."; return 0; }

    if has_cmd gsettings; then
        log_info "Aplicando tema GTK via gsettings..."
        gsettings set org.gnome.desktop.interface gtk-theme  "$GTK_THEME_APPLY"   2>/dev/null || true
        gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME_APPLY"  2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors" 2>/dev/null || true
        log_ok "gsettings aplicado"
    fi

    if has_cmd kwriteconfig5; then
        log_info "Configurando estilo Qt a Kvantum via kwriteconfig5..."
        kwriteconfig5 --file kdeglobals --group KDE --key widgetStyle "kvantum"
        log_ok "Estilo Qt = kvantum"
    elif has_cmd kwriteconfig6; then
        log_info "Configurando estilo Qt a Kvantum via kwriteconfig6..."
        kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle "kvantum"
        log_ok "Estilo Qt = kvantum"
    fi

    if has_cmd kvantummanager; then
        log_info "Seleccionando tema WhiteSur en Kvantum..."
        kvantummanager --set WhiteSur 2>/dev/null || \
            log_warn "kvantummanager --set falló, aplica manualmente el tema WhiteSur en kvantummanager"
    fi

    stamp_done "kde-settings-$THEME_LOWER"
}

# -----------------------------------------------------------------------------
# Función de desinstalación
# -----------------------------------------------------------------------------

uninstall_all() {
    log_section "Desinstalando temas macOS ($THEME_NAME)..."

    local repo_gtk="$THEME_REPOS_DIR/$GTK_REPO_NAME"
    local repo_icons="$THEME_REPOS_DIR/$ICON_REPO_NAME"
    local repo_kde="$THEME_REPOS_DIR/WhiteSur-kde"
    local repo_cursors="$THEME_REPOS_DIR/WhiteSur-cursors"

    [[ -d "$repo_gtk" ]]     && bash "$repo_gtk/install.sh"     --remove --silent-mode || true
    [[ -d "$repo_gtk" ]]     && bash "$repo_gtk/tweaks.sh"      --firefox --remove --silent-mode 2>/dev/null || true
    [[ -d "$repo_gtk" ]]     && bash "$repo_gtk/tweaks.sh"      --flatpak --remove --silent-mode 2>/dev/null || true
    [[ -d "$repo_icons" ]]   && bash "$repo_icons/install.sh"   --remove 2>/dev/null || true
    [[ -d "$repo_kde" ]]     && bash "$repo_kde/install.sh"     --remove 2>/dev/null || true
    [[ -d "$repo_cursors" ]] && bash "$repo_cursors/install.sh" --remove 2>/dev/null || true

    rm -rf "$INSTALL_STAMPS_DIR"
    log_ok "Todo desinstalado. Stamps eliminados."
}

# -----------------------------------------------------------------------------
# Entrypoint
# -----------------------------------------------------------------------------

main() {
    echo -e "\n${BOLD}KDE macOS Theme Setup (${THEME_NAME})${RESET}"
    echo -e "Repo cache : ${CYAN}$THEME_REPOS_DIR${RESET}"
    echo -e "Stamps     : ${CYAN}$INSTALL_STAMPS_DIR${RESET}"
    [[ "$FORCE_REINSTALL" == "--force" ]] && echo -e "${YELLOW}Modo --force: se reinstala todo${RESET}"
    [[ "$FORCE_REINSTALL" == "--uninstall" ]] && { uninstall_all; exit 0; }

    mkdir -p "$THEME_REPOS_DIR" "$THEMES_DIR" "$ICONS_DIR" "$FONTS_DIR"

    check_deps

    install_gtk_theme
    install_icon_theme
    install_whitesur_kde
    install_whitesur_cursors
    install_sf_fonts
    fix_flatpak_themes
    install_firefox_theme
    apply_kde_settings

    echo -e "\n${BOLD}${GREEN}✓ Setup completo.${RESET}"
    echo -e "  Reinicia la sesión KDE para aplicar todos los cambios."
    echo ""
}

main "$@"
