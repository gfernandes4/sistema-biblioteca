/// Classe base para falhas/erros da aplicação
abstract class Failure {
  final String message;
  final int? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'Failure(message: $message, code: $code)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && 
           other.message == message && 
           other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Falhas relacionadas à rede/API
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Erro de conexão com o servidor',
    int? code,
  }) : super(message: message, code: code);
}

class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'Erro interno do servidor',
    int? code,
  }) : super(message: message, code: code);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    String message = 'Credenciais inválidas',
    int? code = 401,
  }) : super(message: message, code: code);
}

/// Falhas de validação
class ValidationFailure extends Failure {
  const ValidationFailure({
    String message = 'Dados inválidos',
    int? code = 400,
  }) : super(message: message, code: code);
}

/// Falhas relacionadas a livros
class BookNotFoundFailure extends Failure {
  const BookNotFoundFailure({
    String message = 'Livro não encontrado',
    int? code = 404,
  }) : super(message: message, code: code);
}

class BookUploadFailure extends Failure {
  const BookUploadFailure({
    String message = 'Erro ao fazer upload do livro',
    int? code = 500,
  }) : super(message: message, code: code);
}

/// Falhas do banco de dados local
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    String message = 'Erro no banco de dados local',
    int? code,
  }) : super(message: message, code: code);
}

/// Falhas de cache
class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Erro no cache local',
    int? code,
  }) : super(message: message, code: code);
}
