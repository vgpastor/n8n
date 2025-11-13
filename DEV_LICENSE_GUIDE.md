# Guía de Llave Mágica de Desarrollo para n8n

Esta guía explica cómo usar la **llave mágica de desarrollo** para habilitar todas las características enterprise de n8n sin necesidad de una licencia real.

## 🎯 Propósito

La llave mágica de desarrollo permite:
- Activar todas las características enterprise sin validación
- Límites ilimitados en usuarios, triggers, variables, etc.
- Desarrollo y testing local sin restricciones
- No interfiere con licencias reales en producción
- **Simula una licencia enterprise válida** sin mensajes de advertencia

## 🔧 Métodos de Activación

### Método 1: Variable de Entorno (Recomendado)

Configura la variable de entorno antes de iniciar n8n:

```bash
# Linux/macOS
export N8N_LICENSE_DEV_MODE=true
npm run dev

# Windows (CMD)
set N8N_LICENSE_DEV_MODE=true
npm run dev

# Windows (PowerShell)
$env:N8N_LICENSE_DEV_MODE="true"
npm run dev
```

O agrégala a tu archivo `.env`:
```
N8N_LICENSE_DEV_MODE=true
```

### Método 2: Llave Mágica en la Interfaz

1. Inicia n8n normalmente
2. Ve a **Settings → Usage & Plan**
3. Click en "Activate License"
4. Ingresa la llave mágica: `DEV-MAGIC-KEY-ENTERPRISE`
5. Click "Activate"

## ✅ Verificación

Cuando el modo dev está activo, verás en los logs:
```
🔓 Development mode enabled - All enterprise features unlocked
✅ Mock license manager initialized - Simulating valid enterprise license
```

Y en la interfaz, el plan mostrará: **Enterprise (Dev Mode)**

## 🚀 Características Habilitadas

Con la llave mágica, obtienes acceso a:

### Características Enterprise
- ✅ LDAP Authentication
- ✅ SAML SSO
- ✅ Advanced Permissions
- ✅ API Key Scopes
- ✅ Source Control (Git)
- ✅ External Secrets
- ✅ Workflow History
- ✅ Variables
- ✅ Log Streaming
- ✅ Worker View
- ✅ Advanced Execution Filters
- ✅ Debug in Editor
- ✅ Binary Data S3
- ✅ Multiple Main Instances
- ✅ Custom NPM Registry
- ✅ Folders
- ✅ Project Roles (Admin, Editor, Viewer)

### Límites Ilimitados
- ✅ Usuarios: ILIMITADO
- ✅ Active Workflow Triggers: ILIMITADO
- ✅ Variables: ILIMITADO
- ✅ Workflow History: ILIMITADO
- ✅ Team Projects: ILIMITADO
- ✅ AI Credits: ILIMITADO

## 📝 Archivos Modificados

La implementación se realizó en los siguientes archivos:

1. **`packages/@n8n/config/src/configs/license.config.ts`**
   - Nueva variable de entorno `N8N_LICENSE_DEV_MODE`

2. **`packages/cli/src/license/license.service.ts`**
   - Detección de la llave mágica `DEV-MAGIC-KEY-ENTERPRISE`
   - Activación del modo dev con reinicialización del manager

3. **`packages/cli/src/license.ts`**
   - Propiedad `devModeEnabled`
   - Método `enableDevMode()`
   - **Método `createMockLicenseManager()`** - Crea un mock completo del SDK
   - Mock con `TEntitlement` enterprise válido
   - Todos los métodos del SDK simulados correctamente

4. **`packages/@n8n/backend-common/src/license-state.ts`** ⭐ NUEVO
   - Método `isDevModeEnabled()` - Detecta si el modo dev está activo
   - Modificado `isLicensed()` - Retorna `true` para todas las features en modo dev
   - Modificado `getValue()` - Retorna valores ilimitados para quotas en modo dev
   - **Esto asegura que TODOS los módulos (como Insights) respeten el modo dev**

## ⚠️ Advertencias

- **Solo para desarrollo**: NO usar en producción
- **No reemplaza licencias reales**: Para producción, obtén una licencia legítima
- **Sin soporte oficial**: Esta es una modificación personalizada

## 🔍 Cómo Funciona

### Implementación del Mock Completo

