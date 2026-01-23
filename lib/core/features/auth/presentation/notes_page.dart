// Página de notas 
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
    final googleAuthState = ref.watch(googleAuthProvider);
    final controller = ref.read(notesControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Notas'),
        actions: [
          googleAuthState.when(
            loading: () => const SizedBox(
              width: 50,
              child: Center(child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )),
            ),
            error: (err, stack) => IconButton(
              icon: const Icon(Icons.cloud_off),
              tooltip: 'Google Drive desconectado',
              onPressed: () => _showLoginDialog(context, ref, controller),
            ),
            data: (isAuthenticated) {
              return isAuthenticated
                  ? PopupMenuButton<String>(
                      icon: const Icon(Icons.cloud_done),
                      tooltip: 'Google Drive conectado',
                      onSelected: (value) {
                        if (value == 'logout') {
                          controller.signOutFromGoogle();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Text('Desconectar de Google'),
                        ),
                      ],
                    )
                  : IconButton(
                      icon: const Icon(Icons.cloud_off),
                      tooltip: 'Conectar Google Drive',
                      onPressed: () => _showLoginDialog(context, ref, controller),
                    );
            },
          ),
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
              return Dismissible(
                key: Key(note.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  controller.deleteNote(note.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nota eliminada')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  title: Text(note.title),
                  subtitle: Text(
                    note.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatDate(note.updatedAt ?? note.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => NoteDetailPage(note: note),
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(notesControllerProvider.notifier).addNote(
            'Nota Nueva',
            'Contenido generado automáticamente',
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoy ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == yesterday) {
      return 'Ayer ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showLoginDialog(BuildContext context, WidgetRef ref, NotesController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conectar a Google Drive'),
        content: const Text('Sincroniza tus notas automáticamente en la nube'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await controller.signInWithGoogle();
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Conectado a Google Drive'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al conectar'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text('Conectar'),
          ),
        ],
      ),
    );
  }
}