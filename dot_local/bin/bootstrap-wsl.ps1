# bootstrap-wsl.ps1 — Zero-Touch provisioning de WSL Ubuntu-24.04
# Prerrequisitos: gh auth login hecho, wsl --install hecho.

$DISTRO = "Ubuntu-24.04"
$ErrorActionPreference = "Stop"

# 1. Detectar Llave en Windows (Nativo)
$WinKeyPath = ""
if (Test-Path "$HOME\.config\age\key.txt") { $WinKeyPath = "$HOME\.config\age\key.txt" }
elseif (Test-Path "$HOME\.config\chezmoi\key.txt") { $WinKeyPath = "$HOME\.config\chezmoi\key.txt" }

Write-Host "==> [1/3] Instalando chezmoi en WSL..." -ForegroundColor Cyan
wsl -d $DISTRO -- bash -c "curl -fsLS get.chezmoi.io | bash -s -- -b ~/.local/bin"

Write-Host "==> [2/3] Sincronizando identidad..." -ForegroundColor Cyan
if ($WinKeyPath) {
    $WslKeyPath = wsl -d $DISTRO -- wslpath $WinKeyPath
    wsl -d $DISTRO -- bash -c "mkdir -p ~/.config/age; cp '$WslKeyPath' ~/.config/age/key.txt; chmod 600 ~/.config/age/key.txt"
    Write-Host "    ✓ age key.txt inyectada desde $WinKeyPath" -ForegroundColor Green
} else {
    Write-Host "    ⚠ No se encontró key.txt en Windows. Continuando sin secretos." -ForegroundColor Yellow
}

Write-Host "==> [3/3] Inicializando dotfiles en WSL..." -ForegroundColor Cyan
$ghToken = (gh auth token 2>$null)
if (-not $ghToken) {
    Write-Error "gh CLI no autenticado. Ejecuta: gh auth login"
    exit 1
}

# Usar variable explícita para evitar errores de interpolación en PowerShell
$InitBashCmd = "export GITHUB_TOKEN='${ghToken}'; ~/.local/bin/chezmoi init --apply yordycg"
wsl -d $DISTRO -- bash -c $InitBashCmd

Write-Host "`n==> WSL configurado exitosamente." -ForegroundColor Green
Write-Host "    Entra con: wsl -d $DISTRO" -ForegroundColor Green
