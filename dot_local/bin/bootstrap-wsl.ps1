# bootstrap-wsl.ps1 — Zero-Touch provisioning de WSL Ubuntu-24.04
# Prerrequisitos:
#   - key.txt en $HOME\.config\chezmoi\key.txt
#   - SSH keys en $HOME\.ssh\
#   - gh auth login ejecutado en Windows
#   - wsl --install -d Ubuntu-24.04 hecho y primer login completado

$DISTRO = "Ubuntu-24.04"
$ErrorActionPreference = "Stop"

Write-Host "==> [1/3] Instalando chezmoi en WSL..." -ForegroundColor Cyan
wsl -d $DISTRO -- bash -c "curl -fsLS get.chezmoi.io | bash -s -- -b ~/.local/bin"

Write-Host "==> [2/3] Verificando token de GitHub..." -ForegroundColor Cyan
$t = gh auth token 2>$null
if (-not $t) {
    Write-Error "gh CLI no autenticado. Ejecuta primero: gh auth login"
    exit 1
}

Write-Host "==> [3/3] Inicializando dotfiles en WSL..." -ForegroundColor Cyan
# WSL copia key.txt desde el mount de Windows (/mnt/c/...)
# Todo ocurre dentro de bash — sin tuberías cross-OS, sin comillas anidadas
wsl -d $DISTRO -- bash -c @"
set -euo pipefail

# Crear directorios
mkdir -p ~/.config/chezmoi ~/.local/bin ~/.ssh

# Copiar key.txt desde el filesystem Windows montado en WSL
WIN_USER=\$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n')
KEY_SRC="/mnt/c/Users/\$WIN_USER/.config/chezmoi/key.txt"
if [ -f "\$KEY_SRC" ]; then
    cp "\$KEY_SRC" ~/.config/chezmoi/key.txt
    chmod 600 ~/.config/chezmoi/key.txt
    echo "  age key.txt copiada."
else
    echo "  Sin age key, continuando sin secretos."
fi

# Inicializar chezmoi con token inyectado via variable de entorno
# La variable nunca toca el historial de shell
GITHUB_TOKEN=$t ~/.local/bin/chezmoi init --apply yordycg
"@

Write-Host "`n==> Listo. Entra con: wsl -d $DISTRO" -ForegroundColor Green
Write-Host "    Luego ejecuta 'bwu' para desbloquear Vaultwarden." -ForegroundColor Green
