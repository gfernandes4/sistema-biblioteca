import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Serviço para armazenamento local de preferências (Singleton).
///
/// Garante uma única instância para gerenciar o SharedPreferences em todo o app.
/// É crucial chamar `await StorageService().init()` no `main.dart` antes de usar.
class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;
  final Logger _logger = Logger();

  StorageService._internal();

  factory StorageService() {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  /// Inicializa a instância do SharedPreferences.
  ///
  /// Deve ser chamado na inicialização do aplicativo para garantir que `_prefs` não seja nulo.
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _logger.i('StorageService inicializado com sucesso.');
    } catch (e) {
      _logger.e('Falha ao inicializar StorageService: $e');
      // Propaga o erro para que a inicialização do app possa tratá-lo.
      rethrow;
    }
  }

  /// Getter privado para o SharedPreferences.
  ///
  /// Lança uma exceção se o serviço for usado antes da inicialização.
  SharedPreferences get _preferences {
    if (_prefs == null) {
      const message =
          'StorageService não foi inicializado. Chame init() no main.dart.';
      _logger.f(message); // 'f' para erro fatal.
      throw Exception(message);
    }
    return _prefs!;
  }

  // === ESTADO DE AUTENTICAÇÃO ===

  /// Verifica se o usuário está logado (baseado na existência do token).
  bool get isLoggedIn => _preferences.containsKey(AppConstants.tokenKey);

  /// Limpa todos os dados de autenticação do usuário do armazenamento local.
  Future<void> logout() async {
    try {
      await _preferences.remove(AppConstants.tokenKey);
      await _preferences.remove(AppConstants.userIdKey);
      await _preferences.remove(AppConstants.userTypeKey);
      await _preferences.remove(AppConstants.userEmailKey);
      await _preferences.remove(AppConstants.userNameKey); // Limpa o nome do usuário
      _logger.i('Dados de sessão do usuário removidos (logout).');
    } catch (e) {
      _logger.e('Erro ao limpar dados de sessão no StorageService: $e');
    }
  }

  // === DADOS DE AUTENTICAÇÃO E USUÁRIO ===

  /// Salva o token de autenticação.
  Future<bool> saveAuthToken(String token) async {
    try {
      return await _preferences.setString(AppConstants.tokenKey, token);
    } catch (e) {
      _logger.e('Erro ao salvar token: $e');
      return false;
    }
  }

  /// Recupera o token de autenticação.
  String? getAuthToken() {
    try {
      return _preferences.getString(AppConstants.tokenKey);
    } catch (e) {
      _logger.e('Erro ao recuperar token: $e');
      return null;
    }
  }

  /// Salva o tipo de usuário (role).
  Future<bool> saveUserType(String userType) async {
    try {
      return await _preferences.setString(AppConstants.userTypeKey, userType);
    } catch (e) {
      _logger.e('Erro ao salvar tipo de usuário: $e');
      return false;
    }
  }

  /// Recupera o tipo de usuário.
  String? getUserType() {
    try {
      return _preferences.getString(AppConstants.userTypeKey);
    } catch (e) {
      _logger.e('Erro ao recuperar tipo de usuário: $e');
      return null;
    }
  }

  /// Salva o ID do usuário.
  Future<bool> saveUserId(String userId) async {
    try {
      return await _preferences.setString(AppConstants.userIdKey, userId);
    } catch (e) {
      _logger.e('Erro ao salvar ID do usuário: $e');
      return false;
    }
  }

  /// Recupera o ID do usuário.
  String? getUserId() {
    try {
      return _preferences.getString(AppConstants.userIdKey);
    } catch (e) {
      _logger.e('Erro ao recuperar ID do usuário: $e');
      return null;
    }
  }

  /// Salva o email do usuário.
  Future<bool> saveUserEmail(String email) async {
    try {
      return await _preferences.setString(AppConstants.userEmailKey, email);
    } catch (e) {
      _logger.e('Erro ao salvar email do usuário: $e');
      return false;
    }
  }

  /// Recupera o email do usuário.
  String? getUserEmail() {
    try {
      return _preferences.getString(AppConstants.userEmailKey);
    } catch (e) {
      _logger.e('Erro ao recuperar email do usuário: $e');
      return null;
    }
  }

  /// Salva o nome do usuário.
  Future<bool> saveUserName(String name) async {
    try {
      return await _preferences.setString(AppConstants.userNameKey, name);
    } catch (e) {
      _logger.e('Erro ao salvar nome do usuário: $e');
      return false;
    }
  }

  /// Recupera o nome do usuário.
  String? getUserName() {
    try {
      return _preferences.getString(AppConstants.userNameKey);
    } catch (e) {
      _logger.e('Erro ao recuperar nome do usuário: $e');
      return null;
    }
  }

  // === CONFIGURAÇÕES DO APP ===

  /// Salva o modo do tema (light/dark).
  Future<bool> saveThemeMode(String themeMode) async {
    try {
      return await _preferences.setString(AppConstants.themeKey, themeMode);
    } catch (e) {
      _logger.e('Erro ao salvar tema: $e');
      return false;
    }
  }

  /// Recupera o modo do tema.
  String? getThemeMode() {
    try {
      return _preferences.getString(AppConstants.themeKey);
    } catch (e) {
      _logger.e('Erro ao recuperar tema: $e');
      return null;
    }
  }
}
