import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';

/// Serviço para armazenamento local de preferências
class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;
  final Logger _logger = Logger();

  StorageService._internal();

  factory StorageService() {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  /// Inicializa o SharedPreferences
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _logger.d('StorageService inicializado');
    } catch (e) {
      _logger.e('Erro ao inicializar StorageService: $e');
    }
  }

  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception('StorageService não foi inicializado. Chame init() primeiro.');
    }
    return _prefs!;
  }

  // === AUTH TOKEN ===
  
  /// Salva o token de autenticação
  Future<bool> saveAuthToken(String token) async {
    try {
      return await _preferences.setString(AppConstants.tokenKey, token);
    } catch (e) {
      _logger.e('Erro ao salvar token: $e');
      return false;
    }
  }

  /// Recupera o token de autenticação
  String? getAuthToken() {
    try {
      return _preferences.getString(AppConstants.tokenKey);
    } catch (e) {
      _logger.e('Erro ao recuperar token: $e');
      return null;
    }
  }

  /// Remove o token de autenticação
  Future<bool> removeAuthToken() async {
    try {
      return await _preferences.remove(AppConstants.tokenKey);
    } catch (e) {
      _logger.e('Erro ao remover token: $e');
      return false;
    }
  }

  // === USER TYPE ===
  
  /// Salva o tipo de usuário
  Future<bool> saveUserType(String userType) async {
    try {
      return await _preferences.setString(AppConstants.userTypeKey, userType);
    } catch (e) {
      _logger.e('Erro ao salvar tipo de usuário: $e');
      return false;
    }
  }

  /// Recupera o tipo de usuário
  String? getUserType() {
    try {
      return _preferences.getString(AppConstants.userTypeKey);
    } catch (e) {
      _logger.e('Erro ao recuperar tipo de usuário: $e');
      return null;
    }
  }

  // === USER ID ===
  
  /// Salva o ID do usuário
  Future<bool> saveUserId(String userId) async {
    try {
      return await _preferences.setString(AppConstants.userIdKey, userId);
    } catch (e) {
      _logger.e('Erro ao salvar ID do usuário: $e');
      return false;
    }
  }

  /// Recupera o ID do usuário
  String? getUserId() {
    try {
      return _preferences.getString(AppConstants.userIdKey);
    } catch (e) {
      _logger.e('Erro ao recuperar ID do usuário: $e');
      return null;
    }
  }

  // === THEME ===
  
  /// Salva o modo do tema
  Future<bool> saveThemeMode(String themeMode) async {
    try {
      return await _preferences.setString(AppConstants.themeKey, themeMode);
    } catch (e) {
      _logger.e('Erro ao salvar tema: $e');
      return false;
    }
  }

  /// Recupera o modo do tema
  String? getThemeMode() {
    try {
      return _preferences.getString(AppConstants.themeKey);
    } catch (e) {
      _logger.e('Erro ao recuperar tema: $e');
      return null;
    }
  }

  // === GENERIC METHODS ===
  
  /// Salva string
  Future<bool> setString(String key, String value) async {
    try {
      return await _preferences.setString(key, value);
    } catch (e) {
      _logger.e('Erro ao salvar string $key: $e');
      return false;
    }
  }

  /// Recupera string
  String? getString(String key) {
    try {
      return _preferences.getString(key);
    } catch (e) {
      _logger.e('Erro ao recuperar string $key: $e');
      return null;
    }
  }

  /// Salva boolean
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _preferences.setBool(key, value);
    } catch (e) {
      _logger.e('Erro ao salvar bool $key: $e');
      return false;
    }
  }

  /// Recupera boolean
  bool? getBool(String key) {
    try {
      return _preferences.getBool(key);
    } catch (e) {
      _logger.e('Erro ao recuperar bool $key: $e');
      return null;
    }
  }

  /// Salva int
  Future<bool> setInt(String key, int value) async {
    try {
      return await _preferences.setInt(key, value);
    } catch (e) {
      _logger.e('Erro ao salvar int $key: $e');
      return false;
    }
  }

  /// Recupera int
  int? getInt(String key) {
    try {
      return _preferences.getInt(key);
    } catch (e) {
      _logger.e('Erro ao recuperar int $key: $e');
      return null;
    }
  }

  /// Remove uma chave específica
  Future<bool> remove(String key) async {
    try {
      return await _preferences.remove(key);
    } catch (e) {
      _logger.e('Erro ao remover $key: $e');
      return false;
    }
  }

  /// Limpa todos os dados armazenados
  Future<bool> clear() async {
    try {
      return await _preferences.clear();
    } catch (e) {
      _logger.e('Erro ao limpar preferências: $e');
      return false;
    }
  }

  /// Verifica se o usuário está logado
  bool get isLoggedIn {
    final token = getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Faz logout removendo dados do usuário
  Future<bool> logout() async {
    try {
      await removeAuthToken();
      await remove(AppConstants.userTypeKey);
      await remove(AppConstants.userIdKey);
      _logger.d('Logout realizado com sucesso');
      return true;
    } catch (e) {
      _logger.e('Erro no logout: $e');
      return false;
    }
  }
}
