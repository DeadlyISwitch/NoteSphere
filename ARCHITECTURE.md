# 🏗️ Arquitectura de la Aplicación

## Diagrama General

```
┌─────────────────────────────────────────────────────────────┐
│                    CAPA DE PRESENTACIÓN                     │
├─────────────────────────────────────────────────────────────┤
│  NotesPage                                  NoteDetailPage   │
│  ├─ Lista de notas                          ├─ Editor       │
│  ├─ Botón Google Drive                      ├─ Autosave     │
│  ├─ Crear/Eliminar notas                    ├─ Backups UI   │
│  └─ UI para sincronización                  └─ Historial    │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                   CAPA DE CONTROLADORES                      │
├─────────────────────────────────────────────────────────────┤
│                    NotesController                           │
│  ├─ Gestiona estado global de notas (Riverpod)              │
│  ├─ Integra BackupService                                   │
│  ├─ Integra GoogleDriveService                              │
│  ├─ Sincronización automática                               │
│  └─ Métodos: loadNotes, addNote, updateNote, deleteNote     │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│               CAPA DE SERVICIOS Y CASOS DE USO               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────┐  ┌─────────────────┐               │
│  │  BackupService     │  │ GoogleDrive     │               │
│  │                    │  │ Service         │               │
│  │ ├─ createBackup    │  │                 │               │
│  │ ├─ getBackups      │  │ ├─ signIn       │               │
│  │ ├─ restoreBackup   │  │ ├─ signOut      │               │
│  │ └─ deleteBackups   │  │ ├─ syncNotes    │               │
│  │                    │  │ ├─ getAppFolder │               │
│  │                    │  │ └─ uploadFile   │               │
│  └────────────────────┘  └─────────────────┘               │
│                                                              │
└─────────────────────────────────────────────────────────────┘
           ↓                      ↓                ↓
    ┌──────────┐      ┌─────────────────┐  ┌──────────────┐
    │ Repository      │   Local Storage   │  │  Google     │
    │  Pattern        │   (SQLite)        │  │  Drive API  │
    └──────────┘      └─────────────────┘  └──────────────┘
```

## Flujo de Datos - Crear/Editar Nota

```
Usuario escribe
    ↓
NoteDetailPage (TextEditingController listener)
    ↓
_scheduleAutoSave() (Debounce 2 seg)
    ↓
_autoSave() 
    ↓
Crear backup:
├─ BackupService.createBackup()
│  ├─ Obtener directorio de backups
│  ├─ Ordenar backups existentes
│  ├─ Eliminar si hay ≥2 backups
│  └─ Guardar nuevo backup JSON
    ↓
Guardar en local:
├─ NotesController.updateNote()
│  ├─ Actualizar en memoria
│  ├─ LocalNotesRepository.saveNote()
│  │  └─ SQLite database (notes.db)
│  └─ Recargar lista de notas
    ↓
Sincronizar a la nube:
├─ GoogleDriveService.syncNotes() [async]
│  ├─ Verificar autenticación
│  ├─ Obtener token de acceso
│  ├─ Obtener/crear carpeta "NoteSphere"
│  ├─ Recopilar todos los backups
│  ├─ Subir JSON consolidado
│  └─ Retornar éxito/error
    ↓
UI Feedback:
├─ Mostrar "Guardado automático"
└─ Limpiar indicador (2 seg)
```

## Estructura de Directorios

```
lib/
├── main.dart
├── core/
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   └── uuid_generator.dart
│   └── features/
│       └── auth/
│           ├── app/
│           │   ├── app.dart
│           │   └── router.dart
│           ├── domain/
│           │   ├── note_entity.dart
│           │   └── create_note_usecase.dart
│           ├── data/
│           │   ├── notes_repository.dart (abstracto)
│           │   ├── local_notes_repository.dart
│           │   ├── backup_service.dart ✨ NUEVO
│           │   └── google_drive_service.dart ✨ NUEVO
│           └── presentation/
│               ├── notes_page.dart (ACTUALIZADO)
│               ├── note_detail_page.dart (ACTUALIZADO)
│               └── notes_controller.dart (ACTUALIZADO)
```

## Flujo de Backups

