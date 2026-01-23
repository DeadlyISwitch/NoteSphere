import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../domain/note_entity.dart';
import '../data/backup_service.dart';
import 'notes_controller.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  final NoteEntity note;
  const NoteDetailPage({super.key, required this.note});

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  Timer? _autoSaveTimer;
  bool _isSaving = false;
  String _lastSavedStatus = '';
  final Duration _autoSaveDuration = const Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    
    // Añadir listeners para autosave
    _titleController.addListener(_scheduleAutoSave);
    _contentController.addListener(_scheduleAutoSave);
  }

  void _scheduleAutoSave() {
    // Cancelar timer anterior
    _autoSaveTimer?.cancel();
    
    // Programar nuevo autosave
    _autoSaveTimer = Timer(_autoSaveDuration, _autoSave);
  }

  Future<void> _autoSave() async {
    if (!mounted || _isSaving) return;
    
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    if (title.isEmpty && content.isEmpty) return;
    
    setState(() => _isSaving = true);
    
    try {
      final backupService = ref.read(backupServiceProvider);
      
      // Crear backup antes de guardar
      final updatedNote = widget.note.copyWith(
        title: title,
        content: content,
        updatedAt: DateTime.now(),
      );
      await backupService.createBackup(updatedNote);
      
      // Guardar la nota
      await ref
          .read(notesControllerProvider.notifier)
          .updateNote(widget.note.id, title, content);
      
      if (mounted) {
        setState(() {
          _lastSavedStatus = 'Guardado automático';
        });
        
        // Limpiar mensaje después de 2 segundos
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _lastSavedStatus = '');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _lastSavedStatus = 'Error al guardar');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _showBackupsDialog() async {
    final backupService = ref.read(backupServiceProvider);
    final backups = await backupService.getBackups(widget.note.id);
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historial de Backups'),
        content: backups.isEmpty
            ? const Text('No hay backups disponibles')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: backups.length,
                  itemBuilder: (context, index) {
                    final backup = backups[index];
                    return ListTile(
                      title: Text(
                        backup.noteData['title'] ?? 'Sin título',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Guardado: ${backup.backupTime.toString().split('.')[0]}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.restore),
                        tooltip: 'Restaurar',
                        onPressed: () {
                          _restoreBackup(backup);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _restoreBackup(NoteBackup backup) async {
    final backupService = ref.read(backupServiceProvider);
    final restoredNote = await backupService.restoreBackup(backup);
    
    if (restoredNote != null && mounted) {
      setState(() {
        _titleController.text = restoredNote.title;
        _contentController.text = restoredNote.content;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup restaurado')),
      );
      
      // Guardar automáticamente
      await Future.delayed(const Duration(milliseconds: 500));
      await _autoSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de nota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ver backups',
            onPressed: _showBackupsDialog,
          ),
          if (_lastSavedStatus.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  _lastSavedStatus,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenido',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
