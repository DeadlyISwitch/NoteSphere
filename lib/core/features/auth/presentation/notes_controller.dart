// Controlador de notas 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/note_entity.dart';
import '../data/notes_repository.dart';
import '../data/local_notes_repository.dart';
import '../data/google_drive_service.dart';
import '../data/backup_service.dart';
import '../domain/create_note_usecase.dart';

// Provider del repositorio local usando la implementación SQLite
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return LocalNotesRepository();
});

// Provider del caso de uso
final createNoteUseCaseProvider = Provider<CreateNoteUseCase>((ref) {
  return CreateNoteUseCase(ref.watch(notesRepositoryProvider));
});

// Provider de Google Drive Service
final googleDriveServiceProvider = Provider<GoogleDriveService>((ref) {
  return GoogleDriveService();
});

// Provider de Backup Service
final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});

// Provider del estado de autenticación con Google
final googleAuthProvider = FutureProvider<bool>((ref) async {
  final googleDrive = ref.watch(googleDriveServiceProvider);
  return await googleDrive.isAuthenticated();
});

// Provider del usuario actual de Google
final googleUserProvider = StateProvider<String?>((ref) {
  final googleDrive = ref.watch(googleDriveServiceProvider);
  return googleDrive.currentUser?.email;
});

/// Controlador que maneja la lista de notas mostradas en la UI.
class NotesController extends StateNotifier<AsyncValue<List<NoteEntity>>> {
  final NotesRepository _repository;
  final CreateNoteUseCase _createNoteUseCase;
  final GoogleDriveService _googleDriveService;
  final BackupService _backupService;

  NotesController(
    this._repository,
    this._createNoteUseCase,
    this._googleDriveService,
    this._backupService,
  ) : super(const AsyncValue.loading()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      final notes = await _repository.getNotes();
      state = AsyncValue.data(notes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addNote(String title, String content) async {
    try {
      await _createNoteUseCase(title: title, content: content);
      // Recargamos la lista tras añadir
      await loadNotes();
      
      // Sincronizar con Google Drive si está autenticado
      await _syncWithGoogleDrive();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateNote(String id, String title, String content) async {
    try {
      // Build updated note with updatedAt
      final currentList = state.asData?.value ?? [];
      final existing = currentList.firstWhere((n) => n.id == id,
          orElse: () => NoteEntity(
                id: id,
                title: title,
                content: content,
                createdAt: DateTime.now(),
              ));

      final updated = existing.copyWith(
        title: title,
        content: content,
        updatedAt: DateTime.now(),
      );

      await _repository.saveNote(updated);
      await loadNotes();
      
      // Sincronizar con Google Drive si está autenticado
      await _syncWithGoogleDrive();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      await _backupService.deleteAllBackups(id);
      await loadNotes();
      
      // Sincronizar con Google Drive si está autenticado
      await _syncWithGoogleDrive();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _syncWithGoogleDrive() async {
    try {
      if (_googleDriveService.currentUser != null) {
        final notes = state.asData?.value ?? [];
        await _googleDriveService.syncNotes(notes, _backupService);
      }
    } catch (e) {
      print('Error syncing with Google Drive: $e');
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      final success = await _googleDriveService.signIn();
      if (success) {
        // Sincronizar inmediatamente después del login
        await _syncWithGoogleDrive();
      }
      return success;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  Future<void> signOutFromGoogle() async {
    try {
      await _googleDriveService.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}

final notesControllerProvider =
    StateNotifierProvider<NotesController, AsyncValue<List<NoteEntity>>>((ref) {
  final repo = ref.watch(notesRepositoryProvider);
  final useCase = ref.watch(createNoteUseCaseProvider);
  final googleDrive = ref.watch(googleDriveServiceProvider);
  final backupService = ref.watch(backupServiceProvider);
  return NotesController(repo, useCase, googleDrive, backupService);
});