# bootstrap-wsl.ps1 — Zero-Touch provisioning de WSL Ubuntu-24.04
# Prerrequisitos:
#   - key.txt en Windows: $HOME\.config\age\key.txt o $HOME\.config\chezmoi\key.txt
#   - SSH keys en Windows: $HOME\.ssh\
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
# WSL hereda la identidad desde el filesystem Windows montado en /mnt/c/...
wsl -d $DISTRO -- bash -c @"
set -euo pipefail

# Crear directorios base
mkdir -p ~/.config/chezmoi ~/.config/age ~/.local/bin ~/.ssh

# Intentar copiar key.txt desde las rutas conocidas de Windows
WIN_USER=\$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n')
# Probar ruta preferida (age) primero, luego chezmoi
KEY_AGE="/mnt/c/Users/\$WIN_USER/.config/age/key.txt"
KEY_CHEZMOI="/mnt/c/Users/\$WIN_USER/.config/chezmoi/key.txt"

if [ -f "\$KEY_AGE" ]; then
    cp "\$KEY_AGE" ~/.config/age/key.txt
    chmod 600 ~/.config/age/key.txt
    echo "  ✓ age key.txt copiada desde .config/age"
elif [ -f "\$KEY_CHEZMOI" ]; then
    cp "\$KEY_CHEZMOI" ~/.config/age/key.txt
    chmod 600 ~/.config/age/key.txt
    echo "  ✓ age key.txt copiada desde .config/chezmoi"
else
    echo "  ⚠ Sin age key encontrada en Windows, continuando sin secretos."
fi

# Inicializar chezmoi con el token de Windows
# La variable GITHUB_TOKEN permite a chezmoi clonar el repo privado sin prompts
GITHUB_TOKEN=$t ~/.local/bin/chezmoi init --apply yordycg
"@

Write-Host "`n==> WSL configurado exitosamente." -ForegroundColor Green
Write-Host "    Entra con: wsl -d $DISTRO" -ForegroundColor Green
