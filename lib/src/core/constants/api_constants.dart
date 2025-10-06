/// Constantes para configuração da API
class ApiConstants {
  // URL base da API (assumindo que o backend Flask está rodando na porta 5000)
  static const String baseUrl = 'http://127.0.0.1:5000/api';
  
  // Endpoints da API
  static const String loginEscolaEndpoint = '/login/escola';
  static const String loginAdminEndpoint = '/login/admin';
  static const String booksEndpoint = '/livros';
  // O backend atual expõe busca via GET /livros?titulo=... e upload via POST /livros
  static const String searchEndpoint = '/livros';
  static const String uploadEndpoint = '/livros';
  // Endpoint para obter mudanças (deltas)
  static const String changesEndpoint = '/livros/changes';
  
  // Headers padrão
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000; // 30 segundos
}
