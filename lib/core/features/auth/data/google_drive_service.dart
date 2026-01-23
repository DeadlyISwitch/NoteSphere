import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../domain/note_entity.dart';
import 'backup_service.dart';

/// Servicio de sincronización con Google Drive
class GoogleDriveService {
  static const String _appFolderName = 'NoteSphere';
  static const String _notesFileName = 'notes.json';
  static const String _backupsFileName = 'backups.json';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  GoogleSignInAccount? _currentUser;

  /// Obtiene el usuario actual
  GoogleSignInAccount? get currentUser => _currentUser;

  /// Obtiene el estado de autenticación
  Future<bool> isAuthenticated() async {
    _currentUser = await _googleSignIn.signInSilently();
    return _currentUser != null;
  }

  /// Realiza el login con Google
  Future<bool> signIn() async {
    try {
      final user = await _googleSignIn.signIn();
      _currentUser = user;
      return user != null;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  /// Realiza el logout
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  /// Obtiene el token de acceso
  Future<String?> _getAccessToken() async {
    try {
      final auth = await _currentUser?.authentication;
      return auth?.accessToken;
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  /// Obtiene el ID de la carpeta de la app en Google Drive
  Future<String?> _getAppFolderId(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/drive/v3/files?q=name="$_appFolderName" and mimeType="application/vnd.google-apps.folder" and trashed=false&spaces=drive&fields=files(id,name)&pageSize=1',
        ),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final files = data['files'] as List?;
        
        if (files != null && files.isNotEmpty) {
          return files[0]['id'] as String?;
        }
      }
    } catch (e) {
      print('Error getting app folder: $e');
    }
    return null;
  }

  /// Crea la carpeta de la app en Google Drive
  Future<String?> _createAppFolder(String accessToken) async {
    try {
      final body = jsonEncode({
        'name': _appFolderName,
        'mimeType': 'application/vnd.google-apps.folder',
      });

      final response = await http.post(
        Uri.parse('https://www.googleapis.com/drive/v3/files?fields=id'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'] as String?;
      }
    } catch (e) {
      print('Error creating app folder: $e');
    }
    return null;
  }

  /// Obtiene o crea el ID de la carpeta de la app
  Future<String?> _getOrCreateAppFolder(String accessToken) async {
    var folderId = await _getAppFolderId(accessToken);
    
    if (folderId == null) {
      folderId = await _createAppFolder(accessToken);
    }
    
    return folderId;
  }

  /// Sincroniza las notas con Google Drive
  Future<bool> syncNotes(List<NoteEntity> notes, BackupService backupService) async {
    try {
      if (_currentUser == null) return false;

      final accessToken = await _getAccessToken();
      if (accessToken == null) return false;

      final appFolderId = await _getOrCreateAppFolder(accessToken);
      if (appFolderId == null) return false;

      // Recopilar todos los backups
      final allBackups = <String, List<NoteBackup>>{};
      for (final note in notes) {
        allBackups[note.id] = await backupService.getBackups(note.id);
      }

      // Preparar datos para sincronizar
      final syncData = {
        'notes': notes.map((n) => n.toMap()).toList(),
        'backups': allBackups.map((noteId, backups) {
          return MapEntry(noteId, backups.map((b) => {
            'id': b.id,
            'noteData': b.noteData,
            'backupTime': b.backupTime.toIso8601String(),
          }).toList());
        }),
        'syncTime': DateTime.now().toIso8601String(),
      };

      // Subir archivo de notas
      final notesFile = await _uploadOrUpdateFile(
        accessToken: accessToken,
        fileName: _notesFileName,
        folderId: appFolderId,
        content: jsonEncode(syncData),
      );

      return notesFile != null;
    } catch (e) {
      print('Error syncing notes: $e');
      return false;
    }
  }

  /// Sube o actualiza un archivo en Google Drive
  Future<String?> _uploadOrUpdateFile({
    required String accessToken,
    required String fileName,
    required String folderId,
    required String content,
  }) async {
    try {
      // Buscar si el archivo ya existe
      final fileId = await _getFileId(
        accessToken: accessToken,
        fileName: fileName,
        folderId: folderId,
      );

      if (fileId != null) {
        // Actualizar archivo existente
        final response = await http.patch(
          Uri.parse(
            'https://www.googleapis.com/upload/drive/v3/files/$fileId?uploadType=media',
          ),
          headers: {'Authorization': 'Bearer $accessToken'},
          body: content,
        );

        if (response.statusCode == 200) {
          return fileId;
        }
      } else {
        // Crear nuevo archivo
        final metadata = jsonEncode({
          'name': fileName,
          'parents': [folderId],
        });

        final request = http.MultipartRequest(
          'POST',
          Uri.parse(
            'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&fields=id',
          ),
        )
          ..headers['Authorization'] = 'Bearer $accessToken'
          ..fields['metadata'] = metadata
          ..fields['file'] = content;

        final response = await request.send();
        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final data = jsonDecode(responseBody);
          return data['id'] as String?;
        }
      }
    } catch (e) {
      print('Error uploading/updating file: $e');
    }
    return null;
  }

  /// Obtiene el ID de un archivo en Google Drive
  Future<String?> _getFileId({
    required String accessToken,
    required String fileName,
    required String folderId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/drive/v3/files?q=name="$fileName" and "$folderId" in parents and trashed=false&fields=files(id)&pageSize=1',
        ),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final files = data['files'] as List?;
        
        if (files != null && files.isNotEmpty) {
          return files[0]['id'] as String?;
        }
      }
    } catch (e) {
      print('Error getting file id: $e');
    }
    return null;
  }

  /// Descarga las notas sincronizadas desde Google Drive
  Future<Map<String, dynamic>?> downloadNotes() async {
    try {
      if (_currentUser == null) return null;

      final accessToken = await _getAccessToken();
      if (accessToken == null) return null;

      final appFolderId = await _getAppFolderId(accessToken);
      if (appFolderId == null) return null;

      final fileId = await _getFileId(
        accessToken: accessToken,
        fileName: _notesFileName,
        folderId: appFolderId,
      );

      if (fileId == null) return null;

      final response = await http.get(
        Uri.parse('https://www.googleapis.com/drive/v3/files/$fileId?alt=media'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error downloading notes: $e');
    }
    return null;
  }
}
