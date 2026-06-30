#!/usr/bin/env bash
#
# passage-rofi: menu rofi para passage (age) en Hyprland/Wayland
#
# Requiere: passage, rofi, wl-clipboard (wl-copy), jq (opcional, no usado),
#           coreutils. Para passphrases: una wordlist EFF (ver WORDLIST abajo).
#
# Instalacion sugerida: ~/.local/bin/passage-rofi.sh (+ chmod +x)
# Bind en Hyprland (hyprland.conf):
#   bind = $mod, P, exec, ~/.local/bin/passage-rofi.sh
#
set -euo pipefail

# Asegurar acceso a binarios locales, shims de Mise y Cargo
export PATH="$HOME/.local/share/mise/shims:$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

# ---------- Config ----------
PREFIX="${PASSAGE_DIR:-$HOME/.passage/store}"
CLIP_TIME="${PASSAGE_CLIP_TIME:-45}"
ROFI_PROMPT="passage"
WORDLIST="${PASSAGE_WORDLIST:-$HOME/.local/share/passage-rofi/eff_large_wordlist.txt}"
ROFI_THEME="${PASSAGE_ROFI_THEME:-}"   # ej: ~/.config/rofi/passage.rasi (opcional)

rofi_cmd=(rofi -dmenu -i -p "$ROFI_PROMPT")
[[ -n "$ROFI_THEME" ]] && rofi_cmd+=(-theme "$ROFI_THEME")

notify() {
    notify-send -a "passage" "$1" "${2:-}" || true
}

clip() {
    # copia stdin al portapapeles wayland y lo limpia luego de CLIP_TIME segundos
    local content
    content="$(cat)"
    
    # Validar si el contenido está vacío (indica un fallo al obtener la pass)
    if [[ -z "$content" ]]; then
        notify "passage" "Error: No se pudo obtener el contenido." "Verifica tu configuración o que la entrada exista."
        exit 1
    fi
    
    printf '%s' "$content" | wl-copy
    notify "passage" "Copiado. Se borra en ${CLIP_TIME}s."
    (
        sleep "$CLIP_TIME"
        # solo borra si el portapapeles sigue teniendo lo mismo
        current="$(wl-paste 2>/dev/null || true)"
        if [[ "$current" == "$content" ]]; then
            wl-copy --clear
        fi
    ) & disown
}

list_entries() {
    shopt -s nullglob globstar
    local files=( "$PREFIX"/**/*.age )
    local out=()
    for f in "${files[@]}"; do
        f="${f#"$PREFIX"/}"
        f="${f%.age}"
        out+=("$f")
    done
    printf '%s\n' "${out[@]}" | sort
}

choose_entry() {
    list_entries | "${rofi_cmd[@]}" -p "$ROFI_PROMPT (selecciona o escribe)"
}

action_copy_password() {
    local entry="$1"
    passage show "$entry" 2>/dev/null | head -n1 | clip
}

action_copy_field() {
    local entry="$1"
    local field
    field=$(passage show "$entry" 2>/dev/null | tail -n +2 \
        | "${rofi_cmd[@]}" -p "campo de $entry")
    [[ -z "$field" ]] && exit 0
    # field es la linea completa tipo "user: foo" -> copiamos lo de despues de ":"
    local value="${field#*: }"
    printf '%s' "$value" | clip
}

action_view_entry() {
    local entry="$1"
    passage show "$entry" 2>/dev/null \
        | "${rofi_cmd[@]}" -p "$entry (solo lectura)"
}

action_edit_entry() {
    local entry="$1"
    # Abre Kitty como ventana flotante y centrada ejecutando 'passage edit'
    kitty --class floating_kitty -e passage edit "$entry"
}

