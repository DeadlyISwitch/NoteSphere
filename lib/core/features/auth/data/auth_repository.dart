// Repositorio de autenticaci�n 
import '../domain/user_entity.dart';

/// Contrato para el repositorio de autenticación.
/// Permite cambiar la implementación (Firebase, Mock, API) sin afectar el dominio.
abstract class AuthRepository {
  /// Obtiene el usuario actual si existe una sesión activa.
  Future<UserEntity?> getCurrentUser();

  /// Inicia sesión (implementación futura).
  Future<void> signIn(String email, String password);

  /// Cierra la sesión actual.
  Future<void> signOut();
}