#!/usr/bin/env bash
# =============================================================================
# provision/system/setup-kde-macos-theme.sh
#
# Instala y configura el stack completo de theming macOS Tahoe para KDE Plasma 6.
# Diseñado para integrarse con el orquestador run_once_before_00-provision-system.sh.tmpl
#
# Idempotente: puede ejecutarse N veces con el mismo resultado final.
# Sudo-less: todo se instala en directorios de usuario (~/.local/share/*)
# La única excepción es el fix de Flatpak que requiere sudo (delegado al orquestador).
#
# Temas que instala:
#   - MacTahoe GTK theme     → apps GTK (Firefox, LibreOffice, Celluloid...)
#   - MacTahoe Icon theme    → iconos del sistema
#   - WhiteSur KDE/Kvantum   → apps Qt nativas de KDE (Dolphin, Konsole...)
#   - WhiteSur Cursors       → puntero del ratón
#   - Firefox theme          → integración con el perfil activo
#
# Uso directo (fuera de chezmoi):
#   bash provision/system/setup-kde-macos-theme.sh
#   bash provision/system/setup-kde-macos-theme.sh --force   # reinstala todo
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuración
# -----------------------------------------------------------------------------

THEME_REPOS_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/kde-macos-themes"
THEMES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/themes"
ICONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons"
FONTS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"

FORCE_REINSTALL="${1:-}"  # pasar --force para reinstalar todo