action_generate_password() {
    local name length symbols_flag opt password
    
    # 1. Pedir nombre (cuadro de texto limpio con -l 0)
    name=$(echo "" | "${rofi_cmd[@]}" -p "Nombre de la entrada (ej: github/usuario)" -l 0)
    [[ -z "$name" ]] && exit 0

    # 2. Pedir largo (cuadro de texto limpio con -l 0)
    length=$(echo "" | "${rofi_cmd[@]}" -p "Largo de la contraseña [Default: 20]" -l 0)
    length="${length:-20}"

    # 3. Pedir si lleva símbolos (menú de selección)
    symbols_flag=$(printf "Sí (con símbolos)\nNo (solo letras y números)" | "${rofi_cmd[@]}" -p "Tipo")
    
    opt=""
    [[ "$symbols_flag" == "No (solo letras y números)" ]] && opt="-n"

    # 4. Generar y capturar la contraseña (está en la segunda línea de la salida)
    password=$(passage generate $opt "$name" "$length" 2>/dev/null | tail -n1 || echo "")
    
    if [[ -z "$password" ]]; then
        notify "passage" "Error" "No se pudo generar la contraseña."
        exit 1
    fi

    # 5. Copiar al portapapeles y enviar notificación con la contraseña visible
    printf '%s' "$password" | clip
    notify "passage" "Generada con éxito para: $name" "Contraseña: $password"
}

action_generate_passphrase() {
    local name words sep phrase
    if [[ ! -f "$WORDLIST" ]]; then
        notify "passage" "Error" "Falta la lista de palabras en $WORDLIST."
        exit 1
    fi

    # 1. Pedir nombre (cuadro de texto limpio con -l 0)
    name=$(echo "" | "${rofi_cmd[@]}" -p "Nombre de la entrada (ej: ssh/llave)" -l 0)
    [[ -z "$name" ]] && exit 0

    # 2. Pedir cantidad de palabras (cuadro de texto limpio con -l 0)
    words=$(echo "" | "${rofi_cmd[@]}" -p "Cantidad de palabras [Default: 6]" -l 0)
    words="${words:-6}"

    # 3. Pedir separador (menú de selección)
    sep=$(printf -- "-\n.\n espacio\n_" | "${rofi_cmd[@]}" -p "Separador")
    case "$sep" in
        " espacio") sep=" " ;;
        "") sep="-" ;;
    esac

    # 4. Generar la frase usando la lista de palabras
    phrase=$(shuf -n "$words" --random-source=/dev/urandom "$WORDLIST" \
        | awk '{print $NF}' | paste -sd "$sep" -)

    if [[ -z "$phrase" ]]; then
        notify "passage" "Error" "No se pudo generar la frase."
        exit 1
    fi

    # 5. Guardar en la bóveda, copiar y enviar notificación con la frase visible
    printf '%s\n' "$phrase" | passage insert -m -f "$name" >/dev/null
    printf '%s' "$phrase" | clip
    notify "passage" "Generada con éxito para: $name" "Frase: $phrase"
}

action_delete_entry() {
    local entry="$1"
    local confirm
    confirm=$(printf 'no\nsi, borrar' | "${rofi_cmd[@]}" -p "borrar $entry?")
    [[ "$confirm" == "si, borrar" ]] && passage rm -f "$entry" && notify "passage" "Eliminado: $entry"
}

main_menu() {
    local choice
    choice=$(printf 'Buscar/copiar password\nCopiar otro campo (user, url, etc)\nVer entrada\nCrear / Editar entrada\nGenerar password nuevo\nGenerar passphrase nueva\nEliminar entrada' \
        | "${rofi_cmd[@]}" -p "passage - accion")

    case "$choice" in
        "Buscar/copiar password")
            entry=$(choose_entry) || exit 0
            [[ -n "$entry" ]] && action_copy_password "$entry"
            ;;
        "Copiar otro campo (user, url, etc)")
            entry=$(choose_entry) || exit 0
            [[ -n "$entry" ]] && action_copy_field "$entry"
            ;;
        "Ver entrada")
            entry=$(choose_entry) || exit 0
            [[ -n "$entry" ]] && action_view_entry "$entry"
            ;;
        "Crear / Editar entrada")
            entry=$(choose_entry) || exit 0
            [[ -n "$entry" ]] && action_edit_entry "$entry"
            ;;
        "Generar password nuevo")
            action_generate_password
            ;;
        "Generar passphrase nueva")
            action_generate_passphrase
            ;;
        "Eliminar entrada")
            entry=$(choose_entry) || exit 0
            [[ -n "$entry" ]] && action_delete_entry "$entry"
            ;;
        *)
            exit 0
            ;;
        esac
}

main_menu
