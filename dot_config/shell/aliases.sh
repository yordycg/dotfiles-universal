# -- Navegacion ---------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'
alias ws='cd ~/workspace'
alias as='cd ~/workspace/assets'
alias pr='cd ~/workspace/personal'
alias wk='cd ~/workspace/work'
alias iv='cd ~/workspace/ivpg'

# -- Reemplazos modernos -----------------------
alias ls='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias lt='eza -tree --icons --level=3'
alias cat='bat --paging=never'
alias grep='rg'
alias find='fd'
alias top='btop'

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
alias cza='chezmoi apply -v'
alias czd='chezmoi diff'
alias cze='chezmoi edit'
alias czu='chezmoi update'
alias czs='chezmoit source-path'

# -- Sistema ----------------------------------
alias lv='NVIM_APPNAME=LazyVim nvim'
alias nv='NVIM_APPNAME=nvim-personal nvim'
alias v='nv'
alias reload='source ~/.zshrc'
alias path='echo $PATH | tr ":" "\n"'
alias ports='ss -tulnp'
alias myip='curl -s ifconfig.me'
alias logout='loginctl terminate-user $USER'
alias shutdown='sudo shutdown now'
alias restart='sudo reboot'

