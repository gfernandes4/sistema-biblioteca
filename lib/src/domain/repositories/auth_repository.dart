import '../entities/user.dart';

/// Interface do repositório de autenticação.
///
/// Define o contrato para todas as operações relacionadas à autenticação,
/// abstraindo as fontes de dados (remota, local) da lógica de negócios.
abstract class AuthRepository {
  /// Realiza o login do usuário com email, senha e tipo.
  ///
  /// Em caso de sucesso, retorna um objeto [User] e salva a sessão localmente.
  /// Em caso de falha, lança uma exceção (ex: [AuthFailure], [NetworkFailure]).
  Future<User> login(String username, String password, UserType userType);

  /// Realiza o logout do usuário.
  ///
  /// Limpa todos os dados da sessão armazenados localmente e pode, opcionalmente,
  /// notificar um endpoint da API.
  Future<void> logout();

  /// Verifica de forma síncrona se o usuário está logado.
  ///
  /// Retorna `true` se um token de autenticação válido existir localmente.
  bool get isLoggedIn;

  /// Obtém o tipo (role) do usuário logado de forma síncrona.
  String? get currentUserType;

  /// Obtém o ID do usuário logado de forma síncrona.
  String? get currentUserId;

  /// Obtém o token de autenticação JWT do usuário logado.
  String? getAuthToken();

  /// Carrega os dados do usuário da sessão salva localmente.
  ///
  /// Retorna um objeto [User] se a sessão for válida, ou `null` se não houver
  /// sessão. Pode lançar [AuthFailure] se a sessão estiver corrompida.
  Future<User?> getSavedUser();
}
