import 'package:jwt_decoder/jwt_decoder.dart';

import '../../domain/entities/user.dart';
import '../../core/errors/failures.dart';
import '../../core/services/storage_service.dart';
import '../datasources/auth_remote_datasource.dart';

/// Interface do repositório de autenticação
abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<void> logout();
  bool get isLoggedIn;
  String? get currentUserType;
  String? get currentUserId;
}

/// Implementação do repositório de autenticação
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<User> login(String email, String password) async {
    try {
      // Fazer login via API
      final token = await remoteDataSource.login(email, password);
      
      // Decodificar o token para obter os dados do usuário
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final String userId = decodedToken['id'].toString();
      final String userRole = decodedToken['role'];

      // Salvar dados do usuário localmente
      await storageService.saveUserId(userId);
      await storageService.saveUserType(userRole);
      
      // Nota: O token já foi salvo pelo ApiService durante o login
      
      return User(id: userId, type: UserTypeExtension.fromString(userRole));
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw NetworkFailure(message: 'Erro durante login: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Fazer logout via API
      await remoteDataSource.logout();
      
      // Limpar dados locais
      await storageService.logout();
    } catch (e) {
      // Mesmo se o logout remoto falhar, limpar dados locais
      await storageService.logout();
      throw NetworkFailure(message: 'Erro durante logout: $e');
    }
  }

  @override
  bool get isLoggedIn => storageService.isLoggedIn;

  @override
  String? get currentUserType => storageService.getUserType();

  @override
  String? get currentUserId => storageService.getUserId();
}
