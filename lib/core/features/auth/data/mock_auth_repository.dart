// Mock implementation of AuthRepository for development and testing
import 'package:uuid/uuid.dart';

import '../domain/user_entity.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  UserEntity? _currentUser;
  final Uuid _uuid = const Uuid();

  @override
  Future<UserEntity?> getCurrentUser() async {
    // Simulate small delay
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentUser;
  }

  @override
  Future<void> signIn(String email, String password) async {
    // Simple mock sign in: accept any credentials
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = UserEntity(id: _uuid.v4(), email: email);
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentUser = null;
  }
}