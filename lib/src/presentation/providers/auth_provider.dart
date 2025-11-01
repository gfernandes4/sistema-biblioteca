// [COPIE E COLE ESTE ARQUIVO INTEIRO]
// Substitua todo o conteúdo de auth_provider.dart por este:

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

  // [NOVA FUNÇÃO - CORREÇÃO 2]
  /// Carrega o usuário do repositório ao iniciar o app.
  /// Isso resolve o problema do _currentUser ser nulo após reiniciar.
  Future<void> loadCurrentUserOnStartup() async {
    // Só executa se estiver logado E o usuário em memória for nulo
    if (isLoggedIn && _currentUser == null) {
      _setLoading(true);
      try {
        // [AÇÃO NECESSÁRIA]
        // Esta função (getSavedUser) precisa ser criada no seu repositório.
        // Ela deve ler os dados (id, email, tipo) do SecureStorage
        // e devolver um objeto User.
        final user = await authRepository.getSavedUser();
        _currentUser = user;
      } catch (e) {
        // Se falhar (ex: token inválido), faz logout
        await logout();
        _setError(_getErrorMessage(e));
      } finally {
        _setLoading(false);
      }
    }
  }


  /// Faz login
  Future<bool> login({
    required String username,
    required String password,
    required UserType userType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // 1. O loginUseCase é chamado.
      final user = await loginUseCase(
        username: username,
        password: password,
      );

      // 2. [A CORREÇÃO - PROBLEMA 1]
      //    Enriquece o objeto 'user' retornado com os dados que
      //    temos aqui (username), caso eles venham nulos do useCase.
      _currentUser = user.copyWith(
        email: user.email ?? username, // Usa 'username' (que é o email)
        name: user.name ?? username, // Usa o 'username' como fallback do nome
      );

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