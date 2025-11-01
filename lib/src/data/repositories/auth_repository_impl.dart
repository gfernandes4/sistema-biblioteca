import 'package:jwt_decoder/jwt_decoder.dart';

import '../../core/errors/failures.dart';
import '../../core/services/storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementação do repositório de autenticação.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<User> login(String username, String password, UserType userType) async {
    try {
      // 1. Fazer login via API para obter o token
      final token = await remoteDataSource.login(username, password, userType);
      await storageService.saveAuthToken(token);

      // 2. Decodificar o token para extrair informações do usuário
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final String userId = decodedToken['id'].toString();
      final String userRole = decodedToken['role'];
      // Opcional: Tenta extrair o nome do usuário do token, usa o email como fallback
      final String userName =
          decodedToken['name'] ?? decodedToken['nome'] ?? username;

      // 3. Salvar todos os dados relevantes localmente
      await storageService.saveUserId(userId);
      await storageService.saveUserType(userRole);
      await storageService.saveUserEmail(username);
      await storageService.saveUserName(userName);

      // 4. Retornar o objeto User completo
      return User(
        id: userId,
        type: UserTypeExtension.fromString(userRole),
        email: username,
        name: userName,
      );
    } catch (e) {
      // Em caso de erro, limpa qualquer dado de sessão que possa ter sido salvo
      await storageService.logout();
      if (e is Failure) {
        rethrow;
      }
      // Envolve exceções desconhecidas em um Failure padrão
      throw NetworkFailure(
          message: 'Não foi possível fazer login. Verifique sua conexão e credenciais.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Tenta fazer logout remoto, mas não bloqueia o usuário se falhar
      await remoteDataSource.logout();
    } finally {
      // A limpeza dos dados locais é a parte mais importante
      await storageService.logout();
    }
  }

  @override
  bool get isLoggedIn => storageService.isLoggedIn;

  @override
  String? get currentUserType => storageService.getUserType();

  @override
  String? get currentUserId => storageService.getUserId();

  @override
  String? getAuthToken() => storageService.getAuthToken();

  @override
  Future<User?> getSavedUser() async {
    if (!isLoggedIn) {
      return null;
    }

    // Busca os dados (síncronos) do storage
    final userId = storageService.getUserId();
    final userType = storageService.getUserType();
    final userEmail = storageService.getUserEmail();
    final userName = storageService.getUserName();

    // Valida se os dados essenciais da sessão existem
    if (userId == null || userType == null || userEmail == null) {
      // Se os dados estiverem incompletos, a sessão é considerada inválida.
      await storageService.logout();
      throw AuthFailure(
          message: 'Sessão inválida. Por favor, faça login novamente.');
    }

    // Retorna o usuário completo, usando o email como fallback para o nome
    return User(
      id: userId,
      type: UserTypeExtension.fromString(userType),
      email: userEmail,
      name: userName ?? userEmail,
    );
  }
}
