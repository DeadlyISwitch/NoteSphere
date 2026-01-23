# Configuración de Android para Google Drive

## Paso 1: Obtener SHA-1 de tu aplicación

Ejecuta el siguiente comando en tu terminal (en la carpeta del proyecto):

```bash
./gradlew signingReport
```

O para macOS/Linux:

```bash
./gradlew app:signingReport
```

Busca la línea `SHA1` en la salida.

## Paso 2: Registrar la aplicación en Google Cloud

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto o crea uno nuevo
3. Ve a "APIs y servicios" > "Credenciales"
4. Haz clic en "Crear credenciales" > "ID de cliente de OAuth"
5. Selecciona "Android"
6. Ingresa:
   - **Nombre del paquete**: `com.algo.notesphere` (según tu configuración)
   - **SHA-1**: La que obtuviste en el Paso 1
7. Haz clic en "Crear"

## Paso 3: Descargar google-services.json

1. Después de crear las credenciales, descarga el archivo `google-services.json`
2. Colócalo en `android/app/`

## Paso 4: Verificar la configuración en build.gradle

Asegúrate de que en `android/build.gradle` (el archivo raíz) esté:

```gradle
buildscript {
    dependencies {
        // classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

Y en `android/app/build.gradle`:

```gradle
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // id("com.google.gms.google-services") // Descomenta si es necesario
}
```

## Paso 5: Configurar AndroidManifest.xml

Verifica que en `android/app/src/main/AndroidManifest.xml` esté la declaración de permisos de internet:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Dependencias en pubspec.yaml

Las siguientes dependencias ya están añadidas:

```yaml
google_sign_in: ^6.2.0
googleapis: ^12.0.0
google_drive_api: ^0.2.0
http: ^1.1.0
```

Ejecuta:

```bash
flutter pub get
```

## Pruebas Locales

Para probar en el emulador:

```bash
flutter run
```

Si encuentras problemas con Google Sign-In en el emulador:
- El emulador debe tener una cuenta de Google configurada
- Ve a "Settings" > "Accounts" en el emulador
- Añade una cuenta de Google

## Solución de Problemas

### "Sign in with Google failed"
- Verifica que SHA-1 esté correctamente registrado
- Comprueba que Google Drive API está habilitada

### "403 Forbidden" al sincronizar
- Verifica que tienes permisos de acceso a Google Drive
- Intenta conectarte de nuevo

### Emulador no tiene Google Play Services
- Usa un emulador que tenga Google APIs (versión con "Google APIs")
- O prueba en un dispositivo físico
