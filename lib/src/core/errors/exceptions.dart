/// exceptions.dart
///
/// Define exceções personalizadas para a camada de dados.
/// Essas exceções são capturadas nos repositórios e convertidas em `Failure`.

/// Lançada quando ocorre um erro durante uma chamada à API.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException(message: $message, statusCode: $statusCode)';
}

/// Lançada quando ocorre um erro ao acessar dados em cache local.
class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Lançada para erros específicos de autenticação.
class AuthenticationException implements Exception {
  final String message;

  AuthenticationException({required this.message});

  @override
  String toString() => 'AuthenticationException(message: $message)';
}

/// Lançada para erros de validação de input antes de uma chamada de API.
class InputValidationException implements Exception {
    final String message;

    InputValidationException({required this.message});

    @override
    String toString() => 'InputValidationException(message: $message)';
}