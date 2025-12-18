// Entidad de usuario 
import 'package:meta/meta.dart';

/// Entidad inmutable que representa al usuario en el dominio.
/// No debe contener lógica de serialización JSON (eso va en Data).
@immutable
class UserEntity {
  final String id;
  final String email;

  const UserEntity({
    required this.id,
    required this.email,
  });

  // Método helper para crear un usuario vacío/nulo si fuera necesario
  factory UserEntity.empty() => const UserEntity(id: '', email: '');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}