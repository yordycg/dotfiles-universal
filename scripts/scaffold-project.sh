#!/usr/bin/env bash

# scaffold-project.sh
# Descripción: Crea la estructura estándar de un nuevo proyecto en la subcarpeta adecuada.

set -e 

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Validar argumentos
PROJECT_NAME="$1"
CATEGORY="${2:-personal}" # Por defecto a 'personal' si no se especifica

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${YELLOW}Uso: just project-new <nombre_del_proyecto> [categoria]${NC}"
    echo -e "Categorías disponibles: personal, work, ivpg, assets"
    exit 1
fi

TARGET_DIR="$HOME/workspace/$CATEGORY/$PROJECT_NAME"

# Verificar si el directorio ya existe
if [ -d "$TARGET_DIR" ]; then
    echo -e "Error: El proyecto ya existe en $TARGET_DIR"
    exit 1
fi

# Asegurar que la carpeta de la categoría existe
mkdir -p "$HOME/workspace/$CATEGORY"

echo -e "${BLUE}Creando proyecto $PROJECT_NAME en la categoría [$CATEGORY]...${NC}"

# Obtener la ruta de las plantillas
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates/project-base"

# Crear y copiar estructura
mkdir -p "$TARGET_DIR"
cp -r "$TEMPLATE_DIR/"* "$TARGET_DIR/"
cp "$TEMPLATE_DIR/.editorconfig" "$TARGET_DIR/"
cp "$TEMPLATE_DIR/.gitignore" "$TARGET_DIR/"
cp "$TEMPLATE_DIR/.env.example" "$TARGET_DIR/"
cp -r "$TEMPLATE_DIR/.forgejo" "$TARGET_DIR/"

# Inicializar Git
cd "$TARGET_DIR"
git init > /dev/null
git add .
git commit -m "chore: initial project scaffolding" > /dev/null

echo -e "${GREEN}¡Proyecto creado exitosamente en $TARGET_DIR!${NC}"
echo ""
eza --tree --icons --level=2 "$TARGET_DIR"
echo ""
echo -e "Siguiente paso: cd $TARGET_DIR && just up"
