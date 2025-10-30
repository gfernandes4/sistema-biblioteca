import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../core/errors/failures.dart';

/// Use case para fazer login
class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase({required this.authRepository});

  /// Executa o login
  ///
  /// Parâmetros:
  /// - [username]: Email do usuário
  /// - [password]: Senha do usuário
  ///
  /// Retorna: [User] se o login for bem-sucedido
  /// Throws: [Failure] se ocorrer algum erro
  Future<User> call({
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();

    // Validações básicas
    if (trimmedUsername.isEmpty) {
      throw ValidationFailure(message: 'Usuário/Email é obrigatório');
    }

    if (trimmedPassword.isEmpty) {
      throw ValidationFailure(message: 'Senha é obrigatória');
    }

    // Determina o tipo de usuário
    final UserType userType;
    if (trimmedUsername.toLowerCase() == 'admin@master.com') {
      userType = UserType.admin;
    } else {
      userType = UserType.school;
    }

    // Valida o formato do email
    //if (!_isValidEmail(trimmedUsername)) {
    //  throw ValidationFailure(message: 'Email inválido');
    //}

    // Executar login
    return await authRepository.login(
        trimmedUsername, trimmedPassword, userType);
  }

  ///  simples de email
  
}