```
BackupService
├─ _getBackupDirectory()
│  └─ app_documents/note_backups/
├─ _getNoteBackupDirectory(noteId)
│  └─ app_documents/note_backups/{noteId}/
├─ createBackup(note)
│  ├─ Crear directorio si no existe
│  ├─ Obtener backups existentes
│  ├─ Ordenar por fecha
│  ├─ Eliminar más antiguos si ≥2
│  └─ Guardar nuevo backup: backup_{timestamp}.json
├─ getBackups(noteId)
│  ├─ Leer archivos JSON
│  ├─ Parsear a NoteBackup
│  ├─ Ordenar por fecha (recientes primero)
│  └─ Retornar lista
├─ restoreBackup(backup)
│  ├─ Parsear datos del backup
│  └─ Retornar NoteEntity restaurada
└─ deleteAllBackups(noteId)
   └─ Eliminar carpeta completa del backup
```

## Flujo de Google Drive

```
GoogleDriveService
├─ isAuthenticated()
│  └─ Verificar si hay usuario autenticado
├─ signIn()
│  ├─ Mostrar selector de cuenta Google
│  ├─ Obtener tokens de autenticación
│  └─ Retornar éxito/error
├─ signOut()
│  └─ Limpiar sesión
├─ _getAccessToken()
│  └─ Obtener token OAuth2 actual
├─ _getAppFolderId()
│  ├─ Buscar carpeta "NoteSphere" en Drive
│  └─ Retornar ID
├─ _createAppFolder()
│  ├─ Crear carpeta "NoteSphere"
│  └─ Retornar ID nuevo
├─ syncNotes()
│  ├─ Verificar autenticación
│  ├─ Obtener/crear carpeta app
│  ├─ Recopilar notas y backups
│  ├─ Crear JSON consolidado
│  ├─ Subir/actualizar archivo
│  └─ Retornar éxito/error
└─ downloadNotes()
   ├─ Obtener acceso a Drive
   ├─ Buscar archivo de notas
   ├─ Descargar JSON
   └─ Retornar datos
```

## Integración Riverpod

```
Providers:
├─ notesRepositoryProvider
│  └─ LocalNotesRepository (singleton)
├─ createNoteUseCaseProvider
│  └─ CreateNoteUseCase
├─ googleDriveServiceProvider ✨ NUEVO
│  └─ GoogleDriveService (singleton)
├─ backupServiceProvider ✨ NUEVO
│  └─ BackupService (singleton)
├─ googleAuthProvider ✨ NUEVO
│  └─ FutureProvider<bool> (check auth)
├─ googleUserProvider ✨ NUEVO
│  └─ StateProvider<String?> (current user)
└─ notesControllerProvider
   └─ StateNotifierProvider<NotesController>
      └─ Maneja AsyncValue<List<NoteEntity>>
```

## Flujo de Estados

```
NotesController (AsyncValue State)

NotesPage observa: ref.watch(notesControllerProvider)

Estados:
├─ Loading
│  └─ Mostrar CircularProgressIndicator
├─ Error
│  └─ Mostrar mensaje de error
└─ Data
   ├─ Si isEmpty: "No hay notas aún"
   └─ Si !isEmpty: ListView con notas
```

## Seguridad y Permisos

```
Local:
├─ SQLite (permisos del dispositivo)
└─ Archivos JSON backups (permisos del dispositivo)

Google Drive:
├─ OAuth 2.0 (tokens seguros)
├─ Scope: drive.file (solo archivos de la app)
├─ Sin credenciales hardcodeadas
└─ Tokens gestionados por google_sign_in
```

## Rendimiento Consideraciones

```
Debounce:
├─ 2 segundos entre guardados automáticos
└─ Previene múltiples escrituras durante edición rápida

Backups:
├─ Máximo 2 por nota (gestión de espacio)
├─ Almacenamiento local eficiente
└─ Eliminación automática de antiguos

Sincronización:
├─ Async (no bloquea UI)
├─ Ocurre después de cada guardado
├─ Requiere autenticación
└─ Reintenta en caso de error de conexión
```

## Componentes Clave

### NoteEntity
```dart
@immutable
class NoteEntity {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

### NoteBackup
```dart
class NoteBackup {
  final String id;
  final Map<String, dynamic> noteData;
  final DateTime backupTime;
  final String filePath;
}
```

## Testing Manual Checklist

- [ ] Autosave se activa al escribir
- [ ] Backups se crean automáticamente
- [ ] Máximo 2 backups por nota
- [ ] Botón historial muestra backups
- [ ] Restaurar backup funciona
- [ ] Google Drive conecta/desconecta
- [ ] Sincronización automática
- [ ] Ícono de estado se actualiza
- [ ] Deslizar para eliminar funciona
- [ ] Fechas se muestran correctamente
