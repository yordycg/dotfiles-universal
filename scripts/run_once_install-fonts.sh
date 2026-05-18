#!/usr/bin/bash

# run_once_install-fonts.sh
# -----------------------------------------------------------------------------
# Este script instala las Nerd Fonts seleccionadas para Linux.
# Se ejecuta una sola vez (o cuando este archivo cambia).

version="3.3.0"
fonts_dir="${HOME}/.local/share/fonts"

# Lista de fuentes (Nombres de archivos en los releases de Nerd Fonts)
# Nota: CascadiaCode se llama 'CaskaydiaCove' en el repositorio de Nerd Fonts.
declare -a fonts=(
  JetBrainsMono
  FiraCode
  Lilex
  CaskaydiaCove
)

# Asegurar que el directorio de fuentes existe
if [[ ! -d "$fonts_dir" ]]; then
  echo "📁 Creando directorio de fuentes en $fonts_dir..."
  mkdir -p "$fonts_dir"
fi

echo "🔍 Verificando fuentes..."

for font in "${fonts[@]}"; do
  # Comprobar si la carpeta de la fuente ya existe para evitar re-descargas
  if [ ! -d "$fonts_dir/$font" ]; then
    echo "📥 Descargando e instalando: $font Nerd Font..."
    zip_file="${font}.zip"
    download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"
    
    # Descargar y descomprimir
    if wget -q --show-progress "$download_url"; then
      unzip -o "$zip_file" -d "$fonts_dir/$font"
      rm "$zip_file"
      echo "✅ $font instalado correctamente."
    else
      echo "❌ Error al descargar $font. Verifica tu conexión o el nombre de la fuente."
    fi
  else
    echo "✨ $font ya está instalada. Saltando..."
  fi
done

# Eliminar versiones "Windows Compatible" que pueden causar problemas en Linux
echo "🧹 Limpiando archivos innecesarios..."
find "$fonts_dir" -name '*Windows Compatible*' -delete

# Actualizar la caché de fuentes del sistema
echo "🔄 Actualizando caché de fuentes (fc-cache)..."
fc-cache -fv

echo "🎉 ¡Proceso de fuentes finalizado!"
