import '../repositories/auth_repository.dart';

/// Use case para fazer logout
class LogoutUseCase {
  final AuthRepository authRepository;

  LogoutUseCase({required this.authRepository});

  /// Executa o logout
  /// 
  /// Remove dados do usuário do dispositivo e finaliza sessão
  Future<void> call() async {
    await authRepository.logout();
  }
}
