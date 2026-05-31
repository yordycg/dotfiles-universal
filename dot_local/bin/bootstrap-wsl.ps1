# bootstrap-wsl.ps1 - Zero-Touch provisioning de WSL Ubuntu-24.04
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
    # Obtener el home de WSL dinamicamente para no asumir /home/yordycg
    $WslUser = (wsl -d $DISTRO -- bash -c "whoami").Trim()
    $WslDestDir = "\\wsl.localhost\$DISTRO\home\$WslUser\.config\age"
    
    # Crear directorio en WSL usando comando Linux
    wsl -d $DISTRO -- bash -c "mkdir -p ~/.config/age"
    
    # Copiar llave usando el filesystem de red de Windows (Cero errores de escape)
    if (Test-Path $WslDestDir) {
        Copy-Item -Path $WinKeyPath -Destination "$WslDestDir\key.txt" -Force
        wsl -d $DISTRO -- bash -c "chmod 600 ~/.config/age/key.txt"
        Write-Host "    - age key.txt inyectada exitosamente vía WSL Network" -ForegroundColor Green
    } else {
        Write-Host "    ! No se pudo acceder a la ruta de red de WSL. Intentando fallback manual..." -ForegroundColor Yellow
        # Fallback si la red de WSL no esta lista
        $KeyContent = Get-Content $WinKeyPath -Raw
        $KeyContent | wsl -d $DISTRO -- bash -c "cat > ~/.config/age/key.txt && chmod 600 ~/.config/age/key.txt"
    }
} else {
    Write-Host "    ! No se encontro key.txt en Windows. Continuando sin secretos." -ForegroundColor Yellow
}

Write-Host "==> [3/3] Inicializando dotfiles en WSL..." -ForegroundColor Cyan
$t = (gh auth token 2>$null)
if (-not $t) {
    Write-Error "gh CLI no autenticado. Ejecuta primero: gh auth login"
    exit 1
}

# Inyectar token y ejecutar init
$initCmd = "export GITHUB_TOKEN='" + $t + "'; ~/.local/bin/chezmoi init --apply yordycg"
wsl -d $DISTRO -- bash -c "$initCmd"

Write-Host ""
Write-Host "==> WSL configurado exitosamente." -ForegroundColor Green
Write-Host "    Entra con: wsl -d Ubuntu-24.04" -ForegroundColor Green
