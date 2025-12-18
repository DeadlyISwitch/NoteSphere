// Controlador de notas 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/note_entity.dart';
import '../data/notes_repository.dart';
import '../data/local_notes_repository.dart';
import '../domain/create_note_usecase.dart';

// Provider del repositorio local usando la implementación SQLite
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return LocalNotesRepository();
});

// Provider del caso de uso
final createNoteUseCaseProvider = Provider<CreateNoteUseCase>((ref) {
  return CreateNoteUseCase(ref.watch(notesRepositoryProvider));
});

/// Controlador que maneja la lista de notas mostradas en la UI.
class NotesController extends StateNotifier<AsyncValue<List<NoteEntity>>> {
  final NotesRepository _repository;
  final CreateNoteUseCase _createNoteUseCase;

  NotesController(this._repository, this._createNoteUseCase)
      : super(const AsyncValue.loading()) {
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
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final notesControllerProvider =
    StateNotifierProvider<NotesController, AsyncValue<List<NoteEntity>>>((ref) {
  final repo = ref.watch(notesRepositoryProvider);
  final useCase = ref.watch(createNoteUseCaseProvider);
  return NotesController(repo, useCase);
});