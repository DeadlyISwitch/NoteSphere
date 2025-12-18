// Repositorio de notas 
import '../domain/note_entity.dart';

/// Contrato para el manejo de datos de las notas.
/// Soportará SQLite (Local) y Firebase (Remoto) en el futuro.
abstract class NotesRepository {
/// Obtiene la lista completa de notas.
  Future<List<NoteEntity>> getNotes();

  /// Guarda una nueva nota o actualiza una existente.
  Future<void> saveNote(NoteEntity note);

  /// Elimina una nota por su ID.
  Future<void> deleteNote(String id);

  /// Sincroniza datos pendientes (para futura implementación Offline-first).
  Future<void> syncNotes();
}