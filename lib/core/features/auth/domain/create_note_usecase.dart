// Caso de uso para crear nota 
import 'package:uuid/uuid.dart';
import '../data/notes_repository.dart';
import 'note_entity.dart';

/// Caso de uso explícito para la creación de notas.
/// Encapsula la lógica de negocio de inicialización de una nota.
class CreateNoteUseCase {
  final NotesRepository _repository;

  CreateNoteUseCase(this._repository);

  Future<void> call({required String title, required String content}) async {
    final newNote = NoteEntity(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );

    await _repository.saveNote(newNote);
  }
}