# Guía de Configuración - Sincronización con Google Drive

## Nuevas Características Implementadas

### 1. **Autosave Automático**
- Las notas se guardan automáticamente mientras escribes
- Debounce de 2 segundos para evitar múltiples guardados
- Indicador visual "Guardado automático" en la AppBar

### 2. **Sistema de Backups Locales**
- Se crean automáticamente hasta 2 backups por nota
- Los backups se crean cada vez que guardas una nota
- Accede a los backups mediante el botón de historial (🕐) en la nota
- Puedes restaurar cualquier versión anterior de tu nota

### 3. **Sincronización con Google Drive**
- Sincroniza automáticamente todas tus notas y backups a Google Drive
- La sincronización ocurre cada vez que:
  - Creas una nueva nota
  - Actualizas una nota existente
  - Eliminas una nota
- Icono en la AppBar que indica el estado de conexión

## Configuración de Google Drive

### Paso 1: Crear un Proyecto en Google Cloud Console

1. Accede a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita la **Google Drive API**:
   - Ve a "APIs y servicios" > "Biblioteca"
   - Busca "Google Drive API"
   - Haz clic en "Habilitar"

### Paso 2: Crear Credenciales OAuth 2.0

1. Ve a "APIs y servicios" > "Credenciales"
2. Haz clic en "Crear credenciales" > "ID de cliente de OAuth"
3. Selecciona "Aplicación web" o "Aplicación móvil" según tu plataforma
4. Configura los orígenes autorizados:
   - Para Android: `https://your-android-app-package`
   - Para iOS: tu Bundle ID
   - Para Web: `http://localhost:5000`

### Paso 3: Configurar la Aplicación Flutter

#### Para Android:
1. Descarga el archivo `google-services.json` desde Google Cloud Console
2. Colócalo en `android/app/`
3. En `android/app/build.gradle`, verifica que esté configurado el Google Sign-In

#### Para iOS:
1. Descarga el archivo `GoogleService-Info.plist`
2. Arrástralo a Xcode bajo el proyecto Runner
3. Verifica que esté incluido en el Bundle

#### Para Web:
1. Configura el Web Client ID en tu `index.html`
2. Reemplaza `YOUR_WEB_CLIENT_ID` con tu ID real

### Paso 4: Variables de Entorno (Opcional)

Si prefieres usar variables de entorno, puedes crear un archivo `.env`:

```
GOOGLE_CLIENT_ID=your_client_id_here
GOOGLE_CLIENT_SECRET=your_client_secret_here
```

Luego usa el paquete `flutter_dotenv` para cargarlas en tu aplicación.

## Uso de las Nuevas Características

### Autosave
- No necesitas hacer nada especial. Las notas se guardan automáticamente mientras escribes.

### Ver y Restaurar Backups
1. Abre una nota
2. Haz clic en el icono de historial (🕐) en la esquina superior derecha
3. Selecciona el backup que quieres restaurar
4. La nota se restaurará automáticamente

### Conectar Google Drive
1. En la pantalla principal, haz clic en el icono de nube (☁️) en la esquina superior derecha
2. Selecciona "Conectar" en el diálogo que aparece
3. Inicia sesión con tu cuenta de Google
4. Tus notas se sincronizarán automáticamente

### Desconectar Google Drive
1. Haz clic en el icono de nube (☁️✓) cuando esté conectado
2. Selecciona "Desconectar de Google" en el menú

## Resolución de Problemas

### "Error al conectar a Google Drive"
- Verifica que hayas habilitado Google Drive API en Google Cloud Console
- Comprueba que las credenciales OAuth están correctamente configuradas
- En Android, asegúrate de que el SHA-1 esté registrado en Google Cloud Console

### "Las notas no se sincronizan"
- Verifica tu conexión a internet
- Comprueba que has iniciado sesión en Google Drive
- Revisa los permisos de la aplicación

### "No puedo ver mis backups"
- Los backups se crean automáticamente cuando guardas
- Abre una nota y espera a que se guarde automáticamente
- Luego abre el diálogo de backups

## Archivos Nuevos Creados

- `lib/core/features/auth/data/backup_service.dart` - Gestión de backups locales
- `lib/core/features/auth/data/google_drive_service.dart` - Sincronización con Google Drive

## Dependencias Agregadas

- `google_sign_in: ^6.2.0` - Autenticación con Google
- `googleapis: ^12.0.0` - API de Google
- `google_drive_api: ^0.2.0` - API de Google Drive
- `http: ^1.1.0` - Solicitudes HTTP
- `intl: ^0.19.0` - Internacionalización

## Notas Adicionales

- Los backups se almacenan localmente en el dispositivo
- La sincronización con Google Drive requiere conexión a internet
- Se mantienen hasta 2 backups por nota
- Los backups más antiguos se eliminan automáticamente
