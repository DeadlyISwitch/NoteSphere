// Entidad de nota 
import 'package:meta/meta.dart';

/// Entidad central de las notas.
/// Mantenemos la estructura simple e inmutable.
@immutable
class NoteEntity {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  /// Crea una copia de la nota con campos modificados.
  NoteEntity copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
  }) {
    return NoteEntity(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory NoteEntity.fromMap(Map<String, Object?> map) {
    return NoteEntity(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: map['updatedAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }
}