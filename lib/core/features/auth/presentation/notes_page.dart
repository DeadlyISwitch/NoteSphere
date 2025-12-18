// P�gina de notas 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notes_controller.dart';
import 'note_detail_page.dart';

/// Pantalla principal de notas.
/// Muestra una lista y un FAB para crear nuevas notas.
class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado del controlador de notas
    final notesState = ref.watch(notesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Notas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              // TODO: Implementar activación de comandos de voz
            },
          )
        ],
      ),
      body: notesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(child: Text('No hay notas aún. Crea una.'));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note.title),
                subtitle: Text(
                  note.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => NoteDetailPage(note: note),
                  ));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ejemplo rápido de creación
          ref.read(notesControllerProvider.notifier).addNote(
                'Nota Nueva',
                'Contenido generado automáticamente',
              );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}