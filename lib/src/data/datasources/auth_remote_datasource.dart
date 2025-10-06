import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

/// DataSource remoto para autenticação
abstract class AuthRemoteDataSource {
  Future<String> login(String email, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl({required this.apiService});

  @override
  Future<String> login(String email, String password) async {
    final response = await apiService.post(
      ApiConstants.loginEscolaEndpoint,
      body: {
        'email': email,
        'senha': password,
      },
    ) as Map<String, dynamic>;

    final token = response['token'] as String;

    // Salvar token no ApiService para próximas requisições
    apiService.setAuthToken(token);

    return token;
  }

  @override
  Future<void> logout() async {
    // Limpar token do ApiService
    apiService.clearAuthToken();
    
    // Opcional: chamar endpoint de logout no backend
    // await apiService.post('/logout');
  }
}
