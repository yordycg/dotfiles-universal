#!/usr/bin/env bash

# --- [git] Interactive Git Tools with FZF ---

# [git] Interactive Add (gafzf)
function gafzf() {
    local files
    files=$(git ls-files -m -o --exclude-standard | fzf -m \
        --preview 'git diff --color=always {} | head -100' \
        --header "Tab to multi-select | Enter to add to stage" \
        --preview-window right:65%)
    if [[ -n "$files" ]]; then
        echo "$files" | xargs git add
        log_ok "Archivos añadidos al stage." "󰊢"
    fi
}

# [git] Interactive Branch Switch (gbfzf)
function gbfzf() {
    local branch
    branch=$(git branch --all | grep -v 'HEAD' | fzf --ansi --no-multi \
        --preview-window right:65% \
        --header "Enter to checkout branch" \
        --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(echo {} | sed "s/.* //" | sed "s#remotes/[^/]*/##")' \
        | sed "s/.* //" | sed "s#remotes/[^/]*/##")
    if [[ -n "$branch" ]]; then
        git checkout "$branch"
        log_ok "Cambiado a rama $branch" "󱓞"
    fi
}

# [git] Interactive Log (glfzf)
function glfzf() {
    local commit
    commit=$(git log --color=always --pretty=format:'%C(auto)%h %s %C(green)(%cr) %C(bold blue)<%an>%C(reset)' | \
        fzf --ansi --no-multi --no-sort --preview-window right:65% \
        --preview 'git show --color=always $(echo {} | awk "{print \$1}")' \
        --header "Enter to copy hash to clipboard")
    if [[ -n "$commit" ]]; then
        local hash=$(echo "$commit" | awk '{print $1}')
        if command -v wl-copy &>/dev/null; then
            echo -n "$hash" | wl-copy
        elif command -v xclip &>/dev/null; then
            echo -n "$hash" | xclip -selection clipboard
        fi
        log_ok "Hash $hash copiado al portapapeles." "󰅍"
    fi
}

# [git] Interactive Stash (gsfzf)
function gsfzf() {
    local stash
    stash=$(git stash list | fzf --ansi --no-multi --preview-window right:65% \
        --preview 'git stash show -p --color=always $(echo {} | awk -F: "{print \$1}")' \
        --header "Enter to apply stash")
    if [[ -n "$stash" ]]; then
        local id=$(echo "$stash" | awk -F: '{print $1}')
        git stash apply "$id"
        log_ok "Stash $id aplicado." "󰄺"
    fi
}

# [git] Smart Fixup (gfix)
function gfix() {
    if git diff --cached --quiet; then
        log_warn "No hay archivos en el stage area." "󰈚"
        return 1
    fi

    local target
    target=$(git log -n 20 --color=always --pretty=format:'%C(auto)%h %s %C(green)(%cr) %C(bold blue)<%an>%C(reset)' | \
        fzf --ansi --no-multi --header "Select commit to fixup")

    [[ -z "$target" ]] && return 0

    local hash=$(echo "$target" | awk '{print $1}')
    git commit --fixup "$hash"
    GIT_EDITOR=true git rebase -i --autosquash "${hash}^"
    
    log_ok "Fixup aplicado y rebase completado para $hash" "󰁨"
}
