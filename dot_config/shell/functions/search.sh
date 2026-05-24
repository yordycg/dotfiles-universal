#!/usr/bin/env bash

# --- Smart Path & Search Utilities ---

# Picker inteligente con visualización optimizada para rutas largas (Zoxide + FD + FZF)
function _smart_path_picker() {
  local INITIAL_QUERY="$1"
  local selection
  
  # Formateo: Home -> ~, Gris para ruta, Azul para carpeta final
  local fmt_cmd='sed "s|$HOME|~|" | awk -F/ "{last=\$NF; path=\"\"; for(i=1; i<NF; i++) path=path \$i \"/\"; print \"\033[38;5;244m\" path \"\033[1;34m\" last \"\033[0m\"}"'

  selection=$( (zoxide query -l; fd --type d --max-depth 2 . "$HOME") | \
    awk '!seen[$0]++' | \
    eval "$fmt_cmd" | fzf \
    --ansi \
    --height 60% \
    --layout=reverse \
    --border=rounded \
    --prompt="Destino: " \
    --query="$INITIAL_QUERY" \
    --keep-right \
    --tiebreak=end,length \
    --header="[ENTER] Confirmar | [ALT-D] Búsqueda profunda | [ALT-Z] Zoxide" \
    --bind "alt-d:reload(fd --type d --hidden --exclude .git . $HOME | $fmt_cmd)" \
    --bind "alt-z:reload(zoxide query -l | $fmt_cmd)" \
    --preview 'p=$(echo {} | sed "s/\x1b\[[0-9;]*m//g"); p=${p/\~/$HOME}; eza --icons --tree --level=2 --color=always "$p" | head -50' \
    --preview-window="right:50%:wrap" )

  if [[ -n "$selection" ]]; then
    local clean_path=$(echo "$selection" | sed 's/\x1b\[[0-9;]*m//g')
    echo "${clean_path/\~/$HOME}"
  fi
}

# Copiar archivo a destino seleccionado interactivamente
function cpz() {
  if [[ $# -lt 1 ]]; then
    echo "Uso: cpz <archivo> [termino_busqueda]"
    return 1
  fi
  local file="$1"
  shift
  local dest=$(_smart_path_picker "$*")
  [[ -n "$dest" ]] && cp -rv "$file" "$dest"
}

# Mover archivo a destino seleccionado interactivamente
function mvz() {
  if [[ $# -lt 1 ]]; then
    echo "Uso: mvz <archivo> [termino_busqueda]"
    return 1
  fi
  local file="$1"
  shift
  local dest=$(_smart_path_picker "$*")
  [[ -n "$dest" ]] && mv -iv "$file" "$dest"
}

# Buscar texto con ripgrep y abrir en nvim en la línea exacta
function findedit() {
  local file=$(
    rg --line-number --no-heading --color=always --smart-case "$*" |
      fzf --ansi --preview "bat --color=always {1} --highlight-line {2}"
  )
  if [[ -n $file ]]; then
    nvim "$(echo "$file" | cut -d':' -f1)" "+$(echo "$file" | cut -d':' -f2)"
  fi
}
