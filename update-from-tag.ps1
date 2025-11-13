# update-from-tag.ps1 - Actualizar dev-license desde un tag oficial de n8n
# Uso: .\update-from-tag.ps1 -Tag n8n@1.120.0

param(
    [Parameter(Mandatory=$false)]
    [string]$Tag
)

# Verificar que estamos en dev-license
$currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
if ($currentBranch -ne "dev-license") {
    Write-Host "❌ Error: Debes estar en la rama dev-license" -ForegroundColor Red
    Write-Host "Rama actual: $currentBranch" -ForegroundColor Yellow
    Write-Host "Ejecuta: git checkout dev-license" -ForegroundColor Cyan
    exit 1
}

# Verificar que no hay cambios sin commitear
$status = git status --porcelain
if ($status) {
    Write-Host "❌ Error: Tienes cambios sin commitear" -ForegroundColor Red
    Write-Host ""
    Write-Host "Archivos modificados:" -ForegroundColor Yellow
    git status --short
    Write-Host ""
    Write-Host "Ejecuta primero:" -ForegroundColor Cyan
    Write-Host "  git add ." -ForegroundColor White
    Write-Host "  git commit -m 'tu mensaje'" -ForegroundColor White
    exit 1
}

# Si no se especificó tag, mostrar disponibles
if (-not $Tag) {
    Write-Host "⚠️  No se especificó tag. Mostrando tags disponibles..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Obteniendo tags del repositorio remoto..." -ForegroundColor Cyan
    git fetch origin --tags 2>&1 | Out-Null

    Write-Host ""
    Write-Host "Últimos 15 tags de n8n:" -ForegroundColor Green
    git tag -l "n8n@*" | Select-Object -Last 15 | ForEach-Object {
        Write-Host "  $_" -ForegroundColor White
    }

    Write-Host ""
    Write-Host "Uso:" -ForegroundColor Cyan
    Write-Host "  .\update-from-tag.ps1 -Tag n8n@1.120.0" -ForegroundColor White
    Write-Host ""
    Write-Host "Para ver todos los tags:" -ForegroundColor Cyan
    Write-Host "  git tag -l 'n8n@*'" -ForegroundColor White
    exit 1
}

# Verificar que el tag existe
Write-Host "🔍 Verificando tag '$Tag'..." -ForegroundColor Cyan
git fetch origin --tags 2>&1 | Out-Null

$tagExists = git rev-parse $Tag 2>$null
if (-not $tagExists) {
    Write-Host "❌ Error: El tag '$Tag' no existe" -ForegroundColor Red
    Write-Host ""
    Write-Host "Tags disponibles (últimos 15):" -ForegroundColor Yellow
    git tag -l "n8n@*" | Select-Object -Last 15 | ForEach-Object {
        Write-Host "  $_" -ForegroundColor White
    }
    exit 1
}

Write-Host "✅ Tag encontrado: $Tag" -ForegroundColor Green
Write-Host ""
Write-Host "🔄 Actualizando dev-license desde $Tag..." -ForegroundColor Green
Write-Host ""

# Crear backup
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupBranch = "dev-license-backup-$timestamp"
git branch $backupBranch 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Backup creado: $backupBranch" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "⚠️  No se pudo crear backup, pero continuando..." -ForegroundColor Yellow
    Write-Host ""
}

# Hacer rebase
Write-Host "📝 Iniciando rebase desde $Tag..." -ForegroundColor Cyan
Write-Host "   Esto puede tomar un momento..." -ForegroundColor Gray
Write-Host ""

$rebaseOutput = git rebase $Tag 2>&1
$rebaseSuccess = $LASTEXITCODE -eq 0

if ($rebaseSuccess) {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "✅ ¡Actualización exitosa!" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host ""
    Write-Host "📌 dev-license ahora está basada en: $Tag" -ForegroundColor Cyan
    Write-Host ""

    # Mostrar commits
    $commitCount = git rev-list --count "$Tag..HEAD"
    if ($commitCount -gt 0) {
        Write-Host "📊 Commits en dev-license (encima de $Tag):" -ForegroundColor Yellow
        git log --oneline "$Tag..HEAD" | ForEach-Object {
            Write-Host "   $_" -ForegroundColor White
        }
        Write-Host ""
    }

    Write-Host "🗑️  Para eliminar el backup:" -ForegroundColor Gray
    Write-Host "   git branch -D $backupBranch" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "⚠️  HAY CONFLICTOS QUE RESOLVER" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host ""

    # Mostrar archivos en conflicto
    $conflictedFiles = git diff --name-only --diff-filter=U
    if ($conflictedFiles) {
        Write-Host "📝 Archivos con conflictos:" -ForegroundColor Red
        $conflictedFiles | ForEach-Object {
            Write-Host "   ❌ $_" -ForegroundColor Red
        }
        Write-Host ""
    }

    Write-Host "📖 Para resolver los conflictos:" -ForegroundColor Cyan
    Write-Host "   1. Edita los archivos con conflictos" -ForegroundColor White
    Write-Host "   2. git add <archivo-resuelto>" -ForegroundColor White
    Write-Host "   3. git rebase --continue" -ForegroundColor White
    Write-Host ""
    Write-Host "🔙 Para abortar y volver al estado anterior:" -ForegroundColor Cyan
    Write-Host "   git rebase --abort" -ForegroundColor White
    Write-Host "   git checkout $backupBranch" -ForegroundColor White
    Write-Host "   git branch -D dev-license" -ForegroundColor White
    Write-Host "   git checkout -b dev-license" -ForegroundColor White
    Write-Host ""
}
