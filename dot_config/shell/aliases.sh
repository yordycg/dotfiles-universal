# -- Sistema & Navegación -----------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'
alias c='clear'
alias x='exit'
alias path='echo $PATH | tr ":" "\n"'
alias ports='ss -tulnp'
alias myip='curl -s ifconfig.me'

# -- Workspace ----------------------------------
alias ws='cd ~/workspace'
alias as='cd ~/workspace/assets'
alias pr='cd ~/workspace/personal'
alias wk='cd ~/workspace/work'
alias iv='cd ~/workspace/ipvg'
alias dev='distrobox enter dev-box'

# -- Reemplazos modernos -----------------------
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --git --group-directories-first'
alias la='eza -lah --icons --git --group-directories-first'
alias lt='eza --tree --icons --level=3'
alias cat='bat --paging=never'
alias grep='rg'
alias find='fd'
alias top='btop'
alias h='history | grep'

# -- Zoxide ------------------------------------
alias zi='zi'

# -- Git --------------------------------------
alias g='git'
alias gs='git status -sb'
alias gl='git lg'
alias gP='git push'
alias gp='git pull'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gb='git branch'
alias lg='lazygit'

# -- Chezmoi ---------------------------------
alias cz='chezmoi'
alias cza='chezmoi apply'
alias czd='chezmoi diff'
alias cze='chezmoi edit'
alias czu='chezmoi update'
alias czs='chezmoi source-path'

# -- Editores ----------------------------------
lv() {
    if command -v distrobox &>/dev/null && distrobox list | grep -Fw "dev-box" &>/dev/null; then
        distrobox enter dev-box -- env NVIM_APPNAME=LazyVim nvim "$@"
    else
        env NVIM_APPNAME=LazyVim nvim "$@"
    fi
}
alias nv='NVIM_APPNAME=nvim-personal nvim'
alias v='nv'
alias v.='nv .'
alias reload='source ~/.zshrc && echo "ZSH Reloaded!"'

# -- Lenguajes & Dev (Senior Lean) ------------
alias pn='pnpm'
alias pnrd='pnpm run dev'
alias py='python3'
alias va='source .venv/bin/activate'
alias vd='deactivate'

# -- Homelab Aliases ---------------------------
alias hl='hl'
alias hls='ssh homelab tmux ls'
alias hlk='ssh homelab tmux kill-session -t'
alias lab-forward='ssh -N -L'
alias lps='lab-status'

# -- Bases de Datos ----------------------------
alias lsql='lazysql'

# -- Sistema (Continuación) -------------------
alias logout='loginctl terminate-user $USER'
alias shutdown='sudo shutdown now'
alias restart='sudo reboot'