La implementación utiliza un **mock completo del LicenseManager** que simula una licencia enterprise válida:

1. **Inicialización**:
   - Al iniciar n8n, se verifica si `N8N_LICENSE_DEV_MODE=true`
   - Si está activo, se habilita `devModeEnabled = true`
   - En lugar de crear un `LicenseManager` real, se crea un **mock manager**

2. **Mock Manager**:
   - Simula un `TEntitlement` enterprise válido con:
     - `productMetadata.terms.isMainPlan: true`
     - Todas las features enterprise habilitadas
     - Límites ilimitados en todos los quotas
     - Fechas de validez (30 días atrás → 1 año adelante)

3. **Métodos del Mock**:
   - `hasFeatureEnabled()` → siempre retorna `true`
   - `getFeatureValue()` → retorna valores ilimitados o `true`
   - `getCurrentEntitlements()` → retorna el entitlement enterprise mock
   - `getManagementJwt()` → retorna un JWT simulado
   - `activate()`, `renew()`, `reload()` → operaciones vacías pero funcionales

4. **Ventajas**:
   - ✅ El SDK no detecta que falta una licencia real
   - ✅ **No hay mensajes de "not licensed for production"**
   - ✅ Funciona exactamente como una licencia enterprise válida
   - ✅ Sin modificar el SDK original (`@n8n_io/license-sdk`)

5. **Llave Mágica en UI**:
   - Al detectar `DEV-MAGIC-KEY-ENTERPRISE` en la UI
   - Se habilita el modo dev y se reinicializa el manager
   - Se reemplaza el manager real por el mock completo

## 🧪 Ejemplo de Uso

```bash
# Iniciar n8n con modo dev
N8N_LICENSE_DEV_MODE=true pnpm dev

# Verificar en logs
# Deberías ver:
# 🔓 Development mode enabled - All enterprise features unlocked
# ✅ Mock license manager initialized - Simulating valid enterprise license

# Acceder a características enterprise
# Todas las características estarán disponibles sin restricciones
# Sin mensajes de advertencia sobre licencias
```

## 🆘 Troubleshooting

**Problema**: El modo dev no se activa
- Verifica que la variable esté correctamente configurada
- Reinicia n8n completamente
- Revisa los logs para ver los mensajes de activación

**Problema**: Aparece "not licensed for production"
- Esto no debería aparecer con el mock completo
- Asegúrate de tener la versión actualizada del código
- Verifica en logs que aparezca "✅ Mock license manager initialized"

**Problema**: Algunas características no están disponibles
- Asegúrate de que el modo dev esté realmente activo
- Verifica en Settings → Usage que el plan diga "Enterprise (Dev Mode)"
- Limpia la caché del navegador y reinicia n8n

## 🔬 Detalles Técnicos

### Estructura del Mock Entitlement

```typescript
{
  id: 'dev-mode-enterprise-entitlement',
  productId: 'dev-mode-enterprise-product',
  productMetadata: {
    terms: {
      isMainPlan: true  // Indica que es un plan principal
    }
  },
  features: {
    // Todas las LICENSE_FEATURES habilitadas
  },
  featureOverrides: {
    // Todos los LICENSE_QUOTAS con valor UNLIMITED_LICENSE_QUOTA (-1)
  },
  validFrom: Date (30 días atrás),
  validTo: Date (1 año adelante)
}
```

### Comparación: Mock vs Bypass Simple

| Aspecto | Mock Completo (Nueva versión) | Bypass Simple (Versión anterior) |
|---------|-------------------------------|-----------------------------------|
| Advertencias SDK | ❌ Sin advertencias | ⚠️ "not licensed for production" |
| Simulación | ✅ Licencia válida completa | ⚠️ Solo bypass de funciones |
| Entitlements | ✅ Retorna datos reales | ❌ Retorna array vacío |
| Compatibilidad | ✅ 100% compatible | ⚠️ Algunas limitaciones |

## 📄 Licencia y Uso Responsable

Este código es para propósitos de desarrollo y testing únicamente. Para uso en producción,
obtén una licencia legítima de n8n visitando: https://n8n.io/pricing

---

**Fecha de Creación**: 2025-01-27
**Versión**: 2.0 (Mock Completo)
**Última Actualización**: 2025-01-28
**Autor**: Desarrollo Personalizado
