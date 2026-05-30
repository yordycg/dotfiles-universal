# bootstrap-wsl.ps1 — Zero-Touch provisioning de WSL Ubuntu-24.04
# Llamado desde: just bootstrap-wsl
# Prerequisitos: gh auth login hecho, wsl --install -d Ubuntu-24.04 hecho.

$DISTRO = "Ubuntu-24.04"
$ErrorActionPreference = "Stop"

Write-Host "==> [1/4] Preparando directorios en WSL..." -ForegroundColor Cyan
wsl -d $DISTRO -- bash -c "mkdir -p ~/.config/chezmoi ~/.local/bin"

Write-Host "==> [2/4] Inyectando age key..." -ForegroundColor Cyan
$keyFile = "$HOME\.config\chezmoi\key.txt"
if (Test-Path $keyFile) {
    Get-Content $keyFile -Raw -Encoding UTF8 | wsl -d $DISTRO -- bash -c "cat > ~/.config/chezmoi/key.txt && chmod 600 ~/.config/chezmoi/key.txt"
    Write-Host "    age key inyectada." -ForegroundColor Green
} else {
    Write-Host "    Sin age key, continuando sin secretos." -ForegroundColor Yellow
}

Write-Host "==> [3/4] Instalando chezmoi en WSL..." -ForegroundColor Cyan
wsl -d $DISTRO -- bash -c "curl -fsLS get.chezmoi.io | bash -s -- -b ~/.local/bin"

Write-Host "==> [4/4] Inicializando dotfiles..." -ForegroundColor Cyan
$ghToken = (gh auth token 2>$null)
if (-not $ghToken) {
    Write-Error "gh CLI no autenticado. Ejecuta primero: gh auth login"
    exit 1
}
wsl -d $DISTRO -- bash -c "GITHUB_TOKEN=$ghToken ~/.local/bin/chezmoi init --apply yordycg"

Write-Host "`n==> Listo. Entra con: wsl -d $DISTRO" -ForegroundColor Green
