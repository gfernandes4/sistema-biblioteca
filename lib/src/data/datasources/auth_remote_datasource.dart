import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/user.dart'; // Import UserType

/// DataSource remoto para autenticação
abstract class AuthRemoteDataSource {
  Future<String> login(String username, String password, UserType userType);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl({required this.apiService});

  @override
  Future<String> login(String username, String password, UserType userType) async {
    String endpoint;
    Map<String, String> body;

    if (userType == UserType.admin) {
      endpoint = ApiConstants.loginAdminEndpoint;
      body = {'usuario': username, 'senha': password};
    } else {
      // Assume UserType.school
      endpoint = ApiConstants.loginEscolaEndpoint;
      body = {'email': username, 'senha': password};
    }

    final response = await apiService.post(
      endpoint,
      body: body,
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
