#!/usr/bin/env bash
# Provisión para el contenedor .NET (Plan B)

echo "== Configurando entorno .NET en Distrobox..."

# Instalar herramientas útiles para C# en la terminal
# (El SDK ya viene en la imagen)

# Ejemplo: Herramientas globales de dotnet
dotnet tool install --global csharpier 2>/dev/null || true

echo "[OK] Contenedor .NET listo"
