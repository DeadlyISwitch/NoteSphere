# 🚀 Guía de Instalación y Prueba

## Paso 1: Actualizar Dependencias

Ejecuta en la raíz del proyecto:

```bash
flutter pub get
```

## Paso 2: Configurar Google Drive (Importante)

### Opción A: Para Desarrollo Rápido (Sin Google Drive)

Si no quieres configurar Google Drive ahora, la app funcionará perfectamente con:
- ✅ Autosave automático
- ✅ Backups locales hasta 2 por nota
- ❌ Solo se deshabilitará la sincronización a la nube

### Opción B: Configuración Completa con Google Drive

Sigue los pasos en:
- `GOOGLE_DRIVE_SETUP.md` (General)
- `ANDROID_GOOGLE_SETUP.md` (Si usas Android)

## Paso 3: Ejecutar la Aplicación

### En Emulador
```bash
flutter run
```

### En Dispositivo Físico
```bash
flutter run -d <device-id>
```

### Modo Release
```bash
flutter run --release
```

## Paso 4: Probar las Nuevas Características

### ✅ Test 1: Autosave

1. Abre la app
2. Presiona el botón + para crear una nota
3. Haz clic en la nota para editarla
4. Escribe algo en el título o contenido
5. Observa: Aparece "Guardado automático" después de 2 segundos
6. ✅ Cierra la app y vuelve a abrirla → La nota debe estar guardada

### ✅ Test 2: Backups Locales

1. Abre una nota
2. Edítala (escribe algo nuevo)
3. Espera a que se guarde automáticamente
4. Cambia el contenido nuevamente
5. Espera a que se guarde (segundo backup)
6. Haz clic en el ícono 🕐 (historial)
7. Deberías ver 2 backups disponibles
8. Haz clic en "Restaurar" en uno de ellos
9. ✅ La nota se restaura al contenido anterior

### ✅ Test 3: Eliminación de Notas

1. En la pantalla principal, desliza una nota hacia la izquierda
2. ✅ La nota se elimina
3. Aparece un SnackBar confirmando la eliminación

### ✅ Test 4: Google Drive (Si está configurado)

1. En la pantalla principal, haz clic en el ícono ☁️
2. Se abre un diálogo "Conectar a Google Drive"
3. Haz clic en "Conectar"
4. Se abre la pantalla de login de Google
5. Inicia sesión con tu cuenta
6. ✅ El ícono cambia a ☁️✓ (conectado)
7. Crea o edita una nota
8. ✅ Se sincroniza automáticamente a Google Drive
9. Ve a tu Google Drive y verifica la carpeta "NoteSphere"

### ✅ Test 5: Desconectar Google Drive

1. Haz clic en el ícono ☁️✓ (conectado)
2. Selecciona "Desconectar de Google"
3. ✅ El ícono vuelve a ☁️✗ (desconectado)
4. Las notas continuarán siendo guardadas localmente

## Troubleshooting

### "Error al conectar"
- [ ] Verifica que Google Drive API esté habilitada
- [ ] Comprueba que las credenciales OAuth estén correctamente configuradas
- [ ] Si usas Android, verifica que el SHA-1 esté registrado
- [ ] Reinicia la app

### "Las notas no se sincronizan"
- [ ] Verifica tu conexión a internet
- [ ] Comprueba que has iniciado sesión en Google Drive
- [ ] Revisa los permisos de la app en Google

### "No veo los backups"
- [ ] Los backups se crean automáticamente al guardar
- [ ] Crea una nota nueva, edítala y espera a que se guarde automáticamente
- [ ] Luego abre el diálogo de backups

### "La app se congela"
- [ ] Reinicia la app
- [ ] Asegúrate de tener conexión a internet (si Google Drive está conectado)
- [ ] Revisa la consola para errores detallados

## Comandos Útiles

### Limpiar todo y reinstalar
```bash
flutter clean
flutter pub get
flutter run
```

### Ver logs en tiempo real
```bash
flutter logs
```

### Correr en modo debug
```bash
flutter run --debug
```

### Build APK (Android)
```bash
flutter build apk --release
```

### Build IPA (iOS)
```bash
flutter build ios --release
```

## Estructura de Carpetas Locales

Los backups se guardan en:
```
[Dispositivo]/Documents/note_backups/
├── [note-id]/
│   ├── backup_1234567890.json
│   └── backup_1234567891.json
└── [otra-note-id]/
    └── backup_1234567892.json
```

Las notas se guardan en SQLite:
```
[Dispositivo]/[AppData]/notes.db
```

## Rendimiento Esperado

- **Autosave**: < 100ms desde el guardado local
- **Sincronización Google Drive**: 1-5 segundos (depende de conexión)
- **Creación de backups**: < 50ms
- **Restauración de backups**: < 50ms

## Seguridad

⚠️ **Importante**: 

- Nunca commits archivos con credenciales
- El archivo `google-services.json` debe estar en `.gitignore`
- No compartir client secrets
- Los tokens se guardan de forma segura en el dispositivo

## Próximos Pasos

Después de probar, considera:

1. **Personalizar**: Ajusta debounce, número de backups, etc.
2. **Tests**: Añade pruebas unitarias y de integración
3. **CI/CD**: Configura GitHub Actions para builds automáticos
4. **Monitoreo**: Añade analytics para monitorear uso
5. **Feedback**: Recolecta feedback de usuarios

¡Disfruta usando NoteSphere! 🎉
