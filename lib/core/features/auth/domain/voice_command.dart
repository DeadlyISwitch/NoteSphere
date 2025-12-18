// Comando de voz 
/// Define los comandos de voz que el sistema puede interpretar.
/// Usamos una clase sellada (sealed class) para manejo exhaustivo seguro.
sealed class VoiceCommand {
  const VoiceCommand();
}

/// Comando para crear una nueva nota.
class CreateNoteCommand extends VoiceCommand {
  final String content;
  const CreateNoteCommand(this.content);
}

/// Comando para buscar notas.
class SearchNoteCommand extends VoiceCommand {
  final String query;
  const SearchNoteCommand(this.query);
}

/// Comando no reconocido o error en el procesamiento.
class UnknownCommand extends VoiceCommand {
  const UnknownCommand();
}