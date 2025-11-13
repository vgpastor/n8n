#!/bin/bash
# update-from-tag.sh - Actualizar dev-license desde un tag oficial de n8n
# Uso: ./update-from-tag.sh n8n@1.120.0

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Verificar que estamos en dev-license
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$CURRENT_BRANCH" != "dev-license" ]; then
    echo -e "${RED}❌ Error: Debes estar en la rama dev-license${NC}"
    echo -e "${YELLOW}Rama actual: $CURRENT_BRANCH${NC}"
    echo -e "${CYAN}Ejecuta: git checkout dev-license${NC}"
    exit 1
fi

# Verificar que no hay cambios sin commitear
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "${RED}❌ Error: Tienes cambios sin commitear${NC}"
    echo ""
    echo -e "${YELLOW}Archivos modificados:${NC}"
    git status --short
    echo ""
    echo -e "${CYAN}Ejecuta primero:${NC}"
    echo "  git add ."
    echo "  git commit -m 'tu mensaje'"
    exit 1
fi

# Obtener el tag (parámetro o usar el último)
if [ -z "$1" ]; then
    echo -e "${YELLOW}⚠️  No se especificó tag. Mostrando tags disponibles...${NC}"
    echo ""
    echo -e "${CYAN}Obteniendo tags del repositorio remoto...${NC}"
    git fetch origin --tags 2>&1 >/dev/null

    echo ""
    echo -e "${GREEN}Últimos 15 tags de n8n:${NC}"
    git tag -l 'n8n@*' | tail -15 | while read -r tag; do
        echo "  $tag"
    done

    echo ""
    echo -e "${CYAN}Uso:${NC}"
    echo "  ./update-from-tag.sh n8n@1.120.0"
    echo ""
    echo -e "${CYAN}Para ver todos los tags:${NC}"
    echo "  git tag -l 'n8n@*'"
    exit 1
fi

TAG=$1

# Verificar que el tag existe
echo -e "${CYAN}🔍 Verificando tag '$TAG'...${NC}"
git fetch origin --tags 2>&1 >/dev/null

if ! git rev-parse "$TAG" >/dev/null 2>&1; then
    echo -e "${RED}❌ Error: El tag '$TAG' no existe${NC}"
    echo ""
    echo -e "${YELLOW}Tags disponibles (últimos 15):${NC}"
    git tag -l 'n8n@*' | tail -15 | while read -r tag; do
        echo "  $tag"
    done
    exit 1
fi

echo -e "${GREEN}✅ Tag encontrado: $TAG${NC}"
echo ""
echo -e "${GREEN}🔄 Actualizando dev-license desde $TAG...${NC}"
echo ""

# Crear un backup por si acaso
BACKUP_BRANCH="dev-license-backup-$(date +%Y%m%d-%H%M%S)"
git branch "$BACKUP_BRANCH" 2>&1 >/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Backup creado: $BACKUP_BRANCH${NC}"
    echo ""
else
    echo -e "${YELLOW}⚠️  No se pudo crear backup, pero continuando...${NC}"
    echo ""
fi

# Hacer merge desde el tag
echo -e "${CYAN}📝 Iniciando merge desde $TAG...${NC}"
echo -e "${GRAY}   Esto puede tomar un momento...${NC}"
echo ""

if git merge "$TAG" -m "chore: Merge tag '$TAG'" 2>&1; then
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ ¡Actualización exitosa!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}📌 dev-license ahora está basada en: $TAG${NC}"
    echo ""

    # Mostrar commits
    COMMIT_COUNT=$(git rev-list --count "$TAG..HEAD")
    if [ "$COMMIT_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}📊 Commits en dev-license (encima de $TAG):${NC}"
        git log --oneline "$TAG..HEAD" | while read -r line; do
            echo "   $line"
        done
        echo ""
    fi

    echo -e "${GRAY}🗑️  Para eliminar el backup:${NC}"
    echo "   git branch -D $BACKUP_BRANCH"
    echo ""
else
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⚠️  HAY CONFLICTOS QUE RESOLVER${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Mostrar archivos en conflicto
    CONFLICTED_FILES=$(git diff --name-only --diff-filter=U)
    if [ -n "$CONFLICTED_FILES" ]; then
        echo -e "${RED}📝 Archivos con conflictos:${NC}"
        echo "$CONFLICTED_FILES" | while read -r file; do
            echo -e "   ${RED}❌ $file${NC}"
        done
        echo ""
    fi

    echo -e "${CYAN}📖 Para resolver los conflictos:${NC}"
    echo "   1. Edita los archivos con conflictos"
    echo "   2. git add <archivo-resuelto>"
    echo "   3. git commit"
    echo ""
    echo -e "${CYAN}🔙 Para abortar y volver al estado anterior:${NC}"
    echo "   git merge --abort"
    echo "   git checkout $BACKUP_BRANCH"
    echo "   git branch -D dev-license"
    echo "   git checkout -b dev-license"
    echo ""
fi
