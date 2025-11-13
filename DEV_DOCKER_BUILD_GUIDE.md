# Guía de Build Docker para Desarrollo

Este documento explica cómo construir imágenes Docker de n8n en tu fork personal sin bloquear tu PC local.

## 📋 Resumen

El workflow `dev-docker-build.yml` permite construir imágenes Docker en GitHub Actions (en la nube), evitando el uso de recursos locales durante el proceso de build que puede tardar 15-30 minutos.

## 🚀 Cómo Usar

### 1. Ejecutar el Workflow

1. Ve a tu fork en GitHub: https://github.com/vgpastor/n8n/actions

2. Selecciona el workflow **"Dev Docker Build (Fork-friendly)"** en el panel izquierdo

3. Click en **"Run workflow"** (botón verde a la derecha)

4. Configura los parámetros:
   - **Branch**: Selecciona la rama que quieres construir (ej: `dev-license`)
   - **tag_name**: Nombre del tag para la imagen (por defecto: `dev`)
     - Si usas `dev`, la imagen se taggeará con el nombre de la rama
     - Si usas otro nombre (ej: `v1.0.0`), ese será el tag
   - **push_to_registry**: Déjalo marcado (true) para subir la imagen a GHCR

5. Click en **"Run workflow"** verde

6. Espera 15-30 minutos mientras se construye la imagen

### 2. Descargar y Usar la Imagen

Una vez completado el workflow:

#### Login a GitHub Container Registry

Necesitas un Personal Access Token (PAT):
1. Ve a https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Marca el scope `read:packages` (y `write:packages` si vas a pushear)
4. Genera y guarda el token

```bash
# Login con tu PAT
echo TU_GITHUB_PAT | docker login ghcr.io -u vgpastor --password-stdin
```

#### Pull de la Imagen

```bash
# Si usaste tag_name "dev" (por defecto), el nombre será el de tu rama
docker pull ghcr.io/vgpastor/n8n:dev-license

# Si especificaste otro tag, por ejemplo "v1.0.0"
docker pull ghcr.io/vgpastor/n8n:v1.0.0
```

#### Ejecutar el Container

```bash
# Ejecución simple
docker run -it --rm -p 5678:5678 ghcr.io/vgpastor/n8n:dev-license

# Con persistencia de datos
docker run -it --rm \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  ghcr.io/vgpastor/n8n:dev-license
```

#### Usar con Docker Compose

Crea un archivo `docker-compose.yml`:

```yaml
version: '3.8'

services:
  n8n:
    image: ghcr.io/vgpastor/n8n:dev-license
    ports:
      - "5678:5678"
    volumes:
      - ~/.n8n:/home/node/.n8n
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=password
```

Luego ejecuta:
```bash
docker-compose up -d
```

## 🔄 Flujo de Trabajo Completo

### Actualizar desde n8n oficial

```powershell
# 1. Actualiza desde el repositorio original
git checkout dev-license
.\update-from-tag.ps1 -Tag n8n@1.120.0

# 2. Resuelve conflictos si los hay

# 3. Push a tu fork
git push origin dev-license
```

### Construir la Imagen Docker

1. Ve a GitHub Actions en tu fork
2. Ejecuta el workflow "Dev Docker Build (Fork-friendly)"
3. Espera a que termine
4. Descarga la imagen en tu PC local

## ⚙️ Características del Workflow

### Ventajas

- ✅ **No bloquea tu PC**: Se ejecuta en servidores de GitHub
- ✅ **Solo AMD64**: Construcción más rápida (no requiere ARM64)
- ✅ **Usa runners estándar**: Compatible con forks gratuitos
- ✅ **Cache inteligente**: Builds subsecuentes son más rápidos
- ✅ **Sube a GHCR**: Tu imagen privada en GitHub Container Registry

### Diferencias con el Workflow Original

| Característica | Workflow Original | Dev Workflow |
|----------------|-------------------|--------------|
| Runners | Blacksmith (no disponible en forks) | ubuntu-latest (disponible) |
| Plataformas | AMD64 + ARM64 | Solo AMD64 |
| Tiempo | ~16-20 min | ~15-30 min |
| Registry | GHCR + Docker Hub | Solo GHCR |
| Uso | Releases oficiales | Desarrollo personal |

## 📝 Notas Importantes

1. **La imagen es privada**: Solo tú puedes acceder a ella (a menos que cambies la visibilidad del paquete)

2. **Limitaciones de GitHub Actions**:
   - Free tier: 2,000 minutos/mes
   - Cada build consume ~15-30 minutos
   - ~60-130 builds por mes en el plan gratuito

3. **Para hacer la imagen pública**:
   - Ve a https://github.com/vgpastor?tab=packages
   - Encuentra el paquete `n8n`
   - Package settings → Change visibility → Public

4. **Si necesitas ARM64**:
   - Requiere GitHub Teams/Enterprise
   - O usa el script local `dockerize-n8n.mjs` en tu Mac/ARM

## 🛠️ Troubleshooting

### "Error: authentication required"
- Necesitas hacer login: `docker login ghcr.io`
- Verifica que tu PAT tenga scope `read:packages`

### "Image not found"
- Verifica que el workflow haya terminado exitosamente
- Confirma el nombre exacto de la imagen en el workflow log
- Asegúrate de que `push_to_registry` estuvo en `true`

### "No space left on device" en GitHub Actions
- Raro, pero puede pasar
- Re-ejecuta el workflow (a veces ayuda)

## 🔗 Enlaces Útiles

- Tu fork: https://github.com/vgpastor/n8n
- GitHub Actions: https://github.com/vgpastor/n8n/actions
- Tus packages: https://github.com/vgpastor?tab=packages
- Crear PAT: https://github.com/settings/tokens

## 📚 Recursos Adicionales

- [Documentación de n8n](https://docs.n8n.io)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Docker Build documentation](https://docs.docker.com/engine/reference/commandline/build/)
