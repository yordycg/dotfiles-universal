# bootstrap-wsl.ps1 - Zero-Touch provisioning de WSL Ubuntu-24.04
# Prerrequisitos: gh auth login hecho, wsl --install hecho.

$DISTRO = "Ubuntu-24.04"
$REPO_URL = "https://github.com/yordycg/dotfiles-universal.git"
$ErrorActionPreference = "Stop"

# 1. Detectar Llave en Windows (Nativo)
$WinKeyPath = ""
if (Test-Path "$HOME\.config\age\key.txt") { $WinKeyPath = "$HOME\.config\age\key.txt" }
elseif (Test-Path "$HOME\.config\chezmoi\key.txt") { $WinKeyPath = "$HOME\.config\chezmoi\key.txt" }

Write-Host "==> [1/3] Instalando chezmoi en WSL..." -ForegroundColor Cyan
wsl -d $DISTRO -- bash -c "curl -fsLS get.chezmoi.io | bash -s -- -b ~/.local/bin"

Write-Host "==> [2/3] Sincronizando identidad..." -ForegroundColor Cyan
if ($WinKeyPath) {
    $WslUser = (wsl -d $DISTRO -- bash -c "whoami").Trim()
    $WslDestDir = "\\wsl.localhost\$DISTRO\home\$WslUser\.config\age"
    wsl -d $DISTRO -- bash -c "mkdir -p ~/.config/age"
    
    if (Test-Path $WslDestDir) {
        Copy-Item -Path $WinKeyPath -Destination "$WslDestDir\key.txt" -Force
        wsl -d $DISTRO -- bash -c "chmod 600 ~/.config/age/key.txt"
        Write-Host "    - age key.txt inyectada exitosamente via WSL Network" -ForegroundColor Green
    } else {
        Write-Host "    ! No se pudo acceder a la ruta de red de WSL. Usando fallback..." -ForegroundColor Yellow
        $KeyContent = Get-Content $WinKeyPath -Raw
        $KeyContent | wsl -d $DISTRO -- bash -c "cat > ~/.config/age/key.txt && chmod 600 ~/.config/age/key.txt"
    }
}

Write-Host "==> [3/3] Aplicando Dotfiles Universales..." -ForegroundColor Cyan
$t = (gh auth token 2>$null)
if (-not $t) {
    Write-Error "gh CLI no autenticado. Ejecuta: gh auth login"
    exit 1
}

# Ejecutar init con URL explicita y PATH asegurado
# Usamos --force para sobreescribir cualquier rastro anterior
$initCmd = "export GITHUB_TOKEN='" + $t + "'; export PATH=`$HOME/.local/bin:`$PATH; ~/.local/bin/chezmoi init --apply --force " + $REPO_URL
wsl -d $DISTRO -- bash -c "$initCmd"

Write-Host ""
Write-Host "==> WSL configurado exitosamente." -ForegroundColor Green
Write-Host "    Entra con: wsl -d $DISTRO" -ForegroundColor Green
Write-Host "    Nota: Si no ves el prompt de Starship, escribe 'zsh'" -ForegroundColor Yellow