# Repos a gestionar
declare -A REPOS=(
    ["MacTahoe-gtk-theme"]="https://github.com/vinceliuice/MacTahoe-gtk-theme.git"
    ["MacTahoe-icon-theme"]="https://github.com/vinceliuice/MacTahoe-icon-theme.git"
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

# Verifica si un comando existe
has_cmd() { command -v "$1" &>/dev/null; }

# Marca un paso como completado (idempotencia entre ejecuciones)
stamp_done() {
    mkdir -p "$INSTALL_STAMPS_DIR"
    touch "$INSTALL_STAMPS_DIR/$1"
}

# Verifica si un paso ya fue completado
is_done() {
    [[ "$FORCE_REINSTALL" == "--force" ]] && return 1
    [[ -f "$INSTALL_STAMPS_DIR/$1" ]]
}

# Clona el repo si no existe, hace pull si ya existe
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

# Verifica si las dependencias de sistema están instaladas
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

install_mactahoe_gtk() {
    log_section "MacTahoe GTK Theme"

    is_done "mactahoe-gtk" && { log_ok "MacTahoe GTK ya instalado (stamp). Usa --force para reinstalar."; return 0; }

    clone_or_update "MacTahoe-gtk-theme" "${REPOS[MacTahoe-gtk-theme]}"

    local repo="$THEME_REPOS_DIR/MacTahoe-gtk-theme"

    log_info "Instalando variantes dark + light con soporte libadwaita..."
    bash "$repo/install.sh" \
        --dest "$THEMES_DIR" \
        --color dark \
        --color light \
        --libadwaita \
        --round \
        --silent-mode \
        2>&1 | sed 's/^/  /'

    log_ok "MacTahoe GTK instalado en $THEMES_DIR"
    stamp_done "mactahoe-gtk"
}

install_mactahoe_icons() {
    log_section "MacTahoe Icon Theme"

    is_done "mactahoe-icons" && { log_ok "MacTahoe Icons ya instalado (stamp). Usa --force para reinstalar."; return 0; }

    clone_or_update "MacTahoe-icon-theme" "${REPOS[MacTahoe-icon-theme]}"

    local repo="$THEME_REPOS_DIR/MacTahoe-icon-theme"

    log_info "Instalando iconos..."
    bash "$repo/install.sh" \
        --dest "$ICONS_DIR" \
        2>&1 | sed 's/^/  /'

    log_ok "MacTahoe Icons instalado en $ICONS_DIR"
    stamp_done "mactahoe-icons"
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
    log_section "Fix Flatpak → MacTahoe"

    is_done "flatpak-fix" && { log_ok "Fix Flatpak ya aplicado (stamp). Usa --force para reinstalar."; return 0; }

    # El override de Flatpak requiere sudo — lo hace el orquestador
    # Aquí solo conectamos el tema a las apps Flatpak instaladas (sudo-less)
    if has_cmd flatpak; then
        local repo="$THEME_REPOS_DIR/MacTahoe-gtk-theme"

        if [[ -d "$repo" ]]; then
            log_info "Conectando MacTahoe a apps Flatpak..."
            bash "$repo/tweaks.sh" \
                --flatpak \
                --color dark \
                --silent-mode \
                2>&1 | sed 's/^/  /' || {
                log_warn "tweaks.sh -F retornó error, puede que no haya Flatpaks instalados aún"
            }
            log_ok "Tema conectado a Flatpak"
        else
            log_warn "Repo MacTahoe no encontrado, omitiendo fix Flatpak"
        fi
    else
        log_warn "flatpak no encontrado, omitiendo fix"
    fi

    stamp_done "flatpak-fix"
}

install_firefox_theme() {
    log_section "Tema Firefox"

    is_done "firefox-theme" && { log_ok "Tema Firefox ya instalado (stamp). Usa --force para reinstalar."; return 0; }

    local repo="$THEME_REPOS_DIR/MacTahoe-gtk-theme"

    if [[ ! -d "$repo" ]]; then
        log_warn "Repo MacTahoe no encontrado, omitiendo tema Firefox"
        return 0
    fi

    # Detectar si Firefox está instalado
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
    stamp_done "firefox-theme"
}

apply_kde_settings() {
    log_section "Aplicar configuración KDE via gsettings / kwriteconfig5"

    is_done "kde-settings" && { log_ok "Configuración KDE ya aplicada (stamp). Usa --force para reinstalar."; return 0; }

    # Aplicar tema GTK para apps no-Qt via gsettings
    if has_cmd gsettings; then
        log_info "Aplicando tema GTK via gsettings..."
        gsettings set org.gnome.desktop.interface gtk-theme  "MacTahoe-Dark"   2>/dev/null || true
        gsettings set org.gnome.desktop.interface icon-theme "MacTahoe"        2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors" 2>/dev/null || true
        log_ok "gsettings aplicado"
    fi

    # Aplicar tema Kvantum como estilo de aplicación en KDE
    if has_cmd kwriteconfig5; then
        log_info "Configurando estilo Qt a Kvantum via kwriteconfig5..."
        kwriteconfig5 --file kdeglobals --group KDE --key widgetStyle "kvantum"
        log_ok "Estilo Qt = kvantum"
    elif has_cmd kwriteconfig6; then
        log_info "Configurando estilo Qt a Kvantum via kwriteconfig6..."
        kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle "kvantum"
        log_ok "Estilo Qt = kvantum"
    else
        log_warn "kwriteconfig5/6 no encontrado. Aplica manualmente: System Settings → Application Style → kvantum"
    fi

    # Aplicar tema Kvantum directamente via kvantummanager si está disponible
    if has_cmd kvantummanager; then
        log_info "Seleccionando tema WhiteSur en Kvantum..."
        kvantummanager --set WhiteSur 2>/dev/null || \
            log_warn "kvantummanager --set falló, aplica manualmente el tema WhiteSur en kvantummanager"
    fi

    stamp_done "kde-settings"
}

# -----------------------------------------------------------------------------
# Función de desinstalación (bonus)
# -----------------------------------------------------------------------------

uninstall_all() {
    log_section "Desinstalando temas macOS..."

    local repo_gtk="$THEME_REPOS_DIR/MacTahoe-gtk-theme"
    local repo_icons="$THEME_REPOS_DIR/MacTahoe-icon-theme"
    local repo_kde="$THEME_REPOS_DIR/WhiteSur-kde"
    local repo_cursors="$THEME_REPOS_DIR/WhiteSur-cursors"

    [[ -d "$repo_gtk" ]]     && bash "$repo_gtk/install.sh"     --remove --silent-mode
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
    echo -e "\n${BOLD}KDE macOS Tahoe Theme Setup${RESET}"
    echo -e "Repo cache : ${CYAN}$THEME_REPOS_DIR${RESET}"
    echo -e "Stamps     : ${CYAN}$INSTALL_STAMPS_DIR${RESET}"
    [[ "$FORCE_REINSTALL" == "--force" ]] && echo -e "${YELLOW}Modo --force: se reinstala todo${RESET}"
    [[ "$FORCE_REINSTALL" == "--uninstall" ]] && { uninstall_all; exit 0; }

    mkdir -p "$THEME_REPOS_DIR" "$THEMES_DIR" "$ICONS_DIR" "$FONTS_DIR"

    check_deps

    install_mactahoe_gtk
    install_mactahoe_icons
    install_whitesur_kde
    install_whitesur_cursors
    install_sf_fonts
    fix_flatpak_themes
    install_firefox_theme
    apply_kde_settings

    echo -e "\n${BOLD}${GREEN}✓ Setup completo.${RESET}"
    echo -e "  Reinicia la sesión KDE (o ejecuta ${CYAN}kquitapp5 plasmashell && kstart5 plasmashell${RESET}) para aplicar todos los cambios."
    echo ""
}

main "$@"
