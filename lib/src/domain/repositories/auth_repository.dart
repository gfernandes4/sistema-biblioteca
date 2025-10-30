import '../entities/user.dart';

/// Interface do repositório de autenticação
abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<void> logout();
  bool get isLoggedIn;
  String? get currentUserType;
  String? get currentUserId;
  String? getAuthToken();
}
