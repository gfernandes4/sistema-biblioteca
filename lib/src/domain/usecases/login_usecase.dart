import '../entities/user.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../core/errors/failures.dart';

/// Use case para fazer login
class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase({required this.authRepository});

  /// Executa o login
  /// 
  /// Parâmetros:
  /// - [email]: Email do usuário
  /// - [password]: Senha do usuário
  /// 
  /// Retorna: [User] se o login for bem-sucedido
  /// Throws: [Failure] se ocorrer algum erro
  Future<User> call({
    required String email,
    required String password,
  }) async {
    // Validações básicas
    if (email.trim().isEmpty) {
      throw ValidationFailure(message: 'Email é obrigatório');
    }
    
    if (password.trim().isEmpty) {
      throw ValidationFailure(message: 'Senha é obrigatória');
    }
    
    if (!_isValidEmail(email)) {
      throw ValidationFailure(message: 'Email inválido');
    }
    
    // Executar login
    return await authRepository.login(email.trim(), password);
  }

  /// Validação simples de email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
