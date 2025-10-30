import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/failures.dart';

/// Provider para gerenciar estado de autenticação
class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;

  AuthProvider({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  });

  // Estado
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => authRepository.isLoggedIn;
  String? get currentUserType => authRepository.currentUserType;

  /// Faz login
  Future<bool> login({
    required String username,
    required String password,
    required UserType userType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await loginUseCase(
        username: username,
        password: password,
      );
      _currentUser = user;
      _setLoading(false);
      notifyListeners(); // Notifica para atualizar a UI
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Faz logout
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await logoutUseCase();
      _currentUser = null;
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Verifica se usuário pode gerenciar livros (Admin ou Escola)
  bool get canManageBooks {
    final userType = currentUserType?.toLowerCase();
    return userType == 'admin' || 
           userType == 'escola' || 
           userType == 'school';
  }

  /// Verifica se usuário é admin
  bool get isAdmin {
    final userType = currentUserType?.toLowerCase();
    return userType == 'admin';
  }

  /// Verifica se usuário é escola
  bool get isSchool {
    final userType = currentUserType?.toLowerCase();
    return userType == 'escola' || userType == 'school';
  }

  /// Verifica se usuário é aluno
  bool get isStudent {
    final userType = currentUserType?.toLowerCase();
    return userType == 'student' || userType == 'aluno';
  }

  /// Define estado de carregamento
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Define mensagem de erro
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Limpa mensagem de erro
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa erro manualmente (para UI)
  void clearError() {
    _clearError();
  }

  /// Converte exceção em mensagem amigável
  String _getErrorMessage(dynamic error) {
    if (error is Failure) {
      return error.message;
    }
    return 'Erro inesperado: $error';
  }
}