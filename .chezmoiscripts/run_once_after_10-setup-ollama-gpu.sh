#!/usr/bin/env bash
# =============================================================================
# .chezmoiscripts/run_once_after_10-setup-ollama-gpu.sh
# Configura de forma portátil Ollama para usar GPU NVIDIA en sistemas híbridos.
# compatible con cualquier distribución que use Systemd.
# =============================================================================
set -euo pipefail

# 1. Comprobar si el sistema utiliza Systemd
if ! command -v systemctl &>/dev/null; then
    echo "[Ollama-GPU] Sistema sin Systemd detectado. Omitiendo configuración."
    exit 0
fi

# 2. Comprobar si Ollama está instalado como servicio de sistema
if ! systemctl list-unit-files ollama.service &>/dev/null; then
    echo "[Ollama-GPU] El servicio ollama.service no está instalado. Omitiendo."
    exit 0
fi

# 3. Detectar si hay una GPU NVIDIA en el sistema
if lspci | grep -qi "nvidia"; then
    echo "[Ollama-GPU] Tarjeta gráfica NVIDIA detectada. Configurando entorno..."

    OVERRIDE_DIR="/etc/systemd/system/ollama.service.d"
    OVERRIDE_FILE="$OVERRIDE_DIR/override.conf"

    # Crear el directorio de override si no existe
    if [ ! -d "$OVERRIDE_DIR" ]; then
        echo "[Ollama-GPU] Creando directorio de override..."
        sudo mkdir -p "$OVERRIDE_DIR"
    fi

    # Escribir las reglas de entorno de forma segura
    echo "[Ollama-GPU] Escribiendo configuración en $OVERRIDE_FILE..."
    sudo tee "$OVERRIDE_FILE" > /dev/null << 'EOF'
[Service]
Environment="HIP_VISIBLE_DEVICES=-1"
Environment="ROCR_VISIBLE_DEVICES=-1"
Environment="CUDA_VISIBLE_DEVICES=0"
EOF

    # Recargar Systemd y reiniciar el servicio para aplicar
    echo "[Ollama-GPU] Recargando Systemd y reiniciando Ollama..."
    sudo systemctl daemon-reload
    sudo systemctl restart ollama
    echo "[Ollama-GPU] ¡Ollama configurado con éxito para NVIDIA GPU!"
else
    echo "[Ollama-GPU] No se detectó GPU NVIDIA. Dejando configuración por defecto."
fi
