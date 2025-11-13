# 🔓 n8n Dev License - Guía Rápida

Esta es tu rama **dev-license** con funcionalidad de licencia de desarrollo para n8n.

## 🚀 Inicio Rápido

### Activar Modo Dev

```bash
# Opción 1: Variable de entorno (recomendado)
N8N_LICENSE_DEV_MODE=true pnpm dev

# Opción 2: Llave mágica en la UI
# Ir a Settings → Usage & Plan → Activate License
# Ingresar: DEV-MAGIC-KEY-ENTERPRISE
```

### Actualizar a Nueva Versión de n8n

```bash
# Windows
.\update-from-tag.ps1 -Tag n8n@1.121.0

# Linux/macOS
./update-from-tag.sh n8n@1.121.0
```

## 📋 Estructura de la Rama

```
origin/main (n8n oficial) ──> dev-license (TU RAMA - LOCAL ONLY)
```

- ✅ La rama `dev-license` NUNCA se hace push al remoto
- ✅ Contiene los cambios oficiales + tu funcionalidad dev-license
- ✅ Se actualiza fácilmente desde cualquier tag oficial

## 🔄 Workflow de Actualización

1. **Ver tags disponibles**:
   ```bash
   # Windows
   .\update-from-tag.ps1

   # Linux/macOS
   ./update-from-tag.sh
   ```

2. **Actualizar a tag específico**:
   ```bash
   # Windows
   .\update-from-tag.ps1 -Tag n8n@1.121.0

   # Linux/macOS
   ./update-from-tag.sh n8n@1.121.0
   ```

3. **Si hay conflictos**:
   - El script te mostrará los archivos con conflictos
   - Edita los archivos y resuelve los conflictos
   - `git add <archivo-resuelto>`
   - `git rebase --continue`

4. **Si algo sale mal**:
   - `git rebase --abort` (cancela el rebase)
   - El script creó un backup automático: `dev-license-backup-TIMESTAMP`
   - Puedes volver a él con: `git checkout dev-license-backup-TIMESTAMP`

## 📝 Archivos Importantes

- **`DEV_LICENSE_GUIDE.md`** - Documentación completa de la funcionalidad
- **`update-from-tag.ps1`** - Script de actualización para Windows
- **`update-from-tag.sh`** - Script de actualización para Linux/macOS
- **`.nvmrc`** - Versión de Node.js recomendada

## ✨ Características Habilitadas

Con el modo dev activo, tienes acceso a:

- ✅ Todas las características Enterprise
- ✅ Límites ilimitados (usuarios, triggers, variables, etc.)
- ✅ Sin mensajes de advertencia de licencia
- ✅ Simulación completa de licencia enterprise válida

## ⚠️ Importante

- **Solo para desarrollo local** - NO usar en producción
- Esta rama NO debe subirse al repositorio remoto
- Para producción, obtén una licencia legítima de n8n

## 📚 Documentación Completa

Para más detalles, consulta:
- **[DEV_LICENSE_GUIDE.md](DEV_LICENSE_GUIDE.md)** - Guía completa

## 🆘 Ayuda Rápida

```bash
# Ver en qué rama estás
git branch

# Cambiar a dev-license
git checkout dev-license

# Ver el estado de git
git status

# Ver commits en dev-license
git log --oneline n8n@1.120.0..HEAD

# Listar todos los tags de n8n
git tag -l 'n8n@*'
```

---

**Última Actualización**: 2025-11-13
**Basado en**: n8n@1.120.0
