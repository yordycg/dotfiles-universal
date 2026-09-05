#!/usr/bin/env bash
# =============================================================================
# run_once_after_98-xdg-migration.sh
# Migración one-shot a XDG Base Directory (Clean Host).
# Mueve los directorios de data/cache que las herramientas crearon en $HOME
# (~/.cargo, ~/.rustup, ~/go, ~/.npm, ~/.nuget, ~/.dotnet, ~/.bun) a sus
# nuevas ubicaciones XDG definidas en ~/.config/shell/exports.sh y
# ~/.config/environment.d/. Idempotente y tolerante: no pisa datos existentes.
# =============================================================================
set -euo pipefail

H="$HOME"
DATA="$H/.local/share"
CACHE="$H/.cache"
STATE="$H/.local/state"
MARKER="$H/.cache/chezmoi-scripts/xdg-migration-state"

[ -f "$MARKER" ] && exit 0

log()  { echo -e "\033[0;36m▶ $1\033[0m"; }
ok()   { echo -e "\033[0;32m  ✓ $1\033[0m"; }
warn() { echo -e "\033[1;33m  ⚠ $1\033[0m"; }

# move_dir <src> <dst>: mueve src → dst sin pisar nada existente
move_dir() {
    local src="$1" dst="$2"
    [ -e "$src" ] || return 0
    if [ -L "$src" ]; then
        warn "Ignorando symlink $src (no se migra)."
        return 0
    fi
    if [ -e "$dst" ]; then
        if [ -n "$(ls -A "$dst" 2>/dev/null)" ]; then
            warn "$dst ya existe y no está vacío; omite migración de $src."
            return 0
        fi
        rmdir "$dst"
    fi
    mkdir -p "$(dirname "$dst")"
    if mv "$src" "$dst" 2>/dev/null; then
        ok "Migrado $src → $dst"
    else
        warn "Fallo al mover $src → $dst."
    fi
}

# move_into <src> <dst>: mueve el CONTENIDO de src dentro de dst (creándolo)
move_into() {
    local src="$1" dst="$2"
    [ -d "$src" ] || return 0
    mkdir -p "$dst"
    local item moved=0
    for item in "$src"/* "$src"/.[!.]* "$src"/..?*; do
        [ -e "$item" ] || continue
        local base
        base="$(basename "$item")"
        if [ -e "$dst/$base" ]; then
            warn "$dst/$base ya existe; omite $(basename "$src")/$base."
        else
            mv "$item" "$dst/$base" 2>/dev/null && moved=1
        fi
    done
    [ "$moved" = 1 ] && ok "Contenido de $src movido a $dst"
    rmdir "$src" 2>/dev/null || true
}

log "Migración a XDG (Clean Host)"

# ── 1. Rust: CARGO_HOME / RUSTUP_HOME ──────────────────────────────────────
move_dir "$H/.cargo"  "$DATA/cargo"
move_dir "$H/.rustup" "$DATA/rustup"

# Re-enlazar el backend rust de mise si apuntaba al antiguo ~/.cargo/bin
RUST_INSTALLS="$H/.local/share/mise/installs/rust"
if [ -d "$RUST_INSTALLS" ] && [ -d "$DATA/cargo/bin" ]; then
    for v in "$RUST_INSTALLS"/*; do
        [ -L "$v" ] || continue
        tgt="$(readlink "$v")"
        if [ "$tgt" = "$H/.cargo/bin" ]; then
            rm "$v"
            ln -s "$DATA/cargo/bin" "$v"
            ok "mise rust re-enlazado: $v → $DATA/cargo/bin"
        fi
    done
fi

# ── 2. Go: GOPATH ──────────────────────────────────────────────────────────
move_dir "$H/go" "$DATA/go"

# ── 3. Node/npm: cache → ~/.cache/npm ──────────────────────────────────────
move_into "$H/.npm" "$CACHE/npm"

# ── 4. .NET / NuGet ────────────────────────────────────────────────────────
move_dir "$H/.dotnet" "$DATA/dotnet"
[ -d "$H/.nuget/packages" ] && move_dir "$H/.nuget/packages" "$DATA/NuGet/packages"

# ── 5. Bun ─────────────────────────────────────────────────────────────────
move_dir "$H/.bun" "$DATA/bun"

# ── 6. Historial de zsh → XDG_STATE_HOME ───────────────────────────────────
OLD_HIST="$H/.zsh_history"
NEW_HIST="$STATE/zsh/history"
if [ -f "$OLD_HIST" ] && [ -s "$OLD_HIST" ]; then
    mkdir -p "$(dirname "$NEW_HIST")"
    if [ -f "$NEW_HIST" ]; then
        warn ".zsh_history nuevo ya existe; se conserva el historial antiguo en $OLD_HIST"
    else
        if mv "$OLD_HIST" "$NEW_HIST"; then
            ok "Historial zsh migrado → $NEW_HIST"
        else
            warn "No se pudo mover el historial zsh."
        fi
    fi
fi

# ── 7. Legado regenerable ──────────────────────────────────────────────────
if [ -f "$H/.zcompdump" ]; then
    rm -f "$H/.zcompdump" && ok "Eliminado .zcompdump legacy (se regenera en ~/.cache/zsh)"
fi

# ── 8. Marcador de estado ──────────────────────────────────────────────────
mkdir -p "$(dirname "$MARKER")"
touch "$MARKER"
ok "Migración XDG completada."
