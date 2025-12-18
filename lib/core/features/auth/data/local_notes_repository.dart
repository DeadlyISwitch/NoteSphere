// Implementación local de NotesRepository usando sqflite
import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../domain/note_entity.dart';
import 'notes_repository.dart';

class LocalNotesRepository implements NotesRepository {
  static final LocalNotesRepository _instance = LocalNotesRepository._internal();
  factory LocalNotesRepository() => _instance;
  LocalNotesRepository._internal();

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'notes.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes (
          id TEXT PRIMARY KEY,
          title TEXT,
          content TEXT,
          createdAt INTEGER,
          updatedAt INTEGER
        )
      ''');
    });
    return _db!;
  }

  @override
  Future<void> deleteNote(String id) async {
    final db = await _database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> saveNote(NoteEntity note) async {
    final db = await _database;
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<NoteEntity>> getNotes() async {
    final db = await _database;
    final maps = await db.query('notes', orderBy: 'createdAt DESC');
    return maps.map((m) => NoteEntity.fromMap(m)).toList();
  }

  @override
  Future<void> syncNotes() async {
    // Placeholder for future sync logic.
    return;
  }

  /// Close the database when the repository is disposed.
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
