// Controlador de autenticaci�n 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_entity.dart';
import '../data/auth_repository.dart';
import '../data/mock_auth_repository.dart';

// Provider del repositorio de autenticación (mock para desarrollo)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

/// Gestiona el estado de autenticación de la aplicación.
class AuthController extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.loading()) {
    _checkAuthStatus();
  }

  /// Verifica si hay un usuario persistido al iniciar.
  Future<void> _checkAuthStatus() async {
    try {
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _repository.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signIn(email, password);
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider global para acceder al AuthController.
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserEntity?>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});