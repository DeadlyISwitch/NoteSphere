// Este archivo genera UUIDs 
import 'dart:math';

/// Utilidad simple para generar identificadores únicos.
/// En un entorno real, se recomendaría usar el paquete 'uuid'.
class UuidGenerator {
  /// Genera un ID pseudo-aleatorio basado en el timestamp actual.
  /// Esto es temporal hasta integrar una librería robusta.
  static String v4() {
    final Random random = Random();
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$timestamp-${random.nextInt(10000)}';
  }
}