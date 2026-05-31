# bootstrap-wsl.ps1 - Zero-Touch provisioning de WSL Ubuntu-24.04
# Prerrequisitos: gh auth login hecho, wsl --install hecho.

$DISTRO = "Ubuntu-24.04"
$ErrorActionPreference = "Stop"

# 1. Detectar Llave en Windows (Nativo)
$WinKeyPath = ""
if (Test-Path "$HOME\.config\age\key.txt") { 
    $WinKeyPath = "$HOME\.config\age\key.txt" 
}
elseif (Test-Path "$HOME\.config\chezmoi\key.txt") { 
    $WinKeyPath = "$HOME\.config\chezmoi\key.txt" 
}

Write-Host "==> [1/3] Instalando chezmoi en WSL..." -ForegroundColor Cyan
wsl -d $DISTRO -- bash -c "curl -fsLS get.chezmoi.io | bash -s -- -b ~/.local/bin"

Write-Host "==> [2/3] Sincronizando identidad..." -ForegroundColor Cyan
if ($WinKeyPath) {
    $WslKeyPath = wsl -d $DISTRO -- wslpath $WinKeyPath
    wsl -d $DISTRO -- bash -c "mkdir -p ~/.config/age; cp '$WslKeyPath' ~/.config/age/key.txt; chmod 600 ~/.config/age/key.txt"
    Write-Host "    - age key.txt inyectada correctamente" -ForegroundColor Green
} else {
    Write-Host "    ! No se encontro key.txt en Windows. Continuando sin secretos." -ForegroundColor Yellow
}

Write-Host "==> [3/3] Inicializando dotfiles en WSL..." -ForegroundColor Cyan
$t = (gh auth token 2>$null)
if (-not $t) {
    Write-Error "gh CLI no autenticado. Ejecuta primero: gh auth login"
    exit 1
}

# Ejecutar init inyectando el token de forma simple
$initCmd = "export GITHUB_TOKEN='" + $t + "'; ~/.local/bin/chezmoi init --apply yordycg"
wsl -d $DISTRO -- bash -c "$initCmd"

Write-Host ""
Write-Host "==> WSL configurado exitosamente." -ForegroundColor Green
Write-Host "    Entra con: wsl -d Ubuntu-24.04" -ForegroundColor Green
