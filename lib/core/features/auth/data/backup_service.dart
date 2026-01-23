import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../domain/note_entity.dart';

/// Servicio de gestión de backups locales
/// Mantiene hasta 2 backups por nota
class BackupService {
  static const maxBackups = 2;
  static const backupDirName = 'note_backups';

  /// Obtiene el directorio de backups
  Future<Directory> _getBackupDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(path.join(appDocDir.path, backupDirName));
    
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    return backupDir;
  }

  /// Obtiene el directorio de backups para una nota específica
  Future<Directory> _getNoteBackupDirectory(String noteId) async {
    final backupDir = await _getBackupDirectory();
    final noteBackupDir = Directory(path.join(backupDir.path, noteId));
    
    if (!await noteBackupDir.exists()) {
      await noteBackupDir.create(recursive: true);
    }
    
    return noteBackupDir;
  }

  /// Crea un backup de la nota
  Future<void> createBackup(NoteEntity note) async {
    try {
      final backupDir = await _getNoteBackupDirectory(note.id);
      
      // Obtener backups existentes y ordenarlos por fecha
      final backups = <File>[];
      final dir = backupDir.listSync();
      
      for (final file in dir) {
        if (file is File && file.path.endsWith('.json')) {
          backups.add(file);
        }
      }
      
      // Ordenar por fecha de modificación (más recientes primero)
      backups.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      // Si hay 2 o más backups, eliminar los más antiguos
      if (backups.length >= maxBackups) {
        for (int i = maxBackups - 1; i < backups.length; i++) {
          await backups[i].delete();
        }
      }
      
      // Crear nuevo backup con timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFile = File(
        path.join(backupDir.path, 'backup_$timestamp.json')
      );
      
      final backupData = jsonEncode({
        'note': note.toMap(),
        'backupTime': timestamp,
      });
      
      await backupFile.writeAsString(backupData);
    } catch (e) {
      print('Error creating backup: $e');
    }
  }

  /// Obtiene todos los backups de una nota
  Future<List<NoteBackup>> getBackups(String noteId) async {
    try {
      final backupDir = await _getNoteBackupDirectory(noteId);
      final backups = <NoteBackup>[];
      
      final dir = backupDir.listSync();
      for (final file in dir) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final content = await file.readAsString();
            final data = jsonDecode(content) as Map<String, dynamic>;
            
            backups.add(NoteBackup(
              id: path.basenameWithoutExtension(file.path),
              noteData: data['note'] as Map<String, dynamic>,
              backupTime: DateTime.fromMillisecondsSinceEpoch(
                data['backupTime'] as int? ?? 0
              ),
              filePath: file.path,
            ));
          } catch (e) {
            print('Error reading backup file: $e');
          }
        }
      }
      
      // Ordenar por fecha de más reciente a más antigua
      backups.sort((a, b) => b.backupTime.compareTo(a.backupTime));
      return backups;
    } catch (e) {
      print('Error getting backups: $e');
      return [];
    }
  }

  /// Restaura una nota desde un backup
  Future<NoteEntity?> restoreBackup(NoteBackup backup) async {
    try {
      return NoteEntity.fromMap(backup.noteData);
    } catch (e) {
      print('Error restoring backup: $e');
      return null;
    }
  }

  /// Elimina todos los backups de una nota
  Future<void> deleteAllBackups(String noteId) async {
    try {
      final backupDir = await _getNoteBackupDirectory(noteId);
      if (await backupDir.exists()) {
        await backupDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error deleting backups: $e');
    }
  }

  /// Limpia todos los backups
  Future<void> clearAllBackups() async {
    try {
      final backupDir = await _getBackupDirectory();
      if (await backupDir.exists()) {
        await backupDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing all backups: $e');
    }
  }
}

/// Modelo para representar un backup
class NoteBackup {
  final String id;
  final Map<String, dynamic> noteData;
  final DateTime backupTime;
  final String filePath;

  NoteBackup({
    required this.id,
    required this.noteData,
    required this.backupTime,
    required this.filePath,
  });
}
