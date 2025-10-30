/// Constantes para configuração da API
class ApiConstants {
  // URL base da API (assumindo que o backend Flask está rodando na porta 5000)
  static const String baseUrl = 'http://127.0.0.1:5000/api';
  
  // Endpoints de autenticação
  static const String loginEscolaEndpoint = '/login/escola';
  static const String loginAdminEndpoint = '/login/admin';
  
  // Endpoints de livros
  static const String booksEndpoint = '/livros';
  static const String searchEndpoint = '/livros';
  static const String uploadEndpoint = '/livros';
  static const String changesEndpoint = '/livros/changes';
  
  // Endpoints de escolas (gerenciamento pelo admin)
  static const String schoolsEndpoint = '/escolas';
  
  // Headers padrão
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000; // 30 segundos
